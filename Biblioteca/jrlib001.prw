#include 'Protheus.ch'
#include 'FileIO.ch'
#include 'tryexception.ch'
#include "Set.ch"


user function clibx001(); return "1.00.32"
 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ BDados   บAutor  ณAndr้ Cruz          บ Data ณ  09/16/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria as defini็๕es de AHeader e ACols para a MSNewGetDados บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
Parametro aJoin Ex.:
AAdd(aJoin, {RetSqlName("SB1") + " SB1", "SB1.B1_DESC" , "SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' AND SB1.B1_COD = GD5.GD5_CODDES", "GD5_DDESPE"})
             Arquivo e Alias           , Campo origem  , Condi็ใo de relacionamento entre os arquivos                                                        , Campo destino
*/
user function BDados(cAlias, aHDados, aCDados, nUDados, nOrd, lFilial, cCond, lStatus, cCpoLeg, cLstCpo, cElimina, cCpoNao, cStaReg, cCpoMar, cMarDef, lLstCpo, aLeg, lEliSql, lOrderBy, cCposGrpBy, cGroupBy, aCposIni, aJoin, aCposCalc, cOrderBy, aCposVis, aCposAlt, cCpoFilial, nOpcX, lMostRecNo, lLinMax)
//local aCpos      := { { "T", "GFR" } }
local aArea      := U_SavArea({{cAlias /*Alias()*/, 0, 0}}), nCol := 0, nTotItens := 0, cCampo := "", nForCpos := 0, aVCposOld := {}, nCposOld := 0
local cSql       := "", cCposSql := "", cCondSql := "", nFor := 0
local nACond     := 0, aArqCond := Iif(aJoin == nil, {}, aJoin), cArqLst := RetSqlName(cAlias) + " " + cAlias
local nQtdLinMax := IIf(nUDados <> nil, nUDados, 0), nPosDef := 0
local nOperLog   := 0
Local aOperLog   := {".and.", ".anD.", ".aNd.", ".aND.", ".And.", ".AnD.", ".ANd.", ".AND.", ".OR.", ".Or.", ".oR.", ".or.", ".not.", ".noT.", ".nOt.", ".nOT.", ".Not.", ".NoT.", ".NOt.", ".NOT." }
// local lGFR       := U_ExisDic(aCpos,.F.)
local aCVirtual  := {}

private cAliasTmp := ""

default aLeg       := {{".T.", "BR_AZUL"}}
default aCposCalc  := {}
default lEliSql    := .T.
default lOrderBy   := .T.
default lLstCpo    := !Empty(cLstCpo)
default cStaReg    := "BR_VERDE"
default cMarDef    := "'LBNO'"
default aCposVis   := {}
default aCposAlt   := {}
default lFilial    := .T.
default nOpcX      := Iif(Type("NOPC") == "U", 3, nOpc)
default lMostRecNo := .t.
default nUDados    := 0
default lLinMax	   := .F.

// Para garantir valor l๓gico ao campo lFilial
lFilial := Iif(ValType(lFilial) <> "L", .T., lFilial)

// Para garantir valor l๓gico ao campo lStatus
lStatus := Iif(ValType(lStatus) <> "L", .F., lStatus)

// Para garantir o valor caracter ao campo cStaReg
cStaReg := Iif(ValType(cStaReg) <> "C", "BR_VERDE", cStaReg)

//Salva valor das variaveis de memoria para restaurar no final
DbSelectArea("SX3")
DbSetOrder(1) // X3_ARQUIVO + X3_ORDEM
DbSeek(cAlias)
while SX3->X3_ARQUIVO == cAlias
    if Type("M->" + SX3->X3_CAMPO) <> "U"
        AAdd(aVCposOld, {"M->" + SX3->X3_CAMPO , &("M->" + SX3->X3_CAMPO) })
    endif
    SX3->(DbSkip())
end

cLstCpo := Iif(cLstCpo == nil, "", cLstCpo)

if lStatus
    nUDados++
    AAdd(aHDados, Sx3Defs(.T., "HSP_STAREG", 1, "'BR_VERMELHO'"))
endif

if cCpoLeg # nil
    DbSetOrder(2)
    if DbSeek(PadR(AllTrim(cCpoLeg), 10))
        nUDados++
        AAdd(aHDados, Sx3Defs(.T., PadR(AllTrim(cCpoLeg), 10), SX3->X3_TAMANHO))
    endif
endif

DbSelectArea("SX3")
if cCpoMar # nil
    if ValType(cCpoMar) == "A"
        for nFor := 1 to Len (cCpoMar)
            DbSetOrder(2) // X3_CAMPO
            if DbSeek(PadR(AllTrim(cCpoMar[nFor]), 10))
                nUDados++
                AAdd(aHDados, Sx3Defs(.T., PadR(AllTrim(cCpoMar[nFor]), 10), 1))
            endif
        next nFor
    else
        DbSetOrder(2)
        if DbSeek(PadR(AllTrim(cCpoMar), 10))
            nUDados++
            AAdd(aHDados, Sx3Defs(.T., PadR(AllTrim(cCpoMar), 10), 1))
        endif
    endif
endif

if aCposIni # nil
    for nForCpos := 1 to Len(aCposIni)
        DbSetOrder(2)
        if DbSeek(PadR(AllTrim(aCposIni[nForCpos]), 10))
            nUDados++
            AAdd(aHDados, Sx3Defs(.F., PadR(AllTrim(aCposIni[nForCpos]), 10),,,, aCposVis, aCposAlt))
        endif
    next
endif

DbSetOrder(1)
DbSeek(cAlias)
while !Eof() .and. SX3->X3_ARQUIVO == cAlias
    if cLstCpo == "ALL"; 
	  .or. (    !lLstCpo;
      .and. X3Uso(SX3->X3_USADO); 
      .and. cNivel >= SX3->X3_NIVEL; 
      .and. SX3->X3_BROWSE == "S";
      .and. Iif(aCposIni == nil, .T., aScan(aCposIni, SX3->X3_CAMPO) == 0); 
      .and. Iif(cCpoLeg == nil,  .T., SX3->X3_CAMPO # PadR(AllTrim(cCpoLeg), 10)); 
      .and. Iif(cCpoMar == nil,  .T., Iif(ValType(cCpoMar) == "C" , SX3->X3_CAMPO # PadR(AllTrim(cCpoMar), 10), aScan(cCpoMar,{|aVet| SX3->X3_CAMPO == PadR(AllTrim(cCpoMar[1]),10) }) == 0 )); 
      .and. Iif(cCpoNao == nil,  .T., !(SX3->X3_CAMPO $ cCpoNao));
       );
      .or. (Iif(!Empty(cLstCpo), SX3->X3_CAMPO $ cLstCpo, lLstCpo))
        
        nUDados++
        AAdd(aHDados, Sx3Defs(.F., SX3->X3_CAMPO,,,, aCposVis, aCposAlt))
        
        if SX3->X3_TIPO # "M" .and. SX3->X3_CONTEXT == "V" .and. !Empty(SX3->X3_RELACAO) .and. IsJoin(SX3->X3_RELACAO)
            AAdd(aCVirtual, {SX3->X3_CAMPO, STRTRAN(STRTRAN(UPPER(SX3->X3_RELACAO), " ", ""), "'", '"'), SX3->X3_ORDEM})
        endif
    endif
    
    if SX3->X3_CONTEXT # "V" .and. SX3->X3_TIPO # "M"
        cCposSql += Iif(!Empty(cCposSql), ", ", "") + cAlias + "." + AllTrim(SX3->X3_CAMPO)
    elseif SX3->X3_CONTEXT # "V" .and. SX3->X3_TIPO == "M"
        cCposSql += Iif(!Empty(cCposSql), ", ", "") + cAlias + ".R_E_C_N_O_ " + AllTrim(SX3->X3_CAMPO)
    endif
    
    DbSkip()
EndDo

if Len(aCposCalc) > 0
    for nForCpos := 1 to Len(aCposCalc)
        DbSetOrder(2)
        if DbSeek(PadR(AllTrim(aCposCalc[nForCpos, 1]), 10))
            nUDados++
            AAdd(aHDados, Sx3Defs(.F., aCposCalc[nForCpos, 3],,, aCposCalc[nForCpos, 2]))
        endif
    next
endif

if lMostRecNo
    AAdd(aHDados, Sx3Defs(.f., "ALIAS"))
    AAdd(aHDados, Sx3Defs(.f., "RECNO"))
    cCposSql += Iif(!Empty(cCposSql), ", ", "") + "'" + cAlias + "' ALIAS, " + cAlias + ".R_E_C_N_O_ RECNO"
    nUDados := Len(aHDados) // nUDados += 2
endif

if cCond # nil
    U_ArqCond(cAlias, @aArqCond, aCVirtual, lFilial, cCpoFilial)
    
    for nACond := 1 to Len(aArqCond)
        if !Empty(aArqCond[nACond, 1]) .and. !Empty(aArqCond[nACond, 3])
            cArqLst += Iif("left join"$aArqCond[nACond, 1],""," inner join ") + aArqCond[nACond, 1] + " on " + aArqCond[nACond, 3] + " "
        endif
        
        if !Empty(aArqCond[nACond, 2])
            cCposSql += ", " + aArqCond[nACond, 2] + " " + aArqCond[nACond, 4]
        endif
    next
    
    // Monta Ramk para o restante dos bancos diferentes de DB2
    if !("DB2" $ TCGetDB()) .and. nQtdLinMax > 0 .and. lLinMax
        if "ORACLE" $ TCGetDB()
            cSql := " select " + Iif(cCposGrpBy # nil, cCposGrpBy, cCposSql) +;
                      " from " + cArqLst + " " + ;
                     " where ROWNUM <= "  + AllTrim(Str(nQtdLinMax)) + " and " + Iif(lFilial, cAlias + "." + PrefixoCpo(cAlias) + "_FILIAL = '" + xFilial(cAlias) + "' and ", "") + cAlias + ".D_E_L_E_T_ <> '*'"
            
        else
            cSql := " select top " + AllTrim(Str(nQtdLinMax)) + " " + Iif(cCposGrpBy # nil, cCposGrpBy, cCposSql) +;
                      " from " + cArqLst + " " + ;
                     " where " + Iif(lFilial, cAlias + "." + PrefixoCpo(cAlias) + "_FILIAL = '" + xFilial(cAlias) + "' and ", "") + cAlias + ".D_E_L_E_T_ <> '*'"
            
        endif
    else
        cSql := "select " + Iif(cCposGrpBy # nil, cCposGrpBy, cCposSql) + ;
                 " from " + cArqLst + " " + ;
                " where " + Iif(lFilial, cAlias + "." + PrefixoCpo(cAlias) + "_FILIAL = '" + xFilial(cAlias) + "' and ", "") + cAlias + ".D_E_L_E_T_ <> '*'"
    endif
    if !Empty(cCond)
        cCondSql := cCond
        
        for nOperLog := 1 to len(aOperLog)
            cCondSql := StrTran(cCondSql, aOperLog[nOperLog], Iif(LEN(aOperLog[nOperLog]) == 4, " or ", Iif(Upper(SubStr(aOperLog[nOperLog],2,1)) == "A", " and ", " not ")))
        next nOperLog
        
        cCondSql := StrTran(cCondSql, "->", ".")
        cCondSql := StrTran(cCondSql, "==", "=")
        cCondSql := StrTran(cCondSql, "#", "<>")
        cSql += " and (" + cCondSql + ")"
    endif
    
    if !Empty(cElimina) .and. lEliSql
        cCondSql := cElimina
        
        for nOperLog := 1 to len(aOperLog)
            cCondSql := StrTran(cCondSql, aOperLog[nOperLog], Iif(LEN(aOperLog[nOperLog]) == 4, " or ", Iif(Upper(SubStr(aOperLog[nOperLog],2,1)) == "A", " and ", " not ")))
        next nOperLog
        
        cCondSql := StrTran(cCondSql, "->", ".")
        cCondSql := StrTran(cCondSql, "==", "=")
        cCondSql := StrTran(cCondSql, "#", "<>")
        cSql += " and not (" + cCondSql + ")"
    endif
    
    if cGroupBy # nil
        cSql += " group by " + cGroupBy
    endif
    
    if lOrderBy
        if cOrderBy # nil .and. !Empty(cOrderBy)
            cSql += " order by " + cOrderBy
        elseif Iif(!Empty(nOrd), U_ExisDic({{"I", cAlias, nOrd}}, .F.), .T.)
            cSql += " order by " + SqlOrder((cAlias)->(IndexKey(nOrd)))
        endif
    endif
    
    // Monta Ramk para banco de dados DB2
    if "DB2" $ TCGetDB() .and. nQtdLinMax > 0 .and. lLinMax
        cSql += " fetch first " + AllTrim(Str(nQtdLinMax)) + " rows only"
    endif
    
    cSql := ChangeQuery(cSql)
    
    while Alias() <> "TMP" + cAlias
       DbUseArea(.T.,"TOPCONN",TCGenQry(,,ChangeQuery(cSql)),"TMP" + cAlias, .T., .F.)
       inkey(.1)
    end
    
    for nCol := 1 to Len(aHDados)
        if aHDados[nCol, 10] <> "V" .and. aHDados[nCol, 08] $ "D/N"
            TCSetField("TMP" + cAlias, aHDados[nCol, 02], aHDados[nCol, 08], aHDados[nCol, 04], aHDados[nCol, 05])
        endif
    next
    
    if ValType(cMarDef) == "A"
        for nFor := 1 to Len(cMarDef)
            cMarDef[nFor] := StrTran(cMarDef[nFor], cAlias + "->", "TMP" + cAlias + "->")
        next nFor
    else
        cMarDef := StrTran(cMarDef, cAlias + "->", "TMP" + cAlias + "->")
    endif
    
    cAliasTmp := "TMP" + cAlias
    DbSelectArea(cAliasTmp)
    
    while !Eof()
        if cElimina # nil .and. !lEliSql .and. &(cElimina)
            DbSkip()
            Loop
        endif
        
        AAdd(aCDados, Array(nUDados + 1))
        for nCol := 1 to nUDados
            nPosDef := 0
            if (nForCpos := aScan(aCposCalc, {| aVet | aVet[3] == aHDados[nCol, 2]})) > 0
                aCDados[Len(aCDados), nCol] := &(aCposCalc[nForCpos, 4])
            elseif IIf(ValType(cCpoMar) == "C", aHDados[nCol, 2] == PadR(AllTrim(cCpoMar), 10) , (nPosDef := aScan(cCpoMar,{|aVet| aHDados[nCol, 2] == PadR(AllTrim(aVet),10) })) <> 0 )
                aCDados[Len(aCDados), nCol] := IIf(nPosDef == 0, &(cMarDef), &(cMarDef[nPosDef]))
            elseif aHDados[nCol, 2] == PadR(AllTrim(cCpoLeg), 10)
                aCDados[Len(aCDados), nCol] := LegBD(aLeg,cCond)
            elseif aHDados[nCol, 2] == "RECNO"
                aCDados[Len(aCDados), nCol] := (cAliasTmp)->RECNO // (Alias())->RECNO
            elseif aHDados[nCol, 2] == "ALIAS"
                aCDados[Len(aCDados), nCol] := cAlias //(Alias())->ALIAS
            elseif aHDados[nCol, 8] == "M" .and. aHDados[nCol, 10] # "V"
                DbSelectArea(cAlias)
                DbSetOrder(1)
                DbGoTo((cAliasTmp)->&(aHDados[nCol, 2]))
                aCDados[Len(aCDados), nCol] := (cAlias)->&(aHDados[nCol, 2]) 
            else
                if aHDados[nCol, 10] # "V"
                    aCDados[Len(aCDados), nCol] := FieldGet(FieldPos(aHDados[nCol, 2]))
                else
                    aCDados[Len(aCDados), nCol] := RPadrao(cAliasTmp, aHDados[nCol], aArqCond)
                endif
                cCampo    := "M->" + aHDados[nCol, 2]
                _SetNamedPrvt(cCampo, aCDados[Len(aCDados), nCol], Iif(IsInCallStack( FunName() ), FunName(), "U_" + FunName()))
                //&(cCampo) := aCDados[Len(aCDados), nCol]
            endif
        next
        aCDados[Len(aCDados), nUDados + 1] := .F.
        nTotItens++
        
        DbSelectArea(cAliasTmp)
        DbSkip()
    EndDo
endif

if Empty(aCDados)
    AAdd(aCDados, Array(nUDados + 1))
    for nCol := 1 to nUDados
        if nOpcX == 3
            nPosDef := 0
            if (nForCpos := aScan(aCposCalc, {| aVet | aVet[3] == aHDados[nCol, 2]})) > 0
                aCDados[Len(aCDados), nCol] := &(aCposCalc[nForCpos, 4])
            elseif IIf(ValType(cCpoMar) == "C", aHDados[nCol, 2] == PadR(AllTrim(cCpoMar), 10) , (nPosDef := aScan(cCpoMar,{|aVet| aHDados[nCol, 2] == PadR(AllTrim(aVet),10) })) <> 0 )
                aCDados[Len(aCDados), nCol] := IIf(nPosDef == 0, &(cMarDef), &(cMarDef[nPosDef]))
            elseif aHDados[nCol, 2] == PadR(AllTrim(cCpoLeg), 10)
                aCDados[Len(aCDados), nCol] := LegBD(aLeg,cCond)
            elseif aHDados[nCol, 2] == "RECNO"
                aCDados[Len(aCDados), nCol] := 0
            elseif aHDados[nCol, 2] == "ALIAS"
                aCDados[Len(aCDados), nCol] := cAlias
            else
                aCDados[Len(aCDados), nCol] := RPadrao(cAliasTmp, aHDados[nCol], aArqCond)
            
                cCampo    := "M->" + aHDados[nCol, 2]
                _SetNamedPrvt(cCampo, aCDados[Len(aCDados), nCol], Iif(IsInCallStack( FunName() ), FunName(), "U_" + FunName()))
                //&(cCampo) := aCDados[Len(aCDados), nCol]
            endif
        else
            if aHDados[nCol, 2] == "RECNO"
                aCDados[Len(aCDados), nCol] := 0
            elseif aHDados[nCol, 2] == "ALIAS"
                aCDados[Len(aCDados), nCol] := cAlias
            else
                aCDados[Len(aCDados), nCol] := CriaVar(aHDados[nCol, 2],.F.)

                cCampo    := "M->" + aHDados[nCol, 2]
                _SetNamedPrvt(cCampo, aCDados[Len(aCDados), nCol], Iif(IsInCallStack( FunName() ), FunName(), "U_" + FunName()))
                //&(cCampo) := aCDados[Len(aCDados), nCol]
            endif
        endif
    next
    aCDados[Len(aCDados), nUDados + 1] := .F.
endif

if cCond # nil
    DbSelectArea(cAliasTmp)
    DbCloseArea()
endif

U_ResArea(aArea)
DbSelectArea(aArea[1][1])

for nCposOld := 1 to Len(aVCposOld)
    &(aVCposOld[nCposOld, 1]) := aVCposOld[nCposOld, 2]
next
return nTotItens

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ArqCond  บAutor  ณ Andr้ Cruz         บ Data ณ  09/16/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria as condi็๕es SQL utilizadas para filtro em queries.   บฑฑ
ฑฑบ          ณ Utilizada pela BDados                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user function ArqCond(cADes, aArqCond, aCVirtual, lFilial, cCpoFilial)
local nCVirtual  := 0
local nPStr      := 0
local cRStr      := ""
local cAOri      := ""
local cNOrd      := ""
local cPChv      := ""
local cIChv      := ""
local nIChv      := 0
local nPChv      := 0
local cRCpo      := ""
local cCond      := ""
local lCpoFilial := !Empty(cCpoFilial) .and. &(cADes)->(FieldPos(cCpoFilial)) > 0
local lArqExclus := .F.

// Inclui o alias do arquivo principal no campo
cCpoFilial := IIf(!Empty(cCpoFilial), cADes + "." + cCpoFilial, nil)

for nCVirtual := 1 to Len(aCVirtual)
    cRStr := aCVirtual[nCVirtual][2]
    
    //POSICIONE("GD4",1,xFilial("GD4")+GCZ->GCZ_REGGER+GCZ->GCZ_CODPLA,"GD4_MATRIC")
    if     "POSICIONE(" $ cRStr
        nPStr := At("POSICIONE(", cRStr) + 10
        
        //U_IniPadr("GFV",1,GCZ->GCZ_CODPLA+GCZ->GCZ_SQCATP,"GFV_NOMCAT",,.F.)
    elseif "U_INIPADR(" $ cRStr
        nPStr := At("U_INIPADR(", cRStr) + 11
        
        //U_X3RELAC("GCM", 2, "GD4_CODPLA", "GCM_DESPLA")
    elseif "U_X3RELAC(" $ cRStr
        nPStr := At("U_X3RELAC(", cRStr) + 11
        
    endif
    
    // Pega o Alias
    cRStr := SubStr(cRStr, nPStr + 1)
    cAOri := SubStr(cRStr, 1, (nPStr := At(",", cRStr)) - 2)
    
    // Pega o Indice
    cRStr := SubStr(cRStr, nPStr + 1)
    cNOrd := U_CInd(Val(SubStr(cRStr, 1, (nPStr := At(",", cRStr)) - 1)))
    
    // Posiciona no dicionแrio de indices para pegar a chave de pesquisa e retirar o campo filial
    SIX->(DbSeek(cAOri + cNOrd))
    cIChv := StrTran(AllTrim(Upper(SIX->CHAVE)), " ", "")
    cIChv := SubStr(cIChv, At("+", cIChv) + 1)
    
    // Pega a chave para pesquisa
    if "U_X3RELAC(" $ aCVirtual[nCVirtual][2]
        cRStr := SubStr(cRStr, nPStr + 2)
    else
        cRStr := SubStr(cRStr, nPStr + 1)
    endif
    // Retira a fun็ใo xFilial()
    if "POSICIONE(" $ aCVirtual[nCVirtual][2]
        cRStr := SubStr(cRStr, At("+", cRStr) + 1)
    endif
    if "U_X3RELAC(" $ aCVirtual[nCVirtual][2]
        cPChv := SubStr(cRStr, 1, (nPStr := At(",", cRStr)) - 2)
    else
        cPChv := SubStr(cRStr, 1, (nPStr := At(",", cRStr)) - 1)
    endif
    
    cPChv := StrTran(cPChv, '"', "'")
    
    // Pega o campo que serแ retornado na query
    cRStr := SubStr(cRStr, nPStr + 2)
    cRCpo := SubStr(cRStr, 1, At('"', cRStr) - 1)
    
    // Acerta a chave do indice para montar a condi็ใo do join
    cIChv := cAOri + aCVirtual[nCVirtual][3] + "." + StrTran(cIChv, "+", " || " + cAOri + aCVirtual[nCVirtual][3] + ".")
    
    // Acerta a chave de pesquisa para montar a condi็ใo do join
    cPChv := StrTran(cPChv, cADes + "->", "")
    cPChv := StrTran(cPChv,        "M->", "")
    cPChv := cADes + "." + StrTran(cPChv, "+", " || " + cADes + ".")
    cPChv := StrTran(cPChv, cADes + ".'", "'")
    
    if (nIChv := U_CntChr(cIChv, "|")) <> (nPChv := U_CntChr(cPChv, "|"))
        //ConOut("Indice   [" + cIChv + "]")
        //ConOut("Pesquisa [" + cPChv + "]")
        
        nIChv := 1
        nPChv := ((nPChv + 2) / 2)
        
        cRStr := cIChv
        cIChv := ""
        while nIChv <= nPChv
            cIChv += IIf(!Empty(cIChv), " || ", "") + SubStr(cRStr, 1, At("||", cRStr)-2)
            nIChv++
            cRStr := SubStr(cRStr, At("||", cRStr)+3)
        end
        //ConOut("Indice   [" + cIChv + "]")
    endif
    
    lArqExclus := !Empty(xFilial(cAOri))
    
    cCond := Iif(lFilial .or. (lCpoFilial .and. lArqExclus),; 
                 cAOri + aCVirtual[nCVirtual][3] + "." + PrefixoCpo(cAOri) + "_FILIAL = " +; 
                     IIf(lCpoFilial .and. !lFilial, cCpoFilial, "'" + xFilial(cAOri) + "'") + " and ", +;
                 "") + ;
             Iif(cAOri == "SRA", cAOri + aCVirtual[nCVirtual][3] + ".RA_CODIGO <> '" + Space(TamSx3("RA_CODIGO")[1]) + "' and ", "") + ;
             cAOri + aCVirtual[nCVirtual][3] + ".D_E_L_E_T_ <> '*' and " + ;
             cIChv + " = " + cPChv
    
    if aScan(aArqCond, {| aVet | Upper(aVet[4]) == Upper(aCVirtual[nCVirtual][1])}) == 0 .and. aScan(aArqCond, {| aVet | Right(Upper(aVet[1]), Len(cAOri + aCVirtual[nCVirtual][3])) == Upper(cAOri + aCVirtual[nCVirtual][3])}) == 0
        AAdd(aArqCond, {" left join " + RetSqlName(cAOri) + " " + cAOri + aCVirtual[nCVirtual][3], cAOri + aCVirtual[nCVirtual][3] + "." + cRCpo, cCond, aCVirtual[nCVirtual][1]})
    endif
next

return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ Sx3Defs  บAutor  ณ Andr้ Cruz         บ Data ณ  09/16/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna as Defini็๕es do campo com base no conte๚do do SX3 บฑฑ
ฑฑบ          ณ Utilizada pela BDados                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function Sx3Defs(lBmpCpo, cNomCpo, nTamCpo, cRelaca, cTitulo, aCposVis, aCposAlt, cPictur)
local aRetSx3 := {}
local cX3_CBox := IIf(SubStr(SX3->X3_CBOX, 1, 1) == "#", &(AllTrim(SubStr(SX3->X3_CBOX, 2))), SX3->X3_CBOX)
//local cAlias := ""

default cRelaca  := ""
default cPictur  := "@BMP"
default aCposVis := {}
default aCposAlt := {}

if "RECNO" == cNomCpo
    aRetSx3 := {;
        "RecNo",; //X3_TITULO
        "RECNO",; //X3_CAMPO
        "@E 999999999999",; //X3_PICTURE
        12,; //X3_TAMANHO
        0,; //X3_DECIMAL
        "",; //X3_VALID  
        "",; //X3_USADO  
        "N",; //X3_TIPO   
        "",; //X3_F3     
        "V",; //X3_CONTEXT
        "",; //X3_CBOX       
        "",; //X3_RELACAO
        "",; //X3_WHEN
        "V",; //X3_VISUAL
        "",; //X3_VLDUSER
        "",; //X3_PICTVAR
        ""; //// X3Obrigat(SX3->X3_CAMPO))
    }
elseif "ALIAS" == cNomCpo
    aRetSx3 := {;
        "Alias",; //X3_TITULO
        "ALIAS",; //X3_CAMPO
        "@!",; //X3_PICTURE
        3,; //X3_TAMANHO
        0,; //X3_DECIMAL
        "",; //X3_VALID  
        "",; //X3_USADO  
        "C",; //X3_TIPO   
        "",; //X3_F3     
        "V",; //X3_CONTEXT
        "",; //X3_CBOX       
        "",; //X3_RELACAO
        "",; //X3_WHEN
        "V",; //X3_VISUAL
        "",; //X3_VLDUSER
        "",; //X3_PICTVAR
        ""; // X3Obrigat(SX3->X3_CAMPO))
    }
elseif lBmpCpo
    aRetSx3 := {;
        " ",; //X3_TITULO
        cNomCpo,; //X3_CAMPO
        cPictur,; //X3_PICTURE
        nTamCpo,; //X3_TAMANHO
        0,; //X3_DECIMAL
        .F.,; //X3_VALID  
        "",; //X3_USADO 
        "C",; //X3_TIPO 
        "",; //X3_F3
        "V",; //X3_CONTEXT
        "",; //X3_CBOX 
        cRelaca,; //X3_RELACAO
        "",; //X3_WHEN
        "V",; //X3_VISUAL
        "",; //X3_VLDUSER
        "",; //X3_PICTVAR
        "",; // X3Obrigat(SX3->X3_CAMPO))
    }
else
    aRetSx3 := {;
        TRIM(Iif(!Empty(cTitulo), cTitulo, X3Titulo())),;
        Iif(!Empty(cNomCpo), cNomCpo, SX3->X3_CAMPO),;
        SX3->X3_PICTURE,;
        SX3->X3_TAMANHO,;
        SX3->X3_DECIMAL,;
        SX3->X3_VALID,;
        SX3->X3_USADO,;
        SX3->X3_TIPO,;
        SX3->X3_F3,;
        SX3->X3_CONTEXT,;
        cX3_CBox,;
        Iif(!Empty(cRelaca), cRelaca, SX3->X3_RELACAO),;
        SX3->X3_WHEN,;
        SX3->X3_VISUAL,;
        SX3->X3_VLDUSER,;
        SX3->X3_PICTVAR,;
        X3Obrigat(SX3->X3_CAMPO);
    }
endif

if aScan(aCposVis, cNomCpo) > 0
    aRetSx3[14] := "V"
elseif aScan(aCposAlt, cNomCpo) > 0
    aRetSx3[14] := "A"
endif

return aRetSx3



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RPadrao  บAutor  ณ Andr้ Cruz         บ Data ณ  09/16/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna dados para a aCols.                                บฑฑ
ฑฑบ          ณ Utilizada pela BDados                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function RPadrao(cAlias, aCampo, aArqCond)

local cRPadrao := "", nPosRet := 0

if "TMP" $ cAlias
    if aArqCond # nil .and. (nPosRet := aScan(aArqCond, {| aVet | aVet[4] == aCampo[2]})) > 0 .and. Type(cAlias + "->" + aArqCond[nPosRet, 4]) <> "U"
        cRPadrao := &(cAlias + "->" + aArqCond[nPosRet, 4])
    else
        if !Empty(aCampo[12])
            cRPadrao := &(StrTran(aCampo[12], SubStr(cAlias, 4, Len(cAlias) - 3) + "->", cAlias + "->"))
        else
            cRPadrao := Iif(aCampo[8] == "N", 0, Iif(aCampo[8] == "D", CToD(""), Space(aCampo[4])))
        endif
    endif
elseif !Empty(aCampo[12])
    cRPadrao := &(aCampo[12])
else
    cRPadrao := Iif(aCampo[8] == "N", 0, Iif(aCampo[8] == "D", CToD(""), Space(aCampo[4])))
endif

return cRPadrao

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ LegBD    บAutor  ณ Andr้ Cruz         บ Data ณ  09/16/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o conte๚do de legenda para MSNewGetDados           บฑฑ
ฑฑบ          ณ Utilizada pela BDados                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function LegBD(aLeg,cCond)

local nLeg := 0, cCorLeg := "BR_CINZA"
if cCond <> nil
    for nLeg := 1 to Len(aLeg)
        if &(aLeg[nLeg, 1])
            cCorLeg := aLeg[nLeg, 2]
        endif
    next
endif

return cCorLeg

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ SavArea  บAutor  ณ Andr้ Cruz         บ Data ณ  09/16/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Salva vแria แreas, passadas pela matriz aArea              บฑฑ
ฑฑบ          ณ Utilizada pela BDados                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user function SavArea(aArea)
local nArea := 1
for nArea := 1 to Len(aArea)
    aArea[nArea, 2] := &(aArea[nArea, 1] + "->(IndexOrd())")
    aArea[nArea, 3] := &(aArea[nArea, 1] + "->(RecNo())")
next
return aArea

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ResArea  บAutor  ณ Andr้ Cruz         บ Data ณ  09/16/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Restaura vแria แreas, passadas pela matriz aArea           บฑฑ
ฑฑบ          ณ Utilizada pela BDados                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user function ResArea(aArea)
local nArea := 1
for nArea := 1 to Len(aArea)
    &(aArea[nArea, 1] + "->(DbSetOrder(" + AllTrim(Str(aArea[nArea, 2])) + "))")
    &(aArea[nArea, 1] + "->(DbGoTo(" + AllTrim(Str(aArea[nArea, 3])) + "))")
next
return nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ExisDic  บAutor  ณ Andr้ Cruz         บ Data ณ  09/16/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica a existencia dos dados no dicionario de dados e reบฑฑ
ฑฑบ          ณ torna qual atualizador deve ser aplicado para a rotina.    บฑฑ
ฑฑบ          ณ Utilizada pela BDados                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user function ExisDic(aCampos, lMsg)

local aArea      := GetArea()
local nFor       := 0
local nForCpo    := 0
local aCpos      := {}
local cMsgCDic   := ""
local cMsgTDic   := ""
local cMsgIDic   := ""
local cMsgCBco   := ""
local cMsgTBco   := ""
local cMsgIBco   := ""
local cMsgBops   := ""
local lRet       := .T.
local cBops      := ""

private cPrefixo := ""
private cCampo   := ""

default lMsg     := .T.

for nFor := 1 to Len(aCampos)
    
    cPrefixo := PADL(SubStr(aCampos[nFor, 2], 1, aT("_",aCampos[nFor, 2])-1), 3, "S")
    cCampo   := aCampos[nFor, 2]
    cBops    := IIf(len(aCampos[nFor]) == 3,aCampos[nFor,3],"") // Pega o Bops se existir ou em branco se for sistema antigo
    
    if aCampos[nFor, 1] == "T"
        DbSelectArea("SX2")
        DbSetOrder(1) //X2_CHAVE
        if !DbSeek(cCampo) //verifica exist๊ncia da tabela no dicionแrio de dados
            AAdd(aCpos, {"T", cCampo, 1,cBops})
        endif
    elseif aCampos[nFor, 1] == "C"
        DbSelectArea("SX3")
        DbSetOrder(2) // X3_CAMPO
        if !DbSeek(cCampo) //verifica exist๊ncia do campo no dicionแrio de dados
            AAdd(aCpos, {"C", cCampo, 1, cBops})
        elseif &(cPrefixo + "->(FieldPos(cCampo))") == 0 .and. SX3->X3_CONTEXT <> "V"//verifica exist๊ncia do campo no banco de dados
            AAdd(aCpos, {"C", cCampo, 2, cBops})
        endif
    elseif aCampos[nFor, 1] == "I"
        DbSelectArea("SIX")
        DbSetOrder(1) //INDICE+ORDEM
        if !DbSeek(cPrefixo + U_CInd(aCampos[nFor, 3])) //verifica exist๊ncia do ํndice no dicionแrio de dados
            AAdd(aCpos, {"I", RetSqlName(cPrefixo) + U_CIND(aCampos[nFor, 3]), 1, cBops})
        elseif !(TCCANOPEN(RetSqlName(cPrefixo), RetSqlName(cPrefixo) + U_CIND(aCampos[nFor, 3])))//verifica exist๊ncia do ํndice no banco de dados
            AAdd(aCpos, {"I", RetSqlName(cPrefixo) + U_CIND(aCampos[nFor, 3]), 2, cBops})
        endif
    endif
next

aSort(aCampos,,, {|x, y| x[1] < y[1]})

if !(lRet := Empty(aCpos)) .and. lMsg
    for nForCpo := 1 to Len(aCpos)
        if aCpos[nForCpo, 1] == "C"
            if aCpos[nForCpo, 3] == 1 //verifica se o campo nใo foi encontrado no dicionแrio
                if !Empty(cMsgCDic)
                    cMsgCDic += ", "
                    cMsgCDic += aCpos[nForCpo, 2]
                else
                    cMsgCDic += aCpos[nForCpo, 2]
                endif
            elseif aCpos[nForCpo, 3] == 2 //verifica se o campo nใo foi encontrado no banco
                if !Empty(cMsgCBco)
                    cMsgCBco += ", "
                    cMsgCBco += aCpos[nForCpo, 2]
                else
                    cMsgCBco += aCpos[nForCpo, 2]
                endif
            endif
        elseif aCpos[nForCpo, 1] == "T"
            if aCpos[nForCpo, 3] == 1 //verifica se a tabela nใo foi encontrada no dicionแrio
                if !Empty(cMsgTDic)
                    cMsgTDic += ", "
                    cMsgTDic += aCpos[nForCpo, 2]
                else
                    cMsgTDic += aCpos[nForCpo, 2]
                endif
            elseif aCpos[nForCpo, 3] == 2 //verifica se a tabela nใo foi encontrada no banco
                if !Empty(cMsgTBco)
                    cMsgTBco += ", "
                    cMsgTBco += aCpos[nForCpo, 2]
                else
                    cMsgTBco := aCpos[nForCpo, 2]
                endif
            endif
        elseif aCpos[nForCpo, 1] == "I"
            if aCpos[nForCpo, 3] == 1 //verifica se o ํndice nใo foi encontrado no dicionแrio
                if !Empty(cMsgIDic)
                    cMsgIDic += ", "
                    cMsgIDic += aCpos[nForCpo, 2]
                else
                    cMsgIDic += aCpos[nForCpo, 2]
                endif
            elseif aCpos[nForCpo, 3] == 2 //verifica se o ํndice nใo foi encontrado no banco
                if !Empty(cMsgIBco)
                    cMsgIBco += ", "
                    cMsgIBco += aCpos[nForCpo, 2]
                else
                    cMsgIBco += aCpos[nForCpo, 2]
                endif
            endif
        endif
        
        // Guarda mensagens informando o BOPS
        if !Empty(cMsgBops)
            if at(aCpos[nForCpo, 4], cMsgBops) == 0
                cMsgBops += ", "
                cMsgBops += aCpos[nForCpo, 4]
            Endif
        else
            cMsgBops = aCpos[nForCpo, 4]
        endif
    next
    
    
    if len(aCampos[1]) == 3 // Se for no sitema novo informa o bops a ser executado
        if cMsgBops <> ""
            U_MsgInf("Por favor, para a atualiza็ใo desta rotina, execute o(s) atualizador(es):" + cMsgBops + ".", "Aten็ใo", "Valida็ใo de Dicionแrios")
        Endif
    else // Sistema antigo
        if aScan(aCpos, {| aVet | aVet[1] == "T"}) <> 0
            if cMsgTDic <> ""
                U_MsgInf("Por favor, para executar esta rotina, verifique a exist๊ncia da(s) tabela(s) " + cMsgTDic + " no dicionแrio de dados.", "Aten็ใo", "Valida็ใo de Dicionแrios")
            elseif cMsgTBco <> ""
                U_MsgInf("Por favor, para executar esta rotina, verifique a exist๊ncia da(s) tabela(s) " + cMsgTBco + " no banco de dados.", "Aten็ใo", "Valida็ใo de Bancos")
            endif
        elseif aScan(aCpos, {| aVet | aVet[1] == "C"}) <> 0
            if cMsgCDic <> ""
                U_MsgInf("Por favor, para executar esta rotina, verifique a exist๊ncia do(s) campo(s) " + cMsgCDic + " no dicionแrio de dados.", "Aten็ใo", "Valida็ใo de Dicionแrios")
            elseif cMsgCBco <> ""
                U_MsgInf("Por favor, para executar esta rotina, verifique a exist๊ncia do(s) campo(s) " + cMsgCBco + " no banco de dados.", "Aten็ใo", "Valida็ใo de Bancos")
            endif
        elseif aScan(aCpos, {| aVet | aVet[1] == "I"}) <> 0
            if cMsgIDic <> ""
                U_MsgInf("Por favor, para executar esta rotina, verifique a exist๊ncia do(s) ํndice(s) " + cMsgIDic + " no dicionแrio de dados.", "Aten็ใo", "Valida็ใo de Dicionแrios")
            elseif cMsgIBco <> ""
                U_MsgInf("Por favor, para executar esta rotina, verifique a exist๊ncia do(s) ํndice(s) " + cMsgIBco + " no banco de dados.", "Aten็ใo", "Valida็ใo de Bancos")
            endif
        endif
    Endif
    
endif

RestArea(aArea)

return lRet

user function X3RELAC(cAlias, nOrdem, cCpoChv, cCpoRet)
local cCodChave := IIf(Inclui, "", IIf("TMP" $ Alias(), &(cCpoChv), ""))
local cDescri   := ""
if !EMPTY(cCodChave)
    cDescri := U_INIPADR(cAlias, nOrdem, cCodChave, cCpoRet,, .F.)
endif
return cDescri

user function IniPadr(cAlias, nOrdem, cChave, cCampo, lSoftSeek, lInclui, cChvURel, cFilAlias)
//cChvURel: se veio preenchido, a rotina deve retornar conteudo somente se ha somente 1 registro para esta chave

local cRet := "", cAliasOld := Alias()
local cChvPesq := ""
local cChvComp := ""
local cInic    := ""
local aAreaSX3 := U_SavArea({{"SX3", 0, 0}})

default lSoftSeek := .F.
default lInclui   := .T.
default cFilAlias := ""

cChvPesq := Iif(!Empty(cFilAlias) .and. !Empty(xFilial(cAlias)), cFilAlias, xFilial(cAlias)) + cChave

if !Empty(cChvURel)
    cChvComp := cAlias + "->" + PrefixoCpo(cAlias) + "_FILIAL + " + cAlias + "->" + cChvURel
Endif

if cCampo <> nil .and. !Empty(cCampo)
    SX3->(DbSetOrder(2))
    SX3->(DbSeek(cCampo))
    cInic := IIf(SX3->X3_TIPO == "D", CToD(" "), IIf(SX3->X3_TIPO == "N", 0, SPACE(SX3->X3_TAMANHO)))
    cRet  := cInic
endif

if !Empty(cChave) .and. IIf(lInclui .and. Type("Inclui") <> "U", !Inclui, .T.)
    IIf((cAlias)->(IndexOrd()) == nOrdem, .T., (cAlias)->(DbSetOrder(nOrdem)))
    if (cAlias)->(DbSeek(cChvPesq, lSoftSeek)) .and. cCampo <> nil .and. !Empty(cCampo)
        cRet := (cAlias)->(FieldGet(FieldPos(cCampo)))
        if !Empty(cChvURel)
            (cAlias)->(DbSkip())
            cRet := IIf((cAlias)->(Eof()) .or. &(cChvComp) <> cChvPesq, cRet, cInic)
        Endif
    endif
endif

U_ResArea(aAreaSX3)
if !Empty(cAliasOld)
    DbSelectArea(cAliasOld)
Endif
return cRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MsgInf   บAutor  ณ Andr้ Cruz         บ Data ณ  09/16/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Explode uma mensagem de alerta na tela.                    บฑฑ
ฑฑบ          ณ Utilizada pela BDados                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

user function MsgInf(cMsgErro, cTitulo, cRotina)
local oTexto, oDlgMsg, oBtnSave, oBtnOk 
local cReadVar := Iif(Type("__ReadVar") <> "U".and. !Empty(__ReadVar), __ReadVar, "") //Guarda o conteudo do ReadVar porque o SetFocus limpa essa variavel

default cRotina := FunName()

DEFINE MSDIALOG oDlgMsg FROM    62,100 TO 320,510 TITLE OemToAnsi(cTitulo) PIXEL

@ 003, 004 TO 027, 200 LABEL "Help" OF oDlgMsg PIXEL //
@ 030, 004 TO 110, 200 OF oDlgMsg PIXEL

@ 010, 008 MSGET OemToAnsi(cRotina) WHEN .F. SIZE 188, 010 OF oDlgMsg PIXEL

@ 036, 008 GET oTexto VAR OemToAnsi(cMsgErro) MEMO READONLY /*NO VSCROLL*/ SIZE 188, 070 OF oDlgMsg PIXEL

oBtnSave := TButton():New(115, 100, "Salvar", oDlgMsg, {|| cFile := cGetFile( '*.txt' , 'Salvar Log', 1, 'C:\', .T., nOR( GETF_LOCALHARD, GETF_RETDIRECTORY, GETF_NETWORKDRIVE ),.T., .T. ), Iif( cFile == '', .T., MemoWrite( cFile, cMsgErro ) ) },,,,,,.T.)
oBtnOk   := TButton():New(115, 170, "Ok", oDlgMsg, {|| oDlgMsg:End()},,,,,,.T.)
oBtnOk:SetFocus()

ACTIVATE MSDIALOG oDlgMsg CENTERED

if !Empty(cReadVar)
    __ReadVar := cReadVar
endif

return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MsgInf   บAutor  ณ Andr้ Cruz         บ Data ณ  09/16/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna o c๓digo do ํndice que ้ utilizado na SIX.         บฑฑ
ฑฑบ          ณ Utilizada pela BDados                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user function CInd(nInd)
local cInd := " "
local cIndOrd := "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"

cInd := SubStr(cIndOrd, nInd, 1)
return cInd

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MsgInf   บAutor  ณ Andr้ Cruz         บ Data ณ  09/16/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Conta a quantidade de um determinado caracter na string    บฑฑ
ฑฑบ          ณ passada pelo parametro cString.                            บฑฑ
ฑฑบ          ณ Utilizada pela BDados                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user function CntChr(cString, cChr)
local nChr := 0, nCnt := 0
for nChr := 0 to Len(cString)
    if SubStr(cString, nChr, 1) == cChr
        nCnt++
    endif
next
return nCnt

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GrvCpo   บAutor  ณ Andr้ Cruz         บ Data ณ  09/16/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava autmoaticamente os registros que sใo apresentados    บฑฑ
ฑฑบ          ณ na tela.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user function GrvCpo(cAliasGrv,aColsGrv,aHeaderGrv, nLin )
local bCampo3   := { |nCPO| FieldName(nCPO) }
local cCpo      := ""
local cSavAlias := Alias()
local cCampoGrv := ""
local cPrefix   := Iif( SubStr(cAliasGrv, 1, 1) == 'S', SubStr(cAliasGrv, 2, 2), cAliasGrv )
local nLen, i

    DbSelectArea("SX3")
    DbSetOrder(2) // X3_CAMPO 
        
    DbSelectArea(cAliasGrv)
    
    if aColsGrv == nil  
        nLen := FCount()      
        for i := 1 to nLen 
            cCpo := Eval(bCampo3, i)
            if SX3->(DbSeek(cCpo)) .and. SX3->X3_CONTEXT != "V" .and. Type("M->"+(cCpo)) != "U"
                &(cCpo) := M->&(cCpo)
            endif
        next
        &(Alltrim(cAliasGrv)+"->"+cPrefix+"_FILIAL")  := xFilial(cAliasGrv)
        
        aMemos := U_AMemos(cAliasGrv)
        
        if Type("aMemos") == "A" .and. Len(aMemos) > 0 .and. Upper(SubStr(aMemos[1, 1], 1, At("_", aMemos[1, 1]) - 1)) == Upper(cAliasGrv)
            nLen := Len(aMemos)
            for i := 1 to nLen
                cCampoGrv := aMemos[i, 2]
                DbSelectArea("SX3")
                DbSetOrder(2)
                DbSeek(cCampoGrv)
                DbSelectArea(cAliasGrv)
                if SX3->X3_TIPO == "M" .and. SX3->X3_CONTEXT == "V" .and. Type("M->" + cCampoGrv) <> "U"
                    _SetNamedPrvt("M->" + cCampoGrv, "", Iif(IsInCallStack( FunName() ), FunName(), "U_" + FunName()))
                    MSMM(, TamSx3(cCampoGrv)[1],, &("M->" + cCampoGrv), 1,,, cAliasGrv, aMemos[i, 1])
                endif
            next
        endif
    else
        nLen := Len(aHeaderGrv)
        for i := 1 to nLen
            if SX3->(DbSeek(aHeaderGrv[i,2])) .and. SX3->X3_CONTEXT != "V"
                if aHeaderGrv[i,8] == "N" .and. aHeaderGrv[i,8] <> ValType(aColsGrv[nLin,i])
                    &(aHeaderGrv[i,2]) := Val(aColsGrv[nLin,i])
                else
                    &(aHeaderGrv[i,2]) := aColsGrv[nLin,i]
                endif
            endif
        next
    endif
    
    DbSelectArea(cSavAlias)
return nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AMemos   บAutor  ณ Andr้ Cruz         บ Data ณ  09/16/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Trata o conte๚do de campos Memo Virtuais e Reais.          บฑฑ
ฑฑบ          ณ Utilizada pela GrvCpo                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user function AMemos(cAliasSx3)
local aMemos := {}
local cAliasOld := Alias()
local nOrderSx3, nRecSx3, nCodObsF

    DbSelectArea("SX3")
    nOrderSx3 := IndexOrd()
    DbSetOrder(1)
    nRecSx3 := RecNo()
    DbSeek(cAliasSx3)

    while !Eof() .and. SX3->X3_ARQUIVO == cAliasSx3

        if SX3->X3_CONTEXT == "V" .and. SX3->X3_TIPO == "M"

            if (nCodObs := At(cAliasSx3 + "_", SX3->X3_RELACAO)) > 0

                nCodObsF := At(",", SX3->X3_RELACAO)
                if nCodObsF == 0
                    nCodObsF := At(")", SX3->X3_RELACAO)
                endif
                nCodObsF := nCodObsF - (nCodObs - 1) - 1
                AAdd(aMemos, {Upper(AllTrim(SubStr(SX3->X3_RELACAO, nCodObs, nCodObsF))), AllTrim(SX3->X3_CAMPO)})

            endIf

        endif
        DbSkip()

    end

    DbGoTo(nRecSx3)
    DbSetOrder(nOrderSx3)
    DbSelectArea(cAliasOld)
return(aMemos)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ  NextSeq      ณ Autor ณ Andr้ Cruz       ณ Data ณ 20100910 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ  Encontra a proxima sequencia para um c๓digo numa tabela   ณฑฑ
ฑฑณ          ณ  qualquer.                                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ  AP                                                        ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user function NextSeq( cFld, cSeqBase, nLen, cFiltro )
local aArea     := GetArea()
local cSeq      := ""
local cPref     := SubStr(cFld, 1, At("_", cFld)-1)
local cTbl      := Iif(At("_", cFld) == 3, "S", "") + cPref
local cDataBase := TCGetDb()

default cSeqBase := ""
default nLen     := TamSX3(cFld)[1]

    cSql := " SELECT MAX(" + cFld + ") SEQ " 
    cSql += "   FROM " + RetSqlName(cTbl) + " "
    cSql += "  WHERE D_E_L_E_T_ = ' ' " 
    cSql += "    AND " + cPref + "_FILIAL = '" + xFilial(cTbl) + "' "

    if !Empty(cSeqBase)
        if "ORACLE" $ cDataBase 
            cSql += "    AND SUBSTR( " + cFld + ", 1, " + Str(Len(AllTrim(cSeqBase))) + " ) = '" + cSeqBase + "' "
        elseif "MSSQL" $ cDataBase
            cSql += "    AND SUBSTRING( " + cFld + ", 1, " + Str(Len(AllTrim(cSeqBase))) + " ) = '" + cSeqBase + "' "
        else
             Final("A fun็ใo 'U_NextSeq' nใo foi implementada para o banco de dados " + cDataBase + ". Entre em contato com o Administrador. " + CRLF + CRLF + "O Protheus serแ finalizado.")
        endif
    endif
    
    if !Empty(cFiltro)
        cSql += "    AND ( " + cFiltro + " ) "
    endif

    DbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "NXTSEQ", .T., .F. )

    cSeq := SubStr(NXTSEQ->SEQ, Len(cSeqBase)+1, nLen)

    NXTSEQ->(DbCloseArea())

    cSeq :=  cSeqBase + Iif( Empty(cSeq), StrZero( 1, nLen ), Soma1( cSeq ) )

RestArea(aArea)
return cSeq

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AMemos   บAutor  ณ Andr้ Cruz         บ Data ณ  09/16/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrega as rela็๕es de Join a partir do dicionario de dadosบฑฑ
ฑฑบ          ณ Utilizada pela Fun็ใo BDados.                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
static function IsJoin(cX3Relacao)
 local lRet     := .F.
 local cX3Alias := ""
 
 cX3Relacao := StrTran(Upper(cX3Relacao), " ", "")
 
 if     "POSICIONE("  $ StrTran(Upper(SX3->X3_RELACAO), " ", "")
  lRet := .T.
  cX3Alias := SubStr(cX3Relacao, At("POSICIONE(", cX3Relacao) + 11, 3)
  
 elseif "U_INIPADR(" $ StrTran(Upper(SX3->X3_RELACAO), " ", "")
  lRet := .T.
  cX3Alias := SubStr(cX3Relacao, At("U_INIPADR(", cX3Relacao) + 12, 3)
  
 elseif "U_X3RELAC(" $ StrTran(Upper(SX3->X3_RELACAO), " ", "")
  lRet := .T.
  cX3Alias := SubStr(cX3Relacao, At("U_X3RELAC(", cX3Relacao) + 12, 3)
  
 endif
            
 // Caso a origem seja um dicionแrio nใo faz o join
 if lRet .and. cX3Alias <> "SX5" .and. (SubStr(cX3Alias, 1, 2) == "SX" .or. cX3Alias == "SIX")
  lRet := .F.
 endif 
 
return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณValProc   บAutor  ณandre cruz          บ Data ณ  07/10/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se uma fun็ใo pertence เ pilha de chamadas        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

user function ValProc(cFuncao)
local lRet       := .F.
local i          := 0

while !(lRet := Upper(cFuncao) $ Upper(ProcName(i))) .and. !Empty(Alltrim(ProcName(i)))
   i++
end

return lRet 

/* 
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ RunFunc      ณ Autor ณ Andr้ Cruz       ณ Data ณ 20100208 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Executa uma fun็ใo                                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ cFunc   Fun็ใo a ser executada com seus parโmetros        ณฑฑ
ฑฑณ          ณ                                                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ Generica                                                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user function RunFunc( cFunc, cCodEmp, cCodFil, nType, cTbl )
private aItens := {}
private lMsg   := .F.

default nType := 3

if cTbl == nil
    if Select("SM0") == 0 
        // dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .T., .F. )
        // dbSetIndex("SIGAMAT.IND")
        OpenSm0( cCodEmp+cCodFil, .F.)

        DbSelectArea("SM0")
        DbSetorder(1)
        
        cCodEmp := Iif( cCodEmp == nil, Space( Len( SM0->M0_CODIGO ) ), cCodEmp )
        cCodFil := Iif( cCodFil == nil, Space( Len( SM0->M0_CODFIL ) ), cCodFil )
        if !Empty( cCodEmp ) .or. !Empty( cCodFil )
           SM0->(DbSeek(cCodEmp+cCodFil))
        endif        
        
    endif
    
    RpcSetType(nType)
    RpcSetEnv(SM0->M0_CODIGO,SM0->M0_CODFIL)
    &(cFunc)
    RpcClearEnv()
else
    axCadastro(cTbl)
endif

return nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PosSX1   บAutor  ณ Andr้ Cruz         บ Data ณ  10/18/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Altara o conte๚do padrใo de um campo de pergunta no SX1.   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

user function PosSX1(aChave)
local aArea      := GetArea()
local nLenChave  := Len(aChave)
local nForChave  := 0
local nForSX1
local cP_Defs    := ""
local cP_DefsTmp := ""
local nPFLin     := 0
local lProfAlias := Select("PROFALIAS") > 0
local nPosGrupo  := 1
local nPosOrdem  := 2
local nPosCont   := 3

for nForChave := 1 to nLenChave

    if aChave[nForChave][nPosCont] == nil 
        aChave[nForChave][nPosCont] := Space(SX1->X1_TAMANHO)
    endif

    if lProfAlias
        DBSelectArea("PROFALIAS")
        DbSetOrder(1)
        if      DbSeek(PadR(AllTrim(cUserName)            , Len(PROFALIAS->P_NAME)) + ;
                       PadR(aChave[nForChave][nPosGrupo]  , Len(PROFALIAS->P_PROG)) + ;
                       PadR("PERGUNTE"                    , Len(PROFALIAS->P_TASK)) + ;
                       PadR("MV_PAR"                      , Len(PROFALIAS->P_TYPE))) ;
           .or. DbSeek(PadR(cFilAnt+AllTrim(cUserName)    , Len(PROFALIAS->P_NAME)) + ;
                       PadR(aChave[nForChave][nPosGrupo]  , Len(PROFALIAS->P_PROG)) + ;
                       PadR("PERGUNTE"                    , Len(PROFALIAS->P_TASK)) + ;
                       PadR("MV_PAR"                      , Len(PROFALIAS->P_TYPE)))                  

            cP_DefsTmp := PROFALIAS->P_DEFS
            nForSX1 := 0
            while !Empty(cP_DefsTmp)
                nPFLin := At(CRLF, cP_DefsTmp)

                if  nForSx1 == Val(aChave[nForChave][nPosOrdem])
                    cP_Defs += SubStr(cP_DefsTmp, 1, 4) + cValToChar(aChave[nForChave][nPosCont]) + CRLF
                else 
                    cP_Defs += SubStr(cP_DefsTmp, 1, nPFLin + 1)
                endif 
                
                cP_DefsTmp := SubStr(cP_DefsTmp, nPFLin + 2)
                nForSx1 := nForSx1 + 1
            end

            RecLock("PROFALIAS", .F.)
            PROFALIAS->P_DEFS := cP_Defs
            MsUnLock() 
        else 
            PosSx1(PADR(aChave[nForChave][nPosGrupo], Len(SX1->X1_GRUPO))+aChave[nForChave][nPosOrdem], aChave[nForChave][nPosCont])
        endif
    else                             
        PosSx1(PADR(aChave[nForChave][nPosGrupo], Len(SX1->X1_GRUPO))+aChave[nForChave][nPosOrdem], aChave[nForChave][nPosCont])
    endif
next nForChave

RestArea(aArea)
return nil


static function PosSx1(cChave, xConteudo)
local nForSx1 := 0

default xConteudo := ""

DbSelectArea("SX1")
DbSetOrder(1) // X1_GRUPO + X1_ORDEM           
if DbSeek(cChave)    
    if Type("xConteudo") == "A"
        for nForSx1 := 1 to Len(xConteudo)
            RecLock("SX1", .F.)
            &(xConteudo[nForSx1][1]) := cValToChar(xConteudo[nForSx1][2])
            MsUnLock()
        next
    else
        RecLock("SX1", .F.)
        SX1->X1_CNT01 := cValToChar(xConteudo)
        MsUnLock()
    endif
endif
return nil


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ AToS     บAutor  ณ Andr้ Cruz         บ Data ณ  10/18/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Converte uma matriz numa string.                           บฑฑ
ฑฑบ          ณ Pode ser usado para simula็ใo de serializa็ใo no protheus  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
user function AToS(aArray)

local cArray    := ""
local nLenArray := Len(aArray)
local i

if ValType(aArray) == 'A'
    
    cArray += '{ '
    
    for i := 1 to nLenArray
        if ValType(aArray[i]) == 'U'
            cArray += 'nil'
        elseif ValType(aArray[i]) == 'C'
            if At( '"', aArray[i] ) > 0
                cArray += "'" + aArray[i] + "'"
            else
                cArray += '"' + aArray[i] + '"'
            endif
            
        elseif ValType(aArray[i]) == 'N'
            cArray +=  AllTrim(Str(aArray[i]))
        elseif ValType(aArray[i]) == 'D'
            cArray +=  'CToD("' + DToC(aArray[i]) + '")'
        elseif ValType(aArray[i]) == 'L'
            cArray +=  Iif(aArray[i],'.T.', '.F.')
        elseif ValType(aArray[i]) == 'A'
            cArray +=  U_AToS(aArray[i])
        endif
        if i != nLenArray
            cArray += ', '
        endif
    next
    
    cArray += ' }'
endif

return cArray

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ DuplAC     ณ Autor ณ Andr้ Cruz            ณ Data ณ11.07.2005ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณVerifica ocorrencia de duplicidade no ACols, atraves de aScan ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณExpL1: Linha OK                                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณExpN1: Posicao da linha na aCols                              ณฑฑ
ฑฑณ          ณExpA2: Array contendo os dados a serem pesquisados            ณฑฑ
ฑฑณ          ณExpA3: Array contendo as posi็๕es dos campos que comporao a   ณฑฑ
ฑฑณ          ณ       chave de pesquisa                                      ณฑฑ
ฑฑณ          ณExpL4: Identifica se a funcao exibira ou nao as mensagens de  ณฑฑ
ฑฑณ          ณ       erro, caso haja.                                       ณฑฑ
ฑฑณ          ณExpL5: Identifica se os registros deletados serใo             ณฑฑ
ฑฑณ          ณ       desconsiderados na valida็ใo de registros duplicados.  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  
user function DuplAC(nLinPesq, aCPesq, aPosicoes, lMsg, lDel)
local lRet  := .T.
local nPos  := 0
local cCond := ""

default lMsg := .T. // Identifica se a funcao exibira ou nao as mensagens de erro, caso haja.
default lDel := .F. // Identifica se os registros deletados serใo desconsiderados na valida็ใo de registros duplicados.

for nPos := 1 to len(aPosicoes)
    cCond += IIf(nPos == 1, "", " .and. ")
    cCond += "aVet[" + Alltrim(Str(aPosicoes[nPos])) + "] == aCPesq[" + AllTrim(Str(nLinPesq)) + ", " + AllTrim(Str(aPosicoes[nPos])) + "]"
next nPos

if lDel .and. !Empty(cCond)
 cCond += " .and. aVet[" + Alltrim(Str(len(aCPesq[1]))) + "] == .F."
endif 

nPos := 0
nPos := FS_AScan(aCPesq, cCond, @nPos)
if nPos <> nLinPesq
    lRet := .F.
elseif nPos <> len(aCPesq)
    nPos := FS_AScan(aCPesq, cCond, @nPos)
    if nPos <> 0
        lRet := .F.
    Endif
Endif

if !lRet .and. lMsg
    U_MsgInf("Verificar ocorr๋ncia de duplicidade", "Atencao", "Duplicidade") 
Endif

return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ FS_AScan   ณ Autor ณ Andr้ Cruz            ณ Data ณ11.07.2005ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณVerifica ocorrencia de duplicidade no ACols, atraves de aScan ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณExpN1: Posicao em que a chave se repete                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณExpA1: Array contendo os dados a serem pesquisados            ณฑฑ
ฑฑณ          ณExpC2: Condicao de busca                                      ณฑฑ
ฑฑณ          ณExpN3: Posicao inicial da busca                               ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  
static function FS_AScan(aCPesq, cCond, nPos)
 private cBusca := "{| aVet |" + cCond + "}"
 nPos := aScan(aCPesq, &cBusca, nPos+1 )
return nPos

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ FS_AScan   ณ Autor ณ Andr้ Cruz            ณ Data ณ11.07.2005ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณVerifica ocorrencia de duplicidade no ACols, atraves de aScan ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณExpN1: Posicao em que a chave se repete                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณExpA1: Array contendo os dados a serem pesquisados            ณฑฑ
ฑฑณ          ณExpC2: Condicao de busca                                      ณฑฑ
ฑฑณ          ณExpN3: Posicao inicial da busca                               ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  
user function VldObrig(cTbl, aMat, aCols, cRot, lShowLog)
local aArea      := GetArea()
local lRet       := .T.
local nLen       := 0
local i          := 0, j          := 0 
local aFld       := {}

   lShowLog := Iif(lShowLog = nil, .F., lShowLog)
   cRot     := Iif(cRot = nil, .F., cRot)

   DbSelectArea("SX3")
   DbSetOrder(2) // X3_CAMPO

   if !Empty(aMat)

      for i := 1 to nLen
         SX3->(DbSeek(aMat[i][1]))
         if X3Obrigat(SX3->X3_CAMPO) .and. Empty(aMat[i][1])
            AAdd(aFld, SX3->X3_TITULO)
         endif
      next

   endif

   if lRet .and. !Empty(aCols)
      for i := 1 to nLen
         nLen2 := Len(aCols)
         for j := 1 to nLen2
            SX3->(DbSeek(aCols[i][j][1]))
            if X3Obrigat(SX3->X3_CAMPO) .and. Empty(aMat[i][1])
               AAdd(aFld, SX3->X3_TITULO)
            endif
         next
      next
   endif

   if !Empty(aFld)
      if lShowLog
         cMsg := "Os campos listado abaixo sใo obrigat๓rios e nใo foram preenchidos pela rotina automแtica. Por favor, entre em contato com o TI."
         nLen := Len(aFld)
         for i := 0 to nLen
            cMsg += CRLF + aFld[i]
         next
         MsgAlert(cMsg, "Problema na rotina automatica " + cRot + ".")
      endif
      lRet := .F.
   endif


if !Empty(aArea)
   RestArea(aArea)
endif
return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ FilObrig   ณ Autor ณ Andr้ Cruz            ณ Data ณ11.07.2005ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณVerifica se existem campos obrigat๓rios que nใo foram preenchiณฑฑ
ฑฑณ          ณdos e adiciona-os ao execauto com a op็ใo .f.                 ณฑฑ 
ฑฑณ          ณ                                                              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ Nenhum                                                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณExpA1: Tabela                                                 ณฑฑ
ฑฑณ          ณExpC2: Matriz para o execauto                                 ณฑฑ
ฑฑณ          ณExpN3: 1.Enchoice, 2.aCols                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/  

/*/{Protheus.doc} u_FilObrig
Verifica se existem campos obrigat๓rios que nใo foram preenchidos e adiciona-os ao execauto com a op็ใo .f. 

/*/
user function FilObrig(cTbl, aMat, nTipo)
local aArea     := GetArea()
local i         := 0
local nLen      := 0
local nPosFld   := 0

   DbSelectArea("SX3")
   DbSetOrder(1)
   DbSeek(cTbl)
   
   if nTipo == 1
      while !SX3->(Eof()) .and. SX3->X3_ARQUIVO == cTbl
         if X3Obrigat(SX3->X3_CAMPO)
            if ( nPosFld := aScan(aMat, { |aMat| PadR(aMat[1], Len(SX3->X3_CAMPO)) == SX3->X3_CAMPO } ) ) > 0
               if Empty(aMat[nPosFld][2])
                  aMat[nPosFld][3] := .F. 
               endif
            else
               AAdd(aMat, {SX3->X3_CAMPO, CriaVar(SX3->X3_CAMPO,.F.), .F.})
            endif
         endif
         SX3->(DbSkip())
      end
   elseif nTipo == 2
      nLen := Len(aMat)
      for i := 1 to nLen
         while !SX3->(Eof()) .and. SX3->X3_ARQUIVO == cTbl
            if X3Obrigat(SX3->X3_CAMPO)
               if ( nPosFld := aScan(aMat[i], { |aMat| PadR(aMat[1], Len(SX3->X3_CAMPO)) == SX3->X3_CAMPO } ) ) > 0
                  if Empty(aMat[nPosFld][2])
                     aMat[i][nPosFld][3] := .F. 
                  endif
               else
                  AAdd(aMat[i], {SX3->X3_CAMPO, CriaVar(SX3->X3_CAMPO,.F.), .F.})
               endif
            endif
            SX3->(DbSkip())
         end
      next
   endif

if !Empty(aArea)
   RestArea(aArea)
endif
return aMat

/*/{Protheus.doc} u_MkExcWB
/*/
user function MkExcWB( aItens, lGauge, cFileName )
local cCreate   := AllTrim( Str( Year( dDataBase ) ) ) + "-" + AllTrim( Str( Month( dDataBase ) ) ) + "-" + AllTrim( Str( Day( dDataBase ) ) ) + "T" + SubStr( Time(), 1, 2 ) + ":" + SubStr( Time(), 4, 2 ) + ":" + SubStr( Time(), 7, 2 ) + "Z" // string de data no formato <Ano>-<Mes>-<Dia>T<Hora>:<Minuto>:<Segundo>Z
local i, j
local cWorkBook := ""

default cFileName := CriaTrab(,.F.)+".xml"

default lGauge := .F.

if !( nHandle := FCreate( cFileName, FC_NORMAL ) ) != -1
    MsgAlert("Nใo foi possivel criar a planilha [" + cFileName + "]. Por favor, verifique se existe espa็o em disco ou voc๊ possui pemissใo de escrita no diret๓rio \system\", "Erro de cria็ใo de arquivo")
    return nil
endif

cWorkBook := "<?xml version=" + Chr(34) + "1.0" + Chr(34) + "?>" + CRLF
cWorkBook += "<?mso-application progid=" + Chr(34) + "Excel.Sheet" + Chr(34) + "?>" + CRLF
cWorkBook += "<Workbook xmlns=" + Chr(34) + "urn:schemas-microsoft-com:office:spreadsheet" + Chr(34) + " " + CRLF
cWorkBook += "    xmlns:o=" + Chr(34) + "urn:schemas-microsoft-com:office:office" + Chr(34) + " " + CRLF
cWorkBook += "    xmlns:x=" + Chr(34) + "urn:schemas-microsoft-com:office:excel" + Chr(34) + " " + CRLF
cWorkBook += "    xmlns:ss=" + Chr(34) + "urn:schemas-microsoft-com:office:spreadsheet" + Chr(34) + " " + CRLF
cWorkBook += "    xmlns:html=" + Chr(34) + "http://www.w3.org/TR/REC-html40" + Chr(34) + ">" + CRLF
cWorkBook += "    <DocumentProperties xmlns=" + Chr(34) + "urn:schemas-microsoft-com:office:office" + Chr(34) + ">" + CRLF
cWorkBook += "        <Author>" + AllTrim(SubStr(cUsuario,7,15)) + "</Author>" + CRLF
cWorkBook += "        <LastAuthor>" + AllTrim(SubStr(cUsuario,7,15)) + "</LastAuthor>" + CRLF
cWorkBook += "        <Created>" + cCreate + "</Created>" + CRLF
cWorkBook += "        <Company>Microsiga Intelligence</Company>" + CRLF
cWorkBook += "        <Version>11.6568</Version>" + CRLF
cWorkBook += "    </DocumentProperties>" + CRLF
cWorkBook += "    <ExcelWorkbook xmlns=" + Chr(34) + "urn:schemas-microsoft-com:office:excel" + Chr(34) + ">" + CRLF
cWorkBook += "        <WindowHeight>9345</WindowHeight>" + CRLF
cWorkBook += "        <WindowWidth>11340</WindowWidth>" + CRLF
cWorkBook += "        <WindowTopX>480</WindowTopX>" + CRLF
cWorkBook += "        <WindowTopY>60</WindowTopY>" + CRLF
cWorkBook += "        <ProtectStructure>False</ProtectStructure>" + CRLF
cWorkBook += "        <ProtectWindows>False</ProtectWindows>" + CRLF
cWorkBook += "    </ExcelWorkbook>" + CRLF
cWorkBook += "    <Styles>" + CRLF
cWorkBook += "        <Style ss:ID=" + Chr(34) + "Default" + Chr(34) + " ss:Name=" + Chr(34) + "Normal" + Chr(34) + ">" + CRLF
cWorkBook += "            <Alignment ss:Vertical=" + Chr(34) + "Bottom" + Chr(34) + "/>" + CRLF
cWorkBook += "            <Borders/>" + CRLF
cWorkBook += "            <Font/>" + CRLF
cWorkBook += "            <Interior/>" + CRLF
cWorkBook += "            <NumberFormat/>" + CRLF
cWorkBook += "            <Protection/>" + CRLF
cWorkBook += "        </Style>" + CRLF
cWorkBook += "    <Style ss:ID=" + Chr(34) + "s21" + Chr(34) + ">" + CRLF
cWorkBook += "        <NumberFormat ss:Format=" + Chr(34) + "Short Date" + Chr(34) + "/>" + CRLF
cWorkBook += "    </Style>" + CRLF
cWorkBook += "    </Styles>" + CRLF

cWorkBook += "    <Worksheet ss:Name=" + Chr(34) + cFileName + Chr(34) + ">" + CRLF
cWorkBook += "        <Table>" + CRLF

FWrite(nHandle, cWorkBook)
cWorkBook := ""

nQtdLine := Len(aItens)
if lGauge
   ProcRegua(nQtdLine)
endif

for i := 1 to nQtdLine
   cWorkBook += "            <Row>" + CRLF
   nLenLine := Len(aItens[i])
   for j := 1 to nLenLine
      cWorkBook += "                " + GetCell(aItens[i][j]) + CRLF
   next
   cWorkBook += "            </Row>" + CRLF
   FWrite(nHandle, cWorkBook)
   cWorkBook := ""
   IncProc("Gerando Planilha...") 
next
    
cWorkBook += "        </Table>" + CRLF
cWorkBook += "        <WorksheetOptions xmlns=" + Chr(34) + "urn:schemas-microsoft-com:office:excel" + Chr(34) + ">" + CRLF
cWorkBook += "            <PageSetup>" + CRLF
cWorkBook += "                <Header x:Margin=" + Chr(34) + "0.49212598499999999" + Chr(34) + "/>" + CRLF
cWorkBook += "                <Footer x:Margin=" + Chr(34) + "0.49212598499999999" + Chr(34) + "/>" + CRLF
cWorkBook += "                <PageMargins x:Bottom=" + Chr(34) + "0.984251969" + Chr(34) + " x:Left=" + Chr(34) + "0.78740157499999996" + Chr(34) + " x:Right=" + Chr(34) + "0.78740157499999996" + Chr(34) + " x:Top=" + Chr(34) + "0.984251969" + Chr(34) + "/>" + CRLF
cWorkBook += "            </PageSetup>" + CRLF
cWorkBook += "            <Selected/>" + CRLF
cWorkBook += "            <ProtectObjects>False</ProtectObjects>" + CRLF
cWorkBook += "            <ProtectScenarios>False</ProtectScenarios>" + CRLF
cWorkBook += "        </WorksheetOptions>" + CRLF
cWorkBook += "    </Worksheet>" + CRLF
FWrite(nHandle, cWorkBook)
cWorkBook := ""
cWorkBook += "</Workbook>" + CRLF

FWrite(nHandle, cWorkBook)
cWorkBook := ""
FClose(nHandle)

return cFileName

/*/{Protheus.doc} GetCell
/*/
static function GetCell( xVar )
local cRet  := ""
local cType := ValType(xVar)

if cType == "U"
    cRet := "<Cell><Data ss:Type=" + Chr(34) + "General" + Chr(34) + "></Data></Cell>"
elseif cType == "C"
    cRet := "<Cell><Data ss:Type=" + Chr(34) + "String" + Chr(34) + ">" + Format( xVar ) + "</Data></Cell>"
elseif cType == "N"
    cRet := "<Cell><Data ss:Type=" + Chr(34) + "Number" + Chr(34) + ">" + AllTrim( Str( xVar ) ) + "</Data></Cell>"
elseif cType == "D"
    xVar := DToS( xVar )
    cRet := "<Cell ss:StyleID=" + Chr(34) + "s21" + Chr(34) + ">" + Iif(Empty(xVar),"", "<Data ss:Type=" + Chr(34) + "DateTime" + Chr(34) + ">" + SubStr(xVar, 1, 4) + "-" + SubStr(xVar, 5, 2) + "-" + SubStr(xVar, 7, 2) + "T00:00:00.000</Data>" ) + "</Cell>"
else
    cRet := "<Cell><Data ss:Type=" + Chr(34) + "Boolean" + Chr(34) + ">" + Iif ( xVar , "=VERDADEIRO" ,  "=FALSO" ) + "</Data></Cell>"
endif

return cRet

/*/{Protheus.doc} Format
/*/
static function Format( cVar )
local nLen := 0
local i    := 0
local aPad := { { 'ใ', 'a' }, { 'แ' , 'a' }, { 'โ', 'a' }, { 'ไ', 'a' }, ;
                { 'ร', 'A' }, { 'ม' , 'A' }, { 'ย', 'A' }, { 'ฤ', 'A' }, ;
                { '้', 'e' }, { '๊' , 'e' }, { '๋', 'e' }, ;
                { 'ษ', 'E' }, { 'ส' , 'E' }, { 'ห', 'E' }, ;
                { 'ํ', 'i' }, { '๎' , 'i' }, { '๏', 'i' }, ; 
                { '๕', 'o' }, { '๓' , 'o' }, { '๔', 'o' }, { '๖', 'o' },;
                { 'ี', 'O' }, { 'ำ' , 'O' }, { 'ิ', 'O' }, { 'ึ', 'O' },;
                { '๚', 'u' }, { '๛' , 'u' }, { 'ü', 'u' }, ;
                { 'ฺ', 'U' }, { 'Û' , 'U' }, { 'Ü', 'U' }, ;
                { '็', 'c' }, ;
                { 'ว', 'C' }, ;
                { '&', '' } }
                
nLen := Len(aPad)
for i := 1 to nLen
   cVar := StrTran(cVar, aPad[i][1], aPad[i][2])
next
return AllTrim(cVar)


/*/{Protheus.doc} u_ToChar
/*/
user function ToChar(xVal)
    
local cVal

if ValType(xVal) == 'D'
    cVal := DToS(xVal)
elseif ValType(xVal) == 'N'
    cVal := AllTrim(Str((xVal)))
elseif ValType(xVal) $ 'CM'
    cVal := StrTran(xVal, "'", "&#39;")
else
    cVal := 'Null'
endif
    
return cVal

static aPerg := {}

/*/{Protheus.doc} u_SavePerg
/*/
user function SavePerg()
local i := 1

aPerg := {}

while Type('MV_PAR' + StrZero(i,2)) <> 'U'
   AAdd(aPerg, &('MV_PAR' + StrZero(i,2))) 
   i++
end

return nil

/*/{Protheus.doc} u_RestPerg
/*/
user function RestPerg()
local i := 0
local nLen := Len(aPerg)

for i := 1 to nLen
    &('MV_PAR' + StrZero(i,2)) := aPerg[i]
next

return nil

/*/{Protheus.doc} u_InSql
/*/
user function InSql(cInSql, cCharSep, nLenCpo)
local cInRet := ""
local i := 0
local nLen := Len(cInSql)

default nLenCpo := 1
default cCharSep := "|"

if At(cCharSep, cInSql) == 0
   for i := 1 to nLen step nLenCpo
      cInRet += Iif(Empty(cInRet), "", ", ") + "'" + SubStr(cInSql, i, nLenCpo) + "'"
   next
else
   cInRet := "'" + StrTran(cInSql, cCharSep, "', '") + "'"
endif

return cInRet

/*/{Protheus.doc} u_HrAdd
/*/
user function HrAdd(xHr1, xHr2)

if ValType(xHr1) == 'C'
    xHr1 := u_Hr2Dec(xHr1)
endif

if ValType(xHr2) == 'C'
    xHr2 := u_Hr2Dec(xHr2)
endif

return u_Dec2Hr(xHr1 + xHr2)

/*/{Protheus.doc} u_HrSub
/*/
user function HrSub(xHr1, xHr2)
if ValType(xHr1) == 'C'
    xHr1 := u_Hr2Dec(xHr1)
endif

if ValType(xHr2) == 'C'
    xHr2 := u_Hr2Dec(xHr2)
endif

return Iif(xHr1-xHr2 >= 0, u_Dec2Hr(xHr1 - xHr2), "  :  ")

/*/{Protheus.doc} u_MinAdd
/*/
user function MinAdd(xHr1, xMin)
local xHr2 := u_Hr2Dec(u_Min2Hr(xMin))

if ValType(xHr1) == 'C'
    xHr1 := u_Hr2Dec(xHr1)
endif

return u_Dec2Hr(xHr1 + xHr2)

/*/{Protheus.doc} u_MinSub
/*/
user function MinSub(xHrIni, xMin)
local xHr2 := u_Hr2Dec(u_Min2Hr(xMin))

if ValType(xHr1) == 'C'
    xHr1 := u_Hr2Dec(xHr1)
endif

return u_Dec2Hr(xHr1 - xHr2)

/*/{Protheus.doc} u_VldHr
/*/
user function VldHr(cHora, lShowErr)
local lRet := .t.
local cHrVal := ""
local cMinVal := ""
local cChar := ""
local lHora := .t.
local nLen, i 

nLen := Len(cHora)
for i := 1 to nLen
    if (cChar := SubStr(cHora, i, 1)) == ":"
        lHora := .f.
    elseif lHora
        if cChar > '9' .or. cChar < '0'
            if lShowErr
                ShowHelpDlg("VLDHR01", {"Existem caracteres invแlidos para dados do tipo hora."}, 1, {"Por favor, verifique as horas."}, 1)
            endif
            lRet := .f.
            exit
        endif
        cHrVal += cChar
    else
        if Len(cMinVal) = 0 .and. cChar > '5' .or. cChar < '0'
            if lShowErr
                ShowHelpDlg("VLDHR02", {"Existem caracteres invแlidos para dados do tipo hora."}, 1, {"Por favor, verifique os minutos."}, 1)
            endif
            lRet := .f.
            exit
        elseif Len(cMinVal) = 1 .and. cChar > '9' .or. cChar < '0'
            if lShowErr
                ShowHelpDlg("VLDHR03", {"Existem caracteres invแlidos para dados do tipo hora."}, 1, {"Por favor, verifique os minutos."}, 1)
            endif
            lRet := .f.
            exit
        elseif Len(cMinVal) > 1
            if lShowErr
                ShowHelpDlg("VLDHR03", {"Comprimento dos minutos ้ muito grande."}, 1, {"Por favor, verifique os minutos."}, 1)
            endif
            lRet := .f.
            exit
        endif
        cMinVal += cChar 
    endif
next 

return lRet

/*/{Protheus.doc} u_VldHr
/*/
user function VldHrDia(cHora, lShowErr)
local lRet       := .t.
local cEstado    := 'A'
local cChar      := ""
local i
nLen := Len(cHora)
for i := 1 to nLen
    cChar := SubStr(cHora, i, 1)
    if cEstado == 'A'
        if cChar >= '0' .and. cChar <= '1'
            cEstado := 'B'
        elseif cChar == '2'
            cEstado := 'C'
        else
            cEstado := 'H'
        endif
    elseif cEstado == 'B'
        if cChar >= '0' .and. cChar <= '9'
            cEstado := 'D'
        else
            cEstado := 'H'
        endif
    elseif cEstado == 'C'
        if cChar >= '0' .and. cChar <= '4'
            cEstado := 'D'
        else
            cEstado := 'H'
        endif
    elseif cEstado == 'D'
        if cChar == ':'
            cEstado := 'E'
        else
            cEstado := 'H'
        endif
    elseif cEstado == 'E'
        if cChar >= '0' .and. cChar <= '5'
            cEstado := 'F'
        else
            cEstado := 'H'
        endif
    elseif cEstado == 'F'
        if cChar >= '0' .and. cChar <= '9'
            cEstado := 'G'
        else
            cEstado := 'H'
        endif
    elseif cEstado == 'G'
        cEstado := 'H'
        exit
    elseif cEstado == 'H'
        exit
    endif
next

if cEstado <> 'G'
    if lShowErr
        ShowHelpDlg("VLDHRDIA01", {"Existem caracteres invแlidos para dados do tipo hora."}, 1, {"Por favor, verifique..."}, 1)
    endif
    lRet := .f.
endif

return lRet


/*/{Protheus.doc} u_Hr2Dec
/*/
user function Hr2Dec(cHora)
local xHora := ""
local xMin := ""
local i, nLen
local lHora := .t.

nLen := Len(cHora)
for i := 1 to nLen
    if SubStr(cHora, i, 1) == ':'
        if lHora
            lHora := .f.
        else // ignora o que vem depois dos minutos
            exit
        endif
    elseif lHora
        xHora += SubStr(cHora, i, 1)
    else
        xMin += SubStr(cHora, i, 1)
    endif
next

xHora := Val(xHora)
if (xMin  := Val(xMin)) > 59 // nใo ้ formato sexagenal
    UserException("Formato dos minutos invแlido.")
else
    xMin := Round(xMin/60, 6)
endif

return xHora + xMin

/*/{Protheus.doc} u_Dec2Hr
/*/
user function Dec2Hr(nHora)
local cHora := ""
local cMin := ""

if Len(cHora := AllTrim(Str(Int(nHora)))) == 1
    cHora := '0' + cHora
endif

if Len(cMin := AllTrim(Str(Round((nHora - int(nHora))*60, 0)))) == 1
    cMin := '0' + cMin
endif

return cHora + ":" + cMin

/*/{Protheus.doc} u_Min2Hr
/*/
user function Min2Hr(xMin)
local cHora := ""
local cMin  := ""

if ValType(xMin) == 'C'
    xMin := Val(xMin)
endif

cHora := AllTrim(Str(Int(xMin/60)))
if Len(cHora) == 1
    cHora := "0" + cHora 
endif

cMin := StrZero(xMin%60, 2)

return cHora + ":" + cMin


user function Normaliz(cString)
local cRet := ""
local cCurChar := ""
local i, nLen

cString := AllTrim(Upper(cString))

nLen := Len(cString)
for i := 1 to nLen
    cCurChar := SubStr(cString, i, 1)
    cRet += Iif( (cCurChar >= '0' .and. cCurChar <= '9') .or. (cCurChar >= 'A' .and. cCurChar <= 'Z'), cCurChar, '_' )  
next

return cRet

/*/{Protheus.doc} EspNome
Adiciona o m๓dulo SIGAESP aos m๓dulos disponiveis no SIGAMDI.
/*/

/*user function EspNome() 
return( OemToAnsi( "Modulo de gerenciamento do BI SIGNA" ) ) 
*/

static __DEBUG__ := nil

user function ConOut(xMsg)
    if type("__DEBUG__") == 'U'
        __DEBUG__ := GetSrvProfString("JRDEBUG","0") == '1' 
    endif
    if __DEBUG__
        ConOut(xMsg)
    endif
return nil

user function isInteger(cVal)
local lRet := .f.
local nLen := 0
local i := 0

if cVal == nil .or. Type(cVal) <> 'C' .or. Empty(cVal)
    lRet := .f.
else
    nLen := Len(cVal)
    for i := 1 to nLen
        if SubStr(cVal, i, 1) < '0' .or. SubStr(cVal, i, 1) > '9' 
            lRet := .f.
            exit
        endif
    next
endif
return lRet

user function CriaDir(cPath)
local aDir := {}
local cDir := ""
local nLen, i

    aDir := StrToKArr(cPath, '\')

    nLen := Len(aDir)
    for i := 1 to nLen
        if At(':', aDir[i]) > 0
        	cDir := aDir[i]
        	Loop
        endif
        cDir += "\" + aDir[i]
        if !ExistDir(cDir)
        	MakeDir(cDir)
        endif
    next

return nil

user function TitleSX3(cCampo)
local aArea := GetArea()
local cRet := ""

DbSelectArea("SX3")
DbSetOrder(2) // X3_CAMPO

if DbSeek(cCampo)
    cRet := AllTrim(X3Titulo())
endif

if !Empty(aArea)
    RestArea(aArea)
endif
return cRet

user function BackupSX()
    u_RunFunc("u_BkpSX()")
return nil

user function BkpSX()
local aDic := {"SIX", "SX1", "SX2", "SX3", "SX6", "SX7", "SXA", "SXB", "SXG"}
local i, nLen

nLen := Len(aDic)
for i := 1 to nLen
    StartJob( "u_CopySX", GetEnvServer(), .f., aDic[i], cEmpAnt, cFilAnt )
next

return nil

user function CopySX(cDic, cCodEmp, cCodFil)
local aEstTRB := {}
local i, nLen
local lSetDeleted 

    if Select("SM0") == 0 
        dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .T., .F. )
        dbSetIndex("SIGAMAT.IND")
    
        DbSelectArea("SM0")
        DbSetorder(1)
        
        cCodEmp := Iif( cCodEmp == nil, Space( Len( SM0->M0_CODIGO ) ), cCodEmp )
        cCodFil := Iif( cCodFil == nil, Space( Len( SM0->M0_CODFIL ) ), cCodFil )
        if !Empty( cCodEmp ) .or. !Empty( cCodFil )
           SM0->(DbSeek(cCodEmp+cCodFil))
        endif        
        
    endif
    
    RpcSetType(3)
    RpcSetEnv(SM0->M0_CODIGO,SM0->M0_CODFIL)

    lSetDeleted := Set( _SET_DELETED, .f. )

    DbSelectArea(cDic)
    DbSetOrder(1) // 
    (cDic)->(DbGoTop())

    aEstTRB := (cDic)->(DBSTRUCT())
    nLen := Len(aEstTRB)
    
    if !ExistDir("\data\" + DToS(Date()))
        MakeDir("\data\" + DToS(Date()))
    endif
    
    if !File("\data\" + DToS(Date()) + "\" + cDic + cEmpAnt + "0.dtc")
        ConOut("[" + DToS(Date()) + "-" + Time() + "] Iniciando c๓pia de " + cDic + " em \data\" + DToS(Date()) + "\" + cDic + cEmpAnt + "0.dtc.")
        DbCreate("\data\" + DToS(Date()) + "\" + cDic + cEmpAnt + "0.dtc", aEstTRB, "CTREECDX")
        DbUseArea(.t., "CTREECDX", "\data\" + DToS(Date()) + "\" + cDic + cEmpAnt + "0.dtc", cDic + "1", .t., .f.)
        
        //(cDic)->(DbGoTop())
        while !(cDic)->(Eof())
            RecLock(cDic+"1", .t.)
                for i := 1 to nLen
                    (cDic+"1")->(FieldPut(i, (cDic)->(FieldGet(i))))
                next
            MsUnlock()
            if (cDic)->(Deleted())
                RecLock(cDic+"1", .f.)
                    (cDic+"1")->(DbDelete())
                MsUnlock()
            endif
            (cDic)->(DbSkip())
        end

        (cDic + "1")->(DbCloseArea())
        ConOut("[" + DToS(Date()) + "-" + Time() + "] O arquivo \data\" + DToS(Date()) + "\" + cDic + cEmpAnt + "0.dtc foi copiado do sucesso.")
    else
        ConOut("[" + DToS(Date()) + "-" + Time() + "] \data\" + DToS(Date()) + "\" + cDic + cEmpAnt + "0.dtc jแ existe. O arquivo nใo serแ substituido.")
    endif

    Set( _SET_DELETED, lSetDeleted )

    RpcClearEnv()

return nil

user function CopyDb()
local aArea := GetArea()
local cDbName := ""
local cRet := ""

DbUseArea(.t., "TOPCONN", TCGenQry(,,"select DB_NAME() as NAME"), "DBName", .f., .f.)
    cDbName := DBName->NAME
DBName->(DbCloseArea())

ConOut("[" + DToS(Date()) + "-" + Time() + "] Backup finalizado.")
if TCSqlExec(" backup database " + cDbName + " to DISK = 'c:\temp\" + cDbName + ".bak' with FORMAT, COMPRESSION ") <= 0
    ConOut("[" + DToS(Date()) + "-" + Time() + "] ocorreu um problema ao executar o backup de " + cDbName + ".")
else
    cRet := "c:\temp\" + cDbName + ".bak"
    ConOut("[" + DToS(Date()) + "-" + Time() + "] Backup finalizado com sucesso.")
endif

if !Empty(aArea)
    RestArea(aArea)
endif

return cRet

user function UpdTable(cTbl)
    X31UpdTable(cTbl)
    if __GetX31Error()
        MsgStop("Erro atualizando estrutra da tabela " + CRLF + __GetX31Trace(),"Atualiza็ใo da tabela " + cTbl)
    else
        MsgInfo("Atualiza็ใo da estrutra efetuada com sucesso.","Atualiza็ใo da tabela " + cTbl)
    endif
return nil

// USADO PELO TRYEXCEPTION.CH
User Function PutTryExceptionVars()
	Public aTryException	:= {}
	Public nTryException	:= 0
Return( NIL )

User Function CaptureError( lObjError , nStart , nFinish , nStep )
	Local cError		:= ''
	Local lTryException	:= ( ( Type( 'aTryException' ) == 'A' ) .and. ( Type( 'nTryException' ) == 'N' ) )
	Local nError
	IF ( lTryException )
		lObjError	:= IF( ( lObjError == NIL ) , .F. , lObjError )
		nStart 		:= IF( ( nStart == NIL ) , 1 , nStart )
		nFinish		:= IF( ( nFinish == NIL ) , Len( aTryException ) , nFinish )
		nStep		:= IF( ( nStep == NIL ) , 1 , nStep )
		For nError := nStart To nFinish Step nStep
			IF ( lObjError )
				IF ( ValType( aTryException[nError][TRY_OBJERROR] ) == 'O' )
					cError	+= aTryException[nError][TRY_OBJERROR]:Description
					cError	+= aTryException[nError][TRY_OBJERROR]:ErrorStack
					cError	+= aTryException[nError][TRY_OBJERROR]:ErrorEnv
				EndIF
			Else
				IF ( ValType( aTryException[nError][TRY_ERROR_MESSAGE] ) == 'C' )
					cError += aTryException[nError][TRY_ERROR_MESSAGE]
				EndIF
			EndIF	
		Next nError
	EndIF
Return( cError )

