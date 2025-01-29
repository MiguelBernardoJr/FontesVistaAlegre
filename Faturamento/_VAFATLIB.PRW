#include "protheus.ch"
#include "topconn.ch"   
#Include "rwmake.ch" 


//----------------------------------------------------------------------------------------------------------
//Troca de series de notas por filiais
//----------------------------------------------------------------------------------------------------------
User Function CHGX5FIL()                                                                                         
return(cFilAnt)

//----------------------------------------------------------------------------------------------------------
// Funcao a ser chamada para reajuste de precos na rotina Reajuste Preco (MATA511)
//----------------------------------------------------------------------------------------------------------
// Desabilitado por nao possibilitar formula de calculo utilizada pela Vista Alegre
/*
User Function CplPreco()
Local aArea 	:= GetArea()
Local nCompl	:= 0
	@ 0,1 TO 170,265 DIALOG oM511Preco TITLE OemToAnsi("Valor Reajuste")
	@ 2,2 TO 80,132	              
	@ 10,010 Say "Valor Total: " Size 50,8
	@ 10,045 GET nCompl 	Picture "@e 999,999,999.9999" SIZE 50,10 	
	@ 62,024 Button OemToAnsi("OK") Size 40,12 Action iif(nCompl>0, Close(oM511Preco), Alert("Valor nao informado!"))	
	Activate Dialog oM511Preco Centered
RestArea(aArea)
Return nCompl    
*/


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³M460FIM   ºAutor  ³Microsiga           º Data ³  09/09/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Após término do faturamento                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Específico SAKPAC para gravar dados na SF2, SD2, SE1, apos º±±
±±ºUso       ³ gravar a nota fiscal                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function M460FIM()
Local aArea 	:= GetArea()
Local aAreaD2 	:= SD2->(GetArea())
Local aAreaC6	:= SC6->(GetArea())
Local cNumSC5  	:= sc5->c5_num
Local cNumNF   	:= sf2->f2_doc
Local cSerieNF 	:= sf2->f2_serie
Local cPedCli	:= ""
Local aAreaSE1 	:= SE1->(GetArea())
Local nVolume	:= 0
Local nPesoNF	:= 0	
Local cEspec1	:= ""
Local nVoluC5	:= SC5->C5_VOLUME1 	// PEGA O DIGITADO NO PEDIDO OU GERADO PELO AVALIA PEDIDO
Local nPesoC5	:= SC5->C5_PESOL 	// PEGA O DIGITADO NO PEDIDO OU GERADO PELO AVALIA PEDIDO
Local lCmpAut  	:= IIF("S"==SuperGetMv("MV_X_CMPAU",.T.,"S"),.T.,.F.)  // Compensa automatico S-sim ou N-nao


If ALLTRIM(FUNNAME())=="MATA310"
	DbSelectArea("SC6")                                   
	DbSetOrder(1)
	DbSeek(xFilial("SC6")+cNumSC5)
	While !SC6->(Eof()) .and. sc6->c6_filial == xFilial("SC6") .and. sc6->c6_num == cNumSC5
		DbSelectArea("SD2")
		DbSetOrder(8)
		DbSeek(xFilial("SD2")+sc6->c6_num+sc6->c6_item)
		if sd2->d2_filial == xFilial("SD2") .and. sd2->d2_pedido=sc6->c6_num .and. sd2->d2_itempv == sc6->c6_item	
	   	     nVolume:= nVolume + sd2->d2_quant
	   	     cEspec1:= if(!Empty(cEspec1),cEspec1, if(substr(sd2->d2_cod,1,2)=="01","BOVINOS",""))   	     
	   	endif        
	    SC6->(DbSkip())          
	Enddo                             
	
	/*
	 * gravando os dados no cabecalho da nota fiscal, conforme campos Tipo Frete, Mensagem, Desconto Financeiro (pedido de vendas)
	 */
	RecLock("SF2",.f.) 
	 sf2->f2_volume1	:= Iif(nVoluC5>0, nVoluC5, nVolume) // sc5->C5_VOLUME1
	 sf2->f2_especi1    := Iif(empty(cEspec1),".",cEspec1)
	SF2->(MsUnLock())
	
	
	DbSelectArea("SC5")                                   
	DbSetOrder(1)
	If DbSeek(xFilial("SC5")+cNumSC5)
		RecLock("SC5",.f.) 
		 SC5->C5_especi1	:= cEspec1
		 SC5->C5_VOLUME1	:= nVolume
		SC5->(MsUnLock())
	Endif	

Endif

// Compensacao automatica de titulos de nf com RA
// Processo de compensação automatica retirado em 03/07/2017 Pedido Contabilidade
If lCmpAut
	u_CmpAutTit('R',SF2->F2_FILIAL, SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA)
Endif

RestArea(aAreaC6)
RestArea(aAreaD2)
RestArea(aArea)

//return     


aArea2 	:= GetArea()
aAreaD2 := SD2->(GetArea())
aAreaC6	:= SC6->(GetArea())

 
// 01/07/2015 - Nao sera mais utilizado
DbSelectArea("SC6")                                   
DbSetOrder(1)
DbSeek(xFilial("SC6")+cNumSC5)

While !SC6->(Eof()) .and. sc6->c6_filial == xFilial("SC6") .and. sc6->c6_num == cNumSC5
	DbSelectArea("SD2")
	DbSetOrder(8)
	DbSeek(xFilial("SD2")+sc6->c6_num+sc6->c6_item)
	if sd2->d2_filial == xFilial("SD2") .and. sd2->d2_pedido=sc6->c6_num .and. sd2->d2_itempv == sc6->c6_item	
		RecLock("SD2",.f.)  
		SD2->D2_CCUSTO := SC6->C6_X_CC
		SD2->(MsUnLock())
	endif        
	SC6->(DbSkip())          
Enddo            



RestArea(aAreaC6)
RestArea(aAreaD2)
RestArea(aArea2)

Return

