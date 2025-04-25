#include "protheus.ch"

#IFNDEF _ENTER_
	#DEFINE _ENTER_ (Chr(13)+Chr(10))
	// Alert("miguel")
#ENDIF 

//##########################################################################################
// Projeto: AVA1000002 - AVA- APONTAMENTOS CUSTO RACAO E ANIMAIS 
// Modulo : Estoque/Custos
// Fonte  : vaest021
//----------+------------------------------+------------------------------------------------
// Data     | Autor                        | Descricao
//----------+------------------------------+------------------------------------------------
// 20170310 | jrscatolon informatica       | Criação do apontamento de alimentação de lotes
//          |                              | 
//          |                              | 
//----------+-------------------------------------------------------------------------------

/*
 * CRIAR PARAMETROS
 * ----------------
 * Parametro:     VA_MOVTRAT
 * Tipo:          C
 * Descrição:     Parametro customizado usado pela rotina vaest004. Tipo de movimento (SF5) utilizado para apontamento automatizado de trato.
 *
 * Parametro:     VA_CCPRDTR
 * Tipo:          C
 * Descrição:     Parametro customizado usado pela rotina vaest004. Centro de custo utilizado para apontamento automatizado da Alimentação.
 *
 * Parametro:     VA_ICPRDTR
 * Tipo:          C
 * Descrição:     Parâmetro customizado usado pela rotina vaest004. Item contabil utilizado para apontamento automatizado da batida. 
 * 
 * Parametro:     VA_CLPRDTR
 * Tipo:          C
 * Descrição:     Parâmetro customizado usado pela rotina vaest004. Classe de valor utilizado para apontamento automatizado da batida. 
 */
/*/{Protheus.doc} vesta021

 Apontamento de alimentação de animais

@type function
@author JRScatolon Informatica

@param cIndividuo, Caractere, Código do produto do animal envolvido
@param cRacao, Caractere, Código do produto ração usado na alimentação
@param nQuant, Numérico, quantidade de ração usada na alimentação

@return numero da ordem de produção

@obs Caso seja criada a variável cNumOP como privada essa função irá preencher o numero da ordem de produção no momento de sua criação
@obs A função lançará uma excessão em caso de erro.
/*/

user function vaest021(cIndividuo, nQtdIndiv, cArmz, cRacao, nQuant, cArmzRac, cLoteCTL )
local aArea 	    := GetArea()
local cMovTrat      := GetMV("VA_MOVTRAT")
local cCC 	 	    := GetMV("VA_CCPRDTR")
local cIC		    := GetMV("VA_ICPRDBA")
local cClvl		    := GetMV("VA_CLPRDBA")
local nQtdIndiv     := 0
Local lContinua     := .F.
Local nI            := 0
Local cAlias        := "", _cQry  := ""
Local aCampos		:= {}, aDados := {}

Default cArmz 		:= ""
Default cArmzRac 	:= ""
Default cLoteCTL	:= ""

If Type("__DATA") == "U"
	Private __DATA		:= iIf(IsInCallStack("U_JOBPrcLote"), MsDate(), dDataBase)
EndIf
If Type("cFile") == "U"
	Private cFile 		:= "C:\TOTVS_RELATORIOS\JOBPrcLote_" + DtoS(__DATA) + ".TXT"
EndIf

cIndividuo := PadR(cIndividuo, TamSX3("B1_COD")[1])
cRacao := PadR(cRacao, TamSX3("B1_COD")[1])

DbSelectArea("SC2")
DbSetorder(1) // C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD

DbSelectArea("SB1")
DbSetOrder(1) // B1_FILIAL+B1_COD

DbSelectArea("SB8")
DbSetOrder(1) // B8_FILIAL+B8_COD+B8_LOCAL

if SB1->(DbSeek(xFilial("SB1")+cIndividuo))

    if Empty(cArmz)
        cArmz := SB1->B1_LOCPAD
    endif
	
	SB8->(DbSetOrder(3)) // B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL+B8_NUMLOTE+DTOS(B8_DTVALID)
    if SB8->(DbSeek(xFilial("SB8")+SB1->B1_COD+cArmz+cLoteCTL )) 
		While SB8->(B8_FILIAL+B8_PRODUTO+B8_LOCAL+B8_LOTECTL) == xFilial("SB8")+SB1->B1_COD+cArmz+cLoteCTL 
			If SB8->B8_SALDO > 0
				lContinua := .T.
				exit
			EndIf
			SB8->(DbSkip())
		EndDo
	EndIf
	
	If lContinua
        if Empty(nQtdIndiv)
            nQtdIndiv := SB8->B8_SALDO
        endif
        if SB1->(DbSeek(xFilial("SB1")+cRacao))
            if Empty(cArmzRac)
                cArmzRac := SB1->B1_LOCPAD
            endif
            if SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+cArmzRac)) ;
				.and. ( nQuant <= SB2->B2_QATU .or. ABS(nQuant-SB2->B2_QATU)<=GetMV("VA_DIFTRAT",,1) )
				
				If nQuant > SB2->B2_QATU .or. ABS(nQuant-SB2->B2_QATU)<=GetMV("VA_DIFTRAT",,1)
					Conout("PRODUTO 		[" + AllTrim(cRacao) + "]")
					Conout("nQuant 			[" + cValToChar(nQuant) + "]")
					Conout("SB2->B2_QATU 	[" + cValToChar(SB2->B2_QATU) + "]")
					Conout("DIFERENCA 		[" + cValToChar(ABS(nQuant-SB2->B2_QATU)) + "]")
					Conout("VA_DIFTRAT 		[" + cValToChar(GetMV("VA_DIFTRAT",,1)) + "]")

					nQuant := SB2->B2_QATU
				EndIf

                aEmpenho := { { cIndividuo, cArmz, nQtdIndiv, cLoteCTL },;
                              { SB1->B1_COD, cArmzRac, nQuant, "" } }
                
                aDados  := {}
                aCampos := U_LoadCustomCpo("SB8")
                For nI := 1 to Len(aCampos)
					aAdd( aDados, { aCampos[nI], SB8->&(aCampos[nI]) } )
				Next nI
				
				U_GravaArq( iIf(IsInCallStack("U_JOBPrcLote"), cFile, ""),;
							cMsg := "[VAEST021] Cria OP: " + AllTrim(cIndividuo),;
							.T./* lConOut */,;
							/* lAlert */ )
				cNumOP := ""
				FWMsgRun(, {|| cNumOP := u_CriaOp(cIndividuo, nQtdIndiv, cArmz) },;
								"Processando [VAEST003]",;
								cMsg )
                u_LimpaEmp(cNumOP)
                u_AjustEmp(cNumOP, aEmpenho)
				
				U_GravaArq( iIf(IsInCallStack("U_JOBPrcLote"), cFile, ""),;
							cMsg := "Processando [VAEST003]"+_ENTER_+"Apontamento OP: " + AllTrim(cNumOp),;
							.T./* lConOut */,;
							/* lAlert */ )
				FWMsgRun(, {|| u_ApontaOP(cNumOp, cMovTrat, cCC, cIC, cClvl, cLoteCTL, SB8->B8_X_CURRA ) },;
								"Processando [VAEST003]",;
								"Apontamento OP: " + AllTrim(cNumOp) )
				
				// MJ : 09.02.2018 : atualizar os campos customizados do NOVO registro SB8 gerado a partir do processamento do lote;
				_cQry := " SELECT MAX(R_E_C_N_O_) RECNO
				_cQry += " FROM "+ RetSqlName('SB8')
				_cQry += " WHERE B8_FILIAL ='"+xFilial("SB8")+"' 
				_cQry += " 	 AND B8_PRODUTO='"+cIndividuo+"'
				_cQry += " 	 AND B8_LOTECTL='"+cLoteCTL+"'
				_cQry += " 	 AND D_E_L_E_T_=' '
				
				cAlias        := GetNextAlias()
				DbUseArea(.T.,'TOPCONN',TCGENQRY(,,ChangeQuery(_cQry)),(cAlias),.T.,.T.)
                If !(cAlias)->(Eof())
					SB8->(DbGoTo((cAlias)->RECNO))
					
					RecLock("SB8", .F.)
						For nI := 1 to Len(aDados)
							SB8->&(aDados[nI,1]) := aDados[nI, 2]
						Next nI
					SB8->(MsUnLock())
				EndIf
				(cAlias)->(DbCloseArea())
				
            else
                MsgStop("Não existe saldo suficiente para apontar a alimentação [" + AllTrim(cRacao) + "] do animal [" + AllTrim(cIndividuo) + "]." )
            endif
        else
            MsgStop("Racao [" + AllTrim(cRacao) + "] não foi encontrada no cadastro de produtos." )
        endif
    else
        MsgStop("O Animal [" + AllTrim(cIndividuo) + "] no lote [" + AllTrim(cLoteCTL) + "] não possui saldo em estoque no armazém [" + cArmz + "] para a filial [" + xFilial("SB8") + "]. Por favor verifique." )
    endif
	lContinua 	:= .F.
	
else
    MsgStop("O Animal [" + AllTrim(cIndividuo) + "] não cadastrado. Por favor verifique." )
endif

RestArea(aArea)

return cNumOp

