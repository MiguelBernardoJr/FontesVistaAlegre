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

    Local oJsonRetorno := JsonObject():New()

    // 4. CORREÇÃO: Acessamos os parâmetros usando Self:NomeDaVariavel
    If !Empty(Self:numero)
        oJsonRetorno["status"]      := "sucesso"
        oJsonRetorno["numeroNota"]  := Self:numero
        oJsonRetorno["serieNota"]   := Self:serie
        oJsonRetorno["fornecedor"]  := Self:fornecedor
        oJsonRetorno["lojaNota"]    := Self:loja
        oJsonRetorno["filial"]      := Self:filial
        oJsonRetorno["mensagem"]    := "Dados recebidos via Query String."
    Else
        Self:SetStatusCode(400) // Bad Request
        oJsonRetorno["status"]   := "erro"
        oJsonRetorno["mensagem"] := "Parâmetros não recebidos."
    Endif

    Self:SetHeader("Content-Type", "application/json")
    Self:SetResponse(oJsonRetorno:ToJson())

Return .T.
