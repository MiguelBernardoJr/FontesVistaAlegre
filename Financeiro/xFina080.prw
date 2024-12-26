#include "TOTVS.CH"
#include "TOPCONN.CH"

User Function xFina080(cBancoA,cAgencA,cContaA,cIdPgto)
	Local lMsErroAuto	:= .F.
	Local nVlrPag		:= 0
	Local cHistBaixa 	:= "PGTO PROF - ID PG: " + cIdPgto
	Local aBaixa 		:= {}
    
	If lRet := SE2->E2_SALDO > 0
		nVlrPag := SE2->E2_SALDO
	EndIf

	if lRet
		AADD(aBaixa, {"E2_FILIAL" 	, SE2->E2_FILIAL 	, Nil})
		AADD(aBaixa, {"E2_PREFIXO" 	, SE2->E2_PREFIXO 	, Nil})
		AADD(aBaixa, {"E2_NUM" 		, SE2->E2_NUM 		, Nil})
		AADD(aBaixa, {"E2_PARCELA" 	, SE2->E2_PARCELA 	, Nil})
		AADD(aBaixa, {"E2_TIPO" 	, SE2->E2_TIPO 		, Nil})
		AADD(aBaixa, {"E2_FORNECE" 	, SE2->E2_FORNECE 	, Nil})
		AADD(aBaixa, {"E2_LOJA" 	, SE2->E2_LOJA 		, Nil})
		AADD(aBaixa, {"AUTMOTBX" 	, "NOR" 		, Nil})
		AADD(aBaixa, {"AUTBANCO" 	, cBancoA 		, Nil})
		AADD(aBaixa, {"AUTAGENCIA" 	, cAgencA 		, Nil})
		AADD(aBaixa, {"AUTCONTA" 	, cContaA 		, Nil})
		AADD(aBaixa, {"AUTDTBAIXA" 	, dDataBase 	, Nil})
		AADD(aBaixa, {"AUTDTCREDITO", dDataBase 	, Nil})
		AADD(aBaixa, {"AUTHIST" 	, cHistBaixa 	, Nil})
		AADD(aBaixa, {"AUTVLRPG" 	, SE2->E2_SALDO , Nil})
		
		ACESSAPERG("FIN080", .F.)
		MSEXECAUTO({|x,y| FINA080(x,y)}, aBaixa, 3)

		If lMsErroAuto
			MostraErro()
		Else
			Alert("Baixa efetuada com sucesso")
		EndIf
	else
		Alert("O título não possui saldo a pagar em aberto")
	endif 

Return !lMsErroAuto
