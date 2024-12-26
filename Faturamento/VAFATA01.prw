#include "protheus.ch"
#include "topconn.ch"   
#Include "rwmake.ch" 


/*
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VAFATA01  ¦ Autor ¦                      ¦ Data ¦ 14/07/11 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Rotina para informar nota de entrada de abatimento	      ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ Vista Alegre                                               ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/


User Function VAFATA01()

dbSelectArea("SF2")
dbSetOrder(1)
dbgotop()

cCadastro := "Notas Fiscais de Saida - Aceite de Notas"

aRotina := {;
{"Pesquisar"		,"AxPesqui"		,0,1},;
{"Informar No."   	,"u_sf2Aceit"	,0,2}}

MBrowse(6, 1, 22, 75, "SF2")

Return

User Function sf2Aceit()
Local cNfeNum	:= Iif(Empty(SF2->F2_X_NFENT),Space(15),SF2->F2_X_NFENT)
Local dNfeDt	:= Iif(Empty(SF2->F2_X_DTENT),DDATABASE,SF2->F2_X_DTENT)  

@ 000,001 TO 230,215 Dialog oDlgAceite Title OemToAnsi("Nota Fiscal "+SF2->F2_DOC+" Serie "+SF2->F2_SERIE)
@ 005,005 To 048,105 Title " Informar Nota/Data Entrada"
@ 052,005 To 095,105

@ 015,010 Say "Numero NF"
@ 015,050 GET cNfeNum	Picture "@e!" 				SIZE 50,45

@ 030,010 Say "Data NF"
@ 030,050 GET dNfeDt	SIZE 50,45

@ 100,045 BmpButton Type 1 Action Gravar(cNfeNum,dNfeDt)
@ 100,075 BmpButton Type 2 Action Close(oDlgAceite)
Activate Dialog oDlgAceite Centered

Return

Static Function Gravar(cNfeNum,dNfeDt)
Local aArea := GetArea()
Reclock("SF2",.f.)
	Replace F2_X_NFENT with cNfeNum
	Replace F2_X_DTENT with dNfeDt
MsUnlock()

DbSelectArea("SE1")
SE1->(DbSetOrder(2)) //E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
SE1->(DbGoTop())
If SE1->(DbSeek(SF2->F2_FILIAL + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_SERIE + SF2->F2_DOC))
	While SE1->E1_FILIAL + SE1->E1_CLIENTE + SE1->E1_LOJA + SE1->E1_PREFIXO + SE1->E1_NUM   =  SF2->F2_FILIAL + SF2->F2_CLIENTE + SF2->F2_LOJA + SF2->F2_SERIE + SF2->F2_DOC
    		RecLock('SE1', .F.)
    			E1_HIST := cNfeNum
    		SE1->(MsUnlock())
	    SE1->(dbSkip())
    EndDo
Endif    

Aviso('AVISO', 'Aceite de nota concluido com sucesso !!!', {'Ok'})
Close(oDlgAceite)

RestArea(aArea)

Return
