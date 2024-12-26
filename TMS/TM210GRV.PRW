#INCLUDE "TOPCONN.CH"

User function TM210GRV()
Local nOpcx    := ParamIxb[1]
Local cFilOri  := ParamIxb[2]
Local cViagem  := ParamIxb[3]
Local cQuery   := ""
Local cTime := SUBSTR(TIME(), 1, 2)+SUBSTR(TIME(), 4, 2)

If nOpcx == 3
	GrvDTW(.T., cViagem, "049", "000002", cFilOri)
	GrvDTW(.F., cViagem, "050", "000003", cFilOri)
EndIf

Return


Static Function GrvDTW(lApt, cViagem, cAtiv, cSequen, cFilOri)
Local dData := DATE()
Local cTime := SUBSTR(TIME(), 1, 2)+SUBSTR(TIME(), 4, 2)

dbSelectArea("DTW")
DTW->( dbSetOrder(1) )
If DTW->( dbSeek(xFilial("DTW")+cFilOri+cViagem+cSequen) )
	Return Nil
EndIf

RecLock("DTW", .T.)

DTW->DTW_FILIAL	:= ""
DTW->DTW_FILORI	:= cFilAnt
DTW->DTW_VIAGEM	:= cViagem
DTW->DTW_SEQUEN	:= cSequen
DTW->DTW_TIPOPE	:= "2"
DTW->DTW_DATPRE	:= dData
DTW->DTW_HORPRE	:= cTime
If lApt
	DTW->DTW_DATINI	:= dData
	DTW->DTW_HORINI	:= cTime
	DTW->DTW_DATREA	:= dData	        	        
	DTW->DTW_HORREA	:= cTime
	DTW->DTW_FILATI	:= cFilAnt
	DTW->DTW_STATUS	:= "2"
Else
	DTW->DTW_STATUS	:= "1"
EndIf
DTW->DTW_SERVIC	:= "002"
DTW->DTW_TAREFA	:= "Z01"
DTW->DTW_ATIVID	:= cAtiv
DTW->DTW_SERTMS	:= "3"
DTW->DTW_TIPTRA	:= "1"
DTW->DTW_FILATU	:= cFilAnt
DTW->DTW_CATOPE	:= "1"
//DTW->DTW_OBSERV	                                                  	                                                  
//DTW->DTW_DATAJU	        	        
//DTW->DTW_HORAJU	    	    
DTW->DTW_HORATR	:= "000:00"

MsUnlock()

Return Nil