#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "font.ch"
#include "colors.ch"

/* MJ : 16.10.2018
	-> Inclusao da opcao para preenchimento da informacao de observacao na NF de entrada;
	-> opcao de visualizacao da chave da NF de Entrada; */
User Function MA103OPC()
	Local aRet := {}
	
	_SetNamedPrvt('cObsMT103', SF1->F1_MENNOTA, 'MATA103') 
	
	aAdd(aRet,{'Observação NF'	 , "U_ObsNFSF1"		, 0, 5})
	aadd(aRet,{"Visualiza Chave" , "u_VisChvNfe"	, 0, 6})  
	//aadd(aRet,{"Boletos" 		 , "u_zCOMI01"		, 0, 5})  
Return aRet

/* MJ : 16/10/2018
	-> Preencher informacao de observacao na nota fiscal
*/
User Function ObsNFSF1()
	
	Private ALTERA := .T.
	
	cObsMT103 := SF1->F1_MENNOTA

	u_FSTelaObs("SF1", "Nota Fiscal: "+SF1->F1_DOC+" - Serie: "+SF1->F1_SERIE)

	Reclock("SF1",.f.)
		SF1->F1_MENNOTA := cObsMT103
	SF1->(MsUnlock())

Return nil


/* MJ : 16/10/2018
	-> Opcao para visualizacao da chafe;
*/
User Function VisChvNfe()
Local cNumCHV	:=SF1->F1_CHVNFE //Space(TAMSX3("F1_CHVNFE"))

@ 000,000 To 130,415 Dialog oDlgChvNfe Title "Nota Fiscal: "+SF1->F1_DOC+" - Serie: "+SF1->F1_SERIE
@ 005,005 To 040,205 Title "Numero da Chave "
//@ 052,005 To 095,105

@ 015,010 Say "Chave"

@ 015,040 GET cNumCHV	Picture "@E!" 				SIZE 150,100

//@ 050,005 BmpButton Type 1 Action Gravar(cNumCHV)
@ 050,035 BmpButton Type 2 Action Close(oDlgChvNfe)
Activate Dialog oDlgChvNfe Centered

Return
