#Include "Protheus.ch"
#include "Tbiconn.ch"
#include "TopConn.ch"
#include "Totvs.ch"
// ###############################################################################################
// Projeto: 
// Fonte  : VAMNTM01.prw
// ---------+------------------------------------+------------------------------------------------
// Data     | Autor                              | Descricao
// ---------+------------------------------------+------------------------------------------------
//  28/02/22|  Manoel Filho                      | Painel Fechamento e Estorno dos Abastecimentos
// ---------+------------------------------------+------------------------------------------------
User Function VAMNTM01()

Local aObjects  := {} , aInfo := {}, aPos := {}
Local aSizeHalf := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local lWhen     := .t. // ver se existe alguma validação por Parâmetro ou Usuário


aInfo := { aSizeHalf[ 1 ], aSizeHalf[ 2 ],aSizeHalf[ 3 ] ,aSizeHalf[ 4 ], 3, 3 } // Tamanho total da tela
aAdd( aObjects, { 0 , 100 , .T. , .F. } ) // Topo
aPos := MsObjSize( aInfo, aObjects )

DEFINE MSDIALOG oDlg FROM aSizeHalf[7],0 TO aSizeHalf[6],aSizeHalf[5] TITLE "" OF oMainWnd PIXEL

@ aPos[1,1]+050,aPos[1,4]-360 BUTTON oFecha PROMPT "Fechamento" OF oDlg SIZE 65,20 PIXEL ACTION FS_Fechamento() WHEN lWhen
@ aPos[1,1]+100,aPos[1,4]-360 BUTTON oEstor PROMPT "Estorno"    OF oDlg SIZE 65,20 PIXEL ACTION U_VAMNTM02() WHEN lWhen
@ aPos[1,1]+150,aPos[1,4]-360 BUTTON oRelat PROMPT "Relatório"  OF oDlg SIZE 65,20 PIXEL ACTION U_VAMNTR02() WHEN lWhen
@ aPos[1,1]+200,aPos[1,4]-360 BUTTON oSair  PROMPT "Sair"       OF oDlg SIZE 65,20 PIXEL ACTION oDlg:End()

ACTIVATE MSDIALOG oDlg 


Return

/*/{Protheus.doc} FS_Fechamento
	Faz a chamada do levantamento e Fechamento dos Abastecmentos
	@author Manoel Filho
	@since 28/02/2022
/*/
Static Function FS_Fechamento()
Local aParamBox  := {}
Local aRet       := {}
Private dDatFec  := Ctod("")

aAdd(aParamBox,{1,"Data Fechamento",Ctod(""),"@D","","","",50,.f.})

While .t.
	If ParamBox(aParamBox,"",@aRet,,,,,,,,.F.)
		dDatFec  := aRet[1]
	Else
		Return .f.
	EndIf
	Exit
Enddo

oProcTTP := MsNewProcess():New({ |lEnd| FS_ProcFech() }," ","",.f.)
oProcTTP:Activate()

Return


/*/{Protheus.doc} FS_ProcFech
	Processa o levantamento e Fechamento dos Abastecmentos, gerando titulo no contas a pagar
	@type  Static Function
	@author Manoel Filho
	@since 28/02/2022
	@return 
/*/
Static Function FS_ProcFech()
Local cQuery     := ""
Local cSeq       := "1"
Local aVetInteg  := {}
Local aVetTemp   := {} 
Local nPosVet    := 0
Local nCntFor    := 0
Local nAtuTQN    := 0
Local aCtasPagar := {}
Local cNatureABT := GetMv("VA_NATABA",,"2158") // Natureza a Pagar do Titulo de Abastecimento
Local dDataVenc	 := dDataBase + GetMv("VA_DDVEAB",,0) // Dias para Vencimento do Titulo a Pagar de Abastecimento
Local cMsgFim    := ""
Local cHistorico := ""
Local nFQtdAbast := 0 // Qtd de Abastecimentos por Fornecedor
Local nFValAbast := 0 // Valor de Abastecimentos por Fornecedor
Local nTQtdAbast := 0 // Qtd Total de Abastecimentos 
Local nTValAbast := 0 // valor Total de Abastecimentos 
Local lPriVez    := .t. // utilizado na criação dos Sub-Totais do Extrato
Local nI         := 0

Private dDatPrxFec := GetMv("VA_DPRXFEC",,cTod("01/01/2021")) // Data do Proximo (inicial) Fechamento dos Abastecimentos // será atualizada a cada fechamento

// Le Abastecimentos do Periodo
If Select("TMPTQN") > 0
	TMPTQN->(dbCloseArea())
EndIf
	
cQuery := "SELECT TQN.TQN_FILIAL, TQN.TQN_FORST9, TQN.TQN_LOJST9, SA2.A2_NOME, TQN.TQN_CODCOM, TQM.TQM_NOMCOM, TQN.TQN_QUANT, TQN.TQN_NRABAS,TQN_VUNABA,TQN.TQN_VTTABA, TQN.R_E_C_N_O_ AS RECTQN "
cQuery += "  FROM "+RetSqlName("TQN")+" TQN "
cQuery += "  JOIN "+RetSqlName('ST9')+" ST9 ON ( ST9.T9_FILIAL = '"+xFilial("ST9")+ "' "
cQuery += "      AND ST9.T9_CODBEM = TQN.TQN_FROTA 
cQuery += "      AND ST9.T9_PROPRIE = '2' "
cQuery += "      AND ST9.D_E_L_E_T_ = ' ' )"
cQuery += "  JOIN "+RetSqlName("TQM")+" TQM ON ( TQM.TQM_FILIAL = '"+xFilial("TQM")+ "' "
cQuery += "      AND TQM.TQM_CODCOM = TQN.TQN_CODCOM "
cQuery += "  	 AND TQM.D_E_L_E_T_ = ' ' )"
cQuery += "  LEFT JOIN "+RetSqlName("SA2")+" SA2 ON ( SA2.A2_FILIAL = '"+xFilial("SA2")+ "' "
cQuery += "     AND SA2.A2_COD+SA2.A2_LOJA = TQN.TQN_FORST9+TQN.TQN_LOJST9 "
cQuery += "  	AND SA2.D_E_L_E_T_= ' ' ) "
cQuery += "    WHERE TQN.TQN_FILIAL='"+xFilial("TQN")+"' AND TQN.TQN_TITABA = '  ' AND TQN_FORST9 <> '   '"
cQuery += "      AND TQN.TQN_DTABAS BETWEEN '"+Dtos(dDatPrxFec)+"' AND '"+dTos(dDatFec) +"' AND TQN.D_E_L_E_T_ = ' '"
cQuery += " ORDER BY 1, 2, 4"
DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(cQuery)), "TMPTQN", .f., .f.)

oProcTTP:IncRegua1("Levantando Abastecimentos do Periodo ...")
oProcTTP:SetRegua2(1000)

While !TMPTQN->(Eof())

	oProcTTP:IncRegua2()

	// Cria SubTotais
	nPosVet := aScan(aVetInteg,{|x| x[1]+x[2] == TMPTQN->TQN_FORST9+TMPTQN->TQN_LOJST9})
	If nPosVet == 0

		If !lPriVez 

			If nFQtdAbast <> aVetInteg[Len(aVetInteg),6] // Esta condição serve para que só crie o Sub-Total para Fornecedores com mais de um Codigo de Combustivel
				// Linha do SubTotal
				aadd(aVetInteg,{;
					"", ; 
					"", ; 
					"Sub-Total - "+cFornec, ; 
					"", ; 
					"", ; 
					nFQtdAbast, ; 
					"", ; 
					nFValAbast/nFQtdAbasT, ; 
					nFValAbast, ; 
					1,;
					{0} })   
			endif

		Endif

		nFQtdAbast := TMPTQN->TQN_QUANT
		nFValAbast := TMPTQN->TQN_VTTABA 

		lPriVez := .f.

	Else

		nFQtdAbast += TMPTQN->TQN_QUANT
		nFValAbast += TMPTQN->TQN_VTTABA 

	Endif

	// 
	nPosVet := aScan(aVetInteg,{|x| x[1]+x[2]+x[4] == TMPTQN->TQN_FORST9+TMPTQN->TQN_LOJST9+TMPTQN->TQN_CODCOM})
	If nPosVet == 0

		aadd(aVetInteg,{;
			TMPTQN->TQN_FORST9, ; 
			TMPTQN->TQN_LOJST9, ; 
			TMPTQN->A2_NOME, ; 
			TMPTQN->TQN_CODCOM, ; 
			TMPTQN->TQM_NOMCOM, ; 
			TMPTQN->TQN_QUANT, ; 
			TMPTQN->TQN_NRABAS, ; 
			TMPTQN->TQN_VUNABA, ; 
			TMPTQN->TQN_VTTABA, ; 
			1,;
			{TMPTQN->RECTQN} })   

	Else

		aVetInteg[nPosVet,9] += TMPTQN->TQN_VTTABA
		aVetInteg[nPosVet,6] += TMPTQN->TQN_QUANT
		aVetInteg[nPosVet,10]++
		aadd(aVetInteg[nPosVet,11],TMPTQN->RECTQN) 
		aVetInteg[nPosVet,8] := aVetInteg[nPosVet,9]/aVetInteg[nPosVet,6]

	Endif

	nTQtdAbast += TMPTQN->TQN_QUANT
	nTValAbast += TMPTQN->TQN_VTTABA
	cFornec    := TMPTQN->A2_NOME

	DbSkip()

Enddo

// Linha do Total
aadd(aVetInteg,{;
	"", ; 
	"", ; 
	"Total Geral ", ; 
	"", ; 
	"", ; 
	nTQtdAbast, ; 
	"", ; 
	nTValAbast/nTQtdAbast, ; 
	nTValAbast, ; 
	1,;
	{0} })   

// Mostra Tela com os Registros levantados para o Fechamento
If FS_PodeFechar(aVetInteg)
	If !MsgYesNo("Deseja realmente gerar os Títulos?","Atenção")
		Return
	Endif
Else
	Return
Endif

aVetTemp  := aClone(aVetInteg)
aVetInteg := {}

For nCntFor := 1 to Len(aVetTemp)

	If Empty(aVetTemp[nCntFor,1])
		Loop
	Endif

	nPosVet := aScan(aVetInteg,{|x| x[1]+x[2] == aVetTemp[nCntFor,1]+aVetTemp[nCntFor,2]})
	If nPosVet == 0
		aadd(aVetInteg,{;
			aVetTemp[nCntFor,1] , ; 
			aVetTemp[nCntFor,2] , ; 
			aVetTemp[nCntFor,3] , ; 
			aVetTemp[nCntFor,4] , ; 
			aVetTemp[nCntFor,5] , ; 
			aVetTemp[nCntFor,6] , ; 
			aVetTemp[nCntFor,7] , ; 
			aVetTemp[nCntFor,8] , ; 
			aVetTemp[nCntFor,9] , ; 
			1,;
			aVetTemp[nCntFor,11] })   
	Else
		aVetInteg[nPosVet,9] += aVetTemp[nCntFor,9]
		aVetInteg[nPosVet,6] += aVetTemp[nCntFor,6]
		aVetInteg[nPosVet,10]++
		aVetInteg[nPosVet,8] := aVetInteg[nPosVet,9]/aVetInteg[nPosVet,6]
		For nI := 1 to Len(aVetTemp[nCntFor,11])
			aadd(aVetInteg[nPosVet,11],aVetTemp[nCntFor,11,nI]) 
		Next
	Endif

Next

// Gera Contas a Pagar
oProcTTP:IncRegua1("Gerando Titulos a Pagar ...")
oProcTTP:SetRegua2(1000)

Begin Transaction

For nCntFor := 1 to Len(aVetInteg)

	oProcTTP:IncRegua2()

	If Select("TMPSE2") > 0
		TMPSE2->(dbCloseArea())
	EndIf
		
	cQuery := "SELECT SE2.E2_NUM "
	cQuery += "  FROM "+RetSqlName("SE2")+" SE2 "
	cQuery += "    WHERE SE2.E2_FILIAL='"+xFilial("SE2")+"' AND SubsTring(SE2.E2_NUM,1,8) = '"+dTos(dDatFec)+"' AND SE2.E2_TIPO = 'ABT'"
	cQuery += "      AND SE2.E2_FORNECE='"+aVetInteg[nCntFor,1]+"' AND SE2.E2_LOJA='"+aVetInteg[nCntFor,2]+"' AND SE2.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY 1 DESC"

	DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(cQuery)), "TMPSE2", .f., .f.)

	If !TMPTQN->(Eof())
		cSeq := Alltrim(Str(Val(Right(TMPTQN->E2_NUM,1)) + 1))
	Endif
	TMPSE2->(dbCloseArea())

	DbSelectArea("SE2")
	
	cHistorico := "REF. A "+Transform(aVetInteg[nCntFor,10],'@E 999999') + " ABASTECIMENTO(S) EM VEÍCULO(S) DE TERCEIRO(S)"

	aCtasPagar := {}
	aAdd(aCtasPagar, {"E2_PREFIXO"	,"ABT"      		 , Nil} )
	aAdd(aCtasPagar, {"E2_NUM"     ,dTos(dDatFec)+cSeq   , Nil} )
	aAdd(aCtasPagar, {"E2_TIPO"    ,"NDF"   	         , Nil} )
	aAdd(aCtasPagar, {"E2_PARCELA"	,"  "	             , Nil} )
	aAdd(aCtasPagar, {"E2_NATUREZ" ,cNatureABT           , Nil} )
	aAdd(aCtasPagar, {"E2_FORNECE" ,aVetInteg[nCntFor,1] , Nil} )
	aAdd(aCtasPagar, {"E2_LOJA"    ,aVetInteg[nCntFor,2] , Nil} )
	aAdd(aCtasPagar, {"E2_EMISSAO" ,dDataBase            , Nil} )
	aAdd(aCtasPagar, {"E2_VENCTO"  ,dDataVenc			 , Nil} )
	aAdd(aCtasPagar, {"E2_VALOR"   ,aVetInteg[nCntFor,9] , Nil} )
	aAdd(aCtasPagar, {"E2_VLCRUZ"  ,aVetInteg[nCntFor,9] , Nil} )
	aAdd(aCtasPagar, {"E2_HIST"    ,cHistorico           , Nil} )
	aAdd(aCtasPagar, {"E2_ORIGEM"  ,"VAMNTM01"      	 , Nil} )

	lMsErroAuto := .f.

	pergunte("FIN050",.F.)
	MSExecAuto({|x,Y,Z| FINA050(X,Y,Z)},aCtasPagar,,3)

	If lMsErroAuto
		DisarmTransaction()
		MostraErro()
		Return .f.
	EndIf

	// Atualiza Campo Titulo da Tabela de Abastecimentos
	DbSelectArea("TQN")
	For nAtuTQN := 1 to Len(aVetInteg[nCntFor,11])

		DbGoTo(aVetInteg[nCntFor,11,nAtuTQN])

		RecLock("TQN", .f.)
		TQN->TQN_TITABA := SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO
		TQN->TQN_DTFABA := dDatFec
		MsUnlock()
		if !SE2->E2_FORNECE+" "+SE2->E2_LOJA $ cMsgFim
			cMsgFim += SE2->E2_PREFIXO+"-"+SE2->E2_NUM+"  -  Fornecedor "+SE2->E2_FORNECE+" "+SE2->E2_LOJA+CRLF
		Endif

	Next

Next

End Transaction

If !Empty(cMsgFim)
	MsgInfo("Titulos gerados com Sucesso!"+CRLF+CRLF+cMsgFim,"Atenção")
	// Atualiza Data do Proximo Fechamento
	DbSelectArea("SX6")
	DbSetOrder(1)
	If DbSeek(xFilial("SX6")+"VA_DPRXFEC")
		RecLock("SX6",.f.)
		SX6->X6_CONTEUD := dToc(dDatFec)
		MsUnLock()
	Endif
Endif

Return.t.

/*/{Protheus.doc} FS_Podefechar
	Tela que mostra os registros levantados para o Fechamento
	@type  Static Function
	@author Manoel Filho
	@since 09/03/2022
	@return 
/*/
Static Function FS_PodeFechar(aVetTel)
Local aObjects := {} , aPosObj := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nOpca    := 0
Local oFont    := TFont():New( "System", 25, 60 )

AAdd( aObjects, { 0, 90, .T., .T. } )  // ListBox
AAdd( aObjects, { 0, 10, .T., .F. } )  // Rodapé
aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
aPosObj := MsObjSize (aInfo, aObjects,.F.)

DEFINE MSDIALOG oDlgTelFec TITLE "Fechamento dos Abastecimentos" From aSizeAut[7],000 TO aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL 

// LISTBOX
oLbTelFec := TWBrowse():New( aPosObj[1,1], aPosObj[1,2], aPosObj[1,4]-2, aPosObj[1,3]-20,,,, oDlgTelFec,,,,,,,,,,,,.F.,,.T.,,.F.,,, )
oLbTelFec:addColumn( TCColumn():New( "Fornecedor"  , { ||     aVetTel[oLbTelFec:nAt,1]          } ,,,,"LEFT" ,040,.F.,.F.,,,,.F.,) )
oLbTelFec:addColumn( TCColumn():New( "Loja"        , { ||     aVetTel[oLbTelFec:nAt,2]          } ,,,,"LEFT" ,020,.F.,.F.,,,,.F.,) )
oLbTelFec:addColumn( TCColumn():New( "Nome"        , { ||     aVetTel[oLbTelFec:nAt,3]          } ,,,,"LEFT" ,100,.F.,.F.,,,,.F.,) )
oLbTelFec:addColumn( TCColumn():New( "Combustivel" , { ||     aVetTel[oLbTelFec:nAt,4]          } ,,,,"LEFT" ,040,.F.,.F.,,,,.F.,) )
oLbTelFec:addColumn( TCColumn():New( "Descrição"   , { ||     aVetTel[oLbTelFec:nAt,5]          } ,,,,"LEFT" ,100,.F.,.F.,,,,.F.,) )
oLbTelFec:addColumn( TCColumn():New( "Qtd Abastec" , { ||     Iif(!Empty(aVetTel[oLbTelFec:nAt,1]),FG_AlinVlrs(Transform(aVetTel[oLbTelFec:nAt,10],"@E 999")),"")         } ,,,,"LEFT",040,.F.,.F.,,,,.F.,) )
oLbTelFec:addColumn( TCColumn():New( "Qtd Litros"  , { ||     FG_AlinVlrs(Transform(aVetTel[oLbTelFec:nAt,6],"@E 99,999,999.999"))    } ,,,,"LEFT" ,060,.F.,.F.,,,,.F.,) )
oLbTelFec:addColumn( TCColumn():New( "Prç Médio Lt", { ||     FG_AlinVlrs(Transform(aVetTel[oLbTelFec:nAt,8],"@E 9999.999"))     } ,,,,"LEFT" ,050,.F.,.F.,,,,.F.,) )
oLbTelFec:addColumn( TCColumn():New( "Valor Total" , { ||     FG_AlinVlrs(Transform(aVetTel[oLbTelFec:nAt,9],"@E 99,999,999.999"))  } ,,,,"LEFT" ,060,.F.,.F.,,,,.F.,) )
oLbTelFec:SetArray(aVetTel)

@ aPosObj[2,1],10  SAY "Periodo: " + dToc(dDatPrxFec) + " a " + dToc(dDatFec) SIZE 450,20 FONT oFont OF oDlgTelFec PIXEL COLOR CLR_BLUE

@ aPosObj[2,1],aPosObj[1,4]-180 BUTTON oOk PROMPT "Gerar Título" OF oDlgTelFec SIZE 100,10 PIXEL ACTION (nOpca := 1,oDlgTelFec:End())

@ aPosObj[2,1],aPosObj[1,4]-050 BUTTON oSair PROMPT "Sair" OF oDlgTelFec SIZE 045,10 PIXEL ACTION (nOpca := 0,oDlgTelFec:End()) // SAIR

ACTIVATE MSDIALOG oDlgTelFec CENTER

If nOpca == 1
	Return(.t.) 
Else'
	Return(.f.) 
Endif
