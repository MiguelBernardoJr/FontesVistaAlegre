#INCLUDE "TOTVS.CH"
#include "TopConn.ch"
#INCLUDE "FWPrintSetup.ch"
#include "ap5mail.ch"
#INCLUDE "RPTDEF.CH"

#define PAD_LEFT          0
#define PAD_RIGHT         1
#define PAD_CENTE         2


#DEFINE IMP_SPOOL 2

#DEFINE VBOX       080
#DEFINE HMARGEM    030
#DEFINE VMARGEM    030

/*
    Criar/Alterar Campos
    ==================================================================================================
    Campo	E1_NUMBCO(campo padrão, alterar apenas o tamanho)
    Tamanho	11

    Campo:			E1_NUMBOL
    Tipo:			C
    Tamanho:		11
    Decimal:		00
    Formato:		@!
    Contexto:		Real
    Propriedade:	Visualizar
    Titulo:			Noss.Núm
    Descrição:		Cópia do Nosso numero, serve para manter o nosso numero em casos de estorno de bordero

    Campo:			E1_IMPBOL
    Tipo:			C
    Tamanho:		 1
    Decimal:		00
    Formato:		@!
    Contexto:		Real
    Propriedade:	Visualizar
    Titulo:			Impr.Boleto
    Descrição:		Imprimiu Boleto.

    Campo:			E1_DVNSNUM
    Tipo:			C
    Tamanho:		1
    Decimal:		00
    Formato:		@!
    Contexto:		Real
    Propriedade:	Visualizar
    Titulo:			DV Noss.Núm
    Descrição:		Dig. Verifc. Nosso Número

    Campo:			E1_LINDIG
    Tipo:			C
    Tamanho			54
    Contexto:		Real
    Propriedade:	Visualizar
    Titulo:			Linha Dig
    Descrição:		Linha Digitavel do Boleto
    Help:			Trata-se da representação digitável do código de barras

    Campo:			E1_BARRA
    Tipo:			C
    Tamanho			44
    Contexto:		Real
    Propriedade:	Visualizar
    Titulo:			Cód Barras
    Descrição:		Código de barras
    Help:			Código de barras

    Campo:			A6_AGEBOL
    Tipo:			C
    Tamanho:		4
    Decimal:		00
    Contexto:		Real
    Propriedade:	Alterar
    Titulo:			Num.Age.Bol
    Descrição:		Num.Agencia Boleto
    Help:			Numero da agência para boleto, conforme pádrão exigido pelo banco para impressão/geração dos boletos.

    Campo:			A6_DVAGE
    Tipo:			C
    Tamanho:		2
    Decimal:		00
    Formato:		@!
    Contexto:		Real
    Propriedade:	Alterar
    Titulo:			DV AGENCIA
    Descrição:		Dig. Verifc. Agência

    Campo:			A6_CONBOL
    Tipo:			C
    Tamanho:		7
    Decimal:		00
    Contexto:		Real
    Propriedade:	Alterar
    Titulo:			Num.Con.Bol
    Descrição:		Num.Conta p/Boleto
    Help:			Numero da Conta Corrente para boleto, conforme pádrão exigido pelo banco para impressão/geração dos boletos.

    Campo:			A6_DVCC
    Tipo:			C
    Tamanho:		2
    Decimal:		00
    Formato:		@!
    Contexto:		Real
    Propriedade:	Alterar
    Titulo:			DV CC
    Descrição:		Dig. Verifc. Cta. Corr.

    Campo:			A6_PROXNUM
    Tipo:			C
    Tamanho:		11
    Decimal:		00
    Contexto:		Real
    Propriedade:	Alterar
    Titulo:			Seq. Boleto
    Descrição:		Sequencial do Boleto

    Campo:			A6_ACEITE
    Tipo:			C
    Tamanho:		02
    Decimal:		00
    Formato:		@!
    Contexto:		Real
    Propriedade:	Alterar
    Titulo:			Aceite
    Descrição:		Aceite

    Campo:		A6_ESPDOC
    Tipo:			C
    Tamanho:		03
    Decimal:		00
    Formato:		@!
    Contexto:		Real
    Propriedade:	Alterar
    Titulo:			Espéc.Documen
    Descrição:		Espécie do Documento

    Campo:			A6_ARQLOGO
    Tipo:			C
    Tamanho:		60
    Decimal:		00
    Formato:		@!
    Contexto:		Real
    Propriedade:	Alterar
    Titulo:			Arq Logotipo
    Descrição:		Arquivo do logotipo

    Campo:			A6_LOCPAG
    Tipo:			C
    Tamanho:		55
    Decimal:		00
    Formato:		@!
    Contexto:		Real
    Propriedade:	Alterar
    Titulo:			Local Pgto
    Descrição:		Local de Pagamento


    Campo*:			A6_INSTR1
    Tipo:			C
    Tamanho:		065
    Decimal:		00
    Contexto:		Real
    Propriedade:	Alterar
    Titulo:			Instrucão L1
    Descrição:		Instrucão da linha 1

    Campo*:			A6_INSTR2
    Tipo:			C
    Tamanho:		065
    Decimal:		00
    Formato:		@!
    Contexto:		Real
    Propriedade:	Alterar
    Titulo:			Instrucão L2
    Descrição:		Instrucão da linha 2

    Campo*:			A6_INSTR3
    Tipo:			C
    Tamanho:		065
    Decimal:		00
    Formato:		@!
    Contexto:		Real
    Propriedade:	Alterar
    Titulo:			Instrucão L3
    Descrição:		Instrucão da linha 3

    Campo*:			A6_INSTR4
    Tipo:			C
    Tamanho:		065
    Decimal:		00
    Contexto:		Real
    Propriedade:	Alterar
    Titulo:			Instrucão L4
    Descrição:		Instrucão da linha 4


    * As instruções são fórmulas. Utilize aspas para adicionar texto simples.

    ** Para utilizar a função de impressão de boletos utilize a matriz abaixo adicionando os boletos a serem impressos.
    BNF                 1          2       3           4          5          6           7       8           9        10
    aBoletos := '{' '{' A6_FILIAL, A6_COD, A6_AGENCIA, A6_NUMCON, E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, A1_FILIAL '}'
                    '{' A6_FILIAL, A6_COD, A6_AGENCIA, A6_NUMCON, E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, A1_FILIAL '}'
                    '{' A6_FILIAL, A6_COD, A6_AGENCIA, A6_NUMCON, E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, A1_FILIAL '}' }

    *** Especificidades
/*/

User Function VAFINBol(aItens, aLog, nTipoCart)
	Local nLen         := Len( aItens )
	Local i

	Private oPrn
	Private cPathServG := ""
	Private cPathServE := ""
	Private cPathTemp  := GETTEMPPATH()
	Private __cCodCart := ""

	If SE1->E1_PORTADO == "707" // Daycoval
		__cCodCart := "121"
	ElseIf SE1->E1_PORTADO == "237" // Bradesco
		__cCodCart := "04" //__cCodCart := "09"
	EndIf

	// Carregando dados do cedente
	DbSelectArea("SM0")
	DbSetOrder(1)

	ProcRegua( nLen )

	For i := 1 To nLen

		cPathServG := "'" + "\bol_gerados"  + "\" + aItens[i, 02] + "'"
		cPathServE := "'" + "\bol_enviados" + "\" + aItens[i, 02] + "'"

		IncProc( "Imprimindo titulos. Aguarde..." )

		// DbSelectArea("SE1")
		// DbSetOrder(1) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		// DbSeek( aItens[i, 5] + aItens[i, 6] + aItens[i, 7] + aItens[i, 8] + aItens[i, 9] )

		cPathServG    := &(GetNewPar("CH_DIRBOLG", cPathServG))

		if !ExistDir(cPathServG)
			u_CriaDir(cPathServG)
		endif

		cPathServE    := &(GetNewPar("CH_DIRBOL", cPathServE))

		if !ExistDir(cPathServE)
			u_CriaDir(cPathServE)
		endif

		//Nome: BOL1707_NUMERO_PARCELA+_CLIENTE+LOJA
		cNomArq       := "bol" + aItens[i, 2] + "_" + ;
			AllTrim(SE1->E1_NUM) + "-" + ;
			AllTrim(IIF(Empty(SE1->E1_PARCELA), "1", SE1->E1_PARCELA)) + "_" +;
			AllTrim(SE1->E1_CLIENTE) + AllTrim(SE1->E1_LOJA) + ".pdf"

		oPrn := FWMSPrinter():New(cNomArq, IMP_SPOOL, .F., , .T., , , , , , , .F.)
		oPrn:SetResolution(78) //Tamanho estipulado para a Danfe
		oPrn:SetPortrait()
		oPrn:SetPaperSize(DMPAPER_A4)
		oPrn:SetMargin(60,60,60,60)
		oPrn:nDevice  := IMP_PDF
		// ----------------------------------------------
		// Define para salvar o PDF
		// ----------------------------------------------f
		oPrn:cPathPDF := cPathTemp

		ProcBol(aItens[i], @aLog, nTipoCart)

		//Deleta se ja existir no TEMPfDayNossoNro
		FErase(oPrn:cPathPDF+cNomArq)

		oPrn:Preview() //Visualiza antes de imprimir 

		If !File(cPathServG)
			MAKEDIR(cPathServG)
		EndIf

		If !File(cPathServE)
			MAKEDIR(cPathServE)
		EndIf

		//Deleta se ja existir no Servidor
		FErase(cPathServG+"\"+cNomArq)
		//Copia PDF - TEMP para o Server (pasta Gerados)
		CpyT2S(oPrn:cPathPDF + cNomArq, cPathServG)

		FreeObj(oPrn)
		oPrn          := Nil
	Next

	If !Empty(aItens)
		U_MntTelDir(cPathServG+"\", aItens[1, 2])
	ENdIf
Return Len(aLog) > 0

/* ############################################################################## */
Static Function ProcBol(aItens, aLog, nTipoCart)
	Local aArea := GetArea()
	Local lRet  := .T.
	// Códigos do Banco
	Private cCodBco := aItens[ 02 ]

	// Características do Sacado
	Private cCliNome   := ""
	Private cCliEndere := ""
	Private cCliBairro := ""
	Private cCliCEP    := ""
	Private cCliMunici := ""
	Private cCliEstado := ""
	Private cCliCPFCNP := ""

	// Características do Banco
	Private cBcoCdBanc := ""
	Private cAgeCodCed := ""
	Private cBcoAgenci := ""
	Private cBcoDVAge  := ""
	Private cBcoConta  := ""
	Private cBcoDVCC   := ""
	Private cBcoNomBco := ""
	Private cBcoLogBco := ""
	Private cBcoCdComp := aItens[ 02 ] + '-' + "2"
	Private cBcoCdCart := "" // , cImpCart := ""
	Private cBcoAceite := ""
	Private cBcoEspDoc := ""
	Private cBcoLocPag := ""
	Private cBcoInstr1 := ""
	Private cBcoInstr2 := ""
	Private cBcoInstr3 := ""
	Private cBcoInstr4 := ""
	Private cBcoInstr5 := ""
	Private cBcoMenCS1 := ""
	Private cBcoMenCS2 := ""
	Private cBcoMenCS3 := ""

	// Características do Cedente
	Private cCedentNom := ""
	Private cCedentCNP := ""
	Private cCedentEnd := ""
	Private cCedentBai := ""
	Private cCedentMun := ""
	Private cCedentEst := ""
	Private cCedentCEP := ""
	Private cCedCodEnt := ""

	// Características do Boleto
	Private cBolDoc    := ""
	Private cBolMoeda  := ""
	Private cBolDscMoe := ""
	Private nBolValDoc := 0
	Private cBolValDoc := ""
	Private cBolDtFat  := ""
	Private cBolDtProc := ""
	Private cBolDtVenc := ""
	Private cBolAceite := ""
	Private cBolNosNum := ""
	Private cBolDVNsNm := ""
	Private cBolFatVnc := ""
	Private cBolDVCdBr := ""
	Private cBolCodBar := ""
	Private cBolDVLnDg := ""
	Private cBolLinDig := ""

	If aItens[5] + aItens[6] + aItens[7] + aItens[8] + aItens[9] <> ;
		SE1->(E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)
		// Carregando dados do Documento
		DbSelectArea("SE1")
		DbSetOrder(1) // E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
		If !DbSeek( aItens[5] + aItens[6] + aItens[7] + aItens[8] + aItens[9] )
			AAdd( aLog, "Erro Título " + aItens[6] + "-" + aItens[7] + ". Título não encontrado. Filial: " + aItens[5] + ", Prefíxo: " + aItens[6] + ", Numero: " + aItens[7] + ", Parcela: " + aItens[8] )
			Return .F.
		EndIf
	EndIf

	// Carregando dados do banco
	DbSelectArea("SA6")
	DbSetOrder(1) // A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
	If !DbSeek( aItens[1]+aItens[2]+aItens[3]+aItens[4] )
		AAdd( aLog, "Erro Título " + aItens[6] + "-" + aItens[7] + ". Banco não encontrado. Filial: " + aItens[1] + ", Banco: " + aItens[2] + ", Agencia: " + aItens[3] + ", Conta: " + aItens[4] )
		Return .F.
	EndIf

	// Carregando dados do Sacado
	DbSelectArea("SA1")
	DbSetOrder(1)
	If !DbSeek(aItens[10]+SE1->E1_CLIENTE+SE1->E1_LOJA)
		AAdd( aLog, "Erro Título " + aItens[6] + "-" + aItens[7] + ". Cliente não cadastrado. Filial: " + aItens[5] + ", Prefíxo: " + aItens[6] + ", Numero: " + aItens[7] + ", Parcela: " + aItens[8] )
		Return .F.
	EndIf
	
	If ( lRet := GetBolDado(aItens, @aLog, nTipoCart) )
		PrnLayout()
		DbSelectArea("SE1")
		// If Empty(SE1->E1_NUMBCO)
		If Empty(SE1->E1_DVNSNUM)
			RecLock( "SE1", .F. )
				SE1->E1_NUMBCO  := cBolNosNum // Nosso Número
				SE1->E1_NUMBOL  := cBolNosNum // COPIA DO Nosso Número
				SE1->E1_DVNSNUM := cBolDVNsNm // DV - Nosso Número
				SE1->E1_BARRA   := cBolCodBar // Código de barras
				SE1->E1_LINDIG  := cBolLinDig // Linha Digitável
				SE1->E1_IMPBOL  := "S"
			MsUnlock()
		EndIf
	EndIf

	If !Empty( aArea )
		RestArea( aArea )
	EndIf

Return lRet

/* ############################################################################## */
Static Function GetBolDado(aItens, aLog, nTipoCart)
	LOCAL nTotAbat	:= 0
	Local nTam 		

	cCedentNom := AllTrim(SM0->M0_NOMECOM) + ' - CNPJ: ' + SM0->M0_CGC
	cCedentCNP := SM0->M0_CGC
	cCedentEnd := SM0->M0_ENDCOB
	cCedentBai := SM0->M0_BAIRCOB
	cCedentMun := SM0->M0_CIDCOB
	cCedentEst := SM0->M0_ESTCOB
	cCedentCEP := SM0->M0_CEPCOB

	cCliNome   := SA1->A1_NOME
	cCliEndere := Iif( Empty( SA1->A1_ENDCOB ), SA1->A1_END, SA1->A1_ENDCOB )
	cCliBairro := Iif( Empty( SA1->A1_ENDCOB ), SA1->A1_BAIRRO, SA1->A1_BAIRROC )
	cCliCEP    := Transform(Iif( Empty( SA1->A1_ENDCOB ), SA1->A1_CEP, SA1->A1_CEPC ),"@r 99999-999")
	cCliMunici := Iif( Empty( SA1->A1_ENDCOB ), SA1->A1_MUN, SA1->A1_MUNC )
	cCliEstado := Iif( Empty( SA1->A1_ENDCOB ), SA1->A1_EST, SA1->A1_ESTC )
	cCliCPFCNP := Transform( SA1->A1_CGC, Iif( RetPessoa( SA1->A1_CGC ) == "J", "@R 99.999.999/9999-99", "@R 999.999.999-99" ) )


	cBcoAgenci := StrZero(Val(SA6->A6_AGEBOL), 4)
	cBcoDVAge  := AllTrim(SA6->A6_DVAGE)
	cBcoCdBanc := SA6->A6_COD
	cBcoNomBco := AllTrim(SA6->A6_NOME)
	cBcoLogBco := SA6->A6_ARQLOGO
	cBcoConta  := StrZero(Val(SA6->A6_CONBOL), 7)
	cBcoDVCC   := Alltrim(SA6->A6_DVCC)

	// If nTipoCart == 1 //Com Registro
		cBcoCdCart	:= __cCodCart // "121" // Carteira
		// cImpCart		 := "09"
	// EndIf

	cAgeCodCed := 	cBcoAgenci + IIF(!EMPTY(cBcoDVAge), "-" + cBcoDVAge, "") + " / " + cBcoConta + IIF(!EMPTY(cBcoDVCC), "-" + cBcoDVCC, "")

	cBcoAceite := SA6->A6_ACEITE
	cBcoEspDoc := SA6->A6_ESPDOC
	cBcoLocPag := SA6->A6_LOCPAG
	cBcoInstr1 := Iif( !Empty( SA6->A6_INSTR1 ), &( SA6->A6_INSTR1 ), " " )
	cBcoInstr2 := Iif( !Empty( SA6->A6_INSTR2 ), &( SA6->A6_INSTR2 ), " " )
	cBcoInstr3 := Iif( !Empty( SA6->A6_INSTR3 ), &( SA6->A6_INSTR3 ), " " )
	cBcoInstr4 := Iif( !Empty( SA6->A6_INSTR4 ), &( SA6->A6_INSTR4 ), " " )

	cBolDoc    := AllTrim(AllTrim(aItens[7]) + AllTrim(aItens[6]) + AllTrim(aItens[8]) )
	cBolMoeda  := "9"   // Definição da moeda para Títulos em Reais
	cBolDscMoe := "R$"

	nTotAbat   := SumAbatRec(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_MOEDA,"V") + SE1->E1_SDDECRE
	nBolValDoc := SE1->E1_SALDO - nTotAbat + SE1->E1_SDACRES
	cBolValDoc := Transform(nBolValDoc,"@E 999,999,999.99")

	cBolDtFat  := HS_DToC( SE1->E1_EMISSAO, 2 )
	cBolDtProc := HS_DToC( dDataBase, 2 )
	cBolDtVenc := HS_DToC( SE1->E1_VENCREA, 2 )

	if SE1->E1_PORTADO == '237'
		nTam := 11
	ELSE 
		nTam := 10
	ENDIF

	If ( cBolNosNum := PadL( AllTrim(GetNossNum(@aLog)), nTam, '0')) == Nil // Nosso número inválido
		AAdd( aLog, "Erro Título " + aItens[6] + "-" + aItens[7] + ". Título não encontrado. Filial: " + aItens[5] + ", Prefíxo: " + aItens[6] + ", Número: " + aItens[7] + ", Parcela: " + aItens[8] )
		Return .F.
	EndIf
	cBolFatVnc := GetFatVenc()
	If  ( cBolCodBar := GetCodBar() ) == Nil
		Return .F.
	EndIf
	cBolLinDig := GetLinDig(cBolCodBar)
Return .T.

Static Function GetNossNum(aLog)
	Local cNossNum   := ""
	Local cProxNum   := ""
	Local i
//	Local nLenNssNum := 10
	Local nLenNssNum 

	if SE1->E1_PORTADO = '237'
		nLenNssNum := 11
	else 
		nLenNssNum := 10
	ENDIF

	cBolDVNsNm     := ""

	If (!Empty(SE1->E1_NUMBCO) .OR. !Empty(SE1->E1_NUMBOL)) .AND.;
			SE1->E1_NUMBCO == PADR(SE1->E1_NUMBOL, TamSx3("E1_NUMBCO")[1])
		
		cNossNum   := SE1->E1_NUMBOL
		If Empty( SE1->E1_DVNSNUM )
			cBolDVNsNm := DVNsNm( AllTrim(cBcoAgenci+cBcoCdCart+cNossNum) )
		Else
			cBolDVNsNm := SE1->E1_DVNSNUM
		EndIf
	
	Else
		
		If Empty( SA6->A6_PROXNUM )
			cNossNum :=  StrZero( 1, nLenNssNum)
		Else
			// cNossNum := SubStr(AllTrim( PadL(Trim(SA6->A6_PROXNUM), nLenNssNum, '0') ), -nLenNssNum)
			cNossNum := SubStr(AllTrim( PadL(Trim(SA6->A6_PROXNUM), nLenNssNum, '0') ), -nLenNssNum)
			For i := 1 To nLenNssNum
				If SubStr( cNossNum, i, 1 ) < '0' .OR. SubStr( cNossNum, i, 1 ) > '9'
					AAdd( aLog, "Nº do boleto inválido. O nº encontrado em " + RetTitle("A6_PROXNUM") + " não é valido para o banco " + SA6->A6_COD + ". Por favor verifique." )
					Return Nil
				EndIf
			Next
		EndIf
		cNossNum := StrZero(Val(cNossNum), nLenNssNum)
		cProxNum := Soma1(cNossNum, nLenNssNum)

		// // - Range: 84580106 a 84580110 (Para testes)
		// // Obs.: Range definitivo será enviado quando estiver em produção.
		// If Val(cProxNum) > 84580110
		// 	cProxNum := PadL( '84580106', nLenNssNum, '0')
		// EndIf
		RecLock( "SA6" )
			SA6->A6_PROXNUM	:= cProxNum
		MsUnlock()

		cBolDVNsNm := DVNsNm( iIf(SE1->E1_PORTADO=="707", AllTrim(cBcoAgenci+cBcoCdCart+cNossNum), cBcoCdCart + AllTrim(cNossNum)) ) /* "19"+AllTrim(cNossNum) */ 
	EndIf
Return cNossNum

/*ROTINA PARA CÁLCULO DO DV DO NOSSO NÚMERO
	Sejam eles:
	AAAA = Código da agência do título, sem DV.
	CCC = Código da carteira (vide e-mail)
	NNNNNNNNNN O nosso número, sem DV

	Multiplica-se cada algarismo do número formado pela composição dos campos acima pela sequência
	de multiplicadores 2,1,2,1,2,1,2 (posicionados da direita para a esquerda).
	. Se a multiplicação resultar > 9 (por exemplo = 12), somar os dígitos (1 + 2).
	. A seguir, soma-se os algarismos dos produtos e o total obtido é dividido por 10. O DV é a diferença
	entre o divisor (10) e o resto da divisão:

	10 - (RESTO DA DIVISAO) = DV. Se o resto da divisão for zero, o DV é zero.
	EXEMPLO: Agência: 0001.9 Carteira = 121 Nosso Número = 0004309540

	O Nosso Número será a concatenação do código da agência (com DV), da carteira, do nosso número e
	do DV do nosso número. No exemplo: 00019/121/0004309540-8.
*/
Static Function DVNsNm(cNossNum)
	LOCAL cRet := "0"
    Local cAux    := ""
    LOCAL nPeso   := 2, i, j, nMult, nSoma := 0, nResto
    Local _nMod   := 10

	Do Case
		Case SE1->E1_PORTADO == "707" // Daycoval
			_nMod := 10
		Case SE1->E1_PORTADO == "237" // Bradesco
			_nMod := 11
		// Otherwise
	EndCase

    // cNossNum := Trim(SA6->A6_AGENCIA) + __cCodCart + cNossNum
	For i := Len(cNossNum) To 1 Step -1
		If SE1->E1_PORTADO == "707" // Daycoval
			If (nMult	:= ( nPeso * Val(substr(cNossNum,i,1)) )) > 0
				If nMult > 9
					// somar individualmente
					cAux := cValToChar(nMult)
					for j := Len(cAux) To 1 Step -1
						nSoma	+= Val(substr(cAux, j, 1))
					next j
				Else
					nSoma	+= nMult
				EndIf
			EndIf
			nPeso	:= if(nPeso==2, 1, 2)

		ElseIf SE1->E1_PORTADO == "237" // Bradesco
			nMult	:= ( nPeso * Val(substr(cNossNum,i,1)) )
			nSoma	+= nMult
			nPeso	:= if(nPeso==7,2,nPeso+1)
		EndIf
	Next i
	If (nResto := MOD(nSoma, _nMod)) > 0
		If SE1->E1_PORTADO == "707" // Daycoval
			cRet	:= AllTrim(Str(_nMod - nResto))
		ElseIf SE1->E1_PORTADO == "237" // Bradesco
			IF nResto == 1
				cRet	:= "P"
			ElseIf nResto == 0
				cRet	:= "0"
			ELSE
				cRet	:= AllTrim(Str(_nMod - nResto))
			ENDIF
		EndIf
	EndIf
Return(cRet)

/* ########################################################################################################## */
Static Function GetCodBar()
	LOCAL cCodBar := "", cValor := ""
	
  	RecLock("SE1", .F.)
		SE1->E1_BARRA := ""
	MsUnlock()  

	if SE1->E1_PORTADO == '237' 
		If Empty(SE1->E1_BARRA)
			cCodBar := cCodBco			// Codigo do banco
			cCodBar += "9"				// Codigo da Moeda "9" Real
			//Posição 5 = DV CodBar - Adiconado no final,depois do calculo
			cCodBar += SUBSTR(cBolFatVnc, 1, 4)	// Fator vencimento

			cValor := AllTrim(Str(Int(nBolValDoc)))
			cValor += Right("00"+AllTrim(Str((nBolValDoc-Int(nBolValDoc))*100)),2)
			cValor := Right("0000000000"+cValor, 10)
			cCodBar += cValor  // valor do documento

			//Inicio do Campo livre do CodBar Posicao 20 - 44 = Campo Livre
			cCodBar += cBcoAgenci // Agencia, 4 posicoes
			cCodBar += cBcoCdCart // Carteira, 2 posicoes
			
			cCodBar += cBolNosNum //nosso numero s/ DV, 11 posicoes
			//cCodBar += cBolDVNsNm // DV
			cCodBar += cBcoConta  // Codigo do cedente (fornecido pela agência), 7 posicoes
			cCodBar += "0"

			cBolDVCdBr := DvCdBar(cCodBar)

			cCodBar	   := substr(cCodBar,1,4) + cBolDVCdBr + substr(cCodBar,5,39)
		Else
			cCodBar := SE1->E1_BARRA
		EndIf 
 	else
		If Empty(SE1->E1_BARRA)
			cCodBar := cCodBco			// Codigo do banco
			cCodBar += "9"				// Codigo da Moeda "9" Real
			//Posição 5 = DV CodBar - Adiconado no final,depois do calculo
			cCodBar += SUBSTR(cBolFatVnc, 1, 4)	// Fator vencimento

			cValor := AllTrim(Str(Int(nBolValDoc)))
			cValor += Right("00"+AllTrim(Str((nBolValDoc-Int(nBolValDoc))*100)),2)
			cValor := Right("0000000000"+cValor, 10)
			cCodBar += cValor  // valor do documento

			//Inicio do Campo livre do CodBar Posicao 20 - 44 = Campo Livre
			cCodBar += cBcoAgenci //Agencia, 4 posicoes
			cCodBar += cBcoCdCart //Carteira, 2 posicoes
			
			cCodBar += cBcoConta  //Codigo do cedente (fornecido pela agência), 7 posicoes
			cCodBar += cBolNosNum //nosso numero s/ DV, 11 posicoes
			cCodBar += cBolDVNsNm //DV
			
			cBolDVCdBr := DvCdBar(cCodBar)

			cCodBar	   := substr(cCodBar,1,4) + cBolDVCdBr + substr(cCodBar,5,39)
		Else
			cCodBar := SE1->E1_BARRA
		EndIf
 	ENDIF 
Return(AllTRIM(cCodBar))

IIF(SE1->E1_INSTR1 != '',ALLTRIM(SE1->E1_INSTR1),00)

/* ########################################################################################################## */
Static Function GetLinDig(cBolCodBar)
	LOCAL cLinDig  := ""
	LOCAL cCampoLD	:= "" // Campo da linha digitavel
	
  	RecLock("SE1", .F.)
		SE1->E1_LINDIG := ""
	MsUnlock()  
	
	If Empty(SE1->E1_LINDIG)
		// Primeiro campo
		cCampoLD := Substr(cBolCodBar, 01, 03)		// Codigo do banco (posicao 1 a 3 da barra)
		cCampoLD += Substr(cBolCodBar, 04, 01)		// Codigo da moeda (posicao 4 da barra)
		cCampoLD += Substr(cBolCodBar, 20, 05)		// 5 Primeiras Campo Livre
		cCampoLD += DvLnDig(cCampoLD)	// digito verificador
		cLinDig := Substr(cCampoLD,01,05) + "." + Substr(cCampoLD,06,05) + Space(1)

		//Segundo Campo
		cCampoLD := Substr(cBolCodBar, 25, 10)		// 6 a 15 do campo livre
		cCampoLD += DvLnDig(cCampoLD)				// digito verificador
		cLinDig += Substr(cCampoLD,01,05) + "." + Substr(cCampoLD,06,06) + Space(1)

		//Terceiro Campo
		cCampoLD := Substr(cBolCodBar, 35, 10)		// 16 a 25 do campo livre
		cCampoLD += DvLnDig(cCampoLD)				// digito verificador
		cLinDig += Substr(cCampoLD,01,05) + "." + Substr(cCampoLD,06,06) + Space(1)

		//Quarto Campo
		cCampoLD := Substr(cBolCodBar, 05, 01)		// digito verificador geral da barra (posicao 5 da barra)
		cLinDig += cCampoLD + Space(1)

		//Quinto Campo - formar 14 posicoes
		cCampoLD := Substr(cBolCodBar, 06, 04)		// fator vencimento (posicao 06 a 09 da barra)
		cCampoLD += Strzero(val(Substr(cBolCodBar,10,10)),10) // valor do documento (posicao 10 a 19 da barra)
		cLinDig += cCampoLD
	Else
		cLinDig := SE1->E1_LINDIG
	EndIf
Return Transform( cLinDig, "@R 99999.99999 99999.999999 99999.999999 9 99999999999999" )

/* ########################################################################################################## */
Static Function Mod11( cString  )
	Local nLenCStrig := 0
	Local nSoma      := 0
	Local i          := 0
	Local j          := 1
	Local nResult    := 0

	Default cString := AllTrim( cString )
	nLenCStrig := Len( cString )

	For i := nLenCStrig To 1 Step - 1
		nSoma +=  Val( SubStr( cString, i, 1 ) ) * ( j := Iif( ( ++j ) > 9, 2, j ) )
	Next i


	If  (nSoma % 11) == 10 .or. (nSoma % 11) == 0
		nResult := 1
	ElseIf (nSoma % 11) == 1
		nResult := (nSoma % 11)
	Else
		nResult := (11 - (nSoma % 11))
	EndIf

Return AllTrim(Str(nResult))

/* ########################################################################################################## */
Static Function GetFatVenc()
	Local dDtaBase := CToD( "03/07/00" )

Return AllTrim( Str( 1000 + ( CToD(cBolDtVenc) - dDtaBase ) ) )


/* Calculo do digito verificador atraves do MODULO 10 e 11*/
Static Function DvLnDig(cCampoLD)
	LOCAL cRet
	LOCAL nPeso := 2, i, nMult, nSoma := 0, nResto

	For i := Len(cCampoLD) To 1 Step -1

		nMult	:= ( nPeso * Val(substr(cCampoLD,i,1)) )
		If nMult >= 10 // se a multiplicacao der 2 digitos
			nMult	:= val(substr(str(nMult,2),1,1)) + val(substr(str(nMult,2),2,1)) // soma os digitos
		Endif
		nSoma	+= nMult
		nPeso	:= if(nPeso==1,2,1)
	Next
	nSoma *= 9
/* 	if SE1->E1_PORTADO == '237'
		nResto	:= MOD(nSoma,11)
	else */
		nResto	:= MOD(nSoma,10)
/* 	ENDIF */

	cRet := AllTrim(Str(nResto))
	// IF nResto==0
	// 	cRet	:= "0"
	// ELSE
	// 	cRet	:= str(10 - nResto,1)
	// ENDIF

Return(cRet)

/*
MB : 16.05.2022
	FICHA DE COMPENSAÇÃO – CÓDIGO DE BARRAS
		Código do banco 3 posições = 707
		Moeda 1 posição = 9
		DV do código de barras 1 posição (vide abaixo)
		Fator de Vencimento 4 posições
		Valor do título 10 posições (sendo 2 casas
		decimais)
		Campo livre 25 posições, onde:
		Agência sem DV – 4 posições (vide
		e-mail)
		Carteira – 3 posições (vide e-mail)
		Operação – 7 posições (vide email)
		Nosso Número + DV – 11 posições
		(utilizar o range disponibilizado –
		vide e-mail)
		. (Resultado da multiplicação) / 11
		. Considerar o resto da divisão e fazer 11 – resto, para obter o DV,
		Observando:
		. Se o resultado da subtração for igual a 0 (Zero), 1 (um) ou maior que 9 (nove) deverão assumir o
		dígito igual a 1 (um).
		. Senão o DV será o próprio calculado acima.
*/
Static Function DvCdBar(cTexto)
	LOCAL cRet
	LOCAL nPeso := 2, i, nMult, nSoma := 0, nResto
	For i := Len(cTexto) To 1 Step -1
		nMult	:= ( nPeso * Val(substr(cTexto,i,1)) )
		nSoma	+= nMult
		nPeso	:= if(nPeso==9,2,nPeso+1)
	Next

	nResto	:= MOD(nSoma,11)

	if SE1->E1_PORTADO == '237'
		IF nResto==0 .OR. nResto==1 .OR. nResto>9  // se resultado da subtração igual a ZERO, UM ou MAIOR QUE 9
			cRet	:= "1"
		ELSE
			cRet	:= str(11 - nResto,1)
		ENDIF
	ELSE
		cRet	:= 11 - nResto
		IF nResto==0 .OR. nResto==1 .OR. nResto>9  // se resultado da subtração igual a ZERO, UM ou MAIOR QUE 9
			cRet	:= "1"
		ELSE
			cRet	:= str(cRet,1)
		ENDIF
	ENDIF
Return(cRet)

/* =========================================================================================== */
Static Function PrnLayout()
	PRIVATE oFont10N   := TFontEx():New(oPrn,"Times New Roman",08,08,.T.,.T.,.F.)// 1
	PRIVATE oFont07N   := TFontEx():New(oPrn,"Times New Roman",06,06,.T.,.T.,.F.)// 2
	PRIVATE oFont07    := TFontEx():New(oPrn,"Times New Roman",06,06,.F.,.T.,.F.)// 3
	PRIVATE oFont08    := TFontEx():New(oPrn,"Times New Roman",07,07,.F.,.T.,.F.)// 4
	PRIVATE oFont08N   := TFontEx():New(oPrn,"Times New Roman",06,06,.T.,.T.,.F.)// 5
	PRIVATE oFont09N   := TFontEx():New(oPrn,"Times New Roman",08,08,.T.,.T.,.F.)// 6
	PRIVATE oFont09    := TFontEx():New(oPrn,"Times New Roman",08,08,.F.,.T.,.F.)// 7
	PRIVATE oFont10    := TFontEx():New(oPrn,"Times New Roman",09,09,.F.,.T.,.F.)// 8
	PRIVATE oFont11    := TFontEx():New(oPrn,"Times New Roman",11,11,.F.,.T.,.F.)// 9
	PRIVATE oFont12    := TFontEx():New(oPrn,"Times New Roman",12,12,.F.,.T.,.F.)// 10
	PRIVATE oFont11N   := TFontEx():New(oPrn,"Times New Roman",11,11,.T.,.T.,.F.)// 11
	PRIVATE oFont18N   := TFontEx():New(oPrn,"Times New Roman",17,17,.T.,.T.,.F.)// 12
	PRIVATE OFONT12N   := TFontEx():New(oPrn,"Times New Roman",11,11,.T.,.T.,.F.)// 13
	PRIVATE OFONT14N   := TFontEx():New(oPrn,"Times New Roman",14,14,.T.,.T.,.F.)// 14
	PRIVATE OFONT15N   := TFontEx():New(oPrn,"Times New Roman",15,15,.T.,.T.,.F.)// 14

	oPrn:startpage()

	// parte 1
	// ---------------------------------------------------------------------------------------------------------
	If File(cBcoLogBco)
		oPrn:SayBitmap( 0001, 0010, cBcoLogBco, 0100, 0035 )
	Else
		oPrn:Say( 0025, 0010, cBcoNomBco, oFont12:oFont)
	EndIf

	oPrn:Say( 0025, 0155, "|" + cBcoCdComp + "|" , oFont15N:oFont)
	oPrn:Say( 0030, 0450, "RECIBO DE ENTREGA", oFont14N:oFont)

	oPrn:Box( 0035, 0010, 0060, 0400 )
	oPrn:Box( 0035, 0400, 0060, 0600 )
	oPrn:Say( 0045, 0015, "Pagador", oFont10:oFont)
	oPrn:Say( 0045, 0405, "Vencimento", oFont10:oFont)
	oPrn:Say( 0055, 0015, cCliNome, oFont11:oFont)
	oPrn:Say( 0055, 0530, cBolDtVenc, oFont11N:oFont)

	oPrn:Box( 0060, 0010, 0085, 0400 )
	oPrn:Box( 0060, 0400, 0085, 0600 )
	oPrn:Say( 0070, 0015, "Beneficiario", oFont10:oFont)
	oPrn:Say( 0070, 0405, "Agência/Código Beneficiario", oFont10:oFont)
	oPrn:Say( 0080, 0015, cCedentNom, oFont11:oFont)
	oPrn:Say( 0080, 0510, cAgeCodCed, oFont11N:oFont)

	oPrn:Box( 0085, 0010, 0110, 0065 )
	oPrn:Box( 0085, 0065, 0110, 0150 )
	oPrn:Box( 0085, 0150, 0110, 0190 )
	oPrn:Box( 0085, 0190, 0110, 0250 )
	oPrn:Box( 0085, 0250, 0110, 0400 )
	oPrn:Box( 0085, 0400, 0110, 0600 )
	oPrn:Say( 0095, 0015, "Dt Documento", oFont10:oFont)
	oPrn:Say( 0095, 0070, "Número do Documento", oFont10:oFont)
	oPrn:Say( 0095, 0155, "Esp.Doc.", oFont10:oFont)
	oPrn:Say( 0095, 0195, "Aceite", oFont10:oFont)
	oPrn:Say( 0095, 0255, "Data Processamento", oFont10:oFont)
	oPrn:Say( 0095, 0405, "Nosso Número", oFont10:oFont)
	oPrn:Say( 0105, 0015, cBolDtFat, oFont11:oFont)
	oPrn:Say( 0105, 0070, cBolDoc, oFont11:oFont)
	oPrn:Say( 0105, 0155, cBcoEspDoc, oFont11:oFont)
	oPrn:Say( 0105, 0195, cBcoAceite, oFont11:oFont)
	oPrn:Say( 0105, 0255, cBolDtProc, oFont11:oFont)
	oPrn:Say( 0105, 0500, cBcoCdCart + " / " + Alltrim(cBolNosNum) + Iif(!Empty(cBolDVNsNm),  + "-" + Alltrim(cBolDVNsNm), ""), oFont11N:oFont)

	oPrn:Box( 0110, 0010, 0135, 0065 )
	oPrn:Box( 0110, 0065, 0135, 0108 )
	oPrn:Box( 0110, 0108, 0135, 0150 )
	oPrn:Box( 0110, 0150, 0135, 0250 )
	oPrn:Box( 0110, 0250, 0135, 0400 )
	oPrn:Box( 0110, 0400, 0135, 0600 )
	oPrn:Say( 0120, 0015, "Uso do Banco", oFont10:oFont)
	oPrn:Say( 0120, 0070, "Carteira", oFont10:oFont)
	oPrn:Say( 0120, 0113, "Espécie", oFont10:oFont)
	oPrn:Say( 0120, 0155, "Quantidade", oFont10:oFont)
	oPrn:Say( 0120, 0255, "Valor", oFont10:oFont)
	oPrn:Say( 0120, 0405, "(=) Valor do Documento", oFont10:oFont)
	oPrn:Say( 0130, 0070, __cCodCart/* AllTrim(cImpCart) */, oFont11:oFont)
	oPrn:Say( 0130, 0113, cBolDscMoe, oFont11:oFont)
	oPrn:Say( 0130, 0520, cBolValDoc, oFont11N:oFont)

	oPrn:Say( 0150, 0050, "NOME DO RECEBEDOR (legivel)", oFont14N:oFont)
	oPrn:Say( 0150, 0250, Repl("_",55), oFont14N:oFont)
	oPrn:Say( 0170, 0050, "ASSINATURA DO RECEBEDOR", oFont14N:oFont)
	oPrn:Say( 0170, 0250, Repl("_",55), oFont14N:oFont)
	oPrn:Say( 0190, 0050, "DATA DO RECEBIMENTO", oFont14N:oFont)
	oPrn:Say( 0190, 0250, Repl("_",55), oFont14N:oFont)

	oPrn:Box( 0200, 0010, 0255, 0600 )
	oPrn:Say( 0210, 0020, "Pagador", oFont10:oFont)
	oPrn:Say( 0220, 0050, ALLTRIM(cCliNome) + " -CPF/CNPJ: " + ALLTRIM(cCliCPFCNP), oFont11:oFont)
	oPrn:Say( 0230, 0050, Alltrim(cCliEndere) + "-" + cCliBairro, oFont11:oFont)
	oPrn:Say( 0240, 0050, Alltrim(cCliMunici) + "/" + cCliEstado + "-CEP:" + cCliCEP, oFont11:oFont)
	oPrn:Say( 0250, 0020, "Pagador/Avalista", oFont10:oFont)
	oPrn:Say( 0265, 0010, Repl( "-", 235 ), oFont10:oFont)

	// Parte 2
	// ---------------------------------------------------------------------------------------------------------
	If File(cBcoLogBco)
		oPrn:SayBitmap( 0270, 0010, cBcoLogBco, 0100, 0035 )
	Else
		oPrn:Say( 0295, 0010, cBcoNomBco, oFont12:oFont)
	EndIf

	oPrn:Say( 0295, 0155, "|" + cBcoCdComp + "|" , oFont15N:oFont)
	oPrn:Say( 0300, 0450, "RECIBO DO PAGADOR", oFont14N:oFont)

	oPrn:Box( 0305, 0010, 0330, 0400 )
	oPrn:Box( 0305, 0400, 0330, 0600 )
	oPrn:Say( 0315, 0015, "Local de Pagamento", oFont10:oFont)
	oPrn:Say( 0315, 0405, "Vencimento", oFont10:oFont)
	oPrn:Say( 0325, 0015, cBcoLocPag, oFont11:oFont)
	oPrn:Say( 0325, 0530, cBolDtVenc, oFont11N:oFont)

	oPrn:Box( 0330, 0010, 0355, 0400 )
	oPrn:Box( 0330, 0400, 0355, 0600 )
	oPrn:Say( 0340, 0015, "Beneficiario", oFont10:oFont)
	oPrn:Say( 0340, 0405, "Agência/Código Beneficiario", oFont10:oFont)
	oPrn:Say( 0350, 0015, cCedentNom, oFont11:oFont)
	oPrn:Say( 0350, 0510, cAgeCodCed, oFont11N:oFont)

	oPrn:Box( 0355, 0010, 0380, 0065 )
	oPrn:Box( 0355, 0065, 0380, 0150 )
	oPrn:Box( 0355, 0150, 0380, 0190 )
	oPrn:Box( 0355, 0190, 0380, 0250 )
	oPrn:Box( 0355, 0250, 0380, 0400 )
	oPrn:Box( 0355, 0400, 0380, 0600 )
	oPrn:Say( 0365, 0015, "Dt Documento", oFont10:oFont)
	oPrn:Say( 0365, 0070, "Número do Documento", oFont10:oFont)
	oPrn:Say( 0365, 0155, "Esp.Doc.", oFont10:oFont)
	oPrn:Say( 0365, 0195, "Aceite", oFont10:oFont)
	oPrn:Say( 0365, 0255, "Data Processamento", oFont10:oFont)
	oPrn:Say( 0365, 0405, "Nosso Número", oFont10:oFont)
	oPrn:Say( 0375, 0015, cBolDtFat, oFont11:oFont)
	oPrn:Say( 0375, 0070, cBolDoc, oFont11:oFont)
	oPrn:Say( 0375, 0155, cBcoEspDoc, oFont11:oFont)
	oPrn:Say( 0375, 0195, cBcoAceite, oFont11:oFont)
	oPrn:Say( 0375, 0255, cBolDtProc, oFont11:oFont)
	oPrn:Say( 0375, 0500, cBcoCdCart + " / " + Alltrim(cBolNosNum) + Iif(!Empty(cBolDVNsNm),  + "-" + Alltrim(cBolDVNsNm), ""), oFont11N:oFont)

	oPrn:Box( 0380, 0010, 0405, 0065 )
	oPrn:Box( 0380, 0065, 0405, 0108 )
	oPrn:Box( 0380, 0108, 0405, 0150 )
	oPrn:Box( 0380, 0150, 0405, 0250 )
	oPrn:Box( 0380, 0250, 0405, 0400 )
	oPrn:Box( 0380, 0400, 0405, 0600 )
	oPrn:Say( 0390, 0015, "Uso do Banco", oFont10:oFont)
	oPrn:Say( 0390, 0070, "Carteira", oFont10:oFont)
	oPrn:Say( 0390, 0113, "Espécie", oFont10:oFont)
	oPrn:Say( 0390, 0155, "Quantidade", oFont10:oFont)
	oPrn:Say( 0390, 0255, "Valor", oFont10:oFont)
	oPrn:Say( 0390, 0405, "(=) Valor do Documento", oFont10:oFont)
	oPrn:Say( 0400, 0070, __cCodCart/* AllTrim(cImpCart) */, oFont11:oFont)
	oPrn:Say( 0400, 0113, cBolDscMoe, oFont11:oFont)
	oPrn:Say( 0400, 0520, cBolValDoc, oFont11N:oFont)

	oPrn:Box( 0405, 0010, 0505, 0400 )
	oPrn:Box( 0405, 0400, 0425, 0600 )
	oPrn:Say( 0415, 0015, "Instruções(Todas as iformações deste bloqueto são de responsabilidade do beneficiario)", oFont09:oFont)
	oPrn:Say( 0415, 0405, "(-) Desconto/Abatimento", oFont10:oFont)

	oPrn:Box( 0425, 0400, 0445, 0600 )
	oPrn:Say( 0435, 0405, "(-) Outras Deduções", oFont10:oFont)

	oPrn:Say( 0435, 0015, cBcoInstr1, oFont11:oFont)
	oPrn:Say( 0445, 0015, cBcoInstr2, oFont11:oFont)
	oPrn:Say( 0455, 0015, cBcoInstr3, oFont11:oFont)
	oPrn:Say( 0465, 0015, cBcoInstr4, oFont11:oFont)

	oPrn:Box( 0445, 0400, 0465, 0600 )
	oPrn:Say( 0455, 0405, "(+) Mora/Multa", oFont10:oFont)

	oPrn:Box( 0465, 0400, 0485, 0600 )
	oPrn:Say( 0475, 0405, "(+) Outros Acréscimos", oFont10:oFont)

	oPrn:Box( 0485, 0400, 0505, 0600 )
	oPrn:Say( 0495, 0405, "(=) Valor Cobrado", oFont10:oFont)

	oPrn:Box( 0505, 0010, 0550, 0600 )
	oPrn:Say( 0515, 0020, "Pagador", oFont10:oFont)
	oPrn:Say( 0515, 0050, ALLTRIM(cCliNome) + " - CPF/CNPJ: " + ALLTRIM(cCliCPFCNP), oFont11:oFont)
	oPrn:Say( 0525, 0050, Alltrim(cCliEndere) + "-" + cCliBairro, oFont11:oFont)
	oPrn:Say( 0535, 0050, Alltrim(cCliMunici) + "/" + cCliEstado + "-CEP:" + cCliCEP, oFont11:oFont)
	oPrn:Say( 0545, 0020, "Pagador/Avalista", oFont10:oFont)
	oPrn:Say( 0545, 0450, "Cód.Baixa", oFont10:oFont)
	oPrn:Say( 0545, 0500, "Autenticação Mecânica", oFont10:oFont)
	oPrn:Say( 0555, 0010, replicate("-", 235),oFont10:oFont)

	// parte 3
	// ---------------------------------------------------------------------------------------------------------
	If File(cBcoLogBco)
		oPrn:SayBitmap( 0560, 0010, cBcoLogBco, 0100, 0035 )
	Else
		oPrn:Say( 0585, 0010, cBcoNomBco, oFont12:oFont)
	EndIf

	oPrn:Say( 0585, 0155, "|" + cBcoCdComp + "|" , oFont15N:oFont)
	oPrn:Say( 0585, 0280, cBolLinDig, oFont15N:oFont)

	oPrn:Box( 0595, 0010, 0620, 0400 )
	oPrn:Box( 0595, 0400, 0620, 0600 )
	oPrn:Say( 0605, 0015, "Local de Pagamento", oFont10:oFont)
	oPrn:Say( 0605, 0405, "Vencimento", oFont10:oFont)
	oPrn:Say( 0615, 0015, cBcoLocPag, oFont11:oFont)
	oPrn:Say( 0615, 0530, cBolDtVenc, oFont11N:oFont)

	oPrn:Box( 0620, 0010, 0645, 0400 )
	oPrn:Box( 0620, 0400, 0645, 0600 )
	oPrn:Say( 0630, 0015, "Beneficiario", oFont10:oFont)
	oPrn:Say( 0630, 0405, "Agência/Código Beneficiario", oFont10:oFont)
	oPrn:Say( 0640, 0015, cCedentNom, oFont11:oFont)
	oPrn:Say( 0640, 0510, cAgeCodCed, oFont11N:oFont)

	oPrn:Box( 0645, 0010, 0670, 0065 )
	oPrn:Box( 0645, 0065, 0670, 0150 )
	oPrn:Box( 0645, 0150, 0670, 0190 )
	oPrn:Box( 0645, 0190, 0670, 0250 )
	oPrn:Box( 0645, 0250, 0670, 0400 )
	oPrn:Box( 0645, 0400, 0670, 0600 )
	oPrn:Say( 0655, 0015, "Dt Documento", oFont10:oFont)
	oPrn:Say( 0655, 0070, "Número do Documento", oFont10:oFont)
	oPrn:Say( 0655, 0155, "Esp.Doc.", oFont10:oFont)
	oPrn:Say( 0655, 0195, "Aceite", oFont10:oFont)
	oPrn:Say( 0655, 0255, "Data Processamento", oFont10:oFont)
	oPrn:Say( 0655, 0405, "Nosso Número", oFont10:oFont)
	oPrn:Say( 0665, 0015, cBolDtFat, oFont11:oFont)
	oPrn:Say( 0665, 0070, cBolDoc, oFont11:oFont)
	oPrn:Say( 0665, 0155, cBcoEspDoc, oFont11:oFont)
	oPrn:Say( 0665, 0195, cBcoAceite, oFont11:oFont)
	oPrn:Say( 0665, 0255, cBolDtProc, oFont11:oFont)
	oPrn:Say( 0665, 0500, cBcoCdCart + " / " + Alltrim(cBolNosNum) + Iif(!Empty(cBolDVNsNm),  + "-" + Alltrim(cBolDVNsNm), "" ), oFont11N:oFont)

	oPrn:Box( 0670, 0010, 0695, 0065 )
	oPrn:Box( 0670, 0065, 0695, 0108 )
	oPrn:Box( 0670, 0108, 0695, 0150 )
	oPrn:Box( 0670, 0150, 0695, 0250 )
	oPrn:Box( 0670, 0250, 0695, 0400 )
	oPrn:Box( 0670, 0400, 0695, 0600 )
	oPrn:Say( 0680, 0015, "Uso do Banco", oFont10:oFont)
	oPrn:Say( 0680, 0070, "Carteira", oFont10:oFont)
	oPrn:Say( 0680, 0113, "Espécie", oFont10:oFont)
	oPrn:Say( 0680, 0155, "Quantidade", oFont10:oFont)
	oPrn:Say( 0680, 0255, "Valor", oFont10:oFont)
	oPrn:Say( 0680, 0405, "(=) Valor do Documento", oFont10:oFont)
	oPrn:Say( 0690, 0070, __cCodCart/* AllTrim(cImpCart) */, oFont11:oFont)
	oPrn:Say( 0690, 0113, cBolDscMoe, oFont11:oFont)
	oPrn:Say( 0690, 0520, cBolValDoc, oFont11N:oFont)

	oPrn:Box( 0695, 0010, 0770, 0400 )
	oPrn:Box( 0695, 0400, 0710, 0600 )
	oPrn:Say( 0705, 0015, "Instruções(Todas as iformações deste bloqueto são de responsabilidade do beneficiario)", oFont09:oFont)
	oPrn:Say( 0705, 0405, "(-) Desconto/Abatimento", oFont10:oFont)

	oPrn:Box( 0710, 0400, 0725, 0600 )
	oPrn:Say( 0720, 0405, "(-) Outras Deduções", oFont10:oFont)

	oPrn:Say( 0720, 0015, cBcoInstr1, oFont11:oFont)
	oPrn:Say( 0730, 0015, cBcoInstr2, oFont11:oFont)
	oPrn:Say( 0740, 0015, cBcoInstr3, oFont11:oFont)
	oPrn:Say( 0750, 0015, cBcoInstr4, oFont11:oFont)

	oPrn:Box( 0725, 0400, 0740, 0600 )
	oPrn:Say( 0735, 0405, "(+) Mora/Multa", oFont10:oFont)

	oPrn:Box( 0740, 0400, 0755, 0600 )
	oPrn:Say( 0750, 0405, "(+) Outros Acréscimos", oFont10:oFont)

	oPrn:Box( 0755, 0400, 0770, 0600 )
	oPrn:Say( 0765, 0405, "(=) Valor Cobrado", oFont10:oFont)

	oPrn:Box( 0770, 0010, 0815, 0600 )
	oPrn:Say( 0780, 0020, "Pagador", oFont10:oFont)
	oPrn:Say( 0780, 0050, ALLTRIM(cCliNome) + " - CPF/CNPJ: " + ALLTRIM(cCliCPFCNP), oFont11:oFont)
	oPrn:Say( 0790, 0050, Alltrim(cCliEndere) + "-" + cCliBairro, oFont11:oFont)
	oPrn:Say( 0800, 0050, Alltrim(cCliMunici) + "/" + cCliEstado + "-CEP:" + cCliCEP, oFont11:oFont)
	oPrn:Say( 0810, 0020, "Pagador/Avalista", oFont10:oFont)
	oPrn:Say( 0810, 0450, "Cód.Baixa", oFont10:oFont)
	oPrn:Say( 0810, 0500, "Autenticação Mecânica", oFont10:oFont)

	/*
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Parametros³ 01 cTypeBar String com o tipo do codigo de barras              ³±±
	±±³          ³ 				"EAN13","EAN8","UPCA" ,"SUP5"   ,"CODE128"                 ³±±
	±±³          ³ 				"INT25","MAT25,"IND25","CODABAR","CODE3_9"                 ³±±
	±±³          ³ 02 nRow		Numero da Linha em centimentros                       ³±±
	±±³          ³ 03 nCol		Numero da coluna em centimentros			                   ³±±
	±±³          ³ 04 cCode		String com o conteudo do codigo                      ³±±
	±±³          ³ 05 oPr		Obejcto Printer                                        ³±±
	±±³          ³ 06 lcheck	Se calcula o digito de controle                      ³±±
	±±³          ³ 07 Cor 		Numero  da Cor, utilize a "common.ch"                 ³±±
	±±³          ³ 08 lHort		Se imprime na Horizontal                             ³±±
	±±³          ³ 09 nWidth	Numero do Tamanho da barra em centimetros            ³±±
	±±³          ³ 10 nHeigth	Numero da Altura da barra em milimetros             ³±±
	±±³          ³ 11 lBanner	Se imprime o linha em baixo do codigo               ³±±
	±±³          ³ 12 cFont		String com o tipo de fonte                           ³±±
	±±³          ³ 13 cMode		String com o modo do codigo de barras CODE128        ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	*/

	//Impressao do Codigo de Barras
//	MSBAR3("INT25",68.0,0.75,cBolCodBar,oPrn,.F.,,.T.,0.028,1.00,.T.,Nil,Nil,.F.)
	//MSBAR3("INT25",27.3,0.3,_cbarra,oprn,.F.,,.T.,0.028,1.13,.T.,Nil,Nil,.F.)
	oPrn:FWMSBAR("INT25",68.0,0.75,cBolCodBar,oPrn,.F., ,.T.,0.028,1.0,NIL,NIL,NIL,.F.,2/*nPFWidth*/,2/*nPFHeigth*/,.F./*lCmtr2Pix*/)

	oPrn:EndPage()

Return Nil

USER FUNCTION AbatMes(dData)
	LOCAL cRet	:= ""
	LOCAL nAno	:= YEAR(dData)
	LOCAL nMes	:= MONTH(dData)

	IF nMes<>1
		cRet := strzero(nMes-1,2) + "/" +strzero(nAno,4)
	ELSE
		cRet := "12/" +strzero(nAno-1,4)
	ENDIF

RETURN(cRet)

User Function MntTelDir(cPathDir, cBanco)
Local aArea      := GetArea()
Local nOpca      := 0
Local nL         := 005
LOCAL oOk        := LoadBitmap( GetResources(), "LBOK" )
LOCAL oNo        := LoadBitmap( GetResources(), "LBNO" )

Local cTitulo    := OemToAnsi("Arquivos Boletos Gerados")
Local aItens     := {}
Local nIteArq    := 0
Local cNomArq    := ""
Local aFiles     := Directory(cPathDir+"*.pdf")
Local cMailBCC   := GetMV("MV_X_MAIBO",, "" )
Local cMailRem   := GetMV("MV_X_MAIRE",, "" )
Local nX         := 0

PRIVATE lmarcado := .T.

If (nCount := Len(aFiles)) == 0
 MsgStop("Nenhum arquivo foi encontrado para o envio de e-mail!" + CHR(10) + "Diretorio: " + cPathDir, "Leitura arquivos de Boletos!")
 RestArea(aArea)
 Return()
EndIf

For nX := 1 to nCount   
 //NomeArq: BOL104_NUMERO_PARCELA_CLIENTE+LOJA
 cNomArq := UPPER(aFiles[nX,1])
 If SUBSTR(cNomArq, 1, 6) <> "BOL" + cBanco
  Loop
 EndIf
  
 cBanco  := SUBSTR(cNomArq, 4,3)
 nPos1_  := At("_", cNomArq)
 nPos2_  := At("_", SUBSTR(cNomArq, nPos1_+1)) + nPos1_
 nPos3_  := At("_", SUBSTR(cNomArq, nPos2_+1)) + nPos2_
 cNumTit := SUBSTR(cNomArq, nPos1_ +1, nPos2_ - nPos1_ - 1) 
 cParc   := SUBSTR(cNomArq, nPos2_ +1, nPos3_ - nPos2_ - 1) 
 If UPPER(cParc) == "U"
  cParc := ""
 EndIf 
 cCliLoj := SUBSTR(cNomArq, nPos3_ +1, 8)
 
 DbSelectArea("SA1")
 DbSetOrder(1)
 DbSeek(xFilial("SA1") + cCliLoj)

 AADD(aItens, {.T., cNumTit, cParc, cCLiLoj, SA1->A1_NREDUZ, SA1->A1_EMAIL, cNomArq})
Next

If Empty(aItens)
 MsgStop("Nenhum arquivo para o Banco: " + cBanco + " foi encontrado!" + CHR(10) + cPathDir, "Leitura arquivos de Boletos!")
 RestArea(aArea)
 Return()
EndIf 

DEFINE MSDIALOG oDlg TITLE cTitulo From 3,0 to 38,144 of oMainWnd  
 @nL,010 SAY OemtoAnsi("Boletos Gerados Banco: " + cBanco) OF oDlg PIXEL COLOR CLR_BLUE
 nL	+= 12
 @nL,005 LISTBOX oLbox FIELDS HEADER OemToAnsi(""),;  //1
                                     OemToAnsi("Titulo"),;//2
                                     OemToAnsi("Parcela"),;//3
                                     OemToAnsi("Cliente+Loja"),;//4
                                     OemToAnsi("Nome"),;//5
                                     OemToAnsi("E-mail"),;//6
                                     OemToAnsi("Arquivo"),;//7
          SIZE 560,220 OF oDlg PIXEL ON DBLCLICK (nPos:=oLbox:nAt,MarcaDes(aItens,"I"),oLbox:Refresh(),oLbox:nAt:=nPos)

 oLbox:SetArray(aItens)
 oLbox:bLine := { || { If(aItens[oLbox:nAt,01],oOk,oNo) ,;
                       aItens[oLbox:nAt,02],;
                       aItens[oLbox:nAt,03],;
                       aItens[oLbox:nAt,04],;
                       aItens[oLbox:nAt,05],;
                       aItens[oLbox:nAt,06],;
                       aItens[oLbox:nAt,07]} }

 nIteArq := Len(aItens)
 
 @241,010 SAY OemtoAnsi("Encontrados") OF oDlg PIXEL COLOR CLR_BLUE
 @240,050 MSGET oIteArq 	VAR nIteArq	PICTURE "99999"  SIZE 030,4 OF oDlg PIXEL COLOR CLR_BLACK WHEN .F.
 
	oMarcaT := { {"Checked"  ,{|| MarcaDes(aItens,"T") }, "Marca/Desmarca Todos", "Marca Todos"},;
	             {"BMPVISUAL"	,{|| AbreArq(cPathDir, aItens[oLbox:nAt,07]) }	, "Abrir arquivo"	, "Abre PDF"} }


ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar( oDlg, { || nOpca := 1, oDlg:End() },;
                                                  { || nOpca := 2, oDlg:End() },, oMarcaT) CENTER

If nOpca==1 .And. MsgYesNo("Confirma envio dos boletos selecionados?")
	Processa( { |lEnd|  EnvMails(aItens, cMailBCC, cMailRem, cBanco)  },"Enviando E-mails ..." )
EndIf

Return()


Static Function EnvMails(aItens, cMailBCC, cMailRem, cBanco)
Local nCont := 0

 For nCont := 1 To Len(aItens)
 	//oPrn:SaveAllAsJPEG(cStartPath + "ORC_" + SCJ->CJ_NUM,1275,1800,200)
 	If !aItens[nCont, 1] .Or. Empty(aItens[nCont, 6])
 	 Loop
 	EndIf
 	 
  cListMail := AllTrim(aItens[nCont, 6])
  cAssunto  := "ENVIO DE BOLETO - " + IIF(cBanco == "104", "CEF", IIF(cBanco == "033","SANTANDER", Iif(cBanco=="707", "DAYCOVAL","") ) ) 
  cMensagem := "Segue Boleto anexo.<BR><BR>" +;//AllTrim(STRTRAN(cTexto, CHR(10), "<BR>"))+"<BR><BR>" +;
               	AllTrim(SM0->M0_NOMECOM) +"<BR>" +;
               	Alltrim(SM0->M0_ENDCOB) + "<BR>" +;
               	Alltrim(SM0->M0_CIDCOB) + "/" + alltrim(SM0->M0_ESTCOB) + "<BR>" +;
              	"CEP:" + TRANSFORM(SM0->M0_CEPCOB,"@R 99999-999") +"<BR>"+;
              	"Fone: " + Alltrim(SM0->M0_TEL) +"<BR><BR>"+; //"       e-mail: " + cEmail +"<BR>" +;
              	"CNPJ: " + transform(SM0->M0_CGC,"@R 99.999.999/9999-99") + "<BR> I.E.:" + SM0->M0_INSC

  //Copia PDF - TEMP para o Server (RootPath) - para ser anexados no e-mail - sem a subpasta
  CpyT2S(cPathTemp + aItens[nCont, 7], "\")
 	cAnexos   := aItens[nCont, 7] //Ira anexar o arquivo gerado na raiz do RootPath - para que no anexo nao vai a subpasta
  
 	cListMail:="igor.oliveira@vistaalegre.agr.br"
	If (lEnviou := U_NewSMail(cListMail,"",cMailBCC,cAssunto,cMensagem,cAnexos,,,,,,,, 587, cMailRem)) //587 - Server TOTVS
			__CopyFIle(cPathServG+"\"+aItens[nCont, 7], cPathServE+"\"+aItens[nCont, 7])
			FErase(cPathServG+"\"+aItens[nCont, 7])
 	EndIf
  //Deleta arquivo da raiz (RootPath)
		FErase("\"+aItens[nCont, 7])
 Next
 
If lEnviou
	HS_MsgInf("E-mail(s) enviado(s) com sucesso","Confirmação","Envio E-mail!")
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ MarcaDes ³ Autor ³ Jose Choite Kita Jr   ³ Data ³ 19/10/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Marca/desmarca item                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MarcaDes(aItens,cTipo) 
LOCAL k := 0
                                     
IF cTipo=="I"
	If aItens[oLbox:nAt,1] == .F.
		aItens[oLbox:nAt,1] := .T.
	Else
		aItens[oLbox:nAt,1] := .F.
	Endif        
ELSE
        
	lMarcado := !lMarcado
	FOR k:= 1 TO len(aItens)
  aItens[k,1] := lMarcado
	NEXT
ENDIF

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ AbreArq  ³ Autor ³ Choite                          ³ Data ³ 28/09/11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Abre Arquivo                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cPath		Caminho onde esta localizado o arquivo                  ³±±
±±³          ³ cFileNane    Nome do Arquivo                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ HISTORICO DE ATUALIZACOES DA ROTINA ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Desenvolvedor   ³ Data   ³Solic.³ Descricao                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                 ³        ³      ³                                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static FUNCTION AbreArq(cPath,cFileName)
Local cOper     := "open" // "print", "explore
Local cParam    := ""
Local cDir      := ""
Local cDrive    := ""
Local cPathOri	:= cPath + "\" + cFileName
Local cPathDes  := GetTempPath() + cFileName
Local lCopied	:= .F.
Local cNaoValido:= "BAT$COM$EXE$MSC"
Local cExtensao	:= substr(alltrim(cFileName),rat(".",cFileName)+1)

IF !empty(cFileName)
	
	IF cExtensao$cNaoValido   
  Alert("Nao é permitido abrir arquivo com extensão " + cExtensao + ".","Valida Extensão!")
		RETURN()
	ENDIF
	
	lCopied := __CopyFile( cPathOri, cPathDes )
	
	IF lCopied
		SplitPath(cPathDes, @cDrive, @cDir )
		cDir := Alltrim(cDrive) + Alltrim(cDir)
		
		nRet := ShellExecute(cOper,cPathDes,cParam,cDir, 1 )
		
		If nRet <= 32
   Alert("Nao foi possivel abrir o objeto " + cPathDes + ", não existe nenhum programa relacionado ào tipo de arquivo.","Abre Arquivos!")
		EndIf
		
	ELSE                                                                                                                          
		Alert("Nao foi possivel efetuar a transferencia do arquivo " + cFileName + ".","Abre Arquivos!")
	ENDIF
	
Endif

RETURN()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NewSMail  ºAutor  ³Daniel Peixoto      º Data ³  26/07/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Nova rotina de envio de e-mail que comporta a utilizacao    º±±
±±º          ³de criptografia SSL                                         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User function NewSMail(cEmailTo,cEmailCc,cEmailBcc,cAssunto,cMensagem,cAnexos,lMsg,cAccount,cPass,cSMTPAddr,cPopAddr,cFrom,nPOPPort,nSMTPPort, cRemet)
Local oServer  := Nil
Local oMessage := Nil
Local nErr     := 0
Local cUser     := ""      // Usuario que ira realizar a autenticacao
Local nSMTPTime := 60      // Timeout SMTP

//Local cAutUser   := GetMv("MV_WFAUTUS")
//Local cAutSenha  := GetMV("MV_WFAUTSE")
Local nI:=0

Default lMsg      := .T.
Default cAnexos   := ""
Default cEmailBcc := ""
Default cMensagem := ""
Default cPopAddr  := ""                           
Default cRemet    := ""

cAccount	 := IIF(Empty(cAccount), GETMV("MV_RELACNT"),cAccount)
cUser     := GETMV("MV_RELAUSR")
cPass    	:= IIF(Empty(cPass), GETMV("MV_RELAPSW"), cPass)
cSMTPAddr	:= IIF(Empty(cSMTPAddr), GETMV("MV_RELSERV"), cSMTPAddr)
//nSMTPPort	:= Iif( nSMTPPort == NIL, WF7->WF7_SMTPPR, nSMTPPort   )
cPopAddr 	:= cPopAddr//Lower( AllTrim( Iif( cPopAddr  == NIL, WF7->WF7_POP3SR, cPopAddr    ) ) )
//nPOPPort 	:= Iif( nPOPPort  == NIL, WF7->WF7_POP3PR, nPOPPort    )
cFrom	   	:= IIF(!Empty(cRemet), cRemet, cAccount)//Lower( AllTrim( Iif( cFrom     == NIL, WF7->WF7_REMETE, cFrom       ) ) )
lSSL        := GETMV("MV_RELSSL")
lTSL        := GETMV("MV_RELTLS")

// Instancia um novo TMailManager
oServer := tMailManager():New()

// Usa SSL na conexao
oServer:setUseSSL(lSSL)
oServer:SetUseTLS(lTSL)

If(At(":",cSMTPAddr) > 0)
	nSMTPPort := Val(Substr(cSMTPAddr,At(":",cSMTPAddr)+1,Len(cSMTPAddr)))
	cSMTPAddr := Substr(cSMTPAddr,0,At(":",cSMTPAddr)-1)
EndIf

// Inicializa
// oServer:init(cPopAddr, cSMTPAddr, cUser, cPass, nPOPPort, nSMTPPort)
oServer:Init("",cSMTPAddr,cUser,cPass,0,nSMTPPort)

// Define o Timeout SMTP
If oServer:SetSMTPTimeout(nSMTPTime) != 0
	Conout("[ERROR]Falha ao definir timeout")
	If lMsg
		HS_MsgInf("Falha ao definir timeout","ATENÇÃO","Envio E-mail")
	EndIf
	
	Return .F.
Endif

// Conecta ao servidor
nErr := oServer:smtpConnect()
If nErr <> 0
	ConOut("[ERROR]Falha ao conectar: " + oServer:getErrorString(nErr))
	oServer:smtpDisconnect()
	If lMsg
		HS_MsgInf("Erro ao conectar: " + oServer:getErrorString(nErr),"ATENÇÃO", "Envio E-mail")
	EndIf
	
	return .F.
Endif

// Realiza autenticacao no servidor
nErr := oServer:smtpAuth(cUser, cPass)
If nErr <> 0
	conOut("[ERROR]Falha ao autenticar: " + oServer:getErrorString(nErr))
	oServer:smtpDisconnect()
	If lMsg
		HS_MsgInf("Erro ao autenticar: " + oServer:getErrorString(nErr),"ATENÇÃO", "Envio E-mail")
	EndIf
	
	return .F.
Endif

// Cria uma nova mensagem (TMailMessage)
oMessage := tMailMessage():new()
oMessage:clear()
oMessage:cFrom    := cFrom
oMessage:cTo      := cEmailTo
oMessage:cCC      := cEmailCc
oMessage:cBCC     := cEmailBcc
oMessage:cSubject := cAssunto
oMessage:cBody    := cMensagem

For nI := 1 to Len(aAnexo := StrToKarr(cAnexos,';'))
	If (nErro := oMessage:AttachFile( aAnexo[nI] )) < 0
		Conout( "Erro ao anexar o arquivo "+aAnexo[nI]+": "+oServer:GetErrorString( nErro )  )
		If lMsg
			HS_MsgInf("Erro ao anexar o arquivo "+aAnexo[nI]+": "+oServer:GetErrorString( nErro ),"ATENÇÃO", "Envio E-mail")
		EndIf
		//Return .F.
	Else
		// 	 cNomAttach := SUBSTR(aAnexo[nI], RAT("\", aAnexo[nI])+1)
		oMessage:AddAtthTag( 'Content-Disposition: attachment; filename='+aAnexo[nI])
	EndIf
Next

// Envia a mensagem
nErr := oMessage:send(oServer)
If nErr <> 0
	conout("[ERROR]Falha ao enviar: " + oServer:getErrorString(nErr))
	oServer:smtpDisconnect()
	If lMsg
		HS_MsgInf("Falha ao enviar: " + oServer:getErrorString(nErr),"ATENÇÃO", "Envio E-mail")
	EndIf
	
	return .F.
Endif

// Disconecta do Servidor
oServer:smtpDisconnect()

Return .T.
