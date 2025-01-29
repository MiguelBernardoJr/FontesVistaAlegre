#include "topconn.ch"
#include "protheus.ch" 
#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ MT103VPC Autor ³ Henrique Magalhaes   ³ Data ³ 19.06.2015³  ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descrição ³ FILTRO NAIMPORATACAO DO PEDIDO DE COMPRAS  			      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³  Usado para preencher campos virtuais                      ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*   
Descrição:
LOCALIZAÇÃO : Funções A103ForF4() , a103procPC() , A103ItemPC()

EM QUE PONTO : EXECUTA FILTRO NAIMPORATACAO DO PEDIDO DE COMPRAS
O ponto é chamado após o acionamento das teclas F5 ou F6 para a importaçao dos pedidos de compra (pedido inteiro F5 ou pedidos por Item F6), 
o arquivo de pedidos de compra SC7 está posicionado, bastando que se aplique o filtro com as condiçoes desejadas para a apresentaçao dos 
registros ou nao nas janelas, o retorno do ponto devera ser uma variavel logica com valor .T. para registros válidos e valor .F. 
para registros a serem descartados.
*/  


User Function MT103VPC()
Local lRet := .T.

Local nPosCod   
Local nPosDesc   
Local nPosCC    
Local nPosITCTA 
Local nPosCLVL  
Local nPosDCC    
Local nPosDITCT 
Local nPosDCLVL  
Local nPosTES  
Local nPosDTES  
Local nPosICMS
Local nPosPesoX
Local cC7Obs
Local _nMeses		:= 0
Local _dtValid		:= dDataBase

/* 
If Alltrim(cEmpAnt)<>'01' // Efetua Validacao apenas para empresa 01 - fazendas
	Return lRet 
Endif
*/
	If AllTrim(ProcName(2)) == "A103PROCPC"
 		lRet := .f.
   		nSldPed := SC7->C7_QUANT-SC7->C7_QUJE-SC7->C7_QTDACLA
   		
   		cC7Obs		:= 	u_SC7OBS(SC7->C7_FILIAL, SC7->C7_NUM)
		If !(Alltrim(cC7Obs)$cObsMT103)
			If Empty(Alltrim(cObsMT103))
				cObsMT103 := Alltrim(cC7Obs)			
			Else
				cObsMT103 := Alltrim(cObsMT103) + ' || ' + Alltrim(cC7Obs) 
				//			cObsMT103 += cObsMT103 + ' || ' + cC7Obs 
			Endif

		Endif

     	If (nSldPed > 0 .And. Empty(SC7->C7_RESIDUO) )
      		NfePC2Acols(SC7->(RecNo()),,nSlDPed,cItem)
        	nPosProd	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_COD"})
         	nPosDesc	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_X_DESC"})
          	nPosOS		:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_ORDEM"})   
          	
          	nPosCod   	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_COD"})
         	nPosNProd	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_X_DESC"})
			nPosCC    	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_CC"})
			nPosITCTA 	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_ITEMCTA"})
			nPosCLVL  	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_CLVL"})
			nPosDCC    	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_X_CC"})
			nPosDITCT 	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_X_ITEMC"})
			nPosDCLVL  	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_X_CLVL"})
          	nPosTES   	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_TES"})
         	nPosDTES	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_X_DESCT"})
         	nPosICMS	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_VALICM"})
			nPosPesoX 	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_X_PESO"})

           	aCols[val(cItem),nPosDesc] 		:= Posicione("SB1",1,xFilial("SB1") + aCols[val(cItem),nPosCod]  ,"B1_DESC")
           	aCols[val(cItem),nPosDCC] 		:= Posicione("CTT",1,xFilial("CTT") + aCols[val(cItem),nPosCC]   ,"CTT_DESC01")
           	aCols[val(cItem),nPosDITCT] 	:= Posicione("CTD",1,xFilial("CTD") + aCols[val(cItem),nPosITCTA],"CTD_DESC01")
           	aCols[val(cItem),nPosDCLVL] 	:= Posicione("CTH",1,xFilial("CTH") + aCols[val(cItem),nPosCLVL] ,"CTH_DESC01")
           	aCols[val(cItem),nPosDTES] 		:= Posicione("SF4",1,xFilial("SF4") + aCols[val(cItem),nPosTES] ,"F4_TEXTO")

			If SB1->B1_RASTRO == "L"
				_nMeses	 := GetMV("JR_MESVLD",, 72)
				_dtValid := dDataBase + ( _nMeses * 30 )
				aCols[ Val(cItem), aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_DTVALID"}) ] := _dtValid
			EndIf
			
           	// if SC7->C7_X_TOICM  > 0
	        //    	aCols[val(cItem),nPosICMS] 		:= SC7->C7_X_TOICM 
			// 	// MaFisRef("IT_VALICM","MT100",aCols[val(cItem),nPosICMS])   // esta linha estava apresentando erro
			// 	// comentado no dia 30.03.2020. Calculo do imposto total ICMS errado.
			// Endif
          	if SC7->C7_X_PESO  > 0
	           	aCols[val(cItem),nPosPesoX] 	:= SC7->C7_X_PESO 
			Endif
            cItem := SomaIt(cItem)
		EndIf
	Else
 		Public cItem := StrZero( 1, TamSx3('D1_ITEM')[1])
    Endif
Return(lRet)  


//---------------------------------------------------------------------------------------------------------
//Retorna a descrição do produto na visualização da NFs de entrada
//Utilizado na inicialização Padrão do campo D1_X_DESC (Virtual)
//---------------------------------------------------------------------------------------------------------
User Function RETSB1(xCpoDesc)

Local aArea     := GetArea()
Local cDesc     := Space(40)
Local nPosCod
Local nPosCC
Local nPosITCTA := 0
Local nPosCLVL
Local nPosDesc
Local nPosDCC
Local nPosDITCT
Local nPosDCLVL
Local nPosTES
Local nPosDTES
Local i         := 0
Local   i := 0

If !('MATA'$ alltrim(funname()))
	RestArea(aArea)
	Return cDesc
Endif

nPosCod   	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_COD"})
nPosCC    	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_CC"})
nPosITCTA 	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_ITEMCTA"})
nPosCLVL  	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_CLVL"})
nPosDesc	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_X_DESC"})
nPosDCC    	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_X_CC"})
nPosDITCT 	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_X_ITEMC"})
nPosDCLVL  	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_X_CLVL"})
nPosTES   	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_TES"})
nPosDTES	:= aScan(aHeader,{ |x| Upper(AllTrim(x[2])) == "D1_X_DESCT"})

For i:= 1 To Len(aCols)
	Do Case                                                                         
		Case xCpoDesc == 'D1_COD'	
			aCols[i,nPosDesc]	:= FDESC("SB1",aCols[i,nPosCod]   ,"B1_DESC")
			cDesc := aCols[i,nPosDesc]
		Case xCpoDesc == 'D1_CC'	
			aCols[i,nPosDCC]	:= FDESC("CTT",aCols[i,nPosCC]    ,"CTT_DESC01")
			cDesc := aCols[i,nPosDCC]
		Case xCpoDesc == 'D1_ITEMCTA'	
			aCols[i,nPosDITCT]	:= FDESC("CTD",aCols[i,nPosITCTA] ,"CTD_DESC01")
			cDesc := aCols[i,nPosDITCT]
		Case xCpoDesc == 'D1_CLVL'	
			aCols[i,nPosDCLVL]	:= FDESC("CTH",aCols[i,nPosCLVL]  ,"CTH_DESC01")
			cDesc := aCols[i,nPosDCLVL]
		Case xCpoDesc == 'D1_TES'	
			aCols[i,nPosDTES]	:= FDESC("SF4",aCols[i,nPosTES]  ,"F4_TEXTO")
			cDesc := aCols[i,nPosDTES]
		OtherWise			
			cDesc := SPACE(40)                                                               
	EndCase                                                                         
Next
Restarea(aArea)
Return(cDesc)    
