#Include 'Protheus.ch'
#Include 'rwmake.CH' 
#Include 'topconn.ch'   

User Function VACOMA03()

Local aAreaSC7 		:= GetArea()
Local cAlias 		:= 'SC7'
Local cTpAlias 		:= 1
Local cPedCom	
Local nC7Recno		:= SC7->(Recno())
Local nC71Recno		:= SC7->(Recno())
Local cPCliente
Local cPedProd
Local cC7Fornece 	:= SC7->C7_FORNECE
Local cC7Loja   	:= SC7->C7_LOJA
Private oDlgCOMIS
Private cCliCod		:= '000002'
Private cCliLoj     := '01'
Private cCliNom		:= 'AGROPECUARIA VISTA ALEGRE LTDA'
Private nComiss   	:= 0
Private dDtCom		:= DDATABASE
Private cVenCod		:= SC7->C7_X_CORRE
Private cVenNom		:= Posicione('SA3',1,xfilial('SA3')+cVenCod,'A3_NOME')
Private cC7NUM		:= SC7->C7_NUM
Private nPCTotal	:= 0

dbSelectArea('SA2')  
dbSetOrder(1)
dbseek(xFilial('SA2') + SC7->C7_FORNECE + SC7->C7_LOJA )

dbSelectArea("SC7")
dbSetOrder(1)
If Dbseek (xFilial('SC7')+cC7NUM)
	nC71Recno		:= SC7->(Recno())
	cVenCod		 	:= SC7->C7_X_CORRE

	Do While !SC7->(EOF()) .AND. cC7NUM = SC7->C7_NUM 
		nPCTotal		+= SC7->C7_TOTAL  
		nComiss			+= SC7->C7_X_COMIS  
		SC7->(dbSkip())
	Enddo					
	SC7->(dbGoTo(nC71Recno))

	If  nPCTotal>0 
 
		If MsgYesNo("O Pedido de Compras possui campo de Comissao para Corretor!" + chr(13) +;
	        				 "Deseja gerar Comissao?" + chr(13)+ chr(13)+;
	        				 "Sim = Gera Comissao " + chr(13) +;
	        				 "Não = Encerra sem Gerar Comissao ")

			
			cCliCod		:= SC7->C7_FORNECE 
			cCliLoj		:= SC7->C7_LOJA   
			cCliNom		:= Posicione('SA2',1,xfilial('SA2')+cCliCod+cCliLoj,'A2_NOME')
			nComiss		:= 0  
			cVenCod		:= SC7->C7_X_CORRE
			cVenNome	:= Posicione('SA3',1,xfilial('SA3')+cVenCod,'A3_NOME')
	      	cPedCom  	:= SC7->C7_NUM + '/' + SC7->C7_ITEM 
	      	cPCliente	:= SC7->C7_FORNECE  + '-'+ SC7->C7_LOJA
			cPedProd	:= alltrim(SC7->C7_PRODUTO+'-'+SC7->C7_DESCRI) 
			nPCTotal	:= 0

			Do While !SC7->(EOF()) .AND. cC7NUM = SC7->C7_NUM 
					nPCTotal		+= SC7->C7_TOTAL  
					nComiss			+= SC7->C7_X_COMIS  
				SC7->(dbSkip())
			Enddo					
			SC7->(dbGoTo(nC71Recno))
					
			DEFINE MSDIALOG oDlgComis FROM 05,10 TO 35,105 TITLE "Gera Comissao Corretor"
			@ 002,002 TO 220,370 TITLE "Dados de Comissao do Pedido de Compras " + cC7NUM //+' - Item '+SC7->C7_ITEM+" "  //265
				
			@ 001,001 SAY "Fornecedor" 		SIZE 070,001 OF oDlgComis
			@ 001,007 MSGET oCliCod VAR cPCliente PICTURE "@!" When .f. OF oDlgComis

			@ 002,001 SAY "R.Social" 		SIZE 070,001 OF oDlgComis
			@ 002,007 MSGET oCliNom VAR cCliNom PICTURE "@!" When .f.  OF oDlgComis
				
			@ 003,001 SAY "Responsavel" 	SIZE 070,001 OF oDlgComis
			@ 003,007 MSGET oVenCod VAR cVenCod F3 "SA3"  PICTURE "@!"  when .t. OF oDlgComis

			@ 004,001 SAY "Nome" 			SIZE 070,001 OF oDlgComis
			@ 004,007 MSGET oVenNom VAR cVenNome PICTURE "@!"  When .F. OF oDlgComis
				
			@ 005,001 SAY "Comissao em R$" 	SIZE 070,001 OF oDlgComis
			@ 005,007 MSGET oComiss VAR nComiss PICTURE "@E 99,999,999,999.99"  When .t. OF oDlgComis
				
			@ 006,001 SAY "Data Comissao" SIZE 70,1 OF oDlgComis
			@ 006,007 MSGET oDtCom VAR dDtCom  When .t. OF oDlgComis

			//	@ 004,007 MSGET oEMAIL VAR cXEMAIL PICTURE "@!"  When IIF(Inclui,.t.,.f.) OF oDlgComis
			//	@ 004,007 MSGET oEMAIL VAR cXEMAIL PICTURE "@!"  When IIF(Inclui,.t.,.f.) OF oDlgComis
				
			@ 007,001 SAY "Pedido " SIZE 70,1 OF oDlgComis
			@ 007,007 MSGET oPedCom VAR cPedCom PICTURE "@!" when .F. OF oDlgComis
				
//				@ 008,001 SAY "Produto " SIZE 70,1 OF oDlgComis
//				@ 008,007 MSGET oPedProd VAR cPedProd PICTURE "@!" When .F. OF oDlgComis
				
			@ 008,001 SAY "Valor Total Pedido" SIZE 70,1 OF oDlgComis
			@ 008,007 MSGET oPedVTot	VAR nPCTotal PICTURE "@E 99,999,999,999.99" When .F. OF oDlgComis
			//@ 006,021 SAY "Segurada   " SIZE 70,1 OF oDlgComis
			//@ 006,027 COMBOBOX cXSegur ITEMS aItems When IIF(Inclui,.t.,.f.) OF oDlgComis

				
			@ 009,001 SAY "Observacoes" SIZE 70,1 OF oDlgComis
			@ 009,007 GET oPedObs VAR SC7->C7_OBS MEMO When .f. Size 200,070 
			//@ 007,021 SAY "Data NF Produtor" SIZE 70,1 OF oDlgComis
			//@ 007,027 MSGET oDNFPF VAR cXDNFPF PICTURE "@D" When IIF(Inclui,.t.,.f.) OF oDlgComis
				
//				@ 008,001 SAY "Tipo Devolução" SIZE 70,1 OF oDlgComis
//				@ 008,007 MSGET oTPDEV VAR cXTPDEV F3 'ZL' PICTURE "@!" When IIF(Inclui,.t.,.f.) OF oDlgComis
				
//				@ 009,001 SAY "Mensagem na NF " SIZE 70,1 OF oDlgComis
//				@ 009,007 Get oMens var cXMens MEMO When IIF(Inclui,.t.,.f.) Size 200,070
				
			@ 200,125 BUTTON "&OK" 		Size 40,14 action (IIF(GRV235CM(cVenCod,nComiss,cC7NUM),oDlgComis:End(),)) 	Object btnOK 
			@ 200,170 BUTTON "&Cancela" Size 40,14 action oDlgComis:End() 										Object btnCancela
			@ 200,215 BUTTON "&Sair" 	Size 40,14 action oDlgComis:End() 										Object btnSair			
		
			ACTIVATE MSDIALOG oDlgComis CENTERED
	    Endif // If MsgYesNo
	    
	Endif	//!EMPTY(SC7->C7_X_CLIENT)

Endif				

SC7->(dbGoTo(nC7Recno))

RestArea(aAreaSC7)

Return  



// Gravar Dados apos confirmacao da comissao na eliminacao de residuos
Static Function GRV235CM(xcVenCod,xnComiss,xcC7NUM)
//gravar dados na sc7
Local aAreaCOM	:= GetArea()
Local aAutCom 	:= {}
Local lGravaE3	:= .T.   
Local lSubstE3 	:= .F.



dbSelectArea("SC7")
dbSetOrder(1)
If Dbseek (xFilial('SC7')+xcC7NUM)
	dbSelectArea("SE3")
	dbSetOrder(1) //E3_FILIAL+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_SEQ+E3_VEND                                                                                                           
	If Dbseek (xFilial('SE3')+'PC '+SC7->C7_NUM+SUBSTR(SC7->C7_ITEM,2,3)+space(TAMSX3("E3_PARCELA")[1])+SUBSTR(SC7->C7_ITEM,3,2)+xcVenCod,.T.) 
		If MsgYesNo("Ja Existe um Registro de Comissao para este pedido!!! Deseja susbtitui-lo?")
			lGravaE3	:= .T.
			lSubstE3	:= .T.
		Else
			lGravaE3	:= .F.	
		Endif
	Endif

    If lGravaE3
		
		RecLock("SC7",.F.)
			SC7->C7_X_COMIS   	:= xnComiss
			//SC7->C7_X_VEND 		:= xcVenCod
		SC7->(MsUnLock())
	
		If lSubstE3
			RecLock("SE3",.F.)
				dbDelete()
			SE3->(MsUnLock())
		Endif	             
		
		//Gerando Comissao
		aAdd(aAutCom,{"E3_VEND"		,SC7->C7_X_CORRE	,Nil})
		aAdd(aAutCom,{"E3_NUM"		,SC7->C7_NUM+SUBSTR(SC7->C7_ITEM,2,3),Nil})
		aAdd(aAutCom,{"E3_EMISSAO"	,dDtCom			,Nil})
		aAdd(aAutCom,{"E3_SERIE"	,'COM'			,Nil})
		aAdd(aAutCom,{"E3_CODCLI"	,'000002'		,Nil})
		aAdd(aAutCom,{"E3_LOJA"		,'01'			,Nil})
		aAdd(aAutCom,{"E3_BASE"		,xnComiss		,Nil})    // foi feito desta forma para nao gerar problemas de arredondamento no calculo da porcentagem  (valor base sera a comissao e % sera 100%)
		aAdd(aAutCom,{"E3_PORC"		,100			,Nil})    // foi feito desta forma para nao gerar problemas de arredondamento no calculo da porcentagem
		aAdd(aAutCom,{"E3_PREFIXO"	,'PC '			,Nil})
		aAdd(aAutCom,{"E3_PARCELA"	,"   "	 		,Nil})
		aAdd(aAutCom,{"E3_TIPO"		,"DH"			,Nil})
		aAdd(aAutCom,{"E3_PEDIDO"	,SC7->C7_NUM	,Nil})
		aAdd(aAutCom,{"E3_VENCTO"	,DDATABASE+30	,Nil}) // tratar a data de vencimento
		aAdd(aAutCom,{"E3_BAIEMI"	,'E'			,Nil}) 
		aAdd(aAutCom,{"E3_ORIGEM"	,'C'			,Nil}) 
		aAdd(aAutCom,{"E3_SEQ"		,SUBSTR(SC7->C7_ITEM,3,2),Nil}) 
		Mata490(aAutCom,3)				
		
		SC7->(dbSkip())	
		Do While !SC7->(EOF()) .AND. xcC7NUM = SC7->C7_NUM 
			RecLock("SC7",.F.)
				SC7->C7_X_COMIS   	:= 0
				SC7->C7_X_CORRE 	:= xcVenCod
			SC7->(MsUnLock())
			SC7->(dbSkip())
		Enddo		
	Endif  //lGravaE3		
Endif //Dbseek (xFilial('SC7')+xcC7NUM)

RestArea(aAreaCOM)

Return .T.


                          
