#include "protheus.ch"
#include "topconn.ch"

user function GetCode( cAlias, cF3, nFldKey, aFlds, cReturn )
local aArea   := GetArea()
local aRet    := {}
local oDlgGetCod := nil
local aHGC    := {}
local aCGC    := {}
local nGDOpc   := Iif(cAlias == 'SM0', 0, GD_INSERT + GD_UPDATE + GD_DELETE)
local nOpcA   := 0
local i, nLen  

private cTitulo  := "" 
private aCpos   := aClone(aFlds)
private cRet    := cReturn
private cTbl    := cAlias
private cConPad  := cF3
private nQtdCpoChv := nFldKey
private cPrefix  := Iif(Substr(cTbl, 1, 1) == 'S', SubStr(cTbl, 2, 2), cTbl)
private oGD    := nil
private nPosMark  := 0
private nPosRecNo := 0
Private nPosDel  := 0

DbSelectArea("SX2")
DbSetOrder(1)
if SX2->(DbSeek(cAlias))
  cTitulo := SX2->X2_NOME
endif

DbSelectArea(cAlias)
DbSetOrder(1)

  fs_DadosGC(cTbl, cF3, @aCpos, @aHGC, @aCGC)
  nPosMark  := AScan(aHGC, {|aMat| AllTrim(aMat[2]) == cPrefix+"_MARK" } )
  nPosRecNo := AScan(aHGC, {|aMat| AllTrim(aMat[2]) == cPrefix+"_RECNO" } ) 
  nPosDel  := Len(aHGC) + 1

  DEFINE MSDIALOG oDlgGetCod FROM 000, 000 to 320, 610 TITLE OemToAnsi(cTitulo) PIXEL
    
   oGD := MsNewGetDados():New( 0, 0, 100, 1, nGDOpc,,,,,,,,,, oDlgGetCod, aHGC, aCGC )
   oGD:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
   oGD:oBrowse:BlDblClick := { || fs_SetMark() }
   
  ACTIVATE MSDIALOG oDlgGetCod ON INIT (EnchoiceBar(oDlgGetCod, {||nOpcA := 1, Iif(fs_TOkGC(oGD), oDlgGetCod:End(), nOpcA := 0) } ,{||nOpca2 := 0, oDlgGetCod:End()})) CENTERED
  
  if nOpcA == 1
    DbSelectArea(cAlias)
    DbSetOrder(1)
    nLen := Len(oGD:aCols)
    for i := 1 to nLen
      if !oGD:aCols[i][nPosDel] .and. oGD:aCols[i][nPosMark] == "LBTIK"
        (cAlias)->(DbGoTo(oGD:aCols[i][nPosRecNo]))
        AAdd(aRet, &(cRet))
      endif
    next
  endif
  
RestArea(aArea)
return aRet

static function fs_TOkGC(oGet)
local lRet   := .f.
local i, nLen

nLen := Len(oGet:aCols)
for i := 1 to nLen
	if oGet:aCols[i][nPosMark] == "LBTIK"
		lRet := .t.
		exit
	endif
next

if !lRet
	MsgAlert("Nenhuma linha foi selecionada. Selecione pelo menos uma linha para prosseguir ou clique em [Fechar].")	
endif

return lRet

user function FillData(cAlias)
local aArea   := GetArea()
local lRet    := .t.
local nLen    := 0
local i     := 0
local cChav   := ""
//local xReadedVar := nil

  if cAlias == "SM0"
    if !Empty(&(ReadVar()))
      cChav := FWCodEmp() + &(ReadVar())
      if SM0->(DbSeek(cChav)) .and. SM0->M0_CODFIL == &(ReadVar())
        nLen    := Len(aCpos)
        for i := nQtdCpoChv+1 to nLen
           oGD:aCols[oGD:nAt][aScan(oGD:aHeader, {|aMat| AllTrim(aMat[2]) == AllTrim(aCpos[i])})] := (cAlias)->&(aCpos[i])
        next 
        oGD:aCols[oGD:nAt][nPosRecNo] := (cAlias)->(RecNo())
      else
        ShowHelpDlg("FILLDATA01", {"Não foi encontrada a filial [" + &(ReadVar()) + "] para a empresa logada."}, 1, {"Por favor, digite uma filial válida." + CRLF + "<F3 Dsiponível>."}, 1)
        lRet    := .f.
      endif
    endif
  elseif cAlias == "SX5"
    cChav := xFilial(cAlias) + cConPad + AllTrim(M->X5_CHAVE)
    if SX5->(DbSeek(cChav))
      nLen    := Len(aCpos)
      for i := nQtdCpoChv+1 to nLen
        oGD:aCols[oGD:nAt][aScan(oGD:aHeader, {|aMat| AllTrim(aMat[2]) == AllTrim(aCpos[i])})] := (cAlias)->&(aCpos[i])
      next
      oGD:aCols[oGD:nAt][nPosRecNo] := (cAlias)->(RecNo())
    else
      ShowHelpDlg("FILLDATA02", {"Não foi encontrado o registro [" + &(ReadVar()) + "] para a tabela generica " + cTitulo + "."}, 1, {"Por favor, digite um registro válido." + CRLF + "<F3 Dsiponível>."}, 1)
      lRet    := .f.
    endif
    
  else
    cChav += xFilial(cAlias)

    for i := 1 to nQtdCpoChv
      if "M->"+AllTrim(oGD:aHeader[aScan(oGD:aHeader, {|aMat| AllTrim(aMat[2]) == AllTrim(aCpos[i])})][2]) = AllTrim(ReadVar())
        cChav += &(ReadVar())
      else
        cChav += GdFieldGet(oGD:aHeader[aScan(oGD:aHeader, {|aMat| AllTrim(aMat[2]) == AllTrim(aCpos[i])})][2])
      endif
    next

    if (cAlias)->(DbSeek(cChav))
      nLen := Len(aCpos)
      for i := nQtdCpoChv+1 to nLen
        oGD:aCols[oGD:nAt][aScan(oGD:aHeader, {|aMat| AllTrim(aMat[2]) == AllTrim(aCpos[i])})] := (cAlias)->&(aCpos[i])
      next
      oGD:aCols[oGD:nAt][nPosRecNo] := (cAlias)->(RecNo())
    else
      ShowHelpDlg("FILLDATA03", {"Não foi encontrado o registro [" + &(ReadVar()) + "] para a tabela " + cTitulo + "."}, 1, {"Por favor, digite um registro válido." + CRLF + "<F3 Dsiponível>."}, 1)
      lRet    := .f.
    endif
  endif
if !Empty(aArea)
  RestArea(aArea)
endif
return lRet

static function fs_SetMark()
  
  oGD:aCols[oGD:nAt][nPosMark] := Iif(oGD:aCols[oGD:nAt][nPosMark] == 'LBNO', 'LBTIK', 'LBNO')
  oGD:Refresh()

return nil 

static function fs_DadosGC(cAlias, cF3, aFlds, aHead, aCols)
local aAreaSM0  := {}
local nLen    := 0
local i     := 0
local aCol    := {}
local cCampo   := ""

  if cAlias == "SM0"
    aAreaSM0 := SM0->(GetArea())
    cTitulo := "Filiais"
    aStruct := SM0->(DbStruct())
    
    AAdd(aHead, { " ", Padr(cPrefix+"_MARK", 10), "@BMP", 1, 0, .F., "", "C", "", "V", "", "'LBNO'", "", "V", "", "", "" } )
    nLen    := Len(aFlds)
    for i := 1 to nLen
      nPos := aScan(aStruct, {|aMat| aMat[1] == aFlds[i]})
      if AllTrim(aFlds[i]) == "M0_CODIGO"
        cCampo := "Empresa"
      elseif AllTrim(aFlds[i]) == "M0_CODFIL"
        cCampo := "Filial"
      elseif AllTrim(aFlds[i]) == "M0_FILIAL"
        cCampo := "Nome Filial"
      elseif AllTrim(aFlds[i]) == "M0_NOME"
        cCampo := "Nome Empresa"
      elseif AllTrim(aFlds[i]) == "M0_NOMECOM"
        cCampo := "Nome Comercial"
      elseif AllTrim(aFlds[i]) == "M0_CGC"  
        cCampo := "CNPJ"
      else
        cCampo := aFlds[i]
      endif      
        AAdd(aHead, { cCampo,;        // SX3->X3_TITULO 
               aFlds[i],;        // SX3->X3_CAMPO
               "",;           // SX3->X3_PICTURE
               aStruct[nPos][3],;    // SX3->X3_TAMANHO
               aStruct[nPos][4],;    // SX3->X3_DECIMAL
               "u_FillData('" + cAlias + "')",; // SX3->X3_VALID
               Chr(128)+Chr(128)+Chr(128)+Chr(128)+Chr(128)+Chr(128)+Chr(128)+Chr(128)+Chr(128)+Chr(128)+Chr(128)+Chr(128)+Chr(128)+Chr(128)+Chr(160),;     // SX3->X3_USADO
               aStruct[nPos][2],;    // SX3->X3_TIPO
               Iif(i == 1, cF3, ""),;  // SX3->X3_F3
               "V",;          // SX3->X3_CONTEXT
               "",;           // SX3->X3_CBOX
               "",;           // SX3->X3_RELACAO
               "",;           // SX3->X3_WHEN
               Iif(i == 1, "A", "V"),; // SX3->X3_VISUAL
               "",;           // SX3->X3_VLDUSER
               "",;           // SX3->X3_PICTVAR
               "" } )          // X3Obrigat(SX3->X3_CAMPO)
    next
    AAdd(aHead, { " ", Padr(cPrefix+"_RECNO", 10), "", 12, 0, .F., "", "N", "", "V", "", "", "", "V", "", "", "" } )

    nLen := Len(aHead)
    aCols := {} 
    SM0->(DbGoTop())

    while !SM0->(Eof())
      aCol := Array(nLen+1)
      for i := 1 to nLen
        if "_MARK" $ aHead[i][2]
          aCol[i] := 'LBNO'
        elseif "_RECNO" $ aHead[i][2]
          aCol[i] := SM0->(RecNo())
        else
          aCol[i] := &(aHead[i][2])
        endif
      next
      aCol[nLen+1] := .F.
      AAdd(aCols, aCol)
      SM0->(DbSkip())
    end

    SM0->(RestArea(aAreaSM0))
  else

    if cAlias == "SX5"
      SX5->(DbSeek(xFilial("SX5")+"00"+cConPad))
      cTitulo  := AllTrim(SX5->X5_DESCRI)

      aFlds   := {"X5_CHAVE", "X5_DESCRI"}
      cRet    := "X5_DESCRI"
      nQtdCpoChv := 1
    endif
    
    DbSelectArea("SX3")
    DbSetOrder(2) // X3_CAMPO
  
    AAdd(aHead, { " ", Padr(cPrefix+"_MARK", 10), "@BMP", 1, 0, .F., "", "C", "", "V", "", "'LBNO'", "", "V", "", "", "" } )
    nLen    := Len(aFlds)
    for i := 1 to nLen
      SX3->(DbSeek(aFlds[i]))
      AAdd(aHead, { SX3->X3_TITULO,;     // SX3->X3_TITULO 
             SX3->X3_CAMPO,;     // SX3->X3_CAMPO
             SX3->X3_PICTURE,;    // SX3->X3_PICTURE
             SX3->X3_TAMANHO,;    // SX3->X3_TAMANHO
             SX3->X3_DECIMAL,;    // SX3->X3_DECIMAL
             Iif(i <= nQtdCpoChv,"u_FillData('" + cAlias + "')",""),; // SX3->X3_VALID
               Chr(128)+Chr(128)+Chr(128)+Chr(128)+Chr(128)+Chr(128)+Chr(128)+Chr(128)+Chr(128)+Chr(128)+Chr(128)+Chr(128)+Chr(128)+Chr(128)+Chr(160),;     // SX3->X3_USADO
             SX3->X3_TIPO,;      // SX3->X3_TIPO
             Iif(i == 1, cF3, ""),;  // SX3->X3_F3
             SX3->X3_CONTEXT,;    // SX3->X3_CONTEXT
             "",;           // SX3->X3_CBOX
             "",;           // SX3->X3_RELACAO
             "",;           // SX3->X3_WHEN
             Iif(i <= nQtdCpoChv, "A", "V"),; // SX3->X3_VISUAL
             "",;           // SX3->X3_VLDUSER
             "",;           // SX3->X3_PICTVAR
             "" } )          // X3Obrigat(SX3->X3_CAMPO)
    next
    AAdd(aHead, { " ", Padr(cPrefix+"_RECNO", 10), "", 12, 0, .F., "", "N", "", "V", "", "", "", "V", "", "", "" } )

    nLen := Len(aHead)
    aCols := {} 
    AAdd(aCols, Array(nLen+1))
    for i := 1 to nLen
      if "_MARK" $ aHead[i][2]
        aCols[1][i] := 'LBNO'
      elseif "_RECNO" $ aHead[i][2]
        aCols[1][i] := 0
      else
        aCols[1][i] := CriaVar(aHead[i][2], .f.)
      endif
    next
    aCols[1][nLen+1] := .f.
  endif

return nil
