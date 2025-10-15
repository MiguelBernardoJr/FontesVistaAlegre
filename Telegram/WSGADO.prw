#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"

WSRESTFUL WSGADO DESCRIPTION "Serviço de Notas de gado"
    
    WSDATA filial       AS STRING
    WSDATA numero       AS STRING
    WSDATA serie        AS STRING
    WSDATA fornecedor   AS STRING
    WSDATA loja         AS STRING
    
    // 2. CORREÇÃO: A WSSYNTAX agora define apenas o caminho base, SEM os parâmetros.
    WSMETHOD GET BuscaNota;
        DESCRIPTION "Busca dados de uma nota de gado";
        WSSYNTAX    "/wsgado/BuscaNota?{filial, numero, serie, fornecedor, loja}"
END WSRESTFUL

/*
================================================================================
| MÉTODO: BuscaNota
|-------------------------------------------------------------------------------
| IMPLEMENTAÇÃO: As variáveis são acessadas como propriedades do serviço (Self).
================================================================================
*/
// 3. CORREÇÃO: Removemos o WSRECEIVE. As variáveis WSDATA são acessadas com Self:
WSMETHOD GET BuscaNota WSRECEIVE filial, numero, serie, fornecedor, loja WSSERVICE WSGADO
   Local cQry 		:= ""
    Local cAlias 	:= GetNextAlias()
    Local jResponse := JsonObject():New()
    Local jCabecalho:= JsonObject():New()
    Local aItens 	:= {}
    Local jItem 	:= Nil
    Local lFirstRec := .T. // Flag para controlar a primeira passagem e montar o cabeçalho

    // Query para buscar os dados da nota fiscal e do contrato
    cQry := " SELECT D1_FILIAL,D1_DOC,D1_SERIE, D1_ITEM, D1_COD, B1_DESC, D1_QUANT, D1_VUNIT, D1_TOTAL, D1_PEDIDO, D1_EMISSAO, "
    cQry += " ZBC_PESREA, D1_X_PESCH, D1_X_QUECA, D1_X_KM, D1_X_QUEKG, D1_X_EMBDT, D1_X_EMBHR, D1_X_CHEDT, D1_X_CHEHR, "
    cQry += " ZBC_CODIGO, ZCC_DTCONT, ZCC_NOMFOR, ZCC_QTTTAN, ZCC_CODCOR, ZCC_NOMCOR "
    cQry += " FROM "+RetSqlName("SD1")+" SD1 "
    cQry += " LEFT JOIN "+RetSqlName("SB1")+" SB1 ON B1_COD = D1_COD AND SB1.D_E_L_E_T_ = '' "
    cQry += " LEFT JOIN "+RetSqlName("ZBC")+" ZBC ON ZBC_FILIAL = D1_FILIAL AND ZBC_PEDIDO = D1_PEDIDO AND ZBC_ITEMPC = D1_ITEMPC AND ZBC.D_E_L_E_T_ = '' "
    cQry += " LEFT JOIN "+RetSqlName("ZCC")+" ZCC ON ZCC_FILIAL = D1_FILIAL AND ZCC_CODIGO = ZBC_CODIGO AND ZCC.D_E_L_E_T_ = '' "
    cQry += " WHERE D1_FILIAL = '"+Self:filial+"' " // Usando xFilial para ser dinâmico
    cQry += " AND D1_FORNECE = '"+Self:fornecedor+"' "
    cQry += " AND D1_LOJA = '"+Self:loja+"' "
    cQry += " AND D1_DOC = '"+Self:numero+"' "
    cQry += " AND D1_SERIE = '"+Self:serie+"' "
    cQry += " AND SD1.D_E_L_E_T_ = '' "
    cQry += " ORDER BY D1_ITEM "

    cAlias := MpSysOpenQry(cQry)

    If (cAlias)->(Eof())
        Self:setStatus(500)
        jResponse['errorid']  := 'ALL003'
        jResponse['error']    := 'Registro(s) não encontrado(s)'
        jResponse['solution'] := 'A consulta de registros não retornou nenhuma informação'
    Else
        // Inicializa o array que conterá os itens da nota
        aItens := {}

        While !(cAlias)->(Eof())
            
            // Na primeira passagem, monta o objeto de cabeçalho
            If lFirstRec
                jCabecalho['filial']           := (cAlias)->D1_FILIAL
                jCabecalho['notanumero']       := AllTrim((cAlias)->D1_DOC) + '-' + AllTrim((cAlias)->D1_SERIE)
                jCabecalho['pedidocompra']     := (cAlias)->D1_PEDIDO
                jCabecalho['dataemissao']      := (cAlias)->D1_EMISSAO
                jCabecalho['codigocontrato']   := (cAlias)->ZBC_CODIGO // Assume-se que o código do item ZBC contém o do contrato
                jCabecalho['datacontrato']     := (cAlias)->ZCC_DTCONT
                jCabecalho['nomefornecedor']   := AllTrim((cAlias)->ZCC_NOMFOR)
                jCabecalho['quantidadeanimais'] := (cAlias)->ZCC_QTTTAN
                jCabecalho['codigocorretor']   := AllTrim((cAlias)->ZCC_CODCOR)
                jCabecalho['nomecorretor']     := AllTrim((cAlias)->ZCC_NOMCOR)
                
                lFirstRec := .F. // Desativa a flag
            EndIf

            // Para cada registro, cria um objeto de item
            jItem := JsonObject():New()
            jItem['item']             := (cAlias)->D1_ITEM
            jItem['codigoproduto']    := AllTrim((cAlias)->D1_COD)
            jItem['descricaoproduto'] := AllTrim((cAlias)->B1_DESC)
            jItem['quantidade']       := (cAlias)->D1_QUANT
            jItem['valorunitario']    := (cAlias)->D1_VUNIT
            jItem['valortotal']       := (cAlias)->D1_TOTAL
            jItem['itemcontrato']     := (cAlias)->ZBC_CODIGO // Link para o item do contrato
            jItem['peso']             := (cAlias)->ZBC_PESREA
            jItem['pesochegada']      := (cAlias)->D1_X_PESCH
            jItem['pesototalchegada'] := (cAlias)->ZBC_PESREA * (cAlias)->D1_QUANT
            jItem['pesototalsaida']   := (cAlias)->D1_X_PESCH * (cAlias)->D1_QUANT
            jItem['quebrachegada']    := (cAlias)->D1_X_QUECA
            jItem['km']               := (cAlias)->D1_X_KM
            jItem['quebrakg']         := (cAlias)->D1_X_QUEKG
            jItem['dataembarque']     := (cAlias)->D1_X_EMBDT
            jItem['horaembarque']     := (cAlias)->D1_X_EMBHR
            jItem['datachegada']      := (cAlias)->D1_X_CHEDT
            jItem['horachegada']      := (cAlias)->D1_X_CHEHR
            
            // Adiciona o objeto do item ao array de itens
            AAdd(aItens, jItem)

            (cAlias)->(DbSkip())
        EndDo

        // Adiciona o cabeçalho e o array de itens ao objeto de resposta final
        jResponse['cabecalhocontrato'] := jCabecalho
        jResponse['itensnotafiscal']   := aItens

    EndIf

    (cAlias)->(DbCloseArea())

    Self:SetHeader("Content-Type", "application/json")
    Self:SetResponse(jResponse:toJSON())
Return .T.

User Function zBusNtTe()
    Local cQry 		:= ""
    Local cAlias 	:= GetNextAlias()
    Local jResponse := JsonObject():New()
    Local jCabecalho:= JsonObject():New()
    Local aItens 	:= {}
    Local jItem 	:= Nil
    Local lFirstRec := .T. // Flag para controlar a primeira passagem e montar o cabeçalho

    // Query para buscar os dados da nota fiscal e do contrato
    cQry := " SELECT D1_FILIAL, D1_ITEM, D1_COD, B1_DESC, D1_QUANT, D1_VUNIT, D1_TOTAL, D1_PEDIDO, D1_EMISSAO, "
    cQry += " ZBC_PESREA, D1_X_PESCH, D1_X_QUECA, D1_X_KM, D1_X_QUEKG, D1_X_EMBDT, D1_X_EMBHR, D1_X_CHEDT, D1_X_CHEHR, "
    cQry += " ZBC_CODIGO, ZCC_DTCONT, ZCC_NOMFOR, ZCC_QTTTAN, ZCC_CODCOR, ZCC_NOMCOR "
    cQry += " FROM "+RetSqlName("SD1")+" SD1 "
    cQry += " LEFT JOIN "+RetSqlName("SB1")+" SB1 ON B1_COD = D1_COD AND SB1.D_E_L_E_T_ = '' "
    cQry += " LEFT JOIN "+RetSqlName("ZBC")+" ZBC ON ZBC_FILIAL = D1_FILIAL AND ZBC_PEDIDO = D1_PEDIDO AND ZBC_ITEMPC = D1_ITEMPC AND ZBC.D_E_L_E_T_ = '' "
    cQry += " LEFT JOIN "+RetSqlName("ZCC")+" ZCC ON ZCC_FILIAL = D1_FILIAL AND ZCC_CODIGO = ZBC_CODIGO AND ZCC.D_E_L_E_T_ = '' "
    cQry += " WHERE D1_FILIAL = '0101001' " // Usando xFilial para ser dinâmico
    cQry += " AND D1_FORNECE = '802583' "
    cQry += " AND D1_LOJA = '01' "
    cQry += " AND D1_DOC = '000021109' "
    cQry += " AND D1_SERIE = '2' "
    cQry += " AND SD1.D_E_L_E_T_ = '' "
    cQry += " ORDER BY D1_ITEM " // É uma boa prática ordenar os itens

    cAlias := MpSysOpenQry(cQry)

    If (cAlias)->(Eof())
        Self:setStatus(500)
        jResponse['errorId']  := 'ALL003'
        jResponse['error']    := 'Registro(s) não encontrado(s)'
        jResponse['solution'] := 'A consulta de registros não retornou nenhuma informação'
    Else
        // Inicializa o array que conterá os itens da nota
        aItens := {}

        While !(cAlias)->(Eof())
            
            // Na primeira passagem, monta o objeto de cabeçalho
            If lFirstRec
                jCabecalho['filial']           := (cAlias)->D1_FILIAL
                jCabecalho['notanumero']       := AllTrim((cAlias)->D1_DOC) + '-' + AllTrim((cAlias)->D1_SERIE)
                jCabecalho['pedidocompra']     := (cAlias)->D1_PEDIDO
                jCabecalho['dataemissao']      := (cAlias)->D1_EMISSAO
                jCabecalho['codigocontrato']   := (cAlias)->ZBC_CODIGO // Assume-se que o código do item ZBC contém o do contrato
                jCabecalho['datacontrato']     := (cAlias)->ZCC_DTCONT
                jCabecalho['nomefornecedor']   := AllTrim((cAlias)->ZCC_NOMFOR)
                jCabecalho['quantidadeanimais'] := (cAlias)->ZCC_QTTTAN
                jCabecalho['codigocorretor']   := AllTrim((cAlias)->ZCC_CODCOR)
                jCabecalho['nomecorretor']     := AllTrim((cAlias)->ZCC_NOMCOR)
                
                lFirstRec := .F. // Desativa a flag
            EndIf

            // Para cada registro, cria um objeto de item
            jItem := JsonObject():New()
            jItem['item']             := (cAlias)->D1_ITEM
            jItem['codigoproduto']    := AllTrim((cAlias)->D1_COD)
            jItem['descricaoproduto'] := AllTrim((cAlias)->B1_DESC)
            jItem['quantidade']       := (cAlias)->D1_QUANT
            jItem['valorunitario']    := (cAlias)->D1_VUNIT
            jItem['valortotal']       := (cAlias)->D1_TOTAL
            jItem['itemcontrato']     := (cAlias)->ZBC_CODIGO // Link para o item do contrato
            jItem['peso']             := (cAlias)->ZBC_PESREA
            jItem['pesochegada']      := (cAlias)->D1_X_PESCH
            jItem['quebrachegada']    := (cAlias)->D1_X_QUECA
            jItem['km']               := (cAlias)->D1_X_KM
            jItem['quebrakg']         := (cAlias)->D1_X_QUEKG
            jItem['dataembarque']     := (cAlias)->D1_X_EMBDT
            jItem['horaembarque']     := (cAlias)->D1_X_EMBHR
            jItem['datachegada']      := (cAlias)->D1_X_CHEDT
            jItem['horachegada']      := (cAlias)->D1_X_CHEHR
            
            // Adiciona o objeto do item ao array de itens
            AAdd(aItens, jItem)

            (cAlias)->(DbSkip())
        EndDo

        // Adiciona o cabeçalho e o array de itens ao objeto de resposta final
        jResponse['cabecalhoContrato'] := jCabecalho
        jResponse['itensNotaFiscal']   := aItens

    EndIf

    (cAlias)->(DbCloseArea())

    Self:SetHeader("Content-Type", "application/json")
    Self:SetResponse(jResponse:toJSON())
Return
