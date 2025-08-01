#include "totvs.ch"


/*----------------------------------------------------------------------
 Ponto de Entrada: PE01NFESEFAZ
 Objetivo: Limpar os campos B1_CODBAR e B1_CODGTIN de cada item
----------------------------------------------------------------------*/
User Function PE01NFESEFAZ()
    // Area Automatica
    Local aArea	   := Lj7GetArea({"SC5","SC6","SB1","SF4","SD2"})
    Local i

	Local aProd		:= PARAMIXB[1]
	Local cMensCli	:= PARAMIXB[2]
	Local cMensFis	:= PARAMIXB[3]
	Local aDest 	:= PARAMIXB[4]
	Local aNota 	:= PARAMIXB[5]
	Local aInfoItem := PARAMIXB[6]
	Local aDupl		:= PARAMIXB[7]
	Local aTransp	:= PARAMIXB[8]
	Local aEntrega	:= PARAMIXB[9]
	Local aRetirada	:= PARAMIXB[10]
	Local aVeiculo	:= PARAMIXB[11]
	Local aReboque	:= PARAMIXB[12]
	Local aNfVincRur:= PARAMIXB[13]
	Local aEspVol 	:= PARAMIXB[14]
	Local aNfVinc 	:= PARAMIXB[15]
	Local aDetPag 	:= PARAMIXB[16]
	Local aObsCont 	:= PARAMIXB[17]
	Local aProcRef 	:= PARAMIXB[18]
	Local aMed 		:= PARAMIXB[19]
	Local aLote 	:= PARAMIXB[20]

	local aRetOrd		:= {}

    For i := 1 To Len(aProd)
        // se o registro tiver esses índices, zera; senão, continua
        If SB1->(FieldPos("B1_CODBAR")) > 0
            aProd[i][ 03 ] := CriaVar("B1_CODBAR")
        EndIf
        If SB1->(FieldPos("B1_CODGTIN")) > 0
            aProd[i][ 46 ] := CriaVar("B1_CODGTIN")
        EndIf
    Next

	// aRetOrd := {aICMS, aICMSST, aIPI, aPIS, aPISST, aCOFINS, aCOFINSST, aISSQN, aCST, aMed, aArma, aveicProd, aDI, aAdi, aExp, aPisAlqZ, aCofAlqZ, aAnfI, aComb, aCsosn, aICMUFDest, aPedCom, aCSTIPI, aICMSZFM, aRetido}

    Lj7RestArea(aArea)

Return({aProd,cMensCli,cMensFis,aDest,aNota,aInfoItem,aDupl,aTransp, aEntrega, aRetirada,aVeiculo,aReboque,aNfVincRur,aEspVol,aNfVinc,aDetPag,aObsCont,aProcRef,aMed,aLote,aRetOrd})
