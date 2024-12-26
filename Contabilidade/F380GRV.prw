#include "Protheus.ch"

#include "TopConn.ch"

/*
Muda a data de conciliacao bancária de todos os titulos pagos com o cheque conciliado
*/
User Function F380GRV()
Local dDtDispo 
Local aArea := GetArea()
Local aAreaTRB := TRB->(GetArea())
Local aAreaE5 := SE5->(GetArea())

 
TRB->(dbGotop())
While !TRB->(Eof())
                SE5->(dbGoto(TRB->E5_RECNO))
		
                If !Empty(SE5->E5_RECONC) .and. SE5->E5_TIPODOC=="CH" .and. !Empty(TRB->E5_OK)
			                   dDtDispo := SE5->E5_DTDISPO
                               BeginSql Alias "QSE5"
                                               SELECT SE5.R_E_C_N_O_ AS E5_RECNO
                                                 FROM %Table:SE5% SE5
                                                WHERE SE5.E5_FILIAL=%xFilial:SE5%
                                                  AND SE5.E5_BANCO=%Exp:SE5->E5_BANCO%
                                                  AND SE5.E5_AGENCIA=%Exp:SE5->E5_AGENCIA%
                                                  AND SE5.E5_CONTA=%Exp:SE5->E5_CONTA%
                                                  AND SE5.E5_NUMCHEQ=%Exp:SE5->E5_NUMCHEQ%
                                                  AND SE5.%NotDel%
                               EndSql
                               QSE5->(dbGotop())
                               While !QSE5->(Eof())    
                                               SE5->(dbGoto(QSE5->E5_RECNO))
                                               If SE5->E5_RECONC==" " .and. SE5->E5_TIPODOC<>"CH"
                                                               RecLock("SE5",.F.)								
								                               SE5->E5_DTDISPO := dDtDispo 
								                               SE5->E5_RECONC  := 'x'
                                                               SE5->(msUnlock())
                                               EndIf
                                               QSE5->(dbSkip())
                               End
                               QSE5->(dbCloseArea())                                                   
                               dbSelectArea("TRB")
				
                SE5->(dbGoto(TRB->E5_RECNO))

                EndIf

                TRB->(dbSkip())
End
 
RestArea(aAreaE5)
RestArea(aAreaTRB)
RestArea(aArea)
Return(Nil) 
