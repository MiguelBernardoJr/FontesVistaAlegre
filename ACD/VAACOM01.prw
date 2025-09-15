#include "PROTHEUS.ch"
#include "FWMVCDef.ch"

/*/{Protheus.doc} vaacdv03
    Transferencia de Localização
    @type Function
    @author nathan.quirino@jrscatolon.com.br
    @since 17/07/2025
    @version 1.0.1
/*/

static cCanPrint := getMV("VA_CANPR",, "000000")
static cCposCabec := "F1_FILIAL|F1_DOC|F1_SERIE|F1_FORNECE|F1_LOJA"
static cCPosBrowse := "ZA0_NOME|ZA0_TES|ZA0_TIPO"

User function VAACOM01()
    //local cvarnaousada := ""
    Local bkeyF12 := SetKey(VK_F12, {||Pergunte('VAACOM01', .T.)})
    Local cPar01 := MV_PAR01
    Local cNome

    Pergunte('VAACOM01', .F.)    

    DbSelectArea("SD1")
    DbSetOrder(1)
    DbSelectArea("SF4")
    DbSetOrder(1)
    DbSelectArea("SF1")
    DbSetOrder(1)
    DbSelectArea("ZA0")
    DbSetOrder(1)
    DbSelectArea("SA1")
    DbSetOrder(1)
    DbSelectArea("SA2")
    DbSetOrder(1)
    DbSelectArea("ZA0")
    DbSetOrder(1)

    IF !SF1->F1_TIPO $ 'N|B'

        Help(nil, nil, "Tipo Inválido", nil, "Para emitir etiquetas é necessário que o tipo de nota fiscal seja normal ou beneficiamento (para poder de Terceiros). Não é possível emitir etiqueta para os demais tipos de nota fiscal.", 1, 0, nil, nil, nil, nil, nil, {"Por favor, selecione uma nota fiscal do tipo normal para que seja possível imprimir as etiquetas."})

    ELSEIF !AllTrim(SF1->F1_ESPECIE)$"SPED|NFE"

        Help(nil, nil, "Espécie Inválida", nil, "Para emitir etiquetas é necessário que a espécie de nota fiscal seja 'SPED' ou 'NFE'. Não é possível emitir etiqueta para as demais espécies de nota fiscal.", 1, 0, nil, nil, nil, nil, nil, {"Por favor, selecione uma nota fiscal cuja espécie seja 'SPED' ou 'NFE' para que seja possível imprimir as etiquetas."})
    
    ELSE
            
        if SF1->F1_TIPO == "B"

            SA1->(DbSeek(FwxFilial('SA1')+SF1->F1_FORNECE+SF1->F1_LOJA))
            cNome := SA1->A1_NREDUZ
            
        else

            SA2->(DbSeek(FwxFilial('SA2')+SF1->F1_FORNECE+SF1->F1_LOJA))
            cNome := SA2->A2_NREDUZ

        endif
   

       DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(;
         " select D1_ITEM, D1_COD, D1_UM, D1_QUANT, D1_SEGUM, D1_QTSEGUM, F4_PODER3, D1_TES"+;
           " from " + RetSqlName("SD1") + " SD1"+;
           " left join " + RetSqlName("SF4") + " SF4"+;
            "  on SF4.F4_FILIAL  = '" + FWxFIlial("SF4") + "'"+;
            " and SF4.F4_CODIGO  = SD1.D1_TES"+;
            " and SF4.F4_ESTOQUE = 'S'"+;
            " and SF4.D_E_L_E_T_ = ' '"+;
           " left join " + RetSqlName("ZA0") + " ZA0" +;
             " on ZA0.ZA0_FILIAL = '" + FWxFIlial("ZA0") + "'"+;
            " and ZA0.ZA0_DOC    = SD1.D1_DOC"+;
            " and ZA0.ZA0_SERIE  = SD1.D1_SERIE"+;
            " and ZA0.ZA0_FORNEC = SD1.D1_FORNECE"+;
            " and ZA0.ZA0_LOJA   = SD1.D1_LOJA"+;
            " and ZA0.ZA0_ITEM   = SD1.D1_ITEM"+;
            " and ZA0.D_E_L_E_T_ = ' '"+;
          " where SD1.D1_FILIAL  = '" + FWxFilial("SD1") + "'"+;
            " and SD1.D1_DOC     = '" + SF1->F1_DOC + "'"+;
            " and SD1.D1_SERIE   = '" + SF1->F1_SERIE + "'"+;
            " and SD1.D1_FORNECE = '" + SF1->F1_FORNECE + "'"+;
            " and SD1.D1_LOJA    = '" + SF1->F1_LOJA + "'"+;
            " and SD1.D_E_L_E_T_ = ' '"+;
            " and ZA0.ZA0_FILIAL IS NULL";
              )),"TMPSD1", .f., .f.)

        if !TMPSD1->(Eof())

            while !TMPSD1->(Eof())
                SB1->(DbSeek(FWxFIlial('SB1')+TMPSD1->D1_COD))
                RecLock("ZA0", .t.)
                    ZA0->ZA0_FILIAL := FWxFilial("ZA0")
                    ZA0->ZA0_DOC    := SF1->F1_DOC
                    ZA0->ZA0_SERIE  := SF1->F1_SERIE
                    ZA0->ZA0_ITEM   := TMPSD1->D1_ITEM
                    ZA0->ZA0_COD    := TMPSD1->D1_COD
                    ZA0->ZA0_FORNEC := SF1->F1_FORNECE
                    ZA0->ZA0_LOJA   := SF1->F1_LOJA
                    ZA0->ZA0_NOME   := cNome
                    ZA0->ZA0_UM     := TMPSD1->D1_UM
                    ZA0->ZA0_QUANT  := TMPSD1->D1_QUANT
                    ZA0->ZA0_SEGUM  := TMPSD1->D1_SEGUM
                    ZA0->ZA0_QTSEGU := TMPSD1->D1_QTSEGUM
                    ZA0->ZA0_MARC   := .F.
                    ZA0->ZA0_QTDPET := 1
                    ZA0->ZA0_NETAIM := 1
                    ZA0->ZA0_NRETIM := 0
                    ZA0->ZA0_SUQTET := 1
                    ZA0->ZA0_SUNAIM := 0
                    //ZA0->ZA0_SUNRIM := 0
                    ZA0->ZA0_LOCALI := SB1->B1_LOCALI
                    ZA0->ZA0_LOC2UM := SB1->B1_LOC2UM
                    ZA0->ZA0_TES    := TMPSD1->D1_TES
                    ZA0->ZA0_TIPO   := SF1->F1_TIPO


                MsUnlock()

                TMPSD1->(DbSkip())

            end
            
        endif
        TMPSD1->(DbCloseArea())
            DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(;
                "SELECT A2_CONFFIS FROM " + RetSqlName("SA2") +;
                "WHERE A2_FILIAL = '"+ FWxFIlial("SA2")+"'" +;
                "AND A2_COD = '" + SF1->F1_FORNECE + "'"+;
                "AND A2_LOJA = '" + SF1->F1_LOJA + "'"+;
                "AND D_E_L_E_T_ = ' '";
                    )),"TMPSA2", .f., .f.)

        if ((FwIsInCallStack("MATA103")) .AND. ((TMPSA2->A2_CONFFIS = '1') .OR. ((TMPSA2->A2_CONFFIS = '0') .AND. (getMV("MV_TPCONFF",,) <> '2'))))
            Help(nil, nil, "CONFERENCIA FISICA", nil, "Não é possivel emitir etiquetas para essa nota. O fornecedor ou o parâmetro MV_TPCONFF não permitem conferência no documento de entrada", 1, 0, nil, nil, nil, nil, nil, {""})
        elseif ((FwIsInCallStack("MATA140")) .AND. ((TMPSA2->A2_CONFFIS = '2') .OR. ((TMPSA2->A2_CONFFIS = '0') .AND. (getMV("MV_TPCONFF",,) <> '1'))))
            Help(nil, nil, "CONFERENCIA FISICA", nil, "Não é possivel emitir etiquetas para essa nota. O fornecedor ou o parâmetro MV_TPCONFF não permitem conferência no pré-documento de entrada.", 1, 0, nil, nil, nil, nil, nil, {""})
        elseif TMPSA2->A2_CONFFIS = '3'
            Help(nil, nil, "CONFERENCIA FISICA", nil, "Não é possivel emitir etiquetas para essa nota.", 1, 0, nil, nil, nil, nil, nil, {"Por favor, selecione uma nota fiscal cujo cornecedor possua conferência física habilitada."})
            
        else   
            
            if FwIsInCallStack("MATA103")
                DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(;
                "select COUNT(*) ZA0CNT"+;
                " from "+ RetSqlName("ZA0") + " ZA0"+;
                " where ZA0.ZA0_FILIAL = '"+ FWxFIlial("ZA0") +"'"+;
                " and ZA0.ZA0_DOC    = '" + SF1->F1_DOC + "'"+;
                " and ZA0.ZA0_SERIE  = '" + SF1->F1_SERIE + "'" +;
                " and ZA0.ZA0_FORNEC = '" + SF1->F1_FORNECE + "'" +;
                " and ZA0.ZA0_LOJA   = '" + SF1->F1_LOJA + "'" +;
                " and ZA0.ZA0_TES    <> ' '"+;
                " and ZA0.D_E_L_E_T_ = ' '";
                    )),"TMPCNT", .f., .f.)

                if TMPCNT->ZA0CNT > 0
                    nValor := FwExecView('Nota Fiscal de Entrada', 'VAACOM01', MODEL_OPERATION_UPDATE, /*[ oDlg ]*/ , /*[ bCloseOnOK ]*/ , /*[ bOk ]*/ , /*nPercReducao*/ , /*[ aEnableButtons ]*/, /*[ bCancel ]*/, /*[ cOperatId ]*/, /*[ cToolBar ]*/, /*[ oModelAct ]*/)
                else
                    Help(nil, nil, "MOVIMENTA ESTOQUE", nil, "Não foram encontrados itens que movimentem estoque na nota fiscal selecionada. Não é possivel emitir etiquetas para essa nota.", 1, 0, nil, nil, nil, nil, nil, {"Por favor, selecione uma nota fiscal que possua itens que movimentem estoque para que seja possível imprimir as etiquetas."})
                endif
                TMPCNT->(DbCloseArea())
            else 
                nValor := FwExecView('Pré-Nota Fiscal de Entrada', 'VAACOM01', MODEL_OPERATION_UPDATE, /*[ oDlg ]*/ , /*[ bCloseOnOK ]*/ , /*[ bOk ]*/ , /*nPercReducao*/ , /*[ aEnableButtons ]*/, /*[ bCancel ]*/, /*[ cOperatId ]*/, /*[ cToolBar ]*/, /*[ oModelAct ]*/)
            endif
            
        endif
            TMPSA2->(DbCloseArea())
    ENDIF
    
    SetKey(VK_F12, bkeyF12)
    MV_PAR01 := cPar01

Return nil


/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor:                                                              |
 | Data:  07/07/2020                                                   |
 | Desc:  Criaçao do modelo de dados MVC                               |
 *---------------------------------------------------------------------*/
Static Function ModelDef()
    Local oModel     := Nil
    Local oStPai     := FWFormStruct(1, 'SF1', {|cCampo| AllTrim(cCampo)$cCPosCabec})
    Local oStFilho   := FWFormStruct(1, 'ZA0', {|cCampo| !AllTrim(cCampo)$cCPosBrowse})
    Local aZA0Rel    := {}


    //Criando o modelo e os relacionamentos
    oModel := MPFormModel():New('UVAACOM01',,,{|oModel| FormCommit(oModel)})
    oModel:AddFields('SF1MASTER',/*cOwner*/,oStPai)
    oModel:AddGrid('ZA0DETAIL','SF1MASTER',oStFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,{|X,Y| LoadZA0(X,Y)})  //cOwner é para quem pertence
    
    //Fazendo o relacionamento entre o Pai e Filho
    //aAdd(aSF1Rel, {'F1_FILIAL','xFilial("ZA0")'} )
    AAdd(aZA0Rel, {'ZA0_DOC','F1_DOC'} )
    AAdd(aZA0Rel, {'ZA0_SERIE','F1_SERIE'})
    AAdd(aZA0Rel, {'ZA0_FORNEC','F1_FORNECE'})
    AAdd(aZA0Rel, {'ZA0_LOJA','F1_LOJA'}) 

    oModel:SetRelation('ZA0DETAIL', aZA0Rel, ZA0->(IndexKey(1))) //IndexKey -> quero a ordenaçao e depois filtrado
    //oModel:GetModel('ZA0DETAIL'):SetUniqueLine({"ZZ3_DESC"})    //Nao repetir informaçoes ou combinaçoes {"CAMPO1","CAMPO2","CAMPOX"}
    oModel:SetPrimaryKey({ "F1_DOC", "F1_SERIE", "F1_FORNECE", "F1_LOJA" })
    
    //Setando as descriçoes
    oModel:SetDescription("Etiquetas de Entrada")
    oModel:GetModel('SF1MASTER'):SetDescription('Nota Fiscal de Entrada')
    oModel:GetModel('ZA0DETAIL'):SetDescription('Etiquetas')

    // Bloqueia alteração e exclusão da linha
    oModel:GetModel( 'ZA0DETAIL' ):SetNoInsertLine( .T. )
    oModel:GetModel( 'ZA0DETAIL' ):SetNoDeleteLine( .T. )
Return oModel

/*/{Protheus.doc} FormCommit
Bloco de código de persistência dos dados, invocado pelo método CommitData. 
Aqui deve apenas retornar .t. pois a gravação dos registro é feita no momento da alteração
@author jr.andre
@since 10/07/2020
@version 1.0
@return lRet, Retorna se os dados foram persistidos com sucesso
@param oModel, object, descricao
@type function
/*/
static function FormCommit(oModel)
local aArea := GetArea()
local aAreaZA0 := ZA0->(GetArea()) 
local lRet := .t.
local oGridModel := oModel:GetModel("ZA0DETAIL")
local i, j, nLen


    // Grava os dados do modelo
    FWFormCommit(oModel)

    // Atualiza os demais dados
    ZA0->(DbSetOrder(1)) // ZA0_FILIAL+ZA0_DOC+ZA0_SERIE+ZA0_FORNEC+ZA0_LOJA+ZA0_COD+ZA0_ITEM

    for i := 1 to oGridModel:Length()

        if oGridModel:GetValue("ZA0_MARC", i)
            // Garante que o registro foi encontrado antes de tentar qualquer operação
            if ZA0->(DbSeek(FWxFilial("ZA0")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+oGridModel:GetValue("ZA0_COD", i)+oGridModel:GetValue("ZA0_ITEM", i)))
                RecLock("ZA0", .f.)
                // Incrementa a quantidade de etiquetas imrpessas na primeira unidade de medida
                if oGridModel:GetValue("ZA0_NETAIM", i) > 0
                    ZA0->ZA0_NRETIM := ZA0->ZA0_NRETIM + (oGridModel:GetValue("ZA0_NETAIM", i) * oGridModel:GetValue("ZA0_QTDPET", i))
                endif

                // Incrementa a quantidade de etiquetas impressas na segunda unidade de medida
                if oGridModel:GetValue("ZA0_SUNAIM", i) > 0
                    ZA0->ZA0_NRETIM := ZA0->ZA0_NRETIM + ConvUM(oGridModel:GetValue("ZA0_COD", i), 0,  (oGridModel:GetValue("ZA0_SUNAIM", i) * oGridModel:GetValue("ZA0_SUQTET", i)), 1)
                endif

                // Autaliza o LOG
                ZA0->ZA0_LGIMPE := ZA0->ZA0_LGIMPE +;
                                  Iif(Empty(ZA0->ZA0_LGIMPE), "", CRLF + CRLF) +;
                                  Replicate("*", 80) + CRLF +;
                                  "Data: " + DToS(Date()) + "-" + Time() + CRLF +;
                                  "Usuário: " + __cUserId + " " + cUserName + CRLF +;
                                  "Etiquetas 1 UM: " + AllTrim(Str(oGridModel:GetValue("ZA0_NETAIM", i))) + CRLF +;
                                  "Qtd/Etiqueta 1 UM: " + AllTrim(Str(oGridModel:GetValue("ZA0_QTDPET", i)))  + CRLF +;
                                  "Etiquetas 2 UM: " + AllTrim(Str(oGridModel:GetValue("ZA0_SUNAIM", i))) + CRLF +;
                                  "Qtd/Etiqueta 2 UM: " + AllTrim(Str(oGridModel:GetValue("ZA0_SUQTET", i)))

                // Zera as quantidades a imprimir, pois a impressão ocorrerá logo em seguida
                ZA0->ZA0_SUNAIM := 0
                ZA0->ZA0_NETAIM := 0
                MsUnlock()
            endif

            SF4->(DbSeek(FwxFilial('SF4')+ZA0->ZA0_TES))

            // Imprime as etiquetas
            if (nLen := oGridModel:GetValue("ZA0_NETAIM", i) ) > 0
                for j := 1 to nLen
 
                    if (!SF4->F4_PODER3 $ "R")
                        u_ImpEtqACD(oGridModel:GetValue("ZA0_DESCRI", i),; 
                                    oGridModel:GetValue("ZA0_COD", i),;
                                    oGridModel:GetValue("ZA0_FORNEC", i),;
                                    oGridModel:GetValue("ZA0_LOJA", i),;
                                    DToC(SF1->F1_DTDIGIT),; 
                                    oGridModel:GetValue("ZA0_QTDPET", i),; // Qtd por etq na Prim UM   
                                    "1", ; 
                                    oGridModel:GetValue("ZA0_UM", i),;
                                    oGridModel:GetValue("ZA0_LOCALI", i),;
                                    ZA0->ZA0_DOC,;
                                    ZA0->ZA0_SERIE,;
                                    AllTrim(Posicione('SB1', 1, FWxFilial('SB1') + oGridModel:GetValue("ZA0_COD", i), 'B1_CODBAR')),; 
                                    IIF(!Empty(MV_PAR01), MV_PAR01, "LPT1");
                        )
                    else         
                        u_ImpEtqTER(ZA0->ZA0_TIPO,;
                                    ZA0->ZA0_NOME,;
                                    ZA0->ZA0_FORNEC,;
                                    ZA0->ZA0_LOJA,;
                                    oGridModel:GetValue("ZA0_DESCRI", i),; 
                                    oGridModel:GetValue("ZA0_COD", i),;
                                    DToC(SF1->F1_DTDIGIT),; 
                                    oGridModel:GetValue("ZA0_QTDPET", i),; // Qtd por etq na Prim UM   
                                    oGridModel:GetValue("ZA0_UM", i),;
                                    ZA0->ZA0_DOC,;
                                    ZA0->ZA0_SERIE,;
                                    AllTrim(Posicione('SB1', 1, FWxFilial('SB1') + oGridModel:GetValue("ZA0_COD", i), 'B1_CODBAR')),; 
                                    IIF(!Empty(MV_PAR01), MV_PAR01, "LPT1");
                        )
                    endif
                next
            endif

            if (nLen := oGridModel:GetValue("ZA0_SUNAIM", i) ) > 0
                for j := 1 to nLen
 
                if (!SF4->F4_PODER3 $ "D|R")
                    u_ImpEtqACD(oGridModel:GetValue("ZA0_DESCRI", i),; 
                                oGridModel:GetValue("ZA0_COD", i),;
                                oGridModel:GetValue("ZA0_FORNEC", i),;
                                oGridModel:GetValue("ZA0_LOJA", i),;
                                DToC(SF1->F1_DTDIGIT),;
                                oGridModel:GetValue("ZA0_SUQTET", i),; // Qtd por etq na Seg UM  
                                "2", ;  
                                oGridModel:GetValue("ZA0_SEGUM", i),;
                                oGridModel:GetValue("ZA0_LOC2UM", i),;
                                ZA0->ZA0_DOC,;
                                ZA0->ZA0_SERIE,;
                                AllTrim(Posicione('SB1', 1, FWxFilial('SB1') + oGridModel:GetValue("ZA0_COD", i), 'B1_CODBAR')),;
                                IIF(!Empty(MV_PAR01), MV_PAR01, "LPT1");
                    )
                else
                    u_ImpEtqTER(ZA0->ZA0_TIPO,;
                                ZA0->ZA0_NOME,;
                                ZA0->ZA0_FORNEC,;
                                ZA0->ZA0_LOJA,;
                                oGridModel:GetValue("ZA0_DESCRI", i),; 
                                oGridModel:GetValue("ZA0_COD", i),;
                                DToC(SF1->F1_DTDIGIT),; 
                                oGridModel:GetValue("ZA0_SUQTET", i),; // Qtd por etq na Prim UM   
                                oGridModel:GetValue("ZA0_SEGUM", i),;
                                ZA0->ZA0_DOC,;
                                ZA0->ZA0_SERIE,;
                                AllTrim(Posicione('SB1', 1, FWxFilial('SB1') + oGridModel:GetValue("ZA0_COD", i), 'B1_CODBAR')),; 
                                IIF(!Empty(MV_PAR01), MV_PAR01, "LPT1");
                    )
                endif
                next
            endif
        endif
    next

if lRet
    U_VAMT140TOK(2) // Altera Status da mensagem no telegram para "Em conferencia"
endif

if !Empty(aAreaZA0)
    RestArea(aAreaZA0)
endif

if !Empty(aArea)
    RestArea(aArea)
endif

return lRet

/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor:                                                              |
 | Data:  08/07/2020                                                   |
 | Desc:  Criaçao da visao MVC                                         |
 *---------------------------------------------------------------------*/
Static Function ViewDef()
    Local oView     := Nil
    Local oModel    := ModelDef()   //FWLoadModel('zModel3')
    Local oStPai    := FWFormStruct(2, 'SF1', {|cCampo| AllTrim(cCampo)$cCPosCabec})
    Local oStFilho  := FWFormStruct(2, 'ZA0', {|cCampo| !AllTrim(cCampo)$cCPosBrowse})
    //local i

    //Não permite a edição dos campos do cabeçalho
    oStPai:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)

    oStFilho:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
    oStFilho:SetProperty('ZA0_MARC', MVC_VIEW_CANCHANGE, .T.)
    oStFilho:SetProperty('ZA0_QTDPET', MVC_VIEW_CANCHANGE, .T.)
    oStFilho:SetProperty('ZA0_NETAIM', MVC_VIEW_CANCHANGE, .T.) 
    oStFilho:SetProperty('ZA0_SUQTET', MVC_VIEW_CANCHANGE, .T.)
    oStFilho:SetProperty('ZA0_SUNAIM', MVC_VIEW_CANCHANGE, .T.) 

    //Criando a View
    oView := FWFormView():New()
    oView:SetModel(oModel)

    /*oView:AddUserButton( 'Log', 'CLIPS', {|oView| MsgInf(Posicione('ZA0', 1, FWxFilial('ZA0') +;
                                                    SF1->F1_DOC +;
                                                    SF1->F1_SERIE +;
                                                    SF1->F1_FORNECE +;
                                                    SF1->F1_LOJA +;
                                                    oGridModel:GetValue("ZA0_COD", 1) +;
                                                    oGridModel:GetValue("ZA0_ITEM", 1) , 'ZA0_LGIMPE'),;
    'Log de impressao de etiqueta')}, "Mostra o Log de Impressao de Etiquetas",,,.t.) */
    oView:AddUserButton( 'Log', 'CLIPS', {|oView| MsgInf(FWFLDGET("ZA0_LGIMPE"),'Log de impressao de etiqueta')}, "Mostra o Log de Impressao de Etiquetas",,,.t.)

    //Adicionando os campos do cabeçalho e o grid dos filhos
    oView:AddField('VIEW_SF1',oStPai,'SF1MASTER')
    oView:AddGrid('VIEW_ZA0',oStFilho,'ZA0DETAIL')
    
    //Setando o dimensionamento de tamanho
    oView:CreateHorizontalBox('CABEC',15)
    oView:CreateHorizontalBox('GRID',85)
    
    //Amarrando a view com as box
    oView:SetOwnerView('VIEW_SF1','CABEC')
    oView:SetOwnerView('VIEW_ZA0','GRID')
    
    //Habilitando título
    oView:EnableTitleView('VIEW_SF1','Nota Fiscal')
    oView:EnableTitleView('VIEW_ZA0','Etiquetas')
    
    //Força o fechamento da janela na confirmaçao
    oView:SetCloseOnOk({||.T.})
    
return oView


user function VMACOM01()
local lRet := .T.

    if (cVar := ReadVar()) == 'M->ZA0_QTDPET'
    
        //Deve ser maior que 0 e menor que a quantidade do item na 1ª UM.
        if M->ZA0_QTDPET <= 0 .OR. M->ZA0_QTDPET > FWFLDGET("ZA0_QUANT")
            Help(nil, nil, "Quantidade por Etiqueta Inválida", nil, "Para emitir etiquetas é necessário que a     quantidade de produtos que a etiqueta representa seja maior que zero e menor que a quantidade da primeira unidade.", 1, 0, nil, nil, nil, nil, nil, {"Por favor, digite um valor maior que zero e menor que a quantidade da primeira unidade."})
            lRet := .F.
        endif
    
    elseif cVar == 'M->ZA0_NETAIM'
    
        if M->ZA0_NETAIM < 0
            Help(nil, nil, "Nro de etiquetas a serem impressas", nil, "Esse campo não aceita valores negativos.", 1, 0, nil, nil, nil, nil, nil, {"Por favor, digite um valor maior que ou igual a zero."})
            lRet := .F.
        elseif (M->ZA0_NETAIM * FWFLDGET("ZA0_QTDPET")) > (FWFLDGET("ZA0_QUANT") - FWFLDGET("ZA0_NRETIM"))
            if (__cUserId $ cCanPrint)
                lRet := MsgYesNo('O número de etiquetas a serem impressas é maior que o a quantidade de produtos da unidade, deseja realmente imprimir etiquetas a mais?', 'Nro de etiquetas a serem impressas ')
            else
                Help(nil, nil, "Nro de etiquetas a serem impressas", nil, "Você não tem permissão para imprimir esta quantidade de etiquetas. O número de etiquetas a serem impressas excede o limite da quantidade permitida para impressão.", 1, 0, nil, nil, nil, nil, nil, {"Por favor, digite um valor menor."})
                lRet := .F.
            endif   
        endif
    
    elseif cVar == 'M->ZA0_SUQTET'
    
        if M->ZA0_SUQTET < 0
            Help(nil, nil, "Nro de etiquetas a serem impressas", nil, "Esse campo não aceita valores negativos.", 1, 0, nil, nil, nil, nil, nil, {"Por favor, digite um valor maior que ou igual a zero."})
            lRet := .F.
        endif
    
    elseif cVar == 'M->ZA0_SUNAIM'
    
        if M->ZA0_SUNAIM < 0
            Help(nil, nil, "Nro de etiquetas a serem impressas", nil, "Esse campo não aceita valores negativos.", 1, 0,     nil, nil, nil, nil, nil, {"Por favor, digite um valor maior que ou igual a zero."})
            lRet := .F.
        elseif (M->ZA0_SUNAIM * FWFLDGET("ZA0_SUQTET")) > (FWFLDGET("ZA0_QTSEGU"))
            if (!__cUserId $ cCanPrint)
                lRet := MsgYesNo('O número de etiquetas a serem impressas é maior que o a quantidade de produtos da unidade, deseja realmente imprimir etiquetas a mais?', 'Nro de etiquetas a serem impressas ')
            else
                Help(nil, nil, "Nro de etiquetas a serem impressas", nil, "Você não tem permissão para imprimir esta quantidade de etiquetas. O número de etiquetas a serem impressas excede o limite da quantidade permitida para impressão.", 1, 0, nil, nil, nil, nil, nil, {"Por favor, digite um valor menor."})
                lRet := .F.
            endif
        endif
     
    endif

    FWFldPut("ZA0_MARC", lRet)

return lRet

user function tmacom01()
    viewdef()
return nil

static function LoadZA0(X,Y)
    
    local aLoad := FormLoadGrid(X,Y)

    //alterar aLoad


return aLoad

static function MsgInf(cMsgErro, cTitulo, cRotina)
    local oTexto, oDlgMsg, oBtnSave, oBtnOk 
    local cReadVar := Iif(Type("__ReadVar") <> "U".And. !Empty(__ReadVar), __ReadVar, "") //Guarda o conteudo do ReadVar porque o SetFocus limpa essa variavel

    default cRotina := FunName()

    DEFINE MSDIALOG oDlgMsg FROM    62,100 TO 320,510 TITLE OemToAnsi(cTitulo) PIXEL

    @ 003, 004 TO 027, 200 LABEL "Help" OF oDlgMsg PIXEL //
    @ 030, 004 TO 110, 200 OF oDlgMsg PIXEL

    @ 010, 008 MSGET OemToAnsi(cRotina) WHEN .F. SIZE 188, 010 OF oDlgMsg PIXEL

    @ 036, 008 GET oTexto VAR OemToAnsi(cMsgErro) MEMO READONLY /*NO VSCROLL*/ SIZE 188, 070 OF oDlgMsg PIXEL

    oBtnSave := TButton():New(115, 100, "Salvar", oDlgMsg, {|| cFile := cGetFile( '*.txt' , 'Salvar Log', 1, 'C', .T., nOR( GETF_LOCALHARD, GETF_RETDIRECTORY, GETF_NETWORKDRIVE ),.T., .T. ), Iif( cFile == '', .T., MemoWrite( cFile, cMsgErro ) ) },,,,,,.T.)
    oBtnOk   := TButton():New(115, 170, "Ok", oDlgMsg, {|| oDlgMsg:End()},,,,,,.T.)
    oBtnOk:SetFocus()

    ACTIVATE MSDIALOG oDlgMsg CENTERED

    if !Empty(cReadVar)
        __ReadVar := cReadVar
    endif

return nil

user function vlmarci()
    local lRet := .T.
    //local cCodProd := M->ZA0_COD
    if(FwIsInCallStack("MATA140") .AND. (Posicione( "SB1",1, FWxFIlial("SB1")+AllTrim(FWFldGet("ZA0_COD")),'B1_XCTLEST') = 'N'))
        lRet := .F.
        Help(nil, nil, "Produto não controla estoque", nil, "Não é possível imprimir etiquetas para esse produto pois o mesmo não controla estoque.", 1, 0, nil, nil, nil, nil, nil, {"Por favor, verifique o campo CTRL. Estoque."})
    endif

return lRet
