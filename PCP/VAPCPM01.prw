// #########################################################################################
// Projeto: JRModelos
// Fonte  : JRMOD1
// ---------+------------------------------+------------------------------------------------
// Data     | Autor: JRScatolon            | Descricao: Cadastro de Nota de Manejo
// ---------+------------------------------+------------------------------------------------
// aaaammdd | <email>                      | <Descricao da rotina>
//          |                              |  
//          |                              |  
// ---------+------------------------------+------------------------------------------------

#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

User Function VAPCPM01(cILNumLote)

Local i, nLen
Local cSql := ""

Local aFields := {}
Local aBrowse := {}
Local aFieFilter := {}
Local aIndex := {}
Local aSeek := {}

Private oBrowse := Nil
Private aRotina := MenuDef()
Private cAlias := "SB8"
Private cDescri := "Lote x Plano nutricional"
Private cAliasTMP := CriaTrab(,.f.)
Private cPerg := "VAPCPM01"
Private oTmpSB8 := nil
Private bF12 := SetKey(VK_F12, {|| povoaBrw() })
Private aCposSB8 := {"B8_X_CURRA", "B8_LOTECTL", "Z0M_DESCRI", "Z0O_DATAIN", "Z0O_DIAIN", "B8_SALDO", "PESO_INIC", "PESO_ATUAL", "PESO_FINAL", "B8_XDATACO", "B8_DIASCO", "Z0O_GMD", "Z0O_DCESP"}
// Z0O_PESO -> Virtual ->  Carregar o campo Z0M_PESO
Private aCposZ0O := {"Z0O_CODPLA", "Z0O_DESPLA", "Z0O_DATAIN", "Z0O_DIAIN ", "Z0O_DATATR", "Z0O_GMD", "Z0O_DCESP ", "Z0O_RENESP", "Z0O_PESO"}


//------------------------------------------------
//Carrega as tabelas que serï¿½o usadas pela rotina 
//------------------------------------------------
DbSelectArea("Z05")
DbSetOrder(1) // Z05_FILIAL+Z05_DATA+Z05_CURRAL+Z05_VERSAO

DbSelectArea("Z0M")
DbSetOrder(1) // Z0M_FILIAL+Z0M_CODIGO+Z0M_VERSAO+Z0M_DIA+Z0M_TRATO

DbSelectArea("SB8")
DbSetOrder(1) //B8_FILIAL+B8_PRODUTO+B8_LOCAL+DTOS(B8_DTVALID)+B8_LOTECTL+B8_NUMLOTE

DbSelectArea("Z0O")
DbSetOrder(1) // Z0O_FILIAL+Z0O_LOTE+Z0O_CODPLA

//-----------------------------------------------
//Monta os campos da tabela temporï¿½ria e o browse
//-----------------------------------------------
SX3->(DbSetOrder(2)) // X3_CAMPO
nLen := Len(aCposSB8)
for i := 1 to nLen
    if aCposSB8[i]$"PESO_INIC"
        AAdd(aFields,{"PESO_INIC", "N", 8, 2})
        AAdd(aBrowse, {"Peso Inicial", "PESO_INIC", "N", 8, 2, "@E 99,999.99"})
        AAdd(aFieFilter, {"PESO_INIC", "Peso Inicial", "N", 8, 2, "@E 99,999.99"})
    elseif aCposSB8[i]$"PESO_ATUAL"
        AAdd(aFields,{"PESO_ATUAL", "N", 8, 2})
        AAdd(aBrowse, {"Peso Atual Proj", "PESO_ATUAL", "N", 8, 2, "@E 99,999.99"})
        AAdd(aFieFilter, {"PESO_ATUAL", "Peso Atual Proj", "N", 8, 2, "@E 99,999.99"})
    elseif aCposSB8[i]$"PESO_FINAL"
        AAdd(aFields,{"PESO_FINAL", "N", 8, 2})
        AAdd(aBrowse, {"Peso Final Proj", "PESO_FINAL", "N", 8, 2, "@E 99,999.99"})
        AAdd(aFieFilter, {"PESO_FINAL", "Peso Final Proj", "N", 8, 2, "@E 99,999.99"})
    elseif aCposSB8[i]$"B8_SALDO"
        AAdd(aFields,{"B8_SALDO", "C", 3, 0})
        AAdd(aBrowse, {"Saldo Lote  ", "B8_SALDO", "C", 3, 0, "@E 999"})
        AAdd(aFieFilter, {"B8_SALDO", "Saldo Lote  ", "C", 3, 0, "@E 999"})
    elseif aCposSB8[i]$"B8_DIASCO"
        AAdd(aFields,{"B8_DIASCO", "C", 3, 0})
        AAdd(aBrowse, {"Dias Cocho  ", "B8_DIASCO", "C", 3, 0, "@E 999"})
        AAdd(aFieFilter, {"B8_DIASCO", "Dias Cocho  ", "C", 3, 0, "@E 999"})
    else
        SX3->(DbSeek(aCposSB8[i]))
        AAdd(aFields,{SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL})
        AAdd(aBrowse, {X3Titulo(), SX3->X3_CAMPO, SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE})
        AAdd(aFieFilter, {SX3->X3_CAMPO, X3Titulo(), SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE})
    endif
next

//-------------------
//Criaï¿½ï¿½o do objeto
//-------------------
oTmpSB8 := FWTemporaryTable():New(cAliasTMP)
oTmpSB8:SetFields(aFields)

//-------------------
//Ajuste dos ï¿½ndices
//-------------------
// "B8_X_CURRA", "B8_LOTECTL", "Z0M_DESCRI", "Z0O_DATAIN", "Z0O_DIAIN", "B8_SALDO", "PESO_INIC", "PESO_ATUAL", "PESO_FINAL", "B8_XDATACO", "B8_DIASCO", "Z0O_GMD", "Z0O_DCESP"

oTmpSB8:AddIndex(cAliasTMP + "1", {"B8_X_CURRA"})
oTmpSB8:AddIndex(cAliasTMP + "2", {"B8_LOTECTL"})
oTmpSB8:AddIndex(cAliasTMP + "3", {"Z0O_DATAIN"})
oTmpSB8:AddIndex(cAliasTMP + "4", {"B8_DIASCO"})
oTmpSB8:AddIndex(cAliasTMP + "5", {"B8_SALDO"})
oTmpSB8:AddIndex(cAliasTMP + "6", {"Z0M_DESCRI"})

AAdd(aIndex, "B8_X_CURRA")
AAdd(aIndex, "B8_LOTECTL")
AAdd(aIndex, "Z0O_DATAIN")
AAdd(aIndex, "B8_DIASCO")
AAdd(aIndex, "B8_SALDO")
AAdd(aIndex, "Z0M_DESCRI")

AAdd(aSeek,{"Curral", {{"", TamSX3("B8_X_CURRA")[3],  TamSX3("B8_X_CURRA")[1],  TamSX3("B8_X_CURRA")[2],  "B8_X_CURRA",  "@!"}}, 1, .t. })
AAdd(aSeek,{"Lote",{{"", TamSX3("B8_LOTECTL")[3], TamSX3("B8_LOTECTL")[1], TamSX3("B8_LOTECTL")[2], "B8_LOTECTL", "@!"}}, 2, .t. })
AAdd(aSeek,{"Data Inicio PL",{{"", TamSX3("Z0O_DATAIN")[3], TamSX3("Z0O_DATAIN")[1], TamSX3("Z0O_DATAIN")[2], "Z0O_DATAIN", "@!"}}, 3, .t. })
AAdd(aSeek,{"Dias Cocho",{{"", "C", 3, 0, "B8_DIASCO", "@E 999"}}, 4, .t. })
AAdd(aSeek,{"Saldo Lote",{{"", "C", 3, 0, "B8_SALDO", "@E 999"}}, 5, .t. })
AAdd(aSeek,{"Descriï¿½ï¿½o PL",{{"", TamSX3("Z0M_DESCRI")[3], TamSX3("Z0M_DESCRI")[1], TamSX3("Z0M_DESCRI")[2], "Z0M_DESCRI", "@!"}}, 6, .t. })

//------------------
//Criaï¿½ï¿½o da tabela
//------------------
oTmpSB8:Create()

povoaBrw(.F.)

DbSelectArea("SX2")
DbSetOrder(1)
DbSeek(cAlias)

If (!Empty(cILNumLote))
	(cAliasTMP)->(DBSetOrder(2))
	(cAliasTMP)->(DBSeek(cILNumLote))
	U_BTNCNSLT()
	cILNumLote := ""
	Return (Nil)
EndIf

oBrowse := FWMBrowse():New()
oBrowse:SetAlias(cAliasTMP)
oBrowse:SetQueryIndex(aIndex)
oBrowse:SetTemporary(.T.)
oBrowse:SetFields(aBrowse)

oBrowse:SetUseFilter(.F.)
oBrowse:SetUseCaseFilter(.F.)
oBrowse:DisableDetails()    

oBrowse:SetDescription(SX2->X2_NOME)
oBrowse:SetSeek(.T.,aSeek)
oBrowse:Activate()

(cAliasTMP)->(DbCloseArea())

If oTmpSB8 <> Nil
    oTmpSB8:Delete()
    oTmpSB8 := Nil
EndIf

SetKey(VK_F12, bF12)

Return Nil


Static Function povoaBrw(lPergunte)

Local cSql := ""
Local nPos := 0
Default lPergunte := .T.

If Type("oBrowse") <> 'U'
    nPos := oBrowse:nAt 
EndIf

//-----------------------------------------------
//Monta a query que carrega os dados dos lotes de 
//acordo com os parametros passados
//-----------------------------------------------
Pergunte(cPerg, lPergunte)
if TCSqlExec("delete from " + oTmpSB8:GetRealName()) >= 0
    cSql :=   " insert into " + oTmpSB8:GetRealName() +CRLF+;
                         "( B8_X_CURRA" +CRLF+;
                         ", B8_LOTECTL" +CRLF+;
                         ", Z0M_DESCRI" +CRLF+;
                         ", Z0O_DATAIN" +CRLF+;
                         ", Z0O_DIAIN " +CRLF+;
                         ", B8_SALDO" +CRLF+;
                         ", PESO_INIC" +CRLF+;
                         ", PESO_ATUAL" +CRLF+;
                         ", PESO_FINAL" +CRLF+;
                         ", B8_XDATACO" +CRLF+;
                         ", B8_DIASCO " +CRLF+;
                        " , Z0O_GMD" +CRLF+;
                        " , Z0O_DCESP" +CRLF+;
                         ")" +CRLF+;
                   " select SB8.B8_X_CURRA" +CRLF+;
                        " , SB8.B8_LOTECTL" +CRLF+;
                         ", ISNULL(Z0M_DESCRI,'') Z0M_DESCRI" +CRLF+;
                         ", ISNULL(Z0O_DATAIN,'') Z0O_DATAIN" +CRLF+;
                         ", ISNULL(Z0O_DIAIN ,'') Z0O_DIAIN " +CRLF+;
                         ", right('000'+rtrim(cast(sum(SB8.B8_SALDO) as varchar(3))), 3) B8_SALDO" + CRLF +;
                        " , CASE WHEN SUM(SB8.B8_SALDO) > 0 THEN " +CRLF+;
                        "    sum(SB8.B8_XPESOCO*SB8.B8_SALDO)/sum(SB8.B8_SALDO) " +CRLF+; 
                        "   WHEN SUM(SB8.B8_SALDO) = 0 THEN 0 " +CRLF+; 
                        "   ELSE 0 " +CRLF+;
                        "   END PESO_INIC " +CRLF+;
                        "   , CASE WHEN SUM(SB8.B8_SALDO) > 0 THEN " +CRLF+;
                        "   ISNULL(sum(SB8.B8_XPESOCO*SB8.B8_SALDO)/sum(SB8.B8_SALDO)+((CAST(convert(datetime, getdate(), 103) - convert(datetime, MIN(SB8.B8_XDATACO), 103) AS numeric))*Z0O_GMD),0) " +CRLF+;
                        "   WHEN SUM(SB8.B8_SALDO) = 0 THEN 0 " +CRLF+;
                        "   ELSE 0 " +CRLF+;
                        "   END PESO_ATUAL " +CRLF+;
                        "   , CASE WHEN SUM(SB8.B8_SALDO) > 0 THEN " +CRLF+;
                        "   ISNULL(sum(SB8.B8_XPESOCO*SB8.B8_SALDO)/sum(SB8.B8_SALDO)+(Z0O_DCESP*Z0O_GMD),0) " +CRLF+; 
                        "   WHEN SUM(SB8.B8_SALDO) = 0 THEN 0 " +CRLF+;
                        "   ELSE 0 " +CRLF+;
                        "   END PESO_FINAL " +CRLF+;
                        "   , ISNULL(CASE WHEN Z0O_DINITR = ' '  THEN DTCOCHO.XDATACO WHEN Z0O_DINITR <> ' ' THEN Z0O_DINITR ELSE DTCOCHO.XDATACO END, DTCOCHO.XDATACO ) B8_XDATACO " +CRLF+;
                         ", case when DTCOCHO.XDATACO is null " + CRLF +;
                               " then '000' " + CRLF +;
                               " else right('000' + rtrim(cast(convert(int, convert(datetime, '" + DToS(dDataBase) + "', 112) - convert(datetime, ISNULL(CASE WHEN Z0O_DINITR = ' '  THEN DTCOCHO.XDATACO WHEN Z0O_DINITR <> ' ' THEN Z0O_DINITR ELSE DTCOCHO.XDATACO END, DTCOCHO.XDATACO), 112)+1) as varchar(3))), 3) " + CRLF +;
                           " end B8_DIASCO" + CRLF +;
                        " , ISNULL(Z0O_GMD,0) Z0O_GMD" +CRLF+;
                        " , ISNULL(Z0O_DCESP,0) Z0O_DCESP" +CRLF+;
                     " from " + RetSqlName("SB8") + " SB8" +CRLF+;
                     " join (" +CRLF+;
                           " select SB8.B8_X_CURRA" +CRLF+;
                                " , SB8.B8_LOTECTL" +CRLF+;
                                " , min(SB8.B8_XDATACO) XDATACO" +CRLF+;
                             " from " + RetSqlName("SB8") + " SB8" +CRLF+;
                            " where SB8.B8_FILIAL = '" + FWxFilial("SB8") + "'" +CRLF+;
                              " and SB8.B8_XDATACO <> '" + Space(TamSX3("B8_XDATACO")[1]) + "'" +CRLF+;
                              " and SB8.D_E_L_E_T_ = ' '" +CRLF+;
                         " group by SB8.B8_X_CURRA" +CRLF+;
                                " , SB8.B8_LOTECTL" +CRLF+;
                          " ) DTCOCHO" +CRLF+;
                       " on SB8.B8_X_CURRA = DTCOCHO.B8_X_CURRA" +CRLF+;
                      " and SB8.B8_LOTECTL = DTCOCHO.B8_LOTECTL" +CRLF+;
                " left join " + RetSqlName("Z0O") + " Z0O" +CRLF+;
                       " on Z0O.Z0O_FILIAL = '" + FWxFilial("Z0O") + "'" +CRLF+;
                      " and Z0O.Z0O_LOTE   = SB8.B8_LOTECTL" +CRLF+;
                      " and ('" + DToS(dDataBase) + "' between Z0O.Z0O_DATAIN and Z0O.Z0O_DATATR or ( Z0O.Z0O_DATAIN <= '" + DToS(dDataBase) + "' and Z0O.Z0O_DATATR = '        '))" +CRLF+;
                      " and Z0O.D_E_L_E_T_ = ' '" +CRLF+;
                " left join (" +CRLF+;
                           " select distinct Z0M_CODIGO, Z0M_DESCRI" +CRLF+;
                             " from " + RetSqlName("Z0M") + " Z0M" +CRLF+;
                            " where Z0M.Z0M_FILIAL = '" + FWxFilial("Z0M") + "'" +CRLF+;
                              " and Z0M.Z0M_VERSAO = (" +CRLF+;
                                                     " select max(Z0M_VERSAO)" +CRLF+;
                                                       " from " + RetSqlName("Z0M") + " Z0Ma" +CRLF+;
                                                      " where Z0Ma.Z0M_FILIAL = Z0M.Z0M_FILIAL" +CRLF+;
                                                        " and Z0Ma.Z0M_CODIGO = Z0M.Z0M_CODIGO" +CRLF+;
                                                        " and D_E_L_E_T_ = ' '" +CRLF+;
                                                   " )" +CRLF+;
                              " and Z0M.D_E_L_E_T_ = ' '" +CRLF+;
                          " ) Z0M" +CRLF+;
                       " on Z0M.Z0M_CODIGO = Z0O.Z0O_CODPLA" +CRLF+;
                    " where SB8.B8_FILIAL = '" + FWxFilial("SB8") + "'" +CRLF+;
                      " and SB8.B8_X_CURRA <> '" + Space(TamSX3("B8_X_CURRA")[1]) + "'" +CRLF+;
                      " and SB8.D_E_L_E_T_ = ' '" + CRLF
    if mv_par01 == 2 // Lotes ativos
        cSql +=       " and SB8.B8_SALDO > 0" + CRLF
    ElseIf 	mv_par01 == 2
		cSql +=       " and SB8.B8_SALDO = 0" + CRLF
	endif
    cSql +=      " group by SB8.B8_X_CURRA" +CRLF+;
                         ", SB8.B8_LOTECTL" +CRLF+;
                         ", Z0M_DESCRI" +CRLF+;
                         ", Z0O_DATAIN" +CRLF+;
                         ", Z0O_DIAIN" +CRLF+;
                         ", Z0O_GMD" +CRLF+;
                         ", Z0O_DCESP" +CRLF+;
						 ", Z0O_DINITR" +CRLF+;
                         ", DTCOCHO.XDATACO" +;
                 " order by SB8.B8_X_CURRA, SB8.B8_LOTECTL"
    
    MEMOWRITE("C:\TOTVS\TOTVS_RELATORIOS\IL_SQL.txt", cSql)
    
    If TCSqlExec(cSql) < 0
        Help(/*Descontinuado*/,/*Descontinuado*/,"LOTE X PL NUTRIC",/**/,"Ocorreu um erro ao carregar a lista de Lotes.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Por favor, tente executar novamente e se o problema persistir entre em contato com o TI para averiguar o problema." })
        MEMOWRITE("C:\TOTVS\TOTVS_RELATORIOS\IL_ERROBROWSE.txt", TCSQLError())
    EndIf

else
    Help(/*Descontinuado*/,/*Descontinuado*/,"LOTE X PL NUTRIC",/**/,"Ocorreu um erro ao descartar a lista de Lotes.", 1, 1,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,/*Descontinuado*/,.f.,{"Por favor, tente executar novamente e se o problema persistir entre em contato com o TI para averiguar o problema." })
//    MemoWrite(cPath + "vapcpa07" + DtoS(dDataBase)+"_"+StrTran(SubS(Time(),1,5),":","") + ".log", "Ocorreu um erro ao descartar a lista de Lotes." + CRLF + TCSQLError())
endif

If (Type("oBrowse") <> 'U')
    oBrowse:nAt := nPos
    oBrowse:Refresh()
    oBrowse:ChangeTopBot()
EndIf

Return Nil


Static Function MenuDef()

Local aRotina := {} 

//ADD OPTION aRotina TITLE OemToAnsi("Pesquisar")  ACTION "PesqBrw"       	  OPERATION 1 ACCESS 0 // "Pesquisar"
//ADD OPTION aRotina TITLE OemToAnsi("Visualizar") ACTION "VIEWDEF.VAPCPM01"    OPERATION 2 ACCESS 0 // "Visualizar"
//ADD OPTION aRotina TITLE OemToAnsi("Incluir")    ACTION "VIEWDEF.VAPCPM01"    OPERATION 3 ACCESS 0 // "Incluir"
//ADD OPTION aRotina TITLE OemToAnsi("Alterar")    ACTION "VIEWDEF.VAPCPM01"    OPERATION 4 ACCESS 0 // "Alterar"
ADD OPTION aRotina TITLE OemToAnsi("Consultar")    ACTION "U_BTNCNSLT"    OPERATION 4 ACCESS 0 // "Consultar"
//ADD OPTION aRotina TITLE OemToAnsi("Excluir")    ACTION "VIEWDEF.VAPCPM01"    OPERATION 5 ACCESS 0 // "Excluir" 
//ADD OPTION aRotina TITLE OemToAnsi("Copiar")     ACTION "VIEWDEF.VAPCPM01"    OPERATION 9 ACCESS 0 // "Copiar" 

Return aRotina


User Function btnCnslt() 

Local aEnButt := {{.F., NIL},{.F., NIL},{.F., NIL},{.F., NIL},{.F., NIL},{.F., NIL},{.F., NIL},{.T., "Fechar"},{.F., NIL},{.F., NIL},{.F., NIL},{.T., NIL},{.F., NIL},{.F., NIL}}

aCrrgAb := {.F., .F., .F., .F., .F.,.F., .F., .F.}

FWExecView('Informacoes do Lote','VAPCPM01', MODEL_OPERATION_UPDATE, , { || .T. },,, aEnButt)

Return (Nil)


Static Function ModelDef()

Local oModel
Local oStrCabc := getStrCab(1)
Local oStrCur  := FWFormStruct(1,"Z0N", {|cCampo| AllTrim(cCampo)+"|" $ "Z0N_CURRAL|Z0N_DATAEN|Z0N_DATASA|"})
Local oStrPlN  := FWFormStruct(1,"Z0O", {|cCampo| AllTrim(cCampo)+"|" $ "Z0O_LOTE|Z0O_CODPLA|Z0O_DESPLA|Z0O_DATAIN|Z0O_DIAIN|Z0O_DATATR|"})
Local oStrAbt  := FWFormStruct(1,"Z0Q")
Local oStrArq  := getStrArq(1)
Local oStrAqH  := FWFormStruct(1,"Z0P")
Local oStrAnm  := getStrAnm(1)
Local oStrDen  := getStrDen(1)
Local oStrRes  := getStrRes(1)
Local oStrSld  := getStrSld(1)
Local oStrANE  := getStrANE(1)
Local oStrANS  := getStrANS(1)
Local oStrNFE  := getStrNFE(1)
Local oStrNFS  := getStrNFS(1)

oModel := MpFormModel():New('U_VAPCPM01', /*bPreValid*/,,{|| .T.}/*Confirrmar*/, {|| .T.}/*Cancel*/) 
oModel:SetDescription("Informacoes do Lote")

oModel:AddFields("MASTER",, oStrCabc,/*bPreValid*/, /*bPosValid*/, {|| DADCAB((cAliasTMP)->B8_LOTECTL, (cAliasTMP)->B8_X_CURRA)})
oModel:AddGrid("GRIDCURRAL" , "MASTER", oStrCur , /*bLnVldVl*/,,,, {|| {{0, {,,}}}}) /*{|| CURLOT((cAliasTMP)->B8_LOTECTL)}*/
oModel:AddGrid("GRIDPLANO"  , "MASTER", oStrPlN, /*bLnVldVl*/,,,, ) //{|| {{0, {SB8->B8_LOTECTL, "000001", dDataBase, 0, dDataBase, "000001"}}}})
oModel:AddFields("MASTERARQ", "MASTER", oStrArq,/*bPreValid*/, /*bPosValid*/, {|| {Space(50),,,}})
oModel:AddGrid("GRIDHISABA" , "MASTER", oStrAqH, /*bLnVldVl*/,,,, )
oModel:AddGrid("GRIDABATE"  , "GRIDHISABA", oStrAbt, /*bLnVldVl*/,,,, )
oModel:AddGrid("GRIDANIM"   , "MASTER", oStrAnm, /*bLnVldVl*/,,,, {|| {{0, {,,,,,,,,,}}}}) /*{|| ANMLOT((cAliasTMP)->B8_LOTECTL)}*/
oModel:AddGrid("GRIDDENT"   , "MASTER", oStrDen, /*bLnVldVl*/,,,, {|| {{0, {,,,,,,,,,}}}}) /*{|| ANMLOT((cAliasTMP)->B8_LOTECTL)}*/
oModel:AddGrid("GRIDRESUMO" , "MASTER", oStrRes, /*bLnVldVl*/,,,, {|| {{0, {,,,,,,,,,,,}}}}) /*{|| RESLOT((cAliasTMP)->B8_LOTECTL)}*/
oModel:AddGrid("GRIDSALDO" , "MASTER", oStrSld, /*bLnVldVl*/,,,, {|| {{0, {,,,,,}}}}) /*{|| SLDLOT((cAliasTMP)->B8_LOTECTL)}*/
oModel:AddFields("MASTERNFE", "MASTER", oStrANE,/*bPreValid*/, /*bPosValid*/, {|| {}})
oModel:AddFields("MASTERNFS", "MASTER", oStrANS,/*bPreValid*/, /*bPosValid*/, {|| {}})
oModel:AddGrid("GRIDNOTAE" , "MASTER", oStrNFE, /*bLnVldVl*/,,,, {|| {{0, {,,,,,,,,,,,,,,,}}}}) /*{|| NOTFISE((cAliasTMP)->B8_LOTECTL)}*/
oModel:AddGrid("GRIDNOTAS" , "MASTER", oStrNFS, /*bLnVldVl*/,,,, {|| {{0, {,,,,,,,,,,,,}}}}) /*{|| NOTFISS((cAliasTMP)->B8_LOTECTL)}*/

//oModel:SetRelation( "GRIDHISABA", {{"Z0P_FILIAL", "'" + (cAliasTMP)->B8_FILIAL + "'"}, {"Z0P_LOTE", "'" + (cAliasTMP)->B8_LOTECTL + "'"}}, Z0P->(IndexKey(1)))
oModel:SetRelation( "GRIDHISABA", {{"Z0P_LOTE", "'" + (cAliasTMP)->B8_LOTECTL + "'"}}, Z0P->(IndexKey(1)))
oModel:SetRelation( "GRIDABATE", {{"Z0Q_FILIAL", "Z0P_FILIAL"}, {"Z0Q_LOTE", "Z0P_LOTE"}, {"Z0Q_SEQUEN", "Z0P_SEQUEN"}}, Z0Q->(IndexKey(1)))

oModel:getModel("MASTER"):SetDescription("Informacoes do Lote")
oModel:getModel("GRIDCURRAL"):SetDescription("Curral")
oModel:getModel("GRIDPLANO"):SetDescription("Plano Nutricional")
oModel:getModel("MASTERARQ"):SetDescription("Arquivo Abates")
oModel:getModel("GRIDHISABA"):SetDescription("Historico Abates")
oModel:getModel("GRIDABATE"):SetDescription("Abates")
oModel:getModel("GRIDANIM"):SetDescription("Animais")
oModel:getModel("GRIDDENT"):SetDescription("Dentição")
oModel:getModel("GRIDRESUMO"):SetDescription("Resumo do Lote")
oModel:getModel("GRIDSALDO"):SetDescription("Saldos")
oModel:getModel("MASTERNFE"):SetDescription("Opcoes Nota Fiscal de Entrada")
oModel:getModel("MASTERNFS"):SetDescription("Opcoes Nota Fiscal de Saida")
oModel:getModel("GRIDNOTAE"):SetDescription("Nota(s) Fiscal(is) de Entrada")
oModel:getModel("GRIDNOTAS"):SetDescription("Nota(s) Fiscal(is) de Saida")

oModel:SetPrimaryKey({})

Return oModel


Static Function ViewDef()

Local oModel := ModelDef() 
Local oView 
Local oStrCab := getStrCab(2)
Local oStrCur := FWFormStruct(2,"Z0N", {|cCampo| AllTrim(cCampo)+"|" $ "Z0N_CURRAL|Z0N_DATAEN|Z0N_DATASA|"})
Local oStrPlN := FWFormStruct(2,"Z0O", {|cCampo| AllTrim(cCampo)+"|" $ "Z0O_LOTE|Z0O_CODPLA|Z0O_DESPLA|Z0O_DATAIN|Z0O_DIAIN|Z0O_DATATR|"})
Local oStrAbt := FWFormStruct(2,"Z0Q")
Local oStrArq := getStrArq(2)
Local oStrAqH := FWFormStruct(2,"Z0P")
Local oStrAnm := getStrAnm(2)
Local oStrDen := getStrDen(2)
Local oStrRes := getStrRes(2)
Local oStrSld := getStrSld(2)
Local oStrANE := getStrANE(2)
Local oStrANS := getStrANS(2)
Local oStrNFE := getStrNFE(2)
Local oStrNFS := getStrNFS(2)

oView := FwFormView():New()
oView:SetModel(oModel)

//View X Model
oView:AddField("VWCABEC", oStrCab, "MASTER")
oView:AddGrid("VWCURRAL", oStrCur, "GRIDCURRAL")
oView:AddGrid("VWPLANO", oStrPlN, "GRIDPLANO")
oView:AddField("VWARQ", oStrArq, "MASTERARQ")
oView:AddGrid("VWHISABA", oStrAqH, "GRIDHISABA")
oView:AddGrid("VWABATE", oStrAbt, "GRIDABATE")
oView:AddGrid("VWANIM", oStrAnm, "GRIDANIM")
oView:AddGrid("VWDENT", oStrDen, "GRIDDENT")
oView:AddGrid("VWRESUMO", oStrRes, "GRIDRESUMO")
oView:AddGrid("VWSALDO", oStrSld, "GRIDSALDO")
//oView:AddField("VWANE", oStrANE, "MASTERNFE")
//oView:AddField("VWANS", oStrANS, "MASTERNFS")
oView:AddGrid("VWNOTAE", oStrNFE, "GRIDNOTAE")
oView:AddGrid("VWNOTAS", oStrNFS, "GRIDNOTAS")

oView:CreateHorizontalBox("CABECALHO",40)
oView:CreateHorizontalBox("PASTAS",60)

oView:CreateFolder("PSTFDR", "PASTAS")

oView:AddSheet("PSTFDR", "ANIMAIS", "Animais", {|| RUNGEN(1)})
oView:CreateHorizontalBox("BOXANIM", 100, , , "PSTFDR", "ANIMAIS")

oView:AddSheet("PSTFDR", "PLANO", "Plano Nutricional", {|| RUNGEN(2)})
oView:CreateHorizontalBox("BOXPLANO", 100, /*owner*/, /*lUsePixel*/, "PSTFDR", "PLANO")

oView:AddSheet("PSTFDR", "ABATE", "Abate")
//oView:CreateHorizontalBox("BOXABATE", 100, /*owner*/, /*lUsePixel*/, "PSTFDR", "ABATE")
oView:CreateVerticalBox("COLABA1", 20,,, "PSTFDR", "ABATE")
oView:CreateHorizontalBox("BOXARQABA", 50, "COLABA1",,"PSTFDR", "ABATE")
oView:CreateHorizontalBox("BOXHISABA", 50, "COLABA1",,"PSTFDR", "ABATE")
oView:CreateVerticalBox("COLABA2", 80,,, "PSTFDR", "ABATE")

oView:AddSheet("PSTFDR", "CURRAL", "Curral", {|| RUNGEN(4)})
oView:CreateHorizontalBox("BOXCURRAL", 100, /*owner*/, /*lUsePixel*/, "PSTFDR", "CURRAL")

oView:AddSheet("PSTFDR", "RESUMO", "Resumo Do Lote", {|| RUNGEN(5)})
oView:CreateHorizontalBox("BOXRESUMO", 100, , , "PSTFDR", "RESUMO")

oView:AddSheet("PSTFDR", "SALDO", "Saldo", {|| RUNGEN(6)})
oView:CreateHorizontalBox("BOXSALDO", 100, , , "PSTFDR", "SALDO")

oView:AddSheet("PSTFDR", "NOTASF", "Notas Fiscais", {|| RUNGEN(7)})
//oView:CreateHorizontalBox("BOXACES", 20, , , "PSTFDR", "NOTASF")
//oView:CreateVerticalBox("BOXACESNE", 50, "BOXACES",, "PSTFDR", "NOTASF")
//oView:CreateVerticalBox("BOXACESNS", 50, "BOXACES",, "PSTFDR", "NOTASF")
oView:CreateHorizontalBox("BOXNF", 100, , , "PSTFDR", "NOTASF")
oView:CreateVerticalBox("BOXNOTAE", 50, "BOXNF",, "PSTFDR", "NOTASF")
oView:CreateVerticalBox("BOXNOTAS", 50, "BOXNF",, "PSTFDR", "NOTASF")

oView:AddSheet("PSTFDR", "DENTICAO", "Dentição", {|| RUNGEN(8)})
oView:CreateHorizontalBox("BOXDENT", 100, , , "PSTFDR", "DENTICAO")


oView:SetOwnerView("VWCABEC","CABECALHO")
oView:SetOwnerView("VWCURRAL", "BOXCURRAL")
oView:SetOwnerView("VWPLANO", "BOXPLANO")
oView:SetOwnerView("VWARQ", "BOXARQABA")
oView:SetOwnerView("VWHISABA", "BOXHISABA")
oView:SetOwnerView("VWABATE", "COLABA2")
oView:SetOwnerView("VWANIM", "BOXANIM")
oView:SetOwnerView("VWDENT", "BOXDENT")
oView:SetOwnerView("VWRESUMO", "BOXRESUMO")
oView:SetOwnerView("VWSALDO", "BOXSALDO")
//oView:SetOwnerView("VWANE", "BOXACESNE")
//oView:SetOwnerView("VWANS", "BOXACESNS")
oView:SetOwnerView("VWNOTAE", "BOXNOTAE")
oView:SetOwnerView("VWNOTAS", "BOXNOTAS")

oStrAqH:RemoveField("Z0P_LOTE")

oStrAbt:RemoveField("Z0Q_LOTE")
oStrAbt:RemoveField("Z0Q_SEQUEN")

oView:AddIncrementField("VWABATE", "Z0Q_ITEM")
oView:AddIncrementField("VWHISABA", "Z0P_SEQUEN")

oStrAnm:SetProperty("*", MVC_VIEW_CANCHANGE , .F.)
oStrCur:SetProperty("*", MVC_VIEW_CANCHANGE , .F.)
oStrPlN:SetProperty("*", MVC_VIEW_CANCHANGE , .F.)
oStrRes:SetProperty("*", MVC_VIEW_CANCHANGE , .F.)
oStrSld:SetProperty("*", MVC_VIEW_CANCHANGE , .F.)
oStrNFE:SetProperty("*", MVC_VIEW_CANCHANGE , .F.)
oStrNFS:SetProperty("*", MVC_VIEW_CANCHANGE , .F.)

//oView:SetNoDeleteLine("VIEW")
oView:SetNoDeleteLine("VWHISABA")
oView:SetNoDeleteLine("VWABATE")
oView:SetNoDeleteLine("VWNOTAE")
oView:SetNoDeleteLine("VWNOTAS")

oView:EnableTitleView("VWARQ", "Arquivo para Importacao")
oView:EnableTitleView("VWHISABA", "Historico Importacao")
//oView:EnableTitleView("VWANE", "Notas Fiscais de Entrada")
//oView:EnableTitleView("VWANS", "Notas Fiscais de Saida")
oView:EnableTitleView("VWNOTAE", "Notas Fiscais de Entrada")
oView:EnableTitleView("VWNOTAS", "Notas Fiscais de Saida")

oView:addUserButton("Kardex", "OK", {|| U_VAESTR16({{(cAliasTMP)->B8_LOTECTL, (cAliasTMP)->B8_X_CURRA}})})
oView:addUserButton("Rel. Comp. Lote", "OK", {|| U_VABOVR01({{(cAliasTMP)->B8_LOTECTL, (cAliasTMP)->B8_X_CURRA}})})
oView:SetViewProperty("VWNOTAE", "GRIDDOUBLECLICK", {{|| VIWNF(1)}})
oView:SetViewProperty("VWNOTAS", "GRIDDOUBLECLICK", {{|| VIWNF(2)}})
//oView:SetViewProperty("VIEW_ZA2", "GRIDDOUBLECLICK", {{|oFormulario,cFieldName,nLineGrid,nLineModel| MyDoubleClick(oFormulario,cFieldName,nLineGrid,nLineModel)}}) 

Return oView


Static Function getStrCab(nOpr)
Local oStruRet

If (nOpr == 1)

	oStruRet := FWFormModelStruct():New()
 
	oStruRet:AddField("Numero       ","Numero do Lote             ", "TMPIL_NUM", "C", 15, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Sequencia    ","Sequencial do Lote         ", "TMPIL_SEQ", "C", 02, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Curral       ","Curral                     ", "TMPIL_CUR", "C", 10, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Cabecas      ","Quantidade de Cabecas      ", "TMPIL_CAB", "N", 10, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Data Entrada ","Data de Entrada            ", "TMPIL_DTE", "D", 08, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Data Saida   ","Data de Saida              ", "TMPIL_DTS", "D", 08, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("PVI Medio    ","PVI Medio                  ", "TMPIL_PVI", "N", 14, 2, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Peso Lote    ","Peso do Lote               ", "TMPIL_PLT", "N", 14, 2, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Peso Med Proj","Peso Medio Projetado       ", "TMPIL_PMP", "N", 14, 2, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Peso Proj Lot","Peso Projetado do Lote     ", "TMPIL_PPL", "N", 14, 2, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Dias de Cocho","Dias de Cocho              ", "TMPIL_DCC", "N", 04, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("GMD Esperado" ,"GMD Esperado               ", "TMPIL_GMD", "N", 14, 2, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("DC Esperado  ","DC Esperado                ", "TMPIL_DCE", "N", 04, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("PVF Esperado ","PVF Esperado               ", "TMPIL_PVF", "N", 14, 2, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Abate Estim. ","Abate Estimado             ", "TMPIL_ABE", "D", 08, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("REND Esper(%)","REND Esperado(%)           ", "TMPIL_RDE", "N", 06, 2, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Quant.Anim.UA","Quantidade de animais em UA", "TMPIL_QUA", "N", 06, 2, , , {}, .F., , .F., .F., .F., , )
	//oStruRet:AddField("Lotacao UA   ","Lotacao por UA             ", "TMPIL_LUA", "N", 04, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Plano Nutric.","Plano Nutricional          ", "TMPIL_PLN", "C", 10, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Raca Lote    ","Raca do Lote               ", "TMPIL_RCL", "C", 20, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Sexo Lote    ","Sexo do Lote               ", "TMPIL_SXL", "C", 05, 0, , , {}, .F., , .F., .F., .F., , )	
	//:AddField(<cTitulo>,<cTooltip>,<cIdField>,<cTipo>,<nTamanho>,[nDecimal],[bValid],[bWhen],[aValues],[lObrigat],[bInit],<lKey>,[lNoUpd],[lVirtual],[cValid])-> NIL
 			
ElseIf (nOpr == 2)

	oStruRet := FWFormViewStruct():New()
	
	oStruRet:AddField("TMPIL_NUM","01","Numero       ","Numero do Lote             ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPIL_SEQ","02","Sequencia    ","Sequencial do Lote         ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPIL_CUR","03","Curral       ","Curral                     ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPIL_CAB","04","Cabecas      ","Quantidade de Cabecas      ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPIL_DTE","05","Data Entrada ","Data de Entrada            ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPIL_DTS","06","Data Saida   ","Data de Saida              ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPIL_PVI","07","PVI Medio    ","PVI Medio                  ",, "GET","@E 999,999,999.99",/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPIL_PLT","08","Peso Lote    ","Peso do Lote               ",, "GET","@E 999,999,999.99",/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPIL_PMP","09","Peso Med Proj","Peso Medio Projetado       ",, "GET","@E 999,999,999.99",/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPIL_PPL","10","Peso Proj Lot","Peso Projetado do Lote     ",, "GET","@E 999,999,999.99",/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPIL_DCC","11","Dias de Cocho","Dias de Cocho              ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPIL_GMD","12","GMD Esperado" ,"GMD Esperado               ",, "GET","@E 999,999,999.99",/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPIL_DCE","13","DC Esperado  ","DC Esperado                ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPIL_PVF","14","PVF Esperado ","PVF Esperado               ",, "GET","@E 999,999,999.99",/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPIL_ABE","15","Abate Estim. ","Abate Estimado             ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPIL_RDE","16","REND Esper(%)","REND Esperado(%)           ",, "GET","@E 999.99",/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPIL_QUA","17","Quant.Anim.UA","Quantidade de animais em UA",, "GET","@E 999.99",/*bpict*/,/*F3*/,.F.,,,,,,,, )
	//oStruRet:AddField("TMPIL_LUA","17","Lotacao UA   ","Lotacao por UA             ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPIL_PLN","18","Plano Nutric.","Plano Nutricional          ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPIL_RCL","19","Raca Lote    ","Raca do Lote               ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPIL_SXL","20","Sexo Lote    ","Sexo do Lote               ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	//:AddField(<cIdField >, <cOrdem >, <cTitulo >, <cDescric >, <aHelp >, <cType >, <cPicture >, <bPictVar >, <cLookUp >, <lCanChange >, <cFolder >, <cGroup >, [ aComboValues ], [ nMaxLenCombo ], <cIniBrow >, <lVirtual >, <cPictVar >, [ lInsertLine ], [ nWidth ])-> NIL 

EndIf

Return (oStruRet)


//Static Function getStrAbt(nOpr)
//Local oStruRet
//
//If (nOpr == 1)
//
//	oStruRet := FWFormModelStruct():New()
// 
//	oStruRet:AddField("Data do Abate","Data do Abate              ", "TMPAB_DTA", "D", 08, 0, , , {}, .F., , .F., .F., .F., , )
//	oStruRet:AddField("Dias Confin. ","Dias de Confinamento       ", "TMPAB_DCF", "N", 04, 0, , , {}, .F., , .F., .F., .F., , )
//	oStruRet:AddField("P.V. Inicial ","P.V. Inicial               ", "TMPAB_PVI", "N", 14, 2, , , {}, .F., , .F., .F., .F., , )
//	oStruRet:AddField("P.V. Final   ","P.V. Final                 ", "TMPAB_PVF", "N", 14, 2, , , {}, .F., , .F., .F., .F., , )
//	oStruRet:AddField("Med.P.V. Fin.","Media P.V. Final           ", "TMPAB_MPV", "N", 14, 2, , , {}, .F., , .F., .F., .F., , )
//	oStruRet:AddField("Peso Banda A ","Peso da Banda A            ", "TMPAB_PBA", "N", 08, 2, , , {}, .F., , .F., .F., .F., , )
//	oStruRet:AddField("Peso Banda B ","Peso da Banda B            ", "TMPAB_PBB", "N", 08, 2, , , {}, .F., , .F., .F., .F., , )
//	oStruRet:AddField("Total Carcaca","Total Carcaca              ", "TMPAB_TCR", "N", 14, 2, , , {}, .F., , .F., .F., .F., , )
//	oStruRet:AddField("Tipificacao  ","Tipificacao                ", "TMPAB_TIP", "C", 10, 0, , , {}, .F., , .F., .F., .F., , )
//	oStruRet:AddField("GMD Carcaca  ","GMD Carcaca                ", "TMPAB_GMD", "N", 14, 2, , , {}, .F., , .F., .F., .F., , )
//	oStruRet:AddField("Especie      ","Especie                    ", "TMPAB_ESP", "C", 10, 0, , , {}, .F., , .F., .F., .F., , )
//	oStruRet:AddField("Raca         ","Raca                       ", "TMPAB_RAC", "C", 10, 0, , , {}, .F., , .F., .F., .F., , )
//	oStruRet:AddField("Sexo         ","Sexo                       ", "TMPAB_SEX", "C", 05, 0, , , {}, .F., , .F., .F., .F., , )
//	oStruRet:AddField("Era          ","Era                        ", "TMPAB_ERA", "C", 10, 0, , , {}, .F., , .F., .F., .F., , )
//	//:AddField(<cTitulo>,<cTooltip>,<cIdField>,<cTipo>,<nTamanho>,[nDecimal],[bValid],[bWhen],[aValues],[lObrigat],[bInit],<lKey>,[lNoUpd],[lVirtual],[cValid])-> NIL
// 
//ElseIf (nOpr == 2)
//
//	oStruRet := FWFormViewStruct():New()
//	
//	oStruRet:AddField("TMPAB_DTA","01","Data do Abate","Data do Abate              ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.T.,,,,,,,, )
//	oStruRet:AddField("TMPAB_DCF","02","Dias Confin. ","Dias de Confinamento       ",, "GET","@E 9999",/*bpict*/,/*F3*/,.T.,,,,,,,, )
//	oStruRet:AddField("TMPAB_PVI","03","P.V. Inicial ","P.V. Inicial               ",, "GET","@E 999,999,999.99",/*bpict*/,/*F3*/,.T.,,,,,,,, )
//	oStruRet:AddField("TMPAB_PVF","04","P.V. Final   ","P.V. Final                 ",, "GET","@E 999,999,999.99",/*bpict*/,/*F3*/,.T.,,,,,,,, )
//	oStruRet:AddField("TMPAB_MPV","05","Med.P.V. Fin.","Media P.V. Final           ",, "GET","@E 999,999,999.99",/*bpict*/,/*F3*/,.T.,,,,,,,, )
//	oStruRet:AddField("TMPAB_PBA","06","Peso Banda A ","Peso da Banda A            ",, "GET","@E 999.99",/*bpict*/,/*F3*/,.T.,,,,,,,, )
//	oStruRet:AddField("TMPAB_PBB","07","Peso Banda B ","Peso da Banda B            ",, "GET","@E 999.99",/*bpict*/,/*F3*/,.T.,,,,,,,, )
//	oStruRet:AddField("TMPAB_TCR","08","Total Carcaca","Total Carcaca              ",, "GET","@E 999,999,999.99",/*bpict*/,/*F3*/,.T.,,,,,,,, )
//	oStruRet:AddField("TMPAB_TIP","09","Tipificacao  ","Tipificacao                ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.T.,,,,,,,, )
//	oStruRet:AddField("TMPAB_GMD","10","GMD Carcaca  ","GMD Carcaca                ",, "GET","@E 999,999,999.99",/*bpict*/,/*F3*/,.T.,,,,,,,, )
//	oStruRet:AddField("TMPAB_ESP","11","Especie      ","Especie                    ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.T.,,,,,,,, )
//	oStruRet:AddField("TMPAB_RAC","12","Raca         ","Raca                       ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.T.,,,,,,,, )
//	oStruRet:AddField("TMPAB_SEX","13","Sexo         ","Sexo                       ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.T.,,,,,,,, )
//	oStruRet:AddField("TMPAB_ERA","14","Era          ","Era                        ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.T.,,,,,,,, )
//	//:AddField(<cIdField >, <cOrdem >, <cTitulo >, <cDescric >, <aHelp >, <cType >, <cPicture >, <bPictVar >, <cLookUp >, <lCanChange >, <cFolder >, <cGroup >, [ aComboValues ], [ nMaxLenCombo ], <cIniBrow >, <lVirtual >, <cPictVar >, [ lInsertLine ], [ nWidth ])-> NIL 
//
//EndIf
//
//Return (oStruRet)


Static Function getStrArq(nOpr)
Local oStruRet

If (nOpr == 1)

	oStruRet := FWFormModelStruct():New()

	oStruRet:AddField("Arquivo      ","Arquivo                    ", "TMPAQ_ARQ", "C" , 200, 0, , , {}, .F., , .F., .F., .F., , )
	//oStruRet:AddField("Preco Arroba ","Preco por Arroba           ", "TMPAQ_VLA", "N" , 06, 2, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Buscar       ","Buscar                     ", "TMPAQ_BTS", "BT", 01, 0, { |oMdl| getArq(), .T. }, , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Processar    ","Processar                  ", "TMPAQ_BTP", "BT", 01, 0, { |oMdl| ImpArq(), .T. }, , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Excluir Imp. ","Excluir Importacao         ", "TMPAQ_BTE", "BT", 01, 0, { |oMdl| ExcArq(), .T. }, , {}, .F., , .F., .F., .F., , )
	//:AddField(<cTitulo>,<cTooltip>,<cIdField>,<cTipo>,<nTamanho>,[nDecimal],[bValid],[bWhen],[aValues],[lObrigat],[bInit],<lKey>,[lNoUpd],[lVirtual],[cValid])-> NIL

ElseIf (nOpr == 2)

	oStruRet := FWFormViewStruct():New()
	
	oStruRet:AddField("TMPAQ_ARQ","01","Arquivo      ","Arquivo                    ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	//oStruRet:AddField("TMPAQ_VLA","02","Preco Arroba ","Preco por Arroba           ",, "GET","999.99",/*bpict*/,/*F3*/,.T.,,,,,,,, )
	oStruRet:AddField("TMPAQ_BTS","02","Buscar       ","Buscar                     ",, "BT" ,/*pict*/,/*bpict*/,/*F3*/,.T.,,,,,,,, )
	oStruRet:AddField("TMPAQ_BTP","03","Processar    ","Processar                  ",, "BT" ,/*pict*/,/*bpict*/,/*F3*/,.T.,,,,,,,, )
	oStruRet:AddField("TMPAQ_BTE","04","Excluir Imp. ","Excluir Importacao         ",, "BT" ,/*pict*/,/*bpict*/,/*F3*/,.T.,,,,,,,, )
	//:AddField(<cIdField >, <cOrdem >, <cTitulo >, <cDescric >, <aHelp >, <cType >, <cPicture >, <bPictVar >, <cLookUp >, <lCanChange >, <cFolder >, <cGroup >, [ aComboValues ], [ nMaxLenCombo ], <cIniBrow >, <lVirtual >, <cPictVar >, [ lInsertLine ], [ nWidth ])-> NIL

EndIf

Return (oStruRet)


//Static Function getStrAqH(nOpr)
//Local oStruRet 
//
//If (nOpr == 1)
//
//	oStruRet := FWFormModelStruct():New()
//	
//	oStruRet:AddField("Data Import. ","Data Importacao            ", "TMPAH_DTI", "D", 08, 0, , , {}, .F., , .F., .F., .F., , )
//	oStruRet:AddField("Arquivo      ","Arquivo                    ", "TMPAH_ARQ", "C", 50, 0, , , {}, .F., , .F., .F., .F., , )
//	//:AddField(<cTitulo>,<cTooltip>,<cIdField>,<cTipo>,<nTamanho>,[nDecimal],[bValid],[bWhen],[aValues],[lObrigat],[bInit],<lKey>,[lNoUpd],[lVirtual],[cValid])-> NIL
//
//ElseIf (nOpr == 2)
//
//	oStruRet := FWFormViewStruct():New()
//	
//	oStruRet:AddField("TMPAH_DTI","01","Data Import. ","Data Importacao            ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.T.,,,,,,,, )
//	oStruRet:AddField("TMPAH_ARQ","02","Arquivo      ","Arquivo                    ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
//	//:AddField(<cIdField >, <cOrdem >, <cTitulo >, <cDescric >, <aHelp >, <cType >, <cPicture >, <bPictVar >, <cLookUp >, <lCanChange >, <cFolder >, <cGroup >, [ aComboValues ], [ nMaxLenCombo ], <cIniBrow >, <lVirtual >, <cPictVar >, [ lInsertLine ], [ nWidth ])-> NIL
//
//EndIf
//
//Return (oStruRet)


Static Function getStrAnm(nOpr)
Local oStruRet 

If (nOpr == 1)

	oStruRet := FWFormModelStruct():New()

	oStruRet:AddField("ID           ","ID                         ", "TMPAN_ID" , "C", 08, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Lote Compra  ","Lote de Compra             ", "TMPAN_LOT", "C", 15, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Pedido       ","Pedido                     ", "TMPAN_PED", "C", 06, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("N Manejo     ","N Manejo                   ", "TMPAN_MNJ", "C", 50, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("SISBOV       ","SISBOV                     ", "TMPAN_SBV", "C", 50, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("RFID         ","RFID                       ", "TMPAN_RFI", "C", 50, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Raca         ","Raca                       ", "TMPAN_RAC", "C", 10, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Sexo         ","Sexo                       ", "TMPAN_SEX", "C", 05, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Peso         ","Peso                       ", "TMPAN_PES", "N", 08, 2, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Fornecedor   ","Fornecedor                 ", "TMPAN_FOR", "C", 60, 0, , , {}, .F., , .F., .F., .F., , )
	//:AddField(<cTitulo>,<cTooltip>,<cIdField>,<cTipo>,<nTamanho>,[nDecimal],[bValid],[bWhen],[aValues],[lObrigat],[bInit],<lKey>,[lNoUpd],[lVirtual],[cValid])-> NIL

ElseIf (nOpr == 2)

	oStruRet := FWFormViewStruct():New()
	
	oStruRet:AddField("TMPAN_ID" ,"01","ID           ","ID                         ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPAN_LOT","02","Lote Compra  ","Lote de Compra             ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPAN_PED","03","Pedido       ","Pedido                     ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPAN_MNJ","04","N Manejo     ","N Manejo                   ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPAN_SBV","05","SISBOV       ","SISBOV                     ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPAN_RFI","06","RFID         ","RFID                       ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPAN_SEX","07","Sexo         ","Sexo                       ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPAN_RAC","08","Raca         ","Raca                       ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPAN_PES","09","Peso         ","Peso                       ",, "GET","@E 999.99",/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPAN_FOR","10","Fornecedor   ","Fornecedor                 ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	//:AddField(<cIdField >, <cOrdem >, <cTitulo >, <cDescric >, <aHelp >, <cType >, <cPicture >, <bPictVar >, <cLookUp >, <lCanChange >, <cFolder >, <cGroup >, [ aComboValues ], [ nMaxLenCombo ], <cIniBrow >, <lVirtual >, <cPictVar >, [ lInsertLine ], [ nWidth ])-> NIL

EndIf

Return (oStruRet)

/*Arthur Toshio - */
Static Function getStrDen(nOpr)
Local oStruRet 

If (nOpr == 1)

	oStruRet := FWFormModelStruct():New()

	oStruRet:AddField("Dentição          ","Dentição                 ", "TDDEN_ID" , "C", 08, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Qtde Animais      ","Qtde Animais             ", "TDDEN_QTD", "N", 02, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Peso Médio        ","Peso Médio               ", "TDDEN_PES", "N", 06, 2, , , {}, .F., , .F., .F., .F., , )
	
	//:AddField(<cTitulo>,<cTooltip>,<cIdField>,<cTipo>,<nTamanho>,[nDecimal],[bValid],[bWhen],[aValues],[lObrigat],[bInit],<lKey>,[lNoUpd],[lVirtual],[cValid])-> NIL

ElseIf (nOpr == 2)

	oStruRet := FWFormViewStruct():New()
	
	oStruRet:AddField("TDDEN_ID" ,"01","Dentição     ","Dentição                   ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TDDEN_QTD","02","Qtde Animais ","Qtde Animais               ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TDDEN_PES","03","Peso Médio   ","Peso Médio                 ",, "GET","@E 999.99",/*bpict*/,/*F3*/,.F.,,,,,,,, )
	
	//:AddField(<cIdField >, <cOrdem >, <cTitulo >, <cDescric >, <aHelp >, <cType >, <cPicture >, <bPictVar >, <cLookUp >, <lCanChange >, <cFolder >, <cGroup >, [ aComboValues ], [ nMaxLenCombo ], <cIniBrow >, <lVirtual >, <cPictVar >, [ lInsertLine ], [ nWidth ])-> NIL

EndIf

Return (oStruRet)

Static Function getStrRes(nOpr)
Local oStruRet 

If (nOpr == 1)

	oStruRet := FWFormModelStruct():New()

	oStruRet:AddField("Lote Compra  ","Lote de Compra             ", "TMPRS_LOT", "C", 15, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Raca         ","Raca                       ", "TMPRS_RAC", "C", 10, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Sexo         ","Sexo                       ", "TMPRS_SEX", "C", 05, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Era          ","Era                        ", "TMPRS_ERA", "C", 10, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Data Entrada ","Data de Entrada            ", "TMPRS_DTE", "D", 08, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Data Saida   ","Data de Saida              ", "TMPRS_DTS", "D", 08, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Cabecas      ","Quantidade de Cabecas      ", "TMPRS_CAB", "N", 10, 0, , , {}, .F., , .F., .F., .F., , )	
	oStruRet:AddField("Dias de Cocho","Dias de Cocho              ", "TMPRS_DCC", "N", 04, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Peso Medio   ","Peso Medio                 ", "TMPRS_PES", "N", 14, 2, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Peso Med Proj","Peso Medio Projetado       ", "TMPRS_PMP", "N", 14, 2, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Peso Lote    ","Peso do Lote               ", "TMPRS_PLT", "N", 14, 2, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Peso Proj Lot","Peso Projetado do Lote     ", "TMPRS_PPL", "N", 14, 2, , , {}, .F., , .F., .F., .F., , )
	//:AddField(<cTitulo>,<cTooltip>,<cIdField>,<cTipo>,<nTamanho>,[nDecimal],[bValid],[bWhen],[aValues],[lObrigat],[bInit],<lKey>,[lNoUpd],[lVirtual],[cValid])-> NIL

ElseIf (nOpr == 2)

	oStruRet := FWFormViewStruct():New()
	
	oStruRet:AddField("TMPRS_LOT","01","Lote Compra  ","Lote de Compra             ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPRS_RAC","02","Raca         ","Raca                       ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPRS_SEX","03","Sexo         ","Sexo                       ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPRS_ERA","04","Era          ","Era                        ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPRS_DTE","05","Data Entrada ","Data de Entrada            ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPRS_DTS","06","Data Saida   ","Data de Saida              ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPRS_CAB","07","Cabecas      ","Quantidade de Cabecas      ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPRS_DCC","08","Dias de Cocho","Dias de Cocho              ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPRS_PES","09","Peso Medio   ","Peso Medio                 ",, "GET","@E 999,999,999.99",/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPRS_PMP","10","Peso Med Proj","Peso Medio Projetado       ",, "GET","@E 999,999,999.99",/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPRS_PLT","11","Peso Lote    ","Peso do Lote               ",, "GET","@E 999,999,999.99",/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPRS_PPL","12","Peso Proj Lot","Peso Projetado do Lote     ",, "GET","@E 999,999,999.99",/*bpict*/,/*F3*/,.F.,,,,,,,, )
	//:AddField(<cIdField >, <cOrdem >, <cTitulo >, <cDescric >, <aHelp >, <cType >, <cPicture >, <bPictVar >, <cLookUp >, <lCanChange >, <cFolder >, <cGroup >, [ aComboValues ], [ nMaxLenCombo ], <cIniBrow >, <lVirtual >, <cPictVar >, [ lInsertLine ], [ nWidth ])-> NIL

EndIf

Return (oStruRet)


Static Function getStrSld(nOpr)
Local oStruRet 

If (nOpr == 1)

	oStruRet := FWFormModelStruct():New()

	oStruRet:AddField("Raca         ","Raca                       ", "TMPSL_RAC", "C", 10, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Sexo         ","Sexo                       ", "TMPSL_SEX", "C", 05, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Era          ","Era                        ", "TMPSL_ERA", "C", 10, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Cabecas      ","Quantidade de Cabecas      ", "TMPSL_CAB", "N", 10, 0, , , {}, .F., , .F., .F., .F., , )	
	oStruRet:AddField("Peso Inicial ","Peso Inicial               ", "TMPSL_PSI", "N", 14, 2, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Peso Projetad","Peso Projetado             ", "TMPSL_PSP", "N", 14, 2, , , {}, .F., , .F., .F., .F., , )
	//:AddField(<cTitulo>,<cTooltip>,<cIdField>,<cTipo>,<nTamanho>,[nDecimal],[bValid],[bWhen],[aValues],[lObrigat],[bInit],<lKey>,[lNoUpd],[lVirtual],[cValid])-> NIL

ElseIf (nOpr == 2)

	oStruRet := FWFormViewStruct():New()
	
	oStruRet:AddField("TMPSL_RAC","01","Raca         ","Raca                       ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPSL_SEX","02","Sexo         ","Sexo                       ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPSL_ERA","03","Era          ","Era                        ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPSL_CAB","04","Cabecas      ","Quantidade de Cabecas      ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPSL_PSI","05","Peso Inicial ","Peso Inicial               ",, "GET","@E 999,999,999.99",/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPSL_PSP","06","Peso Projetad","Peso Projetado             ",, "GET","@E 999,999,999.99",/*bpict*/,/*F3*/,.F.,,,,,,,, )
	//:AddField(<cIdField >, <cOrdem >, <cTitulo >, <cDescric >, <aHelp >, <cType >, <cPicture >, <bPictVar >, <cLookUp >, <lCanChange >, <cFolder >, <cGroup >, [ aComboValues ], [ nMaxLenCombo ], <cIniBrow >, <lVirtual >, <cPictVar >, [ lInsertLine ], [ nWidth ])-> NIL

EndIf

Return (oStruRet)


Static Function getStrANE(nOpr)
Local oStruRet

If (nOpr == 1)

	oStruRet := FWFormModelStruct():New()

	oStruRet:AddField("Visualizar Nota Fiscal Entrada","Visualizar Nota Fiscal     ", "TMPAE_BTN", "BT", 01, 0, { || VIWNF(1), .T. }, , {}, .F., , .F., .F., .F., , )
	//oStruRet:AddField("Nota Fiscal  ","Nota Fiscal                ", "TMPAE_NNE", "C" , 16, 0, , , {}, .F., , .F., .F., .F., , )
	//:AddField(<cTitulo>,<cTooltip>,<cIdField>,<cTipo>,<nTamanho>,[nDecimal],[bValid],[bWhen],[aValues],[lObrigat],[bInit],<lKey>,[lNoUpd],[lVirtual],[cValid])-> NIL

ElseIf (nOpr == 2)

	oStruRet := FWFormViewStruct():New()
		
	oStruRet:AddField("TMPAE_BTN","01","Visualizar Nota Fiscal Entrada","Visualizar Nota Fiscal     ",, "BT" ,/*pict*/,/*bpict*/,/*F3*/,.T.,,,,,,,, )
	//oStruRet:AddField("TMPAE_NNE","02","Nota Fiscal  ","Nota Fiscal                ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	//:AddField(<cIdField >, <cOrdem >, <cTitulo >, <cDescric >, <aHelp >, <cType >, <cPicture >, <bPictVar >, <cLookUp >, <lCanChange >, <cFolder >, <cGroup >, [ aComboValues ], [ nMaxLenCombo ], <cIniBrow >, <lVirtual >, <cPictVar >, [ lInsertLine ], [ nWidth ])-> NIL

EndIf

Return (oStruRet)

Static Function getStrANS(nOpr)
Local oStruRet

If (nOpr == 1)

	oStruRet := FWFormModelStruct():New()

	oStruRet:AddField("Visualizar Nota Fiscal Saida","Visualizar Nota Fiscal     ", "TMPAE_BTN", "BT", 01, 0, { || VIWNF(2), .T. }, , {}, .F., , .F., .F., .F., , )
	//oStruRet:AddField("Nota Fiscal  ","Nota Fiscal                ", "TMPAE_NNS", "C" , 16, 0, , , {}, .F., , .F., .F., .F., , )
	//:AddField(<cTitulo>,<cTooltip>,<cIdField>,<cTipo>,<nTamanho>,[nDecimal],[bValid],[bWhen],[aValues],[lObrigat],[bInit],<lKey>,[lNoUpd],[lVirtual],[cValid])-> NIL

ElseIf (nOpr == 2)

	oStruRet := FWFormViewStruct():New()
	
	oStruRet:AddField("TMPAE_BTN","01","Visualizar Nota Fiscal Saida","Visualizar Nota Fiscal     ",, "BT" ,/*pict*/,/*bpict*/,/*F3*/,.T.,,,,,,,, )
	//oStruRet:AddField("TMPAE_NNS","02","Nota Fiscal  ","Nota Fiscal                ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	//:AddField(<cIdField >, <cOrdem >, <cTitulo >, <cDescric >, <aHelp >, <cType >, <cPicture >, <bPictVar >, <cLookUp >, <lCanChange >, <cFolder >, <cGroup >, [ aComboValues ], [ nMaxLenCombo ], <cIniBrow >, <lVirtual >, <cPictVar >, [ lInsertLine ], [ nWidth ])-> NIL

EndIf

Return (oStruRet)


Static Function getStrNFE(nOpr)
Local oStruRet 

If (nOpr == 1)

	oStruRet := FWFormModelStruct():New()
	//oStruRet:AddField("NF           ","Visualizar Nota Fiscal     ", "TMPNE_VNF","BT", 01, 0, , , {}, .F., , .F., .F., .F., , ) //{ |oMdl| getArq(oMdl), .T. }
	oStruRet:AddField("Numero NF    ","Numero Nota Fiscal         ", "TMPNE_NUM", "C", 15, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Serie NF     ","Serie Nota Fiscal          ", "TMPNE_SER", "C", 03, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Cod.Forneced.","Codigo do Fornecedor       ", "TMPNE_FOR", "C", 20, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Nome Fornece.","Nome do Fornecedor         ", "TMPNE_NFR", "C", 50, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Cod.Produto  ","Codigo do Produto          ", "TMPNE_COD", "C", 30, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Desc.Produto ","Descricao do Produto       ", "TMPNE_DPR", "C", 50, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Quantidade   ","Quantiade                  ", "TMPNE_QTD", "N", 06, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Valor Unit.  ","Valor Unitario             ", "TMPNE_VUN", "N", 14, 2, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Valor Total  ","Valor Total                ", "TMPNE_VTT", "N", 14, 2, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Data Emissao ","Data Emissao               ", "TMPNE_DNF", "D", 08, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Data Embarque","Data Embarque              ", "TMPNE_DEM", "D", 08, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Hora Embarque","Hora Embarque              ", "TMPNE_HEM", "C", 05, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Data Chegada ","Data Chegada               ", "TMPNE_DCH", "D", 08, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Hora Chegada ","Hora Chegada               ", "TMPNE_HCH", "C", 05, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Peso Chegada ","Peso Chegada               ", "TMPNE_PCH", "N", 15, 3, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("KM Rodado    ","KM Rodado                  ", "TMPNE_KMR", "N", 06, 0, , , {}, .F., , .F., .F., .F., , )
	//:AddField(<cTitulo>,<cTooltip>,<cIdField>,<cTipo>,<nTamanho>,[nDecimal],[bValid],[bWhen],[aValues],[lObrigat],[bInit],<lKey>,[lNoUpd],[lVirtual],[cValid])-> NIL

ElseIf (nOpr == 2)

	oStruRet := FWFormViewStruct():New()
	//oStruRet:AddField("TMPNE_VNF","01","NF           ","Visualizar Nota Fiscal     ",, "BT" ,/*pict*/,/*bpict*/,/*F3*/,.T.,,,,,,,, )
	oStruRet:AddField("TMPNE_NUM","01","Numero NF    ","Numero Nota Fiscal         ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPNE_SER","02","Serie NF     ","Serie Nota Fiscal          ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPNE_FOR","03","Cod.Forneced.","Codigo do Fornecedor       ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPNE_NFR","04","Nome Fornece.","Nome do Fornecedor         ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPNE_COD","05","Cod.Produto  ","Codigo do Produto          ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPNE_DPR","06","Desc.Produto ","Descricao do Produto       ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPNE_QTD","07","Quantidade   ","Quantiade                  ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPNE_VUN","08","Valor Unit.  ","Valor Unitario             ",, "GET","@E 999,999,999.99",/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPNE_VTT","09","Valor Total  ","Valor Total                ",, "GET","@E 999,999,999.99",/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPNE_DNF","10","Data Emissao ","Data Emissao               ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPNE_DEM","11","Data Embarque","Data Embarque              ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPNE_HEM","12","Hora Embarque","Hora Embarque              ",, "GET","@99:99",/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPNE_DCH","13","Data Chegada ","Data Chegada               ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPNE_HCH","14","Hora Chegada ","Hora Chegada               ",, "GET","@99:99",/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPNE_PCH","15","Peso Chegada ","Peso Chegada               ",, "GET","@E 999,999,999.999",/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPNE_KMR","16","KM Rodado    ","KM Rodado                  ",, "GET","@E 99,999",/*bpict*/,/*F3*/,.F.,,,,,,,, )	
	//:AddField(<cIdField >, <cOrdem >, <cTitulo >, <cDescric >, <aHelp >, <cType >, <cPicture >, <bPictVar >, <cLookUp >, <lCanChange >, <cFolder >, <cGroup >, [ aComboValues ], [ nMaxLenCombo ], <cIniBrow >, <lVirtual >, <cPictVar >, [ lInsertLine ], [ nWidth ])-> NIL

EndIf

Return (oStruRet)


Static Function getStrNFS(nOpr)
Local oStruRet 

If (nOpr == 1)

	oStruRet := FWFormModelStruct():New()

	oStruRet:AddField("Numero NF    ","Numero Nota Fiscal         ", "TMPNS_NUM", "C", 15, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Serie NF     ","Serie Nota Fiscal          ", "TMPNS_SER", "C", 03, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Cod.Cliente  ","Codigo do Cliente          ", "TMPNS_CLI", "C", 20, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Nome Cliente ","Nome do Cliente            ", "TMPNS_NCL", "C", 50, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Cod.Produto  ","Codigo do Produto          ", "TMPNS_COD", "C", 30, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Desc.Produto ","Descricao do Produto       ", "TMPNS_DPR", "C", 50, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Quantidade   ","Quantiade                  ", "TMPNS_QTD", "N", 06, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Valor Unit.  ","Valor Unitario             ", "TMPNS_VUN", "N", 14, 2, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Valor Total  ","Valor Total                ", "TMPNS_VTT", "N", 14, 2, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Data Emissao ","Data Emissao               ", "TMPNS_DNF", "D", 08, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Num. Pesagem ","Num. Pesagem               ", "TMPNS_NRP", "C", 12, 0, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Peso Liquido ","Peso Liquido               ", "TMPNS_PLQ", "N", 09, 2, , , {}, .F., , .F., .F., .F., , )
	oStruRet:AddField("Data Abate   ","Data Abate                 ", "TMPNS_DAB", "D", 08, 0, , , {}, .F., , .F., .F., .F., , )
	//:AddField(<cTitulo>,<cTooltip>,<cIdField>,<cTipo>,<nTamanho>,[nDecimal],[bValid],[bWhen],[aValues],[lObrigat],[bInit],<lKey>,[lNoUpd],[lVirtual],[cValid])-> NIL

ElseIf (nOpr == 2)

	oStruRet := FWFormViewStruct():New()
	
	oStruRet:AddField("TMPNS_NUM","01","Numero NF    ","Numero Nota Fiscal         ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPNS_SER","02","Serie NF     ","Serie Nota Fiscal          ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPNS_CLI","03","Cod.Cliente  ","Codigo do Cliente          ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPNS_NCL","04","Nome Cliente ","Nome do Cliente            ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPNS_COD","05","Cod.Produto  ","Codigo do Produto          ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPNS_DPR","06","Desc.Produto ","Descricao do Produto       ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPNS_QTD","07","Quantidade   ","Quantiade                  ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPNS_VUN","08","Valor Unit.  ","Valor Unitario             ",, "GET","@E 999,999,999.99",/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPNS_VTT","09","Valor Total  ","Valor Total                ",, "GET","@E 999,999,999.99",/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPNS_DNF","10","Data Emissao ","Data Emissao               ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPNS_NRP","11","Num. Pesagem ","Num. Pesagem               ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPNS_PLQ","12","Peso Liquido ","Peso Liquido               ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	oStruRet:AddField("TMPNS_DAB","13","Data Abate   ","Data Abate                 ",, "GET",/*pict*/,/*bpict*/,/*F3*/,.F.,,,,,,,, )
	//:AddField(<cIdField >, <cOrdem >, <cTitulo >, <cDescric >, <aHelp >, <cType >, <cPicture >, <bPictVar >, <cLookUp >, <lCanChange >, <cFolder >, <cGroup >, [ aComboValues ], [ nMaxLenCombo ], <cIniBrow >, <lVirtual >, <cPictVar >, [ lInsertLine ], [ nWidth ])-> NIL

EndIf

Return (oStruRet)


Static Function getArq(oMdl)

Local cArq := cGetFile("*.txt", "Textos (TXT)", 0, "C:\", .T.,,.T., .T.)
Local oMdlAt  := FWModelActive()
Local oViwAt  := FWViewActive()

	If !(Empty(cArq))
		oMdlAt:GetModel("MASTERARQ"):LoadValue("TMPAQ_ARQ", cArq)
		oViwAt:Refresh("VWARQ")
	EndIf
	
Return (.T.)


Static Function ImpArq(oMdl)

Local lRet := .T.

FWMsgRun(,{|| lRet := ProcArq()}, "Processando", "Processando arquivo de abates...")

Return (lRet)


Static Function ProcArq()

Local aArea   := GetArea()
Local aClsArq := {}
Local cPthArq := ""
Local nPthArq := 0
Local nCntALn := 0
Local cLinPtA := ""
Local cLinPtB := ""
Local cLin    := ""
Local lVldImp := .T.
Local oMdlAt  := FWModelActive()
Local oViwAt  := FWViewActive()
Local nLinAux := 0
Local nLinCbc := 0
Local lIniDad := .F. //auxilia em encontrar a linha onde comecam os dados dos animais
Local nQtdAbt := 0
Local nQtdGrx := 0
Local dDatAbt := 0
Local cHorAbt := ""
Local aAbTmp  := {}
Local nLinTmp := 0
Local nPesTot := 0
Local oVwTmp

Private aRotZAB   := {}
Private cCadastro := "Cadastro de Animais Abatidos"
Private cPerg     := "VAFTCAD1"

cPthArq := oMdlAt:GetModel("MASTERARQ"):GetValue("TMPAQ_ARQ")

nPthArq	:= FOpen(cPthArq, 0)

If (nPthArq == -1)

	MsgStop("Nao foi selecionado nenhum arquivo, ou o arquivo e invalido")
	
Else

	If (!Empty(oMdlAt:GetValue("GRIDHISABA","Z0P_ARQUIV")))
		oViwAt:GetModel("GRIDHISABA"):AddLine()
		oViwAt:Refresh("VWHISABA")
	EndIf

	DBSelectArea("Z0Q")
	Z0Q->(DBSetOrder(1))

	nQtdLin := MLCount(Memoread(cPthArq), 80)
	FT_FUse(cPthArq)
	FT_FGoTop()
	
	For nCntALn := 1 To nQtdLin

		cLin := FT_FREADLN()

		If (SUBSTR(cLin, 1, 10) == Replicate("-", 10))

			lIniDad := .T.
			FT_FSKIP()
			
			cLin := FT_FREADLN()

		EndIf
		
		If !(lIniDad)
		
			aAbTmp := StrToKArr(cLin, " ")
			
			For nLinTmp := 1 To Len(aAbTmp) 
			
				If (aAbTmp[nLinTmp] == "QUANTIDADE:")
					nQtdAbt := aAbTmp[nLinTmp+1]
				ElseIf (aAbTmp[nLinTmp] == "DATA:")
					dDatAbt := CTOD(aAbTmp[nLinTmp+1])
				ElseIf (aAbTmp[nLinTmp] == "HORA:")
					cHorAbt := aAbTmp[nLinTmp+1]
				EndIf
			
			Next nLinTmp
		
		Else
			
			cLinPtA := SUBSTR(cLin, 01, 39)
			cLinPtB := SUBSTR(cLin, 40, 79)
					
		EndIf

		If (SUBSTR(cLin, 1, 10) == Replicate("-", 10))

			lIniDad := .F.
			FT_FSKIP()
			
			Loop

		EndIf

		aAbTmp := StrToKArr(cLinPtA, " ")
		
		If ((Len(aAbTmp) > 0) .AND. ((Len(aAbTmp) == 7) .OR. (Len(aAbTmp) == 8)) .AND. (VALTYPE(VAL(aAbTmp[1])) == "N"))
			
			nLinAux := oMdlAt:GetModel("GRIDABATE"):AddLine()			
			
			//oMdlAt:GetModel("GRIDABATE"):SetValue("Z0Q_ITEM", STR(nCntALn, 3))
			oMdlAt:GetModel("GRIDABATE"):SetValue("Z0Q_DIASCF", 0)
			oMdlAt:GetModel("GRIDABATE"):SetValue("Z0Q_PVINIC", 0)
			oMdlAt:GetModel("GRIDABATE"):SetValue("Z0Q_PVFINA", 0)
			oMdlAt:GetModel("GRIDABATE"):SetValue("Z0Q_MEDPVF", 0)
			oMdlAt:GetModel("GRIDABATE"):SetValue("Z0Q_PESOBA", Val(STRTRAN(aAbTmp[2], ",", ".")))
			oMdlAt:GetModel("GRIDABATE"):SetValue("Z0Q_PESOBB", Val(STRTRAN(aAbTmp[4], ",", ".")))
			oMdlAt:GetModel("GRIDABATE"):SetValue("Z0Q_TOTCRC", Val(STRTRAN(aAbTmp[6], ",", ".")))
			oMdlAt:GetModel("GRIDABATE"):SetValue("Z0Q_TIPIFI", "")
			oMdlAt:GetModel("GRIDABATE"):SetValue("Z0Q_GMDCRC", 0)
			oMdlAt:GetModel("GRIDABATE"):SetValue("Z0Q_ESPECI", "")
			oMdlAt:GetModel("GRIDABATE"):SetValue("Z0Q_RACA"  , "")
			oMdlAt:GetModel("GRIDABATE"):SetValue("Z0Q_SEXO"  , "")
			oMdlAt:GetModel("GRIDABATE"):SetValue("Z0Q_ERA"   , "")
			
			oViwAt:Refresh("VWABATE")
			
			RecLock("Z0Q", .T.)
			
				Z0Q->Z0Q_FILIAL := xFilial("Z0Q")
				Z0Q->Z0Q_LOTE   := (cAliasTMP)->B8_LOTECTL
				Z0Q->Z0Q_SEQUEN := oMdlAt:GetValue("GRIDHISABA","Z0P_SEQUEN")
				Z0Q->Z0Q_ITEM   := oMdlAt:GetValue("GRIDABATE","Z0Q_ITEM")
				Z0Q->Z0Q_DIASCF := oMdlAt:GetValue("GRIDABATE","Z0Q_DIASCF")
				Z0Q->Z0Q_PVINIC := oMdlAt:GetValue("GRIDABATE","Z0Q_PVINIC")
				Z0Q->Z0Q_PVFINA := oMdlAt:GetValue("GRIDABATE","Z0Q_PVFINA")
				Z0Q->Z0Q_MEDPVF := oMdlAt:GetValue("GRIDABATE","Z0Q_MEDPVF")
				Z0Q->Z0Q_PESOBA := oMdlAt:GetValue("GRIDABATE","Z0Q_PESOBA")
				Z0Q->Z0Q_PESOBB := oMdlAt:GetValue("GRIDABATE","Z0Q_PESOBB")
				Z0Q->Z0Q_TOTCRC := oMdlAt:GetValue("GRIDABATE","Z0Q_TOTCRC")
				Z0Q->Z0Q_TIPIFI := oMdlAt:GetValue("GRIDABATE","Z0Q_TIPIFI")
				Z0Q->Z0Q_GMDCRC := oMdlAt:GetValue("GRIDABATE","Z0Q_GMDCRC")
				Z0Q->Z0Q_ESPECI := oMdlAt:GetValue("GRIDABATE","Z0Q_ESPECI")
				Z0Q->Z0Q_RACA   := oMdlAt:GetValue("GRIDABATE","Z0Q_RACA")
				Z0Q->Z0Q_SEXO   := oMdlAt:GetValue("GRIDABATE","Z0Q_SEXO")
				Z0Q->Z0Q_ERA    := oMdlAt:GetValue("GRIDABATE","Z0Q_ERA")
			
			Z0Q->(MsUnlock())
			
			nPesTot += Val(STRTRAN(aAbTmp[6], ",", "."))
			
			If (Len(aAbTmp) == 8)
				If (aAbTmp[8] == "G")
					nQtdGrx += 1
				EndIf
			EndIf
						
		EndIf
		
		aAbTmp := StrToKArr(cLinPtB, " ")

		If ((Len(aAbTmp) > 0) .AND. ((Len(aAbTmp) == 7) .OR. (Len(aAbTmp) == 8)) .AND. (VALTYPE(VAL(aAbTmp[1])) == "N"))
		
			nLinAux := oViwAt:GetModel("GRIDABATE"):AddLine()
		
			//oMdlAt:GetModel("GRIDABATE"):SetValue("Z0Q_ITEM", STR(nCntALn, 3))
			oMdlAt:GetModel("GRIDABATE"):SetValue("Z0Q_DIASCF", 0)
			oMdlAt:GetModel("GRIDABATE"):SetValue("Z0Q_PVINIC", 0)
			oMdlAt:GetModel("GRIDABATE"):SetValue("Z0Q_PVFINA", 0)
			oMdlAt:GetModel("GRIDABATE"):SetValue("Z0Q_MEDPVF", 0)
			oMdlAt:GetModel("GRIDABATE"):SetValue("Z0Q_PESOBA", Val(STRTRAN(aAbTmp[2], ",", ".")))
			oMdlAt:GetModel("GRIDABATE"):SetValue("Z0Q_PESOBB", Val(STRTRAN(aAbTmp[4], ",", ".")))
			oMdlAt:GetModel("GRIDABATE"):SetValue("Z0Q_TOTCRC", Val(STRTRAN(aAbTmp[6], ",", ".")))
			oMdlAt:GetModel("GRIDABATE"):SetValue("Z0Q_TIPIFI", "")
			oMdlAt:GetModel("GRIDABATE"):SetValue("Z0Q_GMDCRC", 0)
			oMdlAt:GetModel("GRIDABATE"):SetValue("Z0Q_ESPECI", "")
			oMdlAt:GetModel("GRIDABATE"):SetValue("Z0Q_RACA"  , "")
			oMdlAt:GetModel("GRIDABATE"):SetValue("Z0Q_SEXO"  , "")
			oMdlAt:GetModel("GRIDABATE"):SetValue("Z0Q_ERA"   , "")

			oViwAt:Refresh("VWABATE")
			
			RecLock("Z0Q", .T.)
			
				Z0Q->Z0Q_FILIAL := xFilial("Z0Q")
				Z0Q->Z0Q_LOTE   := (cAliasTMP)->B8_LOTECTL
				Z0Q->Z0Q_SEQUEN := oMdlAt:GetValue("GRIDHISABA","Z0P_SEQUEN")
				Z0Q->Z0Q_ITEM   := oMdlAt:GetValue("GRIDABATE","Z0Q_ITEM")
				Z0Q->Z0Q_DIASCF := oMdlAt:GetValue("GRIDABATE","Z0Q_DIASCF")
				Z0Q->Z0Q_PVINIC := oMdlAt:GetValue("GRIDABATE","Z0Q_PVINIC")
				Z0Q->Z0Q_PVFINA := oMdlAt:GetValue("GRIDABATE","Z0Q_PVFINA")
				Z0Q->Z0Q_MEDPVF := oMdlAt:GetValue("GRIDABATE","Z0Q_MEDPVF")
				Z0Q->Z0Q_PESOBA := oMdlAt:GetValue("GRIDABATE","Z0Q_PESOBA")
				Z0Q->Z0Q_PESOBB := oMdlAt:GetValue("GRIDABATE","Z0Q_PESOBB")
				Z0Q->Z0Q_TOTCRC := oMdlAt:GetValue("GRIDABATE","Z0Q_TOTCRC")
				Z0Q->Z0Q_TIPIFI := oMdlAt:GetValue("GRIDABATE","Z0Q_TIPIFI")
				Z0Q->Z0Q_GMDCRC := oMdlAt:GetValue("GRIDABATE","Z0Q_GMDCRC")
				Z0Q->Z0Q_ESPECI := oMdlAt:GetValue("GRIDABATE","Z0Q_ESPECI")
				Z0Q->Z0Q_RACA   := oMdlAt:GetValue("GRIDABATE","Z0Q_RACA")
				Z0Q->Z0Q_SEXO   := oMdlAt:GetValue("GRIDABATE","Z0Q_SEXO")
				Z0Q->Z0Q_ERA    := oMdlAt:GetValue("GRIDABATE","Z0Q_ERA")
			
			Z0Q->(MsUnlock())
			
			nPesTot += Val(STRTRAN(aAbTmp[6], ",", "."))
			
			If (Len(aAbTmp) == 8)
				If (aAbTmp[8] == "G")
					nQtdGrx += 1
				EndIf
			EndIf
			
		EndIf
		
		FT_FSkip()

	Next nCntALn
	
	
	
	DBSelectArea("Z0P")
	Z0P->(DBSetOrder(1))
	
	//oMdlAt:GetModel("GRIDHISABA"):SetValue("Z0P_SEQUEN", "001")
	oMdlAt:GetModel("GRIDHISABA"):SetValue("Z0P_ARQUIV", SUBSTR(cPthArq, rAt("\",cPthArq)+1, Len(cPthArq)))
	oMdlAt:GetModel("GRIDHISABA"):SetValue("Z0P_CONTEU", Memoread(cPthArq))
	oMdlAt:GetModel("GRIDHISABA"):SetValue("Z0P_DATAIM"  , dDataBase)
	oMdlAt:GetModel("GRIDHISABA"):SetValue("Z0P_DTABAT"  , dDatAbt)
	
	If (!Z0P->(DBSeek(xFilial("Z0P")+(cAliasTMP)->B8_LOTECTL+oMdlAt:GetValue("GRIDHISABA","Z0P_SEQUEN"))))
	
		RecLock("Z0P", .T.)
			
			Z0P->Z0P_FILIAL := xFilial("Z0P")
			Z0P->Z0P_LOTE   := (cAliasTMP)->B8_LOTECTL
			Z0P->Z0P_SEQUEN := oMdlAt:GetValue("GRIDHISABA","Z0P_SEQUEN")
			Z0P->Z0P_ARQUIV := oMdlAt:GetValue("GRIDHISABA","Z0P_ARQUIV")
			Z0P->Z0P_CONTEU := oMdlAt:GetValue("GRIDHISABA","Z0P_CONTEU")
			Z0P->Z0P_DATAIM := oMdlAt:GetValue("GRIDHISABA","Z0P_DATAIM")
			Z0P->Z0P_DTABAT := dDatAbt
			
		Z0P->(MsUnlock())
				
	EndIf
	
	FT_FUse()
	FClose(nPthArq)
	
	oMdlAt:GetModel("GRIDHISABA"):GoLine(1)
	oMdlAt:GetModel("GRIDABATE"):GoLine(1)
	
	oViwAt:Refresh()
	
	aRotZAB := {(cAliasTMP)->B8_LOTECTL, dDatAbt, nPesTot, oMdlAt:GetModel("GRIDABATE"):Length(), nQtdGrx}
	
	DBSelectArea("ZAB")
	ZAB->(DBSetOrder(1))

	U_VAFTCAD1()

EndIf

RestArea(aArea)

Return (lVldImp)


Static Function ExcArq(oMdl)

Local lRet := .T.

FWMsgRun(,{|| lRet := ProcExc()}, "Cancelamento", "Cancelando importacao do arquivo de abates...")

Return (lRet)


Static Function ProcExc()

Local aArea   := GetArea()
Local lVldExc := .T.
Local oMdlAt  := FWModelActive()
Local oViwAt  := FWViewActive()

DBSelectArea("Z0P")
Z0P->(DBsetOrder(1))

DBSelectArea("Z0Q")
Z0Q->(DBsetOrder(1))

If (Z0P->(DBSeek(xFilial("Z0P")+(cAliasTMP)->B8_LOTECTL+oMdlAt:GetValue("GRIDHISABA","Z0P_SEQUEN"))))

	RecLock("Z0P", .F.)
	
		Z0P->(DBDelete())
	
	Z0P->(MsUnlock())
	
EndIf

If (Z0Q->(DBSeek(xFilial("Z0Q")+(cAliasTMP)->B8_LOTECTL+oMdlAt:GetValue("GRIDHISABA","Z0P_SEQUEN"))))

	While ((Z0Q->Z0Q_LOTE == (cAliasTMP)->B8_LOTECTL) .AND. (Z0Q->Z0Q_SEQUEN == oMdlAt:GetValue("GRIDHISABA","Z0P_SEQUEN")))

		RecLock("Z0Q", .F.)
		
			Z0Q->(DBDelete())
		
		Z0Q->(MsUnlock())
		
		Z0Q->(DBSkip())
		
	EndDo
	
EndIf

oMdlAt:GetModel("GRIDHISABA"):GoLine(1)
oMdlAt:GetModel("GRIDABATE"):GoLine(1)

oViwAt:Refresh()

Return (lVldExc)


Static Function DadCab(cLote, cCurral)

Local aDadCab := {}
Local cQryCab := ""

//cQryCab := " SELECT SB8.B8_FILIAL, SB8.B8_LOTECTL, SB8.B8_X_CURRA, SUM(SB8.B8_SALDO) AS B8_SALDO, SUM(SB8.B8_DIASCO) AS B8_DIASCO " + CRLF 
//cQryCab += "    ,SUM(SB8.B8_DIASCO) AS B8_DIASCO, AVG(SB8.B8_XRENESP) AS B8_XRENESP, SUM(SB8.B8_XPESTOT) AS B8_XPRESTOT, MIN(SB8.B8_XDATACO) AS B8_XDATACO " + CRLF 
//cQryCab += "    ,SUM(SB8.B8_XPESOCO) AS B8_XPESOCO, SUM(SB8.B8_XPESTOT) AS B8_XPESTOT, (SUM(SB8.B8_XPESTOT)/(CASE WHEN Z08.Z08_UAREF=0 THEN " + STR(GETMV("VA_UAREF")) + " ELSE Z08.Z08_UAREF END)) AS QTDUA, SUM(Z08.Z08_PESPRO) AS PESPRJ " + CRLF 
//cQryCab += " FROM " + RetSqlName("SB8") + " SB8 " + CRLF 
//cQryCab += " JOIN " + RetSqlName("Z08") + " Z08 ON Z08.Z08_CODIGO = SB8.B8_X_CURRA AND Z08.Z08_FILIAL = '" + xFilial("Z08") + "' AND Z08.D_E_L_E_T_ <> '*' " + CRLF 
//cQryCab += " WHERE SB8.B8_FILIAL = '" + xFilial("SB8") + "'" + CRLF 
//cQryCab += "   AND SB8.D_E_L_E_T_ <> '*' " + CRLF 
//cQryCab += "   AND SB8.B8_LOTECTL = '" + cLote + "'" + CRLF 
//cQryCab += " GROUP BY SB8.B8_FILIAL, SB8.B8_LOTECTL, SB8.B8_X_CURRA, Z08.Z08_UAREF " + CRLF 
//cQryCab += " ORDER BY SB8.B8_LOTECTL " + CRLF 

cQryCab := " SELECT SB8.B8_FILIAL " + CRLF
cQryCab += "      , SB8.B8_LOTECTL " + CRLF
cQryCab += "	  , SB8.B8_X_CURRA AS CURRAL " + CRLF
cQryCab += "	  , SB8.B8_XPESOCO AS XPESOCO " + CRLF
cQryCab += "	  , SB8.B8_XDATACO AS XDATACO " + CRLF
cQryCab += "	  , SUM(SB8.B8_SALDO) AS SALDO " + CRLF
//cQryCab += "	  , Z0O_DCESP "
cQryCab += "	  , Z0O_GMD AS GMD " + CRLF
cQryCab += "	  , Z0O.Z0O_DCESP AS DCESP " + CRLF
cQryCab += "	  , Z0O.Z0O_RENESP AS RENESP " + CRLF
cQryCab += "	  , CAST(convert(datetime, getdate(), 103) - convert(datetime, Z0O.Z0O_DATAIN, 103) AS numeric)+1 AS DIAS_COCHO " + CRLF
cQryCab += "	  , SB8.B8_XPESOCO + ((CAST(convert(datetime, getdate(), 103) - convert(datetime, Z0O.Z0O_DATAIN, 103) AS numeric)+1) * Z0O.Z0O_GMD) AS PES_MED_PROJ " + CRLF
cQryCab += "	  , CAST((CONVERT(datetime, Z0O.Z0O_DATAIN, 103) + 1) + Z0O.Z0O_DCESP AS DATE) AS ABAT_ESP " + CRLF
cQryCab += "	  , SB8.B8_XPESOCO * SUM(SB8.B8_SALDO) AS PESO_TOTAL_LOTE " + CRLF
cQryCab += "	  , (SB8.B8_XPESOCO +((CAST(convert(datetime, getdate(), 103) - convert(datetime, min(SB8.B8_XDATACO), 103) AS numeric)+1) * Z0O.Z0O_GMD)) * SUM(SB8.B8_SALDO) AS PESO_ATU_PROJET " + CRLF
cQryCab += "	  , (SB8.B8_XPESOCO*SUM(SB8.B8_SALDO))/450 AS QTDE_AN_UA " + CRLF
cQryCab += "      , SB8.B8_XPESOCO + (Z0O.Z0O_DCESP * Z0O.Z0O_GMD) AS PVF " + CRLF
cQryCab += "      , (SELECT DISTINCT Z0M.Z0M_DESCRI FROM " + RetSqlName("Z0M") + " Z0M WHERE Z0M.Z0M_FILIAL = '" + xFilial("Z0M") + "' AND Z0M.Z0M_CODIGO = Z0O.Z0O_CODPLA AND Z0M.D_E_L_E_T_ = ' ' ) AS PLAN_NUTR " + CRLF
//		-- CRIAR CAMPO NA Z08 PARA AREA DO CURRAL EM M2...
//	       -- AREA / QTDE DE ANIMAIS POR UA
cQryCab += " FROM " + RetSqlName("SB8") + " SB8 " + CRLF
cQryCab += " JOIN " + RetSqlName("Z08") + " Z08 ON Z08_CODIGO = SB8.B8_X_CURRA AND Z08.Z08_FILIAL = '" + xFilial("Z08") + "' AND Z08.D_E_L_E_T_ <> '*' " + CRLF
cQryCab += " LEFT JOIN " + RetSqlName("Z0O") + " Z0O ON Z0O.Z0O_LOTE = SB8.B8_LOTECTL AND Z0O.Z0O_FILIAL = '" + xFilial("Z0O") + "' AND Z0O.D_E_L_E_T_ <> '*' " + CRLF
cQryCab += " WHERE SB8.B8_FILIAL = '" + xFilial("SB8") + "'" + CRLF
cQryCab += "	  AND SB8.D_E_L_E_T_ <> '*' " + CRLF
cQryCab += "	  AND SB8.B8_LOTECTL = '" + cLote + "'" + CRLF
cQryCab += "	  AND SB8.B8_X_CURRA = '" + cCurral + "'" + CRLF
cQryCab += " GROUP BY SB8.B8_FILIAL, SB8.B8_LOTECTL, SB8.B8_X_CURRA, Z0O.Z0O_DCESP, SB8.B8_XPESOCO, Z0O_GMD, Z0O.Z0O_DATAIN, Z0O.Z0O_RENESP, SB8.B8_XDATACO, Z0O_CODPLA  " + CRLF
cQryCab += " ORDER BY SB8.B8_LOTECTL " + CRLF

MEMOWRITE("C:\TOTVS_RELATORIOS\IL_CABEC.txt", cQryCab)

TCQUERY cQryCab NEW ALIAS "QRYCAB"


If (!QRYCAB->(EOF()))

	//aDadCab = {SUBSTR(cLote, 1, rAt("-",cLote)-1), SUBSTR(cLote, rAt("-",cLote)+1, Len(cLote)), QRYCAB->B8_SALDO, STOD(QRYCAB->B8_XDATACO), Empty()/*D2_EMISSAO*/, QRYCAB->B8_XPESOCO, QRYCAB->B8_XPESTOT, 0, 0, 0, 0, 0, 0, dDataBase, 0, 0, 0, "", "", ""}

	aDadCab =  {SUBSTR(cLote, 1, rAt("-",cLote)-1),; //TMPIL_NUM
	 			SUBSTR(cLote, rAt("-",cLote)+1,	Len(cLote)),; //TMPIL_SEQ
	 			QRYCAB->CURRAL,; //TMPIL_CUR
	 			QRYCAB->SALDO,; //TMPIL_CAB
	 			STOD(QRYCAB->XDATACO),; //TMPIL_DTE
	 			Empty(),; //TMPIL_DTS
	 			QRYCAB->XPESOCO,; //TMPIL_PVI
	 			QRYCAB->PESO_TOTAL_LOTE,; //TMPIL_PLT
	 			QRYCAB->PES_MED_PROJ,; //TMPIL_PMP
	 			QRYCAB->PESO_ATU_PROJET,; //TMPIL_PPL
	 			QRYCAB->DIAS_COCHO,; //TMPIL_DCC
	 			QRYCAB->GMD,; //TMPIL_GMD
	 			QRYCAB->DCESP,; //TMPIL_DCE
	 			QRYCAB->PVF,; //TMPIL_PVF
	 			QRYCAB->ABAT_ESP,; // TMPIL_ABE
	 			QRYCAB->RENESP,; //TMPIL_RDE
	 			QRYCAB->QTDE_AN_UA,; //TMPIL_QUA
	 			QRYCAB->PLAN_NUTR,; //TMPIL_PLN
	 			"",; //TMPIL_RCL
	 			""} //TMPIL_SXL

EndIf

QRYCAB->(DBCloseArea())

Return (aDadCab)


Static Function CurLot(cLote)

Local aCurLot := {}
Local cQryCur := ""
Local nLin    := 1
Local oMdlAt  := FWModelActive()
Local oViwAt  := FWViewActive()
Local cCurAux := ""

cQryCur := " SELECT SD3.D3_X_CURRA AS CURRAL, SD3.D3_EMISSAO AS DATA, SD3.D3_LOTECTL AS LOTE" + CRLF 
cQryCur += " FROM " + RetSqlName("SD3") + " SD3 " + CRLF 
cQryCur += " WHERE SD3.D3_FILIAL = '" + xFilial("SD3") + "'" + CRLF 
cQryCur += "   AND SD3.D3_TM = '002' " + CRLF 
cQryCur += "   AND SD3.D3_CF IN ('PR0') " + CRLF 
cQryCur += "   AND SD3.D3_X_CURRA <> '' " + CRLF 
cQryCur += "   AND SD3.D3_OP <> '' " + CRLF 
cQryCur += "   AND SD3.D3_LOTECTL = '" + cLote + "'" + CRLF 
cQryCur += "   AND SD3.D_E_L_E_T_ <> '*' " + CRLF
cQryCur += "   AND D3_EMISSAO >= (SELECT DISTINCT MIN(B8_XDATACO) B8_XDATACO FROM " + RetSqlName("SB8") + " WHERE B8_LOTECTL = D3_LOTECTL AND D_E_L_E_T_ = ' ')" + CRLF 
cQryCur += " GROUP BY SD3.D3_X_CURRA, SD3.D3_EMISSAO, SD3.D3_LOTECTL " + CRLF 
cQryCur += " ORDER BY SD3.D3_LOTECTL, SD3.D3_EMISSAO "

TCQUERY cQryCur NEW ALIAS "QRYCUR"

MEMOWRITE("C:\TOTVS\TOTVS_RELATORIOS\IL_CURRAL.txt", cQryCur)

If (!(QRYCUR->(EOF())))
//	oMdlAt:GetModel("MASTER"):SetValue("TMPIL_DCC", DateDiffDay(STOD(QRYCUR->DATA), dDataBase))
	cCurAux := QRYCUR->CURRAL
	oMdlAt:GetModel("GRIDCURRAL"):LoadValue("Z0N_CURRAL", cCurAux)
	oMdlAt:GetModel("GRIDCURRAL"):LoadValue("Z0N_DATAEN", STOD(QRYCUR->DATA))
	QRYCUR->(DBSkip())
	oViwAt:Refresh("VWCURRAL")
EndIf

While (!(QRYCUR->(EOF())))

//	If (Empty(oMdlAt:GetValue("GRIDCURRAL","Z0N_CURRAL")))
//	
//	EndIf

	If (QRYCUR->CURRAL != cCurAux)
		oMdlAt:GetModel("GRIDCURRAL"):LoadValue("Z0N_DATASA", STOD(QRYCUR->DATA)) 
		//AAdd(aCurLot, {0, {QRYCUR->CURRAL, QRYCUR->DATA, Empty()}})
		oMdlAt:GetModel("GRIDCURRAL"):AddLine()
		cCurAux := QRYCUR->CURRAL
		oMdlAt:GetModel("GRIDCURRAL"):LoadValue("Z0N_CURRAL", cCurAux)
		oMdlAt:GetModel("GRIDCURRAL"):LoadValue("Z0N_DATAEN", STOD(QRYCUR->DATA))
		oViwAt:Refresh("VWCURRAL")
		nLin++
	EndIf

	QRYCUR->(DBSkip())

EndDo

QRYCUR->(DBCloseArea())

oMdlAt:GetModel("GRIDCURRAL"):GoLine(1)
oViwAt:Refresh()

Return (.T.)


Static Function AnmLot(cLote)

Local aAnmLot := {}
Local cQryAnm := ""
Local aRaca   := {}
Local aSexo   := {}
Local oMdlAt  := FWModelActive()
Local oViwAt  := FWViewActive()

cQryAnm := " SELECT Z0F.Z0F_SEQ, ZBC.ZBC_CODIGO LOTECOMPRA, ZBC_PEDIDO AS PEDIDO, Z0F.Z0F_MOVTO, Z0F.Z0F_PROD, Z0F.Z0F_TAG, SB1.B1_X_SEXO AS SEXO, Z0F.Z0F_RACA AS RACA, Z0F.Z0F_PESO, SA2.A2_NOME AS FORNECE " + CRLF
cQryAnm += " FROM " + RetSqlName("Z0F") + " Z0F " + CRLF
cQryAnm += " LEFT JOIN " + RetSqlName("ZBC") + " ZBC ON ZBC.ZBC_FILIAL = '" + xFilial("ZBC") + "' AND ZBC.ZBC_PRODUT = Z0F.Z0F_PROD AND ZBC.D_E_L_E_T_ <> '*' " + CRLF 
cQryAnm += " LEFT JOIN " + RetSqlName("SA2") + " SA2 ON SA2.A2_FILIAL  = '" + xFilial("SA2") + "' AND SA2.A2_COD = ZBC.ZBC_CODFOR AND SA2.A2_LOJA = ZBC.ZBC_LOJFOR AND SA2.D_E_L_E_T_ <> '*'" + CRLF
cQryAnm += " JOIN SB1010 SB1 ON SB1.B1_COD = Z0F.Z0F_PROD AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' " + CRLF
cQryAnm += " WHERE Z0F.Z0F_FILIAL = '" + xFilial("Z0F") + "' AND Z0F.D_E_L_E_T_ <> '*' " + CRLF
cQryAnm += " AND Z0F.Z0F_LOTE = '" + cLote + "'" + CRLF
cQryAnm += " ORDER BY Z0F.Z0F_SEQ, Z0F.Z0F_DTPES, Z0F.Z0F_PROD " + CRLF 

TCQUERY cQryAnm NEW ALIAS "QRYANM"

MEMOWRITE("C:\TOTVS\TOTVS_RELATORIOS\IL_ANIMAIS.txt", cQryAnm)

While (!(QRYANM->(EOF())))

	//If (!Empty(oMdlAt:GetValue("GRIDANIM","TMPAN_ID")))
				
	If (aScan( aRaca, { |x| x == ALLTRIM(QRYANM->RACA)}) == 0)
		AAdd(aRaca, ALLTRIM(QRYANM->RACA))
	EndIf
	
	If (aScan( aSexo, { |x| x == ALLTRIM(QRYANM->SEXO)}) == 0)
		AAdd(aSexo, ALLTRIM(QRYANM->SEXO))
	EndIf
	
	oMdlAt:GetModel("GRIDANIM"):LoadValue("TMPAN_ID", QRYANM->Z0F_SEQ)
	oMdlAt:GetModel("GRIDANIM"):LoadValue("TMPAN_LOT", QRYANM->LOTECOMPRA)
	oMdlAt:GetModel("GRIDANIM"):LoadValue("TMPAN_PED", QRYANM->PEDIDO)
	oMdlAt:GetModel("GRIDANIM"):LoadValue("TMPAN_MNJ", QRYANM->Z0F_MOVTO)
	oMdlAt:GetModel("GRIDANIM"):LoadValue("TMPAN_SBV", QRYANM->Z0F_PROD)
	oMdlAt:GetModel("GRIDANIM"):LoadValue("TMPAN_RFI", QRYANM->Z0F_TAG)
	oMdlAt:GetModel("GRIDANIM"):LoadValue("TMPAN_RAC", ALLTRIM(QRYANM->RACA))
	oMdlAt:GetModel("GRIDANIM"):LoadValue("TMPAN_SEX", ALLTRIM(QRYANM->SEXO))
	oMdlAt:GetModel("GRIDANIM"):LoadValue("TMPAN_PES", QRYANM->Z0F_PESO)
	oMdlAt:GetModel("GRIDANIM"):LoadValue("TMPAN_FOR", QRYANM->FORNECE)
		
	//EndIf

	//AAdd(aAnmLot, {0, {QRYANM->Z0F_SEQ, QRYANM->LOTECOMPRA, QRYANM->Z0F_MOVTO, QRYANM->Z0F_PROD, QRYANM->Z0F_TAG, QRYANM->SEXO, QRYANM->RACA, QRYANM->Z0F_PESO}})

	QRYANM->(DBSkip())
	
	If (!QRYANM->(EOF()))
		oMdlAt:GetModel("GRIDANIM"):AddLine()
	EndIf
	
	oViwAt:Refresh("VWANIM")

EndDo

If (Len(aRaca) > 1)
	oMdlAt:GetModel("MASTER"):SetValue("TMPIL_RCL", "MISTO")
ElseIf (Len(aRaca) == 1)
	oMdlAt:GetModel("MASTER"):SetValue("TMPIL_RCL", aRaca[1])
EndIf

If (Len(aSexo) > 1)
	oMdlAt:GetModel("MASTER"):SetValue("TMPIL_SXL", "MISTO")
ElseIf (Len(aSexo) == 1)
	oMdlAt:GetModel("MASTER"):SetValue("TMPIL_SXL", aSexo[1])
EndIf

oMdlAt:GetModel("GRIDANIM"):GoLine(1)
oViwAt:Refresh()

QRYANM->(DBCloseArea())

Return (.T.)

/*Arthur Toshio - 11-05-2020
InclusÃ£o da folder para listar os Dentição do lote.

*/

Static Function DentLote(cLote)

Local cQryDent := ""
Local oMdlAt  := FWModelActive()
Local oViwAt  := FWViewActive()


cQryDent := " SELECT DISTINCT Z0F_LOTE, " +CRLF
cQryDent += "       AVG(Z0F_PESO) Z0F_PESO, Z0F_DENTIC," +CRLF
cQryDent += "       CASE WHEN Z0F_DENTIC = 0 THEN COUNT(Z0F_DENTIC) --ELSE 0 END AS ZERO," +CRLF
cQryDent += "	          WHEN Z0F_DENTIC = 2 THEN COUNT(Z0F_DENTIC) --ELSE 0 END AS DOIS" +CRLF 
cQryDent += "	          WHEN Z0F_DENTIC = 4 THEN COUNT(Z0F_DENTIC) " +CRLF
cQryDent += "            WHEN Z0F_DENTIC = 6 THEN COUNT(Z0F_DENTIC) END QTD_ANI " +CRLF
cQryDent += "    FROM Z0F010 Z0F " +CRLF
cQryDent += "   WHERE Z0F.D_E_L_E_T_ = ' '  --Z0F_FILIAL = '01' " +CRLF 
cQryDent += "     --and  Z0F.Z0F_LOTE in ('25-22     ')  " +CRLF
cQryDent += " GROUP BY Z0F_LOTE, Z0F_DENTIC " +CRLF

TCQUERY cQryDent NEW ALIAS "QRYDENT"

MEMOWRITE("C:\TOTVS\TOTVS_RELATORIOS\IL_DENTICAO.txt", cQryDent)

While (!(QRYDENT->(EOF())))

	//If (!Empty(oMdlAt:GetValue("GRIDDENTI","TMPAN_ID")))

	oMdlAt:GetModel("GRIDDENT"):LoadValue("TDDEN_ID", QRYDENT->Z0F_DENTIC)
	oMdlAt:GetModel("GRIDDENT"):LoadValue("TDDEN_QTD", QRYDENT->QTD_ANI)
	oMdlAt:GetModel("GRIDDENT"):LoadValue("TDDEN_PES", QRYDENT->Z0F_PESO)

	
		
	//EndIf

	//AAdd(aAnmLot, {0, {QRYANM->Z0F_SEQ, QRYANM->LOTECOMPRA, QRYANM->Z0F_MOVTO, QRYANM->Z0F_PROD, QRYANM->Z0F_TAG, QRYANM->SEXO, QRYANM->RACA, QRYANM->Z0F_PESO}})

	QRYDENT->(DBSkip())
	
	If (!QRYDENT->(EOF()))
		oMdlAt:GetModel("GRIDDENT"):AddLine()
	EndIf
	
	oViwAt:Refresh("VWDENT")

EndDo

oMdlAt:GetModel("GRIDDENT"):GoLine(1)
oViwAt:Refresh()

QRYDENT->(DBCloseArea())

Return (.T.)
/*Fim DentiÃ§ao do lote*/


Static Function PlnLot(cLote)

Local aPlnLot := {}
Local cQryPln := ""
Local nLin    := 1
Local oMdlAt  := FWModelActive()
Local oViwAt  := FWViewActive()

cQryPln := " SELECT Z0O.Z0O_LOTE AS LOTE, Z0O.Z0O_CODPLA AS CODPLA, Z0M.Z0M_DESCRI AS DSCPLN, Z0O.Z0O_DATAIN AS DTINI, Z0O.Z0O_DIAIN AS DIAINI, Z0O.Z0O_DATATR AS DTFIN, Z0O.Z0O_GMD AS GMD, Z0O.Z0O_DCESP AS DCE, Z0O.Z0O_RENESP AS RNDESP "
cQryPln += " FROM " + RetSqlName("Z0O") + " Z0O "
cQryPln += " LEFT JOIN " + RetSqlName("Z0M") + " Z0M ON Z0M.Z0M_CODIGO = Z0O.Z0O_CODPLA AND Z0M.Z0M_FILIAL = '" + xFilial("Z0M") + "' AND Z0M.D_E_L_E_T_ <> '*' "
cQryPln += " WHERE Z0O.Z0O_FILIAL = '" + xFilial("Z0O") + "'"
cQryPln += "   AND Z0O.Z0O_LOTE = '" + cLote + "'"
cQryPln += "   AND Z0O.D_E_L_E_T_ <> '*' "
cQryPln += " GROUP BY Z0O.Z0O_LOTE, Z0O.Z0O_CODPLA, Z0M.Z0M_DESCRI, Z0O.Z0O_DATAIN, Z0O.Z0O_DIAIN, Z0O.Z0O_DATATR, Z0O.Z0O_GMD, Z0O.Z0O_DCESP, Z0O.Z0O_RENESP "
  
TCQUERY cQryPln NEW ALIAS "QRYPLN"

MEMOWRITE("C:\TOTVS\TOTVS_RELATORIOS\IL_PLANO.txt", cQryPln)

//If (!(QRYPLN->(EOF())))
//	oMdlAt:GetModel("MASTER"):SetValue("TMPIL_DCE", QRYPLN->DCE)
//	oMdlAt:GetModel("MASTER"):SetValue("TMPIL_RDE", QRYPLN->RNDESP)
//	oMdlAt:GetModel("MASTER"):SetValue("TMPIL_GMD", QRYPLN->GMD)
//	oViwAt:Refresh()
//EndIf

While (!(QRYPLN->(EOF())))

	oMdlAt:GetModel("GRIDPLANO"):LoadValue("Z0O_LOTE"  , QRYPLN->LOTE) 
	oMdlAt:GetModel("GRIDPLANO"):LoadValue("Z0O_CODPLA", QRYPLN->CODPLA)
	oMdlAt:GetModel("GRIDPLANO"):LoadValue("Z0O_DESPLA", QRYPLN->DSCPLN)
	oMdlAt:GetModel("GRIDPLANO"):LoadValue("Z0O_DATAIN", STOD(QRYPLN->DTINI))
	oMdlAt:GetModel("GRIDPLANO"):LoadValue("Z0O_DIAIN" , QRYPLN->DIAINI)
	oMdlAt:GetModel("GRIDPLANO"):LoadValue("Z0O_DATATR", STOD(QRYPLN->DTFIN))

	QRYPLN->(DBSkip())
	
	If (!QRYPLN->(EOF()))
		oMdlAt:GetModel("GRIDPLANO"):AddLine()
	EndIf
	
	oViwAt:Refresh("VWPLANO")

EndDo

QRYPLN->(DBCloseArea())

oMdlAt:GetModel("GRIDPLANO"):GoLine(1)
oViwAt:Refresh()

Return (.T.)


Static Function ResLot(cLote)

Local aResLot := {}
Local cQryRes := ""
Local oMdlAt  := FWModelActive()
Local oViwAt  := FWViewActive()

cQryRes := " SELECT SB1.B1_XLOTCOM, SB1.B1_XRACA, SB1.B1_X_SEXO, SB1.B1_X_ERA, SB1.B1_XDATACO " + CRLF 
cQryRes += " FROM " + RetSqlName("SB1") + " SB1" + CRLF 
cQryRes += " WHERE SB1.B1_COD IN (SELECT DISTINCT(Z0F.Z0F_PROD) " + CRLF 
cQryRes += "                      FROM " + RetSqlName("Z0F") + " Z0F " + CRLF  
cQryRes += "                      WHERE Z0F.Z0F_FILIAL = '" + xFilial("Z0F") + "'" + CRLF 
cQryRes += "                        AND Z0F.D_E_L_E_T_ <> '*' " + CRLF  
cQryRes += "                        AND Z0F.Z0F_LOTE = '" + cLote +"') " + CRLF 
cQryRes += "   AND SB1.D_E_L_E_T_ <> '*' " + CRLF 
cQryRes += "   AND SB1.B1_FILIAL = '" + xFilial("SB1") + "'" + CRLF 

TCQUERY cQryRes NEW ALIAS "QRYRES"

MEMOWRITE("C:\TOTVS\TOTVS_RELATORIOS\IL_RESUMO.txt", cQryRes)

While (!(QRYRES->(EOF())))

	oMdlAt:GetModel("GRIDRESUMO"):LoadValue("TMPRS_LOT", QRYRES->B1_XLOTCOM)
	oMdlAt:GetModel("GRIDRESUMO"):LoadValue("TMPRS_RAC", ALLTRIM(QRYRES->B1_XRACA))
	oMdlAt:GetModel("GRIDRESUMO"):LoadValue("TMPRS_SEX", ALLTRIM(QRYRES->B1_X_SEXO))
	oMdlAt:GetModel("GRIDRESUMO"):LoadValue("TMPRS_ERA", ALLTRIM(QRYRES->B1_X_ERA))
	oMdlAt:GetModel("GRIDRESUMO"):LoadValue("TMPRS_DTE", STOD(QRYRES->B1_XDATACO))
	oMdlAt:GetModel("GRIDRESUMO"):LoadValue("TMPRS_DTS", STOD(""))
	oMdlAt:GetModel("GRIDRESUMO"):LoadValue("TMPRS_CAB", 0)
	oMdlAt:GetModel("GRIDRESUMO"):LoadValue("TMPRS_DCC", 0)
	oMdlAt:GetModel("GRIDRESUMO"):LoadValue("TMPRS_PES", 0)
	oMdlAt:GetModel("GRIDRESUMO"):LoadValue("TMPRS_PMP", 0)
	oMdlAt:GetModel("GRIDRESUMO"):LoadValue("TMPRS_PLT", 0)
	oMdlAt:GetModel("GRIDRESUMO"):LoadValue("TMPRS_PPL", 0)
	
	//AAdd(aResLot, {0, {QRYRES->B1_XLOTCOM, QRYRES->B1_XRACA, QRYRES->B1_X_SEXO, QRYRES->B1_X_ERA, QRYRES->B1_XDATACO, Empty(), 0, 0, 0, 0, 0, 0}})

	QRYRES->(DBSkip())

	If (!QRYRES->(EOF()))
		oMdlAt:GetModel("GRIDRESUMO"):AddLine()
	EndIf
	
	oViwAt:Refresh("VWRESUMO")

EndDo

QRYRES->(DBCloseArea())

oMdlAt:GetModel("GRIDRESUMO"):GoLine(1)
oViwAt:Refresh()

Return (.T.)


Static Function SldLot(cLote)

Local aSldLot := {}
Local cQrySld := ""
Local oMdlAt  := FWModelActive()
Local oViwAt  := FWViewActive()

cQrySld := " SELECT SB1.B1_XRACA  AS RACA, SB1.B1_X_SEXO AS SEXO, SB1.B1_X_ERA  AS ERA, SUM(SB1.B1_X_PESOC) AS PESO, COUNT(Z0F.Z0F_TAG) AS QUANT, SUM(SB1.B1_X_PESOC + SB1.B1_X_RENDP) AS PESOPRJ " + CRLF 
cQrySld += " FROM " + RetSqlName("Z0F") + " Z0F " + CRLF 
cQrySld += " JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_COD = Z0F.Z0F_PROD AND SB1.D_E_L_E_T_ <> '*' AND SB1.B1_FILIAL = '" + xFilial("SB1") + "'" + CRLF  
cQrySld += " WHERE Z0F.Z0F_FILIAL = '" + xFilial("Z0F") + "'" + CRLF 
cQrySld += "   AND Z0F.D_E_L_E_T_ <> '*' " + CRLF 
cQrySld += "   AND Z0F.Z0F_LOTE = '" + cLote + "'" + CRLF 
cQrySld += " GROUP BY SB1.B1_XRACA, SB1.B1_X_SEXO, SB1.B1_X_ERA " + CRLF 

TCQUERY cQrySld NEW ALIAS "QRYSLD"

MEMOWRITE("C:\TOTVS\TOTVS_RELATORIOS\IL_SALDOS.txt", cQrySld)

While (!(QRYSLD->(EOF())))

	oMdlAt:GetModel("GRIDSALDO"):LoadValue("TMPSL_RAC", ALLTRIM(QRYSLD->RACA))
	oMdlAt:GetModel("GRIDSALDO"):LoadValue("TMPSL_SEX", ALLTRIM(QRYSLD->SEXO))
	oMdlAt:GetModel("GRIDSALDO"):LoadValue("TMPSL_ERA", ALLTRIM(QRYSLD->ERA))
	oMdlAt:GetModel("GRIDSALDO"):LoadValue("TMPSL_CAB", QRYSLD->QUANT)
	oMdlAt:GetModel("GRIDSALDO"):LoadValue("TMPSL_PSI", QRYSLD->PESO)
	oMdlAt:GetModel("GRIDSALDO"):LoadValue("TMPSL_PSP", QRYSLD->PESOPRJ)

	//AAdd(aSldLot, {0, {QRYSLD->RACA, QRYSLD->SEXO, QRYSLD->ERA, QRYSLD->QUANT, QRYSLD->PESO, QRYSLD->PESOPRJ}})

	QRYSLD->(DBSkip())
	
	If (!QRYSLD->(EOF()))
		oMdlAt:GetModel("GRIDSALDO"):AddLine()
	EndIf

	oViwAt:Refresh("VWSALDO")

EndDo

QRYSLD->(DBCloseArea())

oMdlAt:GetModel("GRIDSALDO"):GoLine(1)
oViwAt:Refresh()

Return (.T.)


Static Function NotFisE(cLote)

Local aNotFisE := {}
Local cQryNFE  := ""
Local oMdlAt   := FWModelActive()
Local oViwAt   := FWViewActive()

cQryNFE := " SELECT SD1.D1_DOC AS DOC, SD1.D1_SERIE AS SERIE, SD1.D1_ITEM AS ITEM, SD1.D1_QUANT AS QUANT, SD1.D1_VUNIT AS VUNI, SD1.D1_TOTAL AS VTOT, SD1.D1_EMISSAO AS DATA " + CRLF 
cQryNFE += "      , SD1.D1_X_KM AS KMR, SD1.D1_X_PESCH AS PCH, SD1.D1_X_CHEDT AS DCH, SD1.D1_X_CHEHR AS HCH, SD1.D1_X_EMBDT AS DEM, SD1.D1_X_EMBHR AS HEM, SD1.D1_VALICM AS VALICM " + CRLF  //SD1.D1_DOC AS DOC, SD1.D1_ITEM AS ITEM, SD1.D1_QUANT AS QUANT, SD1.D1_VUNIT AS VUNI, SD1.D1_TOTAL AS VTOT, SD1.D1_EMISSAO AS DATA "
cQryNFE += "      , SB1.B1_COD AS CODPROD, SB1.B1_DESC AS NOMPROD, SA2.A2_COD AS CODFOR, SA2.A2_NOME AS NOMFOR " + CRLF 
cQryNFE += " FROM " + RetSqlName("SD1") + " SD1 " + CRLF  
cQryNFE += " JOIN " + RetSqlName("SA2") + " SA2 ON SA2.A2_COD = SD1.D1_FORNECE AND SA2.A2_LOJA = SD1.D1_LOJA AND SA2.D_E_L_E_T_ <> '*' " + CRLF 
cQryNFE += " JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_COD = SD1.D1_COD AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' " + CRLF 
cQryNFE += " WHERE SD1.D_E_L_E_T_ <> '*' " + CRLF 
cQryNFE += "   AND SD1.D1_FILIAL = '" + xFilial("SD1") + "'" + CRLF 
cQryNFE += "   AND D1_TIPO = 'N' " 
cQryNFE += "   AND SD1.D1_COD IN (SELECT SB8.B8_PRODUTO "  
cQryNFE += "                      FROM " + RetSqlName("SB8") + " SB8 " 
cQryNFE += "                      WHERE SB8.B8_LOTECTL = '" + cLote + "'" 
cQryNFE += "   			            AND SB8.D_E_L_E_T_ <> '*') "

TCQUERY cQryNFE NEW ALIAS "QRYNFE"

MEMOWRITE("C:\TOTVS\TOTVS_RELATORIOS\IL_NFENTRADA.txt", cQryNFE)

While (!(QRYNFE->(EOF())))

	oMdlAt:GetModel("GRIDNOTAE"):LoadValue("TMPNE_NUM", QRYNFE->DOC)
	oMdlAt:GetModel("GRIDNOTAE"):LoadValue("TMPNE_SER", QRYNFE->SERIE)
	oMdlAt:GetModel("GRIDNOTAE"):LoadValue("TMPNE_FOR", QRYNFE->CODFOR)
	oMdlAt:GetModel("GRIDNOTAE"):LoadValue("TMPNE_NFR", SUBSTR(QRYNFE->NOMFOR, 1, 50))
	oMdlAt:GetModel("GRIDNOTAE"):LoadValue("TMPNE_COD", QRYNFE->CODPROD)
	oMdlAt:GetModel("GRIDNOTAE"):LoadValue("TMPNE_DPR", SUBSTR(QRYNFE->NOMPROD, 1, 50))
	oMdlAt:GetModel("GRIDNOTAE"):LoadValue("TMPNE_QTD", QRYNFE->QUANT)
	oMdlAt:GetModel("GRIDNOTAE"):LoadValue("TMPNE_VUN", QRYNFE->VUNI)
	oMdlAt:GetModel("GRIDNOTAE"):LoadValue("TMPNE_VTT", QRYNFE->VTOT)
	oMdlAt:GetModel("GRIDNOTAE"):LoadValue("TMPNE_DNF", STOD(QRYNFE->DATA))
	oMdlAt:GetModel("GRIDNOTAE"):LoadValue("TMPNE_DEM", STOD(QRYNFE->DEM))
	oMdlAt:GetModel("GRIDNOTAE"):LoadValue("TMPNE_HEM", QRYNFE->HEM)
	oMdlAt:GetModel("GRIDNOTAE"):LoadValue("TMPNE_DCH", STOD(QRYNFE->DCH))
	oMdlAt:GetModel("GRIDNOTAE"):LoadValue("TMPNE_HCH", QRYNFE->HCH)
	oMdlAt:GetModel("GRIDNOTAE"):LoadValue("TMPNE_PCH", QRYNFE->PCH)
	oMdlAt:GetModel("GRIDNOTAE"):LoadValue("TMPNE_KMR", QRYNFE->KMR)
	
	//AAdd(aNotFisE, {0, {QRYNFE->DOC, QRYNFE->ITEM, QRYNFE->QUANT, QRYNFE->VUNI, QRYNFE->VTOT, QRYNFE->DATA}})

	QRYNFE->(DBSkip())
	
	If (!QRYNFE->(EOF()))
		oMdlAt:GetModel("GRIDNOTAE"):AddLine()
	EndIf
	
	oViwAt:Refresh("VWNOTAE")

EndDo

QRYNFE->(DBCloseArea())

oMdlAt:GetModel("GRIDNOTAE"):GoLine(1)
oViwAt:Refresh()

Return (.T.)


Static Function NotFisS(cLote)

Local aNotFisS := {}
Local cQryNFS  := ""
Local oMdlAt   := FWModelActive()
Local oViwAt   := FWViewActive()

cQryNFS := " SELECT SD2.D2_DOC AS DOC, SD2.D2_SERIE AS SERIE, SD2.D2_ITEM AS ITEM, SD2.D2_QUANT AS QUANT, SD2.D2_PRCVEN AS VUNI, SD2.D2_TOTAL AS VTOT, SD2.D2_EMISSAO AS DATA " + CRLF 
cQryNFS += "      , SD2.D2_XNRPSAG AS NRPSG, SD2.D2_XPESLIQ AS PLIQ, SD2.D2_XDTABAT AS DTABAT " + CRLF 
cQryNFS += "      , SB1.B1_COD AS CODPROD, SB1.B1_DESC AS NOMPROD, SA1.A1_COD AS CODCLI, SA1.A1_NOME AS NOMCLI " + CRLF   
cQryNFS += " FROM " + RetSqlName("SD2") + " SD2 " + CRLF 
cQryNFS += " JOIN " + RetSqlName("SA1") + " SA1 ON SA1.A1_COD = SD2.D2_CLIENTE AND SA1.A1_LOJA = SD2.D2_LOJA AND SA1.D_E_L_E_T_ <> '*' " + CRLF 
cQryNFS += " JOIN " + RetSqlName("SB1") + " SB1 ON SB1.B1_COD = SD2.D2_COD AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' AND SB1.D_E_L_E_T_ <> '*' " + CRLF 
cQryNFS += " WHERE SD2.D_E_L_E_T_ <> '*' " + CRLF 
cQryNFS += "       AND SD2.D2_FILIAL = '" + xFilial("SD2") + "'" + CRLF
cQryNFS += "       AND SD2.D2_LOTECTL = '" + cLote + "'" 
//cQryNFS += "       AND SD2.D2_LOTECTL IN (SELECT SD3.D3_LOTECTL " + CRLF  
//cQryNFS += "                          FROM " + RetSqlName("SD3") + " SD3 " + CRLF 
//cQryNFS += "                          WHERE SD3.D3_FILIAL = '" + xFilial("SD3") + "'" + CRLF 
//cQryNFS += "                            AND SD3.D_E_L_E_T_ <> '*' " + CRLF 
//cQryNFS += "                            AND SD3.D3_LOTECTL <> '' " + CRLF 
//cQryNFS += "                            AND SD3.D3_CF IN ('RE4','DE4') " + CRLF 
//cQryNFS += "                            AND SD3.D3_COD IN (SELECT SD3.D3_COD " + CRLF 
//cQryNFS += "                                               FROM " + RetSqlName("SD3") + " SD3 " + CRLF 
//cQryNFS += "                                               WHERE SD3.D3_LOTECTL <> '' " + CRLF 
//cQryNFS += "                                                 AND SD3.D3_FILIAL = '" + xFilial("SD3") + "'" + CRLF 
//cQryNFS += "                                                 AND SD3.D_E_L_E_T_ <> '*' " + CRLF 
//cQryNFS += "                                                 AND SD3.D3_CF IN ('RE4','DE4') " + CRLF 
//cQryNFS += "                                                 AND SD3.D3_LOTECTL = '" + cLote + "')) " + CRLF 

TCQUERY cQryNFS NEW ALIAS "QRYNFS"

MEMOWRITE("C:\TOTVS\TOTVS_RELATORIOS\IL_NFSAIDA.txt", cQryNFS)

While (!(QRYNFS->(EOF())))

	oMdlAt:GetModel("GRIDNOTAS"):LoadValue("TMPNS_NUM", QRYNFS->DOC)
	oMdlAt:GetModel("GRIDNOTAS"):LoadValue("TMPNS_SER", QRYNFS->SERIE)
	oMdlAt:GetModel("GRIDNOTAS"):LoadValue("TMPNS_CLI", QRYNFS->CODCLI)
	oMdlAt:GetModel("GRIDNOTAS"):LoadValue("TMPNS_NCL", SUBSTR(QRYNFS->NOMCLI, 1, 50))
	oMdlAt:GetModel("GRIDNOTAS"):LoadValue("TMPNS_COD", QRYNFS->CODPROD)
	oMdlAt:GetModel("GRIDNOTAS"):LoadValue("TMPNS_DPR", SUBSTR(QRYNFS->NOMPROD, 1, 50))
	oMdlAt:GetModel("GRIDNOTAS"):LoadValue("TMPNS_QTD", QRYNFS->QUANT)
	oMdlAt:GetModel("GRIDNOTAS"):LoadValue("TMPNS_VUN", QRYNFS->VUNI)
	oMdlAt:GetModel("GRIDNOTAS"):LoadValue("TMPNS_VTT", QRYNFS->VTOT)
	oMdlAt:GetModel("GRIDNOTAS"):LoadValue("TMPNS_DNF", STOD(QRYNFS->DATA))
	oMdlAt:GetModel("GRIDNOTAS"):LoadValue("TMPNS_NRP", QRYNFS->NRPSG)
	oMdlAt:GetModel("GRIDNOTAS"):LoadValue("TMPNS_PLQ", QRYNFS->PLIQ)
	oMdlAt:GetModel("GRIDNOTAS"):LoadValue("TMPNS_DAB", STOD(QRYNFS->DTABAT))
	
	//AAdd(aNotFisS, {0, {QRYNFS->DOC, QRYNFS->ITEM, QRYNFS->QUANT, QRYNFS->VUNI, QRYNFS->VTOT, QRYNFS->DATA}})
	
	QRYNFS->(DBSkip())
	
	If (!QRYNFS->(EOF()))
		oViwAt:GetModel("GRIDNOTAS"):AddLine()
	EndIf
	
	oViwAt:Refresh("VWNOTAS") 

EndDo

QRYNFS->(DBCloseArea())

oMdlAt:GetModel("GRIDNOTAS"):GoLine(1)
oViwAt:Refresh()

Return (.T.)


Static Function VIWNF(nOpc)

Local aArea  := GetAreA()
Local nLin   := 0
Local oMdlAt := FWModelActive()
Local oViwAt := FWViewActive()

If (nOpc == 1)

	If (!Empty(oMdlAt:GetValue("GRIDNOTAE","TMPNE_NUM")))	

		DBSelectArea("SF1")
		SF1->(DBSetOrder(1))
		
		If (SF1->(DBSeek(xFilial("SF1")+ALLTRIM(oMdlAt:GetValue("GRIDNOTAE","TMPNE_NUM"))+ALLTRIM(oMdlAt:GetValue("GRIDNOTAE","TMPNE_SER")))))
			
			antArotina := aRotina
	
			Private aRotina := {{"Pesquisar"  , "AxPesqui"   , 0, 1},; 
								{"Visualizar" , "A103NFiscal", 0, 2},; 
								{"Incluir"    , "A103NFiscal", 0, 3},; 
								{"Classificar", "A103NFiscal", 0, 4},; 
								{"Retornar"   , "A103Devol"  , 0, 3},; 
								{"Excluir"    , "A103NFiscal", 3, 5},; 
								{"Imprimir"   , "A103Impri"  , 0, 4},; 
								{"Legenda"    , "A103Legenda", 0, 2} } 
											
			A103NFiscal("SF1",SF1->(Recno()), 2)
						
			aRotina := antArotina
	
		Else
			MsgInfo("Nota Fiscal de Entrada (Serie + Numero): " + oMdlAt:GetValue("GRIDNOTAE","TMPNE_SER") + " " + oMdlAt:GetValue("GRIDNOTAE","TMPNE_NUM") + " nao encontrada.")	
		EndIf
		
	EndIf
	
ElseIf (nOpc == 2)

	If (!Empty(oMdlAt:GetValue("GRIDNOTAS","TMPNS_NUM")))

		DBSelectArea("SF2")
		SF2->(DBSetOrder(1))
	
		If (SF2->(DBSeek(xFilial("SF2")+ALLTRIM(oMdlAt:GetValue("GRIDNOTAS","TMPNS_NUM"))+ALLTRIM(oMdlAt:GetValue("GRIDNOTAS","TMPNS_SER")))))
			Mc090Visual()
		Else
			MsgInfo("Nota Fiscal de Saida (Serie + Numero): " + oMdlAt:GetValue("GRIDNOTAS","TMPNS_SER") + " " + oMdlAt:GetValue("GRIDNOTAS","TMPNS_NUM") + " nao encontrada.")
		EndIf
	
	EndIf

EndIf

Return (.T.)


Static Function SVDTM(oMdl)

Local aArea   := GetArea()
Local lVldSv  := .T.
Local nCntLin := 1

Return (lVldSv)

DBSelectArea("Z0N")
Z0N->(DBSetOrder(1))

DBSelectArea("Z0O")
Z0O->(DBSetOrder(1))

//grava dados da aba de currais por onde o lote passou
For nCntLin := 1 To oMdl:GetModel("GRIDCURRAL"):Length()

 	oMdl:GetModel("GRIDCURRAL"):GoLine(nCntLin)

	If (Z0N->(DBSeek(xFilial("Z0N")+(cAliasTMP)->B8_LOTECTL+oMdl:GetValue("GRIDCURRAL","Z0N_CURRAL"))))
	
		If (oMdl:GetModel("GRIDCURRAL"):isDeleted())
		
			RecLock("Z0N", .F.)
			
				Z0N->(DBDelete())
			                                                                   
			Z0N->(MsUnlock())
		
		Else
		
			RecLock("Z0N", .F.)
			
				Z0N->Z0N_DATAEN := oMdl:GetValue("GRIDCURRAL","Z0N_DATAEN")
				Z0N->Z0N_DATASA := oMdl:GetValue("GRIDCURRAL","Z0N_DATASA")
			
			Z0N->(MsUnlock())
		
		EndIf
				
	Else
		
		If (!oMdl:GetModel("GRIDCURRAL"):isDeleted())
		
			RecLock("Z0N", .T.)
			
				Z0N->Z0N_FILIAL := xFilial("Z0N")
				Z0N->Z0N_LOTE   := (cAliasTMP)->B8_LOTECTL
				Z0N->Z0N_CURRAL := oMdl:GetValue("GRIDCURRAL","Z0N_CURRAL")
				Z0N->Z0N_DATAEN := oMdl:GetValue("GRIDCURRAL","Z0N_DATAEN")
				Z0N->Z0N_DATASA := oMdl:GetValue("GRIDCURRAL","Z0N_DATASA")
				
			Z0N->(MsUnlock())	
		
		EndIf
		
	EndIf

Next nCntLin

RestArea(aArea)

Return (lVldSv)


Static Function RunGen(nAba)

DO CASE
CASE nAba == 1 .AND. !aCrrgAb[nAba]
	FWMsgRun(,{|| aCrrgAb[nAba] := ANMLOT((cAliasTMP)->B8_LOTECTL)}, "Processando", "Carregando informacoes de Aniamais...")
CASE nAba == 2 .AND. !aCrrgAb[nAba]
	FWMsgRun(,{|| aCrrgAb[nAba] := PLNLOT((cAliasTMP)->B8_LOTECTL)}, "Processando", "Carregando informacoes dos Planos Nutricionais...")
//CASE nAba == 3 .AND. !aCrrgAb[nAba]
//	FWMsgRun(,{|| aCrrgAb[nAba] :=  }, "Processando", "Processando arquivo de abates...")
CASE nAba == 4 .AND. !aCrrgAb[nAba]
	FWMsgRun(,{|| aCrrgAb[nAba] := CURLOT((cAliasTMP)->B8_LOTECTL)}, "Processando", "Carregando informacoes de Currais..")
CASE nAba == 5 .AND. !aCrrgAb[nAba]
	FWMsgRun(,{|| aCrrgAb[nAba] := RESLOT((cAliasTMP)->B8_LOTECTL)}, "Processando", "Carregando informacoes de Resumo...")
CASE nAba == 6 .AND. !aCrrgAb[nAba]
	FWMsgRun(,{|| aCrrgAb[nAba] := SLDLOT((cAliasTMP)->B8_LOTECTL)}, "Processando", "Carregando informacoes de Saldos...")
CASE nAba == 7 .AND. !aCrrgAb[nAba]
	FWMsgRun(,{|| aCrrgAb[nAba] := (NOTFISE((cAliasTMP)->B8_LOTECTL) .AND. NOTFISS((cAliasTMP)->B8_LOTECTL))}, "Processando", "Carregando informacoes de Notas Fiscais...")
CASE nAba == 8 .AND. !aCrrgAb[nAba]
	FWMsgRun(,{|| aCrrgAb[nAba] := DentLote((cAliasTMP)->B8_LOTECTL)}, "Processando", "Carregando informacoes da Dentição dos animais do lote...")
OTHERWISE
	Return (Nil)
ENDCASE

Return (Nil)
