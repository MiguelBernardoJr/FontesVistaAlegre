#include "protheus.ch"

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
/*/{Protheus.doc} vesta004

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

user function vaest004(cIndividuo, cRacao, nQuant, cArmz, cArmzRac)
local aArea := GetArea()
local cMovTrat := GetMV("VA_MOVTRAT")
local cCC := GetMV("VA_CCPRDTR")
Local cIC:= GetMV("VA_ICPRDBA")
Local cClvl:= GetMV("VA_CLPRDBA")

default cArmz := ""
default cArmzRac := ""

cIndividuo := PadR(cIndividuo, TamSX3("B1_COD")[1])
cRacao := PadR(cRacao, TamSX3("B1_COD")[1])

DbSelectArea("SC2")
DbSetorder(1) // C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD

DbSelectArea("SB1")
DbSetOrder(1) // B1_FILIAL+B1_COD

DbSelectArea("SB2")
DbSetOrder(1) // B2_FILIAL+B2_COD+B2_LOCAL

if SB1->(DbSeek(xFilial("SB1")+cIndividuo))

    if Empty(cArmz)
        cArmz := SB1->B1_LOCPAD
    endif

    if SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+cArmz)) .and. SB2->B2_QATU > 0
        //if SB2->B2_QATU == 1 // não é possivel executar essa validação devido ao desvio de escopo. é necessário aceitar mais de um animal devido aos apontamentos nas fazendas.
            if SB1->(DbSeek(xFilial("SB1")+cRacao))
                if Empty(cArmzRac)
                    cArmzRac := SB1->B1_LOCPAD
                endif
                if SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+cArmzRac)) .and. nQuant <= SB2->B2_QATU
                    aEmpenho := { { cIndividuo,  cArmz,          1 },;
                                  { SB1->B1_COD, cArmzRac, nQuant } }
                    cNumOP := ""
                    cNumOP := u_CriaOp(cIndividuo, 1, cArmz)
                    u_LimpaEmp(cNumOP)
                    u_AjustEmp(cNumOP, aEmpenho)
                    u_ApontaOP(cNumOp, cMovTrat, cCC, cIC, cClvl)
                else
                    MsgStop("Não existe saldo suficiente para apontar a alimentação [" + AllTrim(cRacao) + "] do animal [" + AllTrim(cIndividuo) + "]." )
                endif
            else
                MsgStop("Racao [" + AllTrim(cRacao) + "] não foi encontrada no cadastro de produtos." )
            endif
        //else
        //    MsgStop("O Animal [" + AllTrim(cIndividuo) + "] possui saldo em estoque inválido para essa operação. Por favor verifique se o produto se trata de um animal." )
        //endif
    else
        MsgStop("O Animal [" + AllTrim(cIndividuo) + "] não possui saldo em estoque. Por favor verifique." )
    endif
else
    MsgStop("O Animal [" + AllTrim(cIndividuo) + "] não cadastrado. Por favor verifique." )
endif

return cNumOp
