#include "topconn.ch"
#include "protheus.ch"
#include "rwmake.ch"

/* 
	MJ : 20.02.2018
		# Forçar o preenchimento de campos na entrada da Nota Fiscal. 
*/
User Function MT100LOK()
	Local lRet 		 := .T.
	Local cCampos 	 := ""
// Local cFilVld	 := GetMV("VA_C100LOK",,"01,12")
	Local lContinua	 := .T.
	Local cSB1Milhos := GetMV("VA_SB1MILHO",, "020017") // separar por virgula se tiver mais de um produto
	Local cSB1Insumo := GetMv("MV_X_PRDMI",,"020017;020080;020079;") // Indica códigos de prudutos que NÃO deverão passar pela regra de
	Local cGrpAju    := SuperGetMv("MV_GRPAJU",.T.,"02;03")// Grupo de Produtos que será ajustado pela TM
	Local nI		 := 0

	// Alert('MT100LOK')
	// validacao temporaria para evitar o preenchimento dos campos neste fonte;
	// utilizado para analise do problema do ICMS
	// if dDataBase>=sToD('20200714') .and. __cUserId=='000101' // Miguel
	// 	Return .T.
	// EndIf

/* Se a linha estiver apagada, entao nao precisa realizar a FRENTE, NENHUMA validacao; */
	If aCols[ n, Len( aCols[ 1 ] ) ]
		Return .T.
	EndIf

/* REGRA SOMENTE SERA EXECUTADA NA FILIAL 01 */
	If xFilial('SF1') <> '01'
		Return .T.
	EndIf

/* Chamado: 237 : https://agropecuriavistaalegre.freshdesk.com/a/tickets/237
	Solicitante: jessica silva 
	Descri: Validacao Inclusao MILHO; Obrigatoriedade de campos; 
	REGRA PARA MILHO
	*/
	cCampos := ""
	If AllTrim(GdFieldGet('D1_COD')) $ cSB1Milhos .and. SF4->F4_TRANFIL == "2" // 2 = NÃO
		If Empty( GdFieldGet('D1_X_PESOB') )
			cCampos += Iif( Empty(cCampos), "", ",<br>") + "Peso Bruto"
		EndIf

		If Empty( GdFieldGet('D1_X_IMPUR') )
			cCampos += Iif( Empty(cCampos), "", ",<br>") + "Impureza %"
		EndIf

		If Empty( GdFieldGet('D1_X_UMIDA') )
			cCampos += Iif( Empty(cCampos), "", ",<br>") + "Umidade %"
		EndIf

		If !Empty(cCampos)
			MsgInfo('Não foi localizado informação na linha: <b>' + AllTrim(Str(n)) + ;
				'</b> para o(s) campo(s): <br> <b>' + cCampos + '</b>.')
			lRet := .F.
		EndIf
	EndIf

	cCampos := ""
	If lRet // .and. xFilial('SF1') $ cFilVld

		// For nI := 1 to Len(aCols)

		/* REGRA PARA GADO */
		nI := n

		If SubS(GdFieldGet('D1_COD', nI),1,3)<>'BOV' ;
				.OR. Posicione( 'SF4', 1, xFilial('SF4')+GdFieldGet('D1_TES', nI), 'F4_TRANFIL' ) == "1" ;
				.OR. cTipo <> "N" // M->F1_TIPO <> "N"
			// loop
			lContinua := .F.
		EndIf

		if lContinua
			If Empty( GdFieldGet('D1_X_PESCH', nI) )
				cCampos += Iif( Empty(cCampos), "", ",<br>") + "Peso Chegada"
			EndIf

			If Empty( GdFieldGet('D1_X_EMBDT', nI) )
				cCampos += Iif( Empty(cCampos), "", ",<br>") + "Data Embarque"
			EndIf

			If Empty( GdFieldGet('D1_X_EMBHR', nI) )
				cCampos += Iif( Empty(cCampos), "", ",<br>") + "Hora Embarque"
			EndIf

			If Empty( GdFieldGet('D1_X_CHEDT', nI) )
				cCampos += Iif( Empty(cCampos), "", ",<br>") + "Data Chegada"
			EndIf

			If Empty( GdFieldGet('D1_X_CHEHR', nI) )
				cCampos += Iif( Empty(cCampos), "", ",<br>") + "Hora Chegada"
			EndIf

			// If Empty( GdFieldGet('D1_X_JEJUM', nI) )
			// cCampos += Iif( Empty(cCampos), "", ",<br>") + "Jejum"
			// EndIf
			/*  // TIRADO NO DIA 06.04.2018
			If Empty( GdFieldGet('D1_X_QUEKG', nI) )
				cCampos += Iif( Empty(cCampos), "", ",<br>") + "Quebra"
			EndIf
			
			If Empty( GdFieldGet('D1_X_QUECA', nI) )
				cCampos += Iif( Empty(cCampos), "", ",<br>") + "Quebra/Animal"
			EndIf
			*/
			If Empty( GdFieldGet('D1_X_KM', nI) )
				cCampos += Iif( Empty(cCampos), "", ",<br>") + "Distância"
			EndIf

			If !Empty(cCampos)
				MsgInfo('Não foi localizado informação na linha: <b>' + AllTrim(Str(nI)) + '</b> para o(s) campo(s): <br> <b>'+cCampos+'</b>.')
				lRet := .F.
				// exit
			EndIf
			// Next nI
		EndIf
	EndIf

	cCampos := ""
	If lRet

		/* REGRA DOS INSUMOS */

		If AllTrim(Posicione("SB1", 1, xFilial("SB1")+Alltrim(GdFieldGet('D1_COD')), 'B1_GRUPO')) $ cGrpAju ;
		   .and. !Alltrim(GdFieldGet('D1_COD')) $ cSB1Insumo ;
		   .and. cTipo == "N";
		   .and. Empty(GdFieldGet('D1_X_PESOB')) ;
		   .and. SF4->F4_TRANFIL == "2" // 2 = NÃO
			cCampos += Iif( Empty(cCampos), "", ",<br>") + "Peso Bruto"
			MsgInfo('Não foi localizado informação na linha: <b>' + AllTrim(Str(N)) + '</b> para o(s) campo(s): <br> <b>'+cCampos+'</b>.')
			lRet := .F.
		EndIf
	EndIf

Return lRet

/*
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Função    ³ MT100LOK Autor ³ Henrique Magalhaes   ³ Data ³ 19.06.2015³ ±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Descrição ³  Validacao na linha do documento de enttrada              ³±±  
	±±³ ** Utilizado para tratar obrigatoriedade de campos					  ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Uso       ³ validar campos de digitacao no item do documento de entrada ±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
/*   
	Descrição:
	utilizacao para validar as entidade de Centro de Custo / Item Contabil / Classe valor  na digitacao de itens no Documento de Entrada
	Tratamentos diferenciados para Empresa 01 (Vista Alegre com CC/Item/Classe Valor) e Empresa 05 (Quintas, apenas CC)
	*/  
/*
	User Function MT100LOK()
	Local aArea		:= GetArea()
	Local nPosCod   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_COD"})
	Local nPosTES   := aScan(aHeader,{|x| AllTrim(x[2])=="D1_TES"})
	Local nPosCC    := aScan(aHeader,{|x| AllTrim(x[2])=="D1_CC"})
	Local nPosITCTA := aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEMCTA"})
	Local nPosCLVL  := aScan(aHeader,{|x| AllTrim(x[2])=="D1_CLVL"})
	Local cCtrEst	:= ""
	Local cCtrFin	:= ""
	Local lRet		:= .T.

		If !Alltrim(cEmpAnt)$'01;05' // Efetua Validacao apenas para empresa 01 - fazendas
		RestArea(aArea)
		Return lRet 
		Endif


		If !Empty(aCols[n,nPosTES]) // Somente valida após Preenchimento ds TES
		cCtrEst := Posicione('SF4',1,xFilial('SF4') +aCols[n,nPosTES],'F4_ESTOQUE')	
		cCtrFin := Posicione('SF4',1,xFilial('SF4') +aCols[n,nPosTES],'F4_DUPLIC')	
			If cCtrEst == 'S'
			// Se Controlar Estoque nao permite o preenchimento das entidades CC / Item Contabil / Classe Valor

				If  Alltrim(cEmpAnt)$'05'
					If  !Empty(aCols[n,nPosCC])
					aCols[n,nPosCC]		:= Space(TamSX3('D1_CC')[1])
					Aviso('AVISO', 'Itens para Estoque nao devem ter o camp Centro de Custo preenchido!!! Verifique!!!', {'Ok'})	
					lRet := .T.
					Endif
				Endif

				If  Alltrim(cEmpAnt)$'01'
					If  !Empty(aCols[n,nPosCC]) .or. !Empty(aCols[n,nPosITCTA]) .or. !Empty(aCols[n,nPosCLVL])
					aCols[n,nPosCC]		:= Space(TamSX3('D1_CC')[1])
					aCols[n,nPosITCTA]	:= Space(TamSX3('D1_ITEMCTA')[1])
					aCols[n,nPosCLVL]	:= Space(TamSX3('D1_CLVL')[1])    
					Aviso('AVISO', 'Itens para Estoque nao devem ter os campos Centro de Custo / Item Contabil / Classe Valor preenchidos!!! Verifique!!!', {'Ok'})	
					lRet := .T.
					Endif
				Endif
				
			Else // Se for Custo Direto (Nao controle estoque e deve obrigar os preenchimentos das entidades CC / Item Contabil / Classe Valor
			// Se for Custo Diretro (Estoque NAO) obriga preencher as entidades CC / Item Contabil / Classe Valor
				If  Alltrim(cEmpAnt)$'05'
					If  cCtrFin='S' .and. ( Empty(aCols[n,nPosCC]))
					Aviso('AVISO', 'Itens que nao controlam Estoque, devem ter o campo Centro de Custo preenchido!!! Verifique!!!', {'Ok'})	
					lRet := .F.
					Endif
				Endif
					
				If  Alltrim(cEmpAnt)$'01'
					If  cCtrFin='S' .and. ( Empty(aCols[n,nPosCC]) .or. Empty(aCols[n,nPosITCTA]) .or. Empty(aCols[n,nPosCLVL]) )
					Aviso('AVISO', 'Itens que nao controlam Estoque, devem ter os campos Centro de Custo / Item Contabil / Classe Valor preenchidos!!! Verifique!!!', {'Ok'})	
					lRet := .F.
					Endif
				Endif

			Endif

		Endif


	RestArea(aArea)

	Return(lRet)
*/

User Function PegaUmidade( _cFilial, _cPedido, nUmidade, lTemContrato, cZBCDESIMP, cZBCDESAVA )
Local nRetorno       := 0
Local _cQry          := ""
Local _ZBCAlias      := GetNextAlias()
Local _ZDMAlias      := "" // GetNextAlias()
Default nUmidade     := 0
Default lTemContrato := .F.

lTemContrato := .F.
If Empty(_cPedido)
	ConOut("[MT100LOK] Funcao PegaUmidade: " + cValToChar(nRetorno))
	Return nRetorno
EndIf

_cQry := " SELECT ZBC_TABDES, ZBC_DESIMP, ZBC_DESAVA " + CRLF
_cQry += " FROM	  ZBC010 " + CRLF
_cQry += " WHERE  ZBC_FILIAL='" + _cFilial + "' " + CRLF
_cQry += "    AND ZBC_PEDIDO='" + _cPedido + "' " + CRLF
_cQry += " 	  AND D_E_L_E_T_=' '"

dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_ZBCAlias),.F.,.F.)

If !(_ZBCAlias)->(Eof())
	lTemContrato := .T.
	
	cZBCDESIMP := Iif(Empty((_ZBCAlias)->ZBC_DESIMP), "B", (_ZBCAlias)->ZBC_DESIMP)
	cZBCDESAVA := Iif(Empty((_ZBCAlias)->ZBC_DESAVA), "B", (_ZBCAlias)->ZBC_DESAVA)

	If nUmidade >= 0
		_cQry := " SELECT  R_E_C_N_O_ RecnoZDM, ZDM_DESCON" + CRLF
		_cQry += " FROM	ZDM010" + CRLF
		_cQry += " WHERE   ZDM_CODIGO = '" + (_ZBCAlias)->ZBC_TABDES + "'" + CRLF
		_cQry += "     AND ZDM_UMIDAD = (" + CRLF
		_cQry += "   		SELECT	MIN(ZDM_UMIDAD) " + CRLF
		_cQry += "   		FROM	ZDM010" + CRLF
		_cQry += "   		WHERE	ZDM_CODIGO = '" + (_ZBCAlias)->ZBC_TABDES + "'" + CRLF
		_cQry += "   			AND ZDM_UMIDAD >= " + cValToChar(nUmidade) + CRLF
		_cQry += "   			AND ZDM_MSBLQL<>'1'" + CRLF
		_cQry += "   			AND D_E_L_E_T_=' '" + CRLF
		_cQry += "     )" + CRLF
		_cQry += " AND D_E_L_E_T_=' '" + CRLF
		_cQry += " ORDER BY ZDM_UMIDAD"
		
		_ZDMAlias := GetNextAlias()
		dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_ZDMAlias),.F.,.F.)
		
		If !(_ZDMAlias)->(Eof())
			nRetorno := (_ZDMAlias)->ZDM_DESCON
		EndIf
		(_ZDMAlias)->(DbCloseArea())
	EndIf
EndIf
(_ZBCAlias)->(DbCloseArea())

Return nRetorno


User Function M103CALC() // Funcao para recalcular pesos de milho na entrada de NFs
	Local aArea			:= GetArea()
	Local nPosProdu		:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_COD"}) 				// Codigo do Produto
	Local nPosPesoB		:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_X_PESOB"}) 			// peso bruto em Kg
	Local nPosUmida  	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_X_UMIDA"})				// umidade em %
	Local nPosXPERDUM  	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_XPERDUM"})				// Desconto
	Local nPosImpur 	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_X_IMPUR"})				// impurezas em %

	Local nPPAvaria     := aScan(aHeader,{|x| AllTrim(x[2])=="D1_XPAVAIR"})				// Percentual Avaria
	Local nPkgAvaria    := aScan(aHeader,{|x| AllTrim(x[2])=="D1_XKGAVAI"})				// KG Avaria

	Local nPosKGUmi 	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_X_KGUMI"}) 			// umidade em KG
	Local nPosKGImp 	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_X_KGIMP"})				// impurezas em KG
	Local nPosPesol 	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_X_PESOL"})				// peso liquid apos descontos de impureza e umidade
	Local nPosQuant 	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_QUANT"})				// quantidade fiscal da NF
	// Local nPosVUnit 	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_VUNIT"})				// valor unitario dada NF
	// Local nPosTotal 	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_TOTAL"})				// total em R$ da NF
	Local nPosPcNum 	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_PEDIDO"})				// Numero do pedido de compras
	Local nPosPCIte 	:= aScan(aHeader,{|x| AllTrim(x[2])=="D1_ITEMPC"})				// Item pedido de Compras

	Local nLimUmida		:= SuperGetMV("MV_X_LIMUM",.T.,14.00) 							// Tolerancia para Umidade
	Local nLimImpur		:= SuperGetMV("MV_X_LIMIM",.T., 1.00)							// Tolerancia para Impurezas
	Local lDescUmid		:= IIF("S" == SuperGetMV("MV_X_DESUM",.T., "S"), .T., .F.)		// Desconta Umidade .T. ou .F.
	Local lDescImpu		:= IIF("S" == SuperGetMV("MV_X_DESIM",.T., "S"), .T., .F.) 		// Desconta Impurezas .T. ou .F.
	Local nValUmida		:= 0
	Local nValImpur		:= 0
	Local nValAvaria	:= 0
	// Local cForCod		:= 	If(Type("cA100For")<>"U",cA100For,space(6))
	// Local cForLoja		:= 	If(Type("cLoja")<>"U",cLoja,space(2))
	Local cProdCod		:= 	Iif(Type("M->D1_COD")<>"U", M->D1_COD, aCols[n,nPosProdu])
	Local cPCNume		:= 	Iif(Type("M->D1_PEDIDO")<>"U", M->D1_PEDIDO, aCols[n,nPosPcNum])
	Local cPCItem		:= 	Iif(Type("M->D1_ITEMPC")<>"U", M->D1_ITEMPC, aCols[n,nPosPCIte])
	Local cC7Obs		:= ""
	Local lRet			:= .T.
	
	Local lFormProp		:= If(Type("cFormul")<>"U",IIF(cFormul=="S",.T.,.F.),.F.)
	Local cZBCDESIMP	:= ""
	Local cZBCDESAVA	:= ""
	Local nDesconto     := U_PegaUmidade( xFilial("SD1"),;
									 	cPCNume,;
	 									iIf(Type("M->D1_X_UMIDA")<>"U",M->D1_X_UMIDA,aCols[n,nPosUmida]),,;
										@cZBCDESIMP, @cZBCDESAVA )

	If IsInCallStack("A103DEVOL") .OR. cTipo=="D"
		RestArea(aArea)
		Return .T.
	EndIf

	If Alltrim(cEmpAnt)<>'01' // Efetua Validacao apenas para empresa 01 - fazendas
		RestArea(aArea)
		Return lRet
	Endif

	// Atualizar Peso bruto
	If SubS( ReadVar(), At(">",ReadVar())+1) <> "D1_X_PESOB" .and. aCols[n,nPosPesoB]==0
		aCols[n,nPosPesoB] := aCols[n,nPosQuant]
	EndIf

	// Apagar Armazem
	If (SubS( ReadVar(), At(">",ReadVar())+1) == "D1_QUANT") .and. (AllTrim(aCols[n, nPosProdu]) $ GetMV("MB_COMM12B",,"020017"))
		aCols[n, aScan(aHeader,{|x| AllTrim(x[2])=="D1_LOCAL"})] := CriaVar('D1_LOCAL',.F.)
	EndIf

	DbSelectArea("SC7")
	dbSetorder(4) //   C7_FILIAL+C7_PRODUTO+C7_NUM+C7_ITEM+C7_SEQUEN
	If DbSeek(cFilant + cProdCod + cPCNume + cPCItem,.T.)  // acha a primeira ocorrencia
		nLimUmida	:=	SC7->C7_X_LIMUM
		nLimImpur	:= 	SC7->C7_X_LIMIM
		lDescUmid	:=  IIF("S" == SC7->C7_X_DESUM,.T.,.F.)
		lDescImpu	:=  IIF("S" == SC7->C7_X_DESIM,.T.,.F.)
		cC7Obs		:= 	u_SC7OBS(SC7->C7_FILIAL, SC7->C7_NUM)
		If !(Alltrim(cC7Obs)$cObsMT103)
			cObsMT103 += ' || ' + cC7Obs
		Endif
	Endif

	If aCols[n,nPosPesoB]>0 .and. (INCLUI .OR. ALTERA) // Somente valida e calcula se houver Preenchimento do peso

		// Avalia se vai descontar ou nao, as Impurezas
		If iif(Type("M->D1_X_UMIDA")<>"U",M->D1_X_UMIDA,aCols[n,nPosUmida]) > nLimUmida .and. lDescUmid
			If nDesconto == 0 // modo antigo
				nValUmida := NoRound( Iif(Type("M->D1_X_PESOB")<>"U", M->D1_X_PESOB, aCols[n,nPosPesoB]) * ( (Iif(Type("M->D1_X_UMIDA")<>"U",M->D1_X_UMIDA,aCols[n,nPosUmida]) - nLimUmida) / 100), TamSX3("D1_X_KGUMI")[2])
			Else // modo novo, contrato milho
				nValUmida := NoRound( Iif(Type("M->D1_X_PESOB")<>"U", M->D1_X_PESOB, aCols[n,nPosPesoB]) * (nDesconto/100), TamSX3("D1_X_KGUMI")[2])
				If Type("M->D1_XPERDUM")<>"U"
					M->D1_XPERDUM := nDesconto
				Else
					aCols[n,nPosXPERDUM] := nDesconto
				EndIf
			EndIf
		Else
			nValUmida := 0
		Endif

		If Type("M->D1_X_KGUMI")<>"U"  // calcula descontos de umidade
			M->D1_X_KGUMI	   := nValUmida	//NoRound( Iif(Type("M->D1_X_PESOB")<>"U", M->D1_X_PESOB, aCols[n,nPosPesoB])  * ( Iif(Type("M->D1_X_UMIDA")<>"U",M->D1_X_UMIDA,aCols[n,nPosUmida]) / 100)	, TamSX3("D1_X_KGUMI")[2])
		Else
			aCols[n,nPosKGUmi] := nValUmida	//NoRound( Iif(Type("M->D1_X_PESOB")<>"U", M->D1_X_PESOB, aCols[n,nPosPesoB])  * ( Iif(Type("M->D1_X_UMIDA")<>"U",M->D1_X_UMIDA,aCols[n,nPosUmida]) / 100)	, TamSX3("D1_X_KGUMI")[2])
		Endif

		__nPeso := Iif(cZBCDESIMP == "B",;
			Iif(Type("M->D1_X_PESOB")<>"U", M->D1_X_PESOB, aCols[n,nPosPesoB]),;
			Iif(Type("M->D1_X_PESOB")<>"U", M->D1_X_PESOB, aCols[n,nPosPesoB]) - nValUmida )

		If nDesconto == 0 // modo antigo
			// Avalia se vai descontar ou nao, as Impurezas
			If iif(Type("M->D1_X_IMPUR")<>"U",M->D1_X_IMPUR,aCols[n,nPosImpur]) > nLimImpur .and. lDescImpu
				nValImpur := NoRound( __nPeso *;
							( (Iif(Type("M->D1_X_IMPUR")<>"U",M->D1_X_IMPUR,aCols[n,nPosImpur]) - nLimImpur)/ 100),;
							TamSX3("D1_X_KGIMP")[2])
			Else
				nValImpur := 0
			Endif
		Else
			/* MB : 23.08.2021
				-> Regra ddsconto de impuresas;
					Atualizado: iif(Type("M->D1_X_IMPUR")<>"U",M->D1_X_IMPUR,aCols[n,nPosImpur])-1
			*/
			If iif(Type("M->D1_X_IMPUR")<>"U",M->D1_X_IMPUR,aCols[n,nPosImpur]) > 1
				nValImpur := NoRound( (__nPeso /* -nValUmida */) *;
							 	( (iif(Type("M->D1_X_IMPUR")<>"U",M->D1_X_IMPUR,aCols[n,nPosImpur])-1) / 100),;
							  TamSX3("D1_X_KGIMP")[2])
			EndIf
		Endif

		If Type("M->D1_X_KGIMP")<>"U"  // calcula descontos de impurezas
			M->D1_X_KGIMP		:= 	nValImpur	//NoRound( Iif(Type("M->D1_X_PESOB")<>"U", M->D1_X_PESOB, aCols[n,nPosPesoB])  * ( Iif(Type("M->D1_X_IMPUR")<>"U",M->D1_X_IMPUR,aCols[n,nPosImpur]) / 100)	, TamSX3("D1_X_KGIMP")[2])
		Else
			aCols[n,nPosKGImp] 	:= 	nValImpur	//NoRound( Iif(Type("M->D1_X_PESOB")<>"U", M->D1_X_PESOB, aCols[n,nPosPesoB])  * ( Iif(Type("M->D1_X_IMPUR")<>"U",M->D1_X_IMPUR,aCols[n,nPosImpur]) / 100)	, TamSX3("D1_X_KGIMP")[2])
		Endif

		If iif(Type("M->D1_XPAVAIR")<>"U",M->D1_XPAVAIR,aCols[n,nPPAvaria]) > GetMV("MB_100LOK1",,6)
			nValAvaria := NoRound( __nPeso *;
				((iif(Type("M->D1_XPAVAIR")<>"U",M->D1_XPAVAIR,aCols[n,nPPAvaria])-GetMV("MB_100LOK1",,6))/100),;
				TamSX3("D1_X_KGIMP")[2])

			If Type("M->D1_XKGAVAI")<>"U"
				M->D1_XKGAVAI := nValAvaria
			Else
				aCols[n,nPkgAvaria] := nValAvaria
			EndIf
		EndIf

		If Type("M->D1_X_PESOL")<>"U"
			M->D1_X_PESOL		:= NoRound( Iif(Type("M->D1_X_PESOB")<>"U", M->D1_X_PESOB, aCols[n,nPosPesoB]) - Iif(Type("M->D1_X_KGUMI")<>"U", M->D1_X_KGUMI, aCols[n,nPosKGUmi]) -  Iif(Type("M->D1_X_KGIMP")<>"U", M->D1_X_KGIMP, aCols[n,nPosKGImp]) - Iif(Type("M->D1_XKGAVAI")<>"U", M->D1_XKGAVAI, aCols[n,nPkgAvaria]) , TamSX3("D1_X_PESOL")[2] )
		Else
			aCols[n,nPosPesol] 	:= NoRound( Iif(Type("M->D1_X_PESOB")<>"U", M->D1_X_PESOB, aCols[n,nPosPesoB]) - Iif(Type("M->D1_X_KGUMI")<>"U", M->D1_X_KGUMI, aCols[n,nPosKGUmi]) -  Iif(Type("M->D1_X_KGIMP")<>"U", M->D1_X_KGIMP, aCols[n,nPosKGImp]) - Iif(Type("M->D1_XKGAVAI")<>"U", M->D1_XKGAVAI, aCols[n,nPkgAvaria]) , TamSX3("D1_X_PESOL")[2] )
		Endif

		If lFormProp
			If Type("M->D1_QUANT")<>"U"
				M->D1_QUANT			:= NoRound( Iif( Type("M->D1_X_PESOL")<>"U", M->D1_X_PESOL, aCols[n,nPosPesoL] ) , TamSX3("D1_QUANT")[2])
//				M->D1_TOTAL			:= NoRound( Iif(Type("M->D1_QUANT")<>"U", M->D1_QUANT, aCols[n,nPosQuant]) *  Iif(Type("M->D1_VUNIT")<>"U", M->D1_VUNIT, aCols[n,nPosVUnit]), TamSX3("D1_TOTAL")[2]) 
//				M->D1_TOTAL 		:= IF(A103Trigger("D1_TOTAL"),M->D1_TOTAL,0) 
				If A103TOLER() .And. A100SegUm() .And. MaFisRef("IT_QUANT","MT100",M->D1_QUANT) .and. MTA103OPER(n)
				Endif
			Else
				aCols[n,nPosQuant] 	:= NoRound( Iif( Type("M->D1_X_PESOL")<>"U", M->D1_X_PESOL, aCols[n,nPosPesoL] ) , TamSX3("D1_QUANT")[2])
//				aCols[n,nPosTotal] 	:= NoRound( Iif(Type("M->D1_QUANT")<>"U", M->D1_QUANT, aCols[n,nPosQuant]) *  Iif(Type("M->D1_VUNIT")<>"U", M->D1_VUNIT, aCols[n,nPosVUnit]), TamSX3("D1_TOTAL")[2]) 
//				aCols[n,nPosTotal]	:= IF(A103Trigger("D1_TOTAL"),aCols[n,nPosTotal],0) 
				If A103TOLER() .And. A100SegUm() .And. MaFisRef("IT_QUANT","MT100",aCols[n,nPosQuant])  .and. MTA103OPER(n)
				Endif

			//A103TOLER().And.Positivo().And.A100SegUm().And.MaFisRef("IT_QUANT","MT100",M->D1_QUANT)                                         
			//A103TOLER().And.NaoVazio().AND.Positivo().And.MaFisRef("IT_PRCUNI","MT100",M->D1_VUNIT)                                         
			//A103Total(M->D1_TOTAL) .and. MaFisRef("IT_VALMERC","MT100",M->D1_TOTAL) .AND. MTA103OPER(n)  

			Endif

			If ExistTrigger("D1_QUANT")
				RunTrigger(2,N)
			EndIf

		Endif

	Endif

	//M->D1_TOTAL := NoRound(M->D1_VUNIT*M->D1_QUANT,TamSX3("D1_TOTAL")[2])                               
	//M->D1_TOTAL := IF(A103Trigger("D1_TOTAL"),M->D1_TOTAL,0) 
	//A103Total(M->D1_TOTAL) .and. MaFisRef("IT_VALMERC","MT100",M->D1_TOTAL) .AND. MTA103OPER(n)                                           

	RestArea(aArea)
Return lRet
