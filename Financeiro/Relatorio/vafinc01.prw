#include 'protheus.ch'
#include 'parmtype.ch'
#include "fileio.ch"

/*/{Protheus.doc} vafinc01
Cria planilha de fluxo de caixa por natureza financeira

@author jrscatolon@jrscatolon
@since  21/11/2018
@version 1.0
/*/
user function vafinc01()
local cPerg := "VAFINC01"
local dDiaAte := LastDay(dDataBase, 2)

AtuSX1(cPerg)

u_PosSX1({{"VAFINC01", "01", dDataBase},;
          {"VAFINC01", "02", dDiaAte}})

if Pergunte(cPerg)
    if !Empty(mv_par01) .and. !Empty(mv_par02)
        FWMsgRun(, {|oSay| vafinc01() }, "Aguarde", "Gerando planilha...")
    else
       Help(,,"Parâmetros inválidos",,"Os parâmetros data de e data até são obrigatórios.", 1, 0,,,,,,  {"Por favor, preencha os parâmetros para continuar."} )
    endif
endif

return nil


user function RunPlan()

u_RunFunc("u_RunFC01()", "01", "01")

return nil

user function RunFC01() 
mv_par01 := CToD("01/02/2019")
mv_par02 := CToD("28/02/2019")
mv_par03 := 3
mv_par04 := 2
mv_par05 := "2371931 521900;3410203 706502;3410203 71889;3561299 4011592" 

vafinc01()

return nil

/*/{Protheus.doc} vafinc01
Cria planilha de fluxo de caixa por natureza financeira

@author jrscatolon@jrscatolon
@since  21/11/2018
@version 1.0
/*/
static function vafinc01() 
local aWorkBook := {}
local aSaldo := {}
local aData := {}
local aNatureza := {}
local aCheques := {} 
local aFxCx := {}
local aPagar := {}
local aReceber := {}

local i, j, k, nLen

local nLin := 0
local nLinTotBco := 0
local nLinCabec := 0
local nLinSldIni := 0
local nLinPrvCmpGado := 0
local nLinPagDia := 0
local nLinRecDia := 0
local nLinLiqDia := 0
//local nLinTotDia := 0
local nLinTotChq := 0
local nLinSaldo := 0

local nLinIni := 0
local nLinFim := 0
local nLinIniNat := 0
local nLinFimNat := 0
local nLinIniCheque := 0
local nLinFimCheque := 0
//local nTotalDia := 0
//local nSldBanco := 0
local nColData := 0
local nLinNatu := 0
local dDataAtu := SToD("")

DbUseArea(.t., "TOPCONN", TCGenQry(,,;
                          " select A6_COD, A6_AGENCIA, A6_NUMCON, A6_NOME, A6_SALATU" +;
                                         " from " + RetSqlName("SA6") + " SA6" +;
                                        " where SA6.A6_FILIAL  = '" + FWxFilial("SA6") + "'" +;
                                          " and SA6.A6_FLUXCAI = 'S' " +;
                                          " and SA6.A6_BLOCKED = '2'" +;
                                          " and SA6.A6_COD + SA6.A6_AGENCIA + SA6.A6_NUMCON in (" + Iif(At(';', mv_par05), u_InSql(mv_par05, ";"), "'" + AllTrim(mv_par05) + "'") + ") " +;
                                          " and SA6.D_E_L_E_T_ = ' '"), "QRYSLD", .f., .f.)

while !QRYSLD->(Eof())
    AAdd(aSaldo, {AllTrim(QRYSLD->A6_COD) + '/' + AllTrim(QRYSLD->A6_AGENCIA) + "-" +  AllTrim(QRYSLD->A6_NUMCON), AllTrim(QRYSLD->A6_NOME), QRYSLD->A6_SALATU} )
    QRYSLD->(DbSkip())
end

QRYSLD->(DbCloseArea())

DbUseArea(.t., "TOPCONN", TCGenQry(,,;
            " select distinct SE1.E1_VENCREA" +;
              " from " + RetSqlName("SE1") + " SE1 " +;
             " where SE1.E1_SALDO   > 0 " +;
               " and SE1.E1_VENCREA between '" + DToS(mv_par01) + "' and '" + DToS(mv_par02) + "'" +;
               " and ( " +;
                    " SE1.E1_TIPO    not in ('RA','NCC') " +;
                 " or SE1.E1_TIPO    like '%-' " +;
               " ) " +;
               " and SE1.D_E_L_E_T_ = ' ' " +;
             " union " +;
            " select distinct SE2.E2_VENCREA" +;
              " from " + RetSqlName("SE2") + " SE2 " +;
             " where SE2.E2_SALDO   > 0 " +;
               " and SE2.E2_VENCREA between '" + DToS(mv_par01) + "' and '" + DToS(mv_par02) + "'" +;
               " and SE2.E2_TIPO    not in ('PA', 'NDF') " +;
               " and SE2.D_E_L_E_T_ = ' ' " +;
          " order by 1"), "QRYDATA", .f., .f.)
TCSetField('QRYDATA', 'E1_VENCREA', 'D')

while !QRYDATA->(Eof())
    AAdd(aData, QRYDATA->E1_VENCREA)
    QRYDATA->(DbSkip())
end

QRYDATA->(DbCloseArea())

DbUseArea(.t., "TOPCONN", TCGenQry(,,;
              " select distinct SE1.E1_NATUREZ NATUREZA, ED_DESCRIC DESCRICAO" +;
                " from " + RetSqlName("SE1") + " SE1" +;
           " left join " + RetSqlName("SED") + " SED" +;
                  " on SED.ED_FILIAL  = '" + FWxFilial("SED") + "'" +;
                 " and SED.ED_CODIGO  = SE1.E1_NATUREZ " +;
                 " and SED.D_E_L_E_T_ = ' '" +;
               " where SE1.E1_SALDO   > 0 " +;
                 " and SE1.E1_VENCREA between '" + DToS(mv_par01) + "' and '" + DToS(mv_par02) + "'" +;
                 " and ( " +;
                      " SE1.E1_TIPO    not in ('RA','NCC') " +;
                   " or SE1.E1_TIPO    like '%-' " +;
                 " ) " +;
                 " and SE1.D_E_L_E_T_ = ' ' " +;
               " union " +;
              " select distinct SE2.E2_NATUREZ NATUREZA, ED_DESCRIC DESCRICAO" +;
                " from " + RetSqlName("SE2") + " SE2 " +;
           " left join " + RetSqlName("SED") + " SED" +;
                  " on SED.ED_FILIAL  = '" + FWxFilial("SED") + "'" +;
                 " and SED.ED_CODIGO  = SE2.E2_NATUREZ " +;
                 " and SED.D_E_L_E_T_ = ' '" +;
               " where SE2.E2_SALDO   > 0 " +;
                 " and SE2.E2_VENCREA between '" + DToS(mv_par01) + "' and '" + DToS(mv_par02) + "'" +;
                 " and SE2.E2_TIPO    not in ('PA', 'NDF') " +;
                 " and SE2.D_E_L_E_T_ = ' ' " +;
            " order by NATUREZA "), "QRYNATURE", .f., .f.)

while !QRYNATURE->(Eof())
    AAdd(aNatureza, {QRYNATURE->NATUREZA, QRYNATURE->DESCRICAO})
    QRYNATURE->(DbSkip())
end

QRYNATURE->(DbCloseArea())

//    DbUseArea(.t., "TOPCONN", TCGenQry(,,;
//        " select SEF.EF_FILIAL" +;
//             " , SEF.EF_BANCO" +;
//             " , SEF.EF_AGENCIA" +;
//             " , SEF.EF_CONTA" +;
//             " , SEF.EF_NUM" +;
//             " , SEF.EF_BENEF" +;
//             " , SEF.EF_DATA" +;
//             " , SEF.EF_VALOR" +; 
//          " from " + RetSqlName("SEF") + " SEF" +;
//          " join " + RetSqlName("SE5") + " SE5" +;
//            " on SE5.E5_FILIAL  = SEF.EF_FILIAL" +;
//           " and SE5.E5_BANCO   = SEF.EF_BANCO" +;
//           " and SE5.E5_AGENCIA = SEF.EF_AGENCIA" +;
//           " and SE5.E5_CONTA   = SEF.EF_CONTA" +;
//           " and SE5.E5_NUMCHEQ = SEF.EF_NUM" +;
//           " and SE5.E5_SEQ     = SEF.EF_SEQUENC" +;
//           " and SE5.E5_TIPODOC = 'CH'" +; // Considera somente os cheques
//           " and SE5.E5_RECPAG  = 'P'" +; // A pagra
//           " and SE5.E5_SITUACA <> 'C'" +; // Que não foram cancelados
//           " and SE5.E5_RECONC  = ' '" +; // Não foram consiliados
//           " and SE5.D_E_L_E_T_ = ' '" +;
//         " where SEF.EF_IMPRESS = 'S'" +; // Já foram impressos
//           " and (" +;
//                    " (" +;
//                        " SEF.EF_VENCTO = '        '" +; 
//                    " and SEF.EF_DATA  between '" + DToS(mv_par01) + "' and '" + DToS(mv_par02) + "'" +;
//                    " )" +;
//                 " or SEF.EF_VENCTO between '" + DToS(mv_par01) + "' and '" + DToS(mv_par02) + "'" +;
//                " )" +;
//             " and SEF.EF_TIPO    = '   '" +; // Campo EF_TIPO não é preenchido para o tipo cheque. Quando está preenchido vincula cheque ao título de origem. 
//             " and SEF.D_E_L_E_T_ = ' '"+;
//        " order by SEF.EF_DATA" ), "TMPSEF", .f., .f.)

    DbUseArea(.t., "TOPCONN", TCGenQry(,,;
        " select SEF.EF_FILIAL" +;
             " , SEF.EF_BANCO" +;
             " , SEF.EF_AGENCIA" +;
             " , SEF.EF_CONTA" +;
             " , SEF.EF_NUM" +;
             " , SEF.EF_BENEF" +;
             " , SEF.EF_VENCTO" +;
             " , SEF.EF_VALOR" +; 
          " from " + RetSqlName("SEF") + " SEF" +;
         " where SEF.EF_VENCTO  between '" + DToS(mv_par01) + "' and '" + DToS(mv_par02) + "'" +;
           " and SEF.EF_IMPRESS not in ('A', 'C')" +;
           " and SEF.EF_NUM     <> ' '" +;
           " and SEF.EF_CART    <> 'R'" +;
           " and SEF.EF_LIBER   in ('N', ' ')" +;
           " and SEF.D_E_L_E_T_ = ' '" ;
                                         ), "TMPSEF", .f., .f.)

    while !TMPSEF->(Eof())
        AAdd(aCheques, { ;
            AllTrim(TMPSEF->EF_FILIAL) + "|" + AllTrim(TMPSEF->EF_BANCO) + "|" + AllTrim(TMPSEF->EF_AGENCIA) + "|" + AllTrim(TMPSEF->EF_CONTA) + "|" + AllTrim(TMPSEF->EF_NUM), ;
            AllTrim(TMPSEF->EF_BENEF), ;
            SToD(TMPSEF->EF_VENCTO), ;
            TMPSEF->EF_VALOR ;
        })
        TMPSEF->(DbSkip())
    end

    TMPSEF->(DbCloseArea())


if Len(aNatureza) > 0 .and. Len(aData) > 0
    
    // Linhas:  Cabeçalho banco               1                                          (+) 1
    //          Lista dos bancos              Len(aSaldo)                                (+) Len(aSaldo)
    //          Total Bancos                  1
    //          Linha em branco               1
    //          Entrada de Recursos           1
    //          Linha em branco               1 
    //          Cabeçalho                     1
    //          Saldo Inicial                 1
    //          Prev. Compra de gado          1                                          (+) 7
    //          *Naturezas                    Len(aNatureza)*Iif(mv_par03 == 2, 2, 1)    (+) Len(aNatureza)*Iif(mv_par03 == 2, 2, 1)
    //          Linha em branco               1
    //          Cabeçalho Cheques a           1                                          (+) 2
    //          Lista dos Cheques             Len(aCheques)                              (+) Len(aCheques)
    //          Total dos Cheques             1          
    //          Linha em branco               1                                          (+) 2
    //          **Total Pagar                 Iif(mv_par03==2 .or. mv_par03==3, 1, 0)    Iif(mv_par03==2 .or. mv_par03==3, 1, 0)    
    //          **Total Receber               Iif(mv_par03==2 .or. mv_par03==4, 1, 0)    Iif(mv_par03==2 .or. mv_par03==4, 1, 0)
    //          **Liquido no dia              Iif(mv_par03==1 .or. mv_par03==2, 1, 0)    Iif(mv_par03==1 .or. mv_par03==2, 1, 0)
    //          Linha em branco               1
    //          Saldo Final Dia               1                                          (+) 2

    // mv_par03: 1 - 'Saldo'; 2 - 'Pagar/Receber'; 3 - 'Somente pagar'; 4 - 'Somente receber'


    aFxCx := Array(1 +;
                   Len(aSaldo) +;
                   7 +;
                   Len(aNatureza)*Iif(mv_par03 == 2, 2, 1) +;
                   2 +;
                   Len(aCheques) +;
                   2 +;
                   Iif(mv_par03==2 .or. mv_par03==3, 1, 0) +;
                   Iif(mv_par03==2 .or. mv_par03==4, 1, 0) +;
                   Iif(mv_par03==1 .or. mv_par03==2, 1, 0) +;
                   3,; 
                   Iif(mv_par03 <> 1, 3, 2) +;
                   Len(aData))

    // *  - caso mv_par03 == 2 multiplicar por 2 as naturezas pois serão impressos os totais a pagar e receber separadamente
    // ** - caso mv_par02 == 4 apresentar "Receber do dia" 

    // Colunas: Natureza                     
    //          Descrição                    
    //          **Operação                   
    //          Colunas de Datas entre mv_par01 e mv_par02

    // ** -  apena se mv_par03 <> 1

    // seta nColData para a primeira coluna
    nColData := Iif(mv_par03 <> 1, 4, 3)

    nLin := 1 // Define a linha inicial
    
    // Cabeçalho banco
    aFxCx[nLin][1] := "Banco"
    aFxCx[nLin][2] := "Descrição"
    aFxCx[nLin][3] := "Saldo"
    nLen := Len(aFxCx[nLin])
    for i := 4 to nLen
        aFxCx[nLin][i] := ""
    next

    // Saldo detalhado dos bancos selecionados
    nLin++
    nLinIni := nLin
    nLen := Len(aSaldo)
    for j := 1 to nLen
        aFxCx[nLin][1] := aSaldo[j][1]
        aFxCx[nLin][2] := aSaldo[j][2]
        aFxCx[nLin][3] := aSaldo[j][3]
        for k := 4 to Len(aFxCx[nLin])
            aFxCx[nLin][k] := ""
        next
        nLinFim := nLin
        nLin++
    next
    
    // Total Bancos
    nLinTotBco := nLin
    aFxCx[nLin][1] := ""
    aFxCx[nLin][2] := "Total"
    aFxCx[nLin][3] := {Iif(nLinFim == 0, 0, "=SUM(R[-" + AllTrim(Str(nLin-nLinIni)) + "]C:R[-"  + AllTrim(Str(nLin-nLinFim)) +  "]C)"), "Contabil"}
    for j := 4 to Len(aFxCx[nLin])
        aFxCx[nLin][j] := ""
    next

    // Linha em branco
    nLin++
    nLen := Len(aFxCx[nLin])
    for j := 1 to nLen 
        aFxCx[nLin][j] := ""
    next

    // Entrada de Recursos (Better Beef)
    nLin++
    aFxCx[nLin][1] := "Entrada de Recursos (Better Beef)"
    aFxCx[nLin][2] := ""
    if mv_par03 <> 1
        aFxCx[nLin][3] := ""
    endif
    nLen := Len(aFxCx[nLin])
    for j := nColData to nLen
        aFxCx[nLin][j] := {0, "Amarelo"}
    next

    // Linha em branco
    nLin++
    nLen := Len(aFxCx[nLin])
    for j := 1 to nLen 
        aFxCx[nLin][j] := ""
    next

    // Linha em branco
    nLin++
    nLen := Len(aFxCx[nLin])
    for j := 1 to nLen 
        aFxCx[nLin][j] := ""
    next

    // cabeçalho
    nLin++
    nLinCabec := nLin
    aFxCx[nLinCabec][1] := "Natureza"
    aFxCx[nLinCabec][2] := "Descricao"
    if mv_par03 <> 1
        aFxCx[nLinCabec][3] := "Operacao"
    endif

    nLen := Len(aData)
    for i := 0 to nLen-1
        aFxCx[nLinCabec][i+nColData] := aData[i+1]
    next

    // Linha de saldo inicial
    nLin++
    nLinSldIni := nLin
    aFxCx[nLin][1] := ""
    aFxCx[nLin][2] := "Saldo Inicial"
    if mv_par03 <> 1
        aFxCx[nLin][3] := ""
    endif
    aFxCx[nLin][nColData] := "=R" + AllTrim(Str(nLinTotBco)) + "C3+R[-4]C"

    // Linha de Previsão Compra de Gado
    nLin++
    nLinPrvCmpGado := nLin
    aFxCx[nLin][1] := ""
    aFxCx[nLin][2] := "Previsao Compra de Gado"
    if mv_par03 <> 1
        aFxCx[nLin][3] := ""
    endif
    nLen := Len(aFxCx[nLin])
    for j := nColData to nLen
        aFxCx[nLin][j] := {0, "Amarelo"}
    next

    // Naturezas
    nLin++
    nLinIniNat:= nLin
    
    // Preenchimento das naturezas
    nLen := Len(aNatureza)
    for i := 0 to nLen-1 
        if mv_par03 <> 2 
            aFxCx[nLinIniNat+i][1] := aNatureza[i+1][1]
            aFxCx[nLinIniNat+i][2] := aNatureza[i+1][2]
            if mv_par03 == 3
                aFxCx[nLinIniNat+i][3] := "Pagar"
            elseif mv_par03 == 4
                aFxCx[nLinIniNat+i][3] := "Receber"
            endif
            for j := 4 to Len(aFxCx[nLinIniNat+i])
                aFxCx[nLinIniNat+i][j] := {0, "Contabil"}
            next
            nLin++
        else
            aFxCx[nLinIniNat+(i*2)][1] := aNatureza[i+1][1]
            aFxCx[nLinIniNat+(i*2)][2] := aNatureza[i+1][2]
            aFxCx[nLinIniNat+(i*2)][3] := "Receber"
            aFxCx[nLinIniNat+(i*2)+1][1] := aNatureza[i+1][1]
            aFxCx[nLinIniNat+(i*2)+1][2] := aNatureza[i+1][2]
            aFxCx[nLinIniNat+(i*2)+1][3] := "Pagar"
            for j := 4 to Len(aFxCx[nLinIniNat+i])
                aFxCx[nLinIniNat+(i*2)][j] := {0, "Contabil"}
                aFxCx[nLinIniNat+(i*2)+1][j] := {0, "Contabil"}
            next
            nLin += 2
        endif    
    next   
    nLinFimNat := nLin - 1

    // Linha em branco
    nLen := Len(aFxCx[nLin])
    for j := 1 to nLen 
        aFxCx[nLin][j] := ""
    next

    // Cheques
    nLin++
    aFxCx[nLin][1] := "Cheque a Compensar"
    aFxCx[nLin][2] := "Sacado"
    if mv_par03 <> 1
        aFxCx[nLin][3] := ""
    endif
    nLen := Len(aFxCx[nLin])
    for j := nColData to nLen
        aFxCx[nLin][j] := ""
    next

    nLen := Len(aCheques)
    if nLen == 0
        nLin++
        nLinIniCheque := nLin
        aFxCx[nLinIniCheque][1] := "Nenhum cheque a compensar"
        nLinFimCheque := nLin
        nLen := Len(aFxCx[nLin])
        for j := 2 to nLen
            aFxCx[nLin][j] := ""
        next
    else
		for i := 0 to nLen-1
			nLin++
			if nLinIniCheque == 0
				nLinIniCheque := nLin
			endif

			aFxCx[nLin][1] := aCheques[i+1][1]
			aFxCx[nLin][2] := aCheques[i+1][2]
			if mv_par03 <> 1
				aFxCx[nLin][3] := ""
			endif
			for j := nColData to Len(aFxCx[nLin])
				aFxCx[nLin][j] := {0, "Contabil"}
			next
			If (nPosCol := aScan(aFxCx[nLinCabec], {|aMat| ValType(aMat) == "D" .and. aMat == aCheques[i+1][3]}))>0
				aFxCx[nLin, nPosCol] := {aCheques[i+1][4], "Contabil"}
			EndIf 

		next
        nLinFimCheque := nLin

        // Total cheques
        nLin++
        nLinTotChq := nLin
        aFxCx[nLin][1] := "Total cheques"
        aFxCx[nLin][2] := ""
        if mv_par03 <> 1
            aFxCx[nLin][3] := ""
        endif
        nLen := Len(aFxCx[nLin])
        for i := Iif(mv_par03 <> 1, 4, 3) to nLen
            aFxCx[nLin][i] := {"=SUM(R[-" + AllTrim(Str(nLin-nLinIniCheque)) + "]C:R[-" + AllTrim(Str(nLin-nLinFimCheque)) + "]C)", "Contabil"}
        next

    endif

    // Linha em branco
    nLin++
    nLen := Len(aFxCx[nLin])
    for j := 1 to nLen 
        aFxCx[nLin][j] := ""
    next



    // mv_par03: 1 - 'Saldo'; 2 - 'Pagar/Receber'; 3 - 'Somente pagar'; 4 - 'Somente receber'
    // Total Pagar
    if mv_par03==2 .or. mv_par03==3
        nLin++
        nLinPagDia := nLin
        aFxCx[nLin][1] := ""
        aFxCx[nLin][2] := ""
        aFxCx[nLin][3] := "Total Pagar"
        
        // =SOMASE(L14C3:L149C3;"Pagar";L[-139]C:L[-4]C)+L[-140]C
        nLen := Len(aFxCx[nLin])
        for i := 4 to nLen
            aFxCx[nLin][i] := {"=SUMIF(R" + AllTrim(Str(nLinIniNat)) + "C3:R" + AllTrim(Str(nLinFimNat)) + "C3,&quot;Pagar&quot;,R[-" + AllTrim(Str(nLin-nLinIniNat)) + "]C:R[-" + AllTrim(Str(nLin-nLinFimNat)) + "]C)" + Iif(mv_par04==1,"-", "+") + "R[-" + AllTrim(Str(nLin-nLinPrvCmpGado)) + "]C" + Iif(Len(aCheques)> 0, "+R[-" + AllTrim(Str(nLin-nLinTotChq)) + "]C", "") , "Contabil"}
        next
        
    endif

    if mv_par03==2 .or. mv_par03==4
        nLin++
        nLinRecDia := nLin
        aFxCx[nLin][1] := ""
        aFxCx[nLin][2] := ""
        aFxCx[nLin][3] := "Total Receber"
        
        // =SOMASE(L14C3:L149C3;"Receber";L[-140]C[1]:L[-5]C[1])
        nLen := Len(aFxCx[nLin])
        for i := 4 to nLen
            aFxCx[nLin][i] := {"=SUMIF(R" + AllTrim(Str(nLinIniNat)) + "C3:R" + AllTrim(Str(nLinFimNat)) + "C3,&quot;Receber&quot;,R[-" + AllTrim(Str(nLin-nLinIniNat)) + "]C:R[-" + AllTrim(Str(nLin-nLinFimNat)) + "]C)", "Contabil"}
        next
    endif

    // Líquido no dia
    if mv_par03==1 .or. mv_par03==2
        nLin++
        nLinLiqDia := nLin
        aFxCx[nLin][1] := ""
        if mv_par03 == 1
            aFxCx[nLin][2] := "Liquido no Dia"
        else
            aFxCx[nLin][2] := ""
            aFxCx[nLin][3] := "Liquido no Dia"
        endif
    
        nLen := Len(aFxCx[nLin])
        for i := nColData to nLen
            if mv_par03 == 1
                aFxCx[nLin][i] := {"=SUM(R[-" + AllTrim(Str(nLin-nLinIniNat)) + "]C:R[-" + AllTrim(Str(nLin-nLinFimNat)) + "]C)", "Contabil"}
            else
                aFxCx[nLin][i] := {"=R[-" + AllTrim(Str(nLin-nLinRecDia)) + "]C" + Iif(mv_par04==1,"+","-") + "R[-" + AllTrim(Str(nLin-nLinPagDia)) + "]C", "Contabil"}
            endif
        next
    endif

    // Linha em branco
    nLin++
    nLen := Len(aFxCx[nLin])
    for j := 1 to nLen 
        aFxCx[nLin][j] := ""
    next

    // Total Dia
    nLin++
    nLinSaldo := nLin 
    aFxCx[nLin][1] := ""
    if mv_par03 == 1
        aFxCx[nLin][2] := "Total Dia"
    else
        aFxCx[nLin][2] := ""
        aFxCx[nLin][3] := "Total Dia"
    endif

    nLen := Len(aFxCx[nLin])
    for i := nColData to nLen
        aFxCx[nLin][i] := {"=R[-" + AllTrim(Str(nLin-nLinSldIni)) + "]C+R[-2]C", "Contabil"}
        if mv_par03 == 3
            aFxCx[nLin][i] := {"=R[-" + AllTrim(Str(nLin-nLinSldIni)) + "]C-R[-2]C", "Contabil"}
        else 
            aFxCx[nLin][i] := {"=R[-" + AllTrim(Str(nLin-nLinSldIni)) + "]C+R[-2]C", "Contabil"}
        endif
        
    next

    // Saldo Inicial
    nLen := Len(aFxCx[nLinSldIni])
    for i := nColData + 1 to nLen 
        aFxCx[nLinSldIni][i] := {"=R[" + AllTrim(Str(nLinSaldo-nLinSldIni)) + "]C[-1]+R[-4]C", "Contabil"}
    next


//    // Pagar do dia
//    nLinPagDia := nLin 
//    aFxCx[nLinPagDia][1] := ""
//    if mv_par03 == 1
//        aFxCx[nLinPagDia][2] := "Total do dia"
//        nLen := Len(aFxCx[nLinPagDia])
//        for i := 3 to nLen
//            aFxCx[nLinPagDia][i] := {"=SUM(R[-" + AllTrim(Str(nLin-nLinIniNat)) + "]C:R[-" + AllTrim(Str(nLin-nLinFimNat)) + "]C)", "Contabil"}
//        next
//    elseif mv_par03 == 2  
//        aFxCx[nLinPagDia][2] := "Saldo no dia"
//        aFxCx[nLinPagDia][3] := ""
//        nLen := Len(aFxCx[nLinPagDia])
//        for i := 4 to nLen
//            if mv_par04 == 1 // pagar como negativo
//                aFxCx[nLinPagDia][i] := {"=SUMIF(R" + AllTrim(Str(nLinIniNat)) + "C3:R" + AllTrim(Str(nLinFimNat)) + "C3,&quot;Receber&quot;,R[-" + AllTrim(Str(nLin-nLinIniNat)) + "]C:R[-" + AllTrim(Str(nLin-nLinFimNat)) + "]C)+SUMIF(R" + AllTrim(Str(nLinIniNat)) + "C3:R" + AllTrim(Str(nLinFimNat)) + "C3,&quot;Pagar&quot;,R[-" + AllTrim(Str(nLin-nLinIniNat)) + "]C:R[-" + AllTrim(Str(nLin-nLinFimNat)) + "]C)", "Contabil"}
//            else // pagar positivo
//                aFxCx[nLinPagDia][i] := {"=SUMIF(R" + AllTrim(Str(nLinIniNat)) + "C3:R" + AllTrim(Str(nLinFimNat)) + "C3,&quot;Receber&quot;,R[-" + AllTrim(Str(nLin-nLinIniNat)) + "]C:R[-" + AllTrim(Str(nLin-nLinFimNat)) + "]C)-SUMIF(R" + AllTrim(Str(nLinIniNat)) + "C3:R" + AllTrim(Str(nLinFimNat)) + "C3,&quot;Pagar&quot;,R[-" + AllTrim(Str(nLin-nLinIniNat)) + "]C:R[-" + AllTrim(Str(nLin-nLinFimNat)) + "]C)", "Contabil"}
//            endif
//
//        next
//    elseif mv_par03 == 3
//        aFxCx[nLinPagDia][2] := "Pagar no dia"
//        aFxCx[nLinPagDia][3] := ""
//        nLen := Len(aFxCx[nLinPagDia])
//        for i := 4 to nLen
//            aFxCx[nLinPagDia][i] := {"=SUM(R[-" + AllTrim(Str(nLin-nLinIniNat)) + "]C:R[-" + AllTrim(Str(nLin-nLinFimNat)) + "]C)", "Contabil"} // nLinPrvCmpGado
//        next
//    elseif mv_par03 == 4
//        aFxCx[nLinPagDia][2] := "Receber no dia"
//        aFxCx[nLinPagDia][3] := ""
//        nLen := Len(aFxCx[nLinPagDia])
//        for i := 4 to nLen
//            aFxCx[nLinPagDia][i] := {"=SUM(R[-" + AllTrim(Str(nLin-nLinIniNat)) + "]C:R[-" + AllTrim(Str(nLin-nLinFimNat)) + "]C)", "Contabil"}
//        next
//    endif
//    
//    // Linha em branco
//    nLin++
//    nLen := Len(aFxCx[nLin])
//    for j := 1 to nLen 
//        aFxCx[nLin][j] := ""
//    next
//
//    // Saldo Final Dia
//    nLin++
//    nLinSaldo := Len(aFxCx)
//    aFxCx[nLinSaldo][1] := ""
//    aFxCx[nLinSaldo][2] := "Saldo Final Dia"
//    if mv_par03 == 2
//        aFxCx[nLinSaldo][3] := ""
//    endif
//    nLen := Len(aFxCx[nLinSaldo])
//    if mv_par03 == 1
//        for i := 3 to nLen
//            aFxCx[nLinSaldo][i] := {"=R" + AllTrim(Str(nLinSldIni)) + "C+R[-" + AllTrim(Str(nLinSaldo-nLinPagDia)) + "]C", "Contabil"}  
//        next
//    elseif mv_par03 == 2
//        for i := 4 to nLen
//            aFxCx[nLinSaldo][i] := {"=R" + AllTrim(Str(nLinSldIni)) + "C+R[-" + AllTrim(Str(nLinSaldo-nLinPagDia)) + "]C", "Contabil"}  
//        next
//    elseif mv_par03 == 3
//        for i := 4 to nLen
//            aFxCx[nLinSaldo][i] := Iif(mv_par04 == 1, {"=R" + AllTrim(Str(nLinSldIni)) + "C+R[-" + AllTrim(Str(nLinSaldo-nLinPagDia)) + "]C", "Contabil"}, {"=R" + AllTrim(Str(nLinSldIni)) + "C+((-1)*R[-" + AllTrim(Str(nLinSaldo-nLinPagDia)) + "]C)", "Contabil"})
//        next
//    else
//        for i := 4 to nLen
//            aFxCx[nLinSaldo][i] := {"=R" + AllTrim(Str(nLinSldIni)) + "C+R[-" + AllTrim(Str(nLinSaldo-nLinPagDia)) + "]C", "Contabil"}  
//        next
//    endif
//    
//    // Grava a fórmula do saldo inicial para as demais linhas, caso existam
//    nLen := Len(aFxCx[nLinSldIni])
//    for i := nColData + 1 to nLen 
//        aFxCx[nLinSldIni][i] := "=R[" + AllTrim(Str(nLinSaldo-nLinSldIni)) + "]C[-1]+R[-4]C"
//    next

    //  ID    DATA      NATUREZA        RECEBER          PAGAR      SALDO_DIA          SALDO
    //   1              SLDINI             0,00           0,00    -4835930,38    -4835930,38
    //   2    20181001  111             6076,33           0,00        6076,33    -4829854,05
    //   3    20181018  2130               0,00          45,28         -45,28    -4829899,33
    //   4    20181020  254                0,00         970,20        -970,20    -4830869,53
    //   5    20181020  257                0,00         419,78        -419,78    -4831289,31
    //   6    20181022  111           548210,00           0,00      548210,00    -4283079,31
    //   7    20181022  211                0,00        2220,17       -2220,17    -4285299,48
    //   8    20181024  111           660450,00           0,00      660450,00    -3624849,48
    //   9    20181025  111            22000,00           0,00       22000,00    -3602849,48
    //  10    20181030  2130               0,00         587,20        -587,20    -3603436,68

    DbUseArea(.t., "TOPCONN", TCGenQry(,,;
                    " with" +;
               " SALDO as(" +;
                        " select sum(A6_SALATU) SALDO_INI" +;
                          " from " + RetSqlName("SA6") + " SA6" +;
                         " where SA6.D_E_L_E_T_ = ' ' " +;
                           " and SA6.A6_FLUXCAI = 'S' " +;
                           " and SA6.A6_BLOCKED = '2'" +;
                           " and SA6.A6_COD + SA6.A6_AGENCIA + SA6.A6_NUMCON in (" + Iif(At(';', mv_par05), u_InSql(mv_par05, ";"), "'" + AllTrim(mv_par05) + "'") + ") " +;
               " )," +;
               " CAIXA as(" +;
                        " select SE1.E1_VENCREA DATA" +;
                             " , SE1.E1_NATUREZ NATUREZA" +;
                             " , sum(SE1.E1_SALDO)+sum(SE1.E1_ACRESC)-sum(SE1.E1_DECRESC) RECEBER" +;
                             " , 0 PAGAR" +;
                          " from " + RetSqlName("SE1") +" SE1" +;
                         " where SE1.E1_SALDO   > 0" +;
                           " and SE1.E1_VENCREA between '" + DToS(mv_par01) + "' and '" + DToS(mv_par02) + "'" +;
                           " and SE1.E1_TIPO    not in ('RA','NCC')" +;
                           " and SE1.D_E_L_E_T_ = ' '" +;
                      " group by SE1.E1_VENCREA" +;
                             " , SE1.E1_NATUREZ" +;
                         " union all" +;
                        " select SE1.E1_VENCREA DATA" +;
                             " , SE1.E1_NATUREZ NATUREZA" +;
                             " , (-1) * (sum(SE1.E1_SALDO)+sum(SE1.E1_ACRESC)-sum(SE1.E1_DECRESC)) RECEBER" +;
                             " , 0 PAGAR" +;
                          " from " + RetSqlName("SE1") + " SE1" +;
                         " where SE1.E1_SALDO   > 0" +;
                           " and SE1.E1_VENCREA between '" + DToS(mv_par01) + "' and '" + DToS(mv_par02) + "'" +;
                           " and SE1.E1_TIPO    like '%-'" +;
                           " and SE1.D_E_L_E_T_ = ' '" +;
                      " group by SE1.E1_VENCREA, SE1.E1_NATUREZ" +;
                         " union all" +;
                        " select SE2.E2_VENCREA DATA" +;
                             " , SE2.E2_NATUREZ NATUREZA" +;
                             " , 0 RECEBER" +;
                             " , sum(SE2.E2_SALDO)+sum(SE2.E2_ACRESC)-sum(SE2.E2_DECRESC) PAGAR" +;
                          " from " + RetSqlName("SE2") + " SE2" +;
                         " where SE2.E2_SALDO   > 0" +;
                           " and SE2.E2_VENCREA between '" + DToS(mv_par01) + "' and '" + DToS(mv_par02) + "'" +;
                           " and SE2.E2_TIPO    not in ('PA', 'NDF')" +;
                           " and SE2.D_E_L_E_T_ = ' '" +;
                      " group by E2_VENCREA, E2_NATUREZ" +;
               " )," +;
               " CTE as (" +;
                        " select row_number() over (order by ANCORA.DATA) ID, ANCORA.*" +;
                          " from (" +;
                                " select '        ' DATA, 'SLD_INICIA' NATUREZA, 0 RECEBER, 0 PAGAR, SALDO_INI SALDO_DIA" +;
                                  " from SALDO" +;
                                 " union all" +;
                                " select DATA, NATUREZA, SUM(RECEBER)AS RECEBER, SUM (PAGAR) AS PAGAR, SUM(RECEBER) - SUM ( PAGAR) AS SALDO_DIA" +;
                                  " from CAIXA" +;
                              " group by DATA, NATUREZA " +;
                               " ) ANCORA " +;
               " )" +;
                 " select DATA" +;
                      " , NATUREZA" +;
                      " , RECEBER" +;
                      " , PAGAR" +;
                      " , SALDO_DIA" +;
                      " , SALDO = (" +;
                                 " select sum(SALDO_DIA) " +;
                                   " from CTE " +;
                                  " where ID <= C.ID" +;
                        " ) " +;
                   " from CTE C" +;
               " order by DATA, NATUREZA"), "QRYFXCX", .f., .f.)
    while !QRYFXCX->(Eof())

        // Seta o saldo inicial (primeira linha da query)
        if Empty(QRYFXCX->DATA) .and. QRYFXCX->NATUREZA = 'SLD_INICIA'
            // Atribui a dDataAtu o valor do cabeçalho da coluna
            dDataAtu := aFxCx[nLinCabec][nColData]

            // Grava o saldo inicial na linha primeira coluna de nLinSldIni
            // nSaldoIni := QRYFXCX->SALDO
            // aFxCx[nLinSldIni][nColData] := nSaldoIni

            // vai para o proximo registro
            QRYFXCX->(DbSkip())
        endif
        
        // Quando a data for alterada
        if dDataAtu != SToD(QRYFXCX->DATA)
            // grava o total do dia e o saldo final na coluna corrente e
            // aFxCx[nLinTotDia][nColData] := nTotalDia
            // aFxCx[nLinSaldo][nColData] := nSaldoIni + Iif(mv_par03 == 3 .and. mv_par04 <> 1, -1, 1) * nTotalDia
            
            // troca a coluna para a que estiver na data
            nColData := aScan(aFxCx[nLinCabec], {|aMat| ValType(aMat) == "D" .and. aMat == SToD(QRYFXCX->DATA)})
            
            // Atribui a dDataAtu o valor do cabeçalho da coluna
            dDataAtu := aFxCx[nLinCabec][nColData]
            
            // grava o saldo inicial na nova coluna
            // nSaldoIni := nSaldoIni + nTotalDia
            // aFxCx[nLinSldIni][nColData] := nSaldoIni
            // nTotalDia := 0
        endif

        // Grava a natureza
        nLinNatu := aScan(aFxCx, {|aMat| aMat[1] == QRYFXCX->NATUREZA})
        if mv_par03 == 1
            // grava o saldo do dia
            aFxCx[nLinNatu][nColData] := QRYFXCX->SALDO_DIA
            // nTotalDia += QRYFXCX->SALDO_DIA
        elseif mv_par03 == 2
            // grava na linha o valor a receber desde que diferente de 0
            if QRYFXCX->RECEBER <> 0
                aFxCx[nLinNatu][nColData] := QRYFXCX->RECEBER
            endif
            // grava na proxima linha o valor a pagar desde que diferente de 0
            if QRYFXCX->PAGAR <> 0
                aFxCx[nLinNatu+1][nColData] := Iif(mv_par04 == 1, -1, 1) * QRYFXCX->PAGAR
            endif
            // nTotalDia += QRYFXCX->SALDO_DIA
        elseif mv_par03 == 3
            // grava o valor a pagar
            aFxCx[nLinNatu][nColData] := Iif(mv_par04 == 1, -1, 1) * QRYFXCX->PAGAR
            // nTotalDia += Iif(mv_par04 == 1, -1, 1) * QRYFXCX->PAGAR
        elseif mv_par03 == 4
            // grava o valor a receber
            aFxCx[nLinNatu][nColData] := QRYFXCX->RECEBER
            // nTotalDia += QRYFXCX->RECEBER
        endif
        // totaliza na variável nTotalDia o saldo do dia 
        QRYFXCX->(DbSkip())
    end

    // grava o total do dia e o saldo final na coluna corrente
    // aFxCx[nLinTotDia][nColData] := nTotalDia
    // aFxCx[nLinSaldo][nColData] := nSaldoIni + nTotalDia

    QRYFXCX->(DbCloseArea())
    
    AAdd(aWorkBook, {"Fx Caixa de " + DToS(mv_par01) + " a " + DToS(mv_par02), aFxCx})

    // 1=Saldo, 2=Pagar/Receber, 3=Somente pagar, 4=Somente receber.
    if mv_par03 == 1 .or. mv_par03 == 2 .or. mv_par03 == 3 
        DbUseArea(.t., "TOPCONN", TCGenQry(,,;
           " select SE2.E2_FILIAL" +;
                " , SE2.E2_NATUREZ" +;
                " , SED.ED_DESCRIC" +;
                " , SE2.E2_PREFIXO" +;
                " , SE2.E2_TIPO" +;
                " , SE2.E2_NUM" +;
                " , SE2.E2_PARCELA" +;
                " , SE2.E2_FORNECE + SE2.E2_LOJA E2_FORNECE" +;
                " , SE2.E2_NOMFOR" +;
                " , SE2.E2_EMISSAO" +;
                " , SE2.E2_VENCREA" +;
                " , SE2.E2_VALOR" +;
                " , SE2.E2_SALDO" +;
                " , SE2.E2_ACRESC" +;
                " , SE2.E2_DECRESC"  +;
             " from " + RetSqlName("SE2") + " SE2" +; 
             " join " + RetSqlName("SED") + " SED" +;
               " on SED.ED_FILIAL  = '" + FWxFilial("SED") + "'" +;
              " and SED.ED_CODIGO  = SE2.E2_NATUREZ" +;
              " and SED.D_E_L_E_T_ = ' '" +;
            " where SE2.E2_VENCREA between '" + DToS(mv_par01) + "' and '" + DToS(mv_par02) + "'" +;
              " and SE2.E2_SALDO   > 0" +;
              " and SE2.D_E_L_E_T_ = ' '" +; 
         " order by E2_VENCREA, E2_FILIAL, E2_NATUREZ"),"TMPSE2", .f., .f.)

            AAdd(aPagar, {})
            for i := 1 to TMPSE2->(FCount())
                AAdd(aPagar[Len(aPagar)], RetTitulo(TMPSE2->(FieldName(i))))
            next

            while !TMPSE2->(Eof())
                AAdd(aPagar, {})
                for i := 1 to TMPSE2->(fCount())
                    AAdd(aPagar[Len(aPagar)], TMPSE2->(FieldGet(i)))
                next
                TMPSE2->(DbSkip())
            end

        TMPSE2->(DbCloseArea())
        AAdd(aWorkBook, {"Pagar", aPagar})
    endif

    // 1=Saldo, 2=Pagar/Receber, 3=Somente pagar, 4=Somente receber.
    if mv_par03 == 1 .or. mv_par03 == 2 .or. mv_par03 == 4 
        DbUseArea(.t., "TOPCONN", TCGenQry(,,;
               " select SE1.E1_FILIAL" +;
                    " , SE1.E1_NATUREZ" +;
                    " , SED.ED_DESCRIC" +;
                    " , SE1.E1_PREFIXO" +;
                    " , SE1.E1_TIPO" +;
                    " , SE1.E1_NUM" +;
                    " , SE1.E1_PARCELA" +;
                    " , SE1.E1_CLIENTE + SE1.E1_LOJA E1_CLIENTE" +;
                    " , SE1.E1_NOMCLI" +;
                    " , SE1.E1_EMISSAO" +;
                    " , SE1.E1_VENCREA" +;
                    " , SE1.E1_VALOR" +;
                    " , SE1.E1_SALDO" +;
                    " , SE1.E1_ACRESC" +;
                    " , SE1.E1_DECRESC"+;
                 " from SE1010 SE1" +;
                 " join SED010 SED" +;
                   " on SED.ED_FILIAL = '" + FWxFilial("SED") + "'" +;
                  " and SED.ED_CODIGO = SE1.E1_NATUREZ" +;
                  " and SED.D_E_L_E_T_ = ' '" +;
                " where SE1.E1_VENCREA BETWEEN '" + DToS(mv_par01) + "' and '" + DToS(mv_par02) + "'" +;
                  " and SE1.E1_SALDO > 0" +;
                  " and SE1.D_E_L_E_T_ = ' '" +; 
             " order by SE1.E1_VENCREA, SE1.E1_FILIAL, SE1.E1_NATUREZ"),"TMPSE1", .f., .f.)

            AAdd(aReceber, {})
            for i := 1 to TMPSE1->(FCount())
                AAdd(aReceber[Len(aReceber)], RetTitulo(TMPSE1->(FieldName(i))))
            next

            while !TMPSE1->(Eof())
                AAdd(aReceber, {})
                for i := 1 to TMPSE1->(fCount())
                    AAdd(aReceber[Len(aReceber)], TMPSE1->(FieldGet(i)))
                next
                TMPSE1->(DbSkip())
            end

        TMPSE1->(DbCloseArea())
        AAdd(aWorkBook, {"Receber", aReceber})
    endif

    cFileName := MkExcWB( aWorkBook )
    if (CpyS2T(GetSrvProfString ("STARTPATH","") + cFileName, Alltrim(GetTempPath())))
        fErase(cFileName)
    
        // Abre excell
        if !ApOleClient( 'MsExcel' )
            MsgAlert("O excel não foi encontrado. Arquivo " + cFileName + " gerado em " + GetTempPath() + ".", "MsExcel não encontrado" )
        else
            oExcelApp := MsExcel():New()
            oExcelApp:WorkBooks:Open( GetTempPath()+cFileName )
            oExcelApp:SetVisible(.T.)
        endif
    else
        Help(,,"Erro ao criar planilha",,"Não foi possivel criar o arquivo " + cFileName + " no cliente no diretório " + GetTempPath() + ".", 1, 0,,,,,,  {"Por favor, contacte o suporte.", "Não foi possivel criar Planilha."} )
    endif
    
else
    Help(,,"Vazio",,"O Filtro selecionado não trouxe nenhum resultado.", 1, 0,,,,,, {"Por favor, preencha adequadamente o filtro."})
endif

return nil 

static function RetTitulo(cNomeCampo)
local aAreaSX3 := SX3->(GetArea())
local cTitulo := ""
    
    SX3->(DbSetOrder(2))
    SX3->(DbSeek(cNomeCampo))
    cTitulo := AllTrim(X3Titulo())

SX3->(RestArea(aAreaSX3))
return cTitulo

static function AtuSX1(cPerg)
local aArea    := GetArea()
local aAreaDic := SX1->( GetArea() )
local aEstrut  := {}
local aStruDic := SX1->( dbStruct() )
local aDados   := {}
local i       := 0
local j       := 0
local nTam1    := Len( SX1->X1_GRUPO )
local nTam2    := Len( SX1->X1_ORDEM )

cPerg := PadR(cPerg, Len(SX1->X1_GRUPO))

aEstrut := { "X1_GRUPO"  , "X1_ORDEM"  , "X1_PERGUNT", "X1_PERSPA" , "X1_PERENG" , "X1_VARIAVL", "X1_TIPO"   , ;
             "X1_TAMANHO", "X1_DECIMAL", "X1_PRESEL" , "X1_GSC"    , "X1_VALID"  , "X1_VAR01"  , "X1_DEF01"  , ;
             "X1_DEFSPA1", "X1_DEFENG1", "X1_CNT01"  , "X1_VAR02"  , "X1_DEF02"  , "X1_DEFSPA2", "X1_DEFENG2", ;
             "X1_CNT02"  , "X1_VAR03"  , "X1_DEF03"  , "X1_DEFSPA3", "X1_DEFENG3", "X1_CNT03"  , "X1_VAR04"  , ;
             "X1_DEF04"  , "X1_DEFSPA4", "X1_DEFENG4", "X1_CNT04"  , "X1_VAR05"  , "X1_DEF05"  , "X1_DEFSPA5", ;
             "X1_DEFENG5", "X1_CNT05"  , "X1_F3"     , "X1_PYME"   , "X1_GRPSXG" , "X1_HELP"   , "X1_PICTURE", ;
             "X1_IDFIL"  }

AAdd( aDados, {cPerg,'01','Data De?            ','¿Fecha de inicio?    ','From Date?      ','mv_ch1','D', 8,0,0,'G','',                        'mv_par01','',     '',     '',       '','','',             '',            '',           '','','',             '',          '',        '','','',               '',           '',            '','','','','','','','S','','','','', { "Informe a partir de qual data será criado o relatório fluxo de caixa.","Informe a partir de qué fecha se creará el informe de flujo de caja.","Inform from which date the cash flow report will be created."}} )
AAdd( aDados, {cPerg,'02','Data Ate?           ','¿Fecha de fin?       ','To Date?        ','mv_ch2','D', 8,0,0,'G','',                        'mv_par02','',     '',     '',       '','','',             '',            '',           '','','',             '',          '',        '','','',               '',           '',            '','','','','','','','S','','','','', { "Informe até qual data será criado o relatório fluxo de caixa.","Introduzca hasta qué fecha se creará el informe flujo de caja.","Report up to which date the cash flow report will be created."}} )
AAdd( aDados, {cPerg,'03','Detalhe?            ','¿Detalle?            ','Detail?         ','mv_ch3','N', 1,0,0,'C','',                        'mv_par03','Saldo','Saldo','Balance','','','Pagar/Receber','Pagar/Cobrar','Pay/Receive','','','Somente pagar','Sólo pagar','Only pay','','','Somente receber','Sólo cobrar','Only receive','','','','','','','','S','','','','', { "Informe se deseja ver o saldo da natureza no periodo, o total a pagar e receber.", "Informe si desea ver el saldo de la naturaleza en el período o el total a pagar y recibir por separado.", "Inform if you want to see the nature balance in the period or the total to be paid and received separately."}} )
AAdd( aDados, {cPerg,'04','Pagar como negativo?','¿Pagar como negativo?','Pay as negative?','mv_ch4','N', 1,0,0,'C','',                        'mv_par04','Sim',  'Si',   'Yes',    '','','Nao',          'No',          'Not',        '','','',             '',          '',        '','','',               '',           '',            '','','','','','','','S','','','','', { "Imprime o total a pagar como negativo?","Imprime el total a pagar como negativo?","Print the total to be paid as negative?"}} )
AAdd( aDados, {cPerg,'05','Banco?              ','¿Bancos?             ','Bank?           ','mv_ch5','C',99,0,0,'C','NaoVazio().or.u_VldVAF01()','mv_par05','',     '',     '',       '','','',             '',            '',           '','','',             '',          '',        '','','',               '',           '',            '','','','','','','','S','','','','', { "Selecione os bancos que serão usados para compor o saldo inicial.","Seleccione los bancos que se utilizar para representar el saldo inicial.","Select the banks that will be used to compose the opening balance."}} )

DbSelectArea( "SX1" )
SX1->(DbSetOrder( 1 ))

nLenLin := Len( aDados )
for i := 1 to nLenLin
    if !SX1->( DbSeek( PadR( aDados[i][1], nTam1 ) + PadR( aDados[i][2], nTam2 ) ) )
        RecLock( "SX1", .t. )
        nLenCol := Len( aEstrut )
        for j := 1 to nLenCol
            if aScan( aStruDic, { |aX| PadR( aX[1], 10 ) == PadR( aEstrut[j], 10 ) } ) > 0
                SX1->( FieldPut( FieldPos( aEstrut[j] ), aDados[i][j] ) )
            endif
        next
        MsUnLock()
        AtuSX1Hlp("P." + AllTrim(SX1->X1_GRUPO) + AllTrim(SX1->X1_ORDEM) + ".", aDados[i][nLenCol+1], .t.)
    endif
next

RestArea( aAreaDic )
RestArea( aArea )

return nil

/*/{Protheus.doc} VldVAF01
Função de validação usada na pergunta 5 para identificar as contas que farão parte do saldo inicial. 

@author jrscatolon@jrscatolon.com.br
@since  21/11/2018
@version 1.0
/*/
user function VldVAF01()
local mvRet := Alltrim(ReadVar())

    u_zConsMark("SA6", {"A6_COD","A6_AGENCIA","A6_NUMCON","A6_NOME"}, " AND A6_FLUXCAI = 'S' ", 99, "A6_COD+A6_AGENCIA+A6_NUMCON", .F., ";")
    &(mvRet) := Iif(SubStr(AllTrim(__cRetorn), Len(AllTrim(__cRetorn)),1)==';',SubStr(AllTrim(__cRetorn), 1, Len(AllTrim(__cRetorn))-1),AllTrim(__cRetorn))
    
return !Empty(__cRetorn)

/*/{Protheus.doc} AtuSX1Hlp
Função de processamento da gravação dos Helps de Perguntas

@author jrscatolon@jrscatolon.com.br
@since  21/11/2018
@version 1.0
/*/
static function AtuSX1Hlp(cKey, aHelp, lUpdate)
local cFilePor := "SIGAHLP.HLP"
local cFileEng := "SIGAHLE.HLE"
local cFileSpa := "SIGAHLS.HLS"
local nRet := 0
local cHelp := ""
local i, nLen
default cKey := ""
default aHelp := nil
default lUpdate := .F.
     
if !Empty(cKey) 
     
    // Português
    cHelp := ""

    if ValType(aHelp[1]) == "C"
        cHelp := aHelp[1]
    elseif ValType(aHelp[1]) == "A"
        nLen := Len(aHelp[1])
        for i := 1 to nLen
            cHelp += Iif(!Empty(cHelp), CRLF, "") + Iif(ValType(aHelp[1][i]) == "C", aHelp[1][i], "")
        next
    endif

    if !Empty(cHelp)
        nRet := SPF_SEEK(cFilePor, cKey, 1)
        if nRet < 0
            SPF_INSERT(cFilePor, cKey, , , cHelp)
        else
            if lUpdate
                SPF_UPDATE(cFilePor, nRet, cKey, , , cHelp)
            endif
        endif
    endif
    
    // Espanhol
    cHelp := ""

    if ValType(aHelp[2]) == "C"
        cHelp := aHelp[2]
    elseif ValType(aHelp[2]) == "A"
        nLen := Len(aHelp[2])
        for i := 1 to nLen
            cHelp += Iif(!Empty(cHelp), CRLF, "") + Iif(ValType(aHelp[2][i]) == "C", aHelp[2][i], "")
        next
    endif

    if !Empty(cHelp)
        nRet := SPF_SEEK(cFileSpa, cKey, 1)
        if nRet < 0
            SPF_INSERT(cFileSpa, cKey, , , cHelp)
        else
            if lUpdate
                SPF_UPDATE(cFileSpa, nRet, cKey, , , cHelp)
            endif
        endif
    endif

    // Inglês
    cHelp := ""

    if ValType(aHelp[3]) == "C"
        cHelp := aHelp[3]
    elseif ValType(aHelp[3]) == "A"
        nLen := Len(aHelp[3])
        for i := 1 to nLen
            cHelp += Iif(!Empty(cHelp), CRLF, "") + Iif(ValType(aHelp[3][i]) == "C", aHelp[3][i], "")
        next
    endif

    if !Empty(cHelp)
        nRet := SPF_SEEK(cFileEng, cKey, 1)
        if nRet < 0
            SPF_INSERT(cFileEng, cKey, , , cHelp)
        else
            if lUpdate
                SPF_UPDATE(cFileEng, nRet, cKey, , , cHelp)
            endif
        endif
    endif
endif

return nil

/*/{Protheus.doc} MkExcWB
Cria um workbook do excel

@author jrscatolon@jrscatolon
@since  21/11/2018
@version 1.0
/*/
static function MkExcWB( aWBook )
local cCreate   := AllTrim( Str( Year( dDataBase ) ) ) + "-" + AllTrim( Str( Month( dDataBase ) ) ) + "-" + AllTrim( Str( Day( dDataBase ) ) ) + "T" + SubStr( Time(), 1, 2 ) + ":" + SubStr( Time(), 4, 2 ) + ":" + SubStr( Time(), 7, 2 ) + "Z" // string de data no formato <Ano>-<Mes>-<Dia>T<Hora>:<Minuto>:<Segundo>Z
local i, j, k
local cWorkBook := ""
local cFileName := CriaTrab(,.F.)+".xml"
local aWSheet := {}

if !( nHandle := FCreate( cFileName, FC_NORMAL ) ) != -1
    MsgAlert("Não foi possivel criar a planilha [" + cFileName + "]. Por favor, verifique se existe espaço em disco ou você possui pemissão de escrita no diretório \system\", "Erro de criação de arquivo")
else

    cWorkBook := "<?xml version=" + Chr(34) + "1.0" + Chr(34) + "?>" + Chr(13) + Chr(10)
    cWorkBook += "<?mso-application progid=" + Chr(34) + "Excel.Sheet" + Chr(34) + "?>" + Chr(13) + Chr(10)
    cWorkBook += "<Workbook xmlns=" + Chr(34) + "urn:schemas-microsoft-com:office:spreadsheet" + Chr(34) + " " + Chr(13) + Chr(10)
    cWorkBook += "    xmlns:o=" + Chr(34) + "urn:schemas-microsoft-com:office:office" + Chr(34) + " " + Chr(13) + Chr(10)
    cWorkBook += "    xmlns:x=" + Chr(34) + "urn:schemas-microsoft-com:office:excel" + Chr(34) + " " + Chr(13) + Chr(10)
    cWorkBook += "    xmlns:ss=" + Chr(34) + "urn:schemas-microsoft-com:office:spreadsheet" + Chr(34) + " " + Chr(13) + Chr(10)
    cWorkBook += "    xmlns:html=" + Chr(34) + "http://www.w3.org/TR/REC-html40" + Chr(34) + ">" + Chr(13) + Chr(10)
    cWorkBook += "    <DocumentProperties xmlns=" + Chr(34) + "urn:schemas-microsoft-com:office:office" + Chr(34) + ">" + Chr(13) + Chr(10)
    cWorkBook += "        <Author>" + AllTrim(SubStr(cUsuario,7,15)) + "</Author>" + Chr(13) + Chr(10)
    cWorkBook += "        <LastAuthor>" + AllTrim(SubStr(cUsuario,7,15)) + "</LastAuthor>" + Chr(13) + Chr(10)
    cWorkBook += "        <Created>" + cCreate + "</Created>" + Chr(13) + Chr(10)
    cWorkBook += "        <Company>Microsiga Intelligence</Company>" + Chr(13) + Chr(10)
    cWorkBook += "        <Version>11.6568</Version>" + Chr(13) + Chr(10)
    cWorkBook += "    </DocumentProperties>" + Chr(13) + Chr(10)
    cWorkBook += "    <ExcelWorkbook xmlns=" + Chr(34) + "urn:schemas-microsoft-com:office:excel" + Chr(34) + ">" + Chr(13) + Chr(10)
    cWorkBook += "        <WindowHeight>9345</WindowHeight>" + Chr(13) + Chr(10)
    cWorkBook += "        <WindowWidth>11340</WindowWidth>" + Chr(13) + Chr(10)
    cWorkBook += "        <WindowTopX>480</WindowTopX>" + Chr(13) + Chr(10)
    cWorkBook += "        <WindowTopY>60</WindowTopY>" + Chr(13) + Chr(10)
    cWorkBook += "        <ProtectStructure>False</ProtectStructure>" + Chr(13) + Chr(10)
    cWorkBook += "        <ProtectWindows>False</ProtectWindows>" + Chr(13) + Chr(10)
    cWorkBook += "    </ExcelWorkbook>" + Chr(13) + Chr(10)
    cWorkBook += "    <Styles>" + Chr(13) + Chr(10)
    cWorkBook += "        <Style ss:ID=" + Chr(34) + "Default" + Chr(34) + " ss:Name=" + Chr(34) + "Normal" + Chr(34) + ">" + Chr(13) + Chr(10)
    cWorkBook += "            <Alignment ss:Vertical=" + Chr(34) + "Bottom" + Chr(34) + "/>" + Chr(13) + Chr(10)
    cWorkBook += "            <Borders/>" + Chr(13) + Chr(10)
    cWorkBook += "            <Font/>" + Chr(13) + Chr(10)
    cWorkBook += "            <Interior/>" + Chr(13) + Chr(10)
    cWorkBook += "            <NumberFormat/>" + Chr(13) + Chr(10)
    cWorkBook += "            <Protection/>" + Chr(13) + Chr(10)
    cWorkBook += "        </Style>" + Chr(13) + Chr(10)
    cWorkBook += "        <Style ss:ID=" + Chr(34) + "DataHora" + Chr(34) + " ss:Parent=" + Chr(34) + "Default" + Chr(34) + ">" + Chr(13) + Chr(10)
    cWorkBook += "            <NumberFormat ss:Format=" + Chr(34) + "Short Date" + Chr(34) + "/>" + Chr(13) + Chr(10)
    cWorkBook += "        </Style>" + Chr(13) + Chr(10)
    cWorkBook += "        <Style ss:ID=" + Chr(34) + "Contabil" + Chr(34) + " ss:Parent=" + Chr(34) + "Default" + Chr(34) + ">" + Chr(13) + Chr(10)
    cWorkBook += "            <NumberFormat ss:Format=" + Chr(34) + "_-* #,##0.00_-;\-* #,##0.00_-;_-* &quot;-&quot;??_-;_-@_-" + Chr(34) + "/>" + Chr(13) + Chr(10)
    cWorkBook += "        </Style>" + Chr(13) + Chr(10)
    cWorkBook += "        <Style ss:ID=" + Chr(34) + "Amarelo" + Chr(34) + " ss:Parent=" + Chr(34) + "Contabil" + Chr(34) + ">" + Chr(13) + Chr(10)
    cWorkBook += "             <Interior ss:Color=" + Chr(34) + "#FFFF00" + Chr(34) + " ss:Pattern=" + Chr(34) + "Solid" + Chr(34) + "/>" + Chr(13) + Chr(10)
    cWorkBook += "        </Style>" + Chr(13) + Chr(10)
    cWorkBook += "    </Styles>" + Chr(13) + Chr(10)
    FWrite(nHandle, cWorkBook)
    
    for i := 1 to Len(aWBook)
        aWSheet := aWBook[i][2]

        cWorkBook := "    <Worksheet ss:Name=" + Chr(34) + aWBook[i][1] + Chr(34) + ">" + Chr(13) + Chr(10)
        cWorkBook += "        <Table>" + Chr(13) + Chr(10)
        
        FWrite(nHandle, cWorkBook)
        
        nQtdLine := Len(aWSheet)
        for j := 1 To nQtdLine
            cWorkBook := "            <Row>" + Chr(13) + Chr(10)
            nLenLine := Len(aWSheet[j])
            for k := 1 to nLenLine
                cWorkBook += "                " + FS_GetCell(Iif(aWSheet[j][k] == Nil, {0, }, aWSheet[j][k])) + Chr(13) + Chr(10)
            next
            cWorkBook += "            </Row>" + Chr(13) + Chr(10)
            FWrite(nHandle, cWorkBook)
        next
            
        cWorkBook := "        </Table>" + Chr(13) + Chr(10)
        cWorkBook += "        <WorksheetOptions xmlns=" + Chr(34) + "urn:schemas-microsoft-com:office:excel" + Chr(34) + ">" + Chr(13) + Chr(10)
        cWorkBook += "            <PageSetup>" + Chr(13) + Chr(10)
        cWorkBook += "                <Header x:Margin=" + Chr(34) + "0.49212598499999999" + Chr(34) + "/>" + Chr(13) + Chr(10)
        cWorkBook += "                <Footer x:Margin=" + Chr(34) + "0.49212598499999999" + Chr(34) + "/>" + Chr(13) + Chr(10)
        cWorkBook += "                <PageMargins x:Bottom=" + Chr(34) + "0.984251969" + Chr(34) + " x:Left=" + Chr(34) + "0.78740157499999996" + Chr(34) + " x:Right=" + Chr(34) + "0.78740157499999996" + Chr(34) + " x:Top=" + Chr(34) + "0.984251969" + Chr(34) + "/>" + Chr(13) + Chr(10)
        cWorkBook += "            </PageSetup>" + Chr(13) + Chr(10)
        cWorkBook += "            <Selected/>" + Chr(13) + Chr(10)
        cWorkBook += "            <ProtectObjects>False</ProtectObjects>" + Chr(13) + Chr(10)
        cWorkBook += "            <ProtectScenarios>False</ProtectScenarios>" + Chr(13) + Chr(10)
        cWorkBook += "        </WorksheetOptions>" + Chr(13) + Chr(10)
        cWorkBook += "    </Worksheet>" + Chr(13) + Chr(10)
        FWrite(nHandle, cWorkBook)
    next
    
    cWorkBook := "</Workbook>" + Chr(13) + Chr(10)
    
    FWrite(nHandle, cWorkBook)
    cWorkBook := ""
    FClose(nHandle)
endif

return cFileName

/*/{Protheus.doc} FS_GetCell
Retorna o dado passado em xVar como uma célula do excel

@author jrscatolon@jrscatolon
@since  21/11/2018
@version 1.0
/*/
static function FS_GetCell( xVar )
local cRet  := ""
local cType := ""

if ValType(xVar) == "A"
    cType := Iif(ValType(xVar) == "A", ValType(xVar[1]), "U")
    
    if cType == "U"
        cRet := "<Cell/>"
    elseif cType == "C"
        if SubStr(xVar[1],1,1) == "="
            if xVar[2] <> nil
                cRet := "<Cell ss:StyleID=" + Chr(34) + xVar[2] + Chr(34) + " ss:Formula=" + Chr(34) + xVar[1] + Chr(34) + "></Cell>"
            else
                cRet := "<Cell ss:Formula=" + Chr(34) + xVar[1] + Chr(34) + "></Cell>"
            endif
        else
            cRet := "<Data ss:Type=" + Chr(34) + "String" + Chr(34) + ">" + Format( xVar[1] ) + "</Data>"
            if xVar[2] <> nil
                cRet := "<Cell ss:StyleID=" + Chr(34) + xVar[2] + Chr(34) + ">" + cRet + "</Cell>"
            else
                cRet := "<Cell>" + cRet + "</Cell>"
            endif
        endif
    elseif cType == "N"
        cRet := "<Data ss:Type=" + Chr(34) + "Number" + Chr(34) + ">" + AllTrim( Str( xVar[1] ) ) + "</Data>"
        if xVar[2] <> nil
            cRet := "<Cell ss:StyleID=" + Chr(34) + xVar[2] + Chr(34) + ">" + cRet + "</Cell>"
        else
            cRet := "<Cell>" + cRet + "</Cell>"
        endif
    elseif cType == "D"
        xVar[1] := DToS( xVar[1] )
        cRet := "<Cell ss:StyleID=" + Chr(34) + "DataHora" + Chr(34) + "><Data ss:Type=" + Chr(34) + "DateTime" + Chr(34) + ">" + SubStr(xVar[1], 1, 4) + "-" + SubStr(xVar[1], 5, 2) + "-" + SubStr(xVar[1], 7, 2) + "T00:00:00.000</Data></Cell>"
    else
        cRet := "<Cell><Data ss:Type=" + Chr(34) + "Boolean" + Chr(34) + ">" + Iif ( xVar[1] , "=VERDADEIRO" ,  "=FALSO" ) + "</Data></Cell>"
    endif
else

    cType := ValType(xVar)

    if cType == "U"
        cRet := "<Cell/>
    elseif cType == "C"
        if SubStr(xVar,1,1) == "="
            cRet := "<Cell ss:StyleID=" + Chr(34) + "Contabil" + Chr(34) + " ss:Formula=" + Chr(34) + xVar + Chr(34) + "><Data ss:Type=" + Chr(34) + "String" + Chr(34) + ">" + Format(xVar) + "</Data></Cell>"
        else
            cRet := "<Cell><Data ss:Type=" + Chr(34) + "String" + Chr(34) + ">" + Format( xVar ) + "</Data></Cell>
        endif
    elseif cType == "N"
        cRet := "<Cell><Data ss:Type=" + Chr(34) + "Number" + Chr(34) + ">" + AllTrim( Str( xVar ) ) + "</Data></Cell>"
    elseif cType == "D"
        xVar := DToS( xVar )
        cRet := "<Cell ss:StyleID=" + Chr(34) + "DataHora" + Chr(34) + "><Data ss:Type=" + Chr(34) + "DateTime" + Chr(34) + ">" + SubStr(xVar, 1, 4) + "-" + SubStr(xVar, 5, 2) + "-" + SubStr(xVar, 7, 2) + "T00:00:00.000</Data></Cell>"
    else
        cRet := "<Cell><Data ss:Type=" + Chr(34) + "Boolean" + Chr(34) + ">" + Iif ( xVar , "=VERDADEIRO" ,  "=FALSO" ) + "</Data></Cell>"
    endif
endif

return cRet

/*/{Protheus.doc} Format
Remove caracteres especiais do dado

@author jrscatolon@jrscatolon
@since  21/11/2018
@version 1.0
/*/
static function Format( cVar )
local nLen := 0
local i    := 0
local aPad := { { 'ã', 'a' }, { 'á' , 'a' }, { 'â', 'a' }, { 'ä', 'a' }, ;
                { 'Ã', 'A' }, { 'Á' , 'A' }, { 'Â', 'A' }, { 'Ä', 'A' }, ;
                { 'é', 'e' }, { 'ê' , 'e' }, { 'ë', 'e' }, ;
                { 'É', 'E' }, { 'Ê' , 'E' }, { 'Ë', 'E' }, ;
                { 'í', 'i' }, { 'î' , 'i' }, { 'ï', 'i' }, ; 
                { 'õ', 'o' }, { 'ó' , 'o' }, { 'ô', 'o' }, { 'ö', 'o' },;
                { 'Õ', 'O' }, { 'Ó' , 'O' }, { 'Ô', 'O' }, { 'Ö', 'O' },;
                { 'ú', 'u' }, { 'û' , 'u' }, { 'ü', 'u' }, ;
                { 'Ú', 'U' }, { 'Û' , 'U' }, { 'Ü', 'U' }, ;
                { 'ç', 'c' }, ;
                { 'Ç', 'C' }, ;
                { '&', '' } }
                
nLen := Len(aPad)
for i := 1 to nLen
   cVar := StrTran(cVar, aPad[i][1], aPad[i][2])
next

return AllTrim(cVar)
