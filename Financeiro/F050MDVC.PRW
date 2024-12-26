#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

   
/*	Ponto-de-Entrada: F050MDVC - Cálculo da data de vencimento de impostos
	Descrição: O ponto de entrada F050MDVC possibilita que o cliente calcule sua própria data de vencimento de ímpostos.
	ParamIxb[1]			Caracter			Imposto - (IRRF, PIS, COFINS, ...)										
	ParamIxb[2]			Data				Data de emissão do título principal										
	ParamIxb[3]			Data				E2_EMIS1 do título principal										
	ParamIxb[4]			Data				Data de vencimento do título principal										
	ParamIxb[5]			Data				Data de vencimento do imposto calculada pelo sistema.	 

	If ExistBlock("F050MDVC")
		dNextDay := ExecBlock("F050MDVC",.F.,.F.,{dNextDay,cImposto,dEmissao,dEmis1,dVencRea})
	EndIf                                                                            
	Para um melhor funcionamento deste P.E. com esta tratativa ajustar os Parametros abaixo:
	Retenção de PIS COFINS CSLL somente na primeira parcela da Nota Fiscal de Entrada
	MV_RATPIS = .F.
	MV_RATCOF = .F.
	MV_RATCSLL = .F.      
	*/

  
User Function F050MDVC()

Local dVencPR 		:= ParamIXB[1] // Data Vencto
Local cImposto 		:= ParamIXB[2] // Imposto - (IRRF, PIS, COFINS, ...)
Local dEmissao 		:= ParamIXB[3] // Data de emissão do título principal
Local dEmis1 		:= ParamIXB[4] // E2_EMIS1 do título principal
Local dVencRea 		:= ParamIXB[5] // Data de vencimento do imposto calculada pelo sistema.
Local dDtVenc 		:= ParamIXB[1] // provisorio (mantem a data original)

Local nK			:= 0
Local dNextDay 		:= Ctod("//")
Local nTamData 		:= 0
Local nNextMes 		:= 0
Local dDtQuinz 		:= Ctod("//")
Local lLei11196 	:= SuperGetMv("MV_VC11196",.T.,"2") == "1"
Local lMP447    	:= SuperGetMV("MV_MP447",.T.,.F.)
Local nIn480		:= SuperGetMV("MV_IN480",.T.,3)
Local cVencIRPF 	:= GetMv("MV_VCTIRPF",,"")
Local lAntMP351 	:= .F.
Local lVenctoIN  	:= (SuperGetMv("MV_VENCINS",.T.,"1") == "2")  //1 = Emissao    2= Vencimento Real
Local lVerIRBaixa	:= .F.
Local lEmpPublic	:= SuperGetMv("MV_ISPPUBL" ,.T.,"2") == "1" 
Local lINQuinz      := SuperGetMv("MV_IN4815" ,.T.,"Q") == "Q" // Situaçao gerada a partir do chamado SCWLG4, onde foi gerado o boletim tecnico "Vencimento do IRPJ - IN SRF 480"

dNextDay := dVencPR // mantendo data original para os demais impostos

If (alltrim(cImposto))$'PIS;COFINS;CSLL' 
	dVencRea := dEmissao 

	//Calculo da data de vencimento para titulos de PIS, COFINS e CSLL
	//Para o IR na Baixa, segue o mesmo conceito do PCC para o calculo.
	//Verifico se a baixa ou vencimento sao anteriores a Lei 10925 e
	//fato o calculo da data na forma antiga
	If dVencrea < SuperGetMv("MV_RF10925",.t.,CTOD("26/07/04"))
		dNextDay := dVencRea+1
		For nK:=1 To 7
			If Dow( dNextDay ) = 1
				Exit
			Endif
			dNextDay++
		Next
		For nK:= 1 to 3
			dNextDay := DataValida(dNextDay+1,.T.)
		Next
	Else
		
		//Calculo da data de vencimento do imposto a partir de 26/07/04 - Lei 10925
		nTamData := Iif(Len(Dtoc(dVencrea)) == 10, 7, 5)
		
		//Lei 11.196 - Vencimento do PIS COFINS e CSLL passa a ser no ultimo dia util da quinzena subsequente
		//para fatos geradores a partir de 01/01/06
		//Art. 74 que altera o art.35 da Lei 10833
		//Alterada pela MP 351 de 21/01/07, art 7 e sequintes:
		// O pagamento da Contribuição para o PIS/PASEP e da COFINS deverá ser efetuado ate o ultimo dia util do
		// segundo decendio subsequente ao mes de ocorrencia dos fatos geradores."
		
		
		//Calculo antigo para fatos geradores anteriores a vigencia da Lei ou para onde não se aplique
		If lVerIRBaixa .AND. (!lLei11196 .or. dVencRea < CTOD("01/01/06"))
			//Verifico a quizena do vencimento
			If Day(dVencRea) <= 15
				dDtQuinz := Ctod("15/"+Subs(Dtoc(dVencrea),4,nTamData))
				If Dow(dDtQuinz) == 1   //Se o dia 15 for domingo
					dNextDay := Ctod("27/"+Subs(Dtoc(dVencrea),4,nTamData))
				Else
					dNextDay := Ctod("21/"+Subs(Dtoc(dVencrea),4,nTamData))
				Endif
			Else                             
				nNextMes := Month(dVencRea)+1
				dDtQuinz := Ctod(Str(Day(LastDay(dVencRea)),2)+"/"+Subs(Dtoc(dVencrea),4,nTamData))
				If Dow(dDtQuinz) == 1   //Se o ultimo dia do mes for domingo
					dNextDay := CTOD("12/"+Iif(nNextMes==13,"01",StrZero(nNextMes,2))+"/"+;
					Substr(Str(Iif(nNextMes==13,Year(dVencRea)+1,Year(dVencRea))),2))
				Else
					dNextDay := CTOD("06/"+Iif(nNextMes==13,"01",StrZero(nNextMes,2))+"/"+;
					Substr(Str(Iif(nNextMes==13,Year(dVencRea)+1,Year(dVencRea))),2))
				Endif
			Endif
			
			//Acho a Sexta feira da semana subsequente
			nDiaSemana := Dow(dNextDay)
			If nDiaSemana < 6
				dNextDay += 6-nDiaSemana
			ElseIf nDiaSemana > 6
				dNextDay -= 1
			Endif
		ElseIf lLei11196 
			
			//Calculo com base na Lei 11196 art. 74
			//If Day(dVencRea) <= 15
			//	dNextDay := Ctod(Str(Day(LastDay(dVencRea)),2)+"/"+Subs(Dtoc(dVencrea),4,nTamData))
			//Else
				nNextMes := Month(dVencRea)+1 
				dNextDay := CTOD("20/"+Iif(nNextMes==13,"01",StrZero(nNextMes,2))+"/"+;
				Substr(Str(Iif(nNextMes==13,Year(dVencRea)+1,Year(dVencRea))),2)) 
			//Endif

		Endif
		
		//Acho o ultimo dia util do periodo desejado
		dNextday := DataValida(dNextday,.F.) 
	Endif
Endif

Return dNextday       

                 



