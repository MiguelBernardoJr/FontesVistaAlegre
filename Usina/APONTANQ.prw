//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "TOTVS.ch"
#Include "TopConn.ch"

//Variáveis Estáticas 
Static cTitulo := "Apontamento - Inspeção Fisica Diaria dos Tanques"

/*/{Protheus.doc} APONTANQ
Função para Apontamento Inspeção Fisica Diaria dos Tanques
@author Rodrigo Franco
@since 13/02/2025
@version 1.0
    @return Nil, Função não tem retorno
    @example
    u_APONTANQ()
    @obs Os campos chave usado entre cabeçalho e grid são:
/*/

User Function APONTANQ()

    Local aArea   := GetArea()
    Local oBrowse
    Private dGetPerc01 := Date()

    xApontaD(@dGetPerc01)

    //Cria um browse para a ZH3
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("ZH3")
    oBrowse:SetDescription(cTitulo)
    oBrowse:Activate()

    GravaZH1(dGetPerc01)

    RestArea(aArea)

Return Nil


static function xApontaD(dGetPerc01)
    Private oSayChkDes
    Private oGetPerc01
    //   Private dGetPerc01 := Date()
    Private oDlg002
    Private cFontUti    := "Tahoma"
    Private oFontBtn    := TFont():New(cFontUti, , -14)
    Private oFontSay    := TFont():New(cFontUti, , -12)

    DEFINE MSDIALOG oDlg002 TITLE "Apontamento - Inspeção Fisica Diaria dos Tanques"  FROM 0, 0 TO 150, 320 PIXEL
    oSayChkDes := TSay():New(012, 020 , {|| "Data do Apontamento:"}, oDlg002, "", oFontSay,  , , , .T., RGB(031, 073, 125), , 70, 10, , , , , , .F., , )
    oGetPerc01 := TGet():New(010, 090 , {| u | If( PCount() == 0, dGetPerc01, dGetPerc01 := u )}, oDlg002, 50, 10, "@D", /*bValid*/, /*nClrFore*/, /*nClrBack*/, oFontSay, , , .T.)
    oBtnSair   := TButton():New(040, 060, "Apontar",  oDlg002, {|| xGeraDia(dGetPerc01), oDlg002:End()}, 045, 015, , oFontBtn, , .T., , , , , , )

    Activate MsDialog oDlg002 Centered

return

Static Function xGeraDia(dGetPerc01)

    DBSelectArea("ZH3")
    DBSetOrder(1)
    If DBSeek(xFilial("ZH3")+DToS(dGetPerc01))
        cProd := ZH3->ZH3_PRODUT
        cArma := ZH3->ZH3_ARMAZE
        //      MsgInfo("achou zh3, vai gravar",DToS(dGetPerc01))
        DBSelectArea("ZH2")
        DBSetOrder(1)
        If DBSeek(xFilial("ZH2")+cProd)
            cUnid := ZH2->ZH2_UNIDAD
            cOrde := ZH2->ZH2_ORDEM
        Endif
        DBSelectArea("ZH1")
        DBSetOrder(1)
        If DBSeek(xFilial("ZH1")+DToS(dGetPerc01)+cOrde)
            nDia	:= ZH1->ZH1_DIA
            nSemana := ZH1->ZH1_SEMANA
            nMes	:= ZH1->ZH1_MES
            nAcumul := ZH1->ZH1_ACUMUL
            RecLock("ZH1",.F.)
            ZH1->ZH1_DIA	:= nDia
            ZH1->ZH1_SEMANA	:= nSemana
            ZH1->ZH1_MES	:= nMes
            ZH1->ZH1_ACUMUL	:= nAcumul
            MsUnlock()
        Else
            RecLock("ZH1", .T.)
            ZH1->ZH1_FILIAL := xFilial("ZH3")
            ZH1->ZH1_DATA   := dGetPerc01
            ZH1->ZH1_PROCES := cProd
            ZH1->ZH1_UNIDAD := cUnid
            ZH1->ZH1_DIA    := 0
            ZH1->ZH1_SEMANA := 0
            ZH1->ZH1_MES    := 0
            ZH1->ZH1_ACUMUL := 0
            ZH1->ZH1_ORDEM  := cOrde
            MsUnlock()
        EndIF
    Else
        DBSelectArea("ZH2")
        DBGoTop()
        While !Eof()
            cProd := ZH2->ZH2_PROCES
            cArma := ZH2->ZH2_ARMAZE
            cUnid := ZH2->ZH2_UNIDAD
            cOrde := ZH2->ZH2_ORDEM
            If ZH2->ZH2_TANQUE == "S"
                RecLock("ZH3",.T.)
                ZH3->ZH3_FILIAL  := xFilial("ZH3")
                ZH3->ZH3_DATA    := dGetPerc01
                ZH3->ZH3_PRODUT  := cProd
                ZH3->ZH3_ARMAZE  := cArma
                ZH3->ZH3_VOLM3   := 0
                ZH3->ZH3_DENSID  := 0
                ZH3->ZH3_VOLKG   := 0
                ZH3->ZH3_SLDSIS  := 0
                ZH3->ZH3_DESVIO  := 0
                MsUnlock()
            Endif
            DBSelectArea("ZH2")
            DBSkip()
        End
    Endif
    FWExecView( getTitle(MODEL_OPERATION_UPDATE), 'VIEWDEF.APONTANQ', MODEL_OPERATION_UPDATE)
Return

static function getTitle(nOperation)
    local cTitle as char

    if nOperation == MODEL_OPERATION_INSERT
        cTitle := "Inclusão"
    elseif nOperation == MODEL_OPERATION_UPDATE
        cTitle := "Alteração"
    else
        cTitle := "Visualização"
    endif

return cTitle

Static Function MenuDef()
    Local aRot := {}

    //Adicionando opções
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.APONTANQ' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    //  ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.APONTANQ' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.APONTANQ' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.APONTANQ' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
Return aRot

Static Function ModelDef()
    //Na montagem da estrutura do Modelo de dados, o cabeçalho filtrará e exibirá somente 1 campo, já a grid irá carregar a estrutura inteira conforme função fModStruct
    Local oModel    := NIL
    Local oStruCab  := FWFormStruct(1, 'ZH3', {|cCampo| AllTRim(cCampo) $ "ZH3_DATA;"})
    Local oStruGrid := FWFormStruct(1, 'ZH3', {|cCampo| AllTRim(cCampo) $ "ZH3_DATA;ZH3_PRODUT;ZH3_ARMAZE;ZH3_VOLM3;ZH3_DENSID;ZH3_VOLKG;ZH3_SLDSIS;ZH3_DESVIO;"})

    //Monta o modelo de dados, e na Pós Validação, informa a função fValidGrid
    oModel := MPFormModel():New('APONTANM', /*bPreValidacao*/, {|oModel| fValidGrid(oModel)}, /*bCommit*/, /*bCancel*/ )

    //Agora, define no modelo de dados, que terá um Cabeçalho e uma Grid apontando para estruturas acima
    oModel:AddFields('MdFieldZH3', NIL, oStruCab)
    oModel:AddGrid('MdGridZH3', 'MdFieldZH3', oStruGrid, , )

    //Monta o relacionamento entre Grid e Cabeçalho, as expressões da Esquerda representam o campo da Grid e da direita do Cabeçalho
    oModel:SetRelation('MdGridZH3', {;
        {'ZH3_FILIAL', 'xFilial("ZH3")'},;
        {"ZH3_DATA",    "ZH3_DATA"};
        }, ZH3->(IndexKey(1)))

    //Definindo outras informações do Modelo e da Grid
    oModel:GetModel("MdGridZH3"):SetMaxLine(9999)
    oModel:SetDescription("Apontamento Inspeção Fisica Diaria dos Tanques")
    oModel:SetPrimaryKey({"ZH3_FILIAL", "ZH3_DATA", "ZH3_PRODUT"})

    // Pós-save gravação em ZH1
    //   oModel:ActivatePostSave({|oModel| GravaZH1(oModel:GetModel("MdGridZH3"):GetBuffer())})

Return oModel
/*
// Função para gravar na tabela ZH1
Static Function GravaZH1(aBuffer)
    Local cFilial := aBuffer["ZH3_FILIAL"]
    Local dData   := aBuffer["ZH3_DATA"]
    Local cProduto:= aBuffer["ZH3_PRODUT"]
    Local cUnid   := "KG" // Supondo unidade padrão
    Local cProc   := "APONT" // Processo
    Local nDia    := Day(dData)
    Local nSemana := FWGetWeek(dData)
    Local nMes    := Month(dData)
    Local nAcum   := aBuffer["ZH3_VOLKG"]
    Local cOrdem  := PadL(STRZERO(nDia, 2) + STRZERO(nMes, 2), 6)

    DbSelectArea("ZH1")
    ZH1->(DbAppend())

    ZH1->ZH1_FILIAL := cFilial
    ZH1->ZH1_DATA   := dData
    ZH1->ZH1_PROCES := cProc
    ZH1->ZH1_UNIDAD := cUnid
    ZH1->ZH1_DIA    := nDia
    ZH1->ZH1_SEMANA := nSemana
    ZH1->ZH1_MES    := nMes
    ZH1->ZH1_ACUMUL := nAcum
    ZH1->ZH1_ORDEM  := cOrdem

    ZH1->(MsUnlock())

         MsUnlock()
                DBSelectArea("ZH1")
                DBSetOrder(1)
                If DBSeek(xFilial("ZH1")+DToS(dGetPerc01)+cProd)
                    nDia	:= ZH1->ZH1_DIA
                    nSemana := ZH1->ZH1_SEMANA
                    nMes	:= ZH1->ZH1_MES
                    nAcumul := ZH1->ZH1_ACUMUL
                    RecLock("ZH1",.F.)
                    ZH1->ZH1_DIA	:= nDia + nQuant
                    ZH1->ZH1_SEMANA	:= nSemana + nQuant
                    ZH1->ZH1_MES	:= nMes + nQuant
                    ZH1->ZH1_ACUMUL	:= nAcumul + nQuant
                    MsUnlock()
                EndIF

Return .T.
*/
Static Function ViewDef()
    //Na montagem da estrutura da visualização de dados, vamos chamar o modelo criado anteriormente, no cabeçalho vamos mostrar somente 3 campos, e na grid vamos carregar conforme a função fViewStruct
    Local oView        := NIL
    Local oModel    := FWLoadModel('APONTANQ')
    Local oStruCab  := FWFormStruct(2, "ZH3", {|cCampo| AllTRim(cCampo) $ "ZH3_DATA;"})
    Local oStruGRID := fViewStruct()

    //Define que no cabeçalho não terá separação de abas (SXA)
    oStruCab:SetNoFolder()

    //Cria o View
    oView:= FWFormView():New()
    oView:SetModel(oModel)

    //Cria uma área de Field vinculando a estrutura do cabeçalho com MDFieldZH3, e uma Grid vinculando com MdGridZH3
    oView:AddField('VIEW_ZH3', oStruCab, 'MdFieldZH3')
    oView:AddGrid ('GRID_ZH3', oStruGRID, 'MdGridZH3' )

    //O cabeçalho (MAIN) terá 25% de tamanho, e o restante de 75% irá para a GRID
    oView:CreateHorizontalBox("MAIN", 15)
    oView:CreateHorizontalBox("GRID", 85)

    //Vincula o MAIN com a VIEW_ZH3 e a GRID com a GRID_ZH3
    oView:SetOwnerView('VIEW_ZH3', 'MAIN')
    oView:SetOwnerView('GRID_ZH3', 'GRID')
    oView:EnableControlBar(.T.)

    //Define o campo incremental da grid como o ZH3_ITEM
    //****************///   oView:AddIncrementField('GRID_ZH3', 'ZH3_ITEM')
Return oView

//Função chamada para montar o modelo de dados da Grid
Static Function fModStruct()
    Local oStruct
    oStruct := FWFormStruct(1, 'ZH3')
Return oStruct

//Função chamada para montar a visualização de dados da Grid
Static Function fViewStruct()
    Local cCampoCom := "ZH3_DATA"
    Local oStruct

    //Irá filtrar, e trazer todos os campos, menos os que tiverem na variável cCampoCom
    oStruct := FWFormStruct(2, "ZH3", {|cCampo| !(Alltrim(cCampo) $ cCampoCom)})
Return oStruct

//Função que faz a validação da grid
Static Function fValidGrid(oModel)
    Local lRet       := .T.
    Local nDeletados := 0
    Local nLinAtual  := 0
    Local oModelGRID := oModel:GetModel('MdGridZH3')
    //    Local oModelMain := oModel:GetModel('MdFieldZH3')
    //    Local nValorMain := oModelMain:GetValue("")
    //    Local nValorGrid := 0
    //    Local cPictVlr   := PesqPict('ZH3', '')

    //Percorrendo todos os itens da grid
    For nLinAtual := 1 To oModelGRID:Length()
        //Posiciona na linha
        oModelGRID:GoLine(nLinAtual)

        //Se a linha for excluida, incrementa a variável de deletados, senão irá incrementar o valor digitado em um campo na grid
        If oModelGRID:IsDeleted()
            nDeletados++
        Else
            //           nValorGrid += NoRound(oModelGRID:GetValue("ZH3_VOLM3"), 4)
        EndIf
    Next nLinAtual

    //Se o tamanho da Grid for igual ao número de itens deletados, acusa uma falha
    If oModelGRID:Length()==nDeletados
        lRet :=.F.
        Help( , , 'Dados Inválidos' , , 'A grid precisa ter pelo menos 1 linha sem ser excluida!', 1, 0, , , , , , {"Inclua uma linha válida!"})
    EndIf

    If lRet
        /*
        //Se o valor digitado no cabeçalho (valor da NF), não bater com o valor de todos os abastecimentos digitados (valor dos itens da Grid), irá mostrar uma mensagem alertando, porém irá permitir salvar (do contrário, seria necessário alterar lRet para falso)
        If nValorMain != nValorGrid
            //lRet := .F.
            MsgAlert("O valor do cabeçalho (" + Alltrim(Transform(nValorMain, cPictVlr)) + ") tem que ser igual o valor dos itens (" + Alltrim(Transform(nValorGrid, cPictVlr)) + ")!", "Atenção")
        EndIf
        */
    EndIf

Return lRet

// Função para gravar na tabela ZH1
Static Function GravaZH1(dGetPerc01)

    DBSelectArea("ZH3")
    DBSetOrder(1)
    If DBSeek(xFilial("ZH3")+DToS(dGetPerc01))
        While !Eof() .and. xFilial("ZH3") == ZH3->ZH3_FILIAL .and. dGetPerc01 == ZH3->ZH3_DATA
            cProd  := ZH3->ZH3_PRODUT
            cArma  := ZH3->ZH3_ARMAZE
            nQuant := ZH3->ZH3_VOLM3

            dEmiss	:= dGetPerc01
            nSemana := RetSem(dEmiss)
            nMes	:= Month(dEmiss)
            cAno	:= Year(dEmiss)

            DBSelectArea("ZH2")
            DBSetOrder(1)
            If DBSeek(xFilial("ZH2")+cProd)
                cUnid := ZH2->ZH2_UNIDAD
                cOrde := ZH2->ZH2_ORDEM
            Endif

            DBSelectArea("ZH6")
            DBSetOrder(1)
            If DBSeek(xFilial("ZH6")+cValToChar(cAno)+cProd)
                nZH6QTD :=  ZH6->ZH6_QUANT
                RecLock("ZH6",.F.)
                ZH6->ZH6_QUANT	:= nZH6QTD + nQuant
                MsUnlock()
            Else
                RecLock("ZH6",.T.)
                ZH6->ZH6_FILIAL	:= xFilial("ZH6")
                ZH6->ZH6_ANO	:= cValToChar(cAno)
                ZH6->ZH6_PROCES	:= cProd
                ZH6->ZH6_QUANT	:= nQuant
            EndIF
            nZH6QTD :=  ZH6->ZH6_QUANT

            DBSelectArea("ZH5")
            DBSetOrder(1)
            If DBSeek(xFilial("ZH5")+STR(nMes,2,0)+cProd)
                nZH5QTD :=  ZH5->ZH5_QUANT
                RecLock("ZH5",.F.)
                ZH5->ZH5_QUANT	:= nZH5QTD + nQuant
                MsUnlock()
            Else
                RecLock("ZH5",.T.)
                ZH5->ZH5_FILIAL	:= xFilial("ZH5")
                ZH5->ZH5_MES	:= nMes
                ZH5->ZH5_PROCES	:= cProd
                ZH5->ZH5_QUANT	:= nQuant
            EndIF
            nZH5QTD :=  ZH5->ZH5_QUANT
            nSeman1 := Val(nSemana)

            DBSelectArea("ZH4")
            DBSetOrder(1)
            If DBSeek(xFilial("ZH4")+nSemana+cProd)
                nZH4QTD :=  ZH4->ZH4_QUANT
                RecLock("ZH4",.F.)
                ZH4->ZH4_QUANT	:= nZH4QTD + nQuant
                MsUnlock()
            Else
                RecLock("ZH4",.T.)
                ZH4->ZH4_FILIAL	:= xFilial("ZH4")
                ZH4->ZH4_SEMANA	:= nSeman1
                ZH4->ZH4_PROCES	:= cProd
                ZH4->ZH4_QUANT	:= nQuant
            EndIF
            nZH4QTD :=  ZH4->ZH4_QUANT

            DBSelectArea("ZH1")
            DBSetOrder(1)
            If DBSeek(xFilial("ZH1")+DToS(dGetPerc01)+cOrde)

                nZh1Sem := ZH1->ZH1_SEMANA
                nZh1Mes := ZH1->ZH1_MES
                nZh1ano := ZH1->ZH1_ACUMUL

                RecLock("ZH1",.F.)
                ZH1->ZH1_DIA    := nQuant
                ZH1->ZH1_SEMANA := nZh1Sem + nQuant
                ZH1->ZH1_MES    := nZh1Mes + nQuant
                ZH1->ZH1_ACUMUL := nZh1ano + nQuant
                MsUnlock()
            Else
                RecLock("ZH1", .T.)
                ZH1->ZH1_FILIAL := xFilial("ZH3")
                ZH1->ZH1_DATA   := dGetPerc01
                ZH1->ZH1_PROCES := cProd
                ZH1->ZH1_UNIDAD := cUnid
                ZH1->ZH1_DIA    := nQuant
                ZH1->ZH1_SEMANA := nZH4QTD
                ZH1->ZH1_MES    := nZH5QTD
                ZH1->ZH1_ACUMUL := nZH6QTD
                ZH1->ZH1_ORDEM  := cOrde
                MsUnlock()
            EndIF
            DBSelectArea("ZH3")
            DBSkip()
        end
    EndIF

Return .T.
