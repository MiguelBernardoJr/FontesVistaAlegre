#INCLUDE "MATR715.CH"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MATR715   ³ Autor ³ Rodrigo de A Sartorio ³ Data ³ 29.01.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relacao de transferencias entre filiais                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function VAESTR02()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define Variaveis                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local Titulo  := STR0001    //"Transferencias entre filiais"                                     // Titulo do Relatorio
Local cDesc1  := STR0002    //"O relatorio ira imprimir as informacoes sobre as notas fiscais"   // Descricao 1
Local cDesc2  := STR0003    //"de transferencia entre filiais, imprimindo informacoes sobre as"  // Descricao 2
Local cDesc3  := STR0004    //"saidas e entradas de cada documento."                             // Descricao 3
Local cString := "SD2"      // Alias utilizado na Filtragem
Local lDic    := .F.        // Habilita/Desabilita Dicionario
Local lComp   := .T.        // Habilita/Desabilita o Formato Comprimido/Expandido
Local lFiltro := .T.        // Habilita/Desabilita o Filtro
Local wnrel   := "MATR715"  // Nome do Arquivo utilizado no Spool
Local nomeprog:= "MATR715"  // nome do programa

Private Tamanho := "G" // P/M/G
Private Limite  := 220 // 80/132/220
Private aOrdem  := {STR0008,STR0009,STR0010}  //"Produto"###"Documento / Serie"###"Data de emissao"
Private cPerg   := "MTR715"  // Pergunta do Relatorio
Private aReturn := { STR0005, 1,STR0006, 1, 2, 1, "",1 } //"Zebrado"###"Administracao"
//[1] Reservado para Formulario
//[2] Reservado para N§ de Vias
//[3] Destinatario
//[4] Formato => 1-Comprimido 2-Normal
//[5] Midia   => 1-Disco 2-Impressora
//[6] Porta ou Arquivo 1-LPT1... 4-COM1...
//[7] Expressao do Filtro
//[8] Ordem a ser selecionada
//[9]..[10]..[n] Campos a Processar (se houver)

Private lEnd    := .F.// Controle de cancelamento do relatorio
Private m_pag   := 1  // Contador de Paginas
Private nLastKey:= 0  // Controla o cancelamento da SetPrint e SetDefault

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Realiza o acerto no grupo de perguntas MTR715 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AjustaSX1()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica as Perguntas Seleciondas                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ MV_PAR01          // Filial origem de                        ³
//³ MV_PAR02          // Filial origem ate                       ³
//³ MV_PAR03          // Data de emissao de                      ³
//³ MV_PAR04          // Data de emissao ate                     ³
//³ MV_PAR05          // Doc Saida de                            ³
//³ MV_PAR06          // Doc Saida ate                           ³
//³ MV_PAR07          // Ser Doc Saida de                        ³
//³ MV_PAR08          // Ser Doc Saida ate                       ³
//³ MV_PAR09          // Produto de                              ³
//³ MV_PAR10          // Produto ate                             ³
//³ MV_PAR11          // Lista NFs Em transito/Ja recebidas/Todas³
//³ MV_PAR12          // Totaliza quebras  Sim/Nao               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte(cPerg,.F.)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Envia para a SetPrinter                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,lDic,aOrdem,lComp,Tamanho,,lFiltro)
If ( nLastKey==27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	Set Filter to
	Return
Endif
SetDefault(aReturn,cString)
If ( nLastKey==27 )
	dbSelectArea(cString)
	dbSetOrder(1)
	Set Filter to
	Return
Endif
RptStatus({|lEnd| ImpDet(@lEnd,wnRel,cString,nomeprog,Titulo)},Titulo)
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³ ImpDet   ³ Autor ³ Rodrigo de A Sartorio ³ Data ³29.01.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Controle de Fluxo do Relatorio.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ImpDet(lEnd,wnrel,cString,nomeprog,Titulo)
Local aStrucSD2  := {}
Local aFilsCalc  := {}                 				// Array com dados das filiais
Local aAreaSM0   := SM0->(GetArea()) 				// Status original do arquivo SM0
Local cFilBack   := cFilAnt           		 		// Filial corrente original
Local aRetNf     := {}                				// Informacoes relacionadas a transferencia entre filiais
Local cSeek      := ""                				// Variavel utilizada na quebra
Local cWhile     := ""                				// Variavel utilizada na quebra
Local cTexto     := ""                				// Texto para totalizacao utilizada na quebra
// Texto para totalizacao geral
Local cTextoGer  := STR0011 //"TOTAL GERAL EM TRANSITO FILIAL "
Local cName 	 := "" 								// Nome do campo utilizado no filtro
Local cQryAd 	 := "" 						   		// Campos adicionados na query conforme filtro de Usuario
Local aTotais    := {0,0,0}				  			// Array para totalizacao utilizada na quebra
Local aTotaisGer := {0,0,0}				 			// Array para totalizacao geral
Local li         := 100               				// Contador de Linhas
Local cbCont     := 0                 				// Numero de Registros Processados
Local cbText     := ""                				// Mensagem do Rodape
Local cQuery     := ""  								// Query para filtragem
Local lQuery     := .F.								// Variavel que indica filtragem
Local cAliasSD2  := "SD2"							// Alias para processamento
Local nTamDoc    := TamSX3("D2_DOC")[1]
Local nX		 := 0
Local lUsaFilTrf := IIF(FindFunction('UsaFilTrf'), UsaFilTrf(), .F.)
Local nRecnoSF4  := 0
//
//                                  1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21      22
//                        01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
Local cCabec1:= STR0012  // "FILIAL     DESCRICAO       DOCUMENTO SERIE TES CFO   DESCRICAO          PRODUTO         DESCRICAO       GRUPO UM           QUANTIDADE     VALOR TOTAL     CUSTO TOTAL     DATA DE   |FILIAL     DESCRICAO FILIAL DATA DE  "
Local cCabec2:= STR0013  // "ORIGEM     ORIGEM                          ORI ORIG  OPERACAO ORIGEM                                                                                                      EMISSAO   |DESTINO    DESTINO          DIGITACAO"
cCabec1:= 		 		    "FILIAL     DESCRICAO       DOCUMENTO SERIE TES CFO   PRODUTO        DESCRICAO       GRUPO UM           QUANTIDADE     VALOR TOTAL DATA DE   |FILIAL     DESCRICAO FILIAL DATA DE    CHAVE NOTA FISCAL"
cCabec2:= 	  	 		    "ORIGEM     ORIGEM                          ORI ORIG                                                                               EMISSAO   |DESTINO    DESTINO          DIGITACAO"

//                        XXXXXXXXXX  XXXXXXXXXXXXXXX XXXXXX   XXX   XXX XXXXX XXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXX XXXXX XX XXXXXXXXXXXXXX XXXXXXXXXXXXXXX XXXXXXXXXXXXXXX XXXXXXXXXX|XXXXXXXXXX XXXXXXXXXXXXXXX  XXXXXXXXXX
//                        1234567890 123456789012345 123456    123   123 12345 123456789012345678 123456789012345 1234567890123456789012345 12345 12 12345678901234 123456789012345 123456789012345 1234567890|1234567890 123456789012345  1234567890

// Caso o tamanho do campo documento seja maior que 9 mudar o cabecalho
If nTamDoc > 9
//                                  1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21      22
//                        01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	cCabec1 := STR0017 //"FILIAL     DESCRICAO        DOCUMENTO            SERIE TES  CFO         PRODUTO         DESCRICAO PRODUTO         GRUPO UM QUANTIDADE     VALOR TOTAL     CUSTO TOTAL     DATA DE   |FILIAL     DESCRICAO        DATA DE  "
	cCabec2 := STR0018 //"ORIGEM     ORIGEM                                ORI   ORIG                                                                                                               EMISSAO   |DESTINO    DESTINO          DIGITACAO"
	cCabec1:= 		     "FILIAL     DESCRICAO        DOCUMENTO            SERIE TES  CFO         PRODUTO         DESCRICAO PRODUTO         GRUPO UM QUANTIDADE     VALOR TOTAL DATA DE   |FILIAL     DESCRICAO FILIAL DATA DE  CHAVE NOTA FISCAL"
	cCabec2:= 	  	     "ORIGEM     ORIGEM                                ORI ORIG                                                                               EMISSAO   |DESTINO    DESTINO          DIGITACAO"
//                        XXXXXXXXXX XXXXXXXXXXXXXXX  XXXXXXXXXXXXXXXXXXXX XXX   XXX  XXXXX       XXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXX XXXXX XX XXXXXXXXXXXXXX XXXXXXXXXXXXXXX XXXXXXXXXXXXXXX XXXXXXXXXX|XXXXXXXXXX XXXXXXXXXXXXXXX  XXXXXXXXXX
//                        1234567890 123456789012345  12345678901234567890 123   123  12345       123456789012345 1234567890123456789012345 12345 12 12345678901234 123456789012345 123456789012345 1234567890|1234567890 123456789012345  1234567890
EndIf

// Posiciona arquivos utilizados nas ordens corretas
dbSelectArea("SB1")
dbSetOrder(1)

dbSelectArea("SF4")
dbSetOrder(1)

// Varre arquivo de itens de nota fiscal da filial posicionada
dbSelectArea("SD2")
SetRegua(LastRec())
If aReturn[8] == 1 // Ordem por produto 
	dbSetOrder(1)
	cWhile   := "D2_FILIAL+D2_COD"  
	cTexto   := STR0014 //"TOTAL DO PRODUTO EM TRANSITO"
ElseIf aReturn[8] == 2 // Ordem de documento
	dbSetOrder(3)                   
	cWhile   := "D2_FILIAL+D2_DOC+D2_SERIE"  
	cTexto   := STR0015 //"TOTAL DO DOCUMENTO EM TRANSITO"
ElseIf aReturn[8] == 3 // Ordem de data
	dbSetOrder(5)                         
	cWhile   := "D2_FILIAL+DTOS(D2_EMISSAO)"  	
	cTexto   := STR0016 //"TOTAL DA DATA EM TRANSITO"	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega filiais da empresa corrente                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SM0")
dbSeek(cEmpAnt)
Do While ! Eof() .And. SM0->M0_CODIGO == cEmpAnt
	// Adiciona filial
	Aadd(aFilsCalc,{alltrim(SM0->M0_CODFIL),SM0->M0_CGC,SM0->M0_FILIAL})
	dbSkip()
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Varre filiais da empresa corrente                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSeek(cEmpAnt)
Do While ! Eof() .And. SM0->M0_CODIGO == cEmpAnt
	cFilAnt:=SM0->M0_CODFIL
	aTotaisGer:= {0,0,0}
	// Filtra filial da nota fiscal de saida
	If cFilAnt < MV_PAR01 .Or. cFilAnt > MV_PAR02
		dbSkip()
		Loop
	EndIf
	dbSelectArea("SD2")

	#IFDEF TOP
		cQuery := "SELECT SD2.D2_FILIAL,SD2.D2_EMISSAO,SD2.D2_DOC,SD2.D2_SERIE,SD2.D2_COD,SD2.D2_TES,SD2.D2_CF,SD2.D2_UM," + CRLF +;
				  " 	  SD2.D2_QUANT,SD2.D2_TOTAL,SD2.D2_CUSTO1,SD2.D2_TIPO,SD2.D2_CLIENTE,SD2.D2_LOJA" + CRLF +;
				  "     , F2_CHVNFE" + CRLF
	    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Esta rotina foi escrita para adicionar no select os campos         ³
		//³usados no filtro do usuario quando houver, a rotina acrecenta      ³
		//³somente os campos que forem adicionados ao filtro testando         ³
		//³se os mesmo já existem no select ou se forem definidos novamente   ³
		//³pelo o usuario no filtro, esta rotina acrecenta o minimo possivel  ³
		//³de campos no select pois a tabela SD1 tem muitos campos e a query  |
		//³pode derrubar o TOP CONNECT e abortar o sistema				      |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	   	
		aStrucSD2 := SD2->(dbStruct())
		 If !Empty(aReturn[7])
		 	For nX := 1 To SD2->(FCount())
		 	cName := SD2->(FieldName(nX))
		 	If AllTrim( cName ) $ aReturn[7]
		      	If aStrucSD2[nX,2] <> "M"  
		      		If !cName $ cQuery .And. !cName $ cQryAd
		        		cQryAd += "," + cName 
		          	Endif 	
		       	EndIf
			EndIf 			       	
		 	Next nX
     	 Endif     
			 
			 If !Empty(cQryAd)
				cQuery+= cQryAd
			 EndIf	
		lQuery    := .T.
		cAliasSD2 := GetNextAlias()  
		cQuery += " FROM SF2010 F2 " + CRLF +;
			      " JOIN SD2010 SD2 ON F2_FILIAL=D2_FILIAL " + CRLF +;
			      "  AND F2_DOC=D2_DOC " + CRLF +;
			      "  AND F2_SERIE=D2_SERIE " + CRLF +;
			      "  AND F2_CLIENTE=D2_CLIENTE " + CRLF +;
			      "  AND F2_LOJA=D2_LOJA " + CRLF +;
			      "  ,"+RetSqlName("SF4")+" SF4 WHERE SD2.D2_FILIAL='"+xFilial("SD2")+"' AND SD2.D_E_L_E_T_ <> '*' AND " + CRLF
		cQuery += "SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SF4.D_E_L_E_T_ <> '*' AND " + CRLF +;
				  "SF4.F4_TRANFIL = '1' AND SF4.F4_CODIGO = SD2.D2_TES AND " + CRLF +;
				  "SD2.D2_EMISSAO >= '"+DTOS(MV_PAR03)+"' AND SD2.D2_EMISSAO <= '"+DTOS(MV_PAR04)+"' AND " + CRLF +;
				  "SD2.D2_DOC >= '"+MV_PAR05+"' AND SD2.D2_DOC <= '"+MV_PAR06+"' AND " + CRLF +;
				  "SD2.D2_SERIE >= '"+MV_PAR07+"' AND SD2.D2_SERIE <= '"+MV_PAR08+"' AND " + CRLF +;
				  "SD2.D2_COD >= '"+MV_PAR09+"' AND SD2.D2_COD <= '"+MV_PAR10+"' " + CRLF +;
				  "ORDER BY " + SqlOrder(SD2->(IndexKey()))
		
		//cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSD2,.T.,.T.)
		aEval(SD2->(dbStruct()), {|x| If(x[2] <> "C" .And. FieldPos(x[1]) > 0, TcSetField(cAliasSD2,x[1],x[2],x[3],x[4]),Nil)})
		dbSelectArea(cAliasSD2)
		Memowrite("C:\TOTVS_RELATORIOS\VAESTR02.txt",cQuery)	// Gera Arquivo de texto
	#ELSE
		dbSeek(xFilial("SD2"))
	#ENDIF
	Do While !Eof() .And. xFilial("SD2") == D2_FILIAL
		If lEnd
			@ Prow()+1,001 PSAY STR0007 //"CANCELADO PELO OPERADOR"
			Exit
		EndIf
		IncRegua()
		// Valida o Filtro de Usuario
		If !Empty(aReturn[7]) .And. !&(aReturn[7])
			dbSkip()
			Loop
		EndIf	  
		// So efetua filtragem caso nao tenha efetuado na query		
		If !lQuery
			// Filtra emissao da nota fiscal de saida
			If D2_EMISSAO < MV_PAR03 .Or. D2_EMISSAO > MV_PAR04
				dbSkip()
				Loop
			EndIf
			// Filtra documento da nota fiscal de saida
			If D2_DOC < MV_PAR05 .Or. D2_DOC > MV_PAR06
				dbSkip()
				Loop
			EndIf
			// Filtra serie da nota fiscal de saida
			If D2_SERIE < MV_PAR07 .Or. D2_SERIE > MV_PAR08
				dbSkip()
				Loop
			EndIf
			// Filtra produto da nota fiscal de saida
			If D2_COD < MV_PAR09 .Or. D2_COD > MV_PAR10
				dbSkip()
				Loop
			EndIf
		EndIf
		// Totaliza de acordo com a escolha o usuario
		cSeek := &(cWhile)
		aTotais:={0,0,0}
		Do While !Eof() .And. cSeek  == &(cWhile)
			// Valida o Filtro de Usuario
			If !Empty(aReturn[7]) .And. !&(aReturn[7])
				dbSkip()
				Loop
			EndIf		
			// So efetua filtragem caso nao tenha efetuado na query
			If !lQuery
				// Filtra emissao da nota fiscal de saida
				If D2_EMISSAO < MV_PAR03 .Or. D2_EMISSAO > MV_PAR04
					dbSkip()
					Loop
				EndIf
				// Filtra documento da nota fiscal de saida
				If D2_DOC < MV_PAR05 .Or. D2_DOC > MV_PAR06
					dbSkip()
					Loop
				EndIf
				// Filtra serie da nota fiscal de saida
				If D2_SERIE < MV_PAR07 .Or. D2_SERIE > MV_PAR08
					dbSkip()
					Loop
				EndIf
				// Filtra produto da nota fiscal de saida
				If D2_COD < MV_PAR09 .Or. D2_COD > MV_PAR10
					dbSkip()
					Loop
				EndIf
			EndIf
			// Checa TES
			If lQuery .Or. (!lQuery .And. SF4->(MsSeek(xFilial("SF4")+(cAliasSD2)->D2_TES)) .And. SF4->F4_TRANFIL == "1")
				aRetNF:=MR715BuscaNF(aFilsCalc,cAliasSD2,lUsaFilTrf)       			
				If Len(aRetNF) > 0
					// Checa status de acordo com o parametro
					If MV_PAR11 == 3 .Or. (MV_PAR11 == 2 .And. !Empty(aRetNF[3])) .Or. (MV_PAR11 == 1  .And. Empty(aRetNf[3]))
						// Imprime linha
						If ( li > 58 )
							li := cabec(Titulo,cCabec1,cCabec2,nomeprog,Tamanho,If(aReturn[4]==1,15,18))
							li++
						Endif

	                    // Posiciona no produto
	                    SB1->(MsSeek(xFilial("SB1")+(cAliasSD2)->D2_COD))
						@ li,nP1:=0 	 PSAY Substr(cFilAnt,1,10)
						@ li,nP2:=nP1+11 PSAY Substr(SM0->M0_FILIAL,1,15)
						@ li,nP3:=nP2+16 PSAY Substr((cAliasSD2)->D2_DOC,1,nTamDoc)
						If nTamDoc > 9
							@ li,nP4:=nP3+21 PSAY Substr((cAliasSD2)->D2_SERIE,1,3)
							@ li,nP5:=nP4+07 PSAY Substr((cAliasSD2)->D2_TES,1,3)
							@ li,nP6:=nP5+05 PSAY Substr((cAliasSD2)->D2_CF,1,5)
						Else
							@ li,nP4:=nP3+10 PSAY Substr((cAliasSD2)->D2_SERIE,1,3)
							@ li,nP5:=nP4+06 PSAY Substr((cAliasSD2)->D2_TES,1,3)
							@ li,nP6:=nP5+04 PSAY Substr((cAliasSD2)->D2_CF,1,5)
							nRecnoSF4 := SF4->(Recno())
							SF4->(Dbseek((cAliasSD2)->D2_FILIAL+(cAliasSD2)->D2_TES))
							//@ li,053 PSAY Substr(SF4->F4_TEXTO,1,18)  -20
							SF4->(dbGoTo(nRecnoSF4)) 
						EndIf	
						@ li,nP7 :=nP6 +05 PSAY Substr((cAliasSD2)->D2_COD,1,15)
						@ li,nP8 :=nP7 +07 PSAY Substr(SB1->B1_DESC,1,15)
						@ li,nP9 :=nP8 +12 PSAY Substr(SB1->B1_GRUPO,1,5)
						@ li,nP10:=nP9 +06 PSAY Substr((cAliasSD2)->D2_UM,1,2)
						@ li,nP11:=nP10+03 PSAY (cAliasSD2)->D2_QUANT Picture PesqPict("SD2","D2_QUANT",14)
						@ li,nP12:=nP11+15 PSAY (cAliasSD2)->D2_TOTAL Picture PesqPict("SD2","D2_TOTAL",15)
						//@ li,144 PSAY (cAliasSD2)->D2_CUSTO1 Picture PesqPict("SD2","D2_CUSTO1",15)
						@ li,nP13:=nP12+19 PSAY (cAliasSD2)->D2_EMISSAO
						@ li,nP14:=nP13+13 PSAY "|"
						// Imprime informacoes da devolucao
						If !Empty(aRetNf[3])
							@ li,nP15:=nP14+01 PSAY Substr(aRetNf[1],1,10)
							@ li,nP16:=nP15+11 PSAY Substr(aRetNf[2],1,13)
							@ li,nP17:=nP16+16 PSAY aRetNf[3]
						// Soma valores em transito
						Else
// Ajustes para Vista Alegre
							If !Empty(aRetNf[1])
								@ li,nP15:=nP14+01 PSAY aRetNf[1]
								@ li,nP16:=nP15+11 PSAY Substr(aRetNf[2],1,13)
							Else
								@ li,nP15:=nP14+01 PSAY Posicione("SA1",1,xFilial("SA1")+(cAliasSD2)->D2_CLIENTE +(cAliasSD2)->D2_LOJA,"A1_FILTRF" ) // aRetNf[1]
								@ li,nP16:=nP15+11 PSAY Substr(Posicione("SA1",1,xFilial("SA1")+(cAliasSD2)->D2_CLIENTE +(cAliasSD2)->D2_LOJA,"A1_NREDUZ" ),1,13)							
							Endif
// Final AJustes Vista Alegre - 01/09/2015
//							@ li,181 PSAY aRetNf[1]
//							@ li,192 PSAY Substr(aRetNf[2],1,13)
							@ li,nP17:=nP16+16 PSAY STR0019 // o documento ainda nao foi classificado (pre-nota)						
							aTotais[1]+=(cAliasSD2)->D2_QUANT ;aTotaisGer[1]+=(cAliasSD2)->D2_QUANT
							aTotais[2]+=(cAliasSD2)->D2_TOTAL ;aTotaisGer[2]+=(cAliasSD2)->D2_TOTAL
							aTotais[3]+=(cAliasSD2)->D2_CUSTO1;aTotaisGer[3]+=(cAliasSD2)->D2_CUSTO1
						EndIf
						@ li,nP18:=nP17+15 PSAY (cAliasSD2)->F2_CHVNFE // o documento ainda nao foi classificado (pre-nota)						
						li++
						cbCont++
					EndIf
				EndIf
			EndIf
			dbSelectArea(cAliasSD2)
			dbSkip()
		EndDo
		// Imprime total caso tenha quantidade em transito
		If MV_PAR12 == 1 .And. (QtdComp(aTotais[1],.T.) > QtdComp(0,.T.))
			@ li,nP1  PSAY cTexto 
			@ li,nP11 PSAY aTotais[1] Picture PesqPict("SD2","D2_QUANT",14)
			@ li,nP12 PSAY aTotais[2] Picture PesqPict("SD2","D2_TOTAL",15)
//			@ li,144 PSAY aTotais[3] Picture PesqPict("SD2","D2_CUSTO1",15)		
			aTotais:={0,0,0}      
			li+=2
		EndIf
	EndDo
	// Fecha arquivo da query
	If lQuery
		dbSelectArea(cAliasSD2)
		dbCloseArea()
		dbSelectArea("SD2")
	EndIf
	// Imprime total caso tenha quantidade em transito
	If QtdComp(aTotaisGer[1],.T.) > QtdComp(0,.T.)     
 		li+=2
		@ li,nP1  PSAY cTextoGer+cFilAnt
		@ li,nP11 PSAY aTotaisGer[1] Picture PesqPict("SD2","D2_QUANT",14)
		@ li,nP12 PSAY aTotaisGer[2] Picture PesqPict("SD2","D2_TOTAL",15)
		//@ li,144 PSAY aTotaisGer[3] Picture PesqPict("SD2","D2_CUSTO1",15)		
		aTotaisGer:={0,0,0}      
		li+=2
	EndIf
	dbSelectArea("SM0")
	dbSkip()
EndDo
// Restaura filial original
cFilAnt:=cFilBack
RestArea(aAreaSM0)

If cbCont > 0
	Roda(cbCont,cbText,Tamanho)
EndIf

Set Device To Screen
Set Printer To
If ( aReturn[5] = 1 )
	dbCommitAll()
	OurSpool(wnrel)
Endif
MS_FLUSH()
Return(.T.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³ MR715BuscaNF                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Autor     ³ Rodrigo de Almeida Sartorio              ³ Data ³ 29/01/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Busca as informacoes da nota fiscal de transferencia       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³aFilsCalc  Array com informacoes das filiais da empresa     ³±±
±±³           ³           em uso corrente no sistema.                      ³±±
±±³           ³cAliasSD2  Area do arquivo de itens de NF de saida          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³aRetNF     Array com informacoes da nota de retorno         ³±±
±±³           ³           [1] Codigo da filial que recebeu a nota          ³±±
±±³           ³           [2] Descricao da filial que recebu a nota        ³±±
±±³           ³           [3] Data de digitacao da nota                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³  Uso      ³ MATR715                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MR715BuscaNF(aFilsCalc,cAliasSD2,lUsaFilTrf)
Local aRetNf      := {"","",""}
Local nAchoCGC    := 0
Local nAchoFil    := 0
Local aArea       := GetArea()
Local cFilBack    := cFilAnt
Local cCGCOrig    := ""
Local cCGCDest    := SM0->M0_CGC
Local cCodFilOrig := ""
Local cCodFilDest := SM0->M0_CODFIL

If !lUsaFilTrf
	// Posiciona no fornecedor
	If (cAliasSD2)->D2_TIPO $ "DB"
		dbSelectArea("SA2")
		dbSetOrder(1)
		If MsSeek(xFilial("SA2")+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA)
			cCGCOrig:=SA2->A2_CGC
		EndIf
	Else
		// Posiciona no cliente
		cArqCliFor:="SA1"
		dbSelectArea("SA1")
		dbSetOrder(1)
		If MsSeek(xFilial("SA1")+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA)
			cCGCOrig:=SA1->A1_CGC
		EndIf
	EndIf
	
	// Checa se cliente / fornecedor esta configurado como filial do sistema
	If !Empty(cCGCOrig) .And. ((nAchoCGC:=ASCAN(aFilsCalc,{|x| x[2] == cCGCOrig})) > 0)
		// Pesquisa se nota fiscal ja foi registrada no destino
		cFilAnt := aFilsCalc[nAchoCGC,1]
		dbSelectArea("SD1")
		dbSetOrder(2)
		dbSeek(xFilial("SD1")+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE)
		While !Eof() .And. xFilial("SD1")+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE == D1_FILIAL+D1_COD+D1_DOC+D1_SERIE
			// Checa TES
			If !Empty(SD1->D1_TES)
				If SF4->(MsSeek(xFilial("SF4")+SD1->D1_TES)) .And. SF4->F4_TRANFIL == "1"
					// Itens de nota fiscal de entrada
					If SD1->D1_TIPO $ "DB"
						dbSelectArea("SA1")
						dbSetOrder(1)
						If MsSeek(xFilial("SA1")+SD1->D1_FORNECE+SD1->D1_LOJA) .And. SA1->A1_CGC == cCGCDest
							aRetNf:={cFilAnt,aFilsCalc[nAchoCGC,3],SD1->D1_DTDIGIT}
							Exit
						EndIf
					Else
						dbSelectArea("SA2")
						dbSetOrder(1)
						If MsSeek(xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA) .And. SA2->A2_CGC == cCGCDest
							aRetNf:={aFilsCalc[nAchoCGC,1] ,aFilsCalc[nAchoCGC,3],SD1->D1_DTDIGIT}
							Exit
						EndIf
					EndIf
				EndIf
			Else
				// O documento ainda nao foi classificado (pre-nota), portanto o material pode ser considerado "ainda em transito"
				aRetNf:={cFilAnt,aFilsCalc[nAchoCGC,3],''}
			EndIf
			dbSelectArea("SD1")
			dbSkip()
		End
	EndIf
Else
	// Posiciona no fornecedor
	If (cAliasSD2)->D2_TIPO $ "DB"
		dbSelectArea("SA2")
		dbSetOrder(1)
		If MsSeek(xFilial("SA2")+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA)
			cCodFilOrig := SA2->A2_FILTRF
		EndIf
	Else
		// Posiciona no cliente
		cArqCliFor:="SA1"
		dbSelectArea("SA1")
		dbSetOrder(1)
		If MsSeek(xFilial("SA1")+(cAliasSD2)->D2_CLIENTE+(cAliasSD2)->D2_LOJA)
			cCodFilOrig := SA1->A1_FILTRF
		EndIf
	EndIf
	
	// Checa se cliente / fornecedor esta configurado como filial do sistema
	If !Empty(cCodFilOrig) .And. (nAchoFil := ASCAN(aFilsCalc,{|x| x[1] == alltrim(cCodFilOrig)})) > 0 
		// Pesquisa se nota fiscal ja foi registrada no destino
		cFilAnt := aFilsCalc[nAchoFil,1]
		dbSelectArea("SD1")
		dbSetOrder(2)                                           
		dbSeek(xFilial("SD1")+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE)
		While !Eof() .And. xFilial("SD1")+(cAliasSD2)->D2_COD+(cAliasSD2)->D2_DOC+(cAliasSD2)->D2_SERIE == D1_FILIAL+D1_COD+D1_DOC+D1_SERIE
			// Checa TES
			If !Empty(SD1->D1_TES)
				If SF4->(MsSeek(xFilial("SF4")+SD1->D1_TES)) .And. SF4->F4_TRANFIL == "1"
					// Itens de nota fiscal de entrada
					If SD1->D1_TIPO $ "DB"
						dbSelectArea("SA1")
						dbSetOrder(1)
						If MsSeek(xFilial("SA1")+SD1->D1_FORNECE+SD1->D1_LOJA) .And. alltrim(SA1->A1_FILTRF) == alltrim(cCodFilDest)
							aRetNf:={cFilAnt,aFilsCalc[nAchoFil,3],SD1->D1_DTDIGIT}
							Exit
						EndIf
					Else
						dbSelectArea("SA2")
						dbSetOrder(1)
						If MsSeek(xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA) .And. alltrim(SA2->A2_FILTRF) == alltrim(cCodFilDest)
							aRetNf:={aFilsCalc[nAchoFil,1] ,aFilsCalc[nAchoFil,3],SD1->D1_DTDIGIT}
							Exit
						EndIf
					EndIf
				EndIf
			Else
				// O documento ainda nao foi classificado (pre-nota), portanto o material pode ser considerado "ainda em transito"
				aRetNf:={cFilAnt,aFilsCalc[nAchoFil,3],''}
			EndIf
			dbSelectArea("SD1")
			dbSkip()
		End
	EndIf
EndIf
// Reposiciona area original
cFilAnt:=cFilBack
RestArea(aArea)
RETURN aRetNf 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³ AjustaSX1³ Autor ³ Microsiga S/A         ³ Data ³28/07/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Ajusta o grupo de perguntas MTR715                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR715  		                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSX1()

Local aAreaAnt := GetArea()
Local aAreaSX1 := SX1->(GetArea())
Local nTamSX1  := Len(SX1->X1_GRUPO)
Local nTamDoc  := TamSX3("D2_DOC")[1]
Local aHelpPor :={}
Local aHelpEng :={}
Local aHelpSpa :={}


PutSx1("MTR715","01","Filial de ?"   		 ,"Filial de ?"   		  ,"Filial de ?"   ,"mv_ch1","C",2,0,0,"G","","","","","MV_PAR01","","","","","","","","","","","","","")
PutSx1("MTR715","02","Filial ate?"   		 ,"Filial ate?"   		  ,"Filial ate?"   ,"mv_ch2","C",2,0,0,"G","","","","","MV_PAR02","","","","","","","","","","","","","")
PutSx1("MTR715","03","Emissao de ?"  		 ,"Emissao de ?"  		  ,"Emissao de ?"  ,"mv_ch3","D",8,0,0,"G","","","","","MV_PAR03","","","","","","","","","","","","","")
PutSx1("MTR715","04","Emissao ate?"  		 ,"Emissao ate?"  		  ,"Emissao ate?"  ,"mv_ch4","D",8,0,0,"G","","","","","MV_PAR04","","","","","","","","","","","","","")
PutSx1("MTR715","05","Doc saida de ?"		 ,"Doc saida de ?"		  ,"Doc saida de ?","mv_ch5","C",6,0,0,"G","","","","","MV_PAR05","","","","","","","","","","","","","")
PutSx1("MTR715","06","Doc saida ate?"		 ,"Doc saida ate?"		  ,"Doc saida ate?","mv_ch6","C",6,0,0,"G","","","","","MV_PAR06","","","","","","","","","","","","","")
PutSx1("MTR715","07","Ser saida de ?"		 ,"Ser saida de ?"		  ,"Ser saida de ?","mv_ch7","C",3,0,0,"G","","","","","MV_PAR07","","","","","","","","","","","","","")
PutSx1("MTR715","08","Ser saida ate?"		 ,"Ser saida ate?"		  ,"Ser saida ate?","mv_ch8","C",3,0,0,"G","","","","","MV_PAR08","","","","","","","","","","","","","")
PutSx1("MTR715","09","Produto de ?"  		 ,"Produto de ?"  		  ,"Produto de ?"  ,"mv_ch9","C",15,0,0,"G","","","","","MV_PAR09","","","","","","","","","","","","","")
PutSx1("MTR715","10","Produto ate?"  		 ,"Produto ate?"  		  ,"Produto ate?"  ,"mv_cha","C",15,0,0,"G","","","","","MV_PAR10","","","","","","","","","","","","","")
PutSx1("MTR715","11","Lista NFs  ?"  		 ,"Lista NFs  ?"  		  ,"Lista NFs  ?"  ,"mv_chb","N",1,0,1,"C","","","","","MV_PAR11","Em transito","Em transito","Em transito","","Ja recebidas","Ja recebidas","Ja recebidas","Todas","Todas","Todas","","","","","","")
PutSx1("MTR715","12","Totaliza nas quebras ?","Totaliza nas quebras ?","Totaliza nas quebras ?","mv_chc","N",1,0,1,"C","","","","","MV_PAR12","Sim","Sim","Sim","","Nao","Nao","Nao","","","","","","","","","")

dbSelectArea("SX1")
dbSetOrder(1)
If dbSeek(PADR("MTR715",nTamSX1)+"05") .And. X1_TAMANHO <> nTamDoc
	RecLock("SX1",.F.)
	Replace X1_TAMANHO 	with nTamDoc
	MsUnLock()
EndIf

dbSelectArea("SX1")
dbSetOrder(1)
If dbSeek(PADR("MTR715",nTamSX1)+"06") .And. X1_TAMANHO <> nTamDoc
	RecLock("SX1",.F.)
	Replace X1_TAMANHO 	with nTamDoc
	MsUnLock()
EndIf

Aadd( aHelpPor, "O totalizador nas quebras e baseado na  " )
Aadd( aHelpPor, "quantidade de transferencia que estão em" )
Aadd( aHelpPor, "transito. (documentos de entrada penden-" )
Aadd( aHelpPor, "tes de classificação)                   " )

Aadd( aHelpEng, "The totalizer and breaks based on the   " )
Aadd( aHelpEng, "amount of transfer that are in transit. " )
Aadd( aHelpEng, "(input documents pending classification)" )

Aadd( aHelpSpa, "El totalizador y se rompe basado en la  " )
Aadd( aHelpSpa, "cantidad de transferencia que están en  " )
Aadd( aHelpSpa, "tránsito. (documentos de entrada en     " )
Aadd( aHelpSpa, "espera de clasificación)                " )

PutSX1Help("P."+"MTR715"+"12.",aHelpPor,aHelpSpa,aHelpEng)

RestArea(aAreaSX1)
RestArea(aAreaAnt)
Return Nil
