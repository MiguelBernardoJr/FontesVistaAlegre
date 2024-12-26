//**********************************************
//RELATORIO DE TITULOS PAGOS
//**********************************************
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"  
#INCLUDE "RWMAKE.CH"    

//Busca Observacao na SC7 sem duplicidade;
User Function SC7OBS(cC7Fil, cC7Num)
Local aArea		:= GetArea()    
Local cQuery	:= ""
Local cC7Obs	:= ""

	cQuery		:= " SELECT C7_FILIAL, C7_NUM, C7_ITEM, C7_PRODUTO, C7_OBS "
	cQuery		+= " FROM " + RetSqlName("SC7") + " SC7 "
	cQuery		+= " WHERE  C7_NUM BETWEEN '" + cC7Num + "' AND '" + cC7Num + "' "
	cQuery		+= " AND C7_FILIAL = '" + cC7Fil +" '
	cQuery		+= " AND D_E_L_E_T_ = ''
	cQuery		+= " AND C7_OBS <> ''
	
	If Select("QSC7") <> 0
		QSC7->(dbCloseArea())
	Endif

	TcQuery cQuery NEW ALIAS "QSC7"
	dbSelectArea("QSC7")
	dbGotop()
	
	While !Eof()     
		If !Empty(QSC7->C7_OBS) 
			If !(Alltrim(QSC7->C7_OBS)$cC7Obs)
				cC7Obs += Iif(Empty(cC7Obs), Alltrim(QSC7->C7_OBS),  '  -  ' + Alltrim(QSC7->C7_OBS))
			Endif
		Endif
		QSC7->(dbSkip())
	EndDo          
	
	QSC7->(DbCloseArea())

RestArea(aArea)
Return cC7Obs