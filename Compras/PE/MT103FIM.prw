#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "font.ch"
#include "colors.ch"

User Function MT103FIM   
Local nOpcao 	:= PARAMIXB[1]   // Opùùo Escolhida pelo usuario no aRotina  // 3- incluir  2-visualizar 5-excluir
Local nConfirma := PARAMIXB[2]   // Se o usuario confirmou a operaùùo de gravaùùo da NFECODIGO DE APLICAùùO DO USUARIO.....
Local aArea		:= GetArea()
Local aAreaD1	:= SD1->(GetArea())
Local cTMEntra	:= SuperGetMv("MV_X_TMCEN",.T.,"301") // Tipo de Movimento de Entrada para Quebra a Maior no peso de Milho da NF
Local cTMSaida	:= SuperGetMv("MV_X_TMCSA",.T.,"801") // Tipo de Movimento de Saida para Quebra a Menor no peso de Milho da NF
Local nTolRec	:= SuperGetMv("MV_TOLREC",.T.,40) // Tolerancia no recebimento de insumos se peso for inferior a tolerancia avisa sobre diferenùa
Local cProdMil	:= SuperGetMv("MV_X_PRDMI",.T.,"020017;020080;020079;") // Indica cùdigos de prudutos que NùO deverùo passar pela regra de 
Local cSB1Insumo := GetMv("MV_X_PRDMI",,"020017;020080;020079;") // Indica cùdigos de prudutos que NùO deverùo passar pela regra de
Local cGrpAju   := SuperGetMv("MV_GRPAJU",.T.,"02;03")// Grupo de Produtos que serù ajustado pela TM
Local lCmpAut  	:= IIF("S"==SuperGetMv("MV_X_CMPAU",.T.,"S"),.T.,.F.)  // Compensa automatico S-sim ou N-nao
Local QryDia	:= "" // Query Diùrias
Local cB1Diari	:= ""
Local cZ7Fil 	:= ""	                          	
Local QtdDia	:= 0 
Local nDif 		:= 0


	// Alert('MT103FIM - Opùùo: ' + cValToChar(nOpcao) )
    
	/* MJ : 26/12/18
		-> Gravar Data de Inclusao do documento; */
	If nConfirma==1 .and. (nOpcao==3 .or. nOpcao==4)
	//SF1->(DbSetOrder(1)) // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
	//If SF1->( DbSeek( xFilial('SF1')+cNFiscal+cSerie+ca100For+cLoja ) )
		If Empty(SF1->F1_X_DTINC)
			
			// Alert('[MT103FIM] Gravando: F1_X_DTINC')
			
			RecLock( 'SF1', .F.)
				SF1->F1_X_DTINC := MsDate()
			SF1->(MsUnlock())
			
		EndIf
	//EndIf
	EndIf
	
	DbSelectArea("SB1")
	DbSetOrder(1) 	// B1_FILIAL + B1_COD

	DbSelectArea("SD1")
	DbSetOrder(1) 	// D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM

	DbSelectArea("SF4")
	DbSetOrder(1) 	// D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_ITEM


	//Se for confirmado
	If (nConfirma==1)  .and. (nOpcao==3 .or. nOpcao==4) // inclusao apenas ou classificaÁ„o

		// Compensacao automatica de titulos de nf com PA
		If lCmpAut
			u_CmpAutTit('P',SF1->F1_FILIAL, SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA)
		Endif

		DbSelectArea("SD1")
		//Posicionando nos registros conforme dados do Cabeùalho
		If Dbseek(SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
 		 	
			//Enquanto nùo estiver no fim dos registros e os dados forem referentes ao Cabeùalho
		 	While !SD1->(EOF()) .AND. (SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA) = (SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA)					
				
		 		//Seleciona a tabela de TES e Posiciona referente ao Documento de Entrada
				DbSelectArea("SF4")
				//DbSetOrder(1)
			 
				If Dbseek(xFilial("SF4")+SD1->D1_TES)
						If Alltrim(SD1->D1_GRUPO)$cGrpAju .AND. !Alltrim(SD1->D1_COD)$cSB1Insumo .AND.;
									 AllTrim(SF4->F4_DUPLIC)=='S' .AND.;
									 AllTrim(SF4->F4_ESTOQUE) =='S' .AND.;
									 !AllTrim(SF4->F4_TRANFIL)=='1' .AND.;
									 AllTrim(SF1->F1_TIPO)=='N' .AND.;
									 SD1->D1_QUANT > SD1->D1_X_PESOB
						// Lancar Movimento para Registrar a quantidade de classificacao
							If nTolRec < (SD1->D1_QUANT - SD1->D1_X_PESOB )
								nDif := (SD1->D1_QUANT - SD1->D1_X_PESOB)
								MsgInfo('Providenciar DevoluÁ„o de '  + AllTrim(Str(nDif)) +  ' Kgs referente a diferenÁa da Nota Fiscal')
								DocEmail() // Comunicar envolvidos 
							EndIf
						ElseIf Alltrim(SD1->D1_GRUPO)$cGrpAju.AND.!Alltrim(SD1->D1_COD)$cSB1Insumo .AND.;
										 AllTrim(SF4->F4_DUPLIC)=='S' .AND.;
										 AllTrim(SF4->F4_ESTOQUE) =='S' .AND.;
										 !AllTrim(SF4->F4_TRANFIL)=='1' .AND.;
										 AllTrim(SF1->F1_TIPO)=='N' .AND.;
										 SD1->D1_QUANT < SD1->D1_X_PESOB 
										 
								nDif := (SD1->D1_QUANT - SD1->D1_X_PESOB)
								MsgInfo('Realizada Entrada em estoque de '  + AllTrim(Str(abs(nDif))) +  ' Kgs referente a recebimento a maior.')
								LanClassif(SD1->D1_FILIAL, "E", cTMEntra, SD1->D1_COD, SD1->D1_LOCAL, (SD1->D1_X_PESOB - SD1->D1_QUANT), 0.01, SD1->D1_DTDIGIT, 'REF. NF ' +SD1->D1_DOC+ '-'+SD1->D1_SERIE+'-EMISSAO ' +DTOC(SD1->D1_EMISSAO)+ '-FORNECEDOR ' +SD1->D1_FORNECE+ '-PESO NF: ' +AllTrim(STR(SD1->D1_QUANT))+ ' PESO BALANCA: '+AllTrim(STR(SD1->D1_X_PESOB))+'', '', '', '', SD1->D1_FORNECE)
						Endif
   				Endif

				cB1Diari := Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_X_DIARI")

				If cB1Diari=="S"
					QryDia :=  "  SELECT * "
					QryDia +=  "  FROM "+RetSqlName('SZ7')+" SZ7 "
					QryDia +=  "  WHERE SZ7.D_E_L_E_T_ = '' "
					QryDia +=  "  AND Z7_SERVICO = '"+SD1->D1_COD+"' "
					QryDia +=  "  AND Z7_PEDIDO	 = '"+SD1->D1_PEDIDO+"' "
					QryDia +=  "  AND Z7_FORNECE = '"+SD1->D1_FORNECE+"' "
					QryDia +=  "  AND Z7_LOJA 	 = '"+SD1->D1_LOJA+"' "
					QryDia +=  "  AND Z7_STATUS  = 'P' "
					QryDia +=  "  ORDER BY Z7_FILIAL, Z7_COD "
					
					If Select("QRYZ7") > 0
					 	QRYZ7->(DbCloseArea())
					EndIf
					TcQuery QryDia New Alias "QRYZ7"
					
					QtdDia := SD1->D1_QUANT // Quantidade e abater da Diaria

					If !QRYZ7->(EOF())
			 			While  QtdDia > 0 
			 			
			 				SZ7->(dbGoTo(QRYZ7->R_E_C_N_O_))
			 				
			 				QtdDia := QtdDia - SZ7->Z7_QUANT
			 				
			 				RecLock("SZ7",.F.)
			 					Z7_FILDOC	:= SD1->D1_FILIAL
			 					Z7_DOC		:= SD1->D1_DOC
			 					Z7_SERIE	:= SD1->D1_SERIE
			 					Z7_ITEMNF	:= SD1->D1_ITEM  
			 					Z7_STATUS	:= 'A' // ATENDIDO	     
			 				SZ7->(MSUnLock())
			 				
			 				QRYZ7->(dbSkip()) 
			 				
			 				If QRYZ7->(EOF())
			 					Exit
			 				Endif
			 			EndDo	
			 			
					Endif
									
				Endif
	
				SD1->(dbSkip())
			Enddo
		Endif
		
    //Endif
    // FIM Conforme Sim e Inclusùo
    
	/*
	Excluir itens SD1;
	*/
	ElseIf  (nConfirma==1)  .and. nOpcao==5 // Exclusùo apenas
	
	 	//Posicionando nos registros conforme dados do Cabeùalho
	 	DbSelectArea("SD1")
		SD1->(DbSetOrder(1))
	 	While SD1->(Dbseek(SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
			
			RecLock('SD1', .F.)
				SD1->(DbDelete())
			SD1->(MsUnlock())

			SD1->(dbSkip())
		EndDo

	EndIf
    
    SD1->(dbCloseArea())
RestArea(aAreaD1)
RestArea(aArea)
Return Nil                


Static Function DocEmail()
Local xAssunto  := "Recebimento de Mercadoria menor que nota fiscal"
Local xaDados 	:= {}
Local xHTM		:= ""
// Local cFornece  := ""
Local nDif	    := 0

Local xEmail	:= GetMV("MV_RECINS",,"lisandra.santos@vistaalegre.agr.br,"+;
									  "camila.martins@vistaalegre.agr.br,"+;
									  "ricardo.cristofano@vistaalegre.agr.br,"+;
									  "ricardo.souza@vistaalegre.agr.br,"+;
									  "rodrigo.martins@vistaalegre.agr.br,"+;
									  "aderaldo.evangelista@vistaalegre.agr.br,"+;
									  "carlos.silva@vistaalegre.agr.br,"+;
									  "edson.mendonca@vistaalegre.agr.br,"+;
									  "alex.castilho@vistaalegre.agr.br,"+;
									  "joao.santos@vistaalegre.agr.br,"+;
									  "miguel.bernardo@vistaalegre.agr.br,"+;
									   "arthur.toshio@vistaalegre.agr.br" ) // Emails que receberao o email da funcao FECHAMES

	// xEmail := "miguel.bernardo@vistaalegre.agr.br"
	
	aAdd( xaDados, { "LogoTipo", "\workflow\images\logoM.jpg" } )

	aTelEmp:= FisGetTel(SM0->M0_TEL)
	cTelEmp := "" //IIF(aTelDest[1] > 0,U_ConvType(aTelDest[1],3),"") // Cùdigo do Pais
	cTelEmp += "("+ IIF(aTelEmp[2] > 0,U_ConvType(aTelEmp[2],3),"") + ") " // Cùdigo da ùrea
	cTelEmp += IIF(aTelEmp[3] > 0,U_ConvType(aTelEmp[3],9),"") // Cùdigo do Telefone
	//cFoneEmp:= "Telefone: " + cFoneEmp 

	xHTM := '<HTML><BODY>'
	xHTM += '<hr>'
	xHTM += '<p  style="word-spacin g: 0; line-height: 100%; margin-top: 0; margin-bottom: 0">'
	xHTM += '<b><font face="Verdana" SIZE=3>' + SM0->M0_NOMECOM + '</b></p>'
	xHTM += '<br>'                                                                                            
	xHTM += '<font face="Verdana" SIZE=3>'+Alltrim( SM0->M0_ENDENT )+" - "+Alltrim(SM0->M0_BAIRENT)
	xHTM += 		" - CEP: "+alltrim(SM0->M0_CEPENT)+" - Fone/Fax "+ cTelEmp + '</p>'
	xHTM += '<hr>'
	cTitulo := "Quantidade Recebida Ultrapassou a Tolerùncia"
	xHTM += '<b><font face="Verdana" SIZE=3>'+cTitulo+'</b></p>'
	xHTM += '<hr>'
	xHTM += '<font face="Verdana" SIZE=2>Data: ' + dtoc(date()) + ' Hora: ' + time() + '</p>'
	xHTM += '<br><br>'      
	xHTM += '<div>'      
	cFornec := Posicione("SA2",1,xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA,"A2_NOME")
	xHTM += 'Fornecedor: ' + cFornec +'</b>'
	xHTM += '<br>'
	xHTM += 'Nota Fiscal '+SD1->D1_DOC+'-'+SD1->D1_SERIE+'</b>'
	xHTM += '<br>'
	xHTM += 'Emissùo ' +DTOC(SD1->D1_EMISSAO) + '</b>'
	xHTM += '<br>'
	cProd := Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_DESC")
	xHTM += 'Produto: ' +cProd+ '</b>'
	xHTM += '<br>'
	nQtNf := SD1->D1_QUANT
	xHTM += 'Peso NF: ' +AllTrim(str(nQtNf))+ '</b>'
	xHTM += '<br>'
	nQtRec := SD1->D1_X_PESOB
	xHTM += 'Peso Chegada: ' +AllTrim(Str(nQtRec))+ '</b>'
	xHTM += '<br>'
	nDif := (SD1->D1_QUANT - SD1->D1_X_PESOB)
	xHTM += '<b>Diferenùa: '+ AllTrim(Str(nDif)) +'</b>'
	xHTM += '<br>'
	xHTM += 'Data de Lanùamento da NF ' +DTOC(SF1->F1_X_DTINC)+ '</b>'
	xHTM += '</div>'      
	xHTM += '</BODY></HTML>'
	
	MemoWrite( "C:\totvs_relatorios\difrecebimento.html", xHTM )

	Processa({ || u_EnvMail(xEmail	,;			//_cPara
					"" 				,;		//_cCc
					""					,;		//_cBCC
					xAssunto			,;		//_cTitulo
					xaDados				,;		//_aAnexo
					xHTM				,;		//_cMsg
					.T.)},"Enviando e-mail...")	//_lAudit
Return nil


/****************************************************************
Ponto de Entrada - Exclusùo do Documento de Entrada
****************************************************************/
/* MB : 10.02.2020 -> Retirado de operacao a pedido do Toshio, 
        nao esta mais em uso o processo implementado neste P.E.
 
User Function SD1100E()
Local aArea 	:= GetArea()
Local cB1Diari 	:= ''
Local QryDia 	:= ''
		// Tratamento para limpar flags das Diarias, quando ocorrer a exclusao da NF
		cB1Diari := Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_X_DIARI")
		If cB1Diari=="S"
			QryDia :=  "  SELECT * "
			QryDia +=  "  FROM "+RetSqlName('SZ7')+" SZ7 "
			QryDia +=  "  WHERE SZ7.D_E_L_E_T_ = '' "
			QryDia +=  "  AND Z7_SERVICO = '"+SD1->D1_COD+"' "
			QryDia +=  "  AND Z7_FORNECE = '"+SD1->D1_FORNECE+"' "
			QryDia +=  "  AND Z7_LOJA 	 = '"+SD1->D1_LOJA+"' "
			QryDia +=  "  AND Z7_DOC 	 = '"+SD1->D1_DOC+"' "
			QryDia +=  "  AND Z7_SERIE 	 = '"+SD1->D1_SERIE+"' "
			QryDia +=  "  AND Z7_ITEMNF	 = '"+SD1->D1_ITEM+"' "
					
			If Select("QRYZ7") > 0
			 	QRYZ7->(DbCloseArea())
			EndIf
			TcQuery QryDia New Alias "QRYZ7"
					
	 		While  !QRYZ7->(EOF())
			 	SZ7->(dbGoTo(QRYZ7->R_E_C_N_O_))			
			 	RecLock("SZ7",.F.)
			 		Z7_FILDOC	:= ''
			 		Z7_DOC		:= ''
			 		Z7_SERIE	:= ''
			 		Z7_ITEMNF	:= ''
			 		Z7_STATUS	:= 'P' // Pendente	     
			 	SZ7->(MSUnLock())
				QRYZ7->(dbSkip()) 			 				
			EndDo	
		Endif
RestArea(aArea)
Return	              
*/


/****************************************************************
Funùùo para lanùamento de movimento interno automatico
****************************************************************/
/*
cTFil		-> D3_FILIAL (Filial) 
cTipo		-> Tipo (E-Entrada, S-Saida) 
cTTM		-> D3_TM (Tipo de Movimentacao) 
cTProd		-> D3_COD (Produto) 
cTLocal		-> D3_LOCAL (Armazem/Local)
nTQtd 		-> D3_QUANT (Quantidade)
nTCusto		-> D3_CUSTO1 (Custo da moeda 1)	
dTData		-> D3_EMISSAO (Data Emissao)
cTObs		-> D3_X_OBS (Observacao)
cTCC		-> D3_CC (Centro de Custo)
cTItemCta	-> D3_ITEMCTA (Item Contabil) 
cTCLVL		-> D3_CLVL (Classe Valor)
*/
Static Function LanClassif(cTFil, cTipo, cTTM, cTProd, cTLocal, nTQtd,;
						   nTCusto, dTData, cTObs, cTCC, cTItemCta, cTCLVL,;
						   cFornece, cDocumento, RECNOSD3 )
Local aMovimento  	:= {}
Private lMsErroAuto := .F.

//Analisa os tipos e monta os dois arrays (Entrada e Saùda)
//	If (cTipo == "E") // Entrada
  	 aMovimento := {{"D3_FILIAL"	, cTFil				, NIL},; 
	   				{"D3_TM"		, cTTM				, NIL},;
	   			    {"D3_COD"		, cTProd			, NIL},; 
					{"D3_LOCAL"		, cTLocal           , NIL},; 
					{"D3_EMISSAO"	, dTData          	, NIL},;
					{"D3_X_QTD"		, nTQtd      		, NIL},;
					{"D3_QUANT"		, nTQtd      		, NIL},;
					{"D3_CUSTO1"	, nTCusto      		, NIL},;
					{"D3_X_OBS"    	, cTObs			    , NIL},;
					{"D3_CC"    	, cTCC			    , NIL},;
					{"D3_ITEMCTA"   , cTItemCta			, NIL},;
					{"D3_CLVL"    	, cTCLVL            , NIL},;		
					{"D3_FORNECE"   , cFornece			, NIL},;
					{"D3_NOMEFOR"   , Posicione('SA2', 1, xFilial('SA2')+cFornece, 'A2_NOME')			, NIL}}
					// Inclui D3_OBSERVA - SE FOR MOR MOVIMENTAùùO PREENCHER COM NUMERO DA NF, SERIE E DATA DE EMISSAO
//	Endif
	                                   	
	// Gerar Movimento Interno 
	If (cTipo == "E") // Entrada				
		MSExecAuto({|x,y| mata240(x,y)}, aMovimento,3)

	ElseIf cTipo == "X" // Exclusùo
		MSExecAuto({|x,y| mata240(x,y)}, aMovimento, 5)				
		
	EndIf

	If lMsErroAuto
		MostraErro()
	Endif
		
Return !lMsErroAuto

User Function ConvType(xValor,nTam,nDec)

Local cNovo := ""
DEFAULT nDec := 0
Do Case
	Case ValType(xValor)=="N"
		If xValor <> 0
			cNovo := AllTrim(Str(xValor,nTam,nDec))	
		Else
			cNovo := "0"
		EndIf
	Case ValType(xValor)=="D"
		cNovo := FsDateConv(xValor,"YYYYMMDD")
		cNovo := SubStr(cNovo,1,4)+"-"+SubStr(cNovo,5,2)+"-"+SubStr(cNovo,7)
	Case ValType(xValor)=="C"
		If nTam==Nil
			xValor := AllTrim(xValor)
		EndIf
		DEFAULT nTam := 60
		cNovo := AllTrim(EnCodeUtf8(NoAcento(SubStr(xValor,1,nTam))))
EndCase
Return(cNovo)
