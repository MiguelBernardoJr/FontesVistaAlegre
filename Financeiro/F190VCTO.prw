
/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ F190VCTO() ¦ Autor ¦ Henrique Magalhaes  ¦ Data ¦ 17/06/13 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Rotina para informar vencto no cheque emitido (sef)		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ Especifico - Cheques gerados na SEF                        ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
#include "rwmake.ch"  

User Function F190VCTO()
Local dCHVencto	:= SEF->EF_VENCTO  //Space(TAMSX3("EF_VENCTO"))

@ 000,000 To 130,415 Dialog oDlgChqVcto Title "Cheque "+SEF->EF_NUM
@ 005,005 To 040,205 Title " Informar Vencimento do Cheque"
//@ 052,005 To 095,105

@ 015,010 Say "Vencto"

@ 015,040 GET dCHVencto	Picture "@e!" 				SIZE 150,100

@ 050,005 BmpButton Type 1 Action Gravar(dCHVencto)
@ 050,035 BmpButton Type 2 Action Close(oDlgChqVcto)
Activate Dialog oDlgChqVcto Centered

Return

Static Function Gravar(dCHVencto)
Local aArea:= GetArea()
cChFil  	:= SEF->EF_FILIAL
cChBanco    := SEF->EF_BANCO
cChAgenc	:= SEF->EF_AGENCIA
cChConta	:= SEF->EF_CONTA
cChNumer	:= SEF->EF_NUM
cChChave	:= SEF->EF_FILIAL + SEF->EF_BANCO + SEF->EF_AGENCIA + SEF->EF_CONTA + SEF->EF_NUM

// Ajustando SEF- CHEQUES
// EF_FILIAL+EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM                                                                                                                   
DbselectArea("SEF")
dbSetOrder(1) // EF_FILIAL+EF_BANCO+EF_AGENCIA+EF_CONTA+EF_NUM
If dbseek(cChChave)
	While  cChChave = (SEF->EF_FILIAL + SEF->EF_BANCO + SEF->EF_AGENCIA + SEF->EF_CONTA + SEF->EF_NUM)
		Reclock("SEF",.f.)
			Replace SEF->EF_VENCTO with dCHVencto
		SEF->(MsUnlock())
		SEF->(dbSkip())
	EndDo	
Endif

Aviso('AVISO', 'Processo concluido com sucesso !!!', {'Ok'})
Close(oDlgChqVcto)

RestArea(aArea)
Return
                    

// INSERIR ROTINA NO MENU
User Function F190BROW()
	  aAdd(arotina, {'Vencto Cheque',"U_F190VCTO()",0,4,,.T.} )
Return
