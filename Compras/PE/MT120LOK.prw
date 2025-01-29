#include "topconn.ch"
#include "protheus.ch" 
#include "rwmake.ch"

/* 
	MJ : 15.04.2019
		# Forçar o preenchimento de campos no PEDIDO DE COMPRAS 
*/
User Function MT120LOK()
Local lRet 		 := .T.

If !IsInCallStack( "U_VACOMM07") .AND.;
	!IsInCallStack( "U_VACOMM11") .AND.;
	!IsInCallStack( "U_VACOMM12") .AND.;
	!(FunName() $ ("MNTA650|CNTA121"))
	
	If !(lRet := !Empty( CTPFRETE ))
		Alert("O campo Tipo Frete na 3 ABA não foi informado. Este campo é obrigatorio.")
	EndIf
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ MT120LOK Autor ³ Henrique Magalhaes   ³ Data ³ 07.12.2015³ ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descrição ³  Validacao na linha do pedido de compra                   ³±±  
±±³ ** Utilizado para tratar obrigatoriedade de campos					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ validar campos de digitacao no item do pedido de compras    ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*   
Descrição:
utilizacao para validar as entidade de Centro de Custo / Item Contabil / Classe valor  na digitacao de itens no Pedido de compra
*/  

/*User Function MT120LOK()

Local aArea		:= GetArea()
Local nPosCod   := aScan(aHeader,{|x| AllTrim(x[2])=="C7_PRODUTO"})
Local nPosTES   := aScan(aHeader,{|x| AllTrim(x[2])=="C7_TES"})
Local nPosCC    := aScan(aHeader,{|x| AllTrim(x[2])=="C7_CC"})
Local nPosITCTA := aScan(aHeader,{|x| AllTrim(x[2])=="C7_ITEMCTA"})
Local nPosCLVL  := aScan(aHeader,{|x| AllTrim(x[2])=="C7_CLVL"})
Local cCtrEst	:= ""
Local cCtrFin	:= ""
Local lRet		:= .T.

If Alltrim(cEmpAnt)<>'01' // Efetua Validacao apenas para empresa 01 - fazendas
	RestArea(aArea)
	Return lRet 
Endif

If !Empty(aCols[n,nPosTES]) // Somente valida após Preenchimento ds TES
	cCtrEst := Posicione('SF4',1,xFilial('SF4') +aCols[n,nPosTES],'F4_ESTOQUE')	
	cCtrFin := Posicione('SF4',1,xFilial('SF4') +aCols[n,nPosTES],'F4_DUPLIC')	
	If cCtrEst == 'S' 
		// Se Controlar Estoque nao permite o preenchimento das entidades CC / Item Contabil / Classe Valor
		If  !Empty(aCols[n,nPosCC]) .or. !Empty(aCols[n,nPosITCTA]) .or. !Empty(aCols[n,nPosCLVL]) 
			aCols[n,nPosCC]		:= Space(TamSX3('C7_CC')[1])
			aCols[n,nPosITCTA]	:= Space(TamSX3('C7_ITEMCTA')[1])
			aCols[n,nPosCLVL]	:= Space(TamSX3('C7_CLVL')[1])    
			Aviso('AVISO', 'Itens para Estoque nao devem ter os campos Centro de Custo / Item Contabil / Classe Valor preenchidos!!! Verifique!!!', {'Ok'})	
			lRet := .T.
		Endif
	Else // Se for Custo Direto (Nao controle estoque e deve obrigar os preenchimentos das entidades CC / Item Contabil / Classe Valor
		// Se for Custo Diretro (Estoque NAO) obriga preencher as entidades CC / Item Contabil / Classe Valor
		If  cCtrFin='S' .and. ( Empty(aCols[n,nPosCC]) .or. Empty(aCols[n,nPosITCTA]) .or. Empty(aCols[n,nPosCLVL]) ) 
			Aviso('AVISO', 'Itens que nao controlam Estoque, devem ter os campos Centro de Custo / Item Contabil / Classe Valor preenchidos!!! Verifique!!!', {'Ok'})	
			lRet := .F.
		Endif	
	Endif 
Endif

//u_M120CALC()

RestArea(aArea)


Return(lRet)

*/

// User Function M120CALC() // Funcao para recalcular totais de peso x rendimento x arroba
// Local aArea		:= GetArea()
// Local nPosPeso	:= aScan(aHeader,{|x| AllTrim(x[2])=="C7_X_PESO"}) 		// peso em Kg
// Local nPosRend  := aScan(aHeader,{|x| AllTrim(x[2])=="C7_X_REND"})		// rendimento em %
// Local nPosRendP := aScan(aHeader,{|x| AllTrim(x[2])=="C7_X_RENDP"})		// rendimento em KG
// Local nPosArrov := aScan(aHeader,{|x| AllTrim(x[2])=="C7_X_ARROV"}) 	// valor unitário por arroba (@)
// Local nPosArroQ := aScan(aHeader,{|x| AllTrim(x[2])=="C7_X_ARROQ"})		// quantidade de arroba (@)
// Local nPosTotal := aScan(aHeader,{|x| AllTrim(x[2])=="C7_X_TOTAL"})		// valor total calculado pelo Peso x rendimento x arroba
// Local nPosVlUni := aScan(aHeader,{|x| AllTrim(x[2])=="C7_X_VLUNI"})		// valor unitario por cabeça de gado (conforme calculos de rendimento x arroba e quantiddae de cabecas no campo C7_QUANT)
// Local nPosVlICM := aScan(aHeader,{|x| AllTrim(x[2])=="C7_X_VLICM"})		// valor unitario de icms por cabeca de gado
// Local nPosToICM := aScan(aHeader,{|x| AllTrim(x[2])=="C7_X_TOICM"})		// valor total de icms calculado
// Local nPosQuant := aScan(aHeader,{|x| AllTrim(x[2])=="C7_QUANT"})		// Quantidade - Padrao
// Local nPosPreco := aScan(aHeader,{|x| AllTrim(x[2])=="C7_PRECO"})		// Preco Unitario - Padrao
// Local nPosTotPC := aScan(aHeader,{|x| AllTrim(x[2])=="C7_TOTAL"})		// Total do Pedido - Padrao
// Local nArroba	:= 15
// Local lRet		:= .T.
// 
// // Testar Variavel
// 
// If Alltrim(cEmpAnt)<>'01' // Efetua Validacao apenas para empresa 01 - fazendas
// 	RestArea(aArea)
// 	Return lRet 
// Endif
// 
// If aCols[n,nPosPeso]>0 // Somente valida e calcula se houver Preenchimento do peso
// 
// // receber o valor na c7_preco e chamar gatilho pra calcular
// //	aCols[n,nPosRendP]	:= NoRound( aCols[n,nPosPeso]  * (aCols[n,nPosRend] / 100)	, TamSX3("C7_X_RENDP")[2])
// //	aCols[n,nPosArroQ]	:= NoRound( aCols[n,nPosRendP] / nArroba					, TamSX3("C7_X_ARROQ")[2])
// //	aCols[n,nPosTotal]	:= NoRound( aCols[n,nPosArroQ] * aCols[n,nPosArroV]			, TamSX3("C7_X_TOTAL")[2])
// //	aCols[n,nPosVlUni]	:= NoRound( aCols[n,nPosTotal] / aCols[n,nPosQuant] 		, TamSX3("C7_X_VLUNI")[2])
// //	aCols[n,nPosVlICM]	:= NoRound( aCols[n,nPosToICM] / aCols[n,nPosQuant] 		, TamSX3("C7_X_VLICM")[2])
// //	aCols[n,nPosPreco]	:= NoRound( aCols[n,nPosVlUni] + aCols[n,nPosVlICM] 		, TamSX3("C7_PRECO")[2])
// //	aCols[n,nPosTotPC]	:= NoRound( aCols[n,nPosQuant] * aCols[n,nPosPreco] 		, TamSX3("C7_TOTAL")[2])
// 
// //
// 
// 
// 	If Type("M->C7_X_RENDP")<>"U" // testar variaveis 
// 			Alert(Type("M->C7_X_PESO"))
// 			M->C7_X_RENDP		:= NoRound( Iif(Type("M->C7_X_PESO")<>"U", M->C7_X_PESO, aCols[n,nPosPeso])  * ( Iif(Type("M->C7_X_RENDP")<>"U",M->C7_X_RENDP,aCols[n,nPosRend]) / 100)	, TamSX3("C7_X_RENDP")[2])
// 	Else
// 			aCols[n,nPosRendP] 	:= NoRound( Iif(Type("M->C7_X_PESO")<>"U", M->C7_X_PESO, aCols[n,nPosPeso])  * ( Iif(Type("M->C7_X_RENDP")<>"U",M->C7_X_RENDP,aCols[n,nPosRend]) / 100)	, TamSX3("C7_X_RENDP")[2])
// 	Endif
// 	
// 	If Type("M->C7_X_ARROQ")<>"U" 
// 			M->C7_X_ARROQ		:= NoRound( Iif(Type("M->C7_X_RENDP")<>"U",M->C7_X_RENDP, aCols[n,nPosRendP]) / nArroba , TamSX3("C7_X_ARROQ")[2])
// 	Else
// 			aCols[n,nPosArroQ] 	:= NoRound( Iif(Type("M->C7_X_RENDP")<>"U",M->C7_X_RENDP, aCols[n,nPosRendP]) / nArroba , TamSX3("C7_X_ARROQ")[2])
// 	Endif
// 
// 
// 	If Type("M->C7_X_TOTAL")<>"U" 
// 			M->C7_X_TOTAL		:= NoRound( Iif(Type("M->C7_X_ARROQ")<>"U", M->C7_X_ARROQ, aCols[n,nPosArroQ]) * Iif(Type("M->C7_X_ARROV")<>"U", M->C7_X_ARROV, aCols[n,nPosArroV]) , TamSX3("C7_X_TOTAL")[2]) 
// 	Else
// 			aCols[n,nPosTotal] 	:= NoRound( Iif(Type("M->C7_X_ARROQ")<>"U", M->C7_X_ARROQ, aCols[n,nPosArroQ]) * Iif(Type("M->C7_X_ARROV")<>"U", M->C7_X_ARROV, aCols[n,nPosArroV]) , TamSX3("C7_X_TOTAL")[2]) 
// 	Endif
// 
// 	
// 	If Type("M->C7_X_VLUNI")<>"U" 
// 			M->C7_X_VLUNI		:= NoRound( Iif(Type("M->C7_X_TOTAL")<>"U", M->C7_X_TOTAL, aCols[n,nPosTotal]) / Iif(Type("M->C7_QUANT")<>"U", M->C7_QUANT, aCols[n,nPosQuant]) , TamSX3("C7_X_VLUNI")[2]) 
// 	Else
// 			aCols[n,nPosVlUni]	:= NoRound( Iif(Type("M->C7_X_TOTAL")<>"U", M->C7_X_TOTAL, aCols[n,nPosTotal]) / Iif(Type("M->C7_QUANT")<>"U", M->C7_QUANT, aCols[n,nPosQuant]) , TamSX3("C7_X_VLUNI")[2])
// 	Endif
// 
// 
// 	If Type("M->C7_X_VLICM")<>"U" 
// 			M->C7_X_VLICM		:= NoRound( Iif(Type("M->C7_X_TOICM")<>"U", M->C7_X_TOICM, aCols[n,nPosToICM]) / Iif(Type("M->C7_QUANT")<>"U", M->C7_QUANT, aCols[n,nPosQuant]) , TamSX3("C7_X_VLICM")[2])
// 	Else
// 			aCols[n,nPosVlICM]	:= NoRound( Iif(Type("M->C7_X_TOICM")<>"U", M->C7_X_TOICM, aCols[n,nPosToICM]) / Iif(Type("M->C7_QUANT")<>"U", M->C7_QUANT, aCols[n,nPosQuant]) , TamSX3("C7_X_VLICM")[2])
// 	Endif
// 
// 	
// 	If Type("M->C7_PRECO")<>"U" 
// 			M->C7_PRECO			:= NoRound( Iif(Type("M->C7_X_VLUNI")<>"U", M->C7_X_VLUNI, aCols[n,nPosVlUni]) + Iif(Type("M->C7_X_VLICM")<>"U", M->C7_X_VLICM, aCols[n,nPosVlICM]) 		, TamSX3("C7_PRECO")[2])
// 			
// 			If Positivo() .and. A120Preco(M->C7_PRECO) .And. MaFisRef("IT_PRCUNI","MT120",M->C7_PRECO) .AND. MTA121TROP(n)                       	
// //    			A120Preco(M->C7_PRECO)
// 			Endif
// 	Else
// 			aCols[n,nPosPreco]	:= NoRound( Iif(Type("M->C7_X_VLUNI")<>"U", M->C7_X_VLUNI, aCols[n,nPosVlUni]) + Iif(Type("M->C7_X_VLICM")<>"U", M->C7_X_VLICM, aCols[n,nPosVlICM]) 		, TamSX3("C7_PRECO")[2])
// 			If Positivo() .and. A120Preco(aCols[n,nPosPreco]) .And. MaFisRef("IT_PRCUNI","MT120",aCols[n,nPosPreco]) .AND. MTA121TROP(n)                       	
// //				A120Preco(aCols[n,nPosPreco])
// 			Endif
// 	Endif
// 
// 	If ExistTrigger("C7_PRECO")
//  		RunTrigger(2,N)                                  
//  	EndIf
// 
// 
// //	If Type("M->C7_TOTAL")<>"U" 
// //			M->C7_TOTAL			:= NoRound( Iif(Type("M->C7_QUANT")<>"U", M->C7_QUANT, aCols[n,nPosQuant]) *  Iif(Type("M->C7_PRECO")<>"U", M->C7_PRECO, aCols[n,nPosPreco]) 		, TamSX3("C7_TOTAL")[2])
// //			M->C7_TOTAL 		:= If(A120Trigger("C7_TOTAL"), Iif(Type("M->C7_TOTAL")<>"U",M->C7_TOTAL,aCols[n,nPosTotPC]), 0)                                            
// //	Else
// //			aCols[n,nPosTotPC]	:= NoRound( Iif(Type("M->C7_QUANT")<>"U", M->C7_QUANT, aCols[n,nPosQuant]) *  Iif(Type("M->C7_PRECO")<>"U", M->C7_PRECO, aCols[n,nPosPreco]) 		, TamSX3("C7_TOTAL")[2])
// //			M->C7_TOTAL 		:= If(A120Trigger("C7_TOTAL"), Iif(Type("M->C7_TOTAL")<>"U",M->C7_TOTAL,aCols[n,nPosTotPC]), 0)                                            
// // 	Endif                                 
// 	
// 
// Endif
// 
// 
// RestArea(aArea)
// Return lRet
