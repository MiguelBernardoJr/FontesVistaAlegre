#include "totvs.ch"

/*/{Protheus.doc} rEspProd
	Relatório de Estornos de materiais
	@type function
	@author Cristiam Rossi
	@since 29/09/2025
/*/
user function rEstProd()
local oReport := ReportDef()
	oReport:printDialog()
return nil


/*/{Protheus.doc} ReporDef
	Layout do relatório
	@type function
	@author Cristiam Rossi
	@since 29/09/2025
/*/
Static Function ReportDef()
Local cAliasQry := GetNextAlias()
Local oReport	:= Nil
Local oSection	:= Nil
Local cPerg     := "REXTPROD"

    criaSX1( cPerg )
    Pergunte( cPerg, .T. )

    oReport := TReport():New( "rExtProd",;
        "Relatorio de Estornos de Materiais",;
        cPerg,;
        {|oReport| ReportPrint(oReport,cAliasQry)},;
        "Este relatorio imprimira materiais estornados")
	
    oSection := TRSection():New(oReport,"Relacao_Materias",{"SD3"},,,)

    TRCell():New(oSection,"D3_DOC"     , ,"Documento" ,                          ,TamSx3("D3_DOC")[1]    ,/*lPixel*/,/*{|| }*/,,,,)
    TRCell():New(oSection,"D3_EMISSAO" , ,"Emissao"   ,                          ,10                     ,/*lPixel*/,/*{|| }*/,,,,)
    TRCell():New(oSection,"D3_USUARIO" , ,"Usuario"   ,                          ,TamSx3("D3_USUARIO")[1],/*lPixel*/,/*{|| }*/,,,,)
    TRCell():New(oSection,"D3_LOCAL"   , ,"Armazem"   ,                          ,TamSx3("D3_LOCAL")[1]  ,/*lPixel*/,/*{|| }*/,,,,)
    TRCell():New(oSection,"D3_COD"     , ,"Produto"   ,PesqPict("SB1","B1_COD")  ,TamSx3("D3_COD")[1]    ,/*lPixel*/,/*{|| }*/,,,,)
    TRCell():New(oSection,"D3_QUANT"   , ,"Quantidade",PesqPict("SD3","D3_QUANT"),TamSx3("D3_QUANT")[1]  ,/*lPixel*/,/*{|| }*/,,,,)
    TRCell():New(oSection,"D3_XMOTIV"  , ,"Motivo"    ,                          ,TamSx3("D3_XMOTIV")[1] ,/*lPixel*/,/*{|| }*/,,,,)
    TRCell():New(oSection,"X5_DESCRI"  , ,"Descricao" ,                          ,55                     ,/*lPixel*/,/*{|| }*/,,,,)
    TRCell():New(oSection,"D3_NUMSA"     , ,"Sol.Armaz.",                          ,TamSx3("D3_NUMSA")[1]    ,/*lPixel*/,/*{|| }*/,,,,)
    TRCell():New(oSection,"D3_XSEPSA"     , ,"Ord.Separ.",                          ,TamSx3("D3_XSEPSA")[1]    ,/*lPixel*/,/*{|| }*/,,,,)
    TRCell():New(oSection,"D3_OBSERVA" , ,"Observacao",                          ,TamSx3("D3_OBSERVA")[1],/*lPixel*/,/*{|| }*/,,,,)

return oReport


/*/{Protheus.doc} ReportPrint
	Query do relatório
	@type function
	@author Cristiam Rossi
	@since 29/09/2025
/*/
static Function ReportPrint(oReport,cAliasQry)
local oSection := oReport:Section(1)
local cExpress := "%"

    pergunte(oReport:uParam,.F.)

    cExpress += " D3_EMISSAO between '"+DtoS(MV_PAR02)+"' and '"+DtoS(MV_PAR03)+"'"
    cExpress += " and D3_COD between '"+MV_PAR04+"' and '"+MV_PAR05+"'"

    if ! empty( MV_PAR01 )
        cExpress += " and D3_USUARIO = '"+ MV_PAR01 +"'"
    endif
    if ! empty( MV_PAR06 )
        cExpress += " and D3_XMOTIV = '"+ MV_PAR06 +"'"
    endif

    cExpress += " %"

    oSection:BeginQuery()

    BeginSql Alias cAliasQry
        SELECT 
            D3_DOC, D3_COD, D3_EMISSAO, D3_LOCAL, D3_QUANT, D3_USUARIO, D3_OBSERVA
            , D3_XMOTIV, D3_NUMSA, D3_XSEPSA
            , X5_DESCRI
        FROM %Table:SD3% SD3
        JOIN %Table:SX5% SX5 
            ON  X5_FILIAL = %xfilial:SX5%
            AND X5_TABELA = 'E-'
            AND X5_CHAVE  = D3_XMOTIV
            AND SX5.%notdel%
        WHERE D3_FILIAL = %xFilial:SD3%
        AND   %exp:cExpress%
        AND SD3.%NotDel%
        ORDER BY D3_FILIAL, D3_DOC, D3_NUMSEQ, D3_COD
    EndSql 

    oSection:EndQuery()
    oSection:Print()
return nil


/*/{Protheus.doc} criaSX1
	Criação de perguntas
	@type function
	@author Cristiam Rossi
	@since 29/09/2025
/*/
static function criaSX1( cPerg )
local cSeq := "01"

    SX1->( DbSetOrder(1) )
    if ! SX1->( dbSeek( cPerg ) )
        recLock("SX1",.T.)
        SX1->X1_GRUPO   := cPerg
        SX1->X1_ORDEM   := cSeq
        SX1->X1_PERGUNT := "Usuario"
        SX1->X1_VARIAVL := "MV_CH0"
        SX1->X1_TIPO    := "C"
        SX1->X1_TAMANHO := 20
        SX1->X1_GSC     := "G"
        SX1->X1_VAR01   := "MV_PAR01"
        SX1->X1_F3      := "US3"
        msUnlock()
        cSeq := soma1( cSeq )

        recLock("SX1",.T.)
        SX1->X1_GRUPO   := cPerg
        SX1->X1_ORDEM   := cSeq
        SX1->X1_PERGUNT := "Emissao de"
        SX1->X1_VARIAVL := "MV_CH1"
        SX1->X1_TIPO    := "D"
        SX1->X1_TAMANHO := 8
        SX1->X1_GSC     := "G"
        SX1->X1_VAR01   := "MV_PAR02"
        msUnlock()
        cSeq := soma1( cSeq )

        recLock("SX1",.T.)
        SX1->X1_GRUPO   := cPerg
        SX1->X1_ORDEM   := cSeq
        SX1->X1_PERGUNT := "Emissao ate"
        SX1->X1_VARIAVL := "MV_CH2"
        SX1->X1_TIPO    := "D"
        SX1->X1_TAMANHO := 8
        SX1->X1_GSC     := "G"
        SX1->X1_VAR01   := "MV_PAR03"
        msUnlock()
        cSeq := soma1( cSeq )

        recLock("SX1",.T.)
        SX1->X1_GRUPO   := cPerg
        SX1->X1_ORDEM   := cSeq
        SX1->X1_PERGUNT := "Produto de"
        SX1->X1_VARIAVL := "MV_CH3"
        SX1->X1_TIPO    := "C"
        SX1->X1_TAMANHO := len( SB1->B1_COD )
        SX1->X1_GSC     := "G"
        SX1->X1_VAR01   := "MV_PAR04"
        SX1->X1_F3      := "SB1"
        msUnlock()
        cSeq := soma1( cSeq )

        recLock("SX1",.T.)
        SX1->X1_GRUPO   := cPerg
        SX1->X1_ORDEM   := cSeq
        SX1->X1_PERGUNT := "Produto ate"
        SX1->X1_VARIAVL := "MV_CH4"
        SX1->X1_TIPO    := "C"
        SX1->X1_TAMANHO := len( SB1->B1_COD )
        SX1->X1_GSC     := "G"
        SX1->X1_VAR01   := "MV_PAR05"
        SX1->X1_F3      := "SB1"
        msUnlock()
        cSeq := soma1( cSeq )

        recLock("SX1",.T.)
        SX1->X1_GRUPO   := cPerg
        SX1->X1_ORDEM   := cSeq
        SX1->X1_PERGUNT := "Motivo"
        SX1->X1_VARIAVL := "MV_CH5"
        SX1->X1_TIPO    := "C"
        SX1->X1_TAMANHO := len( SD3->D3_XMOTIV )
        SX1->X1_GSC     := "G"
        SX1->X1_VAR01   := "MV_PAR06"
        SX1->X1_F3      := "E-"
        msUnlock()
    endif
return nil
