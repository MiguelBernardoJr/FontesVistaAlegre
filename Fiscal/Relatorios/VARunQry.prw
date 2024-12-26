#include "Protheus.ch"
#include "FileIO.ch"

#define Less(xVal1, xVal2) Iif(xVal1 < xVal2, xVal1, xVal2)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³JFunG002  ºAutor  ³Microsiga           º Data ³  08/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ O programa executa a query definida no arquivo texto e     º±±
±±º          ³ de acordo com os parametros definidos.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß


Criar Parâmetro                   
---------------
Parâmetro:       JW_QRYDIR
Tipo:            C
Descrição:       Parâmetro customizado: Diretório para busca das queries a serem executadas
Conteúdo:        \qry\


Exemplo de arquivo 
------------------

; Definição dos formatos do arquivo
; Todo comentário deve ser precedido por ';'. O comentário pode ocorrer tanto no inicio de uma linha ou no final.
; As linhas em branco serão descartadas

[OWN]; A seção OWN (Owner) define quem serão os usuários ou grupo aptos a usar a query 
ALL ; Define que todos os usuários terão acesso ao arquivo
USR=000000,000001,000002,000003 ; Identifica os usuários que terão acesso ao relatório
GRP=000000,000001,000002 ; Identifica os grupos de usuário que terão acesso

[DEF]; definição do que a query faz, aparecerá na base da tela como ajuda para no momento da seleção do arquivo a ser executado.
ESSE É UM TESTE DE UM ARQUIVO INI PARA QUERIES.

[ASK]; Define a pergunta a ser executa
ASK=POXXXX ; Nome da pergunta deve ter no máximo 10 caracteres. 
;{ <Pergunta> (C, 30), <Tipo>("C", "N", "D"), <Tamanho> (@E99), <Decimal>(@E99),  <GSC>("G", "C"), <Def1> (C 15), <Def2> (C 15), <Def3> (C 15), <Def4> (C 15), <Def5> (C 15), <F3> (C 3), {<Ajuda para pergunta>, <Ajuda para pergunta>} }
;        123456789012345678901234567890                                              123456789012345678901234567890    123456789012345678901234567890
PAR01={ "Emissão de?                   ", "D", 8, 0, "G", "", "", "", "", "", "", { "Digite a data inicial para a  ", "busca.                        "} }
PAR02={ "Emissão até?                  ", "D", 8, 0, "G", "", "", "", "", "", "", { "Digite a data final para a    ", "busca.                        "} }
; Obs 1: Parametro deve iniciar sempre com 01 Ex: PAR01
; Obs 2: No máximo podem haver 60 parâmetros


[PRE]; Executa funções antes de executar a query. 
; Voce pode utilizar a função _SetOwnerPrvt() ou _SetNamedPrvt() para setar variaveis que serão utilizadas 
; nessa query.
; Todas as variáveis do sistema deverão ser passadas entre caracteres '#'. Ex: SD2.D2_EMISSAO BETWEEN '#mv_par01#' AND '#mv_par02#'
; A Propria rotina já converte o tipo de dado para o adequado. não é necessário que seja feito cast.
;
MATA010()
U_PCOMR01()

[PRC]; Executa procedimentos em arquivos .slq salvos na pasta definida em JW_QRYDIR
; no caso de Storage procedures, deve-se criar apenas a SP no arquivo e ela não deve ter parâmetros
proc01.sql ; Nome do arquivo que contem os procedimentos
proc02.sql
procxx.sql

[QRY]; Query a ser executada.
          select SB1.B1_COD Produto, 
                 B1_DESC "Descrição", 
                 B1_TIPO Tipo, SUM(SB2.B2_QATU) "Qtd Estoque",
--                 case when SD1TOT.D1_QUANT is NULL then 0 else SD1TOT.D1_QUANT end "Qtde Comprada",
--                 case when SD3TOT.D3_QUANT is NULL then 0 else SD3TOT.D3_QUANT end "Qtde Produzida"
            from SB2010 SB2 
            join SB1010 SB1
              on SB1.D_E_L_E_T_ = ' '
             and SB1.B1_FILIAL  = '  '
             and SB1.B1_COD     = SB2.B2_COD
             and SB1.B1_TIPO    IN ('PA', 'PR')
       left join SD2010 SD2
              on SD2.D_E_L_E_T_ = ' '
             and SD2.D2_FILIAL  = '01'
             and SD2.D2_COD     = SB2.B2_COD
             and SD2.D2_EMISSAO BETWEEN '#mv_par01#' AND '#mv_par02#'
       left join (
              select D1_COD, SUM(D1_QUANT) D1_QUANT
               from SD1010 SD1
               join SB1010 SB1
                 on SB1.D_E_L_E_T_ = ' '
                and SB1.B1_FILIAL  = '  '
                and SB1.B1_COD     = SD1.D1_COD
                and SB1.B1_TIPO    IN ('PA', 'PR')
               join SF4010 SF4
                 on SF4.D_E_L_E_T_ = ' '
                and SF4.F4_FILIAL  = '  '
                and SF4.F4_CODIGO  = SD1.D1_TES
                and SF4.F4_CODIGO  <= '500'
                and SUBSTRING(SF4.F4_CF,2,3) IN ('101', '102')
              where SD1.D_E_L_E_T_ = ' '
                and SD1.D1_FILIAL  = '01'
                and SD1.D1_EMISSAO BETWEEN '#mv_par01#' AND '#mv_par02#'
           group by D1_COD
       ) SD1TOT 
              on SD1TOT.D1_COD = SB2.B2_COD
             and SD1TOT.D1_COD is NULL
       left join (
              select D3_COD, SUM(D3_QUANT) D3_QUANT
               from SD3010 SD3
               join SB1010 SB1
                 on SB1.D_E_L_E_T_ = ' '
                and SB1.B1_FILIAL  = '  '
                and SB1.B1_COD     = SD3.D3_COD
                and SB1.B1_TIPO    IN ('PA', 'PR')
              where SD3.D_E_L_E_T_ = ' '
                and SD3.D3_FILIAL  = '01'
                and SD3.D3_EMISSAO BETWEEN '#mv_par01#' AND '#mv_par02#'
                and SD3.D3_OP      <> '             '
                and D3_TM          =  '010'
                and D3_CF          LIKE 'PR%'
           group by D3_COD
       ) SD3TOT 
              on SD3TOT.D3_COD = SB2.B2_COD
             and SD3TOT.D3_COD is NULL
           where SB2.D_E_L_E_T_ = ' '
             and SB2.B2_FILIAL  = '01'
             and SB2.B2_QATU    > 0
        group by SB1.B1_COD, B1_DESC, B1_TIPO--, SD1TOT.D1_QUANT, SD3TOT.D3_QUANT
          having SUM( case when SD2.D2_COD is null then 0 else SD2.D2_QUANT end) = 0



[POS]; Funções a serem executadas apos a execução da query e criação do array Private aDados. Voce pode manipular o array, apenas tome o cuidade de não criar
; mais que 2 dimensões para que não haja erro.
MTA010()
U_PESTA01()


------------------


*/

Static nPosOWN := 1
Static nPosDEF := 2
Static nPosASK := 3
Static nPosPRE := 4
Static nPosQRY := 5
Static nPosPOS := 6
Static nPosPRC := 7
Static nQtdSec := 7


User Function VARunQry()        // u_VARunQry()
Local cFile      := ""  

Private cDirQry    := SuperGetMv("PO_QRYDIR",.F.,"/_Relatorios/")
Private aDados     := {}

   cDirQry    := cDirQry+Iif(SubStr(cDirQry,Len(cDirQry),1)=="/","","/")
      
   If !Empty(cFile := ListQrys())
      Processa({ || RunQry( cFile ) }, "Consultas")
   Endif 
Return Nil

Static Function RunQry( cFile )
Local aQry       := {}
Local cPerg      := ""
Local nLen       := 0
Local i          := 0
Local aRecord    := {}
Local lError     := .F.

   ProcRegua(7)

   IncProc("Interpretando Script...")
   aQry := Parse(cDirQry+cFile)
      
   IncProc("Avaliando pergunta...")
   If !Empty(aQry[nPosASK])
      GeraX1(@cPerg, aQry[nPosASK])
      If !Pergunte(cPerg, .T.)
         Return Nil
      EndIf
   Endif
      
   IncProc("Avaliando pré-condições...")
   If !Empty(aQry[nPosPRE])
      nLen := Len(aQry[nPosPRE])
      For i := 1 To nLen
         &(aQry[nPosPRE][i])
      Next
   EndIf
      
   IncProc("Executando procedures ... aguarde. ")
   If !Empty(aQry[nPosPRC])
      If !EvalProcs(aQry[nPosPRC])
         Return Nil 
      EndIf                                                 
   EndIf


   IncProc("Executando query aguarde... ")
   If !Empty(aQry[nPosQRY])

      aQry[nPosQRY] := UpdVars( aQry[nPosQRY] )

      DbUseArea(.T.,"TOPCONN",TCGenQry(,,aQry[nPosQRY]),"TMPTBL",.F.,.F.)
         
         IncProc("Criando ADADOS aguarde...")

         nLen := TMPTBL->(FCount())
         For i := 1 To nLen
            AAdd(aRecord, Upper(SubStr(TMPTBL->(FieldName(i)), 1, 1))+SubStr(Lower(TMPTBL->(FieldName(i))),2))
         Next
         AAdd(aDados, aRecord)
      
         While !TMPTBL->(Eof())
            aRecord := {}
            For i := 1 To nLen
               AAdd(aRecord, TMPTBL->(FieldGet(i)))
            Next
            AAdd(aDados, aRecord)
            TMPTBL->(DbSkip())
         End

      TMPTBL->(DbCloseArea())
      
   EndIf

   IncProc("Avaliando pós-condições...")
   If !Empty(aQry[nPosPOS])
      nLen := Len(aQry[nPosPOS])
      For i := 1 To nLen
         &(aQry[nPosPOS][i])
      Next
   EndIf

   IncProc("Criando arquivo Excell...")
   cFileName := MkExcWB( aDados )
   If (CpyS2T(GetSrvProfString ("STARTPATH","")+cFileName, Alltrim(GetTempPath())))
      fErase(cFileName)

      // Abre excell
      If !ApOleClient( 'MsExcel' )
         MsgAlert("O excel não foi encontrado. Arquivo " + cFileName + " gerado em " + GetTempPath() + ".", "MsExcel não encontrado" )
      Else
         oExcelApp := MsExcel():New()
         oExcelApp:WorkBooks:Open( GetTempPath()+cFileName )
         oExcelApp:SetVisible(.T.)
      EndIf
   Else
      MsgAlert("Não foi possivel criar o arquivo " + cFileName + " no cliente no diretório " + GetTempPath() + ". Por favor, contacte o suporte.", "Não foi possivel criar Planilha." )
   EndIf

Return Nil

Static Function  EvalProcs(aProcs)
Local i           := 0
Local nLen        := 0
Local lRet        := .T.

      nLen := Len(aProcs)
      For i := 1 To nLen 

         cProc := LoadProc(aProcs[i])
         cProc := UpdVars(cProc)
         
         If (nPosProc := At("PROCEDURE", Upper(cProc))) > 0 .and. At("CREATE", Upper(cProc)) > 0
            cNameProc := AllTrim(SubStr(cProc, nPosProc + Len("PROCEDURE")))
            cNameProc := AllTrim(SubStr(cNameProc,1,Less(At(CRLF, Upper(cNameProc)), Less(At(" ", Upper(cNameProc)),At("(", Upper(cNameProc))))-1))
            
            If !TCSPExist(cNameProc)
               If (TCSQLExec(cProc) < 0)    
                  MsgStop("TCSQLError() " + TCSQLError())
                  lRet := .F.  
               EndIf            
            EndIf
            
            TCSPExec(cNameProc)
            
         ElseIf (TCSQLExec(cProc) < 0)    
            MsgStop("TCSQLError() " + TCSQLError())
            lRet := .F.  
         EndIf
      Next

Return lRet

Static Function LoadProc(cFile)
Local cProc := ""
Local cLin  := "" 

FT_FUse(cDirQry+cFile)

   FT_FGoTop()
   While !FT_FEOF()
      cLin := AllTrim(FT_FReadLn())
      // Remove comentários
      If (nPos := At(";", cLin)) > 0
         If nPos == 1
            cLin := ""
         Else
            cLin := SubStr(cLin, 1, nPos-1)
         EndIf
      EndIf
   
      // Remove comentários
      If (nPos := At("--", cLin)) > 0
         If nPos == 1
            cLin := ""
         Else
            cLin := SubStr(cLin, 1, nPos-1)
         EndIf
      EndIf      
      cProc += cLinl + CRLF
      FT_FSkip()
   End 

FT_FUse()

Return cProc


Static Function UpdVars( cStream )
Local nPosStart  := 0
Local cVar       := ""
Local xVal       := Nil
Local cType      := ""

   While (nPosStart := At("#", cStream)) > 0
      cVar := SubStr(cStream ,nPosStart+1)
      cVar := SubStr(cVar, 1, At("#", cVar)-1)
      cType := Type(cVar)
      If cType == 'C'
         xVal := &(cVar)
      ElseIf cType == 'D'
         xVal := DToS(&(cVar))
      ElseIf cType == 'N'
         xVal := AllTrim(Str(&(cVar)))
      ElseIf cType == 'UI'
         xVal := &(cVar)
      ElseIf cType == 'U'
         xVal := "NULL"
      EndIf
      cStream := StrTran(cStream, "#"+cVar+"#",xVal) 
   End

Return cStream

Static Function ListQrys()
Local oDlg       := Nil, oCmbIdx    := Nil, oGetIdx    := Nil, oGDQry     := Nil, oBtnOK     := Nil, oBtnCan    := Nil, oSEdit     := Nil
Local aWndPos    := {0, 0, 390, 515}
Local lCenter    := .T.
Local cCboSel    := ""
Local cGetVar    := "" 
Local nOpcA      := 0
Local bChange    := {||.T.}
Local cFileName  := ""

Private aHelp      := {}
Private aHeader    := GetAHeader()
Private aCols      := GetACols()
Private nGDOpc     := 0
Private aArqs      := {}

If FindProfDef(cUserName, "CONPAD", "CONFIG", "WNDSIZE")
   aWndPos := Str2Array(RetProfDef(cUserName,"CONPAD", "CONFIG", "WNDSIZE"))
   lCenter := FlatMode()
EndIf

oDlg    := MSDialog():New( 86 , 391, 413 , 907 , "Selecione a consulta a ser executada",         ,         ,          ,         ,          ,           ,           , oMainWnd, .T.)
oGDQry  := MsNewGetDados():New(002, 002, 148, 258, nGDOpc,,,,,,,,,,oDlg, aHeader, aCols, { || oSEdit:Load(aHelp[oGDQry:oBrowse:nAt]) } )
oSEdit  := TSimpleEditor():New(150, 002, oDlg, 256, 030 ) //,,.T.,,.T.)
oSEdit:Load(aHelp[1])
oBtnOk  := tButton():New(150, 002, "Ok", oDlg, { || nOpcA := 1, oDlg:End() }, 030, 012,,,,.T.)
oBtnCan := tButton():New(150, 034, "Cancelar", oDlg, { || nOpcA := 0, oDlg:End() }, 030, 012,,,,.T.)
oDlg:Activate(,,,lCenter)

If nOpcA == 1
   cFileName := oGDQry:aCols[oGDQry:nAt][1]
Endif

Return cFileName

Static Function GetAHeader()
Local aHeader := {; 
                   { "Consulta",;         // X3_TITULO
                     "POQRY",;            // X3_CAMPO
                     "@!",;               // X3_PICTURE
                     40,;                 // X3_TAMANHO
                     0,;                  // X3_DECIMAL
                     "",;                 // X3_VALID
                     "€€€€€€€€€€€€€€ ",;  // X3_USADO
      	              "C",;                // X3_TIPO
                     "",;                 // X3_F3
                     "V",;                // X3_CONTEXT
                     "",;                 // X3_CBOX
                     "",;                 // X3_RELACAO
                     "",;                 // SX3->X3_WHEN
                     "V",;                // SX3->X3_VISUAL
                     "",;                 // SX3->X3_VLDUSER
                     "",;                 // SX3->X3_PICTVAR
                     "";                  // X3Obrigat(SX3->X3_CAMPO)
                   };
                 }
Return aHeader

Static Function GetACols()
Local aCols      := {}
Local nLen       := 0
Local i          := 0, j          := 0
Local aFiles     := Directory(cDirQry+Iif(SubStr(cDirQry,Len(cDirQry),1)=="\", "", "\")+"*.qry",,,.F.)
Local aQry       := {}
Local nPos       := 0
Local lApprove   := .F.

AAdd( aCols, {Space(40),.F.} )
AAdd( aHelp, Space(30))

   nLen := Len(aFiles)
   For i := 1 To nLen

      lApprove := .F.
      aQry := Parse(cDirQry+aFiles[i][1])
      If ( nPos := aScan( aQry[1], { |aMat| Upper(aMat[1]) == 'ALL' } ) ) > 0
         lApprove := .T.
      EndIf
      
      If !lApprove .AND. ( nPos := aScan( aQry[1], { |aMat| Upper(aMat[1]) == 'USR' } ) ) > 0
         If At(__cUserID, aQry[1][nPos][2]) > 0
            lApprove := .T.
         EndIf
      EndIf

      If !lApprove .AND. ( nPos := aScan( aQry[1], { |aMat| Upper(aMat[1]) == 'GRP' } ) ) > 0
         PswSeek(__cUserId, .T.)
         If !Empty(aGroups := PswRet(1))
            For j := 1 To Len(aGroups[1][10])
               If AllTrim(aGroups[1][10][j])$aQry[1][nPos][2]
                  lApprove := .T.
                  Exit
               EndIf
            Next
         EndIf
      EndIf

      If lApprove 
         If Empty(aCols[1][1])
            aCols[1][1] := aFiles[i][1]
            aHelp[1] := aQry[2]
         Else
            AAdd( aCols, {aFiles[i][1],.F.} )
            AAdd( aHelp, aQry[2])
         EndIf
      EndIf

   Next

Return aCols

Static Function Parse(cFile)
Local cLin       := ""
Local lOWN       := .F.
Local lDEF       := .F.
Local lASK       := .F.
Local lPRE       := .F.
Local lPRC       := .F.
Local lQRY       := .F.
Local lPOS       := .F.
Local aFile      := {} 
Local nPos       := 0

aFile := Array(nQtdSec)
aFile[nPosOWN] := {}
aFile[nPosDEF] := ""
aFile[nPosASK] := {}
aFile[nPosPRE] := {}
aFile[nPosPRC] := {}
aFile[nPosQRY] := ""
aFile[nPosPOS] := {}

If FT_FUse(cFile) > 0
	While !FT_FEof()
	   cLin := AllTrim(FT_FReadLn())
	   
	   // Remove comentários
	   If (nPos := At(";", cLin)) > 0
	      If nPos == 1
	         cLin := ""
	      Else
	         cLin := SubStr(cLin, 1, nPos-1)
	      EndIf
	   EndIf
	   
	   // Remove comentários
	   If (nPos := At("--", cLin)) > 0
	      If nPos == 1
	         cLin := ""
	      Else
	         cLin := SubStr(cLin, 1, nPos-1)
	      EndIf
	   EndIf
	
	   If Empty(cLin)
	      FT_FSkip()
	      Loop
	   ElseIf SubStr(cLin, 1, 1) == '['
	      cSection := SubStr(cLin, 1, 5)
	      lOWN := cSection == "[OWN]"
	      lDEF := cSection == "[DEF]" 
	      lASK := cSection == "[ASK]"
	      lPRE := cSection == "[PRE]"
	      lPRC := cSection == "[PRC]"
	      lQRY := cSection == "[QRY]"
	      lPOS := cSection == "[POS]"
	   Else
	      If lOWN
	         If SubStr(cLin,1,3)=="ALL"
	               AAdd(aFile[nPosOWN], {"ALL", ""})
	         ElseIf SubStr(cLin,1,3)=="USR"
	            If At("=",cLin) > 0 .AND. !Empty(SubStr(cLin,At("=",cLin)+1))
	               AAdd(aFile[nPosOWN], {"USR", SubStr(cLin,At("=",cLin)+1)})
	            EndIf
	         ElseIf SubStr(AllTrim(cLin),1,3)=="GRP"
	            If At("=",cLin) > 0 .AND. !Empty(SubStr(cLin,At("=",cLin)+1))
	               AAdd(aFile[nPosOWN], {"GRP", SubStr(cLin,At("=",cLin)+1)})
	            EndIf
	         Endif
	      ElseIf lDEF
	         aFile[nPosDEF] += cLin 
	      ElseIf lASK
	         If SubStr(cLin,1,3)=="ASK"
	            If At("=",cLin) > 0 .AND. !Empty(SubStr(cLin,At("=",cLin)+1))
	               AAdd(aFile[nPosASK], {"ASK", SubStr(cLin,At("=",cLin)+1)})
	            EndIf
	         ElseIf SubStr(cLin,1,3) == "PAR"
	            If At("=",cLin) > 0 .AND. !Empty(SubStr(cLin,At("=",cLin)+1))
	               AAdd(aFile[nPosASK], { SubStr(cLin,4, 2), &(SubStr(cLin,At("=",cLin)+1)) } )
	            EndIf
	         EndIf
	      ElseIf lPRE
	         AAdd(aFile[nPosPRE], cLin)
	      ElseIf lPRC
	         AAdd(aFile[nPosPRC], cLin)
	      ElseIf lQRY
	         aFile[nPosQRY] += " " + cLin
	      ElseIf lPOS
	         AAdd(aFile[nPosPOS], cLin)
	      EndIf
	   EndIf
	   FT_FSkip()
	EndDo
EndIf
FT_FUse()
Return aFile

Static Function MkExcWB( aItens )
Local cCreate   := AllTrim( Str( Year( dDataBase ) ) ) + "-" + AllTrim( Str( Month( dDataBase ) ) ) + "-" + AllTrim( Str( Day( dDataBase ) ) ) + "T" + SubStr( Time(), 1, 2 ) + ":" + SubStr( Time(), 4, 2 ) + ":" + SubStr( Time(), 7, 2 ) + "Z" // string de data no formato <Ano>-<Mes>-<Dia>T<Hora>:<Minuto>:<Segundo>Z
Local i, j, k
Local cWorkBook := ""
Local cFileName := CriaTrab(,.F.)+".xml"

If !( nHandle := FCreate( cFileName, FC_NORMAL ) ) != -1
	MsgAlert("Não foi possivel criar a planilha [" + cFileName + "]. Por favor, verifique se existe espaço em disco ou você possui pemissão de escrita no diretório \system\", "Erro de criação de arquivo")
	Return
EndIf

cWorkBook := "<?xml version=" + Chr(34) + "1.0" + Chr(34) + "?>" + Chr(13) + Chr(10)
cWorkBook += "<?mso-application progid=" + Chr(34) + "Excel.Sheet" + Chr(34) + "?>" + Chr(13) + Chr(10)
cWorkBook += "<Workbook xmlns=" + Chr(34) + "urn:schemas-microsoft-com:office:spreadsheet" + Chr(34) + " " + Chr(13) + Chr(10)
cWorkBook += "	xmlns:o=" + Chr(34) + "urn:schemas-microsoft-com:office:office" + Chr(34) + " " + Chr(13) + Chr(10)
cWorkBook += "	xmlns:x=" + Chr(34) + "urn:schemas-microsoft-com:office:excel" + Chr(34) + " " + Chr(13) + Chr(10)
cWorkBook += "	xmlns:ss=" + Chr(34) + "urn:schemas-microsoft-com:office:spreadsheet" + Chr(34) + " " + Chr(13) + Chr(10)
cWorkBook += "	xmlns:html=" + Chr(34) + "http://www.w3.org/TR/REC-html40" + Chr(34) + ">" + Chr(13) + Chr(10)
cWorkBook += "	<DocumentProperties xmlns=" + Chr(34) + "urn:schemas-microsoft-com:office:office" + Chr(34) + ">" + Chr(13) + Chr(10)
cWorkBook += "		<Author>" + AllTrim(SubStr(cUsuario,7,15)) + "</Author>" + Chr(13) + Chr(10)
cWorkBook += "		<LastAuthor>" + AllTrim(SubStr(cUsuario,7,15)) + "</LastAuthor>" + Chr(13) + Chr(10)
cWorkBook += "		<Created>" + cCreate + "</Created>" + Chr(13) + Chr(10)
cWorkBook += "		<Company>Microsiga Intelligence</Company>" + Chr(13) + Chr(10)
cWorkBook += "		<Version>11.6568</Version>" + Chr(13) + Chr(10)
cWorkBook += "	</DocumentProperties>" + Chr(13) + Chr(10)
cWorkBook += "	<ExcelWorkbook xmlns=" + Chr(34) + "urn:schemas-microsoft-com:office:excel" + Chr(34) + ">" + Chr(13) + Chr(10)
cWorkBook += "		<WindowHeight>9345</WindowHeight>" + Chr(13) + Chr(10)
cWorkBook += "		<WindowWidth>11340</WindowWidth>" + Chr(13) + Chr(10)
cWorkBook += "		<WindowTopX>480</WindowTopX>" + Chr(13) + Chr(10)
cWorkBook += "		<WindowTopY>60</WindowTopY>" + Chr(13) + Chr(10)
cWorkBook += "		<ProtectStructure>False</ProtectStructure>" + Chr(13) + Chr(10)
cWorkBook += "		<ProtectWindows>False</ProtectWindows>" + Chr(13) + Chr(10)
cWorkBook += "	</ExcelWorkbook>" + Chr(13) + Chr(10)
cWorkBook += "	<Styles>" + Chr(13) + Chr(10)
cWorkBook += "		<Style ss:ID=" + Chr(34) + "Default" + Chr(34) + " ss:Name=" + Chr(34) + "Normal" + Chr(34) + ">" + Chr(13) + Chr(10)
cWorkBook += "			<Alignment ss:Vertical=" + Chr(34) + "Bottom" + Chr(34) + "/>" + Chr(13) + Chr(10)
cWorkBook += "			<Borders/>" + Chr(13) + Chr(10)
cWorkBook += "			<Font/>" + Chr(13) + Chr(10)
cWorkBook += "			<Interior/>" + Chr(13) + Chr(10)
cWorkBook += "			<NumberFormat/>" + Chr(13) + Chr(10)
cWorkBook += "			<Protection/>" + Chr(13) + Chr(10)
cWorkBook += "		</Style>" + Chr(13) + Chr(10)
cWorkBook += "	<Style ss:ID=" + Chr(34) + "s21" + Chr(34) + ">" + Chr(13) + Chr(10)
cWorkBook += "		<NumberFormat ss:Format=" + Chr(34) + "Short Date" + Chr(34) + "/>" + Chr(13) + Chr(10)
cWorkBook += "	</Style>" + Chr(13) + Chr(10)
cWorkBook += "	</Styles>" + Chr(13) + Chr(10)

cWorkBook += "	<Worksheet ss:Name=" + Chr(34) + cFileName + Chr(34) + ">" + Chr(13) + Chr(10)
cWorkBook += "		<Table>" + Chr(13) + Chr(10)

FWrite(nHandle, cWorkBook)
cWorkBook := ""

nQtdLine := Len(aItens)
For i := 1 To nQtdLine
	cWorkBook += "			<Row>" + Chr(13) + Chr(10)
	nLenLine := Len(aItens[i])
	For j := 1 To nLenLine
		cWorkBook += "				" + FS_GetCell(aItens[i][j]) + Chr(13) + Chr(10)
	Next
	cWorkBook += "			</Row>" + Chr(13) + Chr(10)
	FWrite(nHandle, cWorkBook)
	cWorkBook := ""
Next
	
cWorkBook += "		</Table>" + Chr(13) + Chr(10)
cWorkBook += "		<WorksheetOptions xmlns=" + Chr(34) + "urn:schemas-microsoft-com:office:excel" + Chr(34) + ">" + Chr(13) + Chr(10)
cWorkBook += "			<PageSetup>" + Chr(13) + Chr(10)
cWorkBook += "				<Header x:Margin=" + Chr(34) + "0.49212598499999999" + Chr(34) + "/>" + Chr(13) + Chr(10)
cWorkBook += "				<Footer x:Margin=" + Chr(34) + "0.49212598499999999" + Chr(34) + "/>" + Chr(13) + Chr(10)
cWorkBook += "				<PageMargins x:Bottom=" + Chr(34) + "0.984251969" + Chr(34) + " x:Left=" + Chr(34) + "0.78740157499999996" + Chr(34) + " x:Right=" + Chr(34) + "0.78740157499999996" + Chr(34) + " x:Top=" + Chr(34) + "0.984251969" + Chr(34) + "/>" + Chr(13) + Chr(10)
cWorkBook += "			</PageSetup>" + Chr(13) + Chr(10)
cWorkBook += "			<Selected/>" + Chr(13) + Chr(10)
cWorkBook += "			<ProtectObjects>False</ProtectObjects>" + Chr(13) + Chr(10)
cWorkBook += "			<ProtectScenarios>False</ProtectScenarios>" + Chr(13) + Chr(10)
cWorkBook += "		</WorksheetOptions>" + Chr(13) + Chr(10)
cWorkBook += "	</Worksheet>" + Chr(13) + Chr(10)
FWrite(nHandle, cWorkBook)
cWorkBook := ""
cWorkBook += "</Workbook>" + Chr(13) + Chr(10)

FWrite(nHandle, cWorkBook)
cWorkBook := ""
FClose(nHandle)

Return cFileName


Static Function FS_GetCell( xVar )
Local cRet  := ""
Local cType := ValType(xVar)

If cType == "U"
	cRet := "<Cell><Data ss:Type=" + Chr(34) + "General" + Chr(34) + "></Data></Cell>"
ElseIf cType == "C"
	cRet := "<Cell><Data ss:Type=" + Chr(34) + "String" + Chr(34) + ">" + Format( xVar ) + "</Data></Cell>"
ElseIf cType == "N"
	cRet := "<Cell><Data ss:Type=" + Chr(34) + "Number" + Chr(34) + ">" + AllTrim( Str( xVar ) ) + "</Data></Cell>"
ElseIf cType == "D"
	xVar := DToS( xVar )
	cRet := "<Cell ss:StyleID=" + Chr(34) + "s21" + Chr(34) + "><Data ss:Type=" + Chr(34) + "DateTime" + Chr(34) + ">" + SubStr(xVar, 1, 4) + "-" + SubStr(xVar, 5, 2) + "-" + SubStr(xVar, 7, 2) + "T00:00:00.000</Data></Cell>"
Else
	cRet := "<Cell><Data ss:Type=" + Chr(34) + "Boolean" + Chr(34) + ">" + Iif ( xVar , "=VERDADEIRO" ,  "=FALSO" ) + "</Data></Cell>"
EndIf

Return cRet

Static Function Format( cVar )
Local nLen := 0
Local i    := 0
Local aPad := { { 'ã', 'a' }, { 'á' , 'a' }, { 'â', 'a' }, { 'ä', 'a' }, ;
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
For i := 1 To nLen
   cVar := StrTran(cVar, aPad[i][1], aPad[i][2])
Next
Return AllTrim(cVar)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GeraX1   ³ Autor ³ MICROSIGA             ³ Data ³   /  /   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica as perguntas inclu¡ndo-as caso n„o existam        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Uso Generico.                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

/**
 * GeraX1(cPerg, aRegs)
 * Cria uma pergunta de acordo com os parâmetros passados.
 * BNF
 * @param cPerg Identificação da Pergunta
 * @param aRegs Matriz contendo os dados da pergunta no formato 
 * '{' <Desc Pergunta>, <Tipo>, <Tamanho>, <Decimal>, <GSC>, <Def1>, <Def2>, <Def3>, <Def4>, <Def5>, <F3>, '{' <Desc Help>  {, <Desc Help> } '}' '}'
 * 
 * @autor André Cruz
 */
Static Function GeraX1(cPerg, aRegs)
Local aArea    := GetArea()
Local i        := 0
Local j        := 0
Local nLen     := 0
Local aPerg    := {}
Local aHelpPor := {}
Local aHelpEng := {}
Local aHelpSpa := {}

   nLen := Len(aRegs)
   For i := 1 To nLen
      If aRegs[i][1] == "ASK"
         cPerg := PadR(aRegs[i][2], Len(SX1->X1_GRUPO))
      Else
//  1          2          3          4          5          6          7          8          9          0
//0 X1_GRUPO   X1_ORDEM   X1_PERGUNT X1_PERSPA  X1_PERENG  X1_VARIAVL X1_TIPO    X1_TAMANHO X1_DECIMAL X1_PRESEL  
//1 X1_GSC     X1_VALID   X1_VAR01   X1_DEF01   X1_DEFSPA1 X1_DEFENG1 X1_CNT01   X1_VAR02   X1_DEF02   X1_DEFSPA2 
//2 X1_DEFENG2 X1_CNT02   X1_VAR03   X1_DEF03   X1_DEFSPA3 X1_DEFENG3 X1_CNT03   X1_VAR04   X1_DEF04   X1_DEFSPA4 
//3 X1_DEFENG4 X1_CNT04   X1_VAR05   X1_DEF05   X1_DEFSPA5 X1_DEFENG5 X1_CNT05   X1_F3      X1_PYME    X1_GRPSXG  
//4 X1_HELP    X1_PICTURE X1_IDFIL

         //             1      2            3                          4   5   6                            7               8               9               0   1               2   3                     4               5   6   7   8   9               0   1   2   3   4               5   6   7   8   9               0   1   2   3   4                5   6   7   8                9   0   1   2   3
         AAdd( aPerg, { cPerg, aRegs[i][1], OemToAnsi(aRegs[i][2][1]), "", "", "mv_ch"+GetPar(aRegs[i][1]), aRegs[i][2][2], aRegs[i][2][3], aRegs[i][2][4], 00, aRegs[i][2][5], "", "mv_par"+aRegs[i][1], aRegs[i][2][6], "", "", "", "", aRegs[i][2][7], "", "", "", "", aRegs[i][2][8], "", "", "", "", aRegs[i][2][9], "", "", "", "", aRegs[i][2][10], "", "", "", aRegs[i][2][11], "", "", "", "", "" } )

         If Len(aRegs[i][2]) == 12
            If Len(aRegs[i][2]) < 12
               AAdd( aHelpPor, { Space(30) } )
            Else
               AAdd( aHelpPor, aRegs[i][2][12] )
            EndIf
         EndIf
      EndIf
   Next
   
   DbSelectArea( "SX1" )
   DbSetOrder(1)
   
   For i := 1 To Len( aPerg )
      If !SX1->(DbSeek(cPerg+aPerg[i][2]))
         
         RecLock("SX1",.T.)
         For j := 1 To FCount()
            If j <= Len(aPerg[i])
               FieldPut(j,aPerg[i][j])
            EndIf
         Next
         MsUnlock()
         
         PutSX1Help( "P."+AllTrim(SX1->X1_GRUPO)+AllTrim(SX1->X1_ORDEM)+".", aHelpPor[i], aHelpEng, aHelpSpa )

      EndIf
   Next

   RestArea(aArea)
Return Nil

Static Function SetHelp()
Local aHelpPor := {}
Local aHelpEng := {}
Local aHelpSpa := {}

If Empty(GetHelp("RUNQRY001"))
   aHelpPor := {}
   //               123456789012345678901234567890
   AAdd( aHelpPor, {"Não existe query que possa ser"} )
   AAdd( aHelpPor, {"utilizada pelo seu usuário.   "} )
   AAdd( aHelpPor, {"                              "} )
   PutHelp("PRUNQRY001",aHelpPor,aHelpEng,aHelpSpa,.T.)

   aHelpPor := {}
   //               123456789012345678901234567890
   AAdd( aHelpPor, {"Entre em contato com o        "} )
   AAdd( aHelpPor, {"Suporte.                      "} )
   PutHelp( "SRUNQRY001", aHelpPor, aHelpEng, aHelpSpa, .T. )
EndIf

Return Nil

Static Function GetPar(cNumber)
Return ({'1','2','3','4','5','6','7','8','9','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'})[Val(cNumber)]

Static Function RunFunc( cFunc )
Private aItens := {}
Private lMsg   := .F.

	If Select("SM0") == 0 
		dbUseArea( .T.,, "SIGAMAT.EMP", "SM0", .T., .F. )
		dbSetIndex("SIGAMAT.IND")
	
		DbSelectArea("SM0")
		DbSetorder(1)
	EndIf
	
	RpcSetType(3)
	RpcSetEnv(SM0->M0_CODIGO,SM0->M0_CODFIL)
	&(cFunc)
	RpcClearEnv()

Return Nil

User Function RQInSql(aOpc, xOpc, xAllOpc)
Local cInSql := ""
Local i      := 0
Local nLen   := Len(aOpc)

If xOpc == xAllOpc
   For i := 1 To nLen
      If aOpc[i] <> xOpc
         cInSql += Iif(Empty(cInSql), "", ", ") + "'" + aOpc[i] + "'"
      EndIf
   Next
Else 
   cInSql := "'" + xOpc + "'"
EndIf
Return cInSql

