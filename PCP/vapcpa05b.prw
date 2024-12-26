#include "Protheus.ch"
#include "RWMake.ch"
#include "TopConn.ch"
#include "ParmType.ch"
#include "FWMVCDef.ch"
#include "FWEditPanel.ch"

static nQtdUltTrt := GetMV("VA_TRTCNHG",,3)
static cPath      := "C:\totvs_relatorios\"
static lDebug     := ExistDir(cPath) .and. GetMV("VA_DBGTRTO",,.T.)

user function tstFWTemp()
local oTempTbl := nil
local aSeek := {}
local i, nLen
local aIndex := {}

private cAlias := CriaTrab(, .f.)   
private nNroTratos := u_GetNroTrato()
private aFields := {}
//private aBrowse := {}
private aColumns := {}
private cFldBrw := ""


CriaCpsBrw()
oTempTbl := CriaTemp()
FWMsgRun(, { || LoadTrat(dDataBase, oTempTbl:GetRealName()) }, "Carregamento do trato", "Carregando trato")


AAdd(aSeek,{"Curral",      {{"", TamSX3("Z08_CODIGO")[3], TamSX3("Z08_CODIGO")[1], TamSX3("Z08_CODIGO")[2], "Z08_CODIGO", "@!"}}, 1, .T. })
AAdd(aSeek,{"Lote",        {{"", TamSX3("B8_LOTECTL")[3], TamSX3("B8_LOTECTL")[1], TamSX3("B8_LOTECTL")[2], "B8_LOTECTL", "@!"}}, 2, .T. })
AAdd(aSeek,{"Rota",        {{"", TamSX3("Z0T_ROTA")[3],   TamSX3("Z0T_ROTA")[1],   TamSX3("Z0T_ROTA")[2],   "Z0T_ROTA",   "@!"}}, 3, .T. })
AAdd(aSeek,{"Equipamento", {{"", TamSX3("ZV0_DESC")[3],   TamSX3("ZV0_DESC")[1],   TamSX3("ZV0_DESC")[2],   "ZV0_DESC",   "@!"}}, 4, .T. })

AAdd(aIndex, "Z08_CODIGO")
AAdd(aIndex, "B8_LOTECTL")
AAdd(aIndex, "Z0T_ROTA")
AAdd(aIndex, "ZV0_DESC")

DbSelectArea(cAlias)
DbSetOrder(1)

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( cAlias )
//oBrowse:SetQueryIndex(aIndex)
oBrowse:SetTemporary(.T.)
oBrowse:SetDescription("Programacao do Trato - " + DToC(dDataBase)+ "")
//oBrowse:SetSeek(.T.,aSeek)
//oBrowse:SetMenuDef('vapcpa05b')
//oBrowse:SetUseFilter(.T.)
//oBrowse:SetUseCaseFilter(.F.)


//oBrowse:DisableDetails()

//oBrowse:AddLegend(cAlias+"->PROG_MS < " + cAlias + "->PROGANTMS", "RED",      "Diminuiu consumo")
//oBrowse:AddLegend(cAlias+"->PROG_MS = " + cAlias + "->PROGANTMS", "YELLOW",   "Mateve consumo")
//oBrowse:AddLegend(cAlias+"->PROG_MS > " + cAlias + "->PROGANTMS", "GREEN",    "Aumentou consumo")

//oBrowse:AddStatusColumns( { || BrwStatus() }, { || BrwLegend() } )
nLen := Len(aColumns)
for i := 1 to nLen
    oBrowse:SetColumns(aColumns[i])
next
oBrowse:Activate()

FechaTemp(oTempTbl)

return nil

static function CriaTemp()
local oTempTable := nil

    oTempTable := FWTemporaryTable():New( cAlias )
    oTempTable:SetFields( aFields )
    oTempTable:AddIndex(cAlias + "1", {"Z08_CODIGO"})
    oTempTable:AddIndex(cAlias + "2", {"B8_LOTECTL"})
    oTempTable:AddIndex(cAlias + "3", {"Z0T_ROTA"})
    oTempTable:AddIndex(cAlias + "4", {"ZV0_DESC"})

    oTempTable:Create()

return oTempTable

static function FechaTemp(oTempTable)

    if oTempTable != nil
        oTempTable:Delete()
        oTempTable := nil
    endif

return nil

static function CriaCpsBrw()
local i, nLen
local aFldBrw
local nTrato       := 0

    SX3->(DbSetOrder(2)) // X3_CAMPO
    //-----------------------------------------------------------------------------
    // PROGRAMACAO DE TRATO 
    //-----------------------------------------------------------------------------
    aFldBrw := { ;// "Z08_LINHA",;     // LINHA
                 "Z08_CODIGO",;    // COCHO
                 "Z0T_ROTA",;      // ROTA   
                 "B8_LOTECTL",;    // LOTE
                 "Z05_PESMAT",;    // PESO MED AUAL
                 "CMS_PV",;        // Consumo de materia seca por peso
                 "Z05_MEGCAL",;    // Mega Caloria (Energia)
                 "B8_SALDO",;      // SALDO  
                 "Z05_DIASDI",;    // DIA DA DIETA
                 "NOTA_NOITE",;    // NOTAS DE COCHO
                 "NOTA_MADRU",;    // NOTAS DE COCHO
                 "NOTA_MANHA",;    // NOTAS DE COCHO 
                 "PROGANTMS",;     // PROGRAMACAO ANTERIOR - KG de MS / Cabeca       
                 "PROG_MS",;       // PROGRAMACAO DE TRATO - KG de MS / Cabeca
                 "NR_TRATOS",;     // Qtde Tratos
                 "PROGANTMN",;     // PROGRAMACAO ANTERIOR - KG de MS / Cabeca       
                 "PROG_MN",;       // PROGRAMACAO DE TRATO - KG de MN / Cabeca
                 "Z05_MNTOT",;     // QUANTIDADE TOTAL DE MN
                 "QTDTRATO" }      // QUANTIDADE DE TRATOS REPETIDOS NOS ULTIMOS N DIAS

    for i := 1 to nNroTratos
        AAdd(aFldBrw, "Z06_DIETA" + StrZero(i, 1)) 
        AAdd(aFldBrw, "Z06_KGMS" + StrZero(i, 1)) // Z06_KGMSTR
        AAdd(aFldBrw, "Z06_KGMN" + StrZero(i, 1)) // Z06_KGMNT
    next

    AAdd(aFldBrw, "Z0S_EQUIP") 
    AAdd(aFldBrw, "ZV0_DESC") // Z06_KGMSTR

    nLen := Len(aFldBrw)
    for i := 1 to nLen
        if "LEGEND" $ aFldBrw[i]
            AAdd(aFields, {aFldBrw[i], "C", 10, 0})
            // AAdd(aBrowse, {"CMS/PV", aFldBrw[i], "C", 10, 0, ""})
            // MontaColunas(cCampo,cTitulo,cTipo,cPicture,nSize,nDecimal)
            MontaColunas(aFldBrw[i], "CMS/PV", aFields[Len(aFields)][2], "", aFields[Len(aFields)][3], aFields[Len(aFields)][4])
            // AAdd(aFieFilter, {aFldBrw[i], "CMS/PV", "C", 10, 0, ""})
        elseif "PROGANTMS" $ aFldBrw[i]
            SX3->(DbSeek("Z06_KGMSTR"))
            AAdd(aFields, {aFldBrw[i], SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
            // AAdd(aBrowse, {"Progr MS Ant", aFldBrw[i], SX3->X3_TIPO, 1, 0, SX3->X3_PICTURE})
            MontaColunas(aFldBrw[i], "Progr MS Ant", aFields[Len(aFields)][2], SX3->X3_PICTURE, aFields[Len(aFields)][3], aFields[Len(aFields)][4])
            // AAdd(aFieFilter, {aFldBrw[i], "Progr MS Ant   ", SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE})
        elseif "PROGANTMN" $ aFldBrw[i]
            SX3->(DbSeek("Z06_KGMSTR"))
            AAdd(aFields, {aFldBrw[i], SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
            // AAdd(aBrowse, {"Progr MN Ant", aFldBrw[i], SX3->X3_TIPO, 1, 0, SX3->X3_PICTURE})
            MontaColunas(aFldBrw[i], "Progr MN Ant", aFields[Len(aFields)][2], SX3->X3_PICTURE, aFields[Len(aFields)][3], aFields[Len(aFields)][4])
            // AAdd(aFieFilter, {aFldBrw[i], "Progr MN Ant", SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE})
        elseif "PROG_MS" $ aFldBrw[i]
            SX3->(DbSeek("Z06_KGMSTR"))
            AAdd(aFields, {aFldBrw[i], SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
            // AAdd(aBrowse, {"Progr MS Dia", aFldBrw[i], SX3->X3_TIPO, 1, 0, SX3->X3_PICTURE})
            MontaColunas(aFldBrw[i], "Progr MS Dia", aFields[Len(aFields)][2], SX3->X3_PICTURE, aFields[Len(aFields)][3], aFields[Len(aFields)][4])
            // AAdd(aFieFilter, {aFldBrw[i], "Progr MS Dia", SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE})
        elseif "PROG_MN" $ aFldBrw[i]
            SX3->(DbSeek("Z06_KGMSTR"))
            AAdd(aFields, {aFldBrw[i], SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
            // AAdd(aBrowse, {"Progr MN Dia", aFldBrw[i], SX3->X3_TIPO, 1, 0, SX3->X3_PICTURE})
            MontaColunas(aFldBrw[i], "Progr MN Dia", aFields[Len(aFields)][2], SX3->X3_PICTURE, aFields[Len(aFields)][3], aFields[Len(aFields)][4])
            // AAdd(aFieFilter, {aFldBrw[i], "Progr MN Dia", SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE})
        elseif "NR_TRATOS" $ aFldBrw[i]
            SX3->(DbSeek("Z06_TRATO"))
            AAdd(aFields, {aFldBrw[i], "N", 1, 0})
            // AAdd(aBrowse, {"Nro Tratos", aFldBrw[i], "N", 1, 0, "@E 9"})
            MontaColunas(aFldBrw[i], "Nro Tratos", aFields[Len(aFields)][2], "@E 9", aFields[Len(aFields)][3], aFields[Len(aFields)][4])
            // AAdd(aFieFilter, {aFldBrw[i], "Nro Tratos", "N", 1, 0, "@E 9"})
        elseif "CMS_PV" $ aFldBrw[i]
            AAdd(aFields, {aFldBrw[i], "N", 9, 3})
            //AAdd(aBrowse, {"CMS/PV", aFldBrw[i], "N", 9, 3, "@E 99,999.999"})
            MontaColunas(aFldBrw[i], "CMS/PV", aFields[Len(aFields)][2], "@E 99,999.999", aFields[Len(aFields)][3], aFields[Len(aFields)][4])
            // AAdd(aFieFilter, {aFldBrw[i], "CMS/PV", "N", 9, 3, "@E 99,999.999"})
        elseif "Z05_MEGCAL" $ aFldBrw[i]
            AAdd(aFields, {aFldBrw[i], "N", 6, 2})
            // AAdd(aBrowse, {"Mega Caloria", aFldBrw[i], "N", 6, 2, "@E 999.99"})
            MontaColunas(aFldBrw[i], "Mega Caloria", aFields[Len(aFields)][2], "@E 999.99", aFields[Len(aFields)][3], aFields[Len(aFields)][4])
            // AAdd(aFieFilter, {aFldBrw[i], "CMS/PV", "N", 9, 3, "@E 99,999.999"})
        elseif "Z06_DIETA" $ aFldBrw[i] 
            SX3->(DbSeek("Z06_DIETA"))
            AAdd(aFields, {aFldBrw[i], SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
            // AAdd(aBrowse, {AllTrim(X3Titulo()) + " " + AllTrim(Str(++nTrato)), aFldBrw[i], SX3->X3_TIPO, 10, 0, SX3->X3_PICTURE})
            MontaColunas(aFldBrw[i], AllTrim(X3Titulo()) + " " + AllTrim(Str(++nTrato)), aFields[Len(aFields)][2], SX3->X3_PICTURE, aFields[Len(aFields)][3], aFields[Len(aFields)][4])
            // AAdd(aFieFilter, {aFldBrw[i], AllTrim(X3Titulo()) + " " + AllTrim(Str(nTrato)) , SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE})
        elseif "Z06_KGMS" $ aFldBrw[i]
            SX3->(DbSeek("Z06_KGMSTR"))
            AAdd(aFields, {aFldBrw[i], SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
            // AAdd(aBrowse, {AllTrim(X3Titulo())  + " " + AllTrim(Str(nTrato)), aFldBrw[i], SX3->X3_TIPO, 1, 0, SX3->X3_PICTURE})
            MontaColunas(aFldBrw[i], AllTrim(X3Titulo())  + " " + AllTrim(Str(nTrato)), aFields[Len(aFields)][2], SX3->X3_PICTURE, aFields[Len(aFields)][3], aFields[Len(aFields)][4])
            // AAdd(aFieFilter, {aFldBrw[i], AllTrim(X3Titulo()) + " " + AllTrim(Str(nTrato)), SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE})
        elseif "Z06_KGMN" $ aFldBrw[i]
            SX3->(DbSeek("Z06_KGMNTR"))
            AAdd(aFields,{aFldBrw[i], SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
            // AAdd(aBrowse, {AllTrim(X3Titulo()) + " " + AllTrim(Str(nTrato)), aFldBrw[i], SX3->X3_TIPO, 1, 0, SX3->X3_PICTURE})
            MontaColunas(aFldBrw[i], AllTrim(X3Titulo()) + " " + AllTrim(Str(nTrato)), aFields[Len(aFields)][2], SX3->X3_PICTURE, aFields[Len(aFields)][3], aFields[Len(aFields)][4])
            // AAdd(aFieFilter, {aFldBrw[i], AllTrim(X3Titulo()) + " " + AllTrim(Str(nTrato)), SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE})
        elseif "Z05_MNTOT" $ aFldBrw[i]
            // AAdd(aFields, {aFldBrw[i], "N", 7, 1})
            AAdd(aFields, {aFldBrw[i], "N", TamSX3('Z05_TOTMNI')[1], TamSX3('Z05_TOTMNI')[2] })
            // AAdd(aBrowse, {"MN Total", aFldBrw[i], "N", 6, 2, "@E 99999.9"})
            MontaColunas(aFldBrw[i], "MN Total", aFields[Len(aFields)][2], "@E 99999.9", aFields[Len(aFields)][3], aFields[Len(aFields)][4])
            // AAdd(aBrowse, {"MN Total", aFldBrw[i], "N", TamSX3('Z05_TOTMNI')[1], TamSX3('Z05_TOTMNI')[2], AllTrim(X3Picture("Z05_TOTMNI")) })
            // AAdd(aFieFilter, {aFldBrw[i], "CMS/PV", "N", 9, 3, "@E 99,999.999"})
        elseif "NOTA_MANHA" $ aFldBrw[i]
            SX3->(DbSeek("Z0I_NOTMAN"))
            AAdd(aFields, {aFldBrw[i], SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
            // AAdd(aBrowse, {"NtChMan", aFldBrw[i], SX3->X3_TIPO, 1, 0, SX3->X3_PICTURE})
            MontaColunas(aFldBrw[i], "NtChMan", aFields[Len(aFields)][2], SX3->X3_PICTURE, aFields[Len(aFields)][3], aFields[Len(aFields)][4])
            // AAdd(aFieFilter, {aFldBrw[i],"NtChMan", SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE})
        elseif "NOTA_MADRU" $ aFldBrw[i]
            SX3->(DbSeek("Z0I_NOTNOI"))
            AAdd(aFields, {aFldBrw[i], SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
            // AAdd(aBrowse, {"NtChMad", aFldBrw[i], SX3->X3_TIPO, 1, 0, SX3->X3_PICTURE})
            MontaColunas(aFldBrw[i], "NtChMad", aFields[Len(aFields)][2], SX3->X3_PICTURE, aFields[Len(aFields)][3], aFields[Len(aFields)][4])
            // AAdd(aFieFilter, {aFldBrw[i],"NtChMad", SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE})
        elseif "NOTA_NOITE" $ aFldBrw[i]
            SX3->(DbSeek("Z0I_NOTTAR"))
            AAdd(aFields, {aFldBrw[i], SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
            // AAdd(aBrowse, {"NtChNoi", aFldBrw[i], SX3->X3_TIPO, 1, 0, SX3->X3_PICTURE})
            MontaColunas(aFldBrw[i], "NtChNoi", aFields[Len(aFields)][2], SX3->X3_PICTURE, aFields[Len(aFields)][3], aFields[Len(aFields)][4])
            // AAdd(aFieFilter, {aFldBrw[i],"NtChNoi", SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE})
        elseif "B8_SALDO" $ aFldBrw[i]
            SX3->(DbSeek("B8_SALDO"))
            AAdd(aFields, {"B8_SALDO", "N", 6, 0})
            // AAdd(aBrowse, {"Saldo Lote", "B8_SALDO", "N", 1, 0, "@E 999,999"})
            MontaColunas(aFldBrw[i], "Saldo Lote", aFields[Len(aFields)][2], "@E 999,999", aFields[Len(aFields)][3], aFields[Len(aFields)][4])
            // AAdd(aFieFilter, {"B8_SALDO", "Saldo Lote", "N", 6, 0, "@E 999,999"})
        elseif "Z05_MANUAL" $ aFldBrw[i]
            SX3->(DbSeek("Z05_MANUAL"))
            AAdd(aFields, {AllTrim(SX3->X3_CAMPO), SX3->X3_TIPO, 3, SX3->X3_DECIMAL})
            // AAdd(aBrowse, {AllTrim(X3Titulo()), AllTrim(SX3->X3_CAMPO), SX3->X3_TIPO, 1, 0, SX3->X3_PICTURE})
            MontaColunas(aFldBrw[i], AllTrim(X3Titulo()), aFields[Len(aFields)][2], SX3->X3_PICTURE, aFields[Len(aFields)][3], aFields[Len(aFields)][4])
            // AAdd(aFieFilter, {SX3->X3_CAMPO, AllTrim(X3Titulo()), SX3->X3_TIPO, 3, SX3->X3_DECIMAL, SX3->X3_PICTURE})
        elseif "QTDTRATO" $ aFldBrw[i]
            AAdd(aFields, {"QTDTRATO", "N", 4, 0})
            // AAdd(aFieFilter, {"QTDTRATO", "Qtd Trat Repet ", "N", 4, 0, "@E 9,999"})
        else
            SX3->(DbSeek(aFldBrw[i]))
            AAdd(aFields, {AllTrim(SX3->X3_CAMPO), SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
            // AAdd(aBrowse, {AllTrim(X3Titulo()), AllTrim(SX3->X3_CAMPO), SX3->X3_TIPO, 1, 0, SX3->X3_PICTURE})
            MontaColunas(aFldBrw[i], AllTrim(X3Titulo()), aFields[Len(aFields)][2], SX3->X3_PICTURE, aFields[Len(aFields)][3], aFields[Len(aFields)][4])
            // AAdd(aFieFilter, {SX3->X3_CAMPO, AllTrim(X3Titulo()), SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE})
        endif
    next

return nil 

static function LoadTrat(dDtTrato, cAliasName)
local cSql       := ""
local i, nQtdTr  := u_GetNroTrato()
local cInsertCab := ""
local cSelectCab := ""
local cSelectFld := ""
local cKgMnTot   := ""

cInsertCab := " Z08_CODIGO" +;              // COCHO
             ", Z0T_ROTA" +;                // ROTA
             ", Z0S_EQUIP" +;               // CAMINHAO 
             ", ZV0_DESC" +;                // DESCRICAO DO CAMINHAO
             ", B8_LOTECTL" +;              // LOTE
             ", Z05_PESMAT" +;              // PESO MED AUAL
             ", CMS_PV" +;                  // Consumo de materia seca por peso
             ", Z05_MEGCAL" +;              // Mega Caloria
             ", B8_SALDO" +;                // SALDO
             ", Z05_DIASDI" +;              // Dias de Cocho
             ", NOTA_MANHA" +;              // NOTAS DE COCHO
             ", NOTA_MADRU" +;              // NOTAS DE COCHO
             ", NOTA_NOITE" +;              // NOTAS DE COCHO
             ", PROGANTMS" +;               // PROGRAMACAO ANTERIOR - KG de MS / Cabeca       
             ", PROG_MS" +;                 // PROGRAMACAO DE TRATO - KG de MS / Cabeca
             ", NR_TRATOS" +;               // Qtde Tratos
             ", PROGANTMN" +;               // PROGRAMACAO ANTERIOR - KG de MS / Cabeca       
             ", PROG_MN" +;                 // PROGRAMACAO DE TRATO - KG de MN / Cabeca
             ", QTDTRATO"

cSelectCab := " CURRAIS.Z08_CODIGO CODIGO" +;                                                 // COCHO
             ", isnull(ROTAS.Z0T_ROTA, '" + Space(TamSX3("Z0T_ROTA")[1]) + "') Z0T_ROTA" +;   // ROTA
             ", isnull(ROTAS.Z0S_EQUIP, '" + Space(TamSX3("Z0S_EQUIP")[1]) + "') Z0S_EQUIP" +; // Caminhao 
             ", isnull(ROTAS.ZV0_DESC, '" + Space(TamSX3("ZV0_DESC")[1]) + "') ZV0_DESC" +; // Descricao do Caminhao
             ", isnull(Z05.Z05_LOTE, isnull(CURRAIS.B8_LOTECTL,'" + Space(TamSX3("B8_LOTECTL")[1]) + "')) LOTE" +;  // LOTE
             ", isnull(Z05.Z05_PESMAT, 0) Z05_PESMAT" +; // Peso MÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€šÃ‚Â ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¾Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â©dio Atual
             ", isnull(Z05.Z05_KGMSDI, 0)/case isnull(CURRAIS.B8_XPESOCO, 0) + isnull(Z05.Z05_DIASDI,0) * isnull(Z0O_GMD, 0) when 0 then 1 else isnull(CURRAIS.B8_XPESOCO, 0) + isnull(Z05.Z05_DIASDI,0) * isnull(Z0O_GMD, 0) end * 100 CMS_PV " +; // Consumo de materia seca por peso
             ", isnull(Z05.Z05_MEGCAL, 0) Z05_MEGCAL" +;
             ", isnull(CURRAIS.B8_SALDO,0) SALDO" +;                                          // SALDO
             ", isnull(Z05.Z05_DIASDI,0) DIA_COCHO" +; // Dias de Cocho
             ", isnull(NOTA_MANHA.Z0I_NOTMAN,'" + Space(TamSX3("Z0I_NOTMAN")[1]) + "') NOTA_MANHA" +; // NOTAS DE COCHO
             ", isnull(NOTA_MANHA.Z0I_NOTNOI,'" + Space(TamSX3("Z0I_NOTNOI")[1]) + "') NOTA_MADRU" +; // NOTAS DE COCHO
             ", isnull(NOTA_MANHA.Z0I_NOTTAR,'" + Space(TamSX3("Z0I_NOTTAR")[1]) + "') NOTA_NOITE" +; // NOTAS DE COCHO
             ", isnull(Z05ANT.Z05_KGMSDI,0) MS_D1" +; // PROGRAMACAO ANTERIOR - KG de MS / Cabeca 
             ", isnull(Z05.Z05_KGMSDI,0) MS" +; // PROGRAMACAO DE TRATO - KG de MS / Cabeca
             ", isnull(TRATOS.QTDE_TRATOS,0) QTDE_TRATOS" +; // Qtde Tratos
             ", isnull(Z05ANT.Z05_KGMNDI,0) MN_D1" +; // PROGRAMACAO ANTERIOR - KG de MS / Cabeca 
             ", isnull(Z05.Z05_KGMNDI,0) MN" +; // PROGRAMACAO DE TRATO - KG de MN / Cabeca
             ", isnull(REPETE.QTDTRATO, 0) QTDTRATO"

cSelectFld := " CODIGO" +;                                                 // COCHO
             ", Z0T_ROTA" +;   // ROTA
             ", Z0S_EQUIP" +; // Caminhao 
             ", ZV0_DESC" +; // Descricao do Caminhao
             ", LOTE" +;  // LOTE
             ", Z05_PESMAT" +; // Peso Medio Atual
             ", CMS_PV " +; // Consumo de materia seca por peso
             ", Z05_MEGCAL" +;
             ", SALDO" +;                                          // SALDO
             ", DIA_COCHO" +; // Dias de Cocho
             ", NOTA_MANHA" +; // NOTAS DE COCHO
             ", NOTA_MADRU" +; // NOTAS DE COCHO
             ", NOTA_NOITE" +; // NOTAS DE COCHO
             ", MS_D1" +; // PROGRAMACAO ANTERIOR - KG de MS / Cabeca 
             ", MS" +; // PROGRAMACAO DE TRATO - KG de MS / Cabeca
             ", QTDE_TRATOS" +; // Qtde Tratos
             ", MN_D1" +; // PROGRAMACAO ANTERIOR - KG de MS / Cabeca 
             ", MN" +; // PROGRAMACAO DE TRATO - KG de MN / Cabeca
             ", QTDTRATO"


for i := 1 to nQtdTr
    cInsertCab += ", Z06_DIETA" + StrZero(i, 1) + ", Z06_KGMS" + StrZero(i, 1) + ", Z06_KGMN" + StrZero(i, 1)

    cSelectCab += ", isnull(DI" + StrZero(i, 1) + ", '" + Space(TamSX3("B1_COD")[1]) + "') DI" + StrZero(i, 1) +;
                  ", isnull(MS" + StrZero(i, 1) + ", 0) MS" + StrZero(i, 1) +;
                  ", isnull(MN" + StrZero(i, 1) + ", 0) MN" + StrZero(i, 1) 
    if !Empty(cKgMnTot)
        cKgMnTot  +=  " + (isnull(MN" + StrZero(i, 1) + ", 0) *  isnull(B8_SALDO,0))" 
    Else
        cKgMnTot  +=  ", ((isnull(MN" + StrZero(i, 1) + ", 0) *  isnull(B8_SALDO,0))" 
    EndIf
next
cInsertCab += ", Z05_MNTOT" 

cKgMnTot += ") AS Z05_MNTOT"    
cSelectCab += cKgMnTot
DbSelectArea("Z0R")
DbSetOrder(1) // Z0R_FILIAL+DTOS(Z0R_DATA)
if Z0R->(DbSeek(FWxFilial("Z0R")+DToS(dDtTrato)))

    //-----------------------------------------------
    //Monta a query que carrega os dados dos lotes de 
    //acordo com os parametros passados
    //-----------------------------------------------
    TCSqlExec( "delete from " + cAliasName )
    cSql := " with" + CRLF +; 
            " CURRAIS as (" + CRLF +;
                    " select Z08.Z08_FILIAL" + CRLF +;
                         " , Z08.Z08_CONFNA" + CRLF +;
                         " , Z08.Z08_SEQUEN" + CRLF +;
                         " , Z08.Z08_CODIGO" + CRLF +;
                         " , SB8.B8_LOTECTL" + CRLF +;
                         " , sum(B8_XPESOCO*B8_SALDO)/sum(B8_SALDO) B8_XPESOCO" + CRLF +; 
                         " , sum(B8_SALDO) B8_SALDO" + CRLF +;
                      " from " + RetSqlName("Z08") + " Z08" + CRLF +;
                      " join " + RetSqlName("SB8") + " SB8" + CRLF +;
                        " on SB8.B8_FILIAL  = '" + FWxFilial("SB8") + "'" + CRLF +;
                       " and SB8.B8_X_CURRA = Z08.Z08_CODIGO" + CRLF +;
                       " and SB8.B8_SALDO   <> 0" + CRLF +;
                       " and SB8.D_E_L_E_T_ = ' '" + CRLF +;
                     " where Z08.Z08_FILIAL = '" + FWxFilial("Z08") + "'" + CRLF +;
                       " and Z08.Z08_CONFNA <> '  '" + CRLF +;
                       " and Z08.D_E_L_E_T_ = ' '" + CRLF +;
                  " group by Z08.Z08_FILIAL" + CRLF +;
                         " , Z08.Z08_CONFNA" + CRLF +;
                         " , Z08.Z08_SEQUEN" + CRLF +;
                         " , Z08.Z08_CODIGO" + CRLF +;
                         " , SB8.B8_LOTECTL" + CRLF +;
                     " union all" + CRLF +;
                    " select Z08.Z08_FILIAL" + CRLF +;
                         " , Z08.Z08_CONFNA" + CRLF +;
                         " , Z08.Z08_SEQUEN" + CRLF +;
                         " , Z08.Z08_CODIGO" + CRLF +;
                         " , SB8.B8_LOTECTL" + CRLF +;
                         " , sum(B8_XPESOCO*B8_SALDO)/sum(B8_SALDO) B8_XPESOCO" + CRLF +; 
                         " , sum(B8_SALDO) B8_SALDO" + CRLF +;
                      " from " + RetSqlName("Z08") + " Z08" + CRLF +;
                      " join " + RetSqlName("Z05") + " Z05" +;
                        " on Z05.Z05_FILIAL = '" +  FWxFilial("Z05") + "'" + CRLF +;
                       " and Z05.Z05_CURRAL = Z08.Z08_CODIGO" + CRLF +;
                       " and Z05.Z05_DATA   = '" + DToS(Z0R->Z0R_DATA) + "'" + CRLF +;
                       " and Z05.D_E_L_E_T_ = ' '" + CRLF +;
                 " left join " + RetSqlName("SB8") + " SB8" + CRLF +;
                        " on SB8.B8_FILIAL  = '" + FWxFilial("SB8") + "'" + CRLF +;
                       " and SB8.B8_X_CURRA = Z08.Z08_CODIGO" + CRLF +;
                       " and SB8.B8_SALDO   <> 0" + CRLF +;
                       " and SB8.D_E_L_E_T_ = ' '" + CRLF +;
                     " where Z08.Z08_FILIAL = '" + FWxFilial("Z08") + "'" + CRLF +;
                       " and Z08.Z08_CONFNA <> '  '" + CRLF +;
                       " and Z08.Z08_MSBLQL <> '1'" + CRLF +;
                       " and Z08.D_E_L_E_T_ = ' '" + CRLF +;
                       " and SB8.B8_LOTECTL is null" + CRLF +;
                  " group by Z08.Z08_FILIAL" + CRLF +;
                         " , Z08.Z08_CONFNA" + CRLF +;
                         " , Z08.Z08_SEQUEN" + CRLF +;
                         " , Z08.Z08_CODIGO" + CRLF +; 
                         " , SB8.B8_LOTECTL" + CRLF +;
            " )" + CRLF
    cSql += ", TRATOS as (" + CRLF +;
                    " select Z06.Z06_LOTE" + CRLF +;
                         " , count(Z06_FILIAL) QTDE_TRATOS" + CRLF +;
                      " from " + RetSqlName("Z06") + " Z06" + CRLF +;
                     " where Z06.Z06_FILIAL = '" + FWxFilial("Z06") + "'" + CRLF +;
                       " and Z06.Z06_DATA   = '" + DToS(Z0R->Z0R_DATA) + "'" + CRLF +;
                       " and Z06.Z06_VERSAO = '" + Z0R->Z0R_VERSAO + "'" + CRLF +;
                       " and Z06.D_E_L_E_T_ = ' '" + CRLF +;
                  " group by Z06.Z06_LOTE" + CRLF +;
            " )" + CRLF
    cSql += ", DIETA as (" + CRLF +;
                    " select MS.Z06_LOTE" + CRLF +;
                          ", DI1, MS1, MN1" + CRLF +;
                          ", DI2, MS2, MN2" + CRLF +;
                          ", DI3, MS3, MN3" + CRLF +;
                          ", DI4, MS4, MN4" + CRLF +;
                          ", DI5, MS5, MN5" + CRLF +;
                          ", DI6, MS6, MN6" + CRLF +;
                          ", DI7, MS7, MN7" + CRLF +;
                          ", DI8, MS8, MN8" + CRLF +;
                          ", DI9, MS9, MN9" + CRLF +;
                      " from (" + CRLF +;
                           " select PVT.Z06_LOTE, PVT.[1] MS1, PVT.[2] MS2, PVT.[3] MS3, PVT.[4] MS4" + CRLF +;
                                 ", PVT.[5] MS5, PVT.[6] MS6, PVT.[7] MS7, PVT.[8] MS8, PVT.[9] MS9" + CRLF +;
                             " from (" + CRLF +;
                                  " select Z06.Z06_LOTE, Z06.Z06_TRATO, Z06.Z06_KGMSTR" + CRLF +;
                                    " from " + RetSqlName("Z06") + " Z06" + CRLF +;
                                   " where Z06.Z06_FILIAL = '" + FWxFilial("Z06") + "'" + CRLF +;
                                     " and Z06.Z06_DATA = '" + DToS(Z0R->Z0R_DATA) + "'" + CRLF +;
                                     " and Z06.Z06_VERSAO = '" + Z0R->Z0R_VERSAO + "'" + CRLF +;
                                     " and Z06.D_E_L_E_T_ = ' '" + CRLF +;
                                  " ) as DADOS" + CRLF +;
                            " pivot (" + CRLF +;
                                    " sum(Z06_KGMSTR)" + CRLF +;
                                    " for Z06_TRATO in ([1], [2], [3], [4], [5], [6], [7], [8], [9])" + CRLF +;
                                  " ) as PVT" + CRLF +;
                           " ) MS" + CRLF +;
                      " join (" + CRLF +;
                           " select PVT.Z06_LOTE, PVT.[1] MN1, PVT.[2] MN2, PVT.[3] MN3, PVT.[4] MN4" + CRLF +;
                                 ", PVT.[5] MN5, PVT.[6] MN6, PVT.[7] MN7, PVT.[8] MN8, PVT.[9] MN9" + CRLF +;
                             " from (" + CRLF +;
                                  " select Z06.Z06_LOTE, Z06.Z06_TRATO, Z06.Z06_KGMNTR" + CRLF +;
                                    " from " + RetSqlName("Z06") + " Z06" + CRLF +;
                                   " where Z06.Z06_FILIAL = '" + FWxFilial("Z06") + "'" + CRLF +;
                                     " and Z06.Z06_DATA = '" + DToS(Z0R->Z0R_DATA) + "'" + CRLF +;
                                     " and Z06.Z06_VERSAO = '" + Z0R->Z0R_VERSAO + "'" + CRLF +;
                                     " and Z06.D_E_L_E_T_ = ' '" + CRLF +;
                                  " ) as DADOS" + CRLF +;
                            " pivot (" + CRLF +;
                                    " sum(Z06_KGMNTR)" + CRLF +;
                                    " for Z06_TRATO in ([1], [2], [3], [4], [5], [6], [7], [8], [9])" + CRLF +;
                                  " ) as PVT" + CRLF +;
                           " ) MN" + CRLF +;
                        " on MN.Z06_LOTE = MS.Z06_LOTE" + CRLF +;
                      " join (" + CRLF +;
                           " select PVT.Z06_LOTE, PVT.[1] DI1, PVT.[2] DI2, PVT.[3] DI3, PVT.[4] DI4" + CRLF +;
                                 ", PVT.[5] DI5, PVT.[6] DI6, PVT.[7] DI7, PVT.[8] DI8, PVT.[9] DI9" + CRLF +;
                             " from (" + CRLF +;
                                  " select Z06.Z06_LOTE, Z06.Z06_TRATO, Z06.Z06_DIETA" + CRLF +;
                                    " from " + RetSqlName("Z06") + " Z06" + CRLF +;
                                   " where Z06.Z06_FILIAL = '" + FWxFilial("Z06") + "'" + CRLF +;
                                     " and Z06.Z06_DATA = '" + DToS(Z0R->Z0R_DATA) + "'" + CRLF +;
                                     " and Z06.Z06_VERSAO = '" + Z0R->Z0R_VERSAO + "'" + CRLF +;
                                     " and Z06.D_E_L_E_T_ = ' '" + CRLF +;
                                  " ) as DADOS" + CRLF +;
                            " pivot (" + CRLF +;
                                    " min(Z06_DIETA)" + CRLF +;
                                    " for Z06_TRATO in ([1], [2], [3], [4], [5], [6], [7], [8], [9])" + CRLF +;
                                  " ) as PVT" + CRLF +;
                           " ) DIETA" + CRLF +;
                        " on DIETA.Z06_LOTE = MS.Z06_LOTE" + CRLF +;
            " )" + CRLF
    cSql += ", NOTA_MANHA as (" + CRLF +;
                    " select Z0I.Z0I_LOTE" + CRLF +;
                          ", Z0I.Z0I_NOTMAN" + CRLF +;
                          ", Z0I.Z0I_NOTNOI" + CRLF +;
                          ", Z0I.Z0I_NOTTAR" + CRLF +;
                      " from " + RetSqlName("Z0I") + " Z0I" + CRLF +;
                     " where Z0I.Z0I_FILIAL = '" + FWxFilial("Z0I") + "'" + CRLF +;
                       " and Z0I.Z0I_DATA   = '" + DToS(Z0R->Z0R_DATA) + "'" + CRLF +;
                       " and Z0I.D_E_L_E_T_ = ' '" + CRLF +;
            " )" + CRLF
    cSql += ", ROTAS as (" + CRLF +;
                    " select Z0T.Z0T_CONF" + CRLF +;
                          ", Z0T.Z0T_SEQUEN" + CRLF +;
                          ", Z0T.Z0T_CURRAL" + CRLF +;
                          ", Z0T.Z0T_LOTE" + CRLF +;
                          ", Z0T.Z0T_ROTA" + CRLF +;
                          ", isnull(Z0S.Z0S_EQUIP,'" + Space(TamSX3("Z0S_EQUIP")[1]) + "') Z0S_EQUIP" + CRLF +;
                          ", isnull(ZV0.ZV0_DESC,'" + Space(TamSX3("ZV0_DESC")[1]) + "') ZV0_DESC" + CRLF +;
                      " from " + RetSqlName("Z0T") + " Z0T" + CRLF +;
                 " left join " + RetSqlName("Z0S") + " Z0S" + CRLF +;
                        " on Z0S.Z0S_FILIAL = '" + FWxFilial("Z0S") + "'" + CRLF +;
                       " and Z0S.Z0S_DATA   = Z0T.Z0T_DATA" + CRLF +;
                       " and Z0S.Z0S_VERSAO = Z0T.Z0T_VERSAO" + CRLF +;
                       " and Z0S.Z0S_ROTA   = Z0T.Z0T_ROTA" + CRLF +;
                       " and Z0S.D_E_L_E_T_ = ' '" + CRLF +;
                 " left join " + RetSqlName("ZV0") + " ZV0" + CRLF +;
                        " on ZV0.ZV0_FILIAL = '" + FWxFilial("ZV0") + "'" + CRLF +;
                       " and ZV0.ZV0_CODIGO = Z0S.Z0S_EQUIP" + CRLF +;
                       " and ZV0.D_E_L_E_T_ = ' '" + CRLF +;
                     " where Z0T.Z0T_FILIAL = '" + FWxFilial("Z0T") + "'" + CRLF +;
                       " and Z0T.Z0T_DATA + Z0T.Z0T_VERSAO = (" + CRLF +;
                           " select max(MAXVER) MAXVER" + CRLF +;
                             " from (" + CRLF +;
                                  " select Z0T.Z0T_DATA + Z0T.Z0T_VERSAO MAXVER" + CRLF +;
                                    " from " + RetSqlName("Z0T") + " Z0T" + CRLF +;
                                   " where Z0T.Z0T_FILIAL = '" + FWxFilial("Z0T") + "'" + CRLF +;
                                     " and Z0T.Z0T_DATA = '" + DToS(Z0R->Z0R_DATA) + "'" + CRLF +;
                                     " and Z0T.Z0T_VERSAO = '" + Z0R->Z0R_VERSAO + "'" + CRLF +;
                                     " and Z0T.D_E_L_E_T_ = ' '" + CRLF +;
                                   " union all" + CRLF +;
                                  " select max(Z0T.Z0T_DATA + Z0T.Z0T_VERSAO)" + CRLF +;
                                    " from " + RetSqlName("Z0T") + " Z0T" + CRLF +;
                                   " where Z0T.Z0T_FILIAL = '" + FWxFilial("Z0T") + "'" + CRLF +;
                                     " and Z0T.Z0T_DATA + Z0T.Z0T_VERSAO <= '" + DToS(Z0R->Z0R_DATA) + Z0R->Z0R_VERSAO + "'" + CRLF +;
                                     " and Z0T.D_E_L_E_T_ = ' '" + CRLF +;
                                  " ) ROTA" + CRLF +;
                           " )" + CRLF +;
                       " and Z0T.D_E_L_E_T_ = ' '" + CRLF +;
            " )" + CRLF
    cSql += ", REPETE as (" + CRLF +;
                    " select QTT.Z05_LOTE" + CRLF +;
                          ", max(QTT.QTDTRATO) QTDTRATO" + CRLF +;
                      " from (" + CRLF +;
                            " select Z05.Z05_LOTE" + CRLF +;
                                  ", Z05.Z05_KGMSDI" + CRLF +;
                                  ", count(*) QTDTRATO" + CRLF +;
                             " from " + RetSqlName("Z05") + " Z05" + CRLF +;
                            " where Z05.Z05_FILIAL = '" + FWxFilial("Z05") + "'" + CRLF +;
                              " and Z05.Z05_DATA   > '" + DToS(Z0R->Z0R_DATA - GetMV("VA_TRTCNHG",,3)) + "'" + CRLF +;
                              " and Z05.D_E_L_E_T_ = ' '" + CRLF +;
                         " group by Z05.Z05_LOTE, Z05.Z05_KGMSDI" + CRLF +;
                           " ) QTT" + CRLF +;
                  " group by QTT.Z05_LOTE" + CRLF +;
            " )" + CRLF
//    cSql += "  insert into " + cAliasName + "(" + CRLF+; 
//                cInsertCab + CRLF +;
//            " )" + CRLF ;           
    cSql += " select " + CRLF +;
                cSelectCab + CRLF +;
              " from CURRAIS" + CRLF +;
         " left join " + RetSqlName("Z05") + " Z05" + CRLF +;
                " on Z05.Z05_FILIAL = '" + FWxFilial("Z05") + "'" + CRLF +;
               " and Z05.Z05_CURRAL = CURRAIS.Z08_CODIGO" + CRLF+; 
               " and Z05.Z05_DATA   = '" + DToS(Z0R->Z0R_DATA) + "'" + CRLF +;
               " and Z05.Z05_VERSAO = '" + Z0R->Z0R_VERSAO + "'" +;
               " and Z05.D_E_L_E_T_ = ' '" + CRLF +;
         " left join " + RetSqlName("Z05") + " Z05ANT" + CRLF +;
                " on Z05ANT.Z05_FILIAL = '" + FWxFilial("Z05") + "'" + CRLF +;
               " and Z05ANT.Z05_LOTE   = Z05.Z05_LOTE" + CRLF+; 
               " and Z05ANT.Z05_DATA   = '" + DToS(Z0R->Z0R_DATA-1) + "'" + CRLF +;
               " and Z05ANT.Z05_VERSAO    = (" + CRLF  +;
                   " select Z0R_VERSAO " + CRLF  +;
                     " from " + RetSqlName("Z0R") + " Z0R" + CRLF  +;
                    " where Z0R.Z0R_FILIAL = Z05ANT.Z05_FILIAL" + CRLF  +;
                      " and Z0R.Z0R_DATA   = '" + DToS(Z0R->Z0R_DATA-1) + "'" + CRLF +;
                      " and Z0R.D_E_L_E_T_ = ' '" + CRLF +;
                   " )" + CRLF  +;
               " and Z05ANT.D_E_L_E_T_ = ' '" + CRLF +;
         " left join " + RetSqlName("Z0O") + " Z0O" + CRLF +;
                " on Z0O.Z0O_FILIAL = '" + FWxFilial("Z0O") + "'" + CRLF +;
               " and Z0O.Z0O_LOTE   = Z05.Z05_LOTE" + CRLF +;
               " and (" + CRLF +;
                      " '" + DToS(Z0R->Z0R_DATA) + "' between Z0O.Z0O_DATAIN and Z0O.Z0O_DATATR" + CRLF +;
                   " or (Z0O.Z0O_DATAIN <= '" + DToS(Z0R->Z0R_DATA) + "' and Z0O.Z0O_DATATR = '        ')" + CRLF +;
                   " )" + CRLF +;
              " and Z0O.D_E_L_E_T_ = ' '" + CRLF +;
        " left join TRATOS" + CRLF +;
               " on TRATOS.Z06_LOTE = Z05.Z05_LOTE" + CRLF +;
        " left join DIETA" + CRLF +;
               " on DIETA.Z06_LOTE = Z05.Z05_LOTE" + CRLF +;
        " left join NOTA_MANHA" + CRLF +;
               " on NOTA_MANHA.Z0I_LOTE = Z05.Z05_LOTE" + CRLF +;
        " left join ROTAS" + CRLF +;
              "on ROTAS.Z0T_LOTE = CURRAIS.B8_LOTECTL " + CRLF +;
        " left join REPETE" + CRLF +;
               " on REPETE.Z05_LOTE = Z05.Z05_LOTE" + CRLF +;
         " order by CODIGO"

    if lDebug .and. lower(cUserName) $ 'mbernardo,atoshio,admin,administrador,rsantana'
        MemoWrite(cPath + "LoadTrat" + DtoS(dDataBase) + "_" + StrTran(SubS(Time(),1,5),":","") + ".sql", cSql)
    endif

    //if TCSqlExec(cSql) < 0
    //    Help(/*Descontinuado*/,/*Descontinuado*/,"SELECAO DE TRATO",/**/,"Ocorreu um problema ao carregar o trato de " + DToC(mv_par01) + "." + CRLF + TCSQLError(), 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.F.,{"Por favor, entre em contato com o TI para averiguar o problema." })
    //endif
    
    DbUseArea(.t., "TOPCONN", TcGenQry(,,cSql), "TMPTBL", .f., .f.)
    
    while !TMPTBL->(Eof())
        RecLock(cAlias, .t.)

            (cAlias)->Z08_CODIGO   := TMPTBL->CODIGO
            (cAlias)->Z0T_ROTA     := TMPTBL->Z0T_ROTA
            (cAlias)->Z0S_EQUIP    := TMPTBL->Z0S_EQUIP
            (cAlias)->ZV0_DESC     := TMPTBL->ZV0_DESC
            (cAlias)->B8_LOTECTL   := TMPTBL->LOTE
            (cAlias)->Z05_PESMAT   := TMPTBL->Z05_PESMAT
            (cAlias)->CMS_PV       := TMPTBL->CMS_PV
            (cAlias)->Z05_MEGCAL   := TMPTBL->Z05_MEGCAL
            (cAlias)->B8_SALDO     := TMPTBL->SALDO
            (cAlias)->Z05_DIASDI   := TMPTBL->DIA_COCHO
            (cAlias)->NOTA_MANHA   := TMPTBL->NOTA_MANHA
            (cAlias)->NOTA_MADRU   := TMPTBL->NOTA_MADRU
            (cAlias)->NOTA_NOITE   := TMPTBL->NOTA_NOITE
            (cAlias)->PROGANTMS    := TMPTBL->MS_D1
            (cAlias)->PROG_MS      := TMPTBL->MS
            (cAlias)->NR_TRATOS    := TMPTBL->QTDE_TRATOS
            (cAlias)->PROGANTMN    := TMPTBL->MN_D1
            (cAlias)->PROG_MN      := TMPTBL->MN
            (cAlias)->QTDTRATO     := TMPTBL->QTDTRATO
            (cAlias)->Z06_DIETA1   := TMPTBL->DI1
            (cAlias)->Z06_KGMS1    := TMPTBL->MS1
            (cAlias)->Z06_KGMN1    := TMPTBL->MN1
            (cAlias)->Z06_DIETA2   := TMPTBL->DI2
            (cAlias)->Z06_KGMS2    := TMPTBL->MS2
            (cAlias)->Z06_KGMN2    := TMPTBL->MN2
            (cAlias)->Z06_DIETA3   := TMPTBL->DI3
            (cAlias)->Z06_KGMS3    := TMPTBL->MS3
            (cAlias)->Z06_KGMN3    := TMPTBL->MN3
            (cAlias)->Z06_DIETA4   := TMPTBL->DI4
            (cAlias)->Z06_KGMS4    := TMPTBL->MS4
            (cAlias)->Z06_KGMN4    := TMPTBL->MN4
            (cAlias)->Z06_DIETA5   := TMPTBL->DI5
            (cAlias)->Z06_KGMS5    := TMPTBL->MS5
            (cAlias)->Z06_KGMN5    := TMPTBL->MN5
            (cAlias)->Z06_DIETA6   := TMPTBL->DI6
            (cAlias)->Z06_KGMS6    := TMPTBL->MS6
            (cAlias)->Z06_KGMN6    := TMPTBL->MN6
            (cAlias)->Z06_DIETA7   := TMPTBL->DI7
            (cAlias)->Z06_KGMS7    := TMPTBL->MS7
            (cAlias)->Z06_KGMN7    := TMPTBL->MN7
            (cAlias)->Z05_MNTOT    := TMPTBL->Z05_MNTOT

        MsUnlock()

        TMPTBL->(DbSkip())
    end

    TMPTBL->(DbCloseArea())
endif

return nil

static function MontaColunas(cCampo,cTitulo,cTipo,cPicture,nSize,nDecimal)
	/* Array da coluna
	[n][01] T�tulo da coluna
	[n][02] Code-Block de carga dos dados
	[n][03] Tipo de dados
	[n][04] M�scara
	[n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
	[n][06] Tamanho
	[n][07] Decimal
	[n][08] Indica se permite a edi��o
	[n][09] Code-Block de valida��o da coluna ap�s a edi��o
	[n][10] Indica se exibe imagem
	[n][11] Code-Block de execu��o do duplo clique
	[n][12] Vari�vel a ser utilizada na edi��o (ReadVar)
	[n][13] Code-Block de execu��o do clique no header
	[n][14] Indica se a coluna est� deletada
	[n][15] Indica se a coluna ser� exibida nos detalhes do Browse
	[n][16] Op��es de carga dos dados (Ex: 1=Sim, 2=N�o)
	*/

    aadd(aColumns, {{cTitulo,;  // [n][01] T�tulo da coluna
                    &("{ || u_EvalFld('" + cCampo +"')}"),; // [n][02] Code-Block de carga dos dados
                    /*cTipo*/,;    // [n][03] Tipo de dados
                    cPicture,; // [n][04] M�scara
                    Iif(cTipo == "N", 2, Iif(cTipo == "D", 0, 1)),; // [n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
                    nSize,;    // [n][06] Tamanho
                    nDecimal,; // [n][07] Decimal
                    .F.,;      // [n][08] Indica se permite a edi��o
                    {||.T.},;  // [n][09] Code-Block de valida��o da coluna ap�s a edi��o
                    .F.,;      // [n][10] Indica se exibe imagem
                    {||.T.},;  // [n][11] Code-Block de execu��o do duplo clique
                    NIL,;      // [n][12] Vari�vel a ser utilizada na edi��o (ReadVar)
                    {||.T.},;  // [n][13] Code-Block de execu��o do clique no header
                    .F.,;      // [n][14] Indica se a coluna est� deletada
                    .T.,;      // [n][15] Indica se a coluna ser� exibida nos detalhes do Browse
                    {}}})       // [n][16] Op��es de carga dos dados (Ex: 1=Sim, 2=N�o)
return nil

user function EvalFld(cCampo)
return (cAlias)->&(cCampo)


static function MenuDef()
local aRotina := {} 

    ADD OPTION aRotina TITLE OemToAnsi("Visualizar")          ACTION "u_vap05man" OPERATION 2 ACCESS 0 // "Visualizar"
    ADD OPTION aRotina TITLE OemToAnsi("Trato <F12>")         ACTION "u_vap05cri" OPERATION 3 ACCESS 0 // "Copiar" 
    ADD OPTION aRotina TITLE OemToAnsi("Recarrega <F11>")     ACTION "u_vap05rec" OPERATION 3 ACCESS 0 // "Copiar" 
    ADD OPTION aRotina TITLE OemToAnsi("Recria <F5>")         ACTION "u_vap05rcr" OPERATION 4 ACCESS 0 // "Alterar"
    ADD OPTION aRotina TITLE OemToAnsi("Manuten��o <F6>")     ACTION "u_vap05man" OPERATION 4 ACCESS 0 // "Alterar"
    ADD OPTION aRotina TITLE OemToAnsi("Gerar Arquivos <F7>") ACTION "u_vap05arq" OPERATION 2 ACCESS 0 // "Alterar"
    ADD OPTION aRotina TITLE OemToAnsi("Nro Tratos <F8>")     ACTION "u_vap05tra" OPERATION 4 ACCESS 0 // "Alterar"
    ADD OPTION aRotina TITLE OemToAnsi("Mat�ria Seca <F9>")   ACTION "u_vap05msc" OPERATION 4 ACCESS 0 // "Alterar" 
    ADD OPTION aRotina TITLE OemToAnsi("Dietas <F10>")        ACTION "u_vap05trt" OPERATION 4 ACCESS 0 // "Alterar"
    ADD OPTION aRotina TITLE OemToAnsi("Incluir")             ACTION "u_vap05nov" OPERATION 4 ACCESS 0 // "Alterar"
    ADD OPTION aRotina TITLE OemToAnsi("Excluir")             ACTION "u_vap05rem" OPERATION 5 ACCESS 0 // "Alterar"
    ADD OPTION aRotina TITLE OemToAnsi("Transf. Curral")      ACTION "u_vap05tcu" OPERATION 4 ACCESS 0 // "Alterar"

return aRotina

static function BrwStatus(); return Iif((cAlias)->QTDTRATO == nQtdUltTrt, "BR_CINZA", "BR_AZUL")

static function BrwLegend()
local oLegend := FWLegend():New()

    oLegend:Add("","BR_AZUL" , "Houve altera��o de trato nos �ltimos 3 dias" ) 
    oLegend:Add("","BR_CINZA", "Este lote est� a " + AllTrim(Str(nQtdUltTrt)) + " ou mais dias sem altera��o." )
    oLegend:Activate()
    oLegend:View()
    oLegend:DeActivate()

return nil
