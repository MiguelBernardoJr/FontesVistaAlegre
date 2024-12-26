// #########################################################################################
// Projeto: Trato
// Fonte  : vapcpa16
// ---------+------------------------------+------------------------------------------------
// Data     | Autor                        | Descrição
// ---------+------------------------------+------------------------------------------------
// 20190815 | jrscatolon@jrscatolon.com.br | Nota de Manejo de Cocho
//          |                              | 
//          |                              | 
// ---------+------------------------------+------------------------------------------------


#include 'protheus.ch' 
#include 'parmtype.ch'
#include 'fwbrowse.ch'

// CURRAL, LOTE, ANIMAIS, DATA ENTRADA, DIAS COCHO, PESO ENTRADA, PESO MÉDIO ATUAL
// {"Z08_CODIGO", "B8_LOTECTL", "B8_SALDO", "B8_XDATACO", "Z05_DIASDI", "Z05_PESOCO", "Z05_PESMAT"}
// {"Z0I_DATA","Z0I_NOTTAR","Z0I_NOTNOI","Z0I_NOTMAN","Z05_KGMSDI","Z05_DIETA","Z05_CMSPN"}
static cLogName := ""

/*/{Protheus.doc} vapcpa16
Digitação das notas de cocho.
@author jr.andre
@since 07/11/2019
@version 1.0
@type function
/*/
user function vapcpa16()
local oFntSay14A := TFont():New('Courier New',,-20,,.t.)
local oFntSay14N := TFont():New('Courier New',,-18,,.t.)
local oDlg
local oWndCurral, oWndHNotas, oWndNotas, oWndHist
local oLayer := FwLayer():New()
local oSize := FwDefSize():New()

local i, nLen

private lCheck := .t.   
private dDataLeitu := CriaVar("Z0I_DATA", .f.)
private cPeriodo := Space(20)
private cNotaMan := CriaVar("Z0I_NOTMAN", .f.)
private cNotaNoi := CriaVar("Z0I_NOTNOI", .f.)
private cNotaTar := CriaVar("Z0I_NOTTAR", .f.)
private oBrwLotes, oBrwNotas, oBrwHist, oCodigo, oLote, oSaldo, oDataCo, oDiasDi, oPesoCo, oPesMat, oCMSPV,;
         oRealizado, oPrevisto, oDifVlr, oDifPerc, oMgKPrev, oMgKReal, oMgKMeta, oDifMeta, oDiasAju,  oGmdEsp,;
         oProximo, oGetData, oCmbPeriod, oGetNotMan, oGetNotNoi, oGetNotTar
private aBrwLotes := {{ "", "", 0, SToD(""), 0, 0, 0, 0}} 
private aBrwNotas := {{ SToD(""), "", "", "", 0, "", 0, 0, 0, 0, 0, 0, 0,0,0,0 }}
private aBrwHist := {{ "", "", "", "", "" }}
private lCanChange := .t.

    SetKey( VK_F4, {|| ChgCheck() } )
    
    //Cria janela para a aplicação
    oDlg = MsDialog():New(oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3], oSize:aWindSize[4], "Notas de Cocho",,,,, /*nClrText*/, /*nClrBack*/,, /*oWnd*/, .t.,,,,/*lTransparent*/)

    //Inicializa o FWLayer com a janela que ele pertencera
    oLayer:init(oDlg)

    //Cria as colunas do Layer
    oLayer:addCollumn('Col01', 065, .f.)
    oLayer:addCollumn('Col02', 035, .f.)

    //Adiciona Janelas as colunas e ajusta tamanho
    oLayer:addWindow('Col01','Col1_Win01','Currais',          040, .f., .t., {|| .t. },,{|| .t. })
    oLayer:addWindow('Col01','Col1_Win02','Nota de Cocho',    020, .f., .t., {|| .t. },,{|| .t. })
    oLayer:addWindow('Col01','Col1_Win03','Notas Anteriores', 040, .f., .t., {|| .t. },,{|| .t. })
    oLayer:addWindow('Col02','Col2_Win01','Histórico',        100, .f., .f., {|| .t. },,{|| .t. })

    // recupera o objeto do painel 
    oWndCurral := oLayer:getWinPanel('Col01','Col1_Win01')

    // Monta a lista de currais
    oBrwLotes := FWBrowse():New(oWndCurral)
    oBrwLotes:DisableConfig()
    oBrwLotes:DisableFilter()
    oBrwLotes:DisableLocate()
    oBrwLotes:DisableSaveConfig()
    oBrwLotes:DisableSeek()
    oBrwLotes:DisableReport()

    oBrwLotes:SetChange ({|oBrowse| ChgLotes(dDataLeitu, oBrowse)}) 

    oBrwLotes:SetDataArray()

    // Define as colunas do array
    // {"Z08_CODIGO", "B8_LOTECTL", "B8_SALDO", "B8_XDATACO", "Z05_DIASDI", "Z05_PESOCO", "Z05_PESMAT"}
    // BrwArrCol(cTitulo,xArrData,cPicture,nAlign,nSize,cBrowse,cTipo,nDecimal)
    oBrwLotes:SetColumns(BrwArrCol("Codigo"         , 1, "@!"       , 0 , 20, "oBrwLotes", "C", 0))
    oBrwLotes:SetColumns(BrwArrCol("Lote"           , 2, "@!"       , 0 , 10, "oBrwLotes", "C", 0))
    oBrwLotes:SetColumns(BrwArrCol("Saldo Lote"     , 3, "@!"       , 0 ,  3, "oBrwLotes", "N", 0))
    oBrwLotes:SetColumns(BrwArrCol("Dt. Ini. Conf." , 4, "@D"       , 0 ,  8, "oBrwLotes", "D", 0))
    oBrwLotes:SetColumns(BrwArrCol("Dias Cocho"     , 5, "@E 9,999" , 0 ,  4, "oBrwLotes", "N", 0))
    oBrwLotes:SetColumns(BrwArrCol("Pes. Med. Lote" , 6, "@E 999.99", 0 ,  6, "oBrwLotes", "N", 2))
    oBrwLotes:SetColumns(BrwArrCol("Pes. Med. Atu"  , 7, "@E 999.99", 0 ,  6, "oBrwLotes", "N", 2))
    oBrwLotes:SetColumns(BrwArrCol("GMD Esperado"   , 8, "@E 9.99", 0 ,  6, "oBrwLotes", "N", 2))

    oBrwLotes:SetArray(aBrwLotes)
    oBrwLotes:Activate()

    aPos  := {010, 55, 110, 140, 200, 250, 310, 370, 420, 470, 500, 535, 350, 395, 435, 480, 520}
    aPos2 := {010, 55, 110, 140, 208, 258, 320, 364, 412, 456, 495, 535, 345, 390, 430, 475, 525}
    // Monta a os objetos de leitura do registro
    oWndNotas := oLayer:getWinPanel('Col01','Col1_Win02')

    TSay():New(007, aPos[1], {|| "Código"}, oWndNotas,,,,,, .t.)
    oCodigo := TSay():New(013, aPos2[1], {|| "                    "}, oWndNotas,, oFntSay14A,,,, .t.)

    TSay():New(007, aPos[2], {|| "Lote"}, oWndNotas,,,,,, .t.)
    oLote   := TSay():New(013, aPos2[2], {|| "          "}, oWndNotas,, oFntSay14A,,,, .t.)

    TSay():New(007, aPos[3], {|| "Saldo" }, oWndNotas,,,,,, .t.)
    oSaldo  := TSay():New(013, aPos2[3], {|| Transform (0, "@E 999") }, oWndNotas,, oFntSay14N,,,, .t.)

    TSay():New(007, aPos[4], {|| "Inic. Confinamento" }, oWndNotas,,,,,, .t.)
    oDataCo := TSay():New(013, aPos2[4], {|| SToD("")}, oWndNotas,, oFntSay14N,,,, .t.)

    TSay():New(007, aPos[5], {|| "Dias de Cocho" }, oWndNotas,,,,,, .t.)
    oDiasDi := TSay():New(013, aPos2[5], {|| Transform (0, "@E 999")}, oWndNotas,, oFntSay14N,,,, .t.)

    TSay():New(007, aPos[6], {|| "Peso Medio Lote" }, oWndNotas,,,,,, .t.)
    oPesoCo := TSay():New(013, aPos2[6], {|| Transform (0, "@E 999.99")}, oWndNotas,, oFntSay14N,,,, .t.)

    TSay():New(007, aPos[7], {|| "Peso Medio Atual" }, oWndNotas,,,,,, .t.)
    oPesMat := TSay():New(013, aPos2[7], {|| Transform (0, "@E 999.99")}, oWndNotas,, oFntSay14N,,,, .t.)

    TSay():New(007, aPos[8], {|| "CMS % PV" }, oWndNotas,,,,,, .t.)
    oCMSPV := TSay():New(013, aPos2[8], {|| Transform (0, "@E 999.99")}, oWndNotas,, oFntSay14N,,,, .t.)

    TSay():New(007, aPos[9], {|| "Previsto" }, oWndNotas,,,,,, .t.)
    oPrevisto := TSay():New(013, aPos2[9], {|| Transform (0, "@E 9,999")}, oWndNotas,, oFntSay14N,,,, .t.)

    TSay():New(007, aPos[10], {|| "Realizado" }, oWndNotas,,,,,, .t.)
    oRealizado := TSay():New(013, aPos2[10], {|| Transform (0, "@E 9,999")}, oWndNotas,, oFntSay14N,,,, .t.)

    TSay():New(007, aPos[11], {|| "Diferença" }, oWndNotas,,,,,, .t.)
    oDifVlr := TSay():New(013, aPos2[11], {|| Transform (0, "@E 9,999")}, oWndNotas,, oFntSay14N,,,, .t.)

    TSay():New(007, aPos[12], {|| "%%%" }, oWndNotas,,,,,, .t.)
    oDifPerc := TSay():New(013, aPos2[12], {|| Transform (0, "@E 999.99")}, oWndNotas,, oFntSay14N,,,, .t.)

    TSay():New(035, aPos[13], {|| "Mg Kal Prev" }, oWndNotas,,,,,, .t.)
    oMgKPrev := TSay():New(040, aPos2[13], {|| Transform (0, "@E 999.99")}, oWndNotas,, oFntSay14N,,,, .t.)

    TSay():New(035, aPos[14], {|| "Mg Kal Real" }, oWndNotas,,,,,, .t.)
    oMgKReal := TSay():New(040, aPos2[14], {|| Transform (0, "@E 999.99")}, oWndNotas,, oFntSay14N,,,, .t.)

    TSay():New(035, aPos[15], {|| "Meta Mega Cal" }, oWndNotas,,,,,, .t.)
    oMgKMeta := TSay():New(040, aPos2[15], {|| Transform (0, "@E 999.99")}, oWndNotas,, oFntSay14N,,,, .t.)

    TSay():New(035, aPos[16], {|| "% Diferença" }, oWndNotas,,,,,, .t.)
    oDifMeta := TSay():New(040, aPos2[16], {|| Transform (0, "@E 999.99")}, oWndNotas,, oFntSay14N,,,, .t.)

    TSay():New(035, aPos[17], {|| "Dias sem ajuste" }, oWndNotas,,,,,, .t.)
    oDiasAju := TSay():New(040, aPos2[17], {|| Transform (0, "@E 999")}, oWndNotas,, oFntSay14N,,,, .t.)

    // TGet():New( /*nRow*/, /*nCol*/, /*bSetGet*/, /*oDlg*/, /*nWidth*/, /*nHeight*/, /*cPict*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, /*oFont*/, /*uParam12*/, /*uParam13*/, /*lPixel*/, /*uParam15*/, /*uParam16*/, /*bWhen*/, /*uParam18*/, /*uParam19*/, /*bChange*/, /*lReadOnly*/, /*lPassword*/, /*uParam23*/, /*cReadVar*/, /*uParam25*/, /*uParam26*/, /*uParam27*/, /*lHasButton*/, /*lNoButton*/, /*uParam30*/, /*cLabelText*/, /*nLabelPos*/, /*oLabelFont*/, /*nLabelColor*/, /*cPlaceHold*/, /*lPicturePriority*/, /*lFocSel*/ )
    // TComboBox():New( /*nRow*/, /*nCol*/, /*bSetGet*/, /*aItens*/, /*nWidth*/, /*nHeight*/, /*oWnd*/, /*uParam8*/, /*bChange*/, /*bValid*/, /*nClrText*/, /*nClrBack*/, /*lPixel*/, /*oFont*/, /*uParam15*/, /*uParam16*/, /*bWhen*/, /*uParam18*/, /*uParam19*/, /*uParam20*/, /*uParam21*/, /*cReadVar*/, /*cLabelText*/, /*nLabelPos*/, /*oLabelFont*/, /*nLabelColor*/ )

    oGetData := TGet():New( 32, 20, {|u| Iif(PCount() == 0, dDataLeitu, dDataLeitu := u)}, oWndNotas, /*nWidth*/, /*nHeight*/, "@D", {|| VldData(dDataLeitu)}, /*nClrFore*/, /*nClrBack*/, /*oFont*/, /*uParam12*/, /*uParam13*/, .t., /*uParam15*/, /*uParam16*/, /*bWhen*/, /*uParam18*/, /*uParam19*/, {|| ChgData(dDataLeitu)}, /*lReadOnly*/, /*lPassword*/, /*uParam23*/, /*cReadVar*/, /*uParam25*/, /*uParam26*/, /*uParam27*/, /*lHasButton*/, /*lNoButton*/, /*uParam30*/, "Data do trato  ", 1, /*oLabelFont*/, /*nLabelColor*/, /*cPlaceHold*/, /*lPicturePriority*/, /*lFocSel*/ )

    oCmbPeriod := TComboBox():New( 30, 75, {|u| Iif(PCount()>0, cPeriodo := u, cPeriodo)}, {"Noite", "Madrugada", "Manhã"}, 60, /*nHeight*/, oWndNotas, /*uParam8*/, /*bChange*/, /*bValid*/, /*nClrText*/, /*nClrBack*/, .t., /*oFont*/, /*uParam15*/, /*uParam16*/, /*bWhen*/, /*uParam18*/, /*uParam19*/, /*uParam20*/, /*uParam21*/, /*cReadVar*/, "Período", 1, /*oLabelFont*/, /*nLabelColor*/ )

    // TCheckBox():New( /*nRow*/, /*nCol*/, /*cCaption*/, /*bSetGet*/, /*oDlg*/, /*nWidth*/, /*nHeight*/, /*uParam8*/, /*bLClicked*/, /*oFont*/, /*bValid*/, /*nClrText*/, /*nClrPane*/, /*uParam14*/, /*lPixel*/, /*cMsg*/, /*uParam17*/, /*bWhen*/ )
	// bClick := {||(AEval(aChave, {|z| z[1] := If(z[1]==.T.,.F.,.T.)}), oQual:Refresh(.F.))}
	// bSetGet:= {|l| IIF(PCount()>0, lQual:=l, lQual)}
	// oChkQual:= tCheckBox():New(15,20,STR0015,bSetGet,oDlg,50,10,,bClick,,,,,,.T.) //"Inverte Seleção"
    oProximo := TCheckBox():New( 41, 140, 'Proximo', {|u| Iif(PCount()>0, lCheck := u, lCheck)}, oWndNotas, 100, 210, /*uParam8*/, /*bLClicked*/, /*oFont*/, /*bValid*/, /*nClrText*/, /*nClrPane*/, /*uParam14*/, .t., /*cMsg*/, /*uParam17*/, /*bWhen*/)

    oGetNotTar := TGet():New( 32, 185, {|u| Iif(PCount() == 0, cNotaTar, cNotaTar := u)}, oWndNotas, /*nWidth*/, /*nHeight*/, "", {|| VldNota(cNotaTar)}, /*nClrFore*/, /*nClrBack*/, /*oFont*/, /*uParam12*/, /*uParam13*/, .t., /*uParam15*/, /*uParam16*/, {|| lCanChange .and. cPeriodo == "Noite" }, /*uParam18*/, /*uParam19*/, /*bChange*/, /*lReadOnly*/, /*lPassword*/, /*uParam23*/, /*cReadVar*/, /*uParam25*/, /*uParam26*/, /*uParam27*/, /*lHasButton*/, /*lNoButton*/, /*uParam30*/, "Nota Noite", 1, /*oLabelFont*/, /*nLabelColor*/, /*cPlaceHold*/, /*lPicturePriority*/, /*lFocSel*/ )
    oGetNotTar:cF3 := "Z0G"

    oGetNotNoi := TGet():New( 32, 225, {|u| Iif(PCount() == 0, cNotaNoi, cNotaNoi := u)}, oWndNotas, /*nWidth*/, /*nHeight*/, "", {|| VldNota(cNotaNoi)}, /*nClrFore*/, /*nClrBack*/, /*oFont*/, /*uParam12*/, /*uParam13*/, .t., /*uParam15*/, /*uParam16*/, {|| lCanChange .and. cPeriodo == "Madrugada" }, /*uParam18*/, /*uParam19*/, /*bChange*/, /*lReadOnly*/, /*lPassword*/, /*uParam23*/, /*cReadVar*/, /*uParam25*/, /*uParam26*/, /*uParam27*/, /*lHasButton*/, /*lNoButton*/, /*uParam30*/, "Nota Madrug", 1, /*oLabelFont*/, /*nLabelColor*/, /*cPlaceHold*/, /*lPicturePriority*/, /*lFocSel*/ )
    oGetNotNoi:cF3 := "Z0G"

    oGetNotMan := TGet():New( 32, 275, {|u| Iif(PCount() == 0, cNotaMan, cNotaMan := u)}, oWndNotas, /*nWidth*/, /*nHeight*/, "", {|| VldNota(cNotaMan)}, /*nClrFore*/, /*nClrBack*/, /*oFont*/, /*uParam12*/, /*uParam13*/, .t., /*uParam15*/, /*uParam16*/, {|| lCanChange .and. cPeriodo == "Manhã" }, /*uParam18*/, /*uParam19*/, /*bChange*/, /*lReadOnly*/, /*lPassword*/, /*uParam23*/, /*cReadVar*/, /*uParam25*/, /*uParam26*/, /*uParam27*/, /*lHasButton*/, /*lNoButton*/, /*uParam30*/, "Nota Manhã", 1, /*oLabelFont*/, /*nLabelColor*/, /*cPlaceHold*/, /*lPicturePriority*/, /*lFocSel*/ )
    oGetNotMan:cF3 := "Z0G"

    // Monta o histórico da nota de cocho
    oWndHNotas := oLayer:getWinPanel('Col01','Col1_Win03')

    oBrwNotas := FWBrowse():New(oWndHNotas)
    oBrwNotas:DisableConfig()
    oBrwNotas:DisableFilter()
    oBrwNotas:DisableLocate()
    oBrwNotas:DisableSaveConfig()
    oBrwNotas:DisableSeek()
    oBrwNotas:DisableReport()

    oBrwNotas:SetDataArray()

    // {"Z0I_DATA","Z0I_NOTTAR","Z0I_NOTNOI","Z0I_NOTMAN","Z05_KGMSDI","Z05_DIETA","Z05_CMSPN", "Z0O_GMD"}
    // BrwArrCol(cTitulo,xArrData,cPicture,nAlign,nSize,cBrowse,cTipo,nDecimal)
    oBrwNotas:SetColumns(BrwArrCol("Data Medicao" , 01, "@D"         , 0, 08, "oBrwNotas", "D", 0))
    oBrwNotas:SetColumns(BrwArrCol("Nota Noite"   , 02, "@!"         , 0, 06, "oBrwNotas", "C", 0))
    oBrwNotas:SetColumns(BrwArrCol("Nota Madruga" , 03, "@!"         , 0, 06, "oBrwNotas", "C", 0))
    oBrwNotas:SetColumns(BrwArrCol("Nota Manha"   , 04, "@!"         , 0, 06, "oBrwNotas", "C", 0))
    oBrwNotas:SetColumns(BrwArrCol("Mat Seca Prv" , 05, "@E 9,999.99", 0, 08, "oBrwNotas", "N", 2))
    oBrwNotas:SetColumns(BrwArrCol("Dieta"        , 06, "@!"         , 1, 30, "oBrwNotas", "C", 0))
    oBrwNotas:SetColumns(BrwArrCol("CMS % PV"     , 07, "@E 999.99"  , 0, 06, "oBrwNotas", "N", 2))
    oBrwNotas:SetColumns(BrwArrCol("Previsto"     , 08, "@E 9,999.99", 0, 07, "oBrwNotas", "N", 2))
    oBrwNotas:SetColumns(BrwArrCol("Realizado"    , 09, "@E 9,999.99", 0, 07, "oBrwNotas", "N", 2))
    oBrwNotas:SetColumns(BrwArrCol("Diferença"    , 10, "@E 9,999.99", 0, 07, "oBrwNotas", "N", 2))
    oBrwNotas:SetColumns(BrwArrCol("%%%"          , 11, "@E 999.99"  , 0, 07, "oBrwNotas", "N", 2))
    oBrwNotas:SetColumns(BrwArrCol("Mg Cal Prev"  , 12, "@E 999.99"  , 0, 07, "oBrwNotas", "N", 2))
    oBrwNotas:SetColumns(BrwArrCol("Mg Cal Real"  , 13, "@E 999.99"  , 0, 07, "oBrwNotas", "N", 2))
    oBrwNotas:SetColumns(BrwArrCol("Meta Mega Cal", 14, "@E 999.99"  , 0, 07, "oBrwNotas", "N", 2))
    oBrwNotas:SetColumns(BrwArrCol("% Diferença"  , 15, "@E 999.99"  , 0, 07, "oBrwNotas", "N", 2))
    oBrwNotas:SetColumns(BrwArrCol("Dia sem ajus" , 16, "@E 999"     , 0, 07, "oBrwNotas", "N", 0))

    oBrwNotas:SetArray(aBrwNotas)
    oBrwNotas:Activate()

    // Monta o histórico da operação na tela
    oWndHist := oLayer:getWinPanel('Col02','Col2_Win01')

    oBrwHist := FWBrowse():New(oWndHist)
    oBrwHist:DisableConfig()
    oBrwHist:DisableFilter()
    oBrwHist:DisableLocate()
    oBrwHist:DisableSaveConfig()
    oBrwHist:DisableSeek()
    oBrwHist:DisableReport()

    oBrwHist:SetDataArray()

    // {"Z0I_DATA","Z0I_NOTTAR","Z0I_NOTNOI","Z0I_NOTMAN","Z05_KGMSDI","Z05_DIETA","Z05_CMSPN"}
    // BrwArrCol(cTitulo,xArrData,cPicture,nAlign,nSize,cBrowse,cTipo,nDecimal)
    oBrwHist:SetColumns(BrwArrCol("Curral"      , 1, "@!", 0, 20, "oBrwHist", "C", 0))
    oBrwHist:SetColumns(BrwArrCol("Lote"        , 2, "@!", 0, 10, "oBrwHist", "C", 0))
    oBrwHist:SetColumns(BrwArrCol("Noite"       , 3, "@!", 0,  6, "oBrwHist", "C", 0))
    oBrwHist:SetColumns(BrwArrCol("Madrugada"   , 4, "@!", 0,  6, "oBrwHist", "C", 0))
    oBrwHist:SetColumns(BrwArrCol("Manhã"       , 5, "@!", 0,  6, "oBrwHist", "C", 0))

    oBrwHist:SetArray(aBrwHist)
    oBrwHist:Activate()

    //Coloca o botão de split na coluna
    oLayer:setColSplit('Col02', CONTROL_ALIGN_LEFT,,{|| .t. })

    oDlg:Activate(,,,.t.,/*bValid*/,,/*bInit*/)
    
    SetKey( VK_F4, nil )

return nil

/*/{Protheus.doc} VldData
Valida a data de leitura da nota de cocho e verifica se a data pode ser alterada.
@author jr.andre
@since 07/11/2019
@version 1.0
@param dData, date, Data da leitura do cocho
@type function
/*/
static function VldData(dData)
local lRet := .t.

if Empty(dData)
    Help(/*Descontinuado*/,/*Descontinuado*/,"Data invalida",/**/,"Não foi preenchido o campo data.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Por favor, preencha o campo data para prosseguir." })
    lRet := .f.
else
    // identifica se a nota de cocho pode ser alterada.
    lCanChange := dData >= dDataBase
endif

return lRet

/*/{Protheus.doc} ChgData
Carrega os dados das notas de cocho para a data digitada.
@author jr.andre
@since 07/11/2019
@version 1.0
@param dData, date, Data da leitura do cocho
@type function
/*/
static function ChgData(dData)
local aArea := GetArea()

if !Empty(dData)
    DbSelectArea("Z0I")
    DbSetOrder(1) // Z0I_FILIAL+Z0I_DATA+Z0I_CURRAL+Z0I_LOTE
    if !Z0I->(DbSeek(FWxFilial("Z0I")+DToS(dData)))
        if MsgYesNo("Não foi identificado notas de cocho para a data " + DToC(dData) + ". Deseja criar?", "Notas de cocho não encontrada")
            FWMsgRun(, { || CriaZ0I(dData)}, "Criação das notas de cocho.", "Criação das notas de cocho para o dia " + DToC(dData) + "...")
        else
            oGetData:SetFocus()
        endif
    else
        DbSelectArea("Z0R")
        DbSetOrder(1) // 

        // Só permite alteração se a nota de cocho já foi usada 
        if !Z0R->(DBSeek(FWxFilial("Z0R")+DToS(dData)))
        // verifica se existem alterações de curral
            DbUseArea(.t., "TOPCONN", TCGenQry(,, ;
                                      " select *" +;
                                        " from " + RetSqlName("Z0I") + " Z0I" +;
                                   " left join (" +;
                                              " select B8_LOTECTL, B8_X_CURRA, sum(B8_SALDO) B8_SALDO" +;  
                                                " from " + RetSqlName("SB8") + " SB8" +;
                                               " where SB8.B8_FILIAL = '" + FWxFilial("SB8") + "'" +;
                                                 " and SB8.B8_SALDO > 0" +;
                                                 " and SB8.B8_X_CURRA <> '                    '" +;
                                                 " and SB8.D_E_L_E_T_ = ' '" +;
                                            " group by SB8.B8_LOTECTL, SB8.B8_X_CURRA" +;
                                              " ) SB8" +;
                                          " on SB8.B8_LOTECTL = Z0I.Z0I_LOTE" +;
                                       " where Z0I.Z0I_FILIAL = '" + FWxFilial("Z0I") + "'" +;
                                         " and Z0I.Z0I_DATA   = '" + DToS(dData) + "'" +;
                                         " and SB8.B8_X_CURRA <> Z0I.Z0I_CURRAL" +;
                                         " and Z0I.D_E_L_E_T_ = ' '" ;
                                              ), "TMPZ0I", .f., .f.)
                if !TMPZ0I->(Eof())
                    
                    if MsgYesNo("Existem lotes que estão em currais diferentes. Deseja alterar os currais definidos na nota de cocho antes de carregá-los?", "Atualizar Currais.") 

                        DbSelectArea("SB8")
                        DbSetOrder(7) // B8_FILIAL+B8_LOTECTL+B8_X_CURRA 
                        
                        DbSelectArea("Z0I")
                        DbSetOrder(1) // Z0I_FILIAL+Z0I_DATA+Z0I_CURRAL+Z0I_LOTE
                        Z0I->(DbSeek(FWxFilial("Z0I")+DToS(dData)))
                        
                        while !Z0I->(Eof()) .and. Z0I->Z0I_FILIAL == FWxFilial("Z0I") .and. Z0I->Z0I_DATA == dData
                            SB8->(DbSeek(FWxFilial("Z08")+Z0I->Z0I_LOTE))
                            if Z0I->Z0I_CURRAL <> SB8->B8_X_CURRA
                                RecLock("Z0I", .f.)
                                    Z0I->Z0I_CURRAL := SB8->B8_X_CURRA
                                     Z0I->Z0I_RUA := Rua(SB8->B8_X_CURRA)
                                    Z0I->Z0I_SEQUEN := Sequencia(SB8->B8_X_CURRA)
                                MsUnlock()
                            endif
                            Z0I->(DbSkip())
                        end
                        
                    endif
                     
                endif
            TMPZ0I->(DbCloseArea())
        // caso existam pergunta se deseja que seja alterado o curral
        endif
    endif

    if Z0I->(DbSeek(FWxFilial("Z0I")+DToS(dData)))

        LoadLotes(dData)
        oBrwLotes:SetArray(aBrwLotes)
        oBrwLotes:UpdateBrowse()

        LoadNotas(dData, aBrwLotes[oBrwLotes:At()][2])
        oBrwNotas:SetArray(aBrwNotas)
        oBrwNotas:UpdateBrowse()

        LoadHist(dData)
        oBrwHist:SetArray(aBrwHist)
        oBrwHist:UpdateBrowse()

        // {"Z08_CODIGO", "B8_LOTECTL", "B8_SALDO", "B8_XDATACO", "Z05_DIASDI", "Z05_PESOCO", "Z05_PESMAT"}
        oCodigo:SetText(AllTrim(  aBrwLotes[oBrwLotes:At()][1]))
        oLote:SetText(AllTrim(    aBrwLotes[oBrwLotes:At()][2]))
        oSaldo:SetText(Transform( aBrwLotes[oBrwLotes:At()][3], "@E 999"))
        oDataCo:SetText(          aBrwLotes[oBrwLotes:At()][4])
        oDiasDi:SetText(Transform(aBrwLotes[oBrwLotes:At()][5], "@E 999"))
        oPesoCo:SetText(Transform(aBrwLotes[oBrwLotes:At()][6], "@E 999.99"))
        oPesMat:SetText(Transform(aBrwLotes[oBrwLotes:At()][7], "@E 999.99"))
        //oGmdEsp:SetText(Transform(aBrwLotes[oBrwLotes:At()][8], "@E 9.99"))

        oCMSPV:SetText(Transform(    aBrwNotas[1][7], "@E 999.99"))
        oPrevisto:SetText(Transform( aBrwNotas[1][8], "@E 9,999"))
        oRealizado:SetText(Transform(aBrwNotas[1][9], "@E 9,999"))
        oDifVlr  :SetText(Transform(aBrwNotas[1][10], "@E 9,999"))
        oDifPerc :SetText(Transform(aBrwNotas[1][11], "@E 999.99"))
        oMgKPrev :SetText(Transform(aBrwNotas[1][12], "@E 999.99"))
        oMgKReal :SetText(Transform(aBrwNotas[1][13], "@E 999.99"))
        oMgKMeta :SetText(Transform(aBrwNotas[1][14], "@E 999.99"))
        oDifMeta :SetText(Transform(aBrwNotas[1][15], "@E 999.99"))
        oDiasAju :SetText(Transform(aBrwNotas[1][16], "@E 999"))


        cNotaTar := aBrwNotas[1][2]
        oGetNotTar:Refresh()
        cNotaNoi := aBrwNotas[1][3]
        oGetNotNoi:Refresh()
        cNotaMan := aBrwNotas[1][4]
        oGetNotMan:Refresh()
    endif
endif

if !Empty(aArea)
    RestArea(aArea)
endif
return nil

/*/{Protheus.doc} VldNota
Valida a nota de cocho
@author jr.andre
@since 07/11/2019
@version 1.0
@param cNota, characters, descricao
@return logical, Retorna se a nota é valida
@type function
/*/
static function VldNota(cNota)
local aArea := GetArea()
local lRet := .t.

if !Empty(cNota)
    DbSelectArea("Z0G")
    DbSetOrder(1) // Z0G_FILIAL+Z0G_CODIGO+Z0G_DISPON // 1=Manha;2=Tarde;3=Noite;4=Todos;
    if !(Z0G->(DbSeek(FWxFilial("Z0G")+cNota+'4')) .or. Z0G->(DbSeek(FWxFilial("Z0G")+cNota+Iif(cPeriodo$"Noite", '2', Iif(cPeriodo$"Madrugada", '3', '1')))))
         Help(/*Descontinuado*/,/*Descontinuado*/,"NOTA INVALIDA",/**/,"Nota não encontrada.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Por favor, digite uma nota válida ou pressione F3." })
        lRet := .f.
    else
        DbSelectArea("Z0I")
        DbSetOrder(1) // Z0I_FILIAL+Z0I_DATA+Z0I_CURRAL+Z0I_LOTE
        if Empty(dDataLeitu)
            Help(/*Descontinuado*/,/*Descontinuado*/,"DATA INVALIDA",/**/,"Não foi preenchido o campo data.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Por favor, preencha o campo data para prosseguir." })
        elseif Empty(oCodigo:GetText()) .or. Empty(oLote:GetText())
            Help(/*Descontinuado*/,/*Descontinuado*/,"CURRAL",/**/,"Nenhum lote foi selecionado.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Por favor, selecione um lote para prosseguir." })
        elseif !Z0I->(DbSeek(FWxFilial("Z0I")+DToS(dDataLeitu)+PadR(oCodigo:GetText(),TamSX3("Z0I_CURRAL")[1])))
            Help(/*Descontinuado*/,/*Descontinuado*/,"DATA INVALIDA",/**/,"A data definida não retornou nenhum registro válido.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Por favor, digite uma data válida ou crie as notas de cocho para a data selecionada." })
            oGetData:SetFocus()
        elseif cPeriodo$"Noite"
            RecLock("Z0I", .f.)
                Z0I->Z0I_NOTTAR := cNota
            MsUnlock()
            oBrwHist:oData:aArray[oBrwHist:At()][3] := cNota
            oBrwHist:LineRefresh()
            if lCheck
                if oBrwLotes:At() != Len(aBrwLotes)
                    ProxLin()
                    cNotaMan := Space(TamSX3("Z0I_NOTMAN")[1])
                    oGetNotTar:SetFocus()
                endif
            endif
        elseif cPeriodo$"Madrugada"
            RecLock("Z0I", .f.)
                Z0I->Z0I_NOTNOI := cNota
            MsUnlock()
            oBrwHist:oData:aArray[oBrwHist:At()][4] := cNota
            oBrwHist:LineRefresh()
            if lCheck
                if oBrwLotes:At() != Len(aBrwLotes)
                    ProxLin()
                    cNotaNoi := Space(TamSX3("Z0I_NOTMAN")[1])
                    oGetNotNoi:SetFocus()
                endif
            endif 
        elseif cPeriodo$"Manhã"
            RecLock("Z0I", .f.)
                Z0I->Z0I_NOTMAN := cNota
            MsUnlock()
            oBrwHist:oData:aArray[oBrwHist:At()][5] := cNota
            oBrwHist:LineRefresh()
            if lCheck
                if oBrwLotes:At() != Len(aBrwLotes)
                    ProxLin()
                    cNotaTar := Space(TamSX3("Z0I_NOTMAN")[1])
                    oGetNotMan:SetFocus()
                endif
            endif
        endif
    endif
endif

if !Empty(aArea)
    RestArea(aArea)
endif
return lRet

/*/{Protheus.doc} ProxLin
Reposiciona no proximo registro
@author jr.andre
@since 07/11/2019
@version 1.0
@type function
/*/
static function ProxLin()

    // nPosAtu := oBrwLotes:At()
    oBrwLotes:GoDown()
    ChgLotes(dDataLeitu, oBrwLotes)

return nil 

/*/{Protheus.doc} ChgLotes
Carrega os detalhes do lote posicionado
@author jr.andre
@since 07/11/2019
@version 1.0
@param dData, date, Data da leitura do cocho
@param oBrowse, object, objeto do tipo mbrowse passado como parametro para o bloco de código.
@type function
/*/
static function ChgLotes(dData, oBrowse)
local nPosLote := 0

if oBrowse:lActivate .and. oCodigo <> nil

    LoadNotas(dData, aBrwLotes[oBrwLotes:At()][2])
    oBrwNotas:SetArray(aBrwNotas)
    oBrwNotas:UpdateBrowse()

    nPosLote := AScan(aBrwHist, {|aMat| aMat[1] = AllTrim(aBrwLotes[oBrwLotes:At()][1])})

    oCodigo:SetText(AllTrim(aBrwLotes[oBrwLotes:At()][1]))
    oLote:SetText(AllTrim(aBrwLotes[oBrwLotes:At()][2]))
    oSaldo:SetText(Transform (aBrwLotes[oBrwLotes:At()][3], "@E 999"))
    oDataCo:SetText(aBrwLotes[oBrwLotes:At()][4])
    oDiasDi:SetText(Transform(aBrwLotes[oBrwLotes:At()][5], "@E 999"))
    oPesoCo:SetText(Transform(aBrwLotes[oBrwLotes:At()][6], "@E 999.99"))
    oPesMat:SetText(Transform(aBrwLotes[oBrwLotes:At()][7], "@E 999.99"))
    
    //oGmdEsp:SetText(Transform(aBrwLotes[oBrwLotes:At()][8], "@E 9.99"))
    
    oCMSPV:SetText(Transform(aBrwNotas[1][7], "@E 999.99"))
    oPrevisto:SetText(Transform(aBrwNotas[1][8], "@E 9,999"))
    oRealizado:SetText(Transform(aBrwNotas[1][9], "@E 9,999"))
    oDifVlr:SetText(Transform(aBrwNotas[2][10], "@E 9999,999"))
    oDifPerc:SetText(Transform(aBrwNotas[2][11], "@E 999.99"))
    oMgKPrev:SetText(Transform(aBrwNotas[1][12], "@E 999.99"))
    oMgKReal:SetText(Transform(aBrwNotas[1][13], "@E 999.99"))
    oMgKMeta :SetText(Transform(aBrwNotas[1][14], "@E 999.99"))
    oDifMeta :SetText(Transform(aBrwNotas[1][15], "@E 9999.99"))
    oDiasAju :SetText(Transform(aBrwNotas[1][16], "@E 999"))

    cNotaTar := aBrwNotas[1][2]
    oGetNotTar:Refresh()
    cNotaNoi := aBrwNotas[1][3]
    oGetNotNoi:Refresh()
    cNotaMan := aBrwNotas[1][4]
    oGetNotMan:Refresh()


    while aBrwLotes[oBrwLotes:At()][1] != aBrwHist[oBrwHist:At()][1] 
        if aBrwLotes[oBrwLotes:At()][1] < aBrwHist[oBrwHist:At()][1]
            oBrwHist:GoUp()
        else
            oBrwHist:GoDown()
        endif
    end

    oBrwHist:LineRefresh()
    //oBrwHist:SelectRow(nPosLote-1) // GoTo(nPosLote) //
    //oBrwHist:LineRefresh()

    oBrowse:SetFocus()

endif

return nil

/*/{Protheus.doc} LoadLotes
Carrega os lotes e currais para o objeto oBrwLotes
@author jr.andre
@since 07/11/2019
@version 1.0
@param dData, date, descricao
@type function
/*/
static function LoadLotes(dData)
local aArea := GetArea()

    aBrwLotes := {}
    
    cQry := "  with" +;
                " InicTrato as (" +;
                    " select Z0O.*" +;
                      " from " + RetSqlName("Z0O") + " Z0O" +;
                      " join (" +;
                       " select Z0Oa.Z0O_FILIAL, Z0Oa.Z0O_LOTE, min(Z0Oa.Z0O_DATAIN) Z0O_DATAIN" +;
                         " from " + RetSqlName("Z0O") + " Z0Oa" +;
                        " where Z0Oa.Z0O_FILIAL = '" + FWxFilial("Z0O") + "'" +;
                          " and (" +;
                                 " '" + DToS(dData) + "' < Z0Oa.Z0O_DATATR" +; 
                                 " or (Z0Oa.Z0O_DATAIN < '" + DToS(dData) + "' and Z0Oa.Z0O_DATATR = '" + Space(TamSX3("Z0O_DATATR")[1]) + "')" +;
                              " )" +;
                          " and Z0Oa.D_E_L_E_T_ = ' '" +;
                     " group by Z0Oa.Z0O_FILIAL, Z0Oa.Z0O_LOTE" +;
                           " ) MinReg" +;
                        " on MinReg.Z0O_FILIAL = Z0O.Z0O_FILIAL" +;
                       " and MinReg.Z0O_LOTE   = Z0O.Z0O_LOTE" +;
                       " and MinReg.Z0O_DATAIN = Z0O.Z0O_DATAIN" +;
                     " where Z0O.Z0O_FILIAL = '" + FWxFilial("Z0O") + "'" +;
                       " and Z0O.Z0O_LOTE IN ( " +;
                                             " select distinct B8_LOTECTL " +;
                                                    " from " + RetSqlName("SB8") + " B8 " +;
                                              " WHERE B8_FILIAL =  '" + FWxFilial("Z0O") + "' " +;
                                               " AND B8_SALDO > 0" +;  
                                               " AND B8_X_CURRA IN (" +;
                                                				  " SELECT Z08_CODIGO " +; 
                                                				    " FROM " + RetSqlName("Z08") + " Z081 " +; 
                                                				   " WHERE Z08_FILIAL = '" + FWxFilial("Z0O") + "'" +;
                                                				     " AND Z08_CONFNA <> ' '" +; 
                                                				     " AND Z081.D_E_L_E_T_ = ' '" +; 
                                                				   " )" +;
                                               " AND B8.D_E_L_E_T_ = ' '"  +; 
                                               ")"  +;
                       " and Z0O.D_E_L_E_T_ = ' '" +;
                " )" +;
                " select SB8.B8_X_CURRA" +;  
                     " , SB8.B8_LOTECTL" +; 
                     " , sum(SB8.B8_SALDO) B8_SALDO" +; 
                     " , min(SB8.B8_XDATACO) B8_XDATACO" +; 
                     " , InicTrato.Z0O_GMD Z0O_GMD" +; 
                     " , cast(convert(datetime, '" + DToS(dData) + "', 103) - convert(datetime, min(SB8.B8_XDATACO), 103) as numeric) Z05_DIASDI" +; 
                     " , round(sum(SB8.B8_XPESOCO*SB8.B8_SALDO)/sum(SB8.B8_SALDO), 2) Z05_PESOCO" +; 
                     " , case when InicTrato.Z0O_GMD is not null then cast(convert(datetime, '" + DToS(dData) + "', 103) - convert(datetime, min(SB8.B8_XDATACO), 103) as numeric) * InicTrato.Z0O_GMD else 0 end + round(sum(SB8.B8_XPESOCO*SB8.B8_SALDO)/sum(SB8.B8_SALDO), 2) Z05_PESMAT" +; 
                  " from " + RetSqlName("Z08") + " Z08" +;
                  " join " + RetSqlName("SB8") + " SB8" +;
                    " on SB8.B8_FILIAL  = '" + FWxFilial("SB8") + "'" +;
                   " and SB8.B8_X_CURRA = Z08.Z08_CODIGO" +;
                   " and SB8.B8_SALDO    > 0" +;
                   " and SB8.D_E_L_E_T_ = ' '" +;
             " left join InicTrato" +;
                    " on InicTrato.Z0O_LOTE = SB8.B8_LOTECTL" +;
                 " where Z08.Z08_FILIAL = '" + FWxFilial("Z08") + "'" +;
                   " and Z08.Z08_MSBLQL <> '1'" +;
                   " and Z08.Z08_CONFNA <> ' '" +;
                   " and Z08.D_E_L_E_T_ = ' '" +;
              " group by Z08_FILIAL" +;
                     " , SB8.B8_X_CURRA" +;
                     " , SB8.B8_LOTECTL" +;
                     " , InicTrato.Z0O_GMD" 
                      
    DbUseArea(.t., "TOPCONN", TCGenQry(,,cQry ), "TMPTBL", .f., .f.)
//" having (cast(convert(datetime, '" + DToS(dData) + "', 103) - convert(datetime, min(SB8.B8_XDATACO), 103) as numeric)+1) > 1 " 
               
    MEMOWRITE("C:\TOTVS_RELATORIOS\NEW_NOTA_COCHO.txt", cQry)
    
    while !TMPTBL->(Eof())
        AAdd(aBrwLotes, { TMPTBL->B8_X_CURRA;
                        , TMPTBL->B8_LOTECTL;
                        , TMPTBL->B8_SALDO;
                        , SToD(TMPTBL->B8_XDATACO);
                        , TMPTBL->Z05_DIASDI;
                        , TMPTBL->Z05_PESOCO;
                        , TMPTBL->Z05_PESMAT;
                        , TMPTBL->Z0O_GMD})
        TMPTBL->(DbSkip())
    end

    TMPTBL->(DbCloseArea())

if !Empty(aArea)
    RestArea(aArea)
endif
return nil

/*/{Protheus.doc} LoadNotas
Carrega os dados para serem mostrados pelo objeto oBrwNotas.
@author jr.andre
@since 07/11/2019
@version 1.0
@param dData, date, data da digitação das notas
@param cLote, characters, Lote cujas notas anteriores serão mostradas
@type function
/*/
static function LoadNotas(dData, cLote)
local aArea  := GetArea()
local i, nLen
local cDatas := ""
Local _cQry  := ""
    nLen := GetMV("VA_REGHIST",,5) // Identifica a quantidade de registros históricos que deve ser mostrada
    for i := 1 to nLen
        cDatas += Iif(Empty(cDatas),"", ", ") + "('" + DToS(dData-i) + "')"
    next

    aBrwNotas := {}

    DbUseArea(.t., "TOPCONN", TCGenQry(,,;
           _cQry := " select TMPTBL.DIA_NOTA" + CRLF +;
                 ", isnull(Z0I.Z0I_NOTMAN, '') Z0I_NOTMAN" + CRLF +;
                 ", isnull(Z0I.Z0I_NOTNOI, '') Z0I_NOTNOI" + CRLF +;
                 ", isnull(Z0I.Z0I_NOTTAR, '') Z0I_NOTTAR" + CRLF +;
                 ", isnull(Z05.Z05_KGMSDI,  0) Z05_KGMSDI"+ CRLF +;
                 " , isnull((SELECT STRING_AGG(RTRIM(B1_DESC),',' ) WITHIN GROUP (ORDER BY B1_DESC ASC)" +CRLF +;
                 "             FROM "+RetSqlName("SB1")+" " +CRLF +;
	             "            WHERE B1_COD IN (SELECT DISTINCT Z06_DIETA " +CRLF +;
	             "             FROM "+RetSqlName("Z06")+" Z06 " +CRLF +;
				 "      	  WHERE Z06_FILIAL = Z05_FILIAL " +CRLF +;
				 "      	    and Z06_LOTE = Z05_LOTE " +CRLF +;
				 "      		AND Z06_DATA = Z05_DATA " +CRLF +;
				 "      		AND Z06.D_E_L_E_T_ =' ' )),'') Z05_DIETA" +CRLF +;
                 ", isnull(Z05.Z05_CMSPN,   0) Z05_CMSPN" + CRLF+;
                 ", isnull(Z05.Z05_CMSPN,   0) Z05_CMSPN" + CRLF+;
                 ", isnull(Z05.Z05_MEGCAL,0) Z05_MEGCAL" + CRLF+;
                 ", sum(Z0W.Z0W_QTDPRE) Z0W_QTDPRE" + CRLF+;
                 ", sum(case Z0W.Z0W_PESDIG when 0 then Z0W.Z0W_QTDREA else Z0W.Z0W_PESDIG end) Z0W_QTDREA" + CRLF+;
                                  ", ISNULL(( (SELECT (Z0O_CMSPRE/100)*Z0O_PESO FROM " + RetSqlName("Z0O") + " Z0O WHERE Z0O_FILIAL = '" + FWxFilial("Z0I") + "' AND Z0O_LOTE = Z0I.Z0I_LOTE AND Z0O.D_E_L_E_T_ = ' ' ) * (SELECT AVG(G1_ENERG) FROM " + RetSqlName("SG1") + " WHERE G1_FILIAL = '" + FWxFilial("Z0I") + "' AND D_E_L_E_T_ = ' ' AND G1_COD = 'FINAL' ) ),0) MEGA" + CRLF+;
                 ",   CASE WHEN ISNULL(((sum(case Z0W.Z0W_PESDIG when 0 then Z0W.Z0W_QTDREA else Z0W.Z0W_PESDIG end)*Z05_MEGCAL)/ SUM(Z0W_QTDPRE)),0) >0 THEN ((SELECT (sum(case Z0W.Z0W_PESDIG when 0 then Z0W.Z0W_QTDREA else Z0W.Z0W_PESDIG end)*Z05_MEGCAL)/ SUM(Z0W_QTDPRE)) / ISNULL(( (SELECT (Z05_PESMAT+Z0O_GMD) * ISNULL((Z0O_CMSPRE/100),0.022) " + CRLF+;
                               "FROM " + RetSqlName("Z0O") + " Z0O" + CRLF+;
			                  "WHERE Z0O_FILIAL = '" + FWxFilial("Z0I") + "' AND Z0O_LOTE = Z0I.Z0I_LOTE AND Z0O.D_E_L_E_T_ = ' ' )" + CRLF+;
			                  "*" + CRLF+;
			                  "(SELECT AVG(G1_ENERG) " + CRLF+;
			                     "FROM " + RetSqlName("SG1") + " " + CRLF+;
			                    "WHERE G1_FILIAL = '" + FWxFilial("Z0I") + "' AND D_E_L_E_T_ = ' ' AND G1_COD = 'FINAL' ) ),1) ) ELSE 0 END SITUA" + CRLF+;
                ", DATEDIFF(D,(SELECT MAX(Z0IA.Z0I_DATA) FROM " + RetSqlName("Z0I") + " Z0IA WHERE Z0IA.Z0I_FILIAL = '" + FWxFilial("Z0I") + "' AND Z0IA.Z0I_LOTE = Z0I.Z0I_LOTE AND Z0IA.D_E_L_E_T_ = ' ' AND Z0IA.Z0I_NOTMAN IN (SELECT Z0G_CODIGO FROM " + RetSqlName("Z0G") + " WHERE Z0G_PERAJU > 0 AND D_E_L_E_T_ = ' ' ) AND Z0IA.Z0I_DATA < '"+DToS(dData)+"'),'"+DToS(dData)+"') DIAULT" + CRLF+;
             " from (values " + cDatas + ") TMPTBL (DIA_NOTA)" + CRLF+;
        " left join " + RetSqlName("Z0I") + " Z0I" + CRLF+;
               " on Z0I.Z0I_FILIAL = '" + FWxFilial("Z0I") + "'" + CRLF +;
              " and Z0I.Z0I_DATA   = TMPTBL.DIA_NOTA" + CRLF+;
              " and Z0I.Z0I_LOTE   = '" + cLote + "'" + CRLF+;
              " and Z0I.D_E_L_E_T_ = ' '" + CRLF+;
        " left join " + RetSqlName("Z0W") + " Z0W" + CRLF +;
              "  on Z0W.Z0W_FILIAL = '" + FWxFilial("Z0W") + "'" + CRLF+;
             "  and Z0W.Z0W_LOTE   = Z0I.Z0I_LOTE" + CRLF+;
             "  and Z0W.Z0W_DATA   = TMPTBL.DIA_NOTA" + CRLF+;
             "  and Z0W.D_E_L_E_T_ = ' '" + CRLF+;
        " left join " + RetSqlName("Z05") + " Z05" + CRLF +;
               " on Z05.Z05_FILIAL = '" + FWxFilial("Z05") + "'" + CRLF +;
              " and Z05.Z05_DATA   = Z0I.Z0I_DATA" + CRLF +;
              " and Z05_VERSAO     = (" + CRLF+;
                                    " select max(Z05_VERSAO)" + CRLF+;
                                      " from " + RetSqlName("Z05") + " Z05" + CRLF+;
                                     " where Z05.Z05_FILIAL = '" + FWxFilial("Z05") + "'" + CRLF+;
                                       " and Z05.Z05_DATA   = Z0I.Z0I_DATA" + CRLF+;
                                       " and Z05.D_E_L_E_T_ = ' '" + CRLF+;
                                   " )" +;
              " and Z05.Z05_LOTE = Z0I.Z0I_LOTE" + CRLF+;
              " and Z05.D_E_L_E_T_ = ' '" + CRLF+;
         " group by TMPTBL.DIA_NOTA, Z0I_LOTE, Z0I_NOTMAN, Z0I_NOTNOI, Z0I_NOTTAR, Z05_KGMSDI,Z05_FILIAL, Z05_DATA, Z05_LOTE, Z05_DIETA, Z05_CMSPN, Z05_MEGCAL, Z05_PESMAT" + CRLF+;
         " order by TMPTBL.DIA_NOTA desc" ;
                                 ), "TMPZ0I", .f., .f.)
    MEMOWRITE("C:\TOTVS_RELATORIOS\VAPCPA16-LoadNotas.SQL", _cQry)
    while !TMPZ0I->(Eof())
        AAdd(aBrwNotas, ;
            { SToD(TMPZ0I->DIA_NOTA) ;                                            // 01
                 , TMPZ0I->Z0I_NOTTAR ;                                           // 02
                 , TMPZ0I->Z0I_NOTNOI ;                                           // 03
                 , TMPZ0I->Z0I_NOTMAN ;                                           // 04
                 , TMPZ0I->Z05_KGMSDI ;                                           // 05
                 , AllTrim(TMPZ0I->Z05_DIETA) ;                                   // 06
                 , TMPZ0I->Z05_CMSPN ;                                            // 07
                 , TMPZ0I->Z0W_QTDPRE ;                                           // 08
                 , TMPZ0I->Z0W_QTDREA ;                                           // 09
                 , TMPZ0I->Z0W_QTDREA - TMPZ0I->Z0W_QTDPRE ;                      // 10 diferenca
                 , ((TMPZ0I->Z0W_QTDREA / TMPZ0I->Z0W_QTDPRE) -1) *100 ;          // 11 porcentagem
                 , TMPZ0I->Z05_MEGCAL ;                                           // 12 Z05_MEGCAL Previsto
                 , (TMPZ0I->Z0W_QTDREA*TMPZ0I->Z05_MEGCAL)/TMPZ0I->Z0W_QTDPRE;     // 13 Z05_MEGCAL Realizado
                 , TMPZ0I->MEGA ;
                 , TMPZ0I->SITUAÇ*100 ;//, (((TMPZ0I->Z0W_QTDREA*TMPZ0I->Z05_MEGCAL)/TMPZ0I->Z0W_QTDPRE)/TMPZ0I->MEGA)*100    ;
                 , TMPZ0I->DIAULT} ) 
        TMPZ0I->(DbSkip())
    end
    TMPZ0I->(DbCloseArea())

if !Empty(aArea)
    RestArea(aArea)
endif
return nil

/*/{Protheus.doc} LoadHist
Carrega os dados para serem mostrados pelo objeto oBrwHist.
@author jr.andre
@since 07/11/2019
@version 1.0
@param dData, date, descricao
@type function
/*/
static function LoadHist(dData)
local aArea := GetArea()

aBrwHist := {}

DbUseArea(.t., "TOPCONN", TCGenQry(,,;
                          " select DISTINCT SB8.B8_X_CURRA" +;
                               " , Z0I.Z0I_LOTE" +;
                               " , Z0I.Z0I_NOTMAN" +;
                               " , Z0I.Z0I_NOTNOI" +;
                               " , Z0I.Z0I_NOTTAR" +;
                            " from " + RetSqlName("Z0I") + " Z0I" +;
                            " Join " + RetSqlName("SB8") + " SB8 ON " +;
                                 " B8_FILIAL = Z0I_FILIAL " +;
                             " AND B8_LOTECTL = Z0I_LOTE" +;
                             " AND B8_SALDO > 0" +;
                             " AND B8_X_CURRA <> ' ' " +;
                             " AND SB8.D_E_L_E_T_ = ' ' " +;
                           " where Z0I.Z0I_FILIAL = '" + FWxFilial("Z0I") + "'" +;
                             " and Z0I.Z0I_DATA   = '" + DToS(dData) + "'" +;
                             " and Z0I.D_E_L_E_T_ = ' '" +;
                        " order by SB8.B8_X_CURRA" ;
                                     ), "TMPZ0I", .f., .f.)
    while !TMPZ0I->(Eof())
        AAdd(aBrwHist, { TMPZ0I->B8_X_CURRA ;
                    , TMPZ0I->Z0I_LOTE ;
                    , TMPZ0I->Z0I_NOTTAR ;
                    , TMPZ0I->Z0I_NOTNOI ;
                    , TMPZ0I->Z0I_NOTMAN } )
        TMPZ0I->(DbSkip())
    end

    TMPZ0I->(DbCloseArea())

if !Empty(aArea)
    RestArea(aArea)
endif

return nil

/*/{Protheus.doc} BrwArrCol
Cria array com a estrutura para coluna de objetos mbrowse 
@author jr.andre
@since 07/11/2019
@version 1.0
@return Array, estrutura para coluna de objetos mbrowse
@param cTitulo, characters, título da coluna
@param xArrData, , Code-Block de carga dos dados
@param cPicture, characters, Máscara
@param nAlign, numeric, Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
@param nSize, numeric, Tamanho
@param cBrowse, characters, objeto FwBrowse
@param cTipo, characters, Tipo de dado
@param nDecimal, numeric, Tamanho das casas decimais
@type function
/*/
static function BrwArrCol(cTitulo, xArrData, cPicture, nAlign, nSize, cBrowse, cTipo, nDecimal)
local bData := {||}
default nAlign := 1
default nSize := 20

if !Empty(xArrData)
    if ValType(xArrData) == "B"
        bData := xArrData
    elseif ValType(xArrData) == "N" .AND. xArrData > 0 .AND. !Empty(cBrowse)
        bData := &("{||"+cBrowse+":oData:aArray["+cBrowse+":At(),"+STR(xArrData)+"]}")
    endif
endif

/*/ 
 * Array da coluna
 * [n][01] Título da coluna
 * [n][02] Code-Block de carga dos dados
 * [n][03] Tipo de dados
 * [n][04] Máscara
 * [n][05] Alinhamento (0=Centralizado, 1=Esquerda ou 2=Direita)
 * [n][06] Tamanho
 * [n][07] Decimal
 * [n][08] Indica se permite a edição
 * [n][09] Code-Block de validação da coluna após a edição
 * [n][10] Indica se exibe imagem
 * [n][11] Code-Block de execução do duplo clique
 * [n][12] Variável a ser utilizada na edição (ReadVar)
 * [n][13] Code-Block de execução do clique no header
 * [n][14] Indica se a coluna está deletada
 * [n][15] Indica se a coluna será exibida nos detalhes do Browse
 * [n][16] Opções de carga dos dados (Ex: 1=Sim, 2=Não) 
/*/

return {{cTitulo,bData,cTipo,cPicture,nAlign,nSize,nDecimal,.f.,{||.t.},.f.,{||.t.},nil,{||.t.},.f.,.f.,{}}}

/*/{Protheus.doc} CriaZ0I
Cria os dados da tabela Z0I para a data definida.
@author jr.andre
@since 07/11/2019
@version 1.0
@param dData, date, data da criação da tabela Z0I
@type function
/*/
static function CriaZ0I(dData)
local aArea := GetArea()

DbUseArea(.t., "TOPCONN", TCGenQry(,,;
                          " select Z08.Z08_FILIAL" +;
                               " , Z08.Z08_LINHA" +;
                               " , Z08.Z08_SEQUEN" +;
                               " , Z08.Z08_CODIGO" +;
                               " , SB8.B8_LOTECTL" +;
                            " from " + RetSqlName("Z08") +" Z08" +;
                            " join " + RetSqlName("SB8") + " SB8" +;
                              " on SB8.B8_FILIAL  = '" + FWxFilial("SB8") + "'" +;
                             " and SB8.B8_X_CURRA = Z08.Z08_CODIGO" +;
                             " and SB8.B8_SALDO   <> 0" +;
                             " and SB8.D_E_L_E_T_ = ' '" +;
                           " where Z08.Z08_FILIAL = '" + FWxFilial("Z08") + "'" +;
                             " and Z08.Z08_CONFNA <> '  '" +;
                             " and Z08.D_E_L_E_T_ = ' '" +;
                        " group by Z08.Z08_FILIAL" +;
                               " , Z08.Z08_LINHA" +;
                               " , Z08.Z08_SEQUEN" +;
                               " , Z08.Z08_CODIGO" +;
                               " , SB8.B8_LOTECTL" ;
                                     ), "Z0ITMP", .f., .f.)

    while !Z0ITMP->(Eof())
        RecLock("Z0I", .T.)
            Z0I->Z0I_FILIAL := FWxFilial("Z0I")
            Z0I->Z0I_DATA   := dData
            Z0I->Z0I_RUA    := Z0ITMP->Z08_LINHA
            Z0I->Z0I_SEQUEN := Z0ITMP->Z08_SEQUEN
            Z0I->Z0I_CURRAL := Z0ITMP->Z08_CODIGO
            Z0I->Z0I_LOTE   := Z0ITMP->B8_LOTECTL
        Z0I->(MsUnlock())
        Z0ITMP->(DbSkip())
    end

Z0ITMP->(DbCloseArea())

RestArea(aArea)
return nil

static function Rua(cCurral)
local i := 1
local cChar := ""
local cRua := ""

while !(cChar := SubStr(cCurral, i, 1)) < '0' .and. cChar > '9' 
    cRua += cChar
    i++
end

return cRua

static function Sequencia(cCurral)
local i := 1
local cChar := ""
local cSequencia := ""

while !(cChar := SubStr(cCurral, i, 1)) < '0' .and. cChar > '9' 
    i++
end

while cChar >= '0' .and. cChar <= '9'
    cSequencia += cChar
    i++
    cChar := SubStr(cCurral, i, 1)
end

return cSequencia

static function ChgCheck()
    lCheck := !lCheck
    oProximo:CtrlRefresh()
return nil
