#include 'Totvs.ch'

/*/{Protheus.doc} vaacdv03
    Transferencia de Localização
    @type Function
    @author nathan.quirino@jrscatolon.com.br
    @since 17/07/2025
    @version 1.0.1
/*/


/*   _________________________________________
--  |    DESCRICAO DO PRODUTO                 |
--  |    CONT. DA DESCRICAO                   |  
--  |    LOCALIZ: B10101 QTD.:XXXXXX UM       |  
--  |    |CODEBAR|CODEBARCODEBAR|CODEBAR|     |
--  |_________________________________________|

Produto Avulso Com Quantidade VAREST07

CRIAR PERGUNTAS VAREST07

    Pergunta:   Produto ?
    Tipo:       C
    Tamanho:    15
    Help:       Informe o código do produto para impressão da etiqueta.
    F3:         SB1
    
    Pergunta:   Quantidade Prod por Etiqueta? ?
    Tipo:       C
    Tamanho:    7
    Help:       Informe a quantidade de produtos que serão representados por esta etiqueta.Pergunta:   Quantidade?

    Pergunta:   Quantidade de Etiquetas?
    Tipo:       N
    Tamanho:    4
    Help:       Informe a quantidade de etiquetas que serão impressas

    Pergunta:   Porta?
    Tipo:       C
    Tamanho:    4
    Help:       Porta para impressora.

*/
user function VAREST07()
local cPerg := "VAREST07"

    // Especificação direta do alias que se deseja selecionar
    DbSelectArea("SB1")
    DbSetOrder(1)

    if Pergunte(cPerg, .T.)
        RptStatus({|| ProcRel()}, "Aguarde...", "Imprimindo etiquetas...")
    endif

return nil

//função estatica (só existe aqui) que execura a query
static function ProcRel()

    local nI
    local cSql := ""

    cSql := " SELECT B1_CODBAR, B1_DESC, B1_LOCALI, B1_UM" +;
            " FROM " + RetSqlName("SB1") + " SB1" +;
            " WHERE SB1.B1_FILIAL  = ' ' " +;
            " AND SB1.B1_COD = '" + MV_PAR01 +"'"+;
            " AND SB1.D_E_L_E_T_ <> '*'  "

    //DBUseArea( [ lNewArea ], [ cDriver ], < cFile >, < cAlias >, [ lShared ], [ lReadOnly ] )
    //"TOPCONN" para query em tabela do banco
    //TCGenQry() dispara a queery par ao DBAcces
    //ChangeQuery(cSql) traduz a query para a linguagem do banco 
    //"TMPSB1" Nome dado ao ALIAS da tabela selecionada
    DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(cSql)), "TMPSB1", .f., .f.)

        //faz uma barra de progresso com base na quantidade de registros da TMPSB1
        SetRegua(TMPSB1->(RecCount()))

        //repete enquanto não chegar ao ultimo registro
        while !TMPSB1->(Eof())

            // Adiciona um laço FOR para repetir a impressão
            // O laço vai de 1 até a quantidade informada em MV_PAR03
            for nI := 1 to Val(MV_PAR03)
                // Chama função de impressão da etiquetas passando a descrição do produto e o código como parametros
                U_ImpEtPdAv({TMPSB1->B1_DESC, TMPSB1->B1_CODBAR, TMPSB1->B1_LOCALI, TMPSB1->B1_UM},MV_PAR02, IIF(!Empty(MV_PAR03), MV_PAR03, 'LPT1'))

            next nI
            
            //incrementa barra de progresso 
            IncRegua()
            
            //vai para o próximo registro
            TMPSB1->(DbSkip())
        end
    
    //libera a Área de trabalho corrente para uso. Efetiva as atualizações pendentes e libera os registros.
    TMPSB1->(DbCloseArea())
return nil
