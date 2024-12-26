#Include "Protheus.ch"
#include "Tbiconn.ch"
#include "TopConn.ch"

/*/{Protheus.doc} User Function VlrAbast
	Função chamada no X3_VLDUSER do campo TQQ_QUANT e TQN_FROTA para ver se trata-se de Veiculo de Terceiro
	T9_PROPRIE igual a 2
	@type  Function
	@author Manoel Filho
	@since 20/02/2022
	@version version
	@return 
/*/
User Function VlrAbast()
local lRet := .t.
local cQuery := ""
local nPOSTTABA := 0

If Type("nLanca") == "U"
	return lRet
Endif


If !FM_PILHA("MNTA656")
	return lRet
Endif

If nLanca == "Produto"

	nPOSTTABA := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TL_VTTABA"})
	nPOSVUABA := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TL_VUNABA"})
	nPOSFORT9 := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TL_FORST9"})
	nPOSLOJT9 := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TL_LOJST9"})

Else

	nPOSTTABA := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TQN_VTTABA"})
	nPOSVUABA := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TQN_VUNABA"})
	nPOSFORT9 := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TQN_FORST9"})
	nPOSLOJT9 := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TQN_LOJST9"})

Endif

aCols[n][nPOSFORT9] := ""
aCols[n][nPOSLOJT9] := ""
aCols[n][nPOSVUABA] := 0
aCols[n][nPOSTTABA] := 0

// Verifica se é de terceiro
If Select("TMPST9") > 0
	TMPST9->(dbCloseArea())
EndIf

cQuery := "SELECT ST9.T9_PROPRIE, ST9.T9_FORNECE, ST9.T9_LOJA "
cQuery += " FROM "+RetSqlName("ST9")+" ST9 "
If ReadVar() == "M->TQN_FROTA"
	cQuery += " WHERE ST9.T9_FILIAL='"+xFilial("ST9")+"' AND ST9.T9_CODBEM = '"+M->TQN_FROTA+"' AND ST9.T9_CODBEM LIKE 'TERCEIRO%'" 
Else
	cQuery += " WHERE ST9.T9_FILIAL='"+xFilial("ST9")+"' AND ST9.T9_CODBEM = '"+aCols[n][nPOSFROTA]+"' AND ST9.T9_CODBEM LIKE 'TERCEIRO%'" 
Endif
DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(cQuery)), "TMPST9", .f., .f.)

If !TMPST9->(Eof()) // é veículo de Terceiro

	If TMPST9->T9_PROPRIE <> '2' 
		MsgInfo("Este veículo está cadastrado com nome TERCEIRO, porém o Proprietário está como Próprio! Favor corrigir o cadastro do veículo!","Atenção")
		lRet := .f.
	Endif

	If lRet

		// Busca preço vigente do combustivel
		If Select("TMPZAT") > 0
			TMPZAT->(dbCloseArea())
		EndIf
		cQuery := "SELECT ZAT_VALCOM "
		cQuery += " FROM "+RetSqlName("ZAT")+" ZAT "
		If nLanca == "Produto"
			cQuery += " WHERE ZAT.ZAT_FILIAL='"+xFilial("ZAT")+"' AND ZAT.ZAT_CODCOM = '007'"
		Else
			cQuery += " WHERE ZAT.ZAT_FILIAL='"+xFilial("ZAT")+"' AND ZAT.ZAT_CODCOM = '"+cCODCOM+"'"
		Endif
		cQuery += " AND ZAT.ZAT_DATCAD <= '"+Dtos(aCols[n][nPOSDATAB])+"' AND ZAT.D_E_L_E_T_ = ' '"
		DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(cQuery)), "TMPZAT", .f., .f.)

		aCols[n][nPOSFORT9] := TMPST9->T9_FORNECE
		aCols[n][nPOSLOJT9] := TMPST9->T9_LOJA
		If !TMPZAT->(Eof())
			aCols[n][nPOSVUABA] := TMPZAT->(ZAT_VALCOM)

			If nLanca == "Produto"

				If ReadVar() == "M->TQN_FROTA"
					nPosP := aSCAN(aHeader,{|x| Trim(Upper(x[2])) == "TPE_AJUSCO"})
					aCols[n][nPOSTTABA] := aCols[n][nPosP] * TMPZAT->(ZAT_VALCOM)
				Else
					aCols[n][nPOSTTABA] := M->TPE_AJUSCO * TMPZAT->(ZAT_VALCOM)
				Endif

			Else

				If ReadVar() == "M->TQN_FROTA"
					aCols[n][nPOSTTABA] := aCols[n][nPOSQUANT] * TMPZAT->(ZAT_VALCOM)
				Else
					aCols[n][nPOSTTABA] := M->TQQ_QUANT * TMPZAT->(ZAT_VALCOM)
				Endif

			Endif

		else
			If MsgYesNo("Não existe Preço de Combustível cadastrado para esta data! Deseja Continuar?", "Atenção")
				lRet := .t.
			Else
				lRet := .f.
			Endif
		Endif
		TMPZAT->(dbCloseArea())

	Endif

Endif
TMPST9->(dbCloseArea())

Return lRet
