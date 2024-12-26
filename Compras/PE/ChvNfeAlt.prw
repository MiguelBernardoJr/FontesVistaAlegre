/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ ChvNfeAlt ¦ Autor ¦ Henrique Magalhaes   ¦ Data ¦ 10/04/12 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Rotina para informar número da Chave NF-e na SF1			  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ Especifico - Notas de Entrada Ja gravadas                  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
#include "rwmake.ch"  

User Function ChvNfeAlt()
Local cNumCHV	:=SF1->F1_CHVNFE //Space(TAMSX3("F1_CHVNFE"))

@ 000,000 To 130,415 Dialog oDlgChvNfe Title "Nota Fiscal "+SF1->F1_DOC+" Serie "+SF1->F1_SERIE
@ 005,005 To 040,205 Title " Informar Numero da Chave "
//@ 052,005 To 095,105

@ 015,010 Say "Chave"

@ 015,040 GET cNumCHV	Picture "@e!" 				SIZE 150,100

@ 050,005 BmpButton Type 1 Action Gravar(cNumCHV)
@ 050,035 BmpButton Type 2 Action Close(oDlgChvNfe)
Activate Dialog oDlgChvNfe Centered

Return

Static Function Gravar(cNumCHV)

Reclock("SF1",.f.)
	Replace F1_CHVNFE with cNumCHV
MsUnlock()

Aviso('AVISO', 'Processo concluido com sucesso !!!', {'Ok'})
Close(oDlgChvNfe)

Return


/* 
	MJ : 16/10/2018
		-> Criado o arquivo MA103OPC
		
		a funcao acima nao sera mais utilizada, nao é permitido a opcao de alterar a chave, somente visualizacao
 */
// //Funcao do ponto de entrada para adicionar botao na tela principal de documento de entrada - SD1 - mata103
// User function MA103OPC()
// Local aRotina := {}
// aadd(arotina,{"Acerta Chave" , "u_ChvNfeAlt", 0,1})  
// return aRotina 



