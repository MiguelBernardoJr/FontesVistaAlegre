#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "font.ch"
#include "colors.ch"


/*---------------------------------------------------------------------------------, 
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 10.02.2020                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Ponto de Entrada - Exclusão do Documento de Entrada                  |
 |                                                                       		   |
 |---------------------------------------------------------------------------------|
 | Regras   : Exclusão da movimentação;                                            |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '---------------------------------------------------------------------------------*/
User Function SD1100E()
Local aArea 	:= GetArea()
Local cGrpAju   := SuperGetMv("MV_GRPAJU",.T.,"02;03")// Grupo de Produtos que será ajustado pela TM
Local cProdMil	:= SuperGetMv("MV_X_PRDMI",.T.,"020017;020080;020079;") // Indica códigos de prudutos que NÃO deverão passar pela regra de 
// Local cTMEntra	:= SuperGetMv("MV_X_TMCEN",.T.,"301") // Tipo de Movimento de Entrada para Quebra a Maior no peso de Milho da NF
// Local cTMSaida	:= SuperGetMv("MV_X_TMCSA",.T.,"801") // Tipo de Movimento de Saida para Quebra a Menor no peso de Milho da NF
Local aAreaSD3  := SD3->( GetArea( ) )
PRIVATE l240:=.T.,l250:=.F., l185:=.F.
// ,l650:=.F.,l241:=.F.,l242:=.F.,l261:=.F.
PRIVATE l240Auto := .T., l250Auto := .F.
PRIVATE cCusMed  := GetMv("MV_CUSMED")

	// DbSelectArea("SD1")
	//Posicionando nos registros conforme dados do Cabeçalho
	If SD1->(Dbseek(SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
		
		//Enquanto não estiver no fim dos registros e os dados forem referentes ao Cabeçalho
		While !SD1->(EOF()) .AND. (SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA) = (SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA)
			
			//Seleciona a tabela de TES e Posiciona referente ao Documento de Entrada
			//DbSelectArea("SF4")
			//DbSetOrder(1)
			
			If SF4->(Dbseek(xFilial("SF4")+SD1->D1_TES))
				If Alltrim(SD1->D1_GRUPO)$cGrpAju.AND.!Alltrim(SD1->D1_COD)$cProdMil.AND. SF4->F4_DUPLIC=='S' .AND. SF4->F4_ESTOQUE =='S' .and. (SD1->D1_QUANT < SD1->D1_X_PESOB)

					_QryEst := " SELECT R_E_C_N_O_, D3_FILIAL, D3_TM, D3_COD, D3_UM, D3_LOCAL, " + CRLF
					_QryEst += "        D3_EMISSAO, D3_QUANT, D3_CUSTO1, D3_X_OBS, D3_FORNECE, D3_DOC " + CRLF
					_QryEst += "     FROM " + RetSqlName("SD3") + " SD3 " + CRLF
					_QryEst += "    WHERE D3_COD = '" + SD1->D1_COD + "' " + CRLF
					_QryEst += "      AND D3_EMISSAO = '" + DToS(SF1->F1_X_DTINC) + "'" + CRLF
					_QryEst += "      AND D3_ESTORNO <> 'S' " + CRLF
					_QryEst += " 	 AND D3_X_OBS LIKE '%" + SD1->D1_DOC + "%" + DTOC(SD1->D1_EMISSAO)+ "%'" + CRLF
					_QryEst += "      AND D3_FORNECE = '" + SD1->D1_FORNECE + "' "+ CRLF
					_QryEst += "      AND D_E_L_E_T_=' ' "

					If Select("QRYEST") > 0
						QRYEST->(DbCloseArea())
					EndIf
					TcQuery _QryEst New Alias "QRYEST"
					
					If !QRYEST->(EOF()) .and. QRYEST->R_E_C_N_O_ > 0
						Begin Transaction
							SD3->(dbGoTo( QRYEST->R_E_C_N_O_ ))
							Processa({|| a240Estorn("SD3",;
											QRYEST->R_E_C_N_O_, 5)},;
											"Realizando estorno. Por Favor aguarde...")	
							/*
							LanClassif(QRYEST->D3_FILIAL,;
									   "X",;
									   QRYEST->D3_TM,;
									   QRYEST->D3_COD,;
									   QRYEST->D3_LOCAL,;
									   QRYEST->D3_QUANT,;
									   0.01,;
									   QRYEST->D3_EMISSAO,;
									   QRYEST->D3_X_OBS,;
									   '', '', '',;
									   QRYEST->D3_FORNECE,;
									   QRYEST->D3_DOC,;
									   QRYEST->R_E_C_N_O_ )
							*/
						End Transaction
					EndIf
				Endif
			EndIf
			SD1->(dbSkip())
		EndDo
	EndIf

	RestArea( aAreaSD3 )
	RestArea(aArea)
Return