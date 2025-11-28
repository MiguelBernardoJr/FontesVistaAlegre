//Bibliotecas
#Include "Totvs.ch"
#Include "FWMVCDef.ch"
  
/*/{Protheus.doc} fMontaTela
Monta a tela com a marcação de dados
@author Daniel Atilio
@since 20/07/2022
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

Static dLastClickTime := JurTime(.f., .T.)

User Function VABOVPESQ(nOpc)
    Local aArea         := GetArea()
    Local aCampos := {}
    Local aColunas := {}
    Local cFontPad    := 'Tahoma'
    Local oFontGrid   := TFont():New(cFontPad,,-14)
    //Janela e componentes
    Private oTempTable := Nil
    Private oDlgMark
    Private oPanGrid
    Private oMarkBrowse
    Private cAliasTmp := GetNextAlias()
    Private aRotina   := MenuDef()
    //Tamanho da janela
    Private aTamanho := MsAdvSize()
    Private nJanLarg := 950
    Private nJanAltu := 400
       
    //Adiciona as colunas que serão criadas na temporária
    aAdd(aCampos, { 'OK', 'C', 2, 0}) //Flag para marcação
    aAdd(aCampos, { 'B8_LOTECTL', GetSx3Cache("B8_LOTECTL","X3_TIPO"), GetSx3Cache("B8_LOTECTL","X3_TAMANHO"), GetSx3Cache("B8_LOTECTL","X3_DECIMAL")}) //Filial
    aAdd(aCampos, { 'B8_X_CURRA', GetSx3Cache("B8_X_CURRA","X3_TIPO"), GetSx3Cache("B8_X_CURRA","X3_TAMANHO"), GetSx3Cache("B8_X_CURRA","X3_DECIMAL")}) //Pedido
  
    //Cria a tabela temporária
    oTempTable:= FWTemporaryTable():New(cAliasTmp)
    oTempTable:SetFields( aCampos )
    oTempTable:AddIndex("1", {"B8_LOTECTL"} )
    oTempTable:Create()  
  
    //Popula a tabela temporária
    Processa({|| fPopula(nOpc)}, 'Processando...')
  
    //Adiciona as colunas que serão exibidas no FWMarkBrowse
    aColunas := fCriaCols()
  
    aSeek := {}
    cCampoAux := "B8_LOTECTL"
    aAdd(aSeek,{GetSX3Cache(cCampoAux, "X3_TITULO"), {{"", GetSX3Cache(cCampoAux, "X3_TIPO"), GetSX3Cache(cCampoAux, "X3_TAMANHO"), GetSX3Cache(cCampoAux, "X3_DECIMAL"), AllTrim(GetSX3Cache(cCampoAux, "X3_TITULO")), AllTrim(GetSX3Cache(cCampoAux, "X3_PICTURE"))}} } )
       
    //Criando a janela
    DEFINE MSDIALOG oDlgMark TITLE "Pesquisa - Lotes " + IIF(nOpc==1,"Atuais","Finalizados") FROM 000, 000  TO 400, 950 COLORS 0, 16777215 PIXEL
        //Dados
        oPanGrid := tPanel():New(001, 001, '', oDlgMark, , , , RGB(000,000,000), RGB(254,254,254), (nJanLarg/2)-1,     (nJanAltu/2 - 1))
        oMarkBrowse:= FWMarkBrowse():New()
        oMarkBrowse:SetDescription('') //Titulo da Janela
        oMarkBrowse:SetAlias(cAliasTmp)
        oMarkBrowse:oBrowse:SetDBFFilter(.T.)
        oMarkBrowse:oBrowse:SetUseFilter(.F.) //Habilita a utilização do filtro no Browse
        oMarkBrowse:oBrowse:SetFixedBrowse(.T.)
        oMarkBrowse:SetWalkThru(.F.) //Habilita a utilização da funcionalidade Walk-Thru no Browse
        oMarkBrowse:SetAmbiente(.T.) //Habilita a utilização da funcionalidade Ambiente no Browse
        oMarkBrowse:SetTemporary(.T.) //Indica que o Browse utiliza tabela temporária
        oMarkBrowse:oBrowse:SetSeek(.T.,aSeek) //Habilita a utilização da pesquisa de registros no Browse
        oMarkBrowse:oBrowse:SetFilterDefault("") //Indica o filtro padrão do Browse
        oMarkBrowse:SetFieldMark('OK')
        oMarkBrowse:SetFontBrowse(oFontGrid)
        oMarkBrowse:SetOwner(oPanGrid)
       // oMarkBrowse:SetValid({|| U_zVid46Ok()})
        oMarkBrowse:SetColumns(aColunas)
        oMarkBrowse:Activate()
    ACTIVATE MsDialog oDlgMark CENTERED
  
    //Deleta a temporária e desativa a tela de marcação
    oTempTable:Delete()
    oMarkBrowse:DeActivate()
      
    RestArea(aArea)
Return
  
/*/{Protheus.doc} MenuDef
Botões usados no Browse
@author Daniel Atilio
@since 20/07/2022
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/
  
Static Function MenuDef()
    Local aRotina := {}
       
    //Criação das opções
    ADD OPTION aRotina TITLE 'Imprimir'  ACTION 'u_zVid46Ok'     OPERATION 2 ACCESS 0
Return aRotina
  
/*/{Protheus.doc} fPopula
Executa a query SQL e popula essa informação na tabela temporária usada no browse
@author Daniel Atilio
@since 20/07/2022
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/
  
Static Function fPopula(nOpc)
    Local cQryDados := ''
    Local nTotal := 0
    Local nAtual := 0
  
    //Monta a consulta
    cQryDados := " SELECT DISTINCT B8_LOTECTL, B8_X_CURRA "
	cQryDados += " FROM " + RetSqlName("SB8") + " SB8 " // SB8010
	cQryDados += " WHERE B8_FILIAL = '" + FwxFilial("SB8") + "' "
	cQryDados += " AND SB8.D_E_L_E_T_ = ' ' "
	cQryDados += " AND B8_LOTECTL IN ( "
	cQryDados += "     SELECT DISTINCT Z0F_LOTE FROM " + RetSqlName("Z0F") + " Z0F " // Z0F010
	cQryDados += "     WHERE Z0F_FILIAL = '" + FwxFilial("Z0F") + "' AND Z0F.D_E_L_E_T_ = ' ' "
	cQryDados += " ) "
	if nOpc == 1
		cQryDados += " AND B8_SALDO > 0 "
	else 
		cQryDados += " AND B8_SALDO = 0 "
	endif
	cQryDados += " AND B8_DATA BETWEEN '" + DToS( dDataDe ) + "' AND '" + DToS( dDataAte ) + "' "

    PLSQuery(cQryDados, 'QRYDADTMP')
  
    //Definindo o tamanho da régua
    DbSelectArea('QRYDADTMP')
    Count to nTotal
    ProcRegua(nTotal)
    QRYDADTMP->(DbGoTop())
  
    //Enquanto houver registros, adiciona na temporária
    While ! QRYDADTMP->(EoF())
        nAtual++
        IncProc('Analisando registro ' + cValToChar(nAtual) + ' de ' + cValToChar(nTotal) + '...')
  
        RecLock(cAliasTmp, .T.)
            (cAliasTmp)->OK := Space(2)
            (cAliasTmp)->B8_LOTECTL  := QRYDADTMP->B8_LOTECTL
            (cAliasTmp)->B8_X_CURRA  := QRYDADTMP->B8_X_CURRA
        (cAliasTmp)->(MsUnlock())
  
        QRYDADTMP->(DbSkip())
    EndDo
    QRYDADTMP->(DbCloseArea())
    (cAliasTmp)->(DbGoTop())
Return
  
/*/{Protheus.doc} fCriaCols
Função que gera as colunas usadas no browse (similar ao antigo aHeader)
@author Daniel Atilio
@since 20/07/2022
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/
  
Static Function fCriaCols()
    Local nAtual       := 0 
    Local aColunas := {}
    Local aEstrut  := {}
    Local oColumn
      
    //Adicionando campos que serão mostrados na tela
    //[1] - Campo da Temporaria
    //[2] - Titulo
    //[3] - Tipo
    //[4] - Tamanho
    //[5] - Decimais
    //[6] - Máscara
    aAdd(aEstrut, { 'B8_LOTECTL', 'Lote'  , GetSx3Cache("B8_LOTECTL","X3_TIPO"), GetSx3Cache("B8_LOTECTL","X3_TAMANHO"), GetSx3Cache("B8_LOTECTL","X3_DECIMAL"), ''})
    aAdd(aEstrut, { 'B8_X_CURRA', 'Curral', GetSx3Cache("B8_X_CURRA","X3_TIPO"), GetSx3Cache("B8_X_CURRA","X3_TAMANHO"), GetSx3Cache("B8_X_CURRA","X3_DECIMAL"), ''})
  
    //Percorrendo todos os campos da estrutura
    For nAtual := 1 To Len(aEstrut)
        //Cria a coluna
        oColumn := FWBrwColumn():New()
        oColumn:SetData(&('{|| ' + cAliasTmp + '->' + aEstrut[nAtual][1] +'}'))
        oColumn:SetTitle(aEstrut[nAtual][2])
        oColumn:SetType(aEstrut[nAtual][3])
        oColumn:SetSize(aEstrut[nAtual][4])
        oColumn:SetDecimal(aEstrut[nAtual][5])
        oColumn:SetPicture(aEstrut[nAtual][6])
  
        //Adiciona a coluna
        aAdd(aColunas, oColumn)
    Next
Return aColunas
  
/*/{Protheus.doc} User Function zVid46Ok
Função acionada pelo botão continuar da rotina
@author Daniel Atilio
@since 20/07/2022
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/
  
User Function zVid46Ok()
    Local aArea     := FWGetArea()
    Local cMarca    := oMarkBrowse:Mark()
    Local nTotal    := 0
      
    //Define o tamanho da régua
    DbSelectArea(cAliasTmp)
    (cAliasTmp)->(DbGoTop())
    Count To nTotal
    ProcRegua(nTotal)
    
    aLotes := {}
    //aAdd(aLotes, {})

    //Percorrendo os registros
    (cAliasTmp)->(DbGoTop())
    While ! (cAliasTmp)->(EoF())
        //Caso esteja marcado
        If oMarkBrowse:IsMark(cMarca)
            aAdd(aLotes, (cAliasTmp)->B8_LOTECTL )
        else
            if (nPos := aScan(aLotes, {|x| alltrim(x) == alltrim((cAliasTmp)->B8_LOTECTL)})) > 0 
                aDel(aLotes, nPos )
                aSize(aLotes, Len(aLotes)-1 )
            EndIf
        EndIf
        
        (cAliasTmp)->(DbSkip())
    EndDo
    
    if Len(aLotes) > 0
        FWMsgRun(,{|aLotes| U_bovr01Print(aLotes) },'Por Favor Aguarde...' , 'Processando Banco de Dados') 
    else
        msgInfo("Nenhum lote informado. Operação cancelada pelo usuário.")
    endif

    FWRestArea(aArea)
Return .T.
