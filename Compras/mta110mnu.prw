#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc}u_MTA110Mnu
    Remove a rotina de aprovação do menu da solicitação de compras (MATA110).
@since 20170328
@author JRScatolon
@return nil 
/*/
user function mta110mnu()
local nPosAprv   := 0

    if (nPosAprv := aScan(aRotina, {|aMat| AllTrim(Upper(aMat[2])) == "A110APROV" })) > 0
        aDel(aRotina, nPosAprv)
        aSize(aRotina, Len(aRotina)-1)
    endif	

    if Select("SX2") <> 0
        DbSelectArea("Z0A")
        DbSetOrder(1) // Z0A_FILIAL + Z0A_USERID 
        if DbSeek(xFilial("Z0A")+__cUserId) .and. Z0A->Z0A_MSBLQL <> '1'
            AAdd(aRotina, {"Aprovacao", "u_A110Aprv", 0, 7, 0, nil})
        endif
    endif

    AAdd(aRotina, {"Doc. Aprovacao", "u_a110stat", 0, 2, 0, nil})

return nil 

/*/{Protheus.doc}u_A110Aprv
    Efetua a liberação da solicitação de compras por lista.
@since 20170328
@author JRScatolon
@return nil, Nulo 
/*/
user function A110Aprv(cAlias, nReg, nOpc)
local nRecno := SC1->(RecNo())
//local cProdDesc := ""
//local DtSolInic := SToD("")
//local DtSolFim := SToD("")
private nOpcAprv := 0

    A110Aprov(cAlias, nReg, nOpc)

    // Quanto a Aprovacao ? -> 1 := Por item; 2 := Por SC          
    Pergunte("MTA110", .f.)
    
    DbSelectArea("Z0B")
    DbSetOrder(1) // Z0B_FILIAL+Z0B_SOLICI+Z0B_ITEM+Z0B_USUARI+Z0B_DATA+Z0B_HORA

    // nOpcAprv é carregado através do ponto de entrada MT110BLO.
    if nOpcAprv <> 0
        cSql := " select SC1.R_E_C_N_O_ C1_RECNO, Z0B.R_E_C_N_O_ Z0B_RECNO " +;
                  " from " + RetSqlName("SC1") + " SC1" +;
             " left join " + RetSqlName("Z0B") + " Z0B" +;
                    " on Z0B.Z0B_FILIAL = SC1.C1_FILIAL" +;
                   " and Z0B.Z0B_SOLICI = SC1.C1_NUM" +;
                   " and Z0B.Z0B_ITEM   = SC1.C1_ITEM" +;
                   " and Z0B.Z0B_USUARI = '" + __cUserID + "'" +;
                   " and Z0B.D_E_L_E_T_ = ' '" +; 
                 " where SC1.C1_FILIAL  = '" + xFilial("SC1") + "'"+;
                   " and SC1.C1_NUM     = '" + SC1->C1_NUM + "'" +;
                   " and SC1.C1_PEDIDO  = '" + Space(TamSX3("C1_PEDIDO")[1]) + "'" +;
                   " and SC1.C1_COTACAO = '" + Space(TamSX3("C1_COTACAO")[1]) + "'" +;
                   Iif(mv_par02 == 1," and SC1.C1_ITEM    = '" + SC1->C1_ITEM + "'", "") +;
                   " and SC1.D_E_L_E_T_ = ' ' "
        
        DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(cSql)), "LIBTMP", .t., .f.)

        begin transaction

        while !LIBTMP->(Eof())
            if !Empty(LIBTMP->Z0B_RECNO)
                Z0B->(DbGoTo(LIBTMP->Z0B_RECNO))
            endif
            SC1->(DbGoTo(LIBTMP->C1_RECNO))
            
            // Grava o documento de aprovação
            RecLock("Z0B", Empty(LIBTMP->Z0B_RECNO))
                Z0B->Z0B_FILIAL := SC1->C1_FILIAL
                Z0B->Z0B_SOLICI := SC1->C1_NUM
                Z0B->Z0B_ITEM   := SC1->C1_ITEM
                Z0B->Z0B_PRODUT := SC1->C1_PRODUTO
                Z0B->Z0B_UM     := SC1->C1_UM     
                Z0B->Z0B_QUANT  := SC1->C1_QUANT  
                Z0B->Z0B_CODSOL := SC1->C1_SOLICIT
                Z0B->Z0B_USUARI := __CUSERID
                Z0B->Z0B_OPERAC := Str(nOpcAprv, 1)
                Z0B->Z0B_DATA   := Date() // Utiliza a data efetiva do sistema, não a database
                Z0B->Z0B_HORA   := Time() 
            MsUnlock()

            UpdateSC1(LIBTMP->C1_RECNO, Z0B->Z0B_USUARI, Z0B->Z0B_OPERAC)
            
            LIBTMP->(DbSkip())
        end
        
        U_VACOMM02( SC1->C1_FILIAL, SC1->C1_NUM )
        
        end transaction
        
        LIBTMP->(DbCloseArea())
    endif

return nil

static function UpdateSC1(nC1Recno, cCodUsr, cTpAprv)
local cSql := ""
local cStatus := "L"
local cAprov := cUserName
local nSeq

DbSelectArea("Z0A")
DbSetOrder(1) // Z0A_FILIAL + Z0A_USERID 
DbSeek(xFilial("Z0A")+__cUserId)
nSeq := Val(Z0A->Z0A_SEQ)

DbSelectArea("SC1")
DbSetOrder(1) // 
SC1->(DbGoTo(nC1Recno))
cStatus := SC1->C1_APROV

    cSql := " select Z0A.R_E_C_N_O_ Z0A_RECNO, Z0B.R_E_C_N_O_ Z0B_RECNO " +;
              " from " + RetSqlName("Z0A") + " Z0A" +;
         " left join " + RetSqlName("Z0B") + " Z0B" +;
                " on Z0B.Z0B_FILIAL = '" + xFilial("Z0B") + "'" +;
               " and Z0B.Z0B_USUARI = Z0A.Z0A_USERID" +;
               " and Z0B.Z0B_SOLICI = '" + SC1->C1_NUM + "'" +;
               " and Z0B.Z0B_ITEM   = '" + SC1->C1_ITEM + "'" +;
               " and Z0B.D_E_L_E_T_ = ' '" +;
             " where Z0A.Z0A_FILIAL = '" + xFilial("Z0A") + "'" +;
               " and Z0A.Z0A_MSBLQL <> '1'" +;
               " and Z0A.D_E_L_E_T_ = ' '"
     
    DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(cSql)), "LIBER", .t., .f.)
    while !LIBER->(Eof())
          
        if Empty(LIBER->Z0B_RECNO)
            cStatus := 'B'
            cAprov := Space(TamSX3("C1_NOMAPRO")[1])
            exit
        endif
        Z0B->(DbGoTo(LIBER->Z0B_RECNO))
        Z0A->(DbGoTo(LIBER->Z0A_RECNO))

        if Z0B->Z0B_OPERAC == '2' .or. Z0B->Z0B_OPERAC == '3'
            cStatus := Iif(Z0B->Z0B_OPERAC == '2', 'R', 'B') // 1="Solicitacäo Aprovada",2="Solicitacäo Rejeitada",3="Solicitacäo Bloqueada"
            cAprov := Z0A->Z0A_NOME
            exit  
        endif
         
        LIBER->(DbSkip())    
    end
    LIBER->(DbCloseArea()) 

    DbSelectArea("SC1")
    RecLock("SC1", .f.)
        // 3 -> "Solicitacäo Bloqueada"
        // 1 -> "Solicitacäo Aprovada"
        // 2 -> "Solicitacäo Rejeitada"
        SC1->C1_XAPROV := StrChange(SC1->C1_XAPROV, Iif(cTpAprv == '3', "B", Iif(cTpAprv == '2', "R", "L")), nSeq)
        SC1->C1_APROV := cStatus
        SC1->C1_NOMAPRO := cAprov
    MsUnlock()

return nil

static function StrChange(cStr, cNewChar, nPos)
local cNewStr := ""

    if nPos > 1
        cNewStr := SubStr(cStr, 1, nPos-1)
    endif
    
    cNewStr += cNewChar
    
    if nPos < Len(cStr)
        cNewStr += SubStr(cStr, nPos+1)
    endif

return cNewStr

user function a110stat(cAlias, nReg, nOpc)
local aArea := GetArea()
local aCores := {}

    PswOrder(2) // Username
    cSql := " select Z0A.Z0A_NOME, Z0B.Z0B_OPERAC" +; 
              " from Z0A010 Z0A" +; 
         " left join Z0B010 Z0B" +; 
                " on Z0B.Z0B_FILIAL = '" + xFilial("Z0B") + "'" +; 
               " and Z0B.Z0B_USUARI = Z0A.Z0A_USERID" +; 
               " and Z0B.Z0B_SOLICI = '" + SC1->C1_NUM + "'" +; 
               " and Z0B.Z0B_ITEM   = '" + SC1->C1_ITEM + "'" +; 
               " and Z0B.D_E_L_E_T_ = ' '" +; 
             " where Z0A.Z0A_FILIAL = '" + xFilial("Z0A") + "'" +; 
               " and Z0A.Z0A_MSBLQL <> '1'" +; 
               " and Z0A.D_E_L_E_T_ = ' '"

    DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(cSql)), "TMPZ0A", .f., .f.)
    while !TMPZ0A->(Eof())
        
        cUserName := AllTrim(Iif(PswSeek(TMPZ0A->Z0A_NOME), PswRet(1)[1][4], TMPZ0A->Z0A_NOME))
            
        if Empty(TMPZ0A->Z0B_OPERAC)
            aAdd(aCores,{"BR_BRANCO",  cUserName + " - Aguardando aprovação"})
        elseif TMPZ0A->Z0B_OPERAC == '1'
            aAdd(aCores,{"ENABLE",     cUserName + " - SC liberada"})
        elseif TMPZ0A->Z0B_OPERAC == '2'
            aAdd(aCores,{"BR_LARANJA", cUserName + " - SC rejeitada"})
        elseif TMPZ0A->Z0B_OPERAC == '3'
            aAdd(aCores,{"BR_CINZA",   cUserName + " - SC bloqueada"})
        endif
        TMPZ0A->(DbSkip())
    end
    TMPZ0A->(DbCloseArea())

    BrwLegenda("Documentos de Aprovação", "SC Nro " + SC1->C1_NUM, aCores)

RestArea(aArea) 
return nil
