#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "font.ch"
#include "colors.ch"


User Function MT116AGR()   
	// Local nOpcao 	:= PARAMIXB[1]   // Opção Escolhida pelo usuario no aRotina  // 3- incluir  2-visualizar 5-excluir
	// Local nConfirma := PARAMIXB[2]   // Se o usuario confirmou a operação de gravação da NFECODIGO DE APLICAÇÃO DO USUARIO.....
	Local aArea		:= GetArea()
	Local lAtivo  := SuperGetMv("MV_DESQIVE",,.T.)
	
	If nRotina==2 .and. Empty(SF1->F1_X_DTINC)
	
		// Alert('[MT116AGR] Gravando: F1_X_DTINC')
		
		RecLock( 'SF1', .F.)
			SF1->F1_X_DTINC := MsDate()
		SF1->(MsUnlock())
		
	EndIf
	
	if lAtivo 
		// Ponto de chamada ConexãoNF-e sempre como última instrução.
		U_GTPE021()
	endif 
RestArea(aArea)
Return .T.


// User Function MT116VLD()   
// Local nOpcao 	:= PARAMIXB[1]   // Opção Escolhida pelo usuario no aRotina  // 3- incluir  2-visualizar 5-excluir
// Local nConfirma := PARAMIXB[2]   // Se o usuario confirmou a operação de gravação da NFECODIGO DE APLICAÇÃO DO USUARIO.....
// Local aArea		:= GetArea()
// 
// 	Alert('MT116VLD')
// 
// RestArea(aArea)
// Return .T.


// User Function MT116OK()   
// // Local nOpcao 	:= PARAMIXB[1]   // Opção Escolhida pelo usuario no aRotina  // 3- incluir  2-visualizar 5-excluir
// // Local nConfirma := PARAMIXB[2]   // Se o usuario confirmou a operação de gravação da NFECODIGO DE APLICAÇÃO DO USUARIO.....
// Local aArea		:= GetArea()
// 
// 	Alert('MT116OK: ' + SF1->F1_DOC + ', nRotina: ' + cValToChar(nRotina) )
// 
// 	Atu_DTINC()
// 	
 
// RestArea(aArea)
// RestArea(aArea)
// Return .T.
// 
// 
// // MJ : 28.01.2018
// Static Function Atu_DTINC()
// Local aArea	:= GetArea()
// 
// 	If SF1->F1_DOC <> cNFiscal
// 		SF1->(DbSetOrder(1)) // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
// 		SF1->(DbSeek( xFilial('SF1')+cNFiscal+cSerie+ca100For+cLoja+cTipo ))
// 	Endif
// 	If nRotina==2 .and. Empty(SF1->F1_X_DTINC)
// 	
// 		Alert('[MT116OK] Gravando: F1_X_DTINC')
// 		
// 		RecLock( 'SF1', .F.)
// 			SF1->F1_X_DTINC := MsDate()
// 		SF1->(MsUnlock())
// 		
// 	EndIf
// 	
// RestArea(aArea)
// Return .T.



/*
User Function MT116GRV()   
// Local nOpcao 	:= PARAMIXB[1]   // Opção Escolhida pelo usuario no aRotina  // 3- incluir  2-visualizar 5-excluir
// Local nConfirma := PARAMIXB[2]   // Se o usuario confirmou a operação de gravação da NFECODIGO DE APLICAÇÃO DO USUARIO.....
Local aArea		:= GetArea()

	Alert('MT116GRV: ' + SF1->F1_DOC )

RestArea(aArea)
Return .T.
*/


/*
User Function MT116TOK()   
// Local nOpcao 	:= PARAMIXB[1]   // Opção Escolhida pelo usuario no aRotina  // 3- incluir  2-visualizar 5-excluir
// Local nConfirma := PARAMIXB[2]   // Se o usuario confirmou a operação de gravação da NFECODIGO DE APLICAÇÃO DO USUARIO.....
Local aArea		:= GetArea()

	Alert('MT116TOK: ' + SF1->F1_DOC )

RestArea(aArea)
Return .T.
*/
