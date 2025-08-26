#INCLUDE "Totvs.CH"
#Include "TopConn.ch"

/*/{Protheus.doc} vaacdv03
    Transferencia de Localização
    @type Function
    @author nathan.quirino@jrscatolon.com.br
    @since 17/07/2025
    @version 1.0.1
/*/

static __Debug := getMV("JR_DEBUG",,.F.)

//Etiqueta de Entrada 
/*   ___________________________________________
--  |    Produto: B1_DESC                       |
--  |    Cod.: B1_COD   Entr F1_DTDIGIT         |  
--  |    Qtde: ZA0_QTDPET UM Localiz.:B1_LOCALI |  
--  |    Nf.: ZA0_DOC/ZA0_SERIE                 |
--  |    |CODEBAR|CODEBARCODEBAR|CODEBAR|       |
--  |___________________________________________|
*/

User Function ImpEtqACD(cNome, cCod, cFornec, cLoja, cEntr, nQtde, nUm, cUMed, cLocal, cDoc, cSerie, cCodBar, cPorta)

    
    SB5->(DbSetOrder(1)) // B5_FILIAL+B5_COD
    if !SB5->(DbSeek(FWxFilial("SB5")+cCod)) .or. SB5->B5_IMPETI != 'N'

        
        PZebra(.T.,cPorta)
    
        //MSCBSAY(nXmm, nYmm, cTexto, cRotação, cFonte, cTam, *lReverso, lSerial, cIncr, *lZerosL, lNoAlltrim)
    
        MSCBBEGIN(1,4,100)
        //MSCBBOX(X1,Y1,X2,Y2)
    
        //MSCBSAY(005, 003, 'Produto: ' + AllTrim(cNome),, "0", "35,25") 
        MSCBSAY(010, 003, AllTrim(Substr(cNome,1,51)),, "0", "32,22") 
        MSCBSAY(010, 008, AllTrim(Substr(cNome,52,51)),, "0", "32,22")
        //MSCBSAY(005, 008, 'Cod.: ' + cCod + '  Entr.: ' + cEntr,, "0", "35,25") 
        MSCBSAY(010, 013, 'Fornec.: ' + cFornec + '/' + cLoja + '         Entr.: ' + cEntr,, "0", "35,25") 
        //MSCBSAY(005, 013, 'Qtd.: ' + AllTrim(Transform(nQtde, "@E 9999")) + '  ' + cUMed + '  Loc.: ' + cLocal,, "0", "35,25") 
        MSCBSAY(010, 018, 'NF.: ' + cDoc + '/' + cSerie+  '  ' +'Qtd.: ' + AllTrim(Transform(nQtde, "@E 99999.9999"))+' '+ cUMed + '  Loc.: ' + cLocal,, "0", "35,25") 

        MSCBSAYBAR(010,023, AllTrim(cCodBar),, "MB07", 10, .F.,.T.,.F.,,3,1)

        MSCBSAYBAR(080,002,  AllTrim(Transform(nQtde, "@E 99999")),"B", "MB07", 10, .F.,.T.,.F.,,3,1)
        
        MSCBEND()

        PZebra(.f.,cPorta)
    endif

Return Nil

//Etiqueta de Produtos e transferência VAREST01
/*   _________________________________________
--  |    DESCRICAO DO PRODUTO                 |
--  |    CONT. DA DESCRICAO                   |  
--  |    LOCALIZ: B1_LOCALI                   |  
--  |    |CODEBAR|CODEBARCODEBAR|CODEBAR|     |
--  |_________________________________________|
*/
User Function ImpEtqPdt(aCntImp, cPorta, cLocaliz)

    PZebra(.T.,cPorta)

    //MSCBSAY(nXmm, nYmm, cTexto, cRotação, cFonte, cTam, *lReverso, lSerial, cIncr, *lZerosL, lNoAlltrim)

    MSCBBEGIN(1,4)
    //MSCBBOX(X1,Y1,X2,Y2)

    If Len(AllTrim(aCntImp[1])) > 30
        MSCBSAY(005, 005, 'Descricao:'+ SubStr(aCntImp[1], 1, 24),, "0", "40,30") //Descrição do produto
        MSCBSAY(005, 011, SubStr(aCntImp[1], 25),, "0", "40,30") //Codigo do produto
    else
        MSCBSAY(005, 005, 'Descricao:',, "0", "40,30") //Descrição do produto
        MSCBSAY(005, 011, aCntImp[1],, "0", "40,30") //Codigo do produto
    endif

    if(cLocaliz = 2)
        MSCBSAY(005, 017, 'Localiz.: ' + aCntImp[3],, "0", "40,30") //Localização do produto
    endif
 
    //MSCBSAYBAR(019,023,ALLTRIM(aCntImp[2]),,"MB07",11,,.T.,,,3,,.T.,,,.F.,)
    //MSCBSAYBAR(019, 023, AllTrim(aCntImp[2]),"N", "MB07", 11, .T., .T., .F., 'C', 3, 2,,,.F.,)
    MSCBSAYBAR(015,023, AllTrim(aCntImp[2]),, "MB07", 10, .F.,.T.,.F.,,3,1)
    //                                               tam ,Dig. verif.

    if __Debug
        if !existdir("C:\temp")
            makedir("C:\temp")
        endif    
        MemoWrite( "C:\temp\zebra.txt", MSCBEND() )
    else
        MSCBEND()
    Endif

    PZebra(.f.,cPorta)

Return Nil

//Etiqueta de Prodtuto Para Caixinha MOREST03 ImpEtPdtc
//este layout é uma réplica do VAREST01 para se ajustar ao tamanho de algumas caixinhas armazenadoras
/*   _________________________________________
--  |    CODEBAR|CODEBAR|CODEBAR|CODEBAR|     |
--  |    DESCRICAO DO PRODUTO                 |  
--  |    CONT. DA DESCRICAO                   |
--  |                                         |  
--  |_________________________________________|
*/
User Function ImpEtPdtc(aCntImp, cPorta)

    PZebra(.T.,cPorta)

    //MSCBSAY(nXmm, nYmm, cTexto, cRotação, cFonte, cTam, *lReverso, lSerial, cIncr, *lZerosL, lNoAlltrim)

    MSCBBEGIN(1,4)

    MSCBSAYBAR(015,003, AllTrim(aCntImp[2]),, "MB07", 10, .F.,.T.,.F.,,3,1)
    
    //31
    MSCBSAY(005, 018, ''+ SubStr(aCntImp[1], 1, 35),, "0", "40,30") //Descrição do produto
    MSCBSAY(005, 024, SubStr(aCntImp[1], 36),, "0", "40,30") //Codigo do produto

    if __Debug
        if !existdir("C:\temp")
            makedir("C:\temp")
        endif    
        MemoWrite( "C:\temp\zebra.txt", MSCBEND() )
    else
        MSCBEND()
    endif

    PZebra(.f.,cPorta)

Return Nil



//Etiqueta de Produto Avulso Com Quantidade MOREST07
/*   _________________________________________
--  |    DESCRICAO DO PRODUTO                 |
--  |    CONT. DA DESCRICAO                   |  
--  |    LOCALIZ: B10101 QTD.:XXXXXX UM       |  
--  |    |CODEBAR|CODEBARCODEBAR|CODEBAR|     |
--  |_________________________________________|
*/

User Function ImpEtPdAv(aCntImp, cQtd, cPorta)

    PZebra(.T.,cPorta)
    //MSCBSAY(nXmm, nYmm, cTexto, cRotação, cFonte, cTam, *lReverso, lSerial, cIncr, *lZerosL, lNoAlltrim)

    MSCBBEGIN(1,4)
    //MSCBBOX(X1,Y1,X2,Y2)

        MSCBSAY(005, 005, SubStr(aCntImp[1], 1, 34),, "0", "40,30") //Descrição do produto
        MSCBSAY(005, 011, SubStr(aCntImp[1], 35),, "0", "40,30") //Codigo do produto

        MSCBSAY(005, 017, 'Localiz.: ' + aCntImp[3] + " Qtd.: " + AllTrim(cQtd) + " " + aCntImp[4],, "0", "40,30") //Localização do produto + Un. Medida
        MSCBSAYBAR(015,023, AllTrim(aCntImp[2]),, "MB07", 10, .F.,.T.,.F.,,3,1)//CODBAR

    if __Debug
        if !existdir("C:\temp")
            makedir("C:\temp")
        endif    
        MemoWrite( "C:\temp\zebra.txt", MSCBEND() )
    else
        MSCBEND()
    endif

    PZebra(.f.,cPorta)

Return Nil




//Etiqueta de Endereço MOREST02 (LAYOUT ADAPTADO PARA ETIQUETA 5X3cm)
/*   _________________________________________
--  | |CODEBAR|CODE ARMAZEM|                  |
--  |                                         |  
--  | |CODEBAR|CODEBAR|CODE ENDERECO|         |  
--  |                                         |
--  |_________________________________________|
*/
User Function ImpEtqEnd(aCntImp, cPorta)

    PZebra(.T.,cPorta)

    //MSCBSAY(nXmm, nYmm, cTexto, cRotação, cFonte, cTam, *lReverso, lSerial, cIncr, *lZerosL, lNoAlltrim)

    MSCBBEGIN(1,4)
    //MSCBBOX(X1,Y1,X2,Y2)

    //Etuqueta de 4x8
    //MSCBSAY(005, 005, 'Armazem: ' + aCntImp[1],, "0", "40,30") //Descrição do Armazém
    //MSCBSAYBAR(019,014, AllTrim(aCntImp[2]),, "MB07", 15, .F.,.T.,.F.,,3,1)

    //Etiqueta de 3x5
    MSCBSAYBAR(070,010, AllTrim(aCntImp[1]),"B", "MB07", 15, .F.,.T.,.F.,,3,1) //codbar armazem
    MSCBSAYBAR(005,012, AllTrim(aCntImp[2]),, "MB07", 20, .F.,.T.,.F.,,3,1) //codbar endereco

    MSCBEND()

    PZebra(.f.,cPorta)

Return Nil


//Etiqueta de caixa (não usada)
User Function ImpEtqCx(cTipo, cCodigo, cSeq, cEndereco, cPorta)
    //local cPorta  := "LPT1"
    local cOpera := ""
    local cCodBar := ""
    local nOpera := 0

    //cEndereco só será passado quando a operação for OP
    default cEndereco := " "

    //Operação 1: PV
    If cTipo == "PV"
        cOpera := "Pedido de Venda"
        nOpera := '1'

    //Operação 2: OP
    ElseIf cTipo == "OP"
        cOpera := "Ordem de Producao"
        nOpera := '2'

    //Operação 3: SA
    ElseIf cTipo == "SA"
        cOpera := "Solicitacao de armazem"
        nOpera := '3'
    Endif

    cCodBar := nOpera + AllTrim(aCntImp[2]) + AllTrim(aCntImp[3])

    PZebra(.T.,cPorta)

    //MSCBSAY(nXmm, nYmm, cTexto, cRotação, cFonte, cTam, *lReverso, lSerial, cIncr, *lZerosL, lNoAlltrim)

    MSCBBEGIN(1,4)
    //MSCBBOX(X1,Y1,X2,Y2)

    MSCBSAY(005, 005,  cOpera + " " + AllTrim(cCodigo),, "0", "40,30") // OPERAÇÃO + codigo
    If aCntImp[1] == "OP"
        MSCBSAY(005, 011, 'Endereço: ' + AllTrim(cEndereco),, "0", "40,30") // ENDEREÇO DE DESTINO 
    Endif
    //MSCBSayBar( /*nXmm*/, /*nYmm*/, /*cConteudo*/, /*cRotação*/, /*cTypePrt*/,  [ nAltura*/, /**lDigver*/, /*lLinha*/, /**lLinBaixo*/, /*cSubSetIni*/, /*nLargura*/, /*nRelacao*/, /*lCompacta*/, /*lSerial*/, /*cIncr*/, /*lZerosL ] 
    MSCBSAYBAR(015,023, AllTrim(cCodBar),, "MB07", 10, .F.,.T.,.F.,,3,1)


    MSCBEND()

    PZebra(.f.,cPorta)

Return Nil


//Etiqueta de Terceiros 
/*   ___________________________________________
--  |    Produto: B1_DESC                       |
--  |    Cod.: B1_COD   Entr F1_DTDIGIT         |  
--  |    Qtde: ZA0_QTDPET UM Localiz.:B1_LOCALI |  
--  |    Nf.: ZA0_DOC/ZA0_SERIE                 |
--  |    |CODEBAR|CODEBARCODEBAR|CODEBAR|       |
--  |___________________________________________|
*/
//cNomeCli -> A2_NREDUZ
User Function ImpEtqTER(cTipo, cNomeCli, cCodCli, cCodLoja, cNomeProd, cCodProd, cEntr, nQtde, cUMed, cDoc, cSerie, cCodBar, cPorta)   
    //Local cPorta  := "LPT2"
    
    SB5->(DbSetOrder(1)) // B5_FILIAL+B5_COD
    if !SB5->(DbSeek(FWxFilial("SB5")+cCodProd)) .or. SB5->B5_IMPETI != 'N'
    
        PZebra(.T.,cPorta)
    
        //MSCBSAY(nXmm, nYmm, cTexto, cRotação, cFonte, cTam, *lReverso, lSerial, cIncr, *lZerosL, lNoAlltrim)
    
        MSCBBEGIN(1,4)

        
        //MSCBBOX(X1,Y1,X2,Y2)
        MSCBSAY(005, 003, IIF(cTipo == "B", "Cliente: ", "Fornec.: ") + padr(substring(cNomeCli,1,20),20) + '-' + cCodCli + '-'+ cCodLoja ,, "0", "35,25") 
        MSCBSAY(005, 008, cNomeProd,, "0", "35,25") 
        MSCBSAY(005, 013, cCodProd + '  Entr.: ' + cEntr,, "0", "35,25") 
        MSCBSAY(005, 018, 'Qtde.: ' + AllTrim(Transform(nQtde, "@E 9999")) + '  UM: ' + cUMed + '    NF.: ' + cDoc + '/' + cSerie,, "0", "35,25") 
        MSCBSAYBAR(015,023, AllTrim(cCodBar),, "MB07", 10, .F.,.T.,.F.,,3,1)

        

        MSCBEND()
    
        PZebra(.f.,cPorta)
    endif

Return Nil

static function PZebra(lAcao, cPorta)
    local cIMp  := "S600"
    local cFila  := GetMV("TO_IMPTER",,"ZD230")
    local lSrv   := .F.

    Default cPorta := "LPT1"
    Default lAcao := .T.

    IF cPorta == "LPT1"
        cFila := "ZD230"
    else
        cFila := "ZD230-A"
    endif

    if (lAcao)
        MSCBPRINTER(cIMp,cPorta,,,lSrv,,,,,cFila,)
        MSCBCHKStatus(.F.)
    else
        MSCBCLOSEPRINTER()
    endif

    if __Debug
        if !existdir("C:\temp")
            makedir("C:\temp")
        endif
        MemoWrite( "C:\temp\zebra.txt", MSCBEND() )
    endif

    //MSGINFO("Etiqueta Impressa.")

return Nil


//função de teste de layout das etiquetas
User Function TstEtqEn()

//Local aTst := {"A1", "1234567890"}
//Local aTst := {"NOME DO PRODUTO", "1234567890"}
//Local aTst := "SEED MIX VHS 10T AUTOM.2D150L ", "1.0100.006.1", "29/06/2020", '10', 1, 'PC', '01', "101000061", "LPT2"
//Local aTst := {"PV", "01234567891", "01", "B10101"}

//U_ImpEtqEnd(aTst)
//U_ImpEtqPdt(aTst)
U_ImpEtqACD("SEED MIX VHS 10T AUTOM.2D150L ", "1.0100.006.1", "29/06/2020", '10', 1, 'PC', '01', "101000061", "LPT2")
//U_ImpEtqCx(aTst)
//U_ImpEtqTER("TRANSPORTES PRASNISK","000063","SEED MIX VHS 10T AUTOM.2D150L ", "1.0100.006.1", "29/06/2020", '10', 'PC', "0000000001", "001", "101000061", "LPT2")


//MSGINFO("Etiqueta Impressa.")

Return Nil
