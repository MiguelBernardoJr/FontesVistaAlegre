#include "protheus.ch"
#INCLUDE "MATA170.CH"
/*---------------------------------------------------------------------------------,
 | Analista : Igor Gomes OLiveira                                                  |
 | Data		: 27.06.2024                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Inclusão de solicitações do compras (MATA170)                        |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
'---------------------------------------------------------------------------------*/

User Function VAJOB18()
    ConOut('VAJOB13(): ' + Time())
	
	If Type("oMainWnd") == "U"
		ConOut('oMainWnd: ' + Time())
		U_RunFunc("U_JOB18VA()",'01','01',3) 
	Else
		ConOut('Else oMainWnd: ' + Time())
		U_JOB18VA()
	EndIf
Return
User Function JOB18VA()
    Local aParam    := {}
    Local lAuto     := .T.
    Local cQry      := ""
    Local cAlias    := GetNextAlias()

    Private lMsErroAuto    := .F.
    Private lAutoErrNoFile := .T.

    aParam := {;
        Space(TamSx3("B1_COD")[1]),;               //Produto de
        "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ",;  //Produto ate
        "",;                                //Grupo de 
        "ZZZZ",;                            //Grupo ate
        "",;                                //Tipo de
        "ZZ",;                              //Tipo ate
        "",;                                //Local de
        "ZZ",;                              //Local ate
        1,;                                 //Considera Necess Bruta 1 sim
        1,;                                 //Saldo Neg Considera    1 sim
        cToD(""),;                          //Data limite p/ empenhos
        2,;                                 //Cons.Qtd. De 3os.? Sim / Nao
        2,;                                 //Cons.Qtd. Em 3os.? Sim / Nao
        1,;                                 //Ao atingir Estoque Maximo ?
        2,;                                 //Quebra SC por Lote Econmico?
        2,;                                 //Qtd.PV nao Liberado?" Subtr/Ignora
        "01",;                              //Considera Saldo Armazem de 
        "01",;                              //Considera Saldo Armazem ate
        2,;                                 //Seleciona Filiais? (Sim/Nao)
        2,;                                 //Gera SC por produto(Sim/Nao)
        2,;                                 //Considera Est. Seguranca ?  ³ (Sim / Nao)
        1;                                  //Prioriza geração de         ³ (1-Sol.Compra/2-Ped.Compra)
    }

    cQry := "SELECT X5_CHAVE, X5_DESCRI FROM SX5010 WHERE X5_TABELA = 'Z9' AND D_E_L_E_T_ = '' ORDER BY X5_CHAVE"

    MpSysOpenQuery(cQry,cAlias)

    While !(cAlias)->(EOF())
        
        aParam[3] := (cAlias)->X5_CHAVE
        aParam[4] := (cAlias)->X5_CHAVE

        lProc := Processa( MATA170(lAuto,aParam) )

        (cAlias)->(DbSkip())
    Enddo

    (cAlias)->(DBCLOSEAREA())

return
