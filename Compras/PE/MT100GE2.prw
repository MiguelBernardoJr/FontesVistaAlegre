#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "font.ch"
#include "colors.ch"


// Gravar dados adicionais no titulo apos gravar documento de entrada
// Observacao da Nota no Titulo Financeiro na Inclusao da NF de Entrada
User Function MT100GE2 
/*
Local aTitAtual   := PARAMIXB[1]
Local nOpc        := PARAMIXB[2]
Local aHeadSE2	  := PARAMIXB[3]
// Local nX          := PARAMIXB[4]
// Local aParcelas   := PARAMIXB[5]
//.....Exemplo de customização
Local nPos        := Ascan(aHeadSE2,{|x| Alltrim(x[2]) == 'E2_OBS'})  
   
   // If nOpc == 1 //.. inclusao
   //     SE2->E2_OBS:=aCols[nPos]
   // EndIf
   
   Alert('MT100GE2: ' + cValToChar(nPos))
*/
Local nParc	:= iIf(Empty(SE2->E2_PARCELA),1,Val(SE2->E2_PARCELA))

	If Type("aTitSE2") <> "U" .and. !Empty( aTitSE2 ) .and. PARAMIXB[1,2] <> aTitSE2[ nParc, 3]
		SE2->E2_VENCTO  := DataValida( aTitSE2[ nParc, 3], .T.)
		SE2->E2_VENCREA := DataValida( aTitSE2[ nParc, 3], .T.)
	EndIf

	If INCLUI .and. Type("cObsMT103") <> "U" .and. !Empty(cObsMT103)
		SE2->E2_HIST :=  cObsMT103 //SF1->F1_MENNOTA //cObsMT103 //
	EndIf                
	If SE2->(FieldPos("E2_XXDTDIG"))>0
		SE2->E2_XXDTDIG := DATE()      
		// Update criado para tratar titulos TX;IR;ISS e demais que nao estavam tendo o conteudo alterado pelo ponto de entrada
		cQryUpd := " UPDATE " + RetSqlName('SE2') + "  "
		cQryUpd += " SET E2_XXDTDIG = '" 	+ DTOS(DATE()) + "' "
		cQryUpd += " WHERE E2_TITPAI  = '"	+ SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA) + "' "
		cQryUpd += " AND E2_FILIAL  = '"	+ SE2->E2_FILIAL + "' AND D_E_L_E_T_ = ''  AND E2_XXDTDIG = '' "
		TcSqlExec(cQryUpd) 				
	EndIf

	// Efetuar gravaçao de Centro de Custo no campo e2_ccd para tratamento em regras contabeis
	cQryUpd := " UPDATE " + RetSqlName('SE2') + "     "
	cQryUpd += " SET E2_CCD = D1_CC "
	cQryUpd += " FROM  "  + RetSqlName('SD1') + " SD1 "
	cQryUpd += " WHERE D1_FILIAL=E2_FILIAL AND D1_FORNECE=E2_FORNECE AND D1_LOJA=E2_LOJA AND D1_DOC=E2_NUM AND D1_SERIE=E2_PREFIXO  "
	cQryUpd += " AND SD1.D_E_L_E_T_ = '' AND  " + RetSqlName('SE2') + ".D_E_L_E_T_ = ''  "
	cQryUpd += " AND E2_FILIAL   = '"	+ SE2->E2_FILIAL  + "' " 
	cQryUpd += " AND E2_NUM      = '"	+ SE2->E2_NUM     + "' " 
	cQryUpd += " AND E2_PREFIXO  = '"	+ SE2->E2_PREFIXO + "' " 
	cQryUpd += " AND E2_FORNECE  = '"	+ SE2->E2_FORNECE + "' " 
	cQryUpd += " AND E2_LOJA     = '"	+ SE2->E2_LOJA    + "' " 
	cQryUpd += " AND E2_EMISSAO  = '"	+ DTOS(SE2->E2_EMISSAO)  + "' " 
		
	TcSqlExec(cQryUpd) 				

Return Nil  