#include "topconn.ch"
#include "protheus.ch" 
#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ VAGENPRO³ Autor ³ Henrique Magalhaes     ³ Data ³ 05.10.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ efetua de / para de produtos	(por grupo x codigo automatico³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Alterar produtos											   ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  

User Function VAGENPRO()
Local  cPerg := "VAGENPRO"

ValidPerg(cPerg)
Pergunte(cPerg,.T.)

@ 0,00 TO 227,463 DIALOG oDlg TITLE "Atualizar Arquivos com codigos de produto"
@ 8,10 TO 84,222
@ 23,16 SAY OemToAnsi("Este programa ira atualizar todos os codigo de produtos DE/PARA     "+space(15))
@ 33,16 SAY OemToAnsi("Faça um backup de sua base de dados antes                           "+space(15))
@ 43,16 SAY OemToAnsi("Apos procedimento executar rotina Refaz Saldo Atual/refaz Acumulados"+space(15))
@ 53,16 SAY OemToAnsi("                                                                    "+space(15))
@ 91,138 BMPBUTTON TYPE 05 	ACTION Pergunte(cPerg,.T.)
@ 91,168 BMPBUTTON TYPE 1 	ACTION OkProcProd()
@ 91,196 BMPBUTTON TYPE 2 	ACTION Close(oDlg)

ACTIVATE DIALOG oDlg CENTERED

Return

/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦OkProc    ¦ Autor ¦                       ¦ Data ¦          ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦Confirma o Processamento                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
Static Function OkProcProd()
	If (msgyesno("Confirma Processamento das informacoes?"))
		Processa( {|| RunProc() } )
	Endif
	Close(oDlg)
Return



/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Funçäo    ¦RunProc   ¦ Autor ¦                       ¦ Data ¦          ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçäo ¦Executa o Processamento                                     ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
// Procedimento
// a) Criar Campo na SB1  B1_X_GRPNE 	--> Codigo do grupo de Produto para o qual sera alterado 
// b) Criar Campo na SB1  B1_X_CODNE 	--> Codigo para o qual sera alterado o produto, com base no grupo  
// c) Criar Campo na SB1  B1_X_CODAN	--> Codigo anterior do produto antes da alteracao - alterar apenas apos conclusao da rotina
// d) Criar Campo na SB1  B1_X_GRPAN	--> Grupo  anterior do produto antes da alteracao - alterar apenas apos conclusao da rotina
// ROTEIRO
// e) Executar rotina verificando o grupo de campos e efetuando a alteracao (menos na SB1 e SB2)  - para registros que tenham o codigo B1_X_GRPPA preenchido
// f) gerar codigo novo para o B1_X_CODPA e gravar o B1_X_CODANT/B1_X_GRPANT 
// g) verificar Codigo do Produto e do Grupo, se o grupo tambem existe no grupo de campos
// h) efetuar update nas tabelas do grupo de campos
// g) Procurar Produto na SB2 (origem) e Deletar Registros 
// I) Alterar codigo do produto e grupo na SB1 ( B1_X_GRPNEW --> B1_GRUPO /  B1_X_CONEW --> B1_COD)

*/
Static Function RunProc()
Local aArea		:= GetArea()
Local cQuery	:= ""
Local cQueryGrp	:= ""
Local cTabSX3	:= if(EMPTY(MV_PAR01),"SX3PROD",alltrim(MV_PAR01)) // TABELA COPIA DA SX3 FILTRADA COM OS CAMPOS A SEREM ALTERADOS
Local cTabela	:= ""
Local cCampoX3	:= ""
Local cLogSql	:= ""
Local cLogProd	:= ""
Local cLogGrupo := ""
Local cCodB1De	:= ""
Local cCodB1Pa  := ""
Local cCodBMDe	:= ""
Local cCodBMPa  := ""

//Local nCpoTam	:= if(MV_PAR02>0,MV_PAR02,15) // TAMANHO DO CAMPO A SER PREENCHIDO PARA PRODUTO

//	cLogProd +=  cQryUpd + "; " + Chr(13)+Chr(10)	

// Relaciona Produtos a Serem alterados
	cQuery := " SELECT  B1_COD, B1_GRUPO, B1_X_CODNE, B1_X_GRPNE "
	cQuery += " FROM  "+RetSqlNAme('SB1')+"  "
	cQuery += " WHERE B1_X_GRPNE <> ' ' AND B1_MSBLQL <> '1' AND B1_X_CODNE<>B1_COD AND B1_X_GRPNE<>B1_GRUPO "  // executar apenas para produtos com o campo preenchido e que nao estejam bloqueados  
	cQuery += " AND B1_COD BETWEEN '" + mv_par02 +"'  AND '" + mv_par03 +"'  AND D_E_L_E_T_='' " 
	cQuery += " ORDER BY B1_COD "

	If Select("QRYPROD") <> 0
		QRYPROD->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "QRYPROD"
	dbSelectArea("QRYPROD")
	ProcRegua(RecCount())
	QRYPROD->(DbGoTop())


//SELECT  X3_ARQUIVO, X3_CAMPO, X3_TAMANHO, X3_GRPSXG from sx3prod   where X3_GRPSXG = '030'
                                     
// Seleciona a tabela de grupo de Campos mais atualizada para fazer os updates 
	cQuery := " SELECT  X3_ARQUIVO, X3_CAMPO, X3_TAMANHO, X3_GRPSXG  "
	cQuery += " FROM  "+cTabSX3+"  "
	cQuery += " WHERE X3_GRPSXG = '030' AND X3_ARQUIVO NOT IN ('SB1','SB2') "  // nao alterar o conteudo da SB1/SB2  
	cQuery += " ORDER BY X3_GRPSXG, X3_ARQUIVO, X3_CAMPO, X3_TAMANHO "

	cQueryGrp := " SELECT  X3_ARQUIVO, X3_CAMPO, X3_TAMANHO"
	cQueryGrp += " FROM  "+cTabSX3+"  "
	cQueryGrp += " WHERE X3_F3 = 'SBM' AND X3_ARQUIVO NOT IN ('SB1','SB2') "  // nao alterar o conteudo da SB1/SB2  
	cQueryGrp += " ORDER BY X3_GRPSXG, X3_ARQUIVO, X3_CAMPO, X3_TAMANHO "


	If Select("QSX3GRP") <> 0
		QSX3GRP->(dbCloseArea())
	Endif
	TCQUERY cQueryGrp NEW ALIAS "QSX3GRP"


	If Select("QSX3PROD") <> 0
		QSX3PROD->(dbCloseArea())
	Endif
	TCQUERY cQuery NEW ALIAS "QSX3PROD"
	dbSelectArea("QSX3PROD")

	DbSelectArea('SB1')
	SB1->(dbSetOrder(1))

	Do While !QRYPROD->(EOF()) // While para produtos encontrados na B1_X_CODNW
		IncProc()                                       
		// VERIFICA DE O PRODUTO B1_X_CODNW  existe na SB1
		cCodBMDe := QRYPROD->B1_GRUPO 
		cCodBMPa := QRYPROD->B1_X_GRPNE
		cCodB1De := QRYPROD->B1_COD 
   		// Buscar codigo novo codigo pela funcao u_ProxSB1(cCodBMPa)
		cCodB1Pa := u_ProxSB1(AllTrim(cCodBMPa))   // SB1->B1_X_CODNW
	
		If SB1->(dbSeek(xFilial("SB1") + cCodB1De)) // Grava o Novo codigo no campo B1_X_CODNEW 
			RecLock("SB1",.F.)
				SB1->B1_X_CODNE := cCodB1Pa
				SB1->B1_MSBLQL 	:= '1' 			
		    SB1->(MsUnLock())	
		Endif
	
		If SB1->(dbSeek(xFilial("SB1") + cCodB1De)) // Origem
			QSX3PROD->(dbGoTop())	
			Do While !QSX3PROD->(EOF())
				cTabela		:= ALLTRIM(RetSqlName(QSX3PROD->X3_ARQUIVO))
				cCampoX3	:= ALLTRIM(QSX3PROD->X3_CAMPO)
				
				//SELECT count(* ) AS CONTADOR FROM sysobjects where xtype = 'U' and name = 'sa2010'
				cQuery2 :=  "SELECT count(* ) AS CONTADOR FROM sysobjects where xtype = 'U' and name = '" + cTabela + "'  "   
				If Select("QRYTAB") <> 0
					QRYTAB->(dbCloseArea())
				Endif
				TcQuery cQuery2 NEW ALIAS "QRYTAB"  
				
				If QRYTAB->CONTADOR>0
					
//					cQuery2 :=  "SELECT count(* ) AS QTREG FROM " + cTabela + " WHERE  " + cCampoX3 + " = '"  +  Alltrim(cCodB1De) + "'  AND D_E_L_E_T_<>'*' "
//					If Select("QRYQTD") <> 0
//						QRYQTD->(dbCloseArea())
//					Endif
//					TcQuery cQuery2 NEW ALIAS "QRYQTD"  
//					If QRYQTD->QTREG>0
//						cLogTabU 	+= "SELECT * FROM " + cTabela + " WHERE  " + cCampoX3 + " = '"  + alltrim(cCodB1De) + "'  AND D_E_L_E_T_<>'*'; "	+ Chr(13)+Chr(10)
//					Endif
	

			//SELECT B1_COD, B1_DESC,  Substring( Replicate('0', 15-Len( B1_COD ) ) + Ltrim( Rtrim( B1_COD ) ) ,9,6) AS CODIGO_NOVO FROM SB1010 WHERE D_E_L_E_T_ <> '*'
					cQryUpd := " UPDATE " + cTabela  + "   "
					cQryUpd += " SET    " + cCampoX3 + " = '"  +  Alltrim(cCodB1Pa) + "'   "
					cQryUpd += " WHERE  " + cCampoX3 + " = '"  +  Alltrim(cCodB1De) + "'  AND D_E_L_E_T_<>'*' "
					TcSqlExec(cQryUpd) 
					
					//cLogSql +=  cQryUpd + "; " + Chr(13)+Chr(10)	
				Endif
				QSX3PROD->(dbskip())
			EndDo	   
	 		cLogProd +=  "Produto --> "+ SB1->B1_COD + " com codigo Substituido por  --> "+SB1->B1_X_CODNE + "; " + Chr(13)+Chr(10)	
			
//			MemoWrite("C:\logtotvs\TABELASLOG_"+alltrim(SB1->B1_COD)+".TXT",cLogTabU)
//			cLogTabU := ""            

			QSX3GRP->(dbGoTop())	
			Do While !QSX3GRP->(EOF())
				cTabela		:= ALLTRIM(RetSqlName(QSX3GRP->X3_ARQUIVO))
				cCampoX3	:= ALLTRIM(QSX3GRP->X3_CAMPO)
				
				//SELECT count(* ) AS CONTADOR FROM sysobjects where xtype = 'U' and name = 'sa2010'
				cQuery2 :=  "SELECT count(* ) AS CONTADOR FROM sysobjects where xtype = 'U' and name = '" + cTabela + "'  "   
				If Select("QRYTAB") <> 0
					QRYTAB->(dbCloseArea())
				Endif
				TcQuery cQuery2 NEW ALIAS "QRYTAB"  
				
				If QRYTAB->CONTADOR>0
			//SELECT B1_COD, B1_DESC,  Substring( Replicate('0', 15-Len( B1_COD ) ) + Ltrim( Rtrim( B1_COD ) ) ,9,6) AS CODIGO_NOVO FROM SB1010 WHERE D_E_L_E_T_ <> '*'
					cQryUpd := " UPDATE " + cTabela  + "   "
					cQryUpd += " SET    " + cCampoX3 + " = '"  +  Alltrim(cCodBMPa) + "'   "
					cQryUpd += " WHERE  " + cCampoX3 + " = '"  +  Alltrim(cCodBMDe) + "'  AND D_E_L_E_T_<>'*' "
					TcSqlExec(cQryUpd) 
					
					//cLogSql +=  cQryUpd + "; " + Chr(13)+Chr(10)	
				Endif
			
				QSX3GRP->(dbskip())
			EndDo	   
	 		cLogGrupo +=  "G.Produto --> " + SB1->B1_COD  + " com grupo " + cCodBMDe +  "Substituido por  --> " + SB1->B1_X_GRPNE + "; " + Chr(13)+Chr(10)	
			
			If SB2->(dbSeek(xFilial("SB2") + cCodB1De))
				Do While !SB2->(EOF()) .and. SB2->B2_COD = cCodB1De 
					RecLock("SB2",.F.)
						DbDelete()			
				    SB2->(MsUnLock())	
					SB2->(dbskip())				
			    EndDo
			Else
			   //	Alert('Nao Achou sb2 do cCodB1Pa ' +cCodB1De )   
            Endif

	


			If SB1->(dbSeek(xFilial("SB1") + cCodB1De)) // Grava o Novo codigo no campo B1_X_CODNEW 
				RecLock("SB1",.F.)
					SB1->B1_X_CODAN 	:= cCodB1De 			
					SB1->B1_COD 		:= cCodB1Pa 			
					SB1->B1_X_GRPAN 	:= cCodBMDe 			
					SB1->B1_GRUPO 		:= cCodBMPa 			
					SB1->B1_MSBLQL 		:= '2' 			
			    SB1->(MsUnLock())	
			Endif


		Else // nao encontrou o produto do b1_x_codpa
			 		cLogProd +=  "Produto --> "+ SB1->B1_COD + " #### Nao foi encontrado o codigo  --> "+SB1->B1_X_CODNEW + " ####; " + Chr(13)+Chr(10)		
		Endif
		
		QRYPROD->(dbskip())
	EndDo	   
		                
	MSGINFO("Os produtos tiveram seus codigos atualizados!","Aviso")   
	
	MemoWrite("C:\SX3PRODLOG.TXT",cLogSql)
	MemoWrite("C:\PRODDEPARALOG.TXT",cLogProd)
	MemoWrite("C:\GRUPODEPARALOG.TXT",cLogGrupo)
	
	restArea(aArea)
Return                      



Static Function ValidPerg(cPerg)        
    Local i := 0
	Local j := 0
	_sAlias	:=	Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg 	:=	PADR(cPerg,10)
	aRegs	:=	{}
	//                                                                                                      -- 02 03 04 05 -- 07 08 09 10 -- 12 13 14 15 -- 17 18 19 20 -- 22 23 24 F3
	AADD(aRegs,{cPerg,"01","Tabela SX3/SXG   ?",Space(20),Space(20),"mv_ch1","C",10,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"02","Produto De       ?",Space(20),Space(20),"mv_ch2","C",15,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"03","Produto Ate      ?",Space(20),Space(20),"mv_ch3","C",15,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
//	AADD(aRegs,{cPerg,"02","Tamanho do Campo ?",Space(20),Space(20),"mv_ch2","N",02,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				FieldPut(j,aRegs[i,j])
			Next
			MsUnlock()
			dbCommit()
		Endif
	Next
	
	dbSelectArea(_sAlias)
	
Return
