#INCLUDE "PROTHEUS.CH"


/* 
    MB : 12/05/2022
        CNAB DayCoval de Recebimento
*/

/* 
	MB : 12.05.2022
		2. Nas posições 63 a 70 do detalhe deve constar o sequencial de Nosso Número:
			- Range: 84580106 a 84580110 (Para testes)
			Obs.: Range definitivo será enviado quando estiver em produção.
*/
// Private cNossoNumero := '84580105'

User Function fDayNossoNro(_nTam)
// Local cRet := PadR(Soma1( GetMV("MB_NOSSONR")), 8, ' ')
//               PutMV("MB_NOSSONR", AllTrim(cRet))
Local cRet    := ""
Default _nTam := 8

    cRet := PadL( "0", _nTam, '0' )
    DbSelectArea("SA6")
    DbSetOrder(1) // A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON
    If DbSeek( xFilial("SA6")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA )
        cRet := PadL( SA6->A6_PROXNUM, _nTam, '0' )
        RecLock( "SE1", .F. )
            SE1->E1_NUMBOL := cRet
            SE1->E1_NUMBCO := cRet
        MsUnlock()
        RecLock( "SA6", .F. )
            SA6->A6_PROXNUM	:= Soma1( cRet )
        MsUnlock()
    EndIf
Return cRet

User Function fDayInscFull()
Local cRetorno := SA1->A1_CGC   // cCodCnpj
If Len(Trim(SA1->A1_CGC)) < 14
	cRetorno := "0000" + cRetorno
EndIf
Return cRetorno

User Function fDayNFiscal()
// Local cRet := Posicione("SF2", 1, SE1->E1_FILIAL+SE1->E1_NUM+SE1->E1_SERIE+SE1->E1_CLIENTE+SE1->E1_LOJA, "F2_CHVNFE")
Local cRet := ""
DbSelectArea("SF2")
SF2->(DbSetOrder(1))
If SF2->(DbSeek( SE1->E1_FILIAL+SE1->E1_NUM+SE1->E1_SERIE+SE1->E1_CLIENTE+SE1->E1_LOJA ))
    cRet := SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE
EndIf
Return PadR(cRet, 15, " ")

User Function FI040ROT()
Local aRotina := {} // ParamIXB	

/* SetKey( VK_F10,                       {|| u_fCnabFA() } )
AAdd(aRotina, { "Imprimir Boleto (F10)", "u_fCnabFA", 0 , 4, 0, .f.}) */
SetKey( VK_F10,                       {|| u_fPrtBoleto() } )
AAdd(aRotina, { "Imprimir Boleto (F10)", "u_fPrtBoleto", 0 , 4, 0, .f.})

return aRotina

/* 
    MB : 13.05.2022
        Impressao de Boletos
            -> Impressao UNICA, selecionado o titulo;
*/
User Function fPrtBoleto()
Local aItens := {}

/* aItens := {{   "01",; // 01 // SA6->A6_FILIAL,;
                  "707"          ,; // 02 // SA6->A6_COD,;
                  "00019"        ,; // 03 // SA6->A6_AGENCIA,;
                  "733187    "   ,; // 04 // SA6->A6_NUMCON,;
                  SE1->E1_FILIAL ,; // 05
                  SE1->E1_PREFIXO,; // 06
                  SE1->E1_NUM    ,; // 07
                  SE1->E1_PARCELA,; // 08
                  SE1->E1_TIPO   ,; // 09
                  "01" ,; // 10
                  "2"            ,; // 11
                  "121"          }} // 12 */

/*  aItens := {{ xFilial("SA6"),; // 01 // SA6->A6_FILIAL,;
                  "237"          ,; // 02 // SA6->A6_COD,;
                  "3386 "        ,; // 03 // SA6->A6_AGENCIA,;
                  "521900    "   ,; // 04 // SA6->A6_NUMCON,;
                  SE1->E1_FILIAL ,; // 05
                  SE1->E1_PREFIXO,; // 06
                  SE1->E1_NUM    ,; // 07
                  SE1->E1_PARCELA,; // 08
                  SE1->E1_TIPO   ,; // 09
                  xFilial("SA1")}}// 10 */
                  //"2"            ,; // 11
                  //"121"          }} // 12



aItens := {{ xFilial("SA6"),; // 01 // SA6->A6_FILIAL,;
              SE1->E1_PORTADO,; // 02 // SA6->A6_COD,;
              SE1->E1_AGEDEP ,; // 03 // SA6->A6_AGENCIA,;
              SE1->E1_CONTA  ,; // 04 // SA6->A6_NUMCON,;
              SE1->E1_FILIAL ,; // 05
              SE1->E1_PREFIXO,; // 06
              SE1->E1_NUM    ,; // 07
              SE1->E1_PARCELA,; // 08
              SE1->E1_TIPO   ,; // 09
              xFilial("SA1") }} // 11

Begin Transaction
    U_VAFINBol(aItens, {}, 0)
End Transactions

Return nil
