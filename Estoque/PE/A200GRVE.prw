#include "RWMake.ch"
#include "Protheus.ch"
#include "TopConn.ch"

user function MT200GRE()//P200GRAV()//A200GRVE()
// local nOpc := ParamIXB[1]
local aArea := GetArea()
local cTime := ""
local cSeq  := ""
Local cProd := ""

cProd := SG1->G1_COD
// Cria ZG1 caso não exista
DBSelectArea("ZG1")
ZG1->(DBSetOrder(1))
// paramIXB[1] -> N, nOpc
// paramIXB[2] -> L, Mapa de divergências ativo
// paramIXB[3] -> A, RECNO de cada componente excluído da tabela SG1 p/ nOpc == 5
// paramIXB[4] -> A, {RECNO do registro, [1- Inclusão, 2- Exclusão, 3- Alteração]}

// se for inclusão ou alteração e houve alguma operação com registro da SG1
// Calcula nova sequência
cSeq := u_NextSeq("G1_SEQ")

//if (ParamIXB[1] == 3 .or. ParamIXB[1] == 4) //.and. !Empty(ParamIXB[4])
begin transaction
While  !SG1->(EoF()) .and. SG1->G1_COD = cProd
    
        RecLock("ZG1", .F.)
            SG1->G1_SEQ := CSeq 
        MsUnlock()
        
    
    // Atualiza campo sequência da estrutura
    //TCSqlExec("update " + RetSqlName("SG1") +;
    //               " set G1_ENERG = " + AllTrim(Str(M->G1_ENERG)) +;
    //                  ", G1_SEQ = '" + cSeq + "'" +;
    //             " where G1_FILIAL = '" + FWxFilial("SG1") + "'" +;
    //               " and G1_COD = '" + cProduto + "'" +;
    //               " and D_E_L_E_T_ = ' '" ;
    //             )
    
    // Cria historico da estrutura
    /*
    DbUseArea(.t., "TOPCONN", TCGenQry(,,;
                              " select G1_FILIAL, G1_COD, G1_COMP, G1_TRT, G1_QUANT, G1_PERDA, G1_INI, G1_FIM, G1_OBSERV, G1_FIXVAR, G1_GROPC"+;
                                    ", G1_OPC, G1_REVINI, G1_REVFIM, G1_NIV, G1_NIVINV, G1_POTENCI, G1_VECTOR, G1_OK, G1_TIPVEC, G1_VLCOMPE"+;
                                    ", G1_ENERG, G1_SEQ " +;
                                " from " + RetSqlName("SG1") + " SG1" +;
                               " where SG1.G1_FILIAL = '" + FWxFilial("SG1") + "'" +;
                                 " and SG1.G1_COD = '" + SG1->G1_COD + "'" +;
                                 " and SG1.G1_SEQ = '" + cSeq + "'" +;
                                 " and SG1.D_E_L_E_T_ = ''" ;
                                         ), "TMPSG1", .f., .t.) 
                                         */
        cTime := Time()
        //while !TMPSG1->(Eof())

            
            RecLock("ZG1", .t.)
                ZG1->ZG1_FILIAL := SG1->G1_FILIAL
                ZG1->ZG1_COD    := SG1->G1_COD
                ZG1->ZG1_COMP   := SG1->G1_COMP
                ZG1->ZG1_TRT    := SG1->G1_TRT
                ZG1->ZG1_QUANT  := SG1->G1_QUANT
                ZG1->ZG1_PERDA  := SG1->G1_PERDA
                ZG1->ZG1_INI    := SG1->G1_INI
                ZG1->ZG1_FIM    := SG1->G1_FIM
                ZG1->ZG1_OBSERV := SG1->G1_OBSERV
                ZG1->ZG1_FIXVAR := SG1->G1_FIXVAR
                ZG1->ZG1_GROPC  := SG1->G1_GROPC
                ZG1->ZG1_OPC    := SG1->G1_OPC
                ZG1->ZG1_REVINI := SG1->G1_REVINI
                ZG1->ZG1_REVFIM := SG1->G1_REVFIM
                ZG1->ZG1_NIV    := SG1->G1_NIV
                ZG1->ZG1_NIVINV := SG1->G1_NIVINV
                ZG1->ZG1_POTENC := SG1->G1_POTENCI
                ZG1->ZG1_VECTOR := SG1->G1_VECTOR
                ZG1->ZG1_OK     := SG1->G1_OK
                ZG1->ZG1_TIPVEC := SG1->G1_TIPVEC
                ZG1->ZG1_VLCOMP := SG1->G1_VLCOMPE
                ZG1->ZG1_ENERGI := SG1->G1_ENERG
                ZG1->ZG1_ORIGEM := SG1->G1_ORIGEM
                ZG1->ZG1_SEQ    := SG1->G1_SEQ
                ZG1->ZG1_DTALT  := Date()
                ZG1->ZG1_HRALT  := cTime
                ZG1->ZG1_CODUSU :=  __cUserId
            MsUnlock()
            //TMPSG1->(DbSkip())
        //end
    //TMPSG1->(DbCloseArea())
    
    SG1->(DbSkip())
    End
    end transaction
    //Alert("fim")
//endif


RestArea(aArea)
return .t.

