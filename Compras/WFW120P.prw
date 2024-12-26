/*
NAO COMPILAR - ATE ANALISARMOS MELHOR

fonte descompilado no dia 25.01.2022
apos atualizacao para a release 12.33

a todos respondeu que estava gerando um problema de travar o processo do pedido de compra;
*/

/*
	Workflow em um processo de Libera��o de Pedido de Compras
*/
#include "Totvs.ch"        // incluido pelo assistente de conversao do AP5 IDE em 20/03/00


// User Function MT160WF(nOpcao, oProcess)  
//   Local aArea    := GetArea()
//   Local aAreaSC1 := SC1->(GetArea())
//   Local aAreaSC7 := SC7->(GetArea())
//   Local aAreaSC8 := SC8->(GetArea())
//   Local cQuery   := ""
// 
//   cQuery := " SELECT "
//   cQuery += "   C8_NUMSC , C8_ITEMSC , C8_NUMPED , C8_ITEMPED , C8_PRAZO,"
//   cQuery += "   C1_DESCRI "
//   cQuery += " FROM "
//   cQuery += "   "+ SC8->(RETSQLNAME("SC8")) +" C8 "
//   cQuery += "   INNER JOIN "+ SC1->(RETSQLNAME("SC1")) +" C1 ON "
//   cQuery += "     C1_FILIAL ='"+ SC1->(xFILIAL("SC1")) +"' AND C1_NUM = C8_NUMSC"
//   cQuery += "     AND C1_ITEM = C8_ITEMSC AND C1.D_E_L_E_T_ = ' '"
//   cQuery += " WHERE "
//   cQuery += "   C8_FILIAL = '"+ SC8->(xFILIAL("SC8")) +"' AND C8_NUM ='"+ PARAMIXB[1] +"'"
//   cQuery += "   AND C8_NUMPED <> 'XXXXXX' AND C8_ITEMPED <> 'XXXX'"
//   cQuery += "   AND C8.D_E_L_E_T_ = ' '"
//   TcQuery cQuery Alias TSC8 New
//   TSC8->(dbGoTop())
// 
//   While !(TSC8->(EOF()))
//   
//     SC7->(dbSetOrder(1))
//     SC7->(dbSeek(xFilial("SC7")+TSC8->C8_NUMPED+TSC8->C8_ITEMPED))
//     If SC7->(Found())
//       SC7->(RecLock("SC7",.F.))
//       SC7->C7_DESCRI  := alltrim(C1_DESCRI)
//       SC7->C7_DATPRF  := dDataBase + TSC8->C8_PRAZO  
//       SC7->(MsUnLock())
//     Endif
//     TSC8->(dbSkip())
//   Enddo
//   TSC8->(dbCloseArea())
//     
//   RestArea(aAreaSC8)
//   RestArea(aAreaSC7)
//   RestArea(aAreaSC1)
//   RestArea(aArea)
//   EnvEmail(nOpcao, oProcess)
// Return



User Function WFW120P( nOpcao, oProcess )

	Local aAreaWf	:= GetArea()
	Local cSql		:= ""
	Local nTotal	:= 0    
	Local cPedido   := ''                 
	Local nQAprov   := 0
	Local lRet      := .T. //.F. 
	Local cObs      := ''
	Private cNAtiv 	:= space(3)
	// Private CChvPC	:= SC7->(C7_FILIAL + C7_NUM)

	dbSelectArea("SC7")
	dbSetOrder(1)      
    cObs:=AllTrim(SC7->C7_OBS)                                      

	dbSelectArea("SC7")
	dbSetOrder(1)
	If dbSeek(SC7->(C7_FILIAL + C7_NUM))                
		cChave := SC7->(C7_FILIAL + C7_NUM)
		While !Eof() .and. SC7->(C7_FILIAL + C7_NUM) == cChave
			nTotal += SC7->C7_TOTAL  // alterado por Henrique em 16/04/2010 - para tratar aprovacao com total de despesas+frete+seguro - descontos no valor total do sz7
			//nTotal += SC7->C7_TOTAL + SC7->C7_VALIPI + SC7->C7_SEGURO + SC7->C7_DESPESA + SC7->C7_VALFRE - SC7->C7_VLDESC
		dbSelectArea("SC7")
		dbSkip()
		End	
	Endif	

/*
	RestArea(aAreaWf)
	dbSelectArea("SZ7")
	dbSetOrder(1)
	If dbSeek(xFilial("SZ7") + SC7->C7_NUM)
		If SZ7->Z7_STATUS == "L" .and. SZ7->Z7_TOTAL == nTotal
			cSql := "UPDATE " + RetSqlName("SC7") + " "
			cSql += "SET C7_CONAPRO = 'L'  "
			cSql += "WHERE C7_FILIAL = '" + SC7->C7_FILIAL + "' "
			cSql += "AND C7_NUM = '" + SC7->C7_NUM + "' "
			cSql += "AND D_E_L_E_T_ = ' ' "
			MemoWrite("c:\c7IF.txt",cSql)
			TcSqlExec(cSql)
                                           
			cSql := "UPDATE " + RetSqlName("SCR") + " "
			cSql += "SET CR_STATUS = '03', "
			cSql += "CR_DATALIB = '" + dtos(SZ7->Z7_DATALIB) + "', "
			cSql += "CR_OBS = '" + SZ7->Z7_OBS + "', "
			cSql += "CR_USERLIB = '" + SZ7->Z7_USERLIB + "', "
			cSql += "CR_LIBAPRO = '" + SZ7->Z7_LIBAPRO + "', "
			cSql += "CR_VALLIB = " + Str(SZ7->Z7_VALLIB) + ", "
			cSql += "CR_TIPOLIM = '" + SZ7->Z7_TIPOLIM + "' "
			cSql += "WHERE CR_FILIAL = '" + SZ7->Z7_FILIAL + "' "
			cSql += "AND CR_NUM = '" + SZ7->Z7_NUM + "' "
			cSql += "AND D_E_L_E_T_ = ' ' "
			//MemoWrite("c:\cr.txt",cSql)
			TcSqlExec(cSql)
			Return	
		else       
		    if lRet
			                                  
//			   Alert('Observacao: '+cObs)
	     		cSql := "UPDATE " + RetSqlName("SCR") + " "
				cSql += "SET CR_OBS = '"+cObs+"'"
				cSql += "WHERE CR_FILIAL = '" + SZ7->Z7_FILIAL + "' "
				cSql += "AND CR_NUM = '" + SZ7->Z7_NUM + "' "
				cSql += "AND D_E_L_E_T_ = ' ' "
//				MemoWrite("f:\crObs.txt",cSql)
				TcSqlExec(cSql)		
			endif
		Endif
	Endif     
*/
	
	RestArea(aAreaWf)
	EnvEmail(nOpcao, oProcess)
Return


Static function EnvEmail( nOpcao, oProcess )

    // Alert("enviou email")
    
    If ValType(nOpcao) = "A" 
      nOpcao := nOpcao[1]
    Endif  
                                 
	If nOpcao == NIL
		nOpcao := 0
	End

    ConOut("Opcao:")
    ConOut(nOpcao)
    
	If oProcess == NIL
		oProcess := TWFProcess():New( "PEDCOM", "Pedido de Compras" )
	End

	//����������������������������������������������������������������������?
	//?Declaracao de variaveis utilizadas no programa atraves da funcao    ?
	//?SetPrvt, que criara somente as variaveis definidas pelo usuario,    ?
	//?identificando as variaveis publicas do sistema utilizadas no codigo ?
	//?Incluido pelo assistente de conversao do AP5 IDE                    ?
	//����������������������������������������������������������������������?

	SetPrvt("CPAR,NBARRA,N_ITEM,C_MAT,C_DEST,CGRAP")
	SetPrvt("C_NUM,C_MOTIVO,N_TOTPC,CGRAPANT,N_TERMINA,N_DOHTML")
	SetPrvt("CRAIZ,NRET,NHLDHTM,NHLDSCP,CIND,C_PCANT")
	SetPrvt("N_QTDPC,N_FRTPC,A_ITENS,LCABEC,_AREGISTROS,NLIMITE")
	SetPrvt("CAB_NUM,CAB_EMIS,CAB_FORN,CAB_COND,CAB_NOME,_NI")
	SetPrvt("ARRAYCAB,ARRAYITENS,C_ITPED,NPRESUP,CAPROV,AINFO")
	SetPrvt("CMAILAP,CNOMEAP,CORIGEM,CABEC,NHDLVLR,NCOUNT")
	SetPrvt("NRESULT,CHTML,NHDLCONNECT")

	Do Case
		Case nOpcao == 0
			U_SPCIniciar( oProcess )
		Case nOpcao == 1
			U_SPCRetorno( oProcess )
		Case nOpcao == 2
			U_SPCTimeOut( oProcess )
	
	End
//OProcess:Free()	
RETURN


/*Faz a Libera��o Autom?ica do Pedido*/
User Function SPCRetorno( oProcess )
  Local aArea
  Local cCrChave
  ConOut('Executando Retorno')      

  
  if oProcess:oHtml:RetByName('OPC') <> 'S' 
    ConOut('Pedido nao Aprovado')
    //U_SPCNotificar(oProcess:oHtml:RetByName('OPC'),oProcess:oHtml:RetByName('C7_NUM'))
    DBSelectarea("SCR")                   // Posiciona a Liberacao
    DBSetorder(2)
    If DBSeek(xFilial("SCR")+"PC"+oProcess:oHtml:RetByName('C7_NUM'))    
    ConOut("Bloqueio-"+ xFilial("SCR")+"PC"+oProcess:oHtml:RetByName('C7_NUM'))
      RecLock("SCR",.f.)
      SCR->CR_DataLib := dDataBase
      SCR->CR_Obs     := ""
      SCR->CR_STATUS  := "04"  //Bloqueado
      SCR->CR_OBS := oProcess:oHtml:RetByName('OBS')
      MsUnLock()
    endif            

    //grava obs no pedido
   dbselectarea("SC7")
	DBSETORDER(1)
  	DBSeek(xFilial("SC7")+oProcess:oHtml:RetByName('C7_NUM'))      // Posiciona o Pedido
  	while !EOF() .and. SC7->C7_Num == oProcess:oHtml:RetByName('C7_NUM')
     RecLock("SC7",.f.)
//	     SC7->C7_X_MOT 	:= oProcess:oHtml:RetByName('OBS')
     MsUnLock()
     DBSkip()
  	enddo
   U_SPCNotificar(oProcess:oHtml:RetByName('OPC'),oProcess:oHtml:RetByName('C7_NUM'))  
   return .t.             

  endif  
  
  ConOut('Pedido No:'+oProcess:oHtml:RetByName('C7_NUM'))   
  //Acerto o pedido
  dbSelectArea("SCR")                   // Posiciona a Liberacao
  dbSetOrder(2)
  conout("pedido->" + xFilial("SCR")+"PC"+oProcess:oHtml:RetByName('C7_NUM'))
  If dbSeek(xFilial("SCR")+"PC"+oProcess:oHtml:RetByName('C7_NUM'))    
  
		// antes de liberar tem de verificar se o usuario ?o inferior
		// se for marco o OK dele na OBS e mando a aprova��o p/ o aprovador de fato
		// e n? libero ainda o pedido.
		//No WorkFlow devo tratar no retorno se o aprovador do pedido nao tem o limite
		//transferi-lo p/ o superior
		//MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,,cAprovS,,,,,,,cObs},dRefer,2)
		//e enviar o email p/ o superior
		//Salvo a Area Anterior
      aArea := GetArea()     
      //Guardo a chave da SCR
      cCrChave := SCR->(CR_FILIAL + CR_TIPO + CR_NUM)
      //Busco o Cod de usuario do aprovador deste pedido
      dbSelectArea("SC7")
      dbSetOrder(1)
      dbSeek(xFilial("SC7") + AllTrim(SCR->CR_NUM))
      ConOut("CHAVE " + cCrChave)
      
      //Posiciono na chave deste aprovador na SCR (pode outras) // nao utilizo mais o C7_X_UAPRO
      /*
      dbSelectArea("SCR")
      dbSetOrder(2)
      dbSeek(cCrChave + SC7->C7_X_UAPRO)
      ConOut("CHAVE2 " + cCrChave + SC7->C7_X_UAPRO)
      */
      //Posiciono no Cadastro de aprovador p/ verificar os limites
      dbSelectArea("SAK")
      dbSetOrder(1)
      If dbSeek(xFilial("SAK") + SCR->CR_APROV)
      	ConOut("Achou Aprovador " + Str(SAK->AK_LIMITE) )
      	If SCR->CR_TOTAL > SAK->AK_LIMITE //trata-se apenas do OK do aprovador inferior p/ o superior
				//Transfere o Aprovador
				ConOut("vai Transferir ")
				MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,,SAK->AK_APROSUP,,,,,,,"OK->"+SAK->AK_NOME},ddatabase,2)
				
				
				//Guardo o nome do aprovador anterior
				cNomApro := AllTrim(SAK->AK_NOME)
				//Posiciono no novo aprovador
				dbSelectArea("SAK")
				dbSetOrder(1)
				dbSeek(xFilial("SAK") + SAK->AK_APROSUP)
				
				//grupo de aprovadores
				dbSelectArea("SAL")
				dbGotop()
				While !Eof()
					If SAK->AK_USER == SAL->AL_USER
						cGrupo := SAL->AL_COD
					Endif
				dbSkip()
				End				
				
				//Altera��o no pedido e novo envio  
				cSql	:= "UPDATE " + RetSqlName("SC7") + " "
				cSql	+= "SET C7_OBS = 'OK->" + AllTrim(cNomApro) + "' || ', ' || TRIM(C7_OBS), "
				cSql	+= "C7_APROV = '" + cGrupo + "' "
				cSql	+= "WHERE C7_FILIAL = '" + cFilAnt + "' "
				cSql	+= "AND C7_NUM = '" + AllTrim(SCR->CR_NUM) + "' "
				cSql	+= "AND D_E_L_E_T_ = ' ' "				
				TcSqlExec(cSql)
				Conout("update sc7 "+cSql)
				// Gravar na Obs
				cSql	:= "UPDATE " + RetSqlName("SCR") + " "
				cSql	+= "SET CR_OBS = 'OK->" + cNomApro + "' "
				cSql	+= "WHERE CR_TIPO = 'PC' "
				cSql	+= "AND CR_NUM = '" + SCR->CR_NUM + "' "
				cSql	+= "AND D_E_L_E_T_ = ' ' "
				TcSqlExec(cSql)
				Conout("update scr "+cSql)
				//Enviar WorkFlow p/ o superior
				//EnvEmail(nOpcao, oProcess)
				Conout("vai enviar o email" + SCR->CR_NUM)
				If ExistBlock("MT160WF")
					ExecBlock("MT160WF",.f.,.f.,xFilial("SC7")+AllTrim(SCR->CR_NUM))
				EndIf
				Return(.t.)
      	Endif
      Endif
     
   RestArea(aArea)
 
  	While !eof() .and.xFilial("SCR")+"PC"+oProcess:oHtml:RetByName('C7_NUM') == SCR->(CR_FILIAL + CR_TIPO + AllTrim(CR_NUM))
	    conout("encontrou->" + xFilial("SCR")+"PC"+oProcess:oHtml:RetByName('C7_NUM'))
	    RecLock("SCR",.f.)
	    SCR->CR_DataLib := dDataBase
	    SCR->CR_Obs     := ""
	    SCR->CR_STATUS  := "03"
	    MsUnLock()
   dbSkip()
   End
  
  endif  
  conout(SCR->(CR_FILIAL + CR_TIPO + CR_NUM))
  dbselectarea("SC7")
  DBSETORDER(1)
  DBSeek(xFilial("SC7")+oProcess:oHtml:RetByName('C7_NUM'))      // Posiciona o Pedido
  while !EOF() .and. SC7->C7_Num == oProcess:oHtml:RetByName('C7_NUM')
     RecLock("SC7",.f.)
	     SC7->C7_ConaPro := "L"
//	     SC7->C7_X_MOT 	:= oProcess:oHtml:RetByName('OBS')
     MsUnLock()
     DBSkip()
  enddo
  ConOut("Aprovando o Pedido")

  U_SPCNotificar(oProcess:oHtml:RetByName('OPC'),oProcess:oHtml:RetByName('C7_NUM'))  
	
Return              


// Inicia o Processo de Aprovacao do Pedido de Compras via email
// envia o html de aprovacao
User Function SPCIniciar( oProcess )
Local aCond:={},nTotal:=0, cMailID, cCMailID, cSubject
Local nFrete  := 0 
Local nImp    := 0
Local cUApro  := ""
Local cObs	  := ""
Local RecnoSC7 := SC7->(Recno())

	DbSelectArea('SC7')
	dbSetOrder(1)
	
	//If dbseek(CChvPC)
	If dbseek(SC7->(C7_FILIAL + C7_NUM))
		RecnoSC7 := SC7->(Recno())
	Endif
	
	// Na Primeira Chamada
	// Monta E-mail apenas para Aprovador (na sequencia ?enviado email com copia sem a opcao de resposta) 
	//Abre o HTML criado. Repare que o mesmo se encontra abaixo do RootPath
	//oProcess:NewTask( "Aprova��o", "\WORKFLOW\html\WFW120P3.HTM" )
	oProcess:cSubject := "Aprovacao de Pedido de Compra *** No " + SC7->C7_NUM + " ***" 
	oProcess:bReturn := "U_WFW120P( 1 )"
	oProcess:bTimeOut := {{"U_WFW120P(2)",30, 0, 5 }}
	oHTML := oProcess:oHTML
	
	If TYPE("OHTML")=="U"
	   Return nil
	EndIf
	                                        
	cSubject := "APROVACAO DO PEDIDO  *** No " + SC7->C7_NUM + " ***" 

	oHtml:ValByName( "C7_NUM", SC7->C7_NUM )
		
	/*** Preenche os dados do cabecalho ***/
	oHtml:ValByName( "C7_EMISSAO", SC7->C7_EMISSAO )
   
	dbSelectArea('SA2')
	dbSetOrder(1)
	dbSeek(xFilial('SA2')+SC7->C7_FORNECE)
	oHtml:ValByName( "FORNECEDOR", SC7->C7_FORNECE +" / "+SA2->A2_NOME) 

    //Pego as condicoes de Pagamento
    dbSelectArea('SE4')
    DBSETORDER(1)
    dbSeek(xFilial('SE4') + SC7->C7_COND)
	oHtml:ValByName( "E4_DESCRI", SC7->C7_COND +" / "+SE4->E4_DESCRI)

	dbSelectarea("SY1")
	dbSetOrder(3)
	if dbSeek(xFilial("SY1") + SC7->C7_USER) //comprador
		oHtml:ValByName( "Y1_NOME",  SY1->Y1_NOME)
		oHtml:ValByName( "Y1_TEL",   SY1->Y1_TEL)
		oHtml:ValByName( "Y1_EMAIL", SY1->Y1_EMAIL)
    else
		oHtml:ValByName( "Y1_NOME",  "")
		oHtml:ValByName( "Y1_TEL",   "")
		oHtml:ValByName( "Y1_EMAIL", "")    
    endif
    
    dbSelectArea('SB1')
    dbSetOrder(1)

    dbSelectArea('SC1')
    dbSetOrder(1) // C1_FILIAL + C1_NUM + C1_ITEM

	dbSelectArea('SC7')
    cNum := SC7->C7_NUM
	oProcess:fDesc := "Pedido de Compras No "+ cNum
    dbSetOrder(1)
    dbSeek(xFilial('SC7')+cNum)
    While !Eof() .and. C7_NUM = cNum
       nTotal  := (nTotal + C7_TOTAL - C7_VLDESC)
       nFrete  := nFrete + C7_VLDESC // frete nao desconto!
       nImp    := nFrete +  (C7_VALIPI + C7_VALICM)
       AAdd( (oHtml:ValByName( "t1.1" )),C7_ITEM )		
       AAdd( (oHtml:ValByName( "t1.2" )),C7_PRODUTO )		       
       dbSelectArea('SB1')
//       dbSetOrder(1)   
       dbSeek(xFilial('SB1')+SC7->C7_PRODUTO)
       dbSelectArea('SC1')
       dbSeek(xFilial('SC1')+SC7->C7_NUMSC+SC7->C7_ITEMSC)
       dbSelectArea('SC7')
//     AAdd( (oHtml:ValByName( "t1.3" )),SB1->B1_DESC )		              
       AAdd( (oHtml:ValByName( "t1.3" )),AllTrim(SB1->B1_DESC) )		              
       AAdd( (oHtml:ValByName( "t1.4" )),SB1->B1_UM )		              
       AAdd( (oHtml:ValByName( "t1.5" )),TRANSFORM( C7_QUANT,PesqPict("SC7","C7_QUANT") ) )		              
       AAdd( (oHtml:ValByName( "t1.6" )),TRANSFORM( C7_PRECO,PesqPict("SC7","C7_PRECO") ) )		                     
       AAdd( (oHtml:ValByName( "t1.7" )),TRANSFORM( C7_VLDESC,PesqPict("SC7","C7_VLDESC") ) )		                     
       AAdd( (oHtml:ValByName( "t1.8" )),TRANSFORM( (C7_TOTAL-C7_VLDESC),PesqPict("SC7","C7_TOTAL") ) )		                     
       AAdd( (oHtml:ValByName( "t1.9" )),DTOC(SC7->C7_DATPRF) )
       AAdd( (oHtml:ValByName( "t1.10" )),TRANSFORM( C7_X_LIMUM,PesqPict("SC7","C7_X_LIMUM") ) ) 
       AAdd( (oHtml:ValByName( "t1.11" )),TRANSFORM( C7_X_LIMIM,PesqPict("SC7","C7_X_LIMIM") ) ) 
//       AAdd( (oHtml:ValByName( "t1.10" )),'' )

       WFSalvaID('SC7','C7_WFID',oProcess:fProcessID)

       cNum := SC7->C7_NUM // guardo o codigo do usuario aprovador

       cObs += Alltrim(SC7->C7_OBS) + "/"
       dbSkip()
    Enddo

	AAdd( (oHtml:ValByName("t2.1" )),TRANSFORM( nTotal,	PesqPict("SC7","C7_TOTAL") ))
	AAdd( (oHtml:ValByName("t2.2" )),TRANSFORM( nFrete,	PesqPict("SC7","C7_TOTAL") ))		              	    
	AAdd( (oHtml:ValByName("t2.3" )),TRANSFORM( nImp,	PesqPict("SC7","C7_TOTAL") ))	              	    

	AAdd( (oHtml:ValByName("t3.1")) ,cObs)
   
    DBSelectarea("SCR")                   // Posiciona a Liberacao
    DBSetorder(2)
    If DBSeek(xFilial("SCR")+"PC"+cNum)
		// Faz o envio para o aprovador primeiro --> oProcess:cTo := UsrRetMail(SCR->CR_USER)
    	oProcess:ClientName( Subs(cUsuario,7,15))
		oProcess:cTo      := 'TOTVS'//_cEmlFor
		// aaaa
		oProcess:cTo := UsrRetMail(SCR->CR_USER) //"fernandoalfini@grupotoledo.com.br"  //Coloque aqui o destinatario do Email, aprovador
		oProcess:Start()            
		cMailID := oProcess:Start()
    	ConOut("Rastreando:"+oProcess:fProcCode)

 		oProcess:newtask('Link_Aprova', '\workflow\html\linkaprovpc.htm')  //Inicio uma nova Task com um HTML Simples
	    oProcess:ohtml:valbyname('CR_USER'	, UsrFullName(SCR->CR_USER) )                
	    oProcess:ohtml:valbyname('proc_link_interno','http://192.168.0.243:8087/emp'  + cEmpAnt + '/TOTVS/' + cMailId + '.HTM' ) //Defino o Link onde foi gravado o HTML pelo Workflow,abaixo do diret?io do usu?io definido em cTo do processo acima.           
	    oProcess:ohtml:valbyname('proc_link_externo','http://189.50.138.50:8087/emp' + cEmpAnt + '/TOTVS/' + cMailId + '.HTM' ) //Defino o Link onde foi gravado o HTML pelo Workflow,abaixo do diret?io do usu?io definido em cTo do processo acima.           
	    oProcess:ohtml:valbyname('Y1_NOME'	, SY1->Y1_NOME)  
	    oProcess:ohtml:valbyname('Y1_FONE'	, SY1->Y1_TEL)  
	    oProcess:ohtml:valbyname('Y1_FAX'	, SY1->Y1_FAX)  
	    oProcess:ohtml:valbyname('Y1_EMAIL'	, SY1->Y1_EMAIL)  
		oProcess:cTo :=  UsrRetMail(SCR->CR_USER) //Coloque aqui o destinatario do Email, aprovador
 		oProcess:cCc := 'arthurtoshio@hotmail.com'// apenas para teste
		oProcess:AttachFile('\WORKFLOW\EMP' + cEmpAnt + '\TEMP\'+cMailID+'.HTM')  
//		oProcess:AttachFile('\Workflow\ecf_va_02.dat')// teste
//		oProcess:AttachFile('\Workflow\vafinr05.htm') // teste    
	 	oProcess:Start() 

 	Endif



	// Na Segunda Chamada (geracao novamente de outro email com outro html em copia
	// Monta E-mail apenas para Comprador(?enviado email com copia sem a opcao de resposta) 
	dbSelectArea("SC7")
	dbGoto(RecnoSC7)
	      
    //Abre o HTML criado. Repare que o mesmo se encontra abaixo do RootPath
	oProcess:NewTask( "Aprova��o", "\WORKFLOW\html\WFW120P3.HTM" )
	oProcess:cSubject := "Aprovacao de Pedido de Compra - Copia  *** " +SC7->C7_NUM + " ***" 
	oProcess:bReturn := "U_WFW120P( 1 )"
	oProcess:bTimeOut := {{"U_WFW120P(2)",30, 0, 5 }}
	oHTML := oProcess:oHTML
	
	If TYPE("OHTML")=="U"
	   Return nil
	EndIf
	                                        
	cSubject := "APROVACAO DO PEDIDO No " + SC7->C7_NUM

	oHtml:ValByName( "C7_NUM", SC7->C7_NUM )
		
	/*** Preenche os dados do cabecalho ***/
	oHtml:ValByName( "C7_EMISSAO", SC7->C7_EMISSAO )
   
	dbSelectArea('SA2')
	dbSetOrder(1)
	dbSeek(xFilial('SA2')+SC7->C7_FORNECE)
	oHtml:ValByName( "FORNECEDOR", SC7->C7_FORNECE +" / "+SA2->A2_NOME) 

    //Pego as condicoes de Pagamento
    dbSelectArea('SE4')
    DBSETORDER(1)
    dbSeek(xFilial('SE4') + SC7->C7_COND)
	oHtml:ValByName( "E4_DESCRI", SC7->C7_COND +" / "+SE4->E4_DESCRI)

	dbSelectarea("SY1")
	dbSetOrder(3)
	if dbSeek(xFilial("SY1") + SC7->C7_USER) //comprador
		oHtml:ValByName( "Y1_NOME",  SY1->Y1_NOME)
		oHtml:ValByName( "Y1_TEL",   SY1->Y1_TEL)
		oHtml:ValByName( "Y1_EMAIL", SY1->Y1_EMAIL)
    else
		oHtml:ValByName( "Y1_NOME",  "")
		oHtml:ValByName( "Y1_TEL",   "")
		oHtml:ValByName( "Y1_EMAIL", "")    
    endif
    
    dbSelectArea('SB1')
    dbSetOrder(1)

    dbSelectArea('SC1')
    dbSetOrder(1) // C1_FILIAL + C1_NUM + C1_ITEM

	dbSelectArea('SC7')
    cNum := SC7->C7_NUM
	oProcess:fDesc := "Pedido de Compras No "+ cNum
    dbSetOrder(1)
    dbSeek(xFilial('SC7')+cNum)
    While !Eof() .and. C7_NUM = cNum
       nTotal  := (nTotal + C7_TOTAL - C7_VLDESC)
       nFrete  := nFrete + C7_VLDESC // frete nao desconto!
       nImp    := nFrete +  (C7_VALIPI + C7_VALICM)
       AAdd( (oHtml:ValByName( "t1.1" )),C7_ITEM )		
       AAdd( (oHtml:ValByName( "t1.2" )),C7_PRODUTO )		       
       dbSelectArea('SB1')
//       dbSetOrder(1)   
       dbSeek(xFilial('SB1')+SC7->C7_PRODUTO)
       dbSelectArea('SC1')
       dbSeek(xFilial('SC1')+SC7->C7_NUMSC+SC7->C7_ITEMSC)
       dbSelectArea('SC7')
//     AAdd( (oHtml:ValByName( "t1.3" )),SB1->B1_DESC )		              
       AAdd( (oHtml:ValByName( "t1.3" )),AllTrim(SB1->B1_DESC)  )		              
       AAdd( (oHtml:ValByName( "t1.4" )),SB1->B1_UM )		              
       AAdd( (oHtml:ValByName( "t1.5" )),TRANSFORM( C7_QUANT,PesqPict("SC7","C7_QUANT") ) )		              
       AAdd( (oHtml:ValByName( "t1.6" )),TRANSFORM( C7_PRECO,PesqPict("SC7","C7_PRECO") ) )		                     
       AAdd( (oHtml:ValByName( "t1.7" )),TRANSFORM( C7_VLDESC,PesqPict("SC7","C7_VLDESC") ) )		                     
       AAdd( (oHtml:ValByName( "t1.8" )),TRANSFORM( (C7_TOTAL-C7_VLDESC),PesqPict("SC7","C7_TOTAL") ) )		                     
       AAdd( (oHtml:ValByName( "t1.9" )),DTOC(SC7->C7_DATPRF) )
//       AAdd( (oHtml:ValByName( "t1.10" )),C7_X_QApro )

       WFSalvaID('SC7','C7_WFID',oProcess:fProcessID)

       cNum := SC7->C7_NUM // guardo o codigo do usuario aprovador

       cObs += Alltrim(SC7->C7_OBS) + "/"
       dbSkip()
    Enddo

	AAdd( (oHtml:ValByName("t2.1" )),TRANSFORM( nTotal,PesqPict("SC7","C7_TOTAL") ))
	AAdd( (oHtml:ValByName("t2.2" )),TRANSFORM( nFrete,PesqPict("SC7","C7_TOTAL") ))		              	    
	AAdd( (oHtml:ValByName("t2.3" )),TRANSFORM( nImp,PesqPict("SC7","C7_TOTAL")))	              	    

	AAdd( (oHtml:ValByName("t3.1")) ,cObs)

    DBSelectarea("SCR")                   // Posiciona a Liberacao
    DBSetorder(2)
    If DBSeek(xFilial("SCR")+"PC"+cNum)
		// Faz o envio para o aprovador primeiro --> oProcess:cTo := UsrRetMail(SCR->CR_USER)
    	oProcess:ClientName( Subs(cUsuario,7,15))
		oProcess:cTo      := 'TOTVS'//_cEmlFor
		//oProcess:cTo := UsrRetMail(SCR->CR_USER) //"fernandoalfini@grupotoledo.com.br"  //Coloque aqui o destinatario do Email, aprovador
		//oProcess:Start()            
		cCMailID := oProcess:Start()
    	ConOut("Rastreando:"+oProcess:fProcCode)

 		oProcess:newtask('Link_Aprova', '\workflow\html\linkaprovpc.htm')  //Inicio uma nova Task com um HTML Simples
	    oProcess:ohtml:valbyname('CR_USER'	, UsrFullName(SCR->CR_USER) )                
	    oProcess:ohtml:valbyname('proc_link_interno','http://192.168.0.243:8087/emp' + cEmpAnt + '/TOTVS/' + cCMailId + '.HTM' ) //Defino o Link onde foi gravado o HTML pelo Workflow,abaixo do diret?io do usu?io definido em cTo do processo acima.           
	    oProcess:ohtml:valbyname('proc_link_externo','http://186.227.40.122:8087/emp' + cEmpAnt + '/TOTVS/' + cCMailId + '.HTM' ) //Defino o Link onde foi gravado o HTML pelo Workflow,abaixo do diret?io do usu?io definido em cTo do processo acima.           
	    oProcess:ohtml:valbyname('Y1_NOME'	, SY1->Y1_NOME)  
	    oProcess:ohtml:valbyname('Y1_FONE'	, SY1->Y1_TEL)  
	    oProcess:ohtml:valbyname('Y1_FAX'	, SY1->Y1_FAX)  
	    oProcess:ohtml:valbyname('Y1_EMAIL'	, SY1->Y1_EMAIL)  
		oProcess:cTo :=  SY1->Y1_EMAIL //Coloque aqui o destinatario do Email, Comprados (em copia)
		oProcess:AttachFile('\WORKFLOW\EMP' + cEmpAnt + '\TEMP\'+cCMailID+'.HTM')  
//		oProcess:AttachFile('\Workflow\ecf_va_02.dat')// teste
//		oProcess:AttachFile('\Workflow\vafinr05.htm') // teste    
	 	oProcess:Start() 

 	Endif

Return 

User Function SPCTimeOut( oProcess )
  ConOut("Funcao de TIMEOUT executada")
  oProcess:Finish()  //Finalizo o Processo
Return 

User Function SPCNotificar(cResultado, cNumPed)
Local aCond:={},nTotal := 0,cMailID,cSubject
Local nFrete  := 0 
Local nImp    := 0                
Local cUComp  := ""
Local cObs	  := ""                 
Local cMot	  := ""

ConOut("Inicio")

//Alert("envio ")

	DbSelectArea("SC7")
	DbSetOrder(1)
	DbSeek(xFilial("SC7")+cNumPed)
    //Abre o HTML criado. Repare que o mesmo se encontra abaixo do RootPath
	oProcess := TWFProcess():New( "PEDCOM", "Notificacao do Pedido de Compras" )
	oProcess:NewTask( "Aprova��o", "\WORKFLOW\HTML\WFW120P3.HTM" )
	oProcess:cSubject := "Aprovacao de Pedido de Compra  *** " + SC7->C7_NUM + " ***"
	oHTML := oProcess:oHTML
 		                                        
	ConOut("HTML ok")

	cSubject := "RESULTADO DE PROCESSO DE APROVACAO DO PEDIDO No " + SC7->C7_NUM
    
	If cResultado = 'S'
		oHtml:ValByName( "RESULTADO", "A P R O V A D O" )	
	Else
		oHtml:ValByName( "RESULTADO", "R E P R O V A D O" )		
	EndIf
	
	oHtml:ValByName( "C7_NUM", SC7->C7_NUM )
		
	/*** Preenche os dados do cabecalho ***/
	oHtml:ValByName( "C7_EMISSAO", SC7->C7_EMISSAO )
	
   
	dbSelectArea('SA2')
	dbSetOrder(1)
	dbSeek(xFilial('SA2')+SC7->C7_FORNECE+SC7->C7_LOJA)
	oHtml:ValByName( "FORNECEDOR", SC7->C7_FORNECE +" / "+SA2->A2_NOME) 

   //Pego as condicoes de Pagamento
   dbSelectArea('SE4')
   DBSETORDER(1)
   dbSeek(xFilial('SE4') + SC7->C7_COND)
	oHtml:ValByName( "E4_DESCRI", SC7->C7_COND +" / "+SE4->E4_DESCRI)

	dbSelectArea('SC7')
	dbSetOrder(1)
	dbSeek(xFilial('SC7')+cNumPed)
    While !Eof() .and. C7_NUM = cNumPed
       nTotal  := nTotal + C7_TOTAL
       nFrete  := nFrete + C7_FRETE
       nImp    := nFrete +  (C7_VALIPI + C7_VALICM)
       AAdd( (oHtml:ValByName( "t1.1" )),C7_ITEM )		
       AAdd( (oHtml:ValByName( "t1.2" )),C7_PRODUTO )		       
       dbSelectArea('SB1')
       dbSetOrder(1)
       dbSeek(xFilial('SB1')+SC7->C7_PRODUTO)
       dbSelectArea('SC7')
       AAdd( (oHtml:ValByName( "t1.3" )),SB1->B1_DESC )		              
       AAdd( (oHtml:ValByName( "t1.4" )),SB1->B1_UM )		              
       AAdd( (oHtml:ValByName( "t1.5" )),TRANSFORM( C7_QUANT,PesqPict("SC7","C7_QUANT") ) )		              
       AAdd( (oHtml:ValByName( "t1.6" )),TRANSFORM( C7_PRECO,PesqPict("SC7","C7_PRECO") ) )		                     
       AAdd( (oHtml:ValByName( "t1.8" )),TRANSFORM( C7_TOTAL,PesqPict("SC7","C7_TOTAL") ) )		                     
       AAdd( (oHtml:ValByName( "t1.9" )),DTOC(SC7->C7_DATPRF) )
 //      AAdd( (oHtml:ValByName( "t1.10" )), C7_X_QApro )
       cUComp := SC7->C7_USER // usuario comprador do pedido
       cObs   += AllTrim(SC7->C7_OBS) + "/"
//       cMot	  += AllTrim(SC7->C7_X_MOT) + "/"
       dbSkip()
    Enddo

	AAdd( (oHtml:ValByName("t2.1" )),TRANSFORM( nTotal,PesqPict("SC7","C7_TOTAL") ))
	AAdd( (oHtml:ValByName("t2.2" )),TRANSFORM( nFrete,PesqPict("SC7","C7_TOTAL") ))		              	    
	AAdd( (oHtml:ValByName("t2.3" )),TRANSFORM( nImp  ,PesqPict("SC7","C7_TOTAL") ))	              	    

	AAdd( (oHtml:ValByName("t3.1")),AllTrim(cObs))
	oHtml:ValByName( "OBS",cMot)
	
	//ConOut(ClientName( Subs(cUsuario,7,15)))
	//ConOut(UsrRetMail(cUComp))
	
//	:AttachFile(<cArquivo>)
//	Este m?odo ?respons?el pela inclus? de arquivo anexos ?mensagem. Os arquivos anexos dever? estar abaixo do root path do Protheus.
//		Par?etros:
//			1.     cArquivo: Caminho e nome do arquivo a ser anexo a mensagem.
//			Exemplo: oP:AttachFile(�\Workflow\teste.txt�)
//    oProcess:AttachFile('\Workflow\ecf_va_02.dat')
//    oProcess:AttachFile('\Workflow\vafinr05.htm')     
	//oProcess:ClientName( Subs(cUsuario,7,15))
	oProcess:cTo :=  UsrRetMail(cUComp)  //Coloque aqui o destinatario do Email, comprador do pedido
	ConOut("antes do envio")
	oProcess:Start()            
	ConOut("depois do envio")
Return 
