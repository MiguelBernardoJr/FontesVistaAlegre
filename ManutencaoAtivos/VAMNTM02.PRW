#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "FWADAPTEREAI.CH"

// ###############################################################################################
// Projeto: 
// Fonte  : VAMNTM02.prw
// ---------+------------------------------------+------------------------------------------------
// Data     | Autor                              | Descricao
// ---------+------------------------------------+------------------------------------------------
//  02/03/22|  Manoel Filho                      | Estorno dos Titulos a Pagar gerados pelo 
//          |                                    | Abastecimento de Terceiros
// ---------+------------------------------------+------------------------------------------------
Static cTitulo := "Estorno dos Titulos de Abastecimento (SE2)"

User Function VAMNTM02()
    Local aArea   := GetArea()
    Local cFunBkp := FunName()

    SetFunName("VAMNTM02")

    oMarkBrwSE2 := FWMarkBrowse():New()
    //oMarkBrwSE2 := FWMBrowse():New()
    oMarkBrwSE2:SetAlias("SE2")
    oMarkBrwSE2:SetDescription(cTitulo)
    oMarkBrwSE2:SetFilterDefault('E2_ORIGEM = "VAMNTM01"')
    oMarkBrwSE2:SetFieldMark('E2_OK')
    //Legenda de Status do Titulo
    oMarkBrwSE2:AddLegend( "E2_SALDO  = E2_VALOR", "GREEN","Aberto","1") 
    oMarkBrwSE2:AddLegend( "E2_SALDO <> E2_VALOR", "RED",  "Baixado","1")
    
    oMarkBrwSE2:Activate() 
     
    SetFunName(cFunBkp)
    RestArea(aArea)

Return Nil

static function MenuDef()
local aRotina := {}
    AAdd( aRotina, { 'Estornar'        , 'u_VAEstorno()', 0, 4, 0, NIL } ) 
    
return aRotina

static function ModelDef()
local oModel := nil
local oStruSE2 := FWFormStruct(1, "SE2")

    oModel := MPFormModel():New('MD_VAMNTM02')
    oModel:addFields('MODEL_SE2',,oStruSE2)
    oModel:SetPrimaryKey({"E2_FILIAL","E2_FILIAL","E2_NUM","E2_PREFIXO","E2_PARCELA","E2_TIPO"})
    
return oModel

static function ViewDef()
local oView := nil
local oModel := ModelDef()
local oStrSE2:= FWFormStruct(2, 'SE2')

    oView := FWFormView():New()
    oView:SetModel(oModel) 
    oView:AddField('VIEW_SE2', oStrSE2, 'MODEL_SE2' )
    oView:CreateHorizontalBox( 'BOX_VIEW_SE2', 100)
    oView:SetOwnerView('VIEW_SE2','BOX_VIEW_SE2')
    
return oView

/*/{Protheus.doc} User Function VAEstorno
	Função utilizada para ESTORNAR Titulo do SE2 gerado pela rotina de Fechamento de Abastecimentos de Terceiros
	@type  Function
	@author Manoel Filho
	@since 02/03/2022
	@return 
/*/
User Function VAEstorno()
local aTitPag := {}      

Private lMsErroAuto := .F.

If MsgYesNo("Ao estornar será necessário reprocessar / gerar novamente o título referente aos abastecimentos na rotina Painel de Fechamento.", "Deseja realmente estornar?")

    Begin Transaction

	oMarkBrwSE2:SetFilterDefault('E2_ORIGEM = "VAMNTM01"') 
	(oMarkBrwSE2:Alias())->( DbGoTop() )
	While (oMarkBrwSE2:Alias())->( !Eof() )

		If ( oMarkBrwSE2:IsMark() ) // Estorna apenas os títulos selecionados

            aTitPag := {}

            Aadd(aTitPag, {"E2_FILIAL", SE2->E2_FILIAL,  nil})
            Aadd(aTitPag, {"E2_PREFIXO", SE2->E2_PREFIXO,nil})
            Aadd(aTitPag, {"E2_NUM", SE2->E2_NUM,        nil})
            Aadd(aTitPag, {"E2_PARCELA", SE2->E2_PARCELA,nil})
            Aadd(aTitPag, {"E2_TIPO", SE2->E2_TIPO,      nil})
            Aadd(aTitPag, {"E2_FORNECE", SE2->E2_FORNECE,nil})
            Aadd(aTitPag, {"E2_LOJA", SE2->E2_LOJA ,     nil})
            
            //Pergunte da rotina
            AcessaPerg("FINA080", .F.)      

            nOpc := 5 // Exclusão
            MsExecauto({|a,b,c,| FINA050(a,b,c)}, aTitPag,, nOpc)
                    
            If lMsErroAuto
                DisarmTransaction()
                MostraErro()
                Return
            Else
                // Limpa campo TQN_TITABA que relaciona as tabelas TQN e SE2
                cQuery := "UPDATE "+RetSqlName("TQN")+" SET TQN_TITABA = '                   ' "
                cQuery += " WHERE TQN_FILIAL = '"+xFilial("TQN")+"' AND "
                cQuery += " TQN_TITABA = '"+SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+"' AND "
                cQuery += " TQN_FORST9 = '"+SE2->E2_FORNECE+"' AND TQN_LOJST9 = '"+SE2->E2_LOJA+"' AND D_E_L_E_T_ = ' '"
                TcSqlExec( cQuery )

                // Limpa campo TL_TITABA que relaciona as tabelas STL e SE2
                cQuery := "UPDATE "+RetSqlName("STL")+" SET TL_TITABA = '                   ' "
                cQuery += " WHERE TL_FILIAL = '"+xFilial("STL")+"' AND "
                cQuery += " TL_TITABA = '"+SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO+"' AND "
                cQuery += " TL_FORST9 = '"+SE2->E2_FORNECE+"' AND TL_LOJST9 = '"+SE2->E2_LOJA+"' AND D_E_L_E_T_ = ' '"
                TcSqlExec( cQuery )
            EndIf

        Endif
    
    	(oMarkBrwSE2:Alias())->( DbSkip() )

    Enddo

    End transaction

    Alert("Estorno(s) realizado(s) com sucesso!!!")

Endif

Return

