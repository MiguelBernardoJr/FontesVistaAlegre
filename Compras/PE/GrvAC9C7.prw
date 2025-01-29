#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "font.ch"
#include "colors.ch"


User Function GrvAC9C7(xC7Fil, xC7Num, xA2Fil, xA2Cod, xA2Loja)
Local aArea 	:= GetArea()
Local cQuery	:= ''


	cQuery	+= " SELECT DISTINCT AC9_FILIAL, AC9_CODOBJ "
	cQuery	+= " FROM  " +RetSqlName("AC9") + " AC9P "
	cQuery	+= " WHERE AC9P.D_E_L_E_T_ = '' "
	cQuery	+= " AND AC9P.AC9_ENTIDA = 'SC7' "
	cQuery	+= " AND AC9P.AC9_FILENT = '"+xC7Fil+"'  "
	cQuery	+= " AND SUBSTRING(AC9P.AC9_CODENT,1,8) = '"+ xC7Fil+xC7Num + "' "
	cQuery	+= " AND AC9P.AC9_CODOBJ NOT IN 
	cQuery	+= "  ( SELECT DISTINCT AC9F.AC9_CODOBJ  
	cQuery	+= " FROM " +RetSqlName("AC9") + " AC9F "
	cQuery	+= " WHERE AC9F.D_E_L_E_T_ = '' "
	cQuery	+= " AND AC9F.AC9_ENTIDA = 'SA2' "
	cQuery	+= " AND SUBSTRING(AC9F.AC9_CODENT,1,8) = '" + xA2Fil+xA2Cod+xA2Loja + "' ) "


	If Select("TAC9") <> 0
		TAC9->(dbCloseArea())
	Endif
	TCQuery cQuery Alias "TAC9" New
	
	dbSelectArea("TAC9")
	TAC9->(dbGotop())
	
	Do While !(TAC9->(EOF()))
		// Testar com Dbseek se existe ou nao
		RecLock("AC9",.T.)
			AC9_FILIAL 		:= xFilial("AC9")
			AC9_FILENT  	:= xFilial("SA2")
			AC9_ENTIDA		:= "SA2"
			AC9_CODENT  	:= xA2Fil+xA2Cod+xA2Loja
			AC9_CODOBJ		:= TAC9->AC9_CODOBJ	     
		AC9->(MSUnLock())
		TAC9->(dbSkip())
	Enddo


RestArea(aArea)
Return Nil