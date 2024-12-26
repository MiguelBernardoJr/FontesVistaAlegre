#include "Protheus.ch"

#include "TopConn.ch"

// funcao para buscar dados de titulos compensados
// u_CTBCMPCR(SE5->(Recno()))
User Function CTBCMPCR(nE5Rec,cRetInfo) // recebe o 1-Recno do titulo, 2-qual informacao retornar
Local aArea 	:= GetArea()
Local aAreaE5 	:= SE5->(GetArea())
Local cRet 		:= "" // NAO CONCILIADO
Local cQuery    := ""
Local nE5Pref	:= TamSX3("E1_PREFIXO")[1] 
Local nE5Num	:= TamSX3("E1_NUM")[1]
Local nE5Parc	:= TamSX3("E1_PARCELA")[1]
Local nE5Tipo	:= TamSX3("E1_TIPO")[1] // chave do campo E5_DOCUMEN
Local nE5RecOld :=  SE5->(Recno())

	
	SE5->(DbGoTo(nE5Rec)) // Posiciona na SE5 conforme Recno

	// na LP 596, o titulo posicionado sera o RA, porem é necessário verificar
	 cQuery:=" SELECT *  FROM "+RetSqlName("SE5") + " "
	 cQuery+=" WHERE D_E_L_E_T_ <> '*' " 
	 cQuery+=" AND E5_FILIAL 	= '"+SE5->E5_FILIAL+"' " 
	 cQuery+=" AND E5_RECPAG 	= '"+SE5->E5_RECPAG+"' "
	 cQuery+=" AND E5_DATA 		= '"+DtoS(SE5->E5_DATA)+"' "
	 cQuery+=" AND E5_DTDIGIT 	= '"+DtoS(SE5->E5_DTDIGIT)+"' "
	 cQuery+=" AND E5_PREFIXO 	= '"+SE5->E5_PREFIXO+"' "
	 cQuery+=" AND E5_NUMERO 	= '"+SE5->E5_NUMERO+"' "
	 cQuery+=" AND E5_TIPO 		= '"+SE5->E5_TIPO+"' "
	 cQuery+=" AND E5_PARCELA	= '"+SE5->E5_PARCELA+"' "
	 cQuery+=" AND E5_TIPODOC	= '"+SE5->E5_TIPODOC+"' "
	 cQuery+=" AND E5_MOTBX		= '"+SE5->E5_MOTBX+"' "
	 cQuery+=" AND E5_SEQ		= '"+SE5->E5_SEQ+"' "
	
	If Select("E5CMP1") > 0
		E5CMP1->(DbCloseArea())
	EndIf
	TcQuery cQuery new Alias "E5CMP1"

//	memowrite("D:\TOTVS\Protheus_Data\data\E5CMP1.txt", cQuery)

	// na LP 596, o titulo posicionado sera o RA, porem é necessário verificar
	 cQuery:=" SELECT *  FROM "+RetSqlName("SE5") + " "
	 cQuery+=" WHERE D_E_L_E_T_ <> '*' " 
	 cQuery+=" AND E5_FILIAL 	= '"+E5CMP1->E5_FILIAL+"' " 
	 cQuery+=" AND E5_RECPAG 	= '"+E5CMP1->E5_RECPAG+"' "
	 cQuery+=" AND E5_DATA 		= '"+E5CMP1->E5_DATA+"' "
	 cQuery+=" AND E5_DTDIGIT 	= '"+E5CMP1->E5_DTDIGIT+"' "
	 cQuery+=" AND E5_PREFIXO 	= '"+SUBSTR(SE5->E5_DOCUMEN,1,nE5Pref)+"' "
	 cQuery+=" AND E5_NUMERO 	= '"+SUBSTR(SE5->E5_DOCUMEN,1+nE5Pref,nE5Num)+"' "
	 cQuery+=" AND E5_PARCELA 	= '"+SUBSTR(SE5->E5_DOCUMEN,1+nE5Pref+nE5Num,nE5Parc)+"' "
	 cQuery+=" AND E5_TIPO		= '"+SUBSTR(SE5->E5_DOCUMEN,1+nE5Pref+nE5Num+nE5Parc,nE5Tipo)+"' "
	 cQuery+=" AND E5_TIPODOC	= '"+iif(E5CMP1->E5_TIPODOC=='BA','CP','BA')+"' "
	 cQuery+=" AND E5_MOTBX		= 'CMP' "
	 cQuery+=" AND E5_SEQ		= '"+E5CMP1->E5_SEQ+"' "

	If Select("E5CMP2") > 0
		E5CMP2->(DbCloseArea())
	EndIf
	TcQuery cQuery new Alias "E5CMP2"

//	memowrite("D:\TOTVS\Protheus_Data\data\E5CMP2.txt", cQuery)


	// Encontrando Titulo na Se1, para buscar observacao
	 cQuery:=" SELECT *  FROM "+RetSqlName("SE1") + " "
	 cQuery+=" WHERE D_E_L_E_T_ <> '*' " 
	 cQuery+=" AND E1_FILIAL 	= '"+E5CMP2->E5_FILORIG +"' " 
	 cQuery+=" AND E1_PREFIXO 	= '"+E5CMP2->E5_PREFIXO +"' "
	 cQuery+=" AND E1_NUM	 	= '"+E5CMP2->E5_NUMERO  +"' "
	 cQuery+=" AND E1_TIPO 		= '"+E5CMP2->E5_TIPO    +"' "
	 cQuery+=" AND E1_PARCELA	= '"+E5CMP2->E5_PARCELA +"' "
	 cQuery+=" AND E1_CLIENTE	= '"+E5CMP2->E5_CLIFOR  +"' "
	 cQuery+=" AND E1_LOJA		= '"+E5CMP2->E5_LOJA    +"' "

	If Select("E1CMP") > 0
		E1CMP->(DbCloseArea())
	EndIf
	TcQuery cQuery new Alias "E1CMP"

//	memowrite("D:\TOTVS\Protheus_Data\data\E1CMP.txt", cQuery)

	// busca historico no titulo principal para retornar no LP 596 e complementar a observacao do lancamento contabil
	cRet := Alltrim(E1CMP->E1_HIST)


	If Select("E5CMP1") > 0
		E5CMP1->(DbCloseArea())
	EndIf
	If Select("E5CMP2") > 0
		E5CMP2->(DbCloseArea())
	EndIf
	If Select("E1CMP") > 0
		E1CMP->(DbCloseArea())
	EndIf
    
	SE5->(DbGoTo(nE5RecOld)) // Posiciona na SE5 conforme Recno
	RestArea(aAreaE5)
	RestArea(aArea)
Return cRet

