#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "font.ch"
#include "colors.ch"



/****************************************************************
Ponto de Entrada - Exclusão do Documento de Entrada
****************************************************************/
User Function SD1100E()
Local aArea 	:= GetArea()
Local cB1Diari 	:= ''
Local QryDia 	:= ''
		// Tratamento para limpar flags das Diarias, quando ocorrer a exclusao da NF
		cB1Diari := Posicione("SB1",1,xFilial("SB1")+SD1->D1_COD,"B1_X_DIARI")
		If cB1Diari=="S"
			QryDia :=  "  SELECT * "
			QryDia +=  "  FROM "+RetSqlName('SZ7')+" SZ7 "
			QryDia +=  "  WHERE SZ7.D_E_L_E_T_ = '' "
			QryDia +=  "  AND Z7_SERVICO = '"+SD1->D1_COD+"' "
			QryDia +=  "  AND Z7_FORNECE = '"+SD1->D1_FORNECE+"' "
			QryDia +=  "  AND Z7_LOJA 	 = '"+SD1->D1_LOJA+"' "
			QryDia +=  "  AND Z7_DOC 	 = '"+SD1->D1_DOC+"' "
			QryDia +=  "  AND Z7_SERIE 	 = '"+SD1->D1_SERIE+"' "
			QryDia +=  "  AND Z7_ITEMNF	 = '"+SD1->D1_ITEM+"' "
					
			If Select("QRYZ7") > 0
			 	QRYZ7->(DbCloseArea())
			EndIf
			TcQuery QryDia New Alias "QRYZ7"
					
	 		While  !QRYZ7->(EOF())
			 	SZ7->(dbGoTo(QRYZ7->R_E_C_N_O_))			
			 	RecLock("SZ7",.F.)
			 		Z7_FILDOC	:= ''
			 		Z7_DOC		:= ''
			 		Z7_SERIE	:= ''
			 		Z7_ITEMNF	:= ''
			 		Z7_STATUS	:= 'P' // Pendente	     
			 	SZ7->(MSUnLock())
				QRYZ7->(dbSkip()) 			 				
			EndDo	
		Endif
RestArea(aArea)
Return	    