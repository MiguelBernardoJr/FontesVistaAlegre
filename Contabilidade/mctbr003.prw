#include 'protheus.ch'
#include 'parmtype.ch'

#define DMPAPER_A4 9

// Criar campo
// -----------
// Campo:                CTL_XPERFI
// Tipo:                 C
// Tamanho:              1
// Contexto:             Real
// Propriedade:          Alterar
// Titulo:               Entidade
// Descrição:            Identificação da Entidade 
// Help:                 Campo customizado. Utilizado pela rotina mctbr003. Identifica se a entidade a que se refere o lançamento contábil é o Cliente ou o Fornecedor.
// Lista de Opções:      0=Não Utiliza;1=Cliente;2=Fornecedor3=Ambos 
// Inicializador Padrão: " "
// Validação Usuário:    Pertence(' 0123')
// Uso:                  Usado 

user function mctbr003()
local oReport
local cPerg := PadR('REST003',10)

private cAliasSql := ""
 
    oReport := ReportDef() 
    oReport:PrintDialog()
    
return nil
 
static function ReportDef()
local oReport
local oSection1
local oSection2
local cTitulo := 'Lista de lançamentos'
local cPerg 
 
    oReport := TReport():New('MCTBR003', cTitulo, 'MCTBR003', {|oReport| PrintReport(oReport)},"Este relatório imprimirá a relação de lançamentos por Fornecedor/Cliente.")
    oReport:SetLandscape()
    oReport:SetTotalInLine(.F.)
    oReport:ShowHeader()

    fs_GeraX1(oReport:uParam)
    Pergunte(oReport:uParam, .f.)
 
    oSection1 := TRSection():New(oReport,"Filial",{"QRY"})
    oSection1:SetTotalInLine(.F.)
 
    TRCell():New(oSection1, "cTipo",       "QRY", 'Tipo',                 "@!",                         10,                      /*lPixel*/, {|| cTipo      })
    TRCell():new(oSection1, "cCodigo",     "QRY", 'Código',               PesqPict('SA1',"A1_COD"),     TamSX3("A1_COD")[1]+1,   /*lPixel*/, {|| cCodigo    })
    TRCell():new(oSection1, "cLoja",       "QRY", 'Loja',                 PesqPict('SA1',"A1_LOJA"),    TamSX3("A1_LOJA")[1]+1,  /*lPixel*/, {|| cLoja      })
    TRCell():new(oSection1, "cNome",       "QRY", 'Nome',                 PesqPict('SA1',"A1_NOME"),    TamSX3("A1_NOME")[1],    /*lPixel*/, {|| cNome      })
    TRCell():new(oSection1, "cFilOri",     "QRY", RetTitle("CT2_FILORI"), PesqPict('CT2',"CT2_FILORI"), TamSX3("CT2_FILORI")[1], /*lPixel*/, {|| cFilOri    })
    TRCell():new(oSection1, "cLP",         "QRY", RetTitle("CTL_LP"),     PesqPict('CTL',"CTL_LP"),     TamSX3("CTL_LP")[1],     /*lPixel*/, {|| cLP        })
    TRCell():new(oSection1, "dData",       "QRY", RetTitle("CT2_DATA"),   PesqPict('CT2',"CT2_DATA"),   TamSX3("CT2_DATA")[1]+2, /*lPixel*/, {|| dData      })
    TRCell():new(oSection1, "cHistorico",  "QRY", RetTitle("CT2_HIST"),   PesqPict('CT2',"CT2_HIST"),   TamSX3("CT2_HIST")[1],   /*lPixel*/, {|| cHistorico })
    TRCell():new(oSection1, "cDC",         "QRY", RetTitle("CT2_DC"),     PesqPict('CT2',"CT2_DC"),     TamSX3("CT2_DC")[1],     /*lPixel*/, {|| cDC        })
    TRCell():new(oSection1, "cDebito",     "QRY", RetTitle("CT2_DEBITO"), PesqPict('CT2',"CT2_DEBITO"), TamSX3("CT2_DEBITO")[1], /*lPixel*/, {|| cDebito    })
    TRCell():new(oSection1, "cCredito",    "QRY", RetTitle("CT2_CREDIT"), PesqPict('CT2',"CT2_CREDIT"), TamSX3("CT2_CREDIT")[1], /*lPixel*/, {|| cCredito   })
    TRCell():new(oSection1, "nValDebito",  "QRY", "Valor Débito",         PesqPict('CT2',"CT2_VALOR"),  TamSX3("CT2_VALOR")[1],  /*lPixel*/, {|| nValDebito })
    TRCell():new(oSection1, "nValCredito", "QRY", "Valor Crédito",        PesqPict('CT2',"CT2_VALOR"),  TamSX3("CT2_VALOR")[1],  /*lPixel*/, {|| nValCredito})
    TRCell():new(oSection1, "nSaldo",      "QRY", "Saldo",                PesqPict('CT2',"CT2_VALOR"),  TamSX3("CT2_VALOR")[1],  /*lPixel*/, {|| nSaldo     })
 
    oBreak := TRBreak():New(oSection1,{ || QRY->ALIAS + QRY->COD + QRY->LOJA },{|| "Total"},.F.)
 
    TRFunction():New(oSection1:Cell("nValDebito"),"TOT_DEBITO","SUM",oBreak,,PesqPict('CT2',"CT2_VALOR"),,.F.,.F.)
    TRFunction():New(oSection1:Cell("nValCredito"),"TOT_CREDITO","SUM",oBreak,,PesqPict('CT2',"CT2_VALOR"),,.F.,.F.)
  
return oReport
 
static function PrintReport(oReport)
local oSection1 := oReport:Section(1)
local cSql := ""
local lContinua := .t.

if Empty(mv_par01) .or. Empty(mv_par03) .or. (mv_par04 == 2 .and. Empty(mv_par06))
    ShowHelpDlg("Parâmetros Inválidos", {"Os parâmetros selecionados produzem um erro na seleção."}, 1, {"Por favor verifique os parâmetros."}, 1)
else
    Processa({|| fs_LoadData(oReport)}, "Aguarde!", "Carregando dados...")

    if lContinua 
        cSql := "select ALIAS, COD, LOJA, NOME, FILIAL_ORIGEM, LP, DATA, HISTORICO, TIPO_LP, DEBITO, CREDITO, VAL_DEBITO, VAL_CREDITO, VAL_SALDO, INDICE" +;
                 " from " + cAliasSql + " QRY" +;
             " order by ALIAS, COD, LOJA, FILIAL_ORIGEM, LP, INDICE" 
    
        oSection1:Init()
        oSection1:SetHeaderSection(.t.)
     
        DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(cSql)), 'QRY', .f., .t.)
    
        oReport:SetMeter(QRY->(RecCount()))
    
        while QRY->(!Eof())
    
            if oReport:Cancel()
                Exit
            endif
     
            oReport:IncMeter()
    
            oSection1:SetTotalText("Total " + QRY->ALIAS + ": "+ QRY->COD + '-' + QRY->LOJA)
    
            oSection1:Cell("cTipo"      ):SetValue(Iif(QRY->ALIAS == 'SA1', "Cliente", "Fornecedor"))
            oSection1:Cell("cCodigo"    ):SetValue(QRY->COD)
            oSection1:Cell("cLoja"      ):SetValue(QRY->LOJA)
            oSection1:Cell("cNome"      ):SetValue(QRY->NOME)
            oSection1:Cell("cFilOri"    ):SetValue(QRY->FILIAL_ORIGEM)
            oSection1:Cell("cLP"        ):SetValue(QRY->LP)
            oSection1:Cell("dData"      ):SetValue(SToD(QRY->DATA))
            oSection1:Cell("dData"      ):SetAlign("CENTER")
            oSection1:Cell("cHistorico" ):SetValue(QRY->HISTORICO)
            oSection1:Cell("cDC"        ):SetValue(QRY->TIPO_LP)
            oSection1:Cell("cDebito"    ):SetValue(QRY->DEBITO)
            oSection1:Cell("cCredito"   ):SetValue(QRY->CREDITO)
            oSection1:Cell("nValDebito" ):SetValue(QRY->VAL_DEBITO)
            oSection1:Cell("nValCredito"):SetValue(QRY->VAL_CREDITO)
            oSection1:Cell("nSaldo"     ):SetValue(QRY->VAL_SALDO)
    
            oSection1:PrintLine()
     
            QRY->(dbSkip())
        end
        
        oSection1:Finish()
        QRY->(DbCloseArea())
        fs_EraseData()
    endif
endif    
return nil

static function fs_GeraX1(cPerg)
    cPerg := PADR(cPerg,Len(SX1->X1_GRUPO))
//  PutSX1( cGrupo, cOrdem, cPergunt,                        cPerSpa, cPerEng, cVar,     cTipo, nTam,                    nDec,                    nPresel, cGSC, cValid, cF3,   cGrpSxg, cPyme, cVar01,     cDef01, cDefSpa1, cDefEng1, cCnt01, cDef02, cDefSpa2, cDefEng2, cDef03,  cDefSpa3, cDefEng3, cDef04, cDefSpa4, cDefEng4, cDef05, cDefSpa5, cDefEng5, aHelpPor,                                                                                                                                 aHelpEng, aHelpSpa, cHelp )
//                           123456789012345678901234567890                                                                                                                                                                                                                                                                                                        123456789012345678901234567890    123456789012345678901234567890    123456789012345678901234567890    123456789012345678901234567890    123456789012345678901234567890  
    PutSX1( cPerg,  "01",   "Conta contábil?",               "",      "",      "mv_ch1", "C",   TamSX3("CT2_DEBITO")[1], TamSX3("CT2_DEBITO")[2], 00,      "G",  "",     "CT1", "",      "S",   "mv_par01", "",     "",       "",       "",     "",     "",       "",       "",      "",       "",       "",     "",       "",       "",     "",       "",       {"Informe a conta contabil que  ", "será avaliada.                ", "<F3 Disponível>               ", "                              ", "                              "}, {""},     {""},     "" )
    PutSX1( cPerg,  "02",   "Data de?",                      "",      "",      "mv_ch2", "D",   08,                      00,                      00,      "G",  "",     "",    "",      "S",   "mv_par02", "",     "",       "",       "",     "",     "",       "",       "",      "",       "",       "",     "",       "",       "",     "",       "",       {"Informe o início do período a ", "ser considerado no relatório. ", "                              ", "                              ", "                              "}, {""},     {""},     "" )
    PutSX1( cPerg,  "03",   "Data até?",                     "",      "",      "mv_ch3", "D",   08,                      00,                      00,      "G",  "",     "",    "",      "S",   "mv_par03", "",     "",       "",       "",     "",     "",       "",       "",      "",       "",       "",     "",       "",       "",     "",       "",       {"Informe o final do período a  ", "ser considerado no relatório. ", "                              ", "                              ", "                              "}, {""},     {""},     "" )
    PutSX1( cPerg,  "04",   "Seleciona Filiais?",            "",      "",      "mv_ch4", "N",   01,                      00,                      02,      "C",  "",     "",    "",      "S",   "mv_par04", "Sim",  "Sim",    "Sim",    "",     "Não",  "Não",    "Não",    "",      "",       "",       "",     "",       "",       "",     "",       "",       {"Informe se deseja selecionar  ", "as filiais. Caso essa opcao se", "ja selecionada os parâmetros  ", "[Filial de?] e [Filial até?]  ", "serão ignorados.              "}, {""},     {""},     "" )
    PutSX1( cPerg,  "05",   "Filial de?",                    "",      "",      "mv_ch5", "C",   TamSX3("B1_FILIAL")[1],  TamSX3("B1_FILIAL")[2],  00,      "G",  "",     "SM0", "",      "S",   "mv_par05", "",     "",       "",       "",     "",     "",       "",       "",      "",       "",       "",     "",       "",       "",     "",       "",       {"Filial inicial a ser usada no ", "filtro.                       ", "<F3 Disponível>               ", "                              ", "                              "}, {""},     {""},     "" )
    PutSX1( cPerg,  "06",   "Filial até?",                   "",      "",      "mv_ch6", "C",   TamSX3("B1_FILIAL")[1],  TamSX3("B1_FILIAL")[2],  00,      "G",  "",     "SM0", "",      "S",   "mv_par06", "",     "",       "",       "",     "",     "",       "",       "",      "",       "",       "",     "",       "",       "",     "",       "",       {"Filial final a ser usada no   ", "filtro.                       ", "<F3 Disponível>               ", "                              ", "                              "}, {""},     {""},     "" )
return nil

static function fs_LoadData(oReport)
local cFilInSql := ""
local cFilterQry := ""
local aAreaSM0 := {}

local cCpoCliFor := ""
local cCpoLoja := ""
local nLenIndice := TamSX3("A1_FILIAL")[1]+TamSX3("CT2_DATA")[1]+TamSX3("CT2_LOTE")[1]+TamSX3("CT2_SBLOTE")[1]+TamSX3("CT2_DOC")[1]+TamSX3("CT2_LINHA")[1]
local nSaldo := 0
local cChave := ""

local lContinua := .t.
local nCnt := 0

ProcRegua(0)

cAliasSQL := GetNextAlias()

DbSelectArea("SX3")
DbSetOrder(3) // X3_GRPSXG+X3_ARQUIVO+X3_ORDEM

if lContinua .and. mv_par04 == 1
    while Empty(aFilial := u_GetCode("SM0", "SM0", 1, {"M0_CODFIL", "M0_FILIAL"}, "M0_CODFIL"))
        nCnt++
        if nCnt == 3
            nCnt := 0
            lContinua := MsgYesNo("Não foi selecionada nenhuma filial. Para prosseguir é nessessário que pelo menos uma filial seja Selecionada. Para continuar pressione Sim e selecione pelo menos uma filial, para finalizar pressione Não. Deseja continuar?")
        endif
    end
endif

if lContinua 
    aAreaSM0 := SM0->(GetArea())
    SM0->(DbGoTop())
    while !SM0->(Eof())
        if mv_par04 == 1 
            if aScan(aFilial, { |aMat| AllTrim(aMat) == AllTrim(SM0->M0_CODFIL) } ) > 0
                cFilInSql += (Iif(Empty(cFilInSql), "", ",")) + "'" + AllTrim(SM0->M0_CODFIL) + "'"
            endif
        else
            if AllTrim(SM0->M0_CODFIL) >= mv_par05 .and. AllTrim(SM0->M0_CODFIL) <= mv_par06
                cFilInSql += (Iif(Empty(cFilInSql), "", ",")) + "'" + AllTrim(SM0->M0_CODFIL) + "'"
            endif
        endif
        SM0->(DbSkip())
        IncProc()
    end
    SM0->(RestArea(aAreaSM0))
    
    while TCCanOpen(cAliasSQL)
        cAliasSQL := GetNextAlias()
    end
    
    cSql := " create table " + cAliasSQL + " ( " +; 
                         " ALIAS         varchar(" + StrZero(TamSX3("CTL_ALIAS")[1], 3) + ") not null constraint " + cAliasSQL + "_ALIAS default('" + Space(TamSX3("CTL_ALIAS")[1])  + "')"+;
                        ", COD           varchar(" + StrZero(TamSX3("A1_COD")[1], 3) + ") not null constraint " + cAliasSQL + "_COD default('" + Space(TamSX3("A1_COD")[1])  + "')"+; 
                        ", LOJA          varchar(" + StrZero(TamSX3("A1_LOJA")[1], 3) + ") not null constraint " + cAliasSQL + "_LOJA default('" + Space(TamSX3("A1_LOJA")[1])  + "')"+;
                        ", NOME          varchar(" + StrZero(TamSX3("A1_NOME")[1], 3) + ") not null constraint " + cAliasSQL + "_NOME default('" + Space(TamSX3("A1_NOME")[1])  + "')"+; 
                        ", FILIAL_ORIGEM varchar(" + StrZero(TamSX3("CT2_FILORI")[1], 3) + ") not null constraint " + cAliasSQL + "_FILIAL_ORIGEM default('" + Space(TamSX3("CT2_FILORI")[1])  + "')" +; 
                        ", LP            varchar(" + StrZero(TamSX3("CTL_LP")[1], 3) + ") not null constraint " + cAliasSQL + "_LP default('" + Space(TamSX3("CTL_LP")[1])  + "')"+;
                        ", DATA          varchar(" + StrZero(TamSX3("CT2_DATA")[1], 3) + ") not null constraint " + cAliasSQL + "_DATA default('" + Space(TamSX3("CT2_DATA")[1])  + "')"+;
                        ", HISTORICO     varchar(" + StrZero(TamSX3("CT2_HIST")[1], 3) + ") not null constraint " + cAliasSQL + "_HISTORICO default('" + Space(TamSX3("CT2_HIST")[1])  + "')"+; 
                        ", TIPO_LP       varchar(" + StrZero(TamSX3("CT2_DC")[1], 3) + ") not null constraint " + cAliasSQL + "_TIPO_LP default('" + Space(TamSX3("CT2_DC")[1])  + "')"+;
                        ", DEBITO        varchar(" + StrZero(TamSX3("CT2_DEBITO")[1], 3) + ") not null constraint " + cAliasSQL + "_DEBITO default('" + Space(TamSX3("CT2_DEBITO")[1])  + "')"+;
                        ", CREDITO       varchar(" + StrZero(TamSX3("CT2_CREDIT")[1], 3) + ") not null constraint " + cAliasSQL + "_CREDITO default('" + Space(TamSX3("CT2_CREDIT")[1])  + "')"+;
                        ", VAL_DEBITO    float not null constraint " + cAliasSQL + "_VAL_DEBITO default 0.0" +;
                        ", VAL_CREDITO   float not null constraint " + cAliasSQL + "_VAL_CREDITO default 0.0" +;
                        ", VAL_SALDO     float not null constraint " + cAliasSQL + "_VAL_SALDO default 0.0" +;
                        ", INDICE        varchar(" + StrZero(nLenIndice, 3) + ") not null constraint " + cAliasSQL + "_INDICE default('" + Space(nLenIndice)  + "')" +;
                        ", CONSTRAINT    " + cAliasSQL + "_PK PRIMARY KEY CLUSTERED ( ALIAS, COD, LOJA, FILIAL_ORIGEM, LP, INDICE ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY] " +;
            " ) ON [PRIMARY] " 
    
    if TCSqlExec(cSql) < 0
        UserException(TCSQLError())
    endif
    
    cSql := " select CT2.*, CTL.* " +;
              " from " + RetSqlName("CT2") + " CT2" +;
              " join " + RetSqlName("CTL") + " CTL" +;
                " on CTL.CTL_FILIAL = '" + xFilial("CTL") + "'" +;
               " and CTL.CTL_LP     = CT2.CT2_LP" +;
               " and CTL.CTL_XPERFI not in (' ', '0')" +;
               " and CTL.D_E_L_E_T_ = ' '" +;
             " where CT2.CT2_FILIAL in (" + cFilInSql + ")"  +;
               " and (CT2.CT2_DEBITO = '" + mv_par01 + "'" +;
                 " or CT2.CT2_CREDIT = '" + mv_par01 + "')" +;
               " and CT2.CT2_DATA between '" + DToS(mv_par02) + "'and '" + DToS(mv_par03) + "'" +;
               " and CT2.CT2_MOEDLC = '01' " +;// Considera somente os lançamento na moeda 01
               " and CT2.D_E_L_E_T_ = ' '" +;
          " order by CT2_FILORI, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA "
    
    DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(cSql)), "TMPCTL", .f., .t.)
    
    while !TMPCTL->(Eof())
        
        DbSelectArea(TMPCTL->(CTL_ALIAS))
        DbSetOrder(Val(TMPCTL->(CTL_ORDER)))
        
        cAlias := Space(TamSX3("CTL_ALIAS")[1])
        cCod   := Space(TamSX3("A1_COD")[1])
        cLoja  := Space(TamSX3("A1_LOJA")[1])
        cNome  := Space(TamSX3("A1_NOME")[1])
    
        if DbSeek(TMPCTL->(CT2_KEY))
            if TMPCTL->CTL_XPERFI == '1' .or. TMPCTL->CTL_XPERFI == '2'
                cAlias := Iif(TMPCTL->CTL_XPERFI=='1', 'SA1', 'SA2')
                if SX3->(DbSeek('001' + TMPCTL->(CTL_ALIAS)))
                    cCod := &(SX3->X3_CAMPO)
                endif
                if SX3->(DbSeek('002' + TMPCTL->(CTL_ALIAS)))
                    cLoja := &(SX3->X3_CAMPO)
                endif
                cNome := Posicione(cAlias, 1, xFilial(cAlias) + cCod + cLoja, Iif(cAlias=='SA1', 'A1_NOME', 'A2_NOME'))
            elseif TMPCTL->CTL_XPERFI == '3'
                if TMPCTL->CTL_LP == '594'
                    cAlias := Iif(SE5->E5_RECPAG == 'R', 'SA1', 'SA2')
                    cCod := SE5->E5_CLIFOR
                    cLoja := SE5->E5_LOJA
                    cNome := Posicione(cAlias, 1, xFilial(cAlias) + cCod + cLoja, Iif(cAlias=='SA1', 'A1_NOME', 'A2_NOME'))
                endif
            endif
        endif
    
        cSql := " insert into " + cAliasSQL + "(ALIAS, COD, LOJA, NOME, FILIAL_ORIGEM, LP, DATA, HISTORICO, TIPO_LP, DEBITO, CREDITO, VAL_DEBITO, VAL_CREDITO, VAL_SALDO, INDICE) " +;
                " values (" +;         
                      " '" + cAlias + "'" +; // "ALIAS"
                     ", '" + cCod + "'" +; // "COD"
                     ", '" + cLoja + "'" +; // "LOJA"
                     ", '" + cNome + "'" +; // "NOME"
                     ", '" + TMPCTL->CT2_FILORI + "'" +; // FILIAL_ORIGEM
                     ", '" + TMPCTL->CTL_LP + "'" +; // LP
                     ", '" + TMPCTL->CT2_DATA + "'" +; // DATA
                     ", '" + TMPCTL->CT2_HIST + "'" +; // HISTORICO
                     ", '" + TMPCTL->CT2_DC + "'" +; // TIPO_LP
                     ", '" + TMPCTL->CT2_DEBITO + "'" +; // DEBITO
                     ", '" + TMPCTL->CT2_CREDIT  + "'" +; // CREDITO
                     ", " + AllTrim(Str(Iif(TMPCTL->CT2_DEBITO == mv_par01, TMPCTL->CT2_VALOR, 0))) + "" +; // VAL_DEBITO
                     ", " + AllTrim(Str(Iif(TMPCTL->CT2_CREDIT == mv_par01, TMPCTL->CT2_VALOR, 0))) + "" +; // VAL_CREDITO
                     ", 0" +; // VAL_SALDO     
                     ", '" + TMPCTL->(CT2_FILORI+CT2_DATA+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA) + "'" +; // "INDICE"
                ")"
    
        if TCSqlExec(cSql) < 0
            UserException(TCSQLError())
        endif
        
        DbCloseArea()
        
        IncProc()
        TMPCTL->(DbSkip())
    end
    
    TMPCTL->(DbCloseArea())
    
    cSql := " select * " +;
              " from " + cAliasSQL + "" +;
          " order by ALIAS, COD, LOJA, NOME, FILIAL_ORIGEM, LP, INDICE"
    
    DbUseArea(.t., "TOPCONN", TCGenQry(,,ChangeQuery(cSql)), "TMPSQL", .f., .t.)
    
    nSaldo := 0
    
    while !TMPSQL->(Eof())
    
        if TMPSQL->ALIAS + TMPSQL->COD + TMPSQL->LOJA == cChave 
            nSaldo := nSaldo + TMPSQL->VAL_DEBITO - TMPSQL->VAL_CREDITO
        else
            cChave := TMPSQL->ALIAS + TMPSQL->COD + TMPSQL->LOJA
            nSaldo := TMPSQL->VAL_DEBITO - TMPSQL->VAL_CREDITO
        endif
        
        cSql := " update " + cAliasSQL +;
                   " set VAL_SALDO = " + AllTrim(Str(nSaldo)) +;
                 " where ALIAS = '" + TMPSQL->ALIAS + "'" +;
                   " and COD = '" + TMPSQL->COD + "'" +;
                   " and LOJA = '" + TMPSQL->LOJA + "'" +;
                   " and NOME = '" + TMPSQL->NOME + "'" +;
                   " and FILIAL_ORIGEM = '" + TMPSQL->FILIAL_ORIGEM + "'" +;
                   " and LP = '" + TMPSQL->LP + "'" +;
                   " and INDICE = '" + TMPSQL->INDICE + "'"  
        
        if TCSqlExec(cSql) < 0
            UserException(TCSQLError())
        endif
        
        TMPSQL->(DbSkip())
    end
    TMPSQL->(DbCloseArea())
endif
return lContinua

static function fs_EraseData()
    
    if TCCanOpen(cAliasSql)
        TCDelFile(cAliasSql)
    endif
    
return nil
