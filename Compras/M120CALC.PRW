#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

/*
	MJ : 24.08.2017
		1- Fonte separado por se tratar de uma funcao de validacao, que nao
			mais sera chamado pelo PE, e sim pela validacao do campo:
			X3_VLDUSER;
*/
User Function M120CALC(_cCampo, _cInfo ) // Funcao para recalcular totais de peso x rendimento x arroba
Local lRet		:= .T.
Local nPosQuant := aScan(aHeader,{|x| AllTrim(x[2])=="C7_QUANT"})		// Quantidade - Padrao
Local nPosPreco := aScan(aHeader,{|x| AllTrim(x[2])=="C7_PRECO"})		// Preco Unitario - Padrao
Local nPosTotPC := aScan(aHeader,{|x| AllTrim(x[2])=="C7_TOTAL"})		// Total do Pedido - Padrao

Local nPosPeso	:= aScan(aHeader,{|x| AllTrim(x[2])=="C7_X_PESO"}) 		// peso em Kg
Local nPosRend  := aScan(aHeader,{|x| AllTrim(x[2])=="C7_X_REND"})		// rendimento em %
Local nPosPRend := aScan(aHeader,{|x| AllTrim(x[2])=="C7_X_RENDP"})		// rendimento em KG
Local nPosArrov := aScan(aHeader,{|x| AllTrim(x[2])=="C7_X_ARROV"}) 	// valor unitário por arroba (@)
Local nPosArroQ := aScan(aHeader,{|x| AllTrim(x[2])=="C7_X_ARROQ"})		// quantidade de arroba (@)
Local nPosTotal := aScan(aHeader,{|x| AllTrim(x[2])=="C7_X_TOTAL"})		// valor total calculado pelo Peso x rendimento x arroba
Local nPosVlUni := aScan(aHeader,{|x| AllTrim(x[2])=="C7_X_VLUNI"})		// valor unitario por cabeça de gado (conforme calculos de rendimento x arroba e quantiddae de cabecas no campo C7_QUANT)
Local nPosVlICM := aScan(aHeader,{|x| AllTrim(x[2])=="C7_X_VLICM"})		// valor unitario de icms por cabeça de gado
Local nPosToICM := aScan(aHeader,{|x| AllTrim(x[2])=="C7_X_TOICM"})		// valor total de icms calculado
Local nArroba	:= 15
Local lTodos	:= .F.

Default _cCampo	:= SubStr( ReadVar(),  At( "M->", ReadVar() ) + 3 )
Default _cInfo	:= &( ReadVar() )

If !IsInCallStack( "U_VACOMM07") .AND. !IsInCallStack( "U_VACOMM11")
	If _cCampo == 'C7_QUANT' // nPosQuant
		
		lTodos := (_cInfo > 0 .and. aCols[n,nPosPeso] > 0 .and. aCols[n,nPosRend] > 0 .and. aCols[n,nPosArroV] > 0 .and. aCols[n,nPosToICM] > 0)
		If lTodos
			// ALTERACAO..,
		
			// C7_X_VLUNI
			aCols[n,nPosVlUni]	:= NoRound( aCols[n,nPosTotal] / _cInfo , TamSX3("C7_X_VLUNI")[2])
		
			// C7_X_VLICM: Calcula Valor ICMS Unit?rio (C7_X_VLICM)
			aCols[n,nPosVlICM] :=	NoRound( aCols[n,nPosToICM]/ _cInfo , TamSX3("C7_X_VLICM")[2])
			
			// C7_PRECO
			//aCols[n,nPosPreco]	:= NoRound( aCols[n,nPosVlUni] + aCols[n,nPosVlICM] 		, TamSX3("C7_PRECO")[2])
			
			aCols[n,nPosPreco]	:= NoRound( Iif(Type("M->C7_X_VLUNI")<>"U", M->C7_X_VLUNI, aCols[n,nPosVlUni]) + Iif(Type("M->C7_X_VLICM")<>"U", M->C7_X_VLICM, aCols[n,nPosVlICM]) 		, TamSX3("C7_PRECO")[2])
			If Positivo() .and. A120Preco(aCols[n,nPosPreco]) .And. MaFisRef("IT_PRCUNI","MT120",aCols[n,nPosPreco]) .AND. MTA121TROP(n)
			//				A120Preco(aCols[n,nPosPreco])
			Endif
			
			// C7_TOTAL
			aCols[n,nPosTotPC]	:= NoRound( aCols[n,nPosPreco] * aCols[n,nPosQuant] 		, TamSX3("C7_TOTAL")[2])
		
		EndIf
		
	ElseIf _cCampo == 'C7_X_PESO' // nPosPeso

		lTodos := (aCols[n,nPosQuant] > 0 .and. _cInfo > 0 .and. aCols[n,nPosRend] > 0 .and. aCols[n,nPosArroV] > 0 .and. aCols[n,nPosToICM] > 0)
		If lTodos
			// ALTERACAO
			
			//C7_X_RENDP: Calcula Rendimento em Peso (C7_X_RENDP)
			aCols[n,nPosPRend] := NoRound(_cInfo * aCols[n,nPosRend] / 100	, TamSX3("C7_X_RENDP")[2])
		
			U_M120CALC('C7_X_ARROV', aCols[n,nPosArrov] )
		
		EndIf

	ElseIf _cCampo == 'C7_X_REND' // nPosRend

		//C7_X_RENDP: Calcula Rendimento em Peso (C7_X_RENDP)
		aCols[n,nPosPRend] := NoRound(aCols[n,nPosPeso] * (_cInfo / 100) , TamSX3("C7_X_RENDP")[2])

		lTodos := (aCols[n,nPosQuant] > 0 .and. aCols[n,nPosPeso] > 0 .and. _cInfo > 0 .and. aCols[n,nPosArroV] > 0 .and. aCols[n,nPosToICM] > 0)
		If lTodos
			// ALTERACAO
			
			U_M120CALC('C7_X_ARROV', aCols[n,nPosArrov] )
		
		EndIf
		
	ElseIf _cCampo == 'C7_X_RENDP' // nPosPRend

		//C7_X_REND: Calcula Rendimento em Peso (C7_X_RENDP)
		aCols[n,nPosRend] := NoRound(_cInfo/aCols[n,nPosPeso] * 100	, TamSX3("C7_X_REND")[2])
		
		lTodos := (aCols[n,nPosQuant] > 0 .and. aCols[n,nPosPeso] > 0 .and. aCols[n,nPosRend] > 0 .and. aCols[n,nPosArroV] > 0 .and. aCols[n,nPosToICM] > 0)
		If lTodos
			// ALTERACAO
			
			U_M120CALC('C7_X_ARROV', aCols[n,nPosArrov] )
		
		EndIf
		
	ElseIf _cCampo == 'C7_X_ARROV' // nPosArrov

		// C7_X_ARROQ: [CALCULADO] Quantidade de Arrobas
		aCols[n,nPosArroQ]	:= NoRound( aCols[n,nPosPRend] / nArroba				, TamSX3("C7_X_ARROQ")[2])

		//C7_X_TOTAL: Calcula Valor Total (C7_X_TOTAL)
		aCols[n,nPosTotal] :=  NoRound( aCols[n,nPosArroQ] * _cInfo	, TamSX3("C7_X_TOTAL")[2])

		U_M120CALC('C7_X_TOTAL', aCols[n,nPosTotal] )
		
	ElseIf _cCampo == 'C7_X_TOTAL' // nPosTotal

		// C7_X_VLUNI
		aCols[n,nPosVlUni]	:= NoRound( _cInfo / aCols[n,nPosQuant] , TamSX3("C7_X_VLUNI")[2])
		
		// C7_PRECO
		aCols[n,nPosPreco]	:= NoRound( aCols[n,nPosVlUni] + aCols[n,nPosVlICM] 		, TamSX3("C7_PRECO")[2])
		If Positivo() .and. A120Preco(aCols[n,nPosPreco]) .And. MaFisRef("IT_PRCUNI","MT120",aCols[n,nPosPreco]) .AND. MTA121TROP(n)
			//				A120Preco(aCols[n,nPosPreco])
		Endif
		
		// C7_TOTAL
		aCols[n,nPosTotPC]	:= NoRound( aCols[n,nPosPreco] * aCols[n,nPosQuant] 		, TamSX3("C7_TOTAL")[2])
		
		lTodos := (aCols[n,nPosQuant] > 0 .and. aCols[n,nPosPeso] > 0 .and. aCols[n,nPosRend] > 0 .and. aCols[n,nPosArroV] > 0 .and. aCols[n,nPosToICM] > 0)
		
	ElseIf _cCampo == 'C7_X_VLICM' // nPosVlICM

		// C7_X_TOICM
		aCols[n,nPosToICM] := NoRound(  _cInfo * aCols[n,nPosQuant] , TamSX3("C7_X_TOICM")[2])

		// C7_PRECO
		aCols[n,nPosPreco]	:= NoRound( _cInfo + aCols[n,nPosVlUni] , TamSX3("C7_PRECO")[2])
		If Positivo() .and. A120Preco(aCols[n,nPosPreco]) .And. MaFisRef("IT_PRCUNI","MT120",aCols[n,nPosPreco]) .AND. MTA121TROP(n)
			// A120Preco(aCols[n,nPosPreco])
		Endif
			
		// C7_TOTAL
		aCols[n,nPosTotPC]	:= NoRound( aCols[n,nPosPreco] * aCols[n,nPosQuant] , TamSX3("C7_TOTAL")[2])
		
		lTodos := (aCols[n,nPosQuant] > 0 .and. aCols[n,nPosPeso] > 0 .and. aCols[n,nPosRend] > 0 .and. aCols[n,nPosArroV] > 0 .and. aCols[n,nPosToICM] > 0)
		
	ElseIf _cCampo == 'C7_X_TOICM' // nPosToICM

		// C7_X_VLICM: Calcula Valor ICMS Unit?rio (C7_X_VLICM)
		aCols[n,nPosVlICM] :=	NoRound( _cInfo / aCols[n,nPosQuant] , TamSX3("C7_X_VLICM")[2])
		
		// C7_PRECO
		aCols[n,nPosPreco]	:= NoRound( aCols[n,nPosVlUni] + aCols[n,nPosVlICM] , TamSX3("C7_PRECO")[2])
		If Positivo() .and. A120Preco(aCols[n,nPosPreco]) .And. MaFisRef("IT_PRCUNI","MT120",aCols[n,nPosPreco]) .AND. MTA121TROP(n)
			//				A120Preco(aCols[n,nPosPreco])
		Endif

		// C7_TOTAL
		aCols[n,nPosTotPC]	:= NoRound( aCols[n,nPosPreco] * aCols[n,nPosQuant] , TamSX3("C7_TOTAL")[2])
		
		lTodos := (aCols[n,nPosQuant] > 0 .and. aCols[n,nPosPeso] > 0 .and. aCols[n,nPosRend] > 0 .and. aCols[n,nPosArroV] > 0 .and. _cInfo > 0)
		
	EndIf

	If lTodos
		If ExistTrigger("C7_PRECO")
			RunTrigger(2,N) // ,nil,,'C7_PRECO')
		EndIf
	EndIf
EndIf
Return lRet
