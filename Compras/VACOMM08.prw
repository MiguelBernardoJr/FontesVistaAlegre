#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "RWMAKE.CH"

/*----------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                         |
 | Data:     11.06.2018                                                             |
 | Cliente:  V@                                                                     |
 | Desc:     Este Fonte sera utilizadao para dar manutencao nos campos customi-     |
 |         zados da tabela SD1: Itens da Nota Fiscal de Entrada.                    |
 | Obs.:     -                                                                      |
 '----------------------------------------------------------------------------------*/
User Function VACOMM08()	// U_VACOMM08()

Private oBrowse 
Private cCadastro  := "Alteração de Itens do Documento de Entrada"
Private cAlias     := "SF1" 
Private aRotina    := MenuDef()

	oBrowse := FWMBrowse():New()
	
	oBrowse:SetAlias( cAlias )   
	oBrowse:SetMenuDef("VACOMM08")
	oBrowse:SetDescription( cCadastro )
	// oBrowse:SetFilterDefault( "B8_SALDO > 0" )
	
	// aFields := LoadFields()
	// oBrowse:SetFields(aFields)
	
	oBrowse:Activate()

Return nil


/*----------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                         |
 | Data:     11.06.2018                                                             |
 | Cliente:  V@                                                                     |
 | Desc:     Definicoes dos MENUSs externos;                                        |
 |                                                                                  |
 | Obs.:     -                                                                      |
 '----------------------------------------------------------------------------------*/
Static Function MenuDef()
Local aRotina := {}
	aAdd( aRotina, { 'Pesquisar'  			, 'AxPesqui'   , 0, 1, 0, NIL } )
	aAdd( aRotina, { 'Visualizar' 			, 'AxVisual'   , 0, 2, 0, NIL } ) 
	aAdd( aRotina, { 'Alterar'              , 'U_COMM08MNT', 0, 4, 0, Nil } )
	// aAdd( aRotina, { 'Incluir'              , 'AxInclui', 0, 3, 0, NIL } )
	// aAdd( aRotina, { 'Alterar'    			, 'U_FATB01Alt', 0, 4, 0, NIL } ) 
	//aAdd( aRotina, { 'Excluir'              , 'AxDeleta', 0, 5, 0, NIL } ) // aAdd( aRotina, { 'Legenda'         		, 'U_VAM07Leg', 0, 7, 0, NIL } )
	// aAdd( aRotina, { 'Relacionar NF Entrada', 'U_VAFATB02' , 0, 4, 0, NIL } )

Return aRotina


/*----------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                         |
 | Data:     18.06.2018                                                             |
 | Cliente:  V@                                                                     |
 | Desc:     Definicoes dos MENUSs externos;                                        |
 |                                                                                  |
 | Obs.:     -                                                                      |
 '----------------------------------------------------------------------------------*/
User Function COMM08MNT(cAlias, nReg, nOpc)
Local aArea			:= GetArea()
Local nOpcA
Local nGDOpc        := GD_UPDATE
Local oDlg		    := nil 
Local aSize		    := {}, aObjects := {}, aInfo := {}, aPObjs := {}

Local cLstCpo    	:= "D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM, B1_DESC, D1_UM, D1_LOTECTL, D1_QUANT, D1_TOTAL, D1_TES"
Local aAlter		:= U_LoadCustomCpo("SD1")
Local cNotCpo		:= "D1_X_UMIDA, D1_X_IMPUR, D1_X_KGUMI, D1_X_KGIMP, D1_X_NLOTE"
Local cJoin			:= "D1 JOIN " + RetSqlName('SB1') + " B1 ON B1_FILIAL=' ' AND B1_COD=D1_COD AND D1.D_E_L_E_T_=' ' AND B1.D_E_L_E_T_=' '"
Local cWhere		:= "WHERE D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA='" + SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) + "'"
Private aGets       := {}
Private aTela       := {}

Private oSD1GDad    := nil , aSD1Head  := {}, aSD1Cols  := {}, nUSD1 := 1

aSize := MsAdvSize( .T. )
AAdd( aObjects, { 100 , 100, .T. , .T. , .F. } )
aInfo  := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0}
aPObjs := MsObjSize(aInfo, aObjects, .T., .F.) 

DEFINE MSDIALOG oDlg TITLE OemToAnsi(cCadastro) From 0,0 to aSize[6],aSize[5] ;
		PIXEL STYLE nOR( WS_VISIBLE ,DS_MODALFRAME )  // tirar o X da tela | tirar o botao X da tela |

FWMsgRun(, {|| U_LoadDadosMJ( "SD1", @aSD1Head, @aSD1Cols, StrToKarr(cLstCpo,","), aAlter, ;
								StrToKarr(cNotCpo,","), StrToKarr(cJoin, ","), ;
								StrToKarr(cWhere,",") ) }, 'Pesquisando, Por favor aguarde', 'Consultando o Banco de dados ...')

oSD1GDad := MsNewGetDados():New( 0, 0, 0, 0, nGDOpc, , , /* "+SD1_ITEM" */, , , , , , /* "u_SD1DelOk()" */, ;
					oDlg, aClone(aSD1Head), aClone( aSD1Cols ) )
oSD1GDad:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg ;
          ON INIT EnchoiceBar(oDlg,;
				  { || nOpcA := 1, Iif( /* VldOk(nOpc) .and. */ Obrigatorio(aGets, aTela), oDlg:End(), nOpcA := 0)},;
				  { || nOpcA := 0, oDlg:End() },, /*aButtons*/ )

If nOpcA == 1
	// Begin Transaction     
	for nI := 1 to Len( oSD1GDad:aCols )
		SD1->( DbSetOrder(1) ) // // 1 = D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
		if SD1->(DbSeek( oSD1GDad:aCols[nI,1]+oSD1GDad:aCols[nI,2]+oSD1GDad:aCols[nI,3]+oSD1GDad:aCols[nI,4]+oSD1GDad:aCols[nI,5]+oSD1GDad:aCols[nI,6]+oSD1GDad:aCols[nI,7] ))				
			for nJ := 1 to Len(oSD1GDad:aHeader)
				If aScan( aAlter, { |x| x == AllTrim( oSD1GDad:aHeader[ nJ, 2] ) } ) > 0
					// .AND. !Empty( oSD1GDad:aCols[ nI, nJ] )
					RecLock("SD1", .F.)
						//if oSD1GDad:aHeader[ nJ, 8] == "D"
							//SD1->&(oSD1GDad:aHeader[ nJ, 2]) := dToS( oSD1GDad:aCols[ nI, nJ] )
						//Else
							SD1->&(oSD1GDad:aHeader[ nJ, 2]) := oSD1GDad:aCols[ nI, nJ]
						//EndIf
					SD1->(MsUnLock())
				EndIf
			next nJ
		EndIf
	next nI
	// End Transaction
EndIf

RestArea(aArea)
Return nil 	// U_VACOMM08()

/*----------------------------------------------------------------------------------,
 | Analista: Miguel Martins Bernardo Junior                                         |
 | Data:     18.06.2018                                                             |
 | Cliente:  V@                                                                     |
 | Desc:     Definicoes dos MENUSs externos;                                        |
 |                                                                                  |
 | Obs.:     U_VACOMM08()                                                                    |
 '----------------------------------------------------------------------------------*/
User Function LoadDadosMJ(cAlias, aHead, aCols, aLstCpo, aAlter, aNotCpo, aJoin, aWhere )
Local aArea	:= GetArea()
Local nI
Local cSqlCpos	:= ""
Local _cAliasTMP	:= GetNextAlias(), cSql := ""

DbSelectArea("SX3")
DbSetOrder(2) // X3_CAMPO

for nI := 1 to Len(aLstCpo)
	SX3->(DbSeek( PadR(AllTrim(aLstCpo[nI]),10) ))
	If !Empty(SX3->X3_CAMPO)
		AAdd(aHead, { SX3->X3_TITULO,;         // SX3->X3_TITULO 
					  SX3->X3_CAMPO,;          // SX3->X3_CAMPO
					  SX3->X3_PICTURE,;// SX3->X3_PICTURE
					  Iif(SX3->X3_TAMANHO>30,30,SX3->X3_TAMANHO),; // SX3->X3_TAMANHO
					  SX3->X3_DECIMAL,;        // SX3->X3_DECIMAL
					  .F.,;                    // SX3->X3_VALID
					  "CCCCCCCCCCCCCCa",;      // SX3->X3_USADO
					  SX3->X3_TIPO,;           // SX3->X3_TIPO
					  "",;                     // SX3->X3_F3
					  "V",;                    // SX3->X3_CONTEXT
					  "",;                     // SX3->X3_CBOX
					  "",;                     // SX3->X3_RELACAO
					  "",;                     // SX3->X3_WHEN
					  "V",;                    // SX3->X3_VISUAL
					  "",;                     // SX3->X3_VLDUSER
					  "",;                     // SX3->X3_PICTVAR
					  "" } )                   // X3Obrigat(SX3->X3_CAMPO)
	EndIf
next nI

for nI := 1 to Len(aAlter)
	SX3->(DbSeek( PadR(AllTrim(aAlter[nI]),10) ))
	If !Empty(SX3->X3_CAMPO) .and. aScan( aNotCpo, { |x| AllTrim(x) == AllTrim( aAlter[nI] ) } ) == 0
		AAdd(aHead, { SX3->X3_TITULO,;         // SX3->X3_TITULO 
					  SX3->X3_CAMPO,;          // SX3->X3_CAMPO
					  SX3->X3_PICTURE,;// SX3->X3_PICTURE
					  Iif(SX3->X3_TAMANHO>30,30,SX3->X3_TAMANHO),; // SX3->X3_TAMANHO
					  SX3->X3_DECIMAL,;        // SX3->X3_DECIMAL
					  .F.,;                    // SX3->X3_VALID
					  "CCCCCCCCCCCCCCa",;      // SX3->X3_USADO
					  SX3->X3_TIPO,;           // SX3->X3_TIPO
					  "",;                     // SX3->X3_F3
					  "R",;                    // SX3->X3_CONTEXT
					  "",;                     // SX3->X3_CBOX
					  "",;                     // SX3->X3_RELACAO
					  "",;                     // SX3->X3_WHEN
					  "A",;                    // SX3->X3_VISUAL
					  "",;                     // SX3->X3_VLDUSER
					  "",;                     // SX3->X3_PICTVAR
					  "" } )                   // X3Obrigat(SX3->X3_CAMPO)
	EndIf
next nI

If Empty(aHead)
	// SE anteriormente nao foi adicionado nada na variavel "aHead" entao rodar toda a SX3 para o alias informado por parametro
	While !SX3->(Eof()) .and. SX3->X3_TABELA == cAlias
		AAdd(aHead, { SX3->X3_TITULO,;         // SX3->X3_TITULO 
				  SX3->X3_CAMPO,;          // SX3->X3_CAMPO
				  SX3->X3_PICTURE,;        // SX3->X3_PICTURE
				  SX3->X3_TAMANHO,;        // SX3->X3_TAMANHO
				  SX3->X3_DECIMAL,;        // SX3->X3_DECIMAL
				  .F.,;                    // SX3->X3_VALID
				  "CCCCCCCCCCCCCCa",;      // SX3->X3_USADO
				  SX3->X3_TIPO,;           // SX3->X3_TIPO
				  "",;                     // SX3->X3_F3
				  "V",;                    // SX3->X3_CONTEXT
				  "",;                     // SX3->X3_CBOX
				  "",;                     // SX3->X3_RELACAO
				  "",;                     // SX3->X3_WHEN
				  "V",;                    // SX3->X3_VISUAL
				  "",;                     // SX3->X3_VLDUSER
				  "",;                     // SX3->X3_PICTVAR
				  "" } )                   // X3Obrigat(SX3->X3_CAMPO)
		SX3->(DbSkip())
	EndDo
EndIf

cSqlCpos := ""
nLen 	 := Len(aHead)
for nI := 1 to nLen
	If !Empty(aHead[ nI, 2])
		cSqlCpos += Iif( Empty(cSqlCpos), "", ", " ) + AllTrim( aHead[ nI, 2] )
	EndIf
next nI

cSql := " SELECT " + cSqlCpos + CRLF
cSql += " FROM " + RetSqlName(cAlias) + CRLF

for nI := 1 to Len(aJoin)
	cSql += aJoin[nI] + CRLF
next nI

for nI := 1 to len(aWhere)
	cSql += aWhere[nI] + CRLF
next nI

MemoWrite( "C:\totvs_relatorios\VACOMM08.SQL", cSql)
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),(_cAliasTMP), .F., .F.)		// U_VACOMM08()
If !(_cAliasTMP)->(Eof()) 
	aCols := {}
	While !(_cAliasTMP)->(Eof())
		// aCol := Array(nLen+2)
		aCol := Array(nLen+1)
		// aCol[1] := "LBNO"
		For i := 1 To nLen
			// aCol[i+1] := (_cAliasTMP)->&(aCpos[i])
			if aHead[ i, 8 ] == "D"
				aCol[i] := sToD( (_cAliasTMP)->&(aHead[ i, 2]) )
			Else
				aCol[i] := (_cAliasTMP)->&(aHead[ i, 2])
			EndIf
		Next
		aCol[Len(aHead)+1] := .F.
		AAdd(aCols, aCol)
		(_cAliasTMP)->(DbSkip())
	End
Else
	// aCols := { Array(nLen+2) }
	aCols := { Array(nLen+1) }
	// aCols[1][1] := "LBNO"
	//aCols[1][2] := "BR_BRANCO"
	aCols[1][Len(aCols[1])] := .F.

	For i := 1 To nLen
		// aCols[1][i+1] := CriaVar(aCpos[i], .f.)
		aCols[1][i] := CriaVar(aHead[ I, 2], .f.)
	Next
	ShowHelpDlg("VACOMM08.01", { "O filtro selecionado n? trouxe nenhum pedido v?ido." }, 1, {"Por favor, verifique."}, 1 )
EndIf
(_cAliasTMP)->(DbCloseArea())

RestArea( aArea )

Return Nil	// U_VACOMM08()