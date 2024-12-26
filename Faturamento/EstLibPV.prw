#include "TOTVS.CH"
#include "topconn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ESTLIBPV  ºAutor  ³Cristiam Rossi      º Data ³  18/01/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Estorno Liberação de Pedido de Vendas                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Central Ar                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function EstLibPV(cPedido, cOpc)
Local   aArea       := GetArea()
Local   lRet        := .T.
Local   aCabPV      := {}
Local   aItemPV     := {}
Local   aItemTMP    := {}
Default cPedido     := ""
Default cOpc        := "T"	// T=Estorna e Libera novamente; E=Estorna; L=Libera
Private lMsErroAuto := .F.

	if Empty(cPedido)
		Aviso("Sem parâmetro pedido","Favor informar o Pedido de Vendas",{"Ok"})
		Return .F.
	endif

	SC5->(dbSetOrder(1))
	if ! SC5->( dbSeek( xFilial('SC5') + cPedido ) )
		Aviso("Pedido não encontrado","Favor verifique o Pedido de Vendas "+cPedido+", não foi encontrado!",{"Ok"})
		Return .F.
	endif

	if cOpc != 'L'	// Estorna e Libera ou só Estorna

		//Cabecalho
		aCabPV:={{"C5_NUM"    ,cPedido         ,Nil},; // Numero do pedido
		         {"C5_TIPO"   ,SC5->C5_TIPO    ,Nil},; // Tipo de pedido
		         {"C5_CLIENTE",SC5->C5_CLIENTE ,Nil},; // Codigo do cliente
		         {"C5_LOJACLI",SC5->C5_LOJACLI ,Nil},; // Loja do cliente
		         {"C5_CLIENT" ,SC5->C5_CLIENT  ,Nil},; // Codigo do cliente
		         {"C5_LOJAENT",SC5->C5_LOJAENT ,Nil},; // Loja para entrada
		         {"C5_TIPOCLI",SC5->C5_TIPOCLI ,Nil},; // Loja para entrada         
		         {"C5_EMISSAO",SC5->C5_EMISSAO ,Nil},; // Data de emissao
		         {"C5_CONDPAG",SC5->C5_CONDPAG ,Nil},; // Codigo da condicao de pagamanto*
		         {"C5_VEND1"  ,SC5->C5_VEND1   ,Nil},; // Codigo da condicao de pagamanto*         
		         {"C5_TPFRETE",SC5->C5_TPFRETE ,Nil},;          
		         {"C5_TIPLIB" ,SC5->C5_TIPLIB  ,Nil},; // Tipo de Liberacao
		         {"C5_MOEDA"  ,SC5->C5_MOEDA   ,Nil},; // Moeda
		         {"C5_TXMOEDA",SC5->C5_TXMOEDA ,Nil},; // Moeda         
		         {"C5_TPCARGA",SC5->C5_TPCARGA ,Nil}}  
		
	
		SC6->(dbSetOrder(1))
		SC6->( dbSeek( xFilial('SC6') + cPedido, .T. ) )
	
		While ! SC6->( EOF() ) .and. SC6->C6_FILIAL == SC5->C5_FILIAL .and. SC6->C6_NUM == cPedido
	    
			//Items
			aItemTMP := {}
			AAdd(aItemTMP,{"C6_NUM"    ,cPedido         ,Nil})
			AAdd(aItemTMP,{"C6_ITEM"   ,SC6->C6_ITEM    ,Nil})
			AAdd(aItemTMP,{"C6_PRODUTO",SC6->C6_PRODUTO ,Nil})
			AAdd(aItemTMP,{"C6_QTDVEN" ,SC6->C6_QTDVEN  ,Nil})
			AAdd(aItemTMP,{"C6_QTDLIB" , 0              ,Nil})
			AAdd(aItemTMP,{"C6_QTDLIB2", 0              ,Nil})
			AAdd(aItemTMP,{"C6_PRCVEN" ,SC6->C6_PRCVEN  ,Nil})
			AAdd(aItemTMP,{"C6_VALOR"  ,SC6->C6_VALOR   ,Nil})
			AAdd(aItemTMP,{"C6_ENTREG" ,SC6->C6_ENTREG  ,Nil})
			AAdd(aItemTMP,{"C6_UM"     ,SC6->C6_UM      ,Nil})
			AAdd(aItemTMP,{"C6_TES"    ,SC6->C6_TES     ,Nil})
			AAdd(aItemTMP,{"C6_LOCAL"  ,SC6->C6_LOCAL   ,Nil})
			AAdd(aItemTMP,{"C6_CLI"    ,SC6->C6_CLI     ,Nil})
			AAdd(aItemTMP,{"C6_LOJA"   ,SC6->C6_LOJA    ,Nil})
			AAdd(aItemTMP,{"C6_LOTECTL",SC6->C6_LOTECTL ,Nil})

			AAdd(aItemPV, AClone(aItemTMP))
			SC6->( dbSkip() )
		End

		if len(aItemPV) > 0
			MSExecAuto({|a, b, c| MATA410(a, b, c)}, aCabPV, aItemPV, 4)
			If lMsErroAuto
				lRet := .F.
				MostraErro()
			else	// estornada liberação.
				SC9->(dbSetOrder(1))
				SC9->( dbSeek( xFilial('SC9') + cPedido, .T. ) )
				while ! SC9->(EOF()) .and. xFilial('SC9')==SC9->C9_FILIAL .and. SC9->C9_PEDIDO==cPedido
					if Empty(SC9->C9_NFISCAL)
						RecLock('SC9', .F.)
						SC9->( dbDelete() )
						SC9->( MsUnlock() )
					endif
					SC9->( dbSkip() )
				end
			Endif
		else
			Aviso("Pedido sem itens","Não foi encontrado os itens do pedido "+cPedido,{"Ok"})
			lRet := .F.
		endif
	endif

	if lRet .and. cOpc != 'E'	// Libera ou Estorna e Libera
		lRet := LibEst()
	endif

	RestArea( aArea )
Return lRet


//-------------------------------------------------------------------------------------------------
Static Function LibEst()
Local lRet := .T.

	u_CFatA009(SC5->C5_NUM, 1)

	If ! CheckPed()
		ConOut("EstLibPV Filial: "+SC5->C5_FILIAL+" No.:"+ SC5->C5_NUM+", não liberado "+DtoC(Date())+" "+Time() )
		lRet := .F.
	EndIf

Return lRet


//-------------------------------------------------------------------------------------------------
Static Function CheckPed()
Local cSql    := ""
Local aArea   := GetArea()
Local lBlq    := .F.
Local lExist  := .F.

	cSql := "select sum(C9_QTDLIB) Qtdlib, C9_BLEST from "+RetSqlName('SC9')+" where C9_FILIAL='"+SC5->C5_FILIAL+"'"
	cSql += " and C9_PEDIDO='"+SC5->C5_NUM+"'"
	cSql += " and D_E_L_E_T_=' '"
	cSql += " group by C9_BLEST"

	TcQuery cSql New Alias GetNextAlias()

	while ! EOF()
		lExist := .T.
		if ! Empty(C9_BLEST)
			lBlq := .T.
			MsgAlert("O produto informado não possue saldo disponivel para faturamento.", "Atenção")
			exit
		endif

		dbSkip()
	end

	dbCloseArea()

	RestArea( aArea )
	
Return lExist .and. ! lBlq
