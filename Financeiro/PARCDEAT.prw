#include "topconn.ch"
#include "protheus.ch" 
#include "rwmake.ch"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ PARCDEAT Autor ³ Henrique Magalhaes     ³ Data ³ 04.08.15 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ PARCDEAT (V@) 	            							  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ PARCDEAT (V@)        	    							   ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  

// Gravar na Observacao o campo Parcela De/Ate sendo 2 digitos  ##AA-BB##  AA-De / BB-Ate

User Function PARCDEAT(nTipo, cTitFil, cTitPref, cTitNum, cTitTip, cTitCF, cTitLoj ) 
//nTipo  2= Pagar / 1=Receber
Local aArea			:= GetArea()
Local cQuery		:= ""
Local cTitChave		:=  Iif(!Empty(cTitNum), cTitFil + cTitPref + cTitNum + cTitTip + cTitCF + cTitLoj,"") // chave pra pesquisa

	if nTipo = 2 // Pagar
	
		cQuery := " SELECT E2_FILIAL, E2_PREFIXO, E2_NUM, E2_TIPO, E2_FORNECE, E2_LOJA, MAX(E2_PARCELA) AS PARCE "
		cQuery += " FROM  "+RetSqlNAme('SE2')+"  WITH(NOLOCK) "
		cQuery += " WHERE E2_PARCELA <> ''  AND  D_E_L_E_T_ = '' "  
		if !Empty(cTitChave) 
			cQuery += " AND E2_FILIAL + E2_PREFIXO + E2_NUM + E2_TIPO + E2_FORNECE + E2_LOJA = '" +cTitChave+ "' "  
		Endif
		cQuery += " GROUP BY E2_FILIAL, E2_PREFIXO, E2_NUM, E2_TIPO, E2_FORNECE, E2_LOJA "
		cQuery += " HAVING MAX(E2_PARCELA) > '' "	
	else // 1 = Receber
	
		cQuery := " SELECT E1_FILIAL, E1_PREFIXO, E1_NUM, E1_TIPO, E1_CLIENTE, E1_LOJA, MAX(E1_PARCELA) AS PARCE "
		cQuery += " FROM  "+RetSqlNAme('SE1')+"  WITH(NOLOCK) "
		cQuery += " WHERE E1_PARCELA <> ''  AND  D_E_L_E_T_ = '' "  
		if !Empty(cTitChave) 
			cQuery += " AND E1_FILIAL + E1_PREFIXO + E1_NUM + E1_TIPO + E1_CLIENTE + E1_LOJA = '" +cTitChave+ "' "  
		Endif
		cQuery += " GROUP BY E1_FILIAL, E1_PREFIXO, E1_NUM, E1_TIPO, E1_CLIENTE, E1_LOJA "
		cQuery += " HAVING MAX(E1_PARCELA) > '' "
	Endif

	If Select("QRYTITULO") <> 0
		QRYTITULO->(dbCloseArea())
	Endif
	
	TCQUERY cQuery NEW ALIAS "QRYTITULO"
	dbSelectArea("QRYTITULO")
	QRYTITULO->(DbGoTop())


//UPDATE SE2010
//SET E2_HIST = 
//CASE WHEN (SUBSTRING(E2_HIST,1,1)='#' AND SUBSTRING(E2_HIST,4,1)='/' AND  SUBSTRING(E2_HIST,7,1)='#') 
//	THEN '#'+E2_PARCELA+'/'+'ZZ'+'# '+SUBSTRING(E2_HIST,9,100)
//	ELSE '#'+E2_PARCELA+'/'+E2_PARCELA+'# '+SUBSTRING(E2_HIST,1,100) END 
//WHERE E2_HIST <> ''AND E2_PREFIXO = 'TST' 

	Do While !QRYTITULO->(EOF()) 
		If nTipo = 2 // Pagar
			cQryUpd := " UPDATE " + RetSqlName('SE2') + "  "
			cQryUpd += " SET E2_HIST =  "
			cQryUpd += " CASE WHEN (SUBSTRING(E2_HIST,1,1)='#' AND SUBSTRING(E2_HIST,4,1)='/' AND  SUBSTRING(E2_HIST,7,1)='#')   "
			cQryUpd += " 	THEN '#'+E2_PARCELA+'/'+'"+QRYTITULO->PARCE+"'+'# '+SUBSTRING(E2_HIST,9,"+cValToChar(TamSx3('E2_HIST')[1])+")
			cQryUpd += " 	ELSE '#'+E2_PARCELA+'/'+'"+QRYTITULO->PARCE+"'+'# '+E2_HIST END 
//			cQryUpd += " SET    E2_X_PCATE  = '" +  QRYTITULO->PARCE + "'  " 
			cQryUpd += " WHERE E2_FILIAL + E2_PREFIXO + E2_NUM + E2_TIPO + E2_FORNECE + E2_LOJA = '" +(E2_FILIAL + E2_PREFIXO + E2_NUM + E2_TIPO + E2_FORNECE + E2_LOJA)+ "'   AND E2_PARCELA <> ''  AND  D_E_L_E_T_='' "
		Else  // 1=Receber
//			cQryUpd := " UPDATE " + RetSqlName('SE1') + "  "
//			cQryUpd += " SET    E1_X_PCATE  = '" +  QRYTITULO->PARCE + "'  " 
//			cQryUpd += " WHERE E1_FILIAL + E1_PREFIXO + E1_NUM + E1_TIPO + E1_CLIENTE + E1_LOJA = '" +(E1_FILIAL + E1_PREFIXO + E1_NUM + E1_TIPO + E1_CLIENTE + E1_LOJA)+ "'   AND E1_PARCELA <> ''  AND  D_E_L_E_T_='' "
		Endif

  //	memowrite("c:\TOTVS\update_se2_parcela.txt", cQryUpd)
					
		If nTipo = 2 // Pagar
			TcSqlExec(cQryUpd) 
		Endif
		QRYTITULO->(dbskip())				
    EndDo
	RestArea(aArea)			                              
Return                                                 
       
User Function ParcDAju()
	Local aArea	:= GetArea()
	DbSelectArea('SE2')
	SE2->(dbGoTop())
	Do While !SE2->(EOF())
		u_PARCDEAT(2, SE2->E2_FILIAL, SE2->E2_PREFIXO, SE2->E2_NUM, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA) 
		SE2->(dbSkip())
	EndDo
	RestArea(aArea)			                              
Return