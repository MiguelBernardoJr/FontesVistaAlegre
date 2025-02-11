#include "TOTVS.CH"
#include 'TOPCONN.CH'
#include "TBICONN.CH"
#include "TBICODE.CH"
#include "FILEIO.CH"


/*/{Protheus.doc} VAESTR17
Rotina responsável por listar o saldo diario de cada era.
@author Renato de Bianchi
@since 17/05/2018
@version 1.0
@return ${nil}, ${Sem retorno}

@type function
/*/
user function VAESTR17()
local cMsg := ""
local aParams := GetParams()
local aMatrizFilial := {}
local aDias := {}
local aLinhasExcel := {}
local aLinha := {}
Local _oAppBk := oApp //Guardo a variavel resposavel por componentes visuais
local lReproc := aParams[6] == 1
local lMostra := .F.
Local nJ      := 0 
Local nI      := 0 
Local nX      := 0

	if (len(aParams) > 0)
		aFiliais := GetListFiliais(aParams[1], aParams[2])
		aDias := GetDiasFromPeriodo(aParams[3], aParams[4])
		
		dbSelectArea("SM0")
		_aAreaSM0 := SM0->(GetArea())
		_cEmpBkp := SM0->M0_CODIGO //Guardo a empresa atual
		_cFilBkp := SM0->M0_CODFIL //Guardo a filial atual
		
		for nX := 1 to len(aFiliais)
			aLinha := {}
			aAdd(aLinha, "FILIAL:")
			aAdd(aLinha, aFiliais[nX])
			aAdd(aLinhasExcel, aLinha)
			
			//Preenche o cabecalho da planilha
			aLinha := {}
			aAdd(aLinha, "ERA")
			for nJ := 1 to len(aDias)
				aAdd(aLinha, DTOC(aDias[nJ]))
			endFor
			aAdd(aLinha, "TOTAL")
			aAdd(aLinhasExcel, aLinha)
			
			//troco de empresa
			dbCloseAll() //Fecho todos os arquivos abertos
			OpenSM0() //Abrir Tabela SM0 (Empresa/Filial)
			dbSelectArea("SM0") //Abro a SM0
			SM0->(dbSetOrder(1))
			SM0->(dbSeek(cEmpAnt + aFiliais[nX],.T.)) //Posiciona Empresa
			cEmpAnt := SM0->M0_CODIGO //Seto as variaveis de ambiente
			cFilAnt := SM0->M0_CODFIL
			OpenFile(cEmpAnt + cFilAnt) //Abro a empresa que eu desejo trabalhar
			
			
			FWMsgRun(, {|| aMatrizFilial := U_GetMatrizSaldoErasPorDia(aFiliais[nX], aParams[3], aParams[4], lReproc, aParams) }, "Processando", "Obtendo dados da Filial " + aFiliais[nX])
			for nI := 1 to len(aMatrizFilial)
				aLinha := {}
				for nJ := 1 to len(aMatrizFilial[nI])
					//aAdd(aLinha, iif(valtype(aMatrizFilial[nI, nJ]) != "C", cValToChar(aMatrizFilial[nI, nJ]), aMatrizFilial[nI, nJ]))
					aAdd(aLinha, aMatrizFilial[nI, nJ])
				endFor
				aAdd(aLinhasExcel, aLinha)
			endFor
			aAdd(aLinhasExcel, {" "})
		endFor
		
		//Para finalizar volto as variaveis de sistema para seus valores antes da execução
		dbCloseAll() //Fecho todos os arquivos abertos
		OpenSM0() //Abrir Tabela SM0 (Empresa/Filial)
		dbSelectArea("SM0")
		SM0->(dbSetOrder(1))
		SM0->(RestArea(_aAreaSM0)) //Restaura Tabela
		cFilAnt := SM0->M0_CODFIL //Restaura variaveis de ambiente
		cEmpAnt := SM0->M0_CODIGO
		OpenFile(cEmpAnt + cFilAnt) //Abertura das tabelas
		oApp := _oAppBk //Backup do componente visual
		
		if lMostra
			for nI := 1 to len(aLinhasExcel)
				cMsg += CRLF
				for nJ := 1 to len(aLinhasExcel[nI])
					cMsg += "     "+iif(valtype(aLinhasExcel[nI, nJ]) != "C", cValToChar(aLinhasExcel[nI, nJ]), aLinhasExcel[nI, nJ])
				endFor
			endFor
			oDlg := MSDialog():New(0,0,700,1200,'Exibição do conteúdo',,,,,,,,,.T.)
				@ 020,050 GET oSay VAR cMsg OF oDlg MEMO PIXEL SIZE 500,300 READONLY
		  	oDlg:Activate(,,,.T.)
		else
			FWMsgRun(, {|| Excel(aParams[5], aLinhasExcel) }, "Finalizando processo", "Gerando arquivo Excel ")
		endIf
		
	else
		msgInfo("Nenhum parâmetro informado. Operação cancelada pelo usuário.")
	endIf
return


/*/{Protheus.doc} GetMatrizSaldoErasPorDia
Função que gera uma matriz relacionando o saldo das eras por cada dia para uma determinada filial.
@author Renato de Bianchi
@since 17/05/2018
@version 1.0
@return ${aMatriz}, ${Matriz contendo o saldo por dia de cada era}
@param cNumFilial, characters, Codigo da filial
@param dDtIni, date, Data inicial do periodo
@param dDtFim, date, Data final do periodo
@type function
/*/
User function GetMatrizSaldoErasPorDia(cNumFilial, dDtIni, dDtFim, lReproc, aParams)
local aMatriz := {}
local aDias := GetDiasFromPeriodo(dDtIni, dDtFim)
local aEras := GetErasFromDB()
local nTotEra := 0
local nJ      := 0
local nI      := 0
local aTotDia := {}
default lReproc := .F.

for nI := 1 to len(aEras)
	aAdd(aMatriz, {aEras[nI]})
	nTotEra := 0
	for nJ := 1 to len(aDias)
		nSaldo := GetSaldoDiarioFromEra(cNumFilial, aEras[nI], aDias[nJ]+1, lReproc, aParams)
		nTotEra += nSaldo
		
		nPosDia := aScan(aTotDia, {|x| x[1]==aDias[nJ]})
		if (nPosDia > 0)
			aTotDia[nPosDia, 2] += nSaldo
		else
			aAdd(aTotDia, {aDias[nJ], nSaldo})
		endIf
		
		aAdd(aMatriz[nI], nSaldo)
	endFor
	aAdd(aMatriz[nI], nTotEra)
endFor

aAdd(aMatriz, {"TOTAL P/ DIA"})
for nI := 1 to len(aTotDia)
	aAdd(aMatriz[len(aMatriz)], aTotDia[nI, 2])
endFor

return aMatriz


/*/{Protheus.doc} GetSaldoDiarioFromEra
Obtem o saldo de um determinado dia de uma era.
@author Renato de Bianchi
@since 17/05/2018
@version 1.0
@return ${nSaldo}, ${Saldo do dia da era informada}
@param cNumFilial, characters, Código da Filial
@param cEra, characters, Era desejada
@param dDia, date, Dia desejado
@type function
/*/
static function GetSaldoDiarioFromEra(cNumFilial, cEra, dDia, lReproc, aParams)
local nSaldo := 0
local cAliasQry := GetNextAlias()
default lReproc := .F.

	nRecCalc := HasCalcSalvo(cNumFilial, cEra, dDia)
	if nRecCalc == 0 .or. lReproc

		beginSQL alias cAliasQry
			%noParser%
	   		select B2_COD, B2_LOCAL
	   		  from %table:SB2% SB2
	   		 where B2_FILIAL=%exp:cNumFilial% and SB2.%notDel%
	   		   and B2_COD in (
			   		select B1_COD 
			   		  from %table:SB1% SB1
			   		 where B1_FILIAL=%xFilial:SB1% and SB1.%notDel%
			   		   and B1_X_ERA=%exp:cEra%
			   		   and B1_GRUPO between %exp:aParams[7]% and %exp:aParams[8]% 
						  and B1_GRUPO<>'LOTE'
			   )
			   and B2_LOCAL between %exp:aParams[9]% and %exp:aParams[10]%
		endSQL
		while !(cAliasQry)->(Eof())
			nSaldo += CalcEst((cAliasQry)->B2_COD,(cAliasQry)->B2_LOCAL, dDia)[1]
			(cAliasQry)->(dbSkip())
		endDo
		(cAliasQry)->(dbCloseArea())
	
	else
		dbSelectArea("Z01")
		dbGoTo(nRecCalc)
		nSaldo := Z01->Z01_SALDO
	endIf
	
	SaveCalcEra(cNumFilial, cEra, dDia, nSaldo, lReproc)
	
return nSaldo



/*/{Protheus.doc} HasCalcSalvo
verifica se ja existe calculo para esta era nesta data.
@author Renato de Bianchi
@since 17/05/2018
@version 1.0
@return ${nRecno}, ${Numero do R_E_C_N_O_ se encontrado}
@param cNumFilial, characters, Filial
@param cEra, characters, Era
@param dDia, date, Data
@type function
/*/
static function HasCalcSalvo(cNumFilial, cEra, dDia)
local nRecno := 0
local cAliasQry := GetNextAlias()

	beginSQL alias cAliasQry
		%noParser%
   		select R_E_C_N_O_ NUMREC //Z01_FILIAL, Z01_ERA, Z01_DATA, Z01_SALDO
   		  from %table:Z01% Z01
   		 where Z01_FILIAL=%exp:cNumFilial% and Z01.%notDel%
   		   and Z01_ERA=%exp:cEra%
		   and Z01_DATA=%exp:DToS(dDia)%
	endSQL
	if !(cAliasQry)->(Eof())
		nRecno := (cAliasQry)->NUMREC
	endIf
	(cAliasQry)->(dbCloseArea())

return nRecno



/*/{Protheus.doc} SaveCalcEra
Salva um determinado calculo de saldo de era no banco de dados
@author renat
@since 17/05/2018
@version 1.0
@return ${return}, ${return_description}
@param cNumFilial, characters, descricao
@param cEra, characters, descricao
@param dDia, date, descricao
@param nSaldo, numeric, descricao
@param lReproc, logical, descricao
@type function
/*/
static function SaveCalcEra(cNumFilial, cEra, dDia, nSaldo, lReproc)
local lRet := .T.
local cAliasQry := GetNextAlias()
default lReproc := .F.

	nRecCalc := HasCalcSalvo(cNumFilial, cEra, dDia)
	if nRecCalc != 0 .and. lReproc
		dbSelectArea("Z01")
		dbGoTo(nRecCalc)
		RecLock("Z01", .F.)
		Z01->(dbDelete())
		MsUnLock()
	endIf
	
	nRecCalc := HasCalcSalvo(cNumFilial, cEra, dDia)
	if nRecCalc == 0
		dbSelectArea("Z01")
		RecLock("Z01", .T.)
		Z01->Z01_FILIAL := cNumFilial
		Z01->Z01_ERA 	:= cEra
		Z01->Z01_DATA 	:= dDia
		Z01->Z01_SALDO 	:= nSaldo
		MsUnLock()
	endIf

return lRet


/*/{Protheus.doc} GetDiasFromPeriodo
Obtem um vetor com os dias entre duas datas.
@author Renato de Bianchi
@since 17/05/2018
@version 1.0
@return ${aDias}, ${Vetor dos dias entre as datas}
@param dDtIni, date, Data inicial
@param dDtFim, date, Data final
@type function
/*/
static function GetDiasFromPeriodo(dDtIni, dDtFim)
local aDias := {}
local dDtAux := dDtIni

if (!empty(dDtIni) .and. !empty(dDtFim) .and. dDtFim >= dDtIni)
	while dDtAux <= dDtFim
		aAdd(aDias, dDtAux)
		dDtAux += 1
	endDo
endIf

return aDias



/*/{Protheus.doc} GetErasFromDB
Obtem um vetor com as eras cadastradas no sistema.
@author Renato de Bianchi
@since 17/05/2018
@version 1.0
@return ${aEras}, ${Vetor com as eras}

@type function
/*/
static function GetErasFromDB()
local aEras := {}
local cAliasQry := GetNextAlias()

//Gera vetor com as eras encontradas
beginSQL alias cAliasQry
	%noParser%
	select distinct Z09_DESCRI
	  from %table:Z09% Z09
	 where Z09_FILIAL=%xFilial:Z09% and Z09.%notDel%
endSQL
while !(cAliasQry)->(Eof())
	aAdd(aEras, (cAliasQry)->Z09_DESCRI)
	(cAliasQry)->(dbSkip())
endDo
(cAliasQry)->(dbCloseArea())

return aEras



/*/{Protheus.doc} GetParams
Gera a tela de parametros da rotina.
@author renat
@since 17/05/2018
@version 1.0
@return ${aParams}, ${Vetor com os valores de cada parametro}

@type function
/*/
static function GetParams()
local aParams    := {}
local nI         := 0
local cPerg      := "VAER17"
local aPerguntas := {}

cPerg := PADR(cPerg,Len(SX1->X1_GRUPO))

/*Formato peguntas: TEXTO, TIPO, TAMANHO, DECIMAL, F3, OPCOES (OPCIONAL)*/
aAdd(aPerguntas, {'Filial de?    '			, 'C', TamSX3("D3_FILIAL")[1] , TamSX3("D3_FILIAL")[2] , 'SM0', {}})
aAdd(aPerguntas, {'Filial ate?   '			, 'C', TamSX3("D3_FILIAL")[1] , TamSX3("D3_FILIAL")[2] , 'SM0', {}})
aAdd(aPerguntas, {'Período de?   '			, 'D', TamSX3("D3_EMISSAO")[1], TamSX3("D3_EMISSAO")[2], '   ', {}})
aAdd(aPerguntas, {'Período de?   '			, 'D', TamSX3("D3_EMISSAO")[1], TamSX3("D3_EMISSAO")[2], '   ', {}})
aAdd(aPerguntas, {'Nome do Arquivo Excel?'	, 'C', 20 					  , 0					   , '   ', {}}) // aAdd(aPerguntas, {'Tipo de Saldo?', 'N', 1, 0, '   ', {'Por Trato', 'CalcEst'} })
aAdd(aPerguntas, {'Reprocessa Saldos?'		, 'N', 1 					  , 0					   , '   ', {'Sim','Nao'}}) // aAdd(aPerguntas, {'Tipo de Saldo?', 'N', 1, 0, '   ', {'Por Trato', 'CalcEst'} })
aAdd(aPerguntas, {'Grupo de?    '			, 'C', TamSX3("B1_GRUPO")[1]  , TamSX3("B1_GRUPO")[2]  , 'SBM', {}})
aAdd(aPerguntas, {'Grupo ate?   '			, 'C', TamSX3("B1_GRUPO")[1]  , TamSX3("B1_GRUPO")[2]  , 'SBM', {}})
aAdd(aPerguntas, {'Armazem de?    '			, 'C', TamSX3("B2_LOCAL")[1]  , TamSX3("B2_LOCAL")[2]  , 'NNR', {}})
aAdd(aPerguntas, {'Armazem ate?   '			, 'C', TamSX3("B2_LOCAL")[1]  , TamSX3("B2_LOCAL")[2]  , 'NNR', {}})

GeraSX1(cPerg, aPerguntas)

	if Pergunte(cPerg,.T.)
		for nI := 1 to len(aPerguntas)
			aAdd(aParams, &("mv_par"+StrZero(nI, 2)))
		next
	endIf

return aParams



/*/{Protheus.doc} GeraSX1
Função que gera os parametros na tabela SX1.
@author Renato de Bianchi
@since 17/05/2018
@version 1.0
@return ${return}, ${return_description}
@param cPerg, characters, Indice da pergunta
@param aPerguntas, array, Vetor com as perguntas no formato: TEXTO, TIPO, TAMANHO, DECIMAL, F3, OPCOES (OPCIONAL)
@type function
/*/
Static Function GeraSX1(cPerg, aPerguntas)
	Local aArea 	:= GetArea()
	Local i	  		:= 0
	Local j     	:= 0
	Local nI        := 0
	Local lInclui	:= .F.
	Local cTexto    := ''
	
	aRegs := {}
	for nI := 1 to len(aPerguntas)
		aAdd(aRegs,{cPerg, StrZero(nI, 2), aPerguntas[nI, 1],"","","mv_ch"+cValToChar(nI), aPerguntas[nI, 2], aPerguntas[nI, 3], aPerguntas[nI, 4],0,iif(len(aPerguntas[nI, 6]) > 0,"C","G"),"","mv_par"+StrZero(nI, 2),iif(len(aPerguntas[nI, 6]) > 0,aPerguntas[nI, 6, 1],""),"","","","",iif(len(aPerguntas[nI, 6]) > 1,aPerguntas[nI, 6, 2],""),"","","","",iif(len(aPerguntas[nI, 6]) > 2,aPerguntas[nI, 6, 3],""),"","","","",iif(len(aPerguntas[nI, 6]) > 3,aPerguntas[nI, 6, 4],""),"","","","",iif(len(aPerguntas[nI, 6]) > 4,aPerguntas[nI, 6, 5],""),"","","", aPerguntas[nI, 5],"N","","",""})
	next
	
	dbSelectArea("SX1")
	dbSetOrder(1)
	For i := 1 To Len(aRegs)
	 If lInclui := !dbSeek(cPerg + aRegs[i,2])
		 RecLock("SX1", lInclui)
		  For j := 1 to FCount()
		   If j <= Len(aRegs[i])
		    FieldPut(j,aRegs[i,j])
		   Endif
		  Next
		 MsUnlock()
		EndIf
	Next
	
	RestArea(aArea)
Return('SX1: ' + cTexto  + CHR(13) + CHR(10))



/*/{Protheus.doc} GetListFiliais
Obtem um vetor com as filiais em um determinado intervalo
@author Renato de Bianchi
@since 17/05/2018
@version 1.0
@return ${aFiliais}, ${Vetor com as filiais do intervalo}
@param cFilIni, characters, Filial inicial
@param cFilFim, characters, Filial final
@type function
/*/
static function GetListFiliais(cFilIni, cFilFim)
local aFiliais := {}

	dbSelectArea("SM0")
	_aAreaSM0 := SM0->(GetArea())
	
	dbSelectArea("SM0") 
	SM0->(dbSetOrder(1))
	SM0->(dbSeek(cEmpAnt + cFilIni,.T.)) //Posiciona Empresa
	
	while !SM0->(Eof()) .and. SM0->M0_CODFIL <= cFilFim
		aAdd(aFiliais, SM0->M0_CODFIL)
		SM0->(dbSkip())
	endDo
	
	//Para finalizar volto as variaveis de sistema para seus valores antes da execução
	dbSelectArea("SM0")
	SM0->(dbSetOrder(1))
	SM0->(RestArea(_aAreaSM0)) //Restaura Tabela
	
return aFiliais



/*/{Protheus.doc} Excel
Função responsavel por gerar um excel a partir de um vetor
@author Renato de Bianchi
@since 17/05/2018
@version 1.0
@return ${nil}, ${sem retorno}
@param cArquivo, characters, Nome do arquivo
@param aLinhasExcel, array, Vetor com as linhas do Excel
@type function
/*/
static function Excel(cArquivo, aLinhasExcel)
	cDiretorio	:= space(100)
	
	cDiretorio  := cGetFile(, 'Escolha o local do arquivo', 1, 'C:\', .T., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. )
	if right(cDiretorio,1)!='/' .and. right(cDiretorio,1)!='\'
		cDiretorio += "\"
	endIf
	
	if !empty(cArquivo)
		aCabec := {}
		aItens := aClone(aLinhasExcel)
		
		cArqGer := geraExcel( .F., aItens, aCabec, cDiretorio, cArquivo )
		CpyS2T(GetSrvProfString ("STARTPATH","")+cArqGer, Alltrim(cDiretorio))
		If (CpyS2T(GetSrvProfString ("STARTPATH","")+cArqGer, Alltrim(GetTempPath())))
			fErase(cArqGer)
			// Abre excell
			If !ApOleClient( 'MsExcel' )
				MsgAlert("O excel não foi encontrado. Arquivo " + cArqGer + " gerado em " + GetTempPath() + ".", "MsExcel não encontrado" )
			Else
				oExcelApp := MsExcel():New()
				oExcelApp:WorkBooks:Open( GetTempPath()+cArqGer )
				oExcelApp:SetVisible(.T.)
			EndIf
		Else
			MsgAlert("Não foi possivel criar o arquivo " + cArqGer + " no cliente no diretório " + GetTempPath() + ". Por favor, contacte o suporte.", "Não foi possivel criar Planilha." )
		EndIf
		msgInfo('Arquivo '+cDiretorio+cArqGer+" gerado com sucesso")
	endIf
return

/*/{Protheus.doc} geraExcel
Função que gera o XML do Excel.
@author Renato de Bianchi
@since 17/05/2018
@version 1.0
@return ${cFileName}, ${Caminho completo do arquivo}
@param lCabec, logical, Indica se usa cabeçalho
@param aItens, array, Vetor com itens a serem impressos
@param aCabec, array, Vetor com cabeçalho
@param cDirServer, characters, Caminho do arquivo
@param cNomeArq, characters, Nome do arquivo
@type function
/*/
static function geraExcel( lCabec, aItens, aCabec, cDirServer, cNomeArq )
	Local cCreate   := AllTrim( Str( Year( dDataBase ) ) ) + "-" + AllTrim( Str( Month( dDataBase ) ) ) + "-" + AllTrim( Str( Day( dDataBase ) ) ) + "T" + SubStr( Time(), 1, 2 ) + ":" + SubStr( Time(), 4, 2 ) + ":" + SubStr( Time(), 7, 2 ) + "Z" // string de data no formato <Ano>-<Mes>-<Dia>T<Hora>:<Minuto>:<Segundo>Z
	Local nRecords  := 0 // Numero de Linhas + Cabeçalho formato string
	Local cFileName :=  trim(cNomeArq)   //CriaTrab( , .F. )
	Local i, j
	
	Default lCabec := .F.
	
    if upper(right(trim(cNomeArq),3)) != "XLS"
	    cFileName := trim(cNomeArq) + ".xls" // "TESTE.XML"
	else
		cFileName := trim(cNomeArq)
	endif
	
	nRecords := Len( aItens)
		
	If ( nHandle := FCreate( cFileName , FC_NORMAL ) ) != -1
		ConOut("Arquivo criado com sucesso.")
	Else
		MsgAlert("Não foi possivel criar a planilha. Por favor, verifique se existe espaço em disco ou você possui pemissão de escrita no diretório", "Erro de criação de arquivo")
		ConOut("Não foi possivel criar a planilha no diretório")
	 Return()
	EndIf
		
	cFile := "<?xml version=" + Chr(34) + "1.0" + Chr(34) + "?>" + Chr(13) + Chr(10)
	cFile += "<?mso-application progid=" + Chr(34) + "Excel.Sheet" + Chr(34) + "?>" + Chr(13) + Chr(10)
	cFile += "<Workbook xmlns=" + Chr(34) + "urn:schemas-microsoft-com:office:spreadsheet" + Chr(34) + " " + Chr(13) + Chr(10)
	cFile += "	xmlns:o=" + Chr(34) + "urn:schemas-microsoft-com:office:office" + Chr(34) + " " + Chr(13) + Chr(10)
	cFile += "	xmlns:x=" + Chr(34) + "urn:schemas-microsoft-com:office:excel" + Chr(34) + " " + Chr(13) + Chr(10)
	cFile += "	xmlns:ss=" + Chr(34) + "urn:schemas-microsoft-com:office:spreadsheet" + Chr(34) + " " + Chr(13) + Chr(10)
	cFile += "	xmlns:html=" + Chr(34) + "http://www.w3.org/TR/REC-html40" + Chr(34) + ">" + Chr(13) + Chr(10)
	cFile += "	<DocumentProperties xmlns=" + Chr(34) + "urn:schemas-microsoft-com:office:office" + Chr(34) + ">" + Chr(13) + Chr(10)
	cFile += "		<Author>" + AllTrim(SubStr(cUsuario,7,15)) + "</Author>" + Chr(13) + Chr(10)
	cFile += "		<LastAuthor>" + AllTrim(SubStr(cUsuario,7,15)) + "</LastAuthor>" + Chr(13) + Chr(10)
	cFile += "		<Created>" + cCreate + "</Created>" + Chr(13) + Chr(10)
	cFile += "		<Company>Microsiga Intelligence</Company>" + Chr(13) + Chr(10)
	cFile += "		<Version>11.6568</Version>" + Chr(13) + Chr(10)
	cFile += "	</DocumentProperties>" + Chr(13) + Chr(10)
	cFile += "	<ExcelWorkbook xmlns=" + Chr(34) + "urn:schemas-microsoft-com:office:excel" + Chr(34) + ">" + Chr(13) + Chr(10)
	cFile += "		<WindowHeight>9345</WindowHeight>" + Chr(13) + Chr(10)
	cFile += "		<WindowWidth>11340</WindowWidth>" + Chr(13) + Chr(10)
	cFile += "		<WindowTopX>480</WindowTopX>" + Chr(13) + Chr(10)
	cFile += "		<WindowTopY>60</WindowTopY>" + Chr(13) + Chr(10)
	cFile += "		<ProtectStructure>False</ProtectStructure>" + Chr(13) + Chr(10)
	cFile += "		<ProtectWindows>False</ProtectWindows>" + Chr(13) + Chr(10)
	cFile += "	</ExcelWorkbook>" + Chr(13) + Chr(10)
	cFile += "	<Styles>" + Chr(13) + Chr(10)
	cFile += "		<Style ss:ID=" + Chr(34) + "Default" + Chr(34) + " ss:Name=" + Chr(34) + "Normal" + Chr(34) + ">" + Chr(13) + Chr(10)
	cFile += "			<Alignment ss:Vertical=" + Chr(34) + "Bottom" + Chr(34) + "/>" + Chr(13) + Chr(10)
	cFile += "			<Borders/>" + Chr(13) + Chr(10)
	cFile += "			<Font/>" + Chr(13) + Chr(10)
	cFile += "			<Interior/>" + Chr(13) + Chr(10)
	cFile += "			<NumberFormat/>" + Chr(13) + Chr(10)
	cFile += "			<Protection/>" + Chr(13) + Chr(10)
	cFile += "		</Style>" + Chr(13) + Chr(10)
	cFile += "	<Style ss:ID=" + Chr(34) + "s21" + Chr(34) + ">" + Chr(13) + Chr(10)
	cFile += "		<NumberFormat ss:Format=" + Chr(34) + "Short Date" + Chr(34) + "/>" + Chr(13) + Chr(10)
	cFile += "	</Style>" + Chr(13) + Chr(10)
	cFile += "	</Styles>" + Chr(13) + Chr(10)
	
 	cFile += " <Worksheet ss:Name=" + Chr(34) + "Fonte de Dados" /*"Plan1"*/ + Chr(34) + ">" + Chr(13) + Chr(10)
	cFile += "		<Table x:FullColumns=" + Chr(34) + "1" + Chr(34) + " x:FullRows=" + Chr(34) + "1" + Chr(34) + ">" + Chr(13) + Chr(10)
			
	If nHandle >=0
	 FWrite(nHandle, cFile)
	 cFile := ""
	Endif
				
	For i := 1 To nRecords
		cFile += "			<Row>" + Chr(13) + Chr(10)
		For j := 1 To len(aItens[i])
			cFile += "				" + FS_GetCell(aItens[i][j]) + Chr(13) + Chr(10)
		Next
		cFile += "			</Row>" + Chr(13) + Chr(10)
	 If (i % 100) == 0
	  If nHandle >=0
	   FWrite(nHandle, cFile)
		  cFile := ""
	  Endif
	 Endif
	Next
  
 	cFile += "		</Table>" + Chr(13) + Chr(10)
 	cFile += "		<WorksheetOptions xmlns=" + Chr(34) + "urn:schemas-microsoft-com:office:excel" + Chr(34) + ">" + Chr(13) + Chr(10)
	cFile += "			<PageSetup>" + Chr(13) + Chr(10)
	cFile += "				<Header x:Margin=" + Chr(34) + "0.49212598499999999" + Chr(34) + "/>" + Chr(13) + Chr(10)
	cFile += "				<Footer x:Margin=" + Chr(34) + "0.49212598499999999" + Chr(34) + "/>" + Chr(13) + Chr(10)
	cFile += "				<PageMargins x:Bottom=" + Chr(34) + "0.984251969" + Chr(34) + " x:Left=" + Chr(34) + "0.78740157499999996" + Chr(34) + " x:Right=" + Chr(34) + "0.78740157499999996" + Chr(34) + " x:Top=" + Chr(34) + "0.984251969" + Chr(34) + "/>" + Chr(13) + Chr(10)
	cFile += "			</PageSetup>" + Chr(13) + Chr(10)
	cFile += "			<Selected/>" + Chr(13) + Chr(10)
	cFile += "			<ProtectObjects>False</ProtectObjects>" + Chr(13) + Chr(10)
	cFile += "			<ProtectScenarios>False</ProtectScenarios>" + Chr(13) + Chr(10)
	cFile += "		</WorksheetOptions>" + Chr(13) + Chr(10)
	cFile += "	</Worksheet>" + Chr(13) + Chr(10)
  
	cFile += "	<Worksheet ss:Name=" + Chr(34) + "Plan2" + Chr(34) + ">" + Chr(13) + Chr(10)
	cFile += "		<WorksheetOptions xmlns=" + Chr(34) + "urn:schemas-microsoft-com:office:excel" + Chr(34) + ">" + Chr(13) + Chr(10)
	cFile += "			<PageSetup>" + Chr(13) + Chr(10)
	cFile += "				<Header x:Margin=" + Chr(34) + "0.49212598499999999" + Chr(34) + "/>" + Chr(13) + Chr(10)
	cFile += "				<Footer x:Margin=" + Chr(34) + "0.49212598499999999" + Chr(34) + "/>" + Chr(13) + Chr(10)
	cFile += "				<PageMargins x:Bottom=" + Chr(34) + "0.984251969" + Chr(34) + " x:Left=" + Chr(34) + "0.78740157499999996" + Chr(34) + " x:Right=" + Chr(34) + "0.78740157499999996" + Chr(34) + " x:Top=" + Chr(34) + "0.984251969" + Chr(34) + "/>" + Chr(13) + Chr(10)
	cFile += "			</PageSetup>" + Chr(13) + Chr(10)
	cFile += "			<ProtectObjects>False</ProtectObjects>" + Chr(13) + Chr(10)
	cFile += "			<ProtectScenarios>False</ProtectScenarios>" + Chr(13) + Chr(10)
	cFile += "		</WorksheetOptions>" + Chr(13) + Chr(10)
	cFile += "	</Worksheet>" + Chr(13) + Chr(10)
	cFile += "	<Worksheet ss:Name=" + Chr(34) + "Plan3" + Chr(34) + ">" + Chr(13) + Chr(10)
	cFile += "		<WorksheetOptions xmlns=" + Chr(34) + "urn:schemas-microsoft-com:office:excel" + Chr(34) + ">" + Chr(13) + Chr(10)
	cFile += "			<PageSetup>" + Chr(13) + Chr(10)
	cFile += "				<Header x:Margin=" + Chr(34) + "0.49212598499999999" + Chr(34) + "/>" + Chr(13) + Chr(10)
	cFile += "				<Footer x:Margin=" + Chr(34) + "0.49212598499999999" + Chr(34) + "/>" + Chr(13) + Chr(10)
	cFile += "				<PageMargins x:Bottom=" + Chr(34) + "0.984251969" + Chr(34) + " x:Left=" + Chr(34) + "0.78740157499999996" + Chr(34) + " x:Right=" + Chr(34) + "0.78740157499999996" + Chr(34) + " x:Top=" + Chr(34) + "0.984251969" + Chr(34) + "/>" + Chr(13) + Chr(10)
	cFile += "			</PageSetup>" + Chr(13) + Chr(10)
	cFile += "			<ProtectObjects>False</ProtectObjects>" + Chr(13) + Chr(10)
	cFile += "			<ProtectScenarios>False</ProtectScenarios>" + Chr(13) + Chr(10)
	cFile += "		</WorksheetOptions>" + Chr(13) + Chr(10)
	cFile += "	</Worksheet>" + Chr(13) + Chr(10)
	cFile += "</Workbook>" + Chr(13) + Chr(10)
	
	ConOut("Criando o arquivo " + cFileName + ".")
	If nHandle  >= 0
		FWrite(nHandle, cFile)
		FClose(nHandle)
		ConOut("Arquivo criado com sucesso.")
	Else
		MsgAlert("Não foi possivel criar a planilha. Por favor, verifique se existe espaço em disco ou você possui pemissão de escrita no diretório \system\", "Erro de criação de arquivo")
		ConOut("Não foi possivel criar a planilha no diretório \system\")
	EndIf
	
Return cFileName



/*/{Protheus.doc} FS_GetCell
Função que gera celulas do excel.
@author Andre Cruz
@since 17/05/2018
@version 1.0
@return ${cRet}, ${Texto da celula}
@param xVar, , Valor a ser convertido em celula
@type function
/*/
static function FS_GetCell( xVar )
	Local cRet  := ""
	Local cType := ValType(xVar)
	
	If cType == "U"
		cRet := "<Cell><Data ss:Type=" + Chr(34) + "General" + Chr(34) + "></Data></Cell>"
	ElseIf cType == "C"
		cRet := "<Cell><Data ss:Type=" + Chr(34) + "String" + Chr(34) + ">" + AllTrim( xVar ) + "</Data></Cell>"
	ElseIf cType == "N"
		cRet := "<Cell><Data ss:Type=" + Chr(34) + "Number" + Chr(34) + ">" + AllTrim( Str( xVar ) ) + "</Data></Cell>"
	ElseIf cType == "D"
		xVar := DToS( xVar )
	 	if empty(xVar)
			cRet := "<Cell ss:StyleID=" + Chr(34) + "s21" + Chr(34) + " />"
	 	else
			cRet := "<Cell ss:StyleID=" + Chr(34) + "s21" + Chr(34) + "><Data ss:Type=" + Chr(34) + "DateTime" + Chr(34) + ">" + SubStr(xVar, 1, 4) + "-" + SubStr(xVar, 5, 2) + "-" + SubStr(xVar, 7, 2) + "T00:00:00.000</Data></Cell>"
		endIf
	Else
		cRet := "<Cell><Data ss:Type=" + Chr(34) + "Boolean" + Chr(34) + ">" + Iif ( xVar , "=VERDADEIRO" ,  "=FALSO" ) + "</Data></Cell>"
	EndIf

Return cRet
