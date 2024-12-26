/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CFATA009  ºAutor  ³Microsiga           º Data ³  07/17/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescrição ³Liberação do pedido de vendas                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cNumPed:  Numero do pedido a ser liberado                   º±±
±±º          ³nTpLiber: 1. Liberação de estoque                           º±±
±±º          ³          2. Liberação financeira                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function CFatA009(cNumPed, nTpLiber)
Local aArea      := GetArea()
Local nQtdLib    := 0
Local lRet       := .T.

Private nValTot    := 0

DbSelectArea("SF4")
DbSetOrder(1)

DbSelectArea("SC5")
DbSetOrder(1)

DbSelectArea("SC6")
DbSetOrder(1)

DbSeek( xFilial("SC6") + cNumPed )

DbSelectArea("SC9")
DbSetorder(1)
If DbSeek( xFilial("SC9") + cNumPed )
   While SC9->C9_FILIAL == SC6->C6_FILIAL .and. SC9->C9_PEDIDO == SC6->C6_NUM
      If !Empty(SC9->C9_NFISCAL) 
         lRet := .F.
         Exit
      EndIf
      SC9->(DbSkip())
   End
EndIf

If lRet
   u_RemLib(xFilial("SC6"), cNumPed)

   While !SC6->(Eof()) .And. SC6->C6_NUM == cNumPed .And. SC6->C6_FILIAL == xFilial("SC6")

     nValTot += SC6->C6_VALOR
     
     DbSelectArea("SF4")
     DbSetOrder(1)
     DbSeek( xFilial("SF4") + SC6->C6_TES )
     
     If RecLock("SC5")
          
          nQtdLib := SC6->C6_QTDVEN //SC6->C6_QTDLIB
          //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
          //³Recalcula a Quantidade Liberada                                         ³
          //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
          RecLock("SC6") //Forca a atualizacao do Buffer no Top
          //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
          //³Libera por Item de Pedido                                               ³
          //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
          Begin Transaction
          /*
          ±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
          ±±³Funcao    ³MaLibDoFat³ Autor ³Eduardo Riera          ³ Data ³09.03.99 ³±±
          ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
          ±±³Descri+.o ³Liberacao dos Itens de Pedido de Venda                      ³±±
          ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
          ±±³Retorno   ³ExpN1: Quantidade Liberada                                  ³±±
          ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
          ±±³Transacao ³Nao possui controle de Transacao a rotina chamadora deve    ³±±
          ±±³          ³controlar a Transacao e os Locks                            ³±±
          ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
          ±±³Parametros³ExpN1: Registro do SC6                                      ³±±
          ±±³          ³ExpN2: Quantidade a Liberar                                 ³±±
          ±±³          ³ExpL3: Bloqueio de Credito                                  ³±±
          ±±³          ³ExpL4: Bloqueio de Estoque                                  ³±±
          ±±³          ³ExpL5: Avaliacao de Credito                                 ³±±
          ±±³          ³ExpL6: Avaliacao de Estoque                                 ³±±
          ±±³          ³ExpL7: Permite Liberacao Parcial                            ³±±
          ±±³          ³ExpL8: Tranfere Locais automaticamente                      ³±±
          ±±³          ³ExpA9: Empenhos ( Caso seja informado nao efetua a gravacao ³±±
          ±±³          ³       apenas avalia ).                                    ³±±
          ±±³          ³ExpbA: CodBlock a ser avaliado na gravacao do SC9           ³±±
          ±±³          ³ExpAB: Array com Empenhos previamente escolhidos            ³±±
          ±±³          ³       (impede selecao dos empenhos pelas rotinas)          ³±±
          ±±³          ³ExpLC: Indica se apenas esta trocando lotes do SC9          ³±±
          ±±³          ³ExpND: Valor a ser adicionado ao limite de credito          ³±±
          ±±³          ³ExpNE: Quantidade a Liberar - segunda UM                    ³±±
          ±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
          */
          If nTpLiber == 1
	          MaLibDoFat(SC6->(RecNo()),@nQtdLib,.F.,.T.,.F.,.T.,.F.,.F.)
          Else
    	      MaLibDoFat(SC6->(RecNo()),@nQtdLib,.T.,.F.,.T.,.F.,.F.,.F.)
          EndIf
          End Transaction
     EndIf
     SC6->(MsUnLock())
     //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
     //³Atualiza o Flag do Pedido de Venda                                      ³
     //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
     Begin Transaction
     SC6->(MaLiberOk({cNumPed},.F.))
     End Transaction

     DbSelectArea("SC6")
     SC6->(DbSkip())
   End
EndIf

If!Empty(aArea)
   RestArea(aArea)
EndIf
Return lRet

User Function RemLib(xFilial, cPed)
Local aAreaSM0 := SM0->(GetArea())
Local aAreaSC5 := SC5->(GetArea())
Local aAreaSC6 := SC6->(GetArea())
Local cCurFil  := cFIlAnt
Local nVal     := 0
Local aCab     := {}
Local aItens   := {}

Local lContinua := .t.

cFilAnt := xFilial
DbSelectArea("SM0")
DbSetOrder(1) // M0_CODIGO+M0_CODFIL
If AllTrim(SM0->M0_CODFIL) <> xFilial
   DbSeek(SM0->M0_CODIGO+xFilial)
EndIf

DbSelectArea("SC5")
DbSetOrder(1) // C5_FILIAL+C5_NUM
DbSeek(xFilial("SC5")+cPed)

DbSelectArea("SC6")
DbSetOrder(1) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
DbSeek(xFilial("SC6")+cPed)

While !SC6->(Eof()) .and. SC6->C6_FILIAL == SC5->C5_FILIAL .and. SC6->C6_NUM == SC5->C5_NUM
   //nSC6Recno := SC6->( Recno() )
   MaAvalSC6("SC6", 4, "SC5")
   //SC6-> (DbGoTo(nSC6Recno) )
   SC6->( DbSkip())
End

cFilAnt := cCurFil
SC6->(RestArea(aAreaSC6))   
SC5->(RestArea(aAreaSC5))
SM0->(RestArea(aAreaSM0))
Return Nil


Static Function Libera(cNumPed)
 
 Local lLibPedido := .T.
 
 lCredito := .T.
 lEstoque := .T.
 lLiber   := .T.
 lTransf  := .F.

 DbSelectArea("SC9")
 DbSetOrder(1)

 DbSelectArea("SC6")
 DbSetOrder(1)
 DbSeek(xFilial("SC6") + cNumPed)
 While !SC6->(Eof()) .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == cNumPed
 	SC9->(DbSeek(xFilial("SC9") + SC6->C6_NUM))
 	nQtdLib := SC6->C6_QTDVEN
 	nQtdLib := MaLibDoFat(SC6->(RecNo()),nQtdLib,@lCredito,@lEstoque,.F.,.F.,lLiber,lTransf)
 	If SC6->C6_QTDVEN <> nQtdLib
  		lLibPedido := .F.
 	EndIf
 	SC6->(DbSkip())
 Enddo
Return(lLibPedido)