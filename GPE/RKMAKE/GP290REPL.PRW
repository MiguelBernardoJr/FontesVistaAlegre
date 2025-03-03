#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} GP290REPL
RdMake para replicar f�rmulas para todas as filiais quando RC2/RC2 s�o exclusivas.
@author Leandro Drumond
@since 14/02/2022
@version P12.1.33
@Type     Function
/*/
User Function GP290REPL()
Local aFilAux   := {}
Local aRecForm  := {}
Local lGpea290  := FunName() == "GPEA290"
Local lCompAux  := .F.

aFilAux := Gp290LoadFil(!lGpea290,@aRecForm)

If lGpea290 //Se foi chamado pelo Ponto de Entrada, retorna as filiais para grava��o interna
    Return aFilAux
EndIf

If Len(aFilAux) > 0
    lCompAux := MsgYesNo("Deseja compilar a f�rmula em todas as filiais selecionadas? ", "Aten��o")
    If lCompAux 
        Proc2BarGauge( { || GP290REPLProc(aFilAux,aRecForm,lCompAux) } , "Replicando altera��es" , NIL , NIL , .F. , .T. , .F. , .F. )	// "Replicando altera��es"
    Else 
        ProcGpe({|lEnd| GP290REPLProc(aFilAux,aRecForm,lCompAux) },,,.T.)
    EndIf
EndIf

Return Nil

/*/{Protheus.doc} GP290REPLProc
Processa as filiais selecionadas
@author Leandro Drumond
@since 14/02/2022
@version P12.1.33
@Type     Function
/*/
Static Function GP290REPLProc(aFilAux, aRecForm,lCompila)
Local aRc2Enchoice  := {}
Local aRc2VirtChoice:= {}
Local aRc2Visual    := {}
Local aRc2Cols      := {}
Local aRc3Cols      := {}
Local aRC3Virtual   := {}
Local aRC3Visual    := {}
Local aRC3Recnos    := {}
Local aLogTitle     := {}
Local aLogItens     := {}
Local aLogAux       := {}   
Local aLogTime      := {} 
Local cFilAux       := cFilAnt
Local cRC3Key       := ""
Local cFormName     := ""
Local nY            := 0
Local nX            := 0

Private aRc3Header      := {}
Private lGpea290Cpy     := .F.
Private lManutence      := .F.

If lCompila
    BarGauge1Set( Len(aFilAux) )
Else 
    GPProcRegua(Len(aRecForm))
EndIf

For nY := 1 to Len(aRecForm)

    RC2->(DbGoTo(aRecForm[nY]))

    cFormName     := RC2->(RC2_ORIGEM + RC2_CODIGO)

    If Empty(aLogTitle)
        aAdd(aLogTitle, "Tempo de processamento")
        aAdd(aLogTime, "Inicio do Processamento: " + Time())
        aAdd(aLogTitle, "As seguintes f�rmulas foram processadas:")
        
    EndIf 
    aAdd(aLogAux, cFormName)

    aRc2Enchoice  := {}
    aRc2VirtChoice:= {}
    aRc2Visual    := {}
    aRc2Cols      := {}

    aRc2Cols := RC2->( GdBuildCols( @aRc2Enchoice , NIL , @aRc2VirtChoice , @aRc2Visual , "RC2" , { "RC2_FILIAL" , "RC2_ORIGEM", "RC2_VERSAO" } , NIL , "RC2" ) )

    RC2->(DbGoTo(aRecForm[nY]))

    cRC3Key 	:= RC2->(RC2_FILIAL + RC2_ORIGEM + RC2_CODIGO)

    aRc3Cols      := {}
    aRc3Header    := {}
    aRC3Virtual   := {}
    aRC3Visual    := {}
    aRC3Recnos    := {}

    aRc3Cols	:= RC3->( GdMontaCols(	@aRc3Header 								,;	// 01 -> Array com os Campos do Cabecalho
                                        NIL											,;	// 02 -> Numero de campos em uso
                                        @aRC3Virtual								,;	// 03 -> Array com os campos virtuais
                                        @aRC3Visual									,;	// 04 -> Array com os campos visuais
                                        "RC3" 										,;	// 05 -> Opcional, Alias do Arquivo Carga dos itens do aCols
                                        NIL											,;	// 06 -> Opcional, campos que nao deverao constar do aHedder (NotFields)
                                        @aRC3Recnos                                	,;  // 07 -> [@]Array unidimensional contendo os Recnos
                                        "RC2"										,;	// 08 -> Alias do Arquivo Pai
                                        cRC3Key										,;	// 09 -> Chave para o Posicionamento no Alias Filho
                                        NIL											,;	// 10 -> Bloco para condicao de Loop While
                                        NIL											,;	// 11 -> Bloco para Skip no Loop While
                                        NIL											,;	// 12 -> Se Havera o Elemento de Delecao no aCols
                                        NIL											,;	// 13 -> Se cria variaveis Publicas
                                        NIL											,;	// 14 -> Se Sera considerado o Inicializador Padrao
                                        NIL											,;	// 15 -> Lado para o inicializador Padrao
                                        .T.											,;	// 16 -> Opcional, Carregar Todos os Campos
                                        NIL											,;	// 17 -> Opcional, Nao Carregar os Campos Virtuais
                                        NIL											,;	// 18 -> Opcional, Utilizacao de Query para Selecao de Dados
                                        NIL											,;	// 19 -> Opcional, Se deve Executar bKey  ( Apenas Quando TOP ) - utilizado com o parametro 10
                                        NIL											,;	// 20 -> Opcional, Se deve Executar bSkip ( Apenas Quando TOP ) - utilizado com o parametro 11
                                        .T.											,;	// 21 -> Carregar Coluna Fantasma e/ou BitMap ( Logico ou Array )
                                        NIL											,;	// 22 -> Inverte a Condicao de aNotFields carregando apenas os campos ai definidos
                                        NIL											,;	// 23 -> Verifica se Deve Checar se o campo eh usado
                                        NIL											,;	// 24 -> Verifica se Deve Checar o nivel do usuario
                                        NIL											,;	// 25 -> Verifica se Deve Carregar o Elemento Vazio no aCols
                                        NIL											,;	// 26 -> [@]Array que contera as chaves conforme recnos
                                        NIL											,;	// 27 -> [@]Se devera efetuar o Lock dos Registros
                                        NIL											,;	// 28 -> [@]Se devera obter a Exclusividade nas chaves dos registros
                                        NIL											,;	// 29 -> Numero maximo de Locks a ser efetuado
                                        .T.		 							         ;	// 30 -> Utiliza Numeracao na GhostCol
                        );
                )

	For nX := 1 To Len( aRc2Enchoice )
		SetMemVar( aRc2Enchoice[ nX , 02 ] , aRc2Cols[ 1 , nX ] , .T. , .T. )
	Next nX

    SetMemVar( "RC2_ORIGEM", "U_", .T. , .T.  )

    If lCompila
        Gp290Replica(4, lCompila, aFilAux, aRc2Enchoice, aRc2Cols, {}, aRc2VirtChoice, aRC3Virtual, aRC3Recnos, aRc3Cols, {}, .T., cFormName)
    Else
        GPIncProc( "Replicando F�rmula: " + aRc2Cols[1,1], 50, .T. )
        GrvForm(aRc2Enchoice,aRc2Cols,aRc3Header,aRc3Cols,aFilAux)
    EndIf

Next nY

cFilAnt := cFilAux

If Len(aLogTitle) > 0
    aAdd(aLogTime, "Fim do Processamento: " + Time())
    aAdd(aLogItens, aClone(aLogTime)) //Incluido para pular linha ap�s o inicio do processamento
    aAdd(aLogItens, aClone(aLogAux))
    aAdd(aLogTitle, "Filiais processadas")
    aAdd(aLogItens, aFilAux)
    MsAguarde( { || fMakeLog( aLogItens, aLogTitle , "GP290REPL" , NIL , FunName() , "Log de r�plica de f�rmulas" ) } ,  "Log de r�plica de f�rmulas") //"Log de r�plica de f�rmulas"
EndIf

Return Nil

/*/{Protheus.doc} GrvForm
Efetua a grava��o da RC2 e RC3
@author Leandro Drumond
@since 16/11/2022
@version P12.1.33
@Type     Function
/*/
Static Function GrvForm(aRc2Enchoice,aRc2Cols,aRc3Header,aRc3Cols,aFilAux)
Local nX        := 0
Local nY        := 0
Local nFil      := 0
Local nRc3Cod   := GdFieldPos("RC3_CODIGO",aRc3Header)
Local cFilAux   := ""
Local cKeyRC3   := ""

For nFil := 1 to Len(aFilAux)
    cFilAux := xFilial("RC2", aFilAux[nFil])

    If (RC2->(DbSeek(cFilAux + "U_" + aRc2Cols[1,1])))
        RecLock("RC2",.F.)
        DbDelete()
        MsUnLock()
    EndIf

    RecLock("RC2", .T.)

    RC2->RC2_FILIAL := cFilAux
    RC2->RC2_ORIGEM := "U_"
    RC2->RC2_MODELO := "1"
    RC2->RC2_RECOMP := "1"

    For nX := 1 to Len(aRc2Enchoice)
        If aRc2Enchoice[nX,2] $ "RC2_FILIAL*RC2_ALI_WT*RC2_REC_WT" .or. aRc2Enchoice[nX,10] == "V"
            Loop
        EndIf
        &("RC2->"+aRc2Enchoice[nX,2]) := aRc2Cols[1,nX]
    Next nX

    RC2->(MsUnLock())

    For nX := 1 to Len(aRc3Cols)

        If cKeyRC3 <> cFilAux + "U_" + aRc3Cols[nX,nRc3Cod]
            cKeyRC3 := cFilAux + "U_" + aRc3Cols[nX,nRc3Cod]
            If RC3->(DbSeek(cKeyRC3))
                While RC3->(!Eof() .and. RC3_FILIAL + RC3_ORIGEM + RC3_CODIGO == cKeyRC3)
                    RecLock("RC3",.F.)
                    DbDelete()
                    MsUnLock()
                    RC3->(DbSeek(cKeyRC3))
                EndDo
            EndIf
        EndIf

        RecLock("RC3", .T.)

        RC3->RC3_FILIAL := cFilAux

        For nY := 1 to Len(aRc3Header)

            If aRc3Header[nY,2] $ "RC3_FILIAL*GHOSTCOL*RC3_ALI_WT*RC3_REC_WT" .or. aRc3Header[nY,10] == "V"
                Loop 
            EndIf

            &("RC3->"+aRc3Header[nY,2]) := aRc3Cols[nX,nY]

        Next nY 

        RC3->(MsUnLock())

    Next nX

Next nFil

Return Nil

/*/{Protheus.doc} Gp290LoadFil
Carrega filiais
@author Leandro Drumond
@since 14/02/2022
@version P12.1.33
@Type     Function
/*/
Static Function Gp290LoadFil(lLoadForm,aRecForm)
Local aArea			:= GetArea()
Local aColumns		:= {}
Local aSM0     		:= {}
Local aStru			:= {}
Local aLstIndices	:= {}
Local aRet          := {}
Local aFilAux       := {}
Local cFilRC2       := ""
Local cSeekRC2      := ""
Local lMarcar 		:= .T.
Local nOpcX 		:= 0
Local nCont
Local oSize 
Local oDlgGrid 
Local oTela
Local oPanel
Local oMark
Local oFont         := TFont():New('Courier new',,-16,,.T.)

Private cAliasTRB
Private cAliasForm

Static cAliasTmp
Static oArqTmp

If oArqTmp == Nil //Monta tempor�ria com filiais dispon�veis
	Aadd(aStru, {"OK"		, "C", 2						, 0})
	Aadd(aStru, {"FILIAL"	, "C", FwGetTamFilial			, 0})
	Aadd(aStru, {"NOME"  	, "C", 100						, 0})
    Aadd(aStru, {"FILCOMP" 	, "C", FwGetTamFilial			, 0})
	AAdd(aLstIndices, {"FILIAL"})

	cAliasTmp := cAliasTRB := GetNextAlias()

	oArqTmp := RhCriaTrab(cAliasTRB, aStru, aLstIndices)

	aSM0  := FWLoadSM0(.T.,,.T.)

	For nCont := 1 To Len(aSM0)
		If aSM0[nCont, 1] == cEmpAnt
            cFilRC2 := xFilial("RC2",aSM0[nCont, 2])
            If ( aScan(aFilAux, { |x| x == cFilRC2 } ) ) == 0
                RecLock(cAliasTRB, .T.)
                    (cAliasTRB)->FILIAL	    := cFilRC2
                    (cAliasTRB)->NOME  	    := aSM0[nCont, 7]
                    (cAliasTRB)->FILCOMP	:= aSM0[nCont, 2]
                (cAliasTRB)->(MsUnlock())
                aAdd(aFilAux, cFilRC2)
            EndIf
		EndIf
	Next nCont
Else 
	cAliasTRB := cAliasTmp
EndIf

oSize := FwDefSize():New(.F.)

oSize:AddObject( "CABECALHO",(oSize:aWindSize[3]*1.1),(oSize:aWindSize[3]*0.4) , .F., .F. ) // N�o dimensionavel
oSize:aMargins 	:= { 0, 0, 0, 0 } 		// Espaco ao lado dos objetos 0, entre eles 3
oSize:lProp 		:= .F. 				// Proporcional
oSize:Process() 	   					// Dispara os calculos

Begin Sequence

    If lLoadForm
        aStru       := {}
        aLstIndices := {}
        Aadd(aStru, {"OK"		, "C", 2						, 0})
        Aadd(aStru, {"FILIAL"	, "C", FwGetTamFilial			, 0})
        Aadd(aStru, {"FORM"  	, "C", 15						, 0})
        Aadd(aStru, {"RECNO"  	, "N", 10						, 0})
        AAdd(aLstIndices, {"FILIAL","FORM"})

        cAliasForm := cAliasFRM := GetNextAlias()

        oArqForm := RhCriaTrab(cAliasForm, aStru, aLstIndices)

        RC2->(DbSetOrder(1)) //RC2_FILIAL, RC2_ORIGEM, RC2_CODIGO, R_E_C_N_O_, D_E_L_E_T_

        cSeekRC2 := xFilial("RC2") + "U_"

        If RC2->(DbSeek(cSeekRC2)) //Busca todas as f�rmulas de usu�rio da filial logada
            While RC2->(!Eof() .and. RC2_FILIAL + RC2_ORIGEM == cSeekRC2 )
                RecLock(cAliasForm, .T.)
                        (cAliasForm)->FILIAL    := RC2->RC2_FILIAL
                        (cAliasForm)->FORM      := RC2->RC2_CODIGO
                        (cAliasForm)->RECNO 	:= RC2->(Recno())
                    (cAliasForm)->(MsUnlock())
                RC2->(DbSkip())
            EndDo
        EndIf

        AAdd(aColumns,FWBrwColumn():New())
        aColumns[Len(aColumns)]:SetData( &("{||(cAliasForm)->FILIAL}") )
        aColumns[Len(aColumns)]:SetTitle("Filial" ) //"Filial"
        aColumns[Len(aColumns)]:SetSize(FwGetTamFilial)
        aColumns[Len(aColumns)]:SetDecimal(0)
        aColumns[Len(aColumns)]:SetPicture("@!")

        AAdd(aColumns,FWBrwColumn():New())
        aColumns[Len(aColumns)]:SetData( &("{||(cAliasForm)->FORM}") )
        aColumns[Len(aColumns)]:SetTitle("F�rmula") //"F�rmula"
        aColumns[Len(aColumns)]:SetSize(15)
        aColumns[Len(aColumns)]:SetDecimal(0)
        aColumns[Len(aColumns)]:SetPicture("@!")

        DEFINE MSDIALOG oDlgGrid TITLE OemToAnsi( "R�plica de f�rmulas" ) From 0,0 TO 380,930 OF oMainWnd PIXEL //"Selecione as f�rmulas para replicar" 

        // Cria o conteiner onde ser�o colocados os paineis
        oTela		:= FWFormContainer():New( oDlgGrid )
        cIdGrid  	:= oTela:CreateHorizontalBox( 80 )

        oTela:Activate( oDlgGrid, .F. )

        //Cria os paineis onde serao colocados os browses
        oPanel	:= oTela:GeTPanel( cIdGrid )

        @ oSize:GetDimension("CABECALHO","LININI")+08 , oSize:GetDimension("CABECALHO","COLINI")+6 SAY "Selecione as f�rmulas que ser�o replicadas" Of oDlgGrid Pixel FONT oFont

        oMark := FWMarkBrowse():New()

        oMark:SetOwner(oPanel)
        oMark:SetAlias(cAliasForm)
        oMark:SetTemporary(.T.)
        oMark:SetColumns(aColumns)
        oMark:SetFieldMark('OK')
        oMark:SetIgnoreARotina(.T.)
        oMark:SetMenuDef('')

        oMark:bAllMark := { || SetMarkAll(oMark:Mark(), lMarcar := !lMarcar, cAliasForm ), oMark:Refresh(.T.)  }

        oMark:Activate()

        SetMarkAll(oMark:Mark(),.T.,cAliasForm) //Marca todos os registros

        oMark:Refresh(.T.)

        //Botoes
        oBtn1:= TBrowseButton():New( oSize:GetDimension("CABECALHO","LININI")+20,oSize:GetDimension("CABECALHO","COLINI")+320, OemToAnsi("Confirmar"),oDlgGrid, {||nOpcX := 1, oDlgGrid:End()},42,12,,,.F.,.T.,.F.,,.F.,,,)	//"Confirmar"			         
        oBtn2:= TBrowseButton():New( oSize:GetDimension("CABECALHO","LININI")+20,oSize:GetDimension("CABECALHO","COLINI")+370, OemToAnsi("Cancelar"),oDlgGrid, {||nOpcX := 0, oDlgGrid:End()},42,12,,,.F.,.T.,.F.,,.F.,,,)	//"Cancelar"

        ACTIVATE MSDIALOG oDlgGrid CENTERED

        If nOpcX == 1

            //Adiciona filiais selecionadas
            (cAliasForm)->(dbGoTop())

            While (cAliasForm)->(!EOF())
                If !Empty((cAliasForm)->OK)
                    aAdd(aRecForm, (cAliasForm)->RECNO)
                EndIf
                (cAliasForm)->(dbSkip())
            EndDo
        Else 
            Break
        EndIf
        If Empty(aRecForm)
            MsgInfo("Nenhuma f�rmula selecionada")
            Break 
        EndIf
    EndIf

    nOpcX := 0

    aColumns := {}

    AAdd(aColumns,FWBrwColumn():New())
    aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->FILIAL}") )
    aColumns[Len(aColumns)]:SetTitle("Filial" ) //"Filial"
    aColumns[Len(aColumns)]:SetSize(FwGetTamFilial)
    aColumns[Len(aColumns)]:SetDecimal(0)
    aColumns[Len(aColumns)]:SetPicture("@!")

    AAdd(aColumns,FWBrwColumn():New())
    aColumns[Len(aColumns)]:SetData( &("{||(cAliasTRB)->NOME}") )
    aColumns[Len(aColumns)]:SetTitle("Nome") //"Nome"
    aColumns[Len(aColumns)]:SetSize(Len(SM0->M0_NOME))
    aColumns[Len(aColumns)]:SetDecimal(0)
    aColumns[Len(aColumns)]:SetPicture("@!")

    DEFINE MSDIALOG oDlgGrid TITLE OemToAnsi( "R�plica de f�rmulas" ) From 0,0 TO 380,930 OF oMainWnd PIXEL //"R�plica de f�rmulas"

    // Cria o conteiner onde ser�o colocados os paineis
    oTela		:= FWFormContainer():New( oDlgGrid )
    cIdGrid  	:= oTela:CreateHorizontalBox( 80 )

    oTela:Activate( oDlgGrid, .F. )

    //Cria os paineis onde serao colocados os browses
    oPanel	:= oTela:GeTPanel( cIdGrid )

    @ oSize:GetDimension("CABECALHO","LININI")+08 , oSize:GetDimension("CABECALHO","COLINI")+6 SAY "Selecione as filiais onde as f�rmulas ser�o replicadas" Of oDlgGrid Pixel FONT oFont

    oMark := FWMarkBrowse():New()

    oMark:SetOwner(oPanel)
    oMark:SetAlias(cAliasTRB)
    oMark:SetTemporary(.T.)
    oMark:SetColumns(aColumns)
    oMark:SetFieldMark('OK')
    oMark:SetFilterDefault( " (cAliasTRB)->FILCOMP <> cFilAnt " )
    oMark:SetIgnoreARotina(.T.)
    oMark:SetMenuDef('')

    oMark:bAllMark := { || SetMarkAll(oMark:Mark(), lMarcar := !lMarcar, cAliasTRB ), oMark:Refresh(.T.)  }

    oMark:Activate()

    SetMarkAll(oMark:Mark(),.T.,cAliasTRB) //Marca todos os registros

    oMark:Refresh(.T.)

    //Botoes
    oBtn1:= TBrowseButton():New( oSize:GetDimension("CABECALHO","LININI")+20,oSize:GetDimension("CABECALHO","COLINI")+320, OemToAnsi("Confirmar"),oDlgGrid, {||nOpcX := 1, oDlgGrid:End()},42,12,,,.F.,.T.,.F.,,.F.,,,)	//"Confirmar"			         
    oBtn2:= TBrowseButton():New( oSize:GetDimension("CABECALHO","LININI")+20,oSize:GetDimension("CABECALHO","COLINI")+370, OemToAnsi("Cancelar"),oDlgGrid, {||nOpcX := 0, oDlgGrid:End()},42,12,,,.F.,.T.,.F.,,.F.,,,)	//"Cancelar"

    ACTIVATE MSDIALOG oDlgGrid CENTERED

    If nOpcX == 1

        //Adiciona filiais selecionadas
        (cAliasTRB)->(dbGoTop())

        While (cAliasTRB)->(!EOF())
            If !Empty((cAliasTRB)->OK) .and. (cAliasTRB)->FILCOMP <> cFilAnt
                aAdd(aRet, (cAliasTRB)->FILCOMP)
            EndIf
            (cAliasTRB)->(dbSkip())
        EndDo
    EndIf

End Sequence

RestArea(aArea)

Return aRet

/*/{Protheus.doc} SetMarkAll
Marca/Desmarca todas as filiais
@author Leandro Drumond
@since 14/02/2022
@version P12.1.33
@Type     Function
/*/
Static Function SetMarkAll(cMarca,lMarcar,cAliasTRB)

Local cAliasMark := cAliasTRB
Local aAreaMark  := (cAliasMark)->( GetArea() )

dbSelectArea(cAliasMark)
(cAliasMark)->( dbGoTop() )

While !(cAliasMark)->( Eof() )
	RecLock( (cAliasMark), .F. )
	(cAliasMark)->OK := IIf( lMarcar , cMarca, '  ' )
	MsUnLock()
	(cAliasMark)->( dbSkip() )
EndDo

RestArea(aAreaMark)

Return .T.
