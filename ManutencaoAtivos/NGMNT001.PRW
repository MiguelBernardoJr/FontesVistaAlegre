#INCLUDE "PROTHEUS.CH"
// ###############################################################################################
// Projeto: 
// Fonte  : NGMNT001.prw
// ---------+------------------------------------+------------------------------------------------
// Data     | Autor                              | Descricao
// ---------+------------------------------------+------------------------------------------------
//  12/04/22|  Manoel Filho                      | Gravação dos campos custmizados da tabela STL
// ---------+------------------------------------+------------------------------------------------
 
User Function NGMNT001()

// O Parãmetro não foi utilizado. 
// Foi preciso ler o aCols inteiro a cada passagem aqui. E a chamada deste PE é o FOR do aCols.
// Sabemos que assim fica redundante, mas é a única forma, pois não existe acesso ao nro da linha do aCols.

// Local aChaveSTL := ParamIXB[1]
// Local cFilial   := aChaveSTL[1]
// Local cOrdem    := aChaveSTL[2]
// Local cPlano    := aChaveSTL[3]
// Local cTarefa   := aChaveSTL[4]
// Local cTipoReg  := aChaveSTL[5]
// Local cCodigo   := aChaveSTL[6]
// Local cSeqRela  := aChaveSTL[7]
// Local cSeqTare  := aChaveSTL[8]

Local cQuery    := ""
Local nCntFor   := 0
Local nPOSNRABA := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TL_NRABAS"})
Local nPOSVUABA := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TL_VUNABA"})
Local nPOSTTABA := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TL_VTTABA"})
Local nPOSFORT9 := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TL_FORST9"})
Local nPOSLOJT9 := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TL_LOJST9"})
Local nPOSCOABA := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TL_COBABA"})
Local nRecSavSTL := STL->(Recno())

If FunName() == "MNTA656" .and. nLanca == "Produto"

	For nCntFor := 1 to Len(acols)

		cQuery := "SELECT STL.R_E_C_N_O_ RECSTL FROM " + RetSQLName( "STL" ) + " STL"
		cQuery += "	 JOIN "+RetSqlName("STJ")+" STJ ON "
		cQuery += "	     STJ.TJ_FILIAL = '"+xFilial("STJ")+ "' "
		cQuery += "	 AND STJ.TJ_ORDEM = STL.TL_ORDEM "
		cQuery += "	 AND STJ.TJ_PLANO = STL.TL_PLANO AND STJ.D_E_L_E_T_ = ' '"
		cQuery += " WHERE STL.TL_FILIAL = '"+xFilial("STL")+"' 
		cQuery += "  AND STL.TL_CODIGO = '130011' AND STL.D_E_L_E_T_ = ' ' 
		cQuery += " AND STJ.TJ_CODBEM   = '" + aCols[nCntFor,nPOSFROTA] + "' "
		cQuery += " AND STJ.D_E_L_E_T_ = ' ' "
		cQuery += " AND STJ.TJ_SERVICO = 'C00014' "
		cQuery += " ORDER BY 1 DESC"
		DbUseArea(.t., "TOPCONN", TCGenQry(,,cQuery), "TMPSTL", .f., .f.)

		If TMPSTL->( !EoF() )
			STL->(DbGoTo(TMPSTL->(RECSTL)))
			RecLock("STL",.f.)
			STL->TL_NRABAS := aCols[nCntFor][nPOSNRABA]
			STL->TL_VUNABA := aCols[nCntFor][nPOSVUABA]
			STL->TL_VTTABA := aCols[nCntFor][nPOSTTABA]
			STL->TL_FORST9 := aCols[nCntFor][nPOSFORT9]
			STL->TL_LOJST9 := aCols[nCntFor][nPOSLOJT9]
			STL->TL_COBABA := aCols[nCntFor][nPOSCOABA]
			MsUnlock()
		EndIf
		TMPSTL->( dbCloseArea() )

	Next

Endif

STL->(DbGoTo(nRecSavSTL))

Return .T.
