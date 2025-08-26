#include 'Totvs.ch'


//
user function VAREST02()
local cPerg := "VAREST02"

    // Especifica��o direta do alias que se deseja selecionar
    DbSelectArea("SBE")
    DbSetOrder(1)

    if Pergunte(cPerg)
        RptStatus({|| ProcRel()}, "Aguarde...", "Imprimindo etiquetas...")
    endif

return nil

//fun��o estatica (s� existe aqui) que executa a query
static function ProcRel()

    local cSql := ""

    cSql :=     "SELECT SBE.BE_LOCAL, SBE.BE_LOCALIZ FROM " + RetSqlName("SBE") + " SBE" +;
                "WHERE SBE.BE_LOCAL BETWEEN '" + AllTrim(MV_PAR01) + "' AND '" + AllTrim(MV_PAR02) + "' "  +;
                "AND SBE.BE_LOCALIZ BETWEEN '" + AllTrim(MV_PAR03) + "' AND '" + AllTrim(MV_PAR04) + "' "  +;
                "AND SBE.D_E_L_E_T_ <> '*' "
    
    //DBUseArea( [ lNewArea ], [ cDriver ], < cFile >, < cAlias >, [ lShared ], [ lReadOnly ] )
    //"TOPCONN" para query em tabela do banco
    //TCGenQry() dispara a queery par ao DBAcces
    //ChangeQuery(cSql) traduz a query para a linguagem do banco 
    //"TMPSB1" Nome dado ao ALIAS da tabela selecionada
    DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(cSql)), "TMPSB1", .f., .f.)

        //faz uma barra de progresso com base na quantidade de registros da TMPSB1
        SetRegua(TMPSB1->(RecCount()))

        //repete enquanto n�o chegar ao ultimo registro
        while !TMPSB1->(Eof())
            
            // Chama fun��o de impress�o da etiquetas passando o armazem e o endere�o
            U_ImpEtqEnd({TMPSB1->BE_LOCAL, TMPSB1->BE_LOCALIZ}, IIF(!Empty(MV_PAR05), MV_PAR05, 'LPT1'))


            //incrementa barra de progresso 
            IncRegua()
            
            //vai para o pr�ximo registro
            TMPSB1->(DbSkip())
        end
    
    //libera a �rea de trabalho corrente para uso. Efetiva as atualiza��es pendentes e libera os registros.
    TMPSB1->(DbCloseArea())

return nil
