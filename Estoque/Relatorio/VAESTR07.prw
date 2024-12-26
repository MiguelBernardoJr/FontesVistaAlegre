#include "TOTVS.CH"
#include "TOPCONN.CH"

/*/{Protheus.doc} VaEstR07
Imprime o termo de Termo de Responsabilidade sobre Produtos.
@author Renato de Bianchi
@since 25/10/2017
@version undefined
@param lValida, logical, O termo só pode ser impresso para Requisições baixadas.
@type function
/*/
User Function VaEstR07(lValida)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local wnrel
// Local tamanho		:= "G"
Local titulo		:= "Termo de Responsabilidade sobre Produtos"
Local cDesc1		:= "Impressão do Termo de Responsabilidade sobre Produtos"
Local cDesc2		:= "Verificar se data base é a mesma da solicitacao ao armazém"
// Local cDesc3		:= " "
Local cTitulo		:= ""
Local cErro			:= ""
Local cSolucao		:= ""                         

Local lPrinter		:= .T.
Local lOk			:= .F.
Local aSays     	:= {}, aButtons := {}, nOpca := 0

Private nomeprog 	:= "RESTR001"
Private nLastKey 	:= 0
Private cPerg

Private oPrint

Default lValida := .F.

if lValida
	if Empty(SCP->CP_STATUS) .or. SCP->CP_PREREQU != "S"
		msgAlert("O termo só pode ser impresso para Requisições baixadas.")
		return nil
	endIf
endIf

cString := "SF2"
wnrel   := "VAESTR07"
cPerg   := "VAER07"

//AjustaSX1()
//Pergunte(cPerg,.F.)

AADD(aSays,cDesc1) 
AADD(aSays,cDesc2)
//AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
AADD(aButtons, { 1,.T.,{|| nOpca := 1, FechaBatch() }} )
AADD(aButtons, { 2,.T.,{|| nOpca := 0, FechaBatch() }} )  

FormBatch( Titulo, aSays, aButtons,, 160 )

If nOpca == 0
   Return
EndIf   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Configuracoes para impressao grafica³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oPrint := TMSPrinter():New(titulo)		
oPrint:SetPortrait()					// Modo retrato
oPrint:SetPaperSize(9)					// Papel A4

// Inserido por Michel A. Sander (Fictor) em 07.02.12 para tratar o codigo de barras
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Configuracoes para codigo de barras ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aFontes := "Arial"//"Courier New"

If nLastKey = 27
	dbClearFilter()
	Return
Endif

RptStatus({|lEnd| PrintRel(@lEnd,wnRel,cString)},Titulo)

oPrint:Preview()  		// Visualiza impressao grafica antes de imprimir

Return

//Função de preparação para a impressão
Static Function PrintRel(lEnd,wnRel,cString)

Local aAreaRPS		:= {}
Local aPrintServ	:= {}
Local aPrintObs		:= {}
                            
Local cTime			:= "" 
Local cLogo			:= ""
Local cAlias		:= "QRYREL"
Local cCampos		:= ""     

Local nValDed		:= 0
Local nCopias		:= 2
Local nX			:= 1
Local nY			:= 1

Local nTamLim		:= 38
Local nLinIni		:= 100  
Local nColIni		:= 225
Local nColFim		:= 2225
Local nLinFim		:= 3250
Local nLinha		:= 0

Local oFont8 	:= TFont():New(aFontes,06,06,,.F.,,,,.T.,.F.)
Local oFont10 	:= TFont():New(aFontes,08,08,,.F.,,,,.T.,.F.)	//Normal s/negrito
Local oFont10n	:= TFont():New(aFontes,08,08,,.T.,,,,.T.,.F.)	//Negrito
Local oFont11 	:= TFont():New(aFontes,09,09,,.F.,,,,.T.,.F.)	//Normal s/negrito
Local oFont12	:= TFont():New(aFontes,10,10,,.F.,,,,.T.,.F.)	//Negrito
Local oFont12n	:= TFont():New(aFontes,10,10,,.T.,,,,.T.,.F.)	//Negrito

Local cQuery    := "" 

dbSelectArea("SF3")
dbSetOrder(6)
	
		BeginSql Alias cAlias
			// SELECT DISTINCT // D3_MATRI, D3_NOME, 
			// 	   RA_MAT, RA_NOME
			// 	 , D3_CODCA, D3_COD, B1_DESC, D3_EMISSAO, D3_QUANT
			//      , B1_DESC
			//      , CTT_DESC01 RA_SETOR, RJ_DESC RA_CARGO
			// FROM %table:SD3% SD3
			// 	 JOIN %table:SCP% SCP on CP_FILIAL=D3_FILIAL AND CP_NUM=D3_NUMSA AND SCP.%notDel%
			// LEFT JOIN %table:SRA% SRA on SRA.RA_FILIAL=%xFilial:SRA% and SRA.%notDel% and RA_MAT=CP_MATRI
			//      JOIN %table:SB1% SB1 on SB1.B1_FILIAL=%xFilial:SB1% and SB1.%notDel% and SB1.B1_COD=SD3.D3_COD // AND SB1.B1_GRUPO='018')
			// LEFT JOIN %table:SRJ% SRJ on SRJ.RJ_FILIAL=%xFilial:SRJ% and SRJ.%notDel% and RJ_FUNCAO=RA_CODFUNC
			// LEFT JOIN %table:CTT% CTT on CTT.CTT_FILIAL=%xFilial:CTT% and CTT.%notDel% and CTT_CUSTO=RA_CC
			// 	
			// WHERE SD3.D3_FILIAL = %xFilial:SD3% 
			//   AND SD3.D3_NUMSA=%exp:SCP->CP_NUM%
			//   AND SD3.D3_ESTORNO=' '
			//   // AND SD3.D3_EMISSAO = %exp:dToS(dDatabase)% 	
			//   AND SD3.%NotDel%
			// ORDER BY SD3.D3_COD

			SELECT DISTINCT RA_MAT,RA_NOME
						, CP_PRODUTO
						,B1_DESC
						, CP_EMISSAO, CP_QUANT, CP_CODCA
						,CTT_DESC01 RA_SETOR,RJ_DESC RA_CARGO 
			FROM SCP010 SCP
			LEFT JOIN SRA010 SRA ON SRA.RA_FILIAL= %xFilial:SRA% 
								AND RA_MAT=CP_MATRI 
								AND SRA.D_E_L_E_T_= ' ' 
			JOIN SB1010 SB1 ON SB1.B1_FILIAL=%xFilial:SB1% AND SB1.D_E_L_E_T_= ' ' AND SB1.B1_COD=CP_PRODUTO
			LEFT JOIN SRJ010 SRJ ON SRJ.RJ_FILIAL=%xFilial:SRJ% AND SRJ.D_E_L_E_T_= ' ' 
								AND RJ_FUNCAO=RA_CODFUNC 
			LEFT JOIN CTT010 CTT ON CTT.CTT_FILIAL=%xFilial:CTT%  AND CTT.D_E_L_E_T_= ' ' AND CTT_CUSTO=RA_CC 
			WHERE    CP_FILIAL = %xFilial:SCP%
				AND CP_NUM = %exp:SCP->CP_NUM%
			AND SCP.D_E_L_E_T_= ' ' 
			ORDER BY  CP_PRODUTO

		EndSql
		
		MemoWrite("C:\totvs_relatorios\VaEstR07.sql" , GetLastQuery()[2])

		nRegs := 0
		dbSelectArea(cAlias)
		while !(cAlias)->(Eof())
			nRegs++
			(cAlias)->(DbSkip())
		endDo
		if nRegs > 0
			(cAlias)->(DbGoTop())
		endIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime os RPS gerados de acordo com o numero de copias selecionadas³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
if (cAlias)->(!Eof())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Relatorio Grafico:                                                                                      ³
	//³* Todas as coordenadas sao em pixels	                                                                   ³
	//³* oPrint:Line - (linha inicial, coluna inicial, linha final, coluna final)Imprime linha nas coordenadas ³
	//³* oPrint:Say(Linha,Coluna,Valor,Picture,Objeto com a fonte escolhida)		                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	For nX := 1 to nCopias
        (cAlias)->(DbGoTop())
		//Aqui entra a função customizada do layout
		//oPrint:Say(nLinIni-50,nColIni+300,Alltrim("DANFSE - DOCUMENTO AUXILIAR DA NOTA FISCAL DE SERVIÇOS ELETRÔNICA"),oFont12n)
		
		//-----------------------------------------
		// Box no tamanho do RPS
		//-----------------------------------------
		/*oPrint:Line(nLinIni,nColIni,nLinIni,nColFim)
		oPrint:Line(nLinIni,nColIni,nLinFim,nColIni)		
		oPrint:Line(nLinIni,nColFim,nLinFim,nColFim)
		oPrint:Line(nLinFim,nColIni,nLinFim,nColFim)*/
		if nX = 1 .or. nRegs > 5 // 10 // MJ : 31/07/2018 pular linha qdo mais de 5 produtos
			if nX > 1
				//If nCopias > 1 .And. nX < nCopias
				oPrint:EndPage()
				//Endif
			endIf
			
			nLinIni := 100
		else
			nLinIni := (nLinFim/2)+nTamLim*6		
		endIf
		nLinha := nLinIni+nTamLim
		
		//-----------------------------------------
		// Dados da empresa emitente do documento
		//-----------------------------------------
		cLogo := "\system\lgrl" + AllTrim(cEmpAnt) + ".bmp" //FisxLogo("1") 
		//cLogo := "LGRL"+cEmpAnt+".BMP"
		oPrint:SayBitmap(nLinha-15,nColIni+25,cLogo,240,150)
		oPrint:Say(nLinha,nColIni+300,Alltrim(SM0->M0_NOMECOM),oFont12n)
		oPrint:Say(nLinha+=nTamLim,nColIni+300,Alltrim(SM0->M0_ENDENT)+" - "+Alltrim("Fone:") + Transform(SM0->M0_TEL,"@R (18) 99999-9999)")/*Alltrim(SM0->M0_TEL)*/ + " - " + Alltrim(SM0->M0_CIDENT) + " - " +  Alltrim(SM0->M0_ESTENT),oFont10n)
		nLinha += nTamLim
		oPrint:Line(nLinha,nColIni+300,nLinha,nColFim-240)
		nLinha += nTamLim/4
		oPrint:Say(nLinha,nColIni+300,"C.N.P.J. " + Transform(SM0->M0_CGC,"@R 99.999.999/9999-99") + space(30) + "Inscrição Estadual " + Transform(SM0->M0_INSC,"@R 999.999.9999.99"/*Alltrim(SM0->M0_INSC*/),oFont10)
  		
  		oPrint:Line(nLinIni,nColFim-240,nLinha+nTamLim,nColFim-240)
		
		//nLinha += nTamLim
		oPrint:Say(nLinha - nTamLim*3,nColFim-200,"   FICHA",oFont10n)
		oPrint:Say(nLinha - nTamLim*2,nColFim-220,"DE CONTROLE",oFont10n)
		oPrint:Say(nLinha - nTamLim  ,nColFim-210,"DE ENTREGA",oFont10n)
		oPrint:Say(nLinha  			 ,nColFim-200,"  DE EPI",oFont10n)
		
		nLinha += nTamLim
		oPrint:Line(nLinha,nColIni,nLinha,nColFim)
		
		nLinha += nTamLim
		oPrint:Say(nLinha,nColIni,PadC(Alltrim("TERMO DE RESPONSABILIDADE"),170),oFont12n)
		
		nColDiv1 := nColFim/2
		nColDiv2 := nColDiv1+(nColDiv1/2)
		
		nLinha += nTamLim*1.5
		oPrint:Line(nLinha,nColIni,nLinha,nColFim)
		oPrint:Line(nLinha,nColIni,nLinha+nTamLim*2,nColIni)
		oPrint:Line(nLinha,nColFim,nLinha+nTamLim*2,nColFim)
		oPrint:Line(nLinha,nColDiv1,nLinha+nTamLim*2,nColDiv1)
		oPrint:Line(nLinha,nColDiv2,nLinha+nTamLim*2,nColDiv2)
		oPrint:Line(nLinha+nTamLim*2,nColIni,nLinha+nTamLim*2,nColFim)
		
		nLinha += nTamLim/4
		oPrint:Say(nLinha,nColIni+10,Alltrim("Nome:"),oFont10)
		oPrint:Say(nLinha,nColDiv1+10,Alltrim("Setor:"),oFont10)
		oPrint:Say(nLinha,nColDiv2+10,Alltrim("Cargo:"),oFont10)
		
		nLinha += nTamLim/1.5
		oPrint:Say(nLinha,nColIni+10,(cAlias)->RA_NOME,oFont12n)
		oPrint:Say(nLinha,nColDiv1+10,(cAlias)->RA_SETOR,oFont12n)
		oPrint:Say(nLinha,nColDiv2+10,(cAlias)->RA_CARGO,oFont12n)
		
		nLinha += nTamLim
		oPrint:Say(nLinha+=nTamLim,nColIni+10,"Declaro sob minha responsabilidade a guarda e conservação dos Equipamentos de Proteção Individual (EPI).",oFont12)
		oPrint:Say(nLinha+=nTamLim,nColIni+10,"Assumo também a responsabilidade de devolve-los integralmente ou parcialmente quando solicitado ou por ocasião de",oFont12)
		oPrint:Say(nLinha+=nTamLim,nColIni+10,"eventual rescisão de contrato na data do respectivo aviso de qualquer das partes.",oFont12)
		oPrint:Say(nLinha+=nTamLim,nColIni+10,"Também estou ciente que o uso do equipamento (EPI) é obrigatório, e na eventualidade de danificar ou extraviar o equipa-",oFont12)
		oPrint:Say(nLinha+=nTamLim,nColIni+10,"mento por ato doloso ou culposo, estarei sujeito ao desconto do valor do mesmo em meu salário, conf. artigo 158 da CLT.",oFont12)
		oPrint:Say(nLinha+=nTamLim,nColIni+10,"Assim sendo, estou ciente que sofrerei as seguintes sanções por parte do Empregador POR NÃO USAR OS EPIs.",oFont12n)
		
		nLinha += nTamLim*4
		oPrint:Say(nLinha+nTamLim,nColIni-80,PadC(Alltrim("____/____/________"),50),oFont12n)
		oPrint:Say(nLinha+nTamLim*2,nColIni-80,PadC(Alltrim("DATA"),60),oFont12n) 

		oPrint:Say(nLinha+nTamLim,nColDiv1-340,PadC(Alltrim("__________________________________"),50),oFont12n)
		oPrint:Say(nLinha+nTamLim*2,nColDiv1-340,PadC(Alltrim("Assinatura do Empregado"),60),oFont12n)
		
		oPrint:Say(nLinha+nTamLim,nColDiv1+340,PadC(Alltrim("__________________________________"),50),oFont12n)
		oPrint:Say(nLinha+nTamLim*2,nColDiv1+340,PadC(Alltrim("Técnico / Engenheiro Responsável"),60),oFont12n)

		nColDiv1 := nColIni//+580
		nColDiv2 := nColDiv1+400//+300
		nColDiv3 := nColDiv2+300//+200
		nColDiv4 := nColDiv3+250//+150
		nColDiv5 := nColDiv4+420//+320
		
		nLinha += nTamLim*4
		oPrint:Line(nLinha,nColIni,nLinha,nColFim)
		oPrint:Line(nLinha,nColIni,nLinha+nTamLim*1.5,nColIni)
		oPrint:Line(nLinha,nColFim,nLinha+nTamLim*1.5,nColFim)
		oPrint:Line(nLinha+nTamLim*1.5,nColIni,nLinha+nTamLim*1.5,nColFim)
		
		nLinha += nTamLim/4
		oPrint:Say(nLinha,nColIni+10,Alltrim("Equipamento Recebido"),oFont12n)
		
		nLinha += nTamLim*1.5 - nTamLim/4
		oPrint:Line(nLinha,nColIni,nLinha,nColFim)
		oPrint:Line(nLinha,nColIni,nLinha+nTamLim*1.5,nColIni)
		oPrint:Line(nLinha,nColFim,nLinha+nTamLim*1.5,nColFim)
		oPrint:Line(nLinha,nColDiv1,nLinha+nTamLim*1.5,nColDiv1)
		oPrint:Line(nLinha,nColDiv2,nLinha+nTamLim*1.5,nColDiv2)
		oPrint:Line(nLinha,nColDiv3,nLinha+nTamLim*1.5,nColDiv3)
		oPrint:Line(nLinha,nColDiv4,nLinha+nTamLim*1.5,nColDiv4)
		oPrint:Line(nLinha,nColDiv5,nLinha+nTamLim*1.5,nColDiv5)
		oPrint:Line(nLinha+nTamLim*1.5,nColIni,nLinha+nTamLim*1.5,nColFim)
		
		nLinha += nTamLim/4
		oPrint:Say(nLinha,nColDiv1+10,Alltrim("Data de Entrega"),oFont12n)
		oPrint:Say(nLinha,nColDiv2+10,Alltrim("C.A."),oFont12n)
		oPrint:Say(nLinha,nColDiv3+10,Alltrim("Qtde."),oFont12n)
		oPrint:Say(nLinha,nColDiv4+10,Alltrim("Devolvido em"),oFont12n)
		oPrint:Say(nLinha,nColDiv5+10,Alltrim("Assinatura"),oFont12n)
		
		//nLinha -= nTamLim/4
		
		(cAlias)->(dbGoTop())
		while !(cAlias)->(Eof())
			
			//ProcRegua()
			If Interrupcao(@lEnd)
			    Exit
		 	Endif
			
			nLinha += nTamLim*1.5
			oPrint:Line(nLinha,nColIni,nLinha,nColFim)
			oPrint:Line(nLinha,nColIni,nLinha+nTamLim*1.5,nColIni)
			oPrint:Line(nLinha,nColFim,nLinha+nTamLim*1.5,nColFim)
			oPrint:Line(nLinha+nTamLim*1.5,nColIni,nLinha+nTamLim*1.5,nColFim)
			
			nLinha += nTamLim/4
			oPrint:Say(nLinha,nColIni+10,Alltrim((cAlias)->B1_DESC),oFont10)
			
			nLinha += nTamLim*1.5 - nTamLim/4
			oPrint:Line(nLinha,nColIni,nLinha,nColFim)
			oPrint:Line(nLinha,nColIni,nLinha+nTamLim*1.5,nColIni)
			oPrint:Line(nLinha,nColFim,nLinha+nTamLim*1.5,nColFim)
			oPrint:Line(nLinha,nColDiv1,nLinha+nTamLim*1.5,nColDiv1)
			oPrint:Line(nLinha,nColDiv2,nLinha+nTamLim*1.5,nColDiv2)
			oPrint:Line(nLinha,nColDiv3,nLinha+nTamLim*1.5,nColDiv3)
			oPrint:Line(nLinha,nColDiv4,nLinha+nTamLim*1.5,nColDiv4)
			oPrint:Line(nLinha,nColDiv5,nLinha+nTamLim*1.5,nColDiv5)
			oPrint:Line(nLinha+nTamLim*1.5,nColIni,nLinha+nTamLim*1.5,nColFim)
			
			nLinha += nTamLim/4
			oPrint:Say(nLinha,nColDiv1+10,dToC(sToD((cAlias)->CP_EMISSAO)),oFont10)
			oPrint:Say(nLinha,nColDiv2+15, Alltrim((cAlias)->CP_CODCA) ,oFont10n)
			oPrint:Say(nLinha,nColDiv3+15,transform((cAlias)->CP_QUANT,"@E 9,999,999.99"),oFont10)
			oPrint:Say(nLinha,nColDiv4+10,space(1),oFont10)
			oPrint:Say(nLinha,nColDiv5+10,space(1),oFont10)
			
			//nLinha -= nTamLim/4
			
			(cAlias)->(dbSkip())
		endDo
		
		/*
		oPrint:FillRect( {nLinha+2, nColIni+2, nLinha+nTamLim*2, nColDiv1}, oBrush1 )
		oPrint:FillRect( {nLinha+2, nColDiv2+2, nLinha+nTamLim*2, nColDiv3}, oBrush1 )
		*/
		
	Next
	
	If !((cAlias)->(Eof()))
		oPrint:EndPage()
	Endif       
EndIf                 

dbSelectArea(cAlias)
dbCloseArea()

return
