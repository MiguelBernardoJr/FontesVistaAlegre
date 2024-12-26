
#INCLUDE 'Protheus.ch'
#INCLUDE 'TopConn.ch'

/*************************************************/
/* Estorno de Nota Fiscal - SEFAZ MS             */
/*************************************************/

User Function EstNFMS()

    Processa({ || ProcEstorno() } , "Processando estorno...") 

Return()

Static Function ProcEstorno()

    Local aArea    := GetArea()
    Local aAreaSF2 := SF2->(GetArea())
    Local aRegSD2  := {}
    Local aRegSE1  := {}
    Local aRegSE2  := {}
    Local lRet     := .F.
    Local cNumNF   := ""
    Local aLotes   := {}
  
    
    If Empty(SC5->C5_NFMS)
		Aviso("Nota Fiscal SEFAZ MS", "Pedido não é de Nota Fiscal SEFAZ MS.", {"Ok"})
		Return()
	EndIf
    
    DbSelectArea("SD2")
    DbSetOrder(3) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
    DbSeek(xFilial("SD2") + SC5->C5_NOTA + SC5->C5_SERIE + SC5->C5_CLIENTE + SC5->C5_LOJACLI)

    DbSelectArea("SF2")
    DbSetOrder(1) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA
    If !DbSeek(xFilial("SF2") + SC5->C5_NOTA + SC5->C5_SERIE + SC5->C5_CLIENTE + SC5->C5_LOJACLI)
        Aviso("Nota Fiscal SEFAZ MS", "Documento de saída não encontrado.", {"Ok"})
        Return()
    EndIf

    cNumNF := SF2->F2_DOC

    aLotes := SalvaLotes()

    //Begin Transaction 
    //Não é possível usar transação, após a transferência, a alteração de pedido não reconhece o estoque

        ProcRegua(0)

        //Estorna documento de saída
	    IncProc("Excluindo documento de saída...")
        
        If (lRet := MaCanDelF2("SF2", SF2->(RecNo()), @aRegSD2, @aRegSE1, @aRegSE2))
            MaDelNFS(aRegSD2, aRegSE1, aRegSE2, .F., .F., .T., .F.)
            MsUnlockAll()
        Else
            Aviso("Nota Fiscal SEFAZ MS", "Documento de saída não encontrado.", {"Ok"})
	  	    DisarmTransaction()		 	
        EndIf

        AlteraPed(, aLotes)//Faz alteração apenas para liberar os saldos de produtos

        Transfere(cNumNF, aLotes)

        AlteraPed(.T., aLotes)//Faz alteração do produto do pedido

    //End Transaction

    //Limpar campos C5_NFMS
    RecLock("SC5", .F.)
        SC5->C5_NFMS    := ""
        SC5->C5_SERIEMS := ""
    SC5->(MsUnLock())
    //Retirar XML anexo

    RestArea(aAreaSF2)
    RestArea(aArea)
Return()

/********************************************************************************/
/* Faz alteração do pedido, para liberar os saldos dos produtos e depois para   */
/* trocar os produtos no pedido.                                                */
/********************************************************************************/

Static Function Transfere(cNumNF, aLotes)

    Local aArea    := GetArea()
    Local aAreaSC6 := SC6->(GetArea())
    Local aAreaSF4 := SF4->(GetArea())
    Local aProd    := {}
	Local cNumDoc  := "ES" + SC5->C5_NUM
    Local nPos     := 0

    Private lMsErroAuto := .F.

    SC6->(DbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
    SC6->(DbSeek(xFilial("SC6") + SC5->C5_NUM))

    While SC5->C5_FILIAL + SC5->C5_NUM == xFilial("SC6") + SC6->C6_NUM

        SF4->(DbSeek(xFilial("SF4") + SC6->C6_TES))

        If SF4->F4_ESTOQUE <> "S"
			SC6->(DbSkip())
		EndIf

        nPos := aScan(aLotes, {|aVet| aVet[1] == SC6->C6_ITEM} )

        aProd := {{	cNumDoc,;    // 01.Numero do Documento
	                dDataBase }} // 02.Data da Transferencia
        
        aAdd(aProd, { ;
            SC6->C6_PRODUTO  ,;                 // 01.Produto Origem
            Posicione("SB1", 1, xFilial("SB1") + SC6->C6_PRODUTO, "B1_DESC"),;                 // 02.Descricao
            Posicione("SB1", 1, xFilial("SB1") + SC6->C6_PRODUTO, "B1_UM"  ),;                 // 03.Unidade de Medida
            SC6->C6_LOCAL,;                   // 04.Local Origem
            CriaVar("D3_LOCALIZ"),;	   	 // 05.Endereco Origem
            SC6->C6_PRODANT,;     // 06.Produto Destino
            Posicione("SB1", 1, xFilial("SB1") + SC6->C6_PRODANT, "B1_DESC"),; // 07.Descricao
            Posicione("SB1", 1, xFilial("SB1") + SC6->C6_PRODANT, "B1_UM")  ,; // 08.Unidade de Medida
            SC6->C6_LOCAL,;			         // 09.Armazem Destino
            CriaVar("D3_LOCALIZ",.F.),;	 // 10.Endereco Destino
            CriaVar("D3_NUMSERI",.F.),;	 // 11.Numero de Serie
            aLotes[nPos, 2],;	 // 12.Lote Origem
            CriaVar("D3_NUMLOTE",.F.),;	 // 13.Sublote
            aLotes[nPos, 3],;                   // 14.Data de Validade
            CriaVar("D3_POTENCI",.F.),;	 // 15.Potencia do Lote
            SC6->C6_QTDVEN,;    // 16.Quantidade
            CriaVar("D3_QTSEGUM",.F.),;	 // 17.Quantidade na 2 UM
            CriaVar("D3_ESTORNO",.F.),;	 // 18.Estorno
            "",;                         // 19.NumSeq
            aLotes[nPos, 2],; // 20.Lote Destino
            aLotes[nPos, 3],; // 21.Validade Lote Destino
            CriaVar("D3_ITEMGRD",.F.),; // 22.Item grade
            "Referente ao estorno do pedido: " + SC5->C5_NUM + " - Nota Fiscal: " + cNumNF }) // 23.Observação       28/08/20 - grava itens na observacao
	
	        lMsErroAuto := .F.
	        MSExecAuto({|x,y| MATA261(x,y)}, aProd, 3)
			
	        If lMsErroAuto
		        MostraErro()
		        DisarmTransaction()
                Exit
	        EndIf

        SC6->(DbSkip())
    End

    RestArea(aAreaSC6)
    RestArea(aAreaSF4)
    RestArea(aArea)
Return()

/********************************************************************************/
/* Faz alteração do pedido, para liberar os saldos dos produtos e depois para   */
/* trocar os produtos no pedido.                                                */
/********************************************************************************/

Static Function AlteraPed(lTrocaPrd, aLotes)

	Local aArea    := GetArea()
	Local aAreaSC6 := SC6->(GetArea())
	Local aAreaSC5 := SC5->(GetArea())
	Local aAreaSB1 := SB1->(GetArea())
	Local aCab     := {}
	Local aItem    := {}
    Local nPos     := 0

	Default lTrocaPrd := .F.

	Private lMsErroAuto := .F.

	SC5->(DbSetOrder(1)) //C5_FILIAL+C5_NUM
	SC5->(DbSeek(xFilial("SC5") + SC5->C5_NUM))

	// Monta vetor com cabecalho do pedido                             
	aadd(aCab,{"C5_NUM    ", SC5->C5_NUM    , Nil}) // Tipo de pedido	
	aadd(aCab,{"C5_TIPO   ", SC5->C5_TIPO   , Nil}) // Tipo de pedido
	aadd(aCab,{"C5_CLIENTE", SC5->C5_CLIENTE, Nil}) // Cliente
	aadd(aCab,{"C5_LOJACLI", SC5->C5_LOJACLI, Nil}) // Loja
	aadd(aCab,{"C5_CLIENT ", SC5->C5_CLIENT , Nil}) // Cliente de entrega
	aadd(aCab,{"C5_LOJAENT", SC5->C5_LOJAENT, Nil}) // Loja de entrega

	SB1->(DbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

	SC6->(DbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	SC6->(DbSeek(xFilial("SC6") + SC5->C5_NUM))

	While !SC6->(Eof()) .And. SC6->C6_FILIAL + SC6->C6_NUM == xFilial("SC5") + SC5->C5_NUM

        nPos := aScan(aLotes, {|aVet| aVet[1] == SC6->C6_ITEM} )

		If lTrocaPrd
			SB1->(DbSeek(xFilial("SB1") + SC6->C6_PRODANT))
		Else 
			SB1->(DbSeek(xFilial("SB1") + SC6->C6_PRODUTO))
		EndIf

		aAdd(aItem, {	{"C6_ITEM   ", SC6->C6_ITEM        , Nil},; // Item
						{"C6_PRODUTO", SB1->B1_COD         , Nil},; // Codigo do produto
						{"C6_UM     ", SB1->B1_UM          , Nil},; // Unidade de medida
						{"C6_QTDVEN ", SC6->C6_QTDVEN      , Nil},; // quantidade
						{"C6_PRUNIT ", SC6->C6_PRUNIT      , Nil},; // valor unitario do preco de lista
						{"C6_PRCVEN ", SC6->C6_PRCVEN      , Nil},; // Valor unitario liquido B2_CM1
						{"C6_VALOR  ", A410Arred(SC6->C6_PRCVEN * SC6->C6_QTDVEN, "C6_VALOR"), Nil},; // Valor total
						{"C6_TES    ", SC6->C6_TES         , Nil},; // TES do Item
						{"C6_LOCAL  ", SC6->C6_LOCAL       , Nil},; // De onde sai o produto -- Almoxarifado (SB1)
						{"C6_QTDLIB ", IIf(lTrocaPrd, SC6->C6_QTDVEN, 0), Nil},; // De onde sai o produto -- Almoxarifado (SB1)
						{"C6_LOTECTL", aLotes[nPos, 2]     , Nil},;
						{"C6_PRODBMS", SC6->C6_PRODUTO     , Nil},;
						{"C6_PRODANT", IIf(lTrocaPrd, "", SC6->C6_PRODANT), Nil},;
						{"C6_NUM    ", SC6->C6_NUM         , Nil}}) // Numero do Pedido
		
		SC6->(DbSkip())
	End

	Begin Transaction
	
	lMsErroAuto := .F.
	MSExecAuto({|x,y,z|Mata410(x,y,z)}, aCab, aItem, 4 )

	If lMsErroAuto
		cErro := "1"
		MostraErro()
		DisarmTransaction()
	EndIf

	End Transaction
	
	RestArea(aAreaSB1)
	RestArea(aAreaSC5)
	RestArea(aAreaSC6)
	RestArea(aArea)
Return()

/********************************************************************************/
/* Faz alteração do pedido, para liberar os saldos dos produtos e depois para   */
/* trocar os produtos no pedido.                                                */
/********************************************************************************/

Static Function SalvaLotes()

    Local aLotes := {}
    Local aAreaSC6 := SC6->(GetArea())
    Local aAreaSD2 := SD2->(GetArea())

    DbSelectArea("SD2")
    DbSetOrder(8)//D2_FILIAL+D2_PEDIDO+D2_ITEMPV

    DbSelectArea("SC6")
    DbSetorder(1)//C6_FILIAL+C6_NUM
    DbSeek(xFilial("SC6") + SC5->C5_NUM)

    While !SC6->(Eof()) .And. SC6->C6_FILIAL + SC6->C6_NUM == xFilial("SC5") + SC5->C5_NUM

        SD2->(DbSeek(xFilial("SD2") + SC6->C6_NUM + SC6->C6_ITEM))

        aAdd(aLotes, { SC6->C6_ITEM, SD2->D2_LOTECTL, SD2->D2_DTVALID})

        SC6->(DbSkip())
    End

    RestArea(aAreaSD2)
    RestArea(aAreaSC6)
Return(aLotes)
