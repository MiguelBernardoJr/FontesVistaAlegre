#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"

STATIC _ENTER_    := (Chr(13)+Chr(10))

/*
- https://centraldeatendimento.totvs.com/hc/pt-br/articles/360026453811-MP-FRAME-Configura%C3%A7%C3%A3o-de-Portais-e-WebServices

- https://terminaldeinformacao.com/2021/07/19/como-configurar-um-appserver-rest-no-protheus/
*/

// User Function WSNotaCocho(); Return '20240325'

WSRESTFUL WSNotaCocho DESCRIPTION "WebService REST para NotaCocho"

    WsMethod GET CadastroDasNotas;
        DESCRIPTION "Listagem do cadastro de notas com a percentagem de ajustes";
        Path "/CadastroDasNotas" ; // Path "/baias || /baias/{id}" ; WsSyntax "/CadastroDasNotas" ; // Path "/baias || /baias/{id}" ;
        Produces APPLICATION_JSON // ; TTalk "v1"

    WsMethod GET NotasDasBaias;
        DESCRIPTION "Historico de notas de cocho de todas as baias";
        Path "/NotasDasBaias" ;
        WsSyntax "/NotasDasBaias" ;
        Produces APPLICATION_JSON // ; TTalk "v1"

    WsMethod POST NotasDasBaias;
        DESCRIPTION "Historico de notas de cocho de todas as baias";
        Path "/NotasDasBaias" ; // Path "/baias || /baias/{id}" ; WsSyntax "/NotasDasBaias" ; // Path "/baias || /baias/{id}" ;
        WsSyntax "/NotasDasBaias" ;
        Produces APPLICATION_JSON // ; TTalk "v1"

END WSRESTFUL

// /* WSRECEIVE startIndex, count */

WsMethod GET NotasDasBaias WSSERVICE WSNotaCocho

    Local oHeaderJson := JsonObject():New()
    Local cAlias      := GetNextAlias()
    Local cQry        := ""
    Local cRet        := ""
    Local cLotes      := ""

    Local aHistorico  := {}
    Local nDiasHist   := GetMV('MB_DISHIST',,55)

    self:SetContentType("application/json")

    // verifica se recebeu parametro pela URL
    // exemplo: http://localhost:8080/NotaCocho/1
    If Len(self:aURLParms) > 0 .AND. "GET_" + Upper(self:aURLParms[1]) == ProcName()

        cQry := " WITH DADOS AS ( " + _ENTER_ +;
        "       select B8_FILIAL [FILIAL] " + _ENTER_ +;
        "  	      , CASE WHEN Z08_CONFNA <> '99' THEN Z08_LINHA  " + _ENTER_ +;
        "  	             WHEN Z08_CODIGO BETWEEN 'PS01' AND 'PS99' THEN 'PASTOS' " + _ENTER_ +;
        "  	             WHEN Z08_CODIGO BETWEEN 'RP01' AND 'RP10' THEN 'RP01 A 10' " + _ENTER_ +;
        "  	             WHEN Z08_CODIGO BETWEEN 'RP11' AND 'RP20' THEN 'RP11 A 20' " + _ENTER_ +;
        "  	             WHEN Z08_CODIGO BETWEEN 'RP21' AND 'RP30' THEN 'RP21 A 30' " + _ENTER_ +;
        "  	             WHEN Z08_CODIGO BETWEEN 'RP31' AND 'RP40' THEN 'RP31 A 40' " + _ENTER_ +;
        "  	             WHEN Z08_CODIGO BETWEEN 'RP41' AND 'RP54' THEN 'RP41 A 54' " + _ENTER_ +;
        "  	             WHEN Z08_CODIGO BETWEEN 'RP55' AND 'RP62' THEN 'RP55 A 62' " + _ENTER_ +;
        "  	             WHEN Z08_CODIGO BETWEEN 'RP63' AND 'RP69' THEN 'RP63 A 69' " + _ENTER_ +;
        "  	             WHEN Z08_CODIGO BETWEEN 'RZ01' AND 'RZ10' THEN 'RODIZIO' ELSE ' ' END  LINHA " + _ENTER_ +;
        "  	      , CASE WHEN Z08_CONFNA = '01' THEN 'B. VELHO' " + _ENTER_ +;
        "  		         WHEN Z08_CONFNA = '02' THEN 'B. NOVO'  " + _ENTER_ +;
        "  				 WHEN Z08_CONFNA = '99' THEN 'RECEPCAO' " + _ENTER_ +;
        "  				 ELSE 'CURRAIS' " + _ENTER_ +;
        "  				 END LOCALx       " + _ENTER_ +;
        "  		  , B8_LOTECTL [LOTE] " + _ENTER_ +;
        "  	      , RTRIM(B8_X_CURRA) [CURRAL] " + _ENTER_ +;
        "  	      , SUM(B8_SALDO) [QTDE] " + _ENTER_ +;
        "  		  , AVG(B8_XPESOCO) [PESO] " + _ENTER_ +;
        "  		  , ISNULL((CASE WHEN Z0O.Z0O_SEXO = 'M' THEN 'MACHO' " + _ENTER_ +;
        "  		                 WHEN Z0O.Z0O_SEXO = 'F' THEN 'FEMEA' " + _ENTER_ +;
        "  						 WHEN Z0O.Z0O_SEXO = 'C' THEN 'CAPAO' " + _ENTER_ +;
        "  						 ELSE ' ' END),'') [SEXO] " + _ENTER_ +;
        "  		  , ISNULL((Z0O.Z0O_RACA),' ' ) [RACA] " + _ENTER_ +;
        "  	      , CASE WHEN Z0O_DINITR = ' ' THEN CONVERT(DATE,max(SB8.B8_XDATACO),103)  " + _ENTER_ +;
        "                   WHEN Z0O_DINITR <> ' ' THEN CONVERT(DATE,Z0O_DINITR ,103) " + _ENTER_ +;
        "  				 ELSE CONVERT(DATE,max(SB8.B8_XDATACO), 103) END [DATA_INICIO]  " + _ENTER_ +;
        "  		  , DATEDIFF(DAY,  " + _ENTER_ +;
        "                   CASE WHEN Z0O_DINITR = ' ' THEN CONVERT(DATE,max(SB8.B8_XDATACO),103)  " + _ENTER_ +;
        "                        WHEN Z0O_DINITR <> ' ' THEN CONVERT(DATE,Z0O_DINITR ,103) " + _ENTER_ +;
        "  	            	  ELSE CONVERT(DATE,max(SB8.B8_XDATACO), 103)  " + _ENTER_ +;
        "  				 END  " + _ENTER_ +;
        "  	    		 ,  " + _ENTER_ +;
        "     	    		 CONVERT(DATE, GETDATE(), 103) " + _ENTER_ +;
        "  				) [DIAS_DE_COCHO] " + _ENTER_ +;
        "  		  " + _ENTER_ +;
        " 		  --, ISNULL(Z0O_PESOPR, 0) [PESO_PROJETADO] " + _ENTER_ +;
        "  		  , ISNULL((Z0O.Z0O_MCALPR),0) [MEGA_CAL] " + _ENTER_ +;
        "  		  , ISNULL(Z0O_GMD,1.7) [GMD_ESPERADO] " + _ENTER_ +;
        "  		   " + _ENTER_ +;
        "  		  /*, ISNULL((SELECT Z05.Z05_CMSPN  " + _ENTER_ +;
        "  		              FROM "+RetSqlName("Z05")+" (nolock) Z05  " + _ENTER_ +;
        "  					 WHERE Z05.Z05_FILIAL = B8_FILIAL  " + _ENTER_ +;
        "  					   AND Z05.Z05_LOTE = B8_LOTECTL  " + _ENTER_ +;
        "  					   AND Z05.D_E_L_E_T_ =' '   " + _ENTER_ +;
        "  					   AND Z05.Z05_DATA = (SELECT MAX(Z05D.Z05_DATA)  " + _ENTER_ +;
        "  					                     FROM "+RetSqlName("Z05")+" (nolock) Z05D  " + _ENTER_ +;
        "  										WHERE Z05D.Z05_FILIAL = Z05.Z05_FILIAL " + _ENTER_ +;
        "  										  AND Z05D.Z05_LOTE = Z05.Z05_LOTE " + _ENTER_ +;
        "  										  AND Z05D.D_E_L_E_T_ = ' ' )),0) [% CMS PV] " + _ENTER_ +;
        "  										  */ " + _ENTER_ +;
        "            , ISNULL((SELECT Z05.Z05_MEGCAL  " + _ENTER_ +;
        "  		              FROM "+RetSqlName("Z05")+" (nolock) Z05  " + _ENTER_ +;
        "  					 WHERE Z05.Z05_FILIAL = B8_FILIAL  " + _ENTER_ +;
        "  					   AND Z05.Z05_LOTE = B8_LOTECTL  " + _ENTER_ +;
        "  					   AND Z05.D_E_L_E_T_ =' '   " + _ENTER_ +;
        "  					   AND Z05.Z05_DATA = (SELECT MAX(Z05D.Z05_DATA)  " + _ENTER_ +;
        "  					                     FROM "+RetSqlName("Z05")+" (nolock) Z05D  " + _ENTER_ +;
        "  										WHERE Z05D.Z05_FILIAL = Z05.Z05_FILIAL " + _ENTER_ +;
        "  										  AND Z05D.Z05_LOTE = Z05.Z05_LOTE " + _ENTER_ +;
        "  										  AND Z05D.D_E_L_E_T_ = ' ' )),0) [MEGA_CAL_ATUAL] " + _ENTER_ +;
        "  		  , ROUND(ISNULL((SELECT MIN(SG1.G1_ENERG) " + _ENTER_ +;
        "  			            FROM "+RetSqlName("SG1")+" (nolock) SG1  " + _ENTER_ +;
        "  					   WHERE SG1.G1_FILIAL = SB8.B8_FILIAL " + _ENTER_ +;
        "  					     AND SG1.G1_COD = 'FINAL'  " + _ENTER_ +;
        "  						 AND SG1.D_E_L_E_T_ = ' ' " + _ENTER_ +;
        "  						 ),0)  " + _ENTER_ +;
        "  			  *  " + _ENTER_ +;
        "  		  ISNULL((SELECT Z0O.Z0O_PESO * (Z0O.Z0O_CMSPRE/100)  " + _ENTER_ +;
        "  			 FROM "+RetSqlName("Z0O")+" (nolock) Z0O  " + _ENTER_ +;
        "  			WHERE Z0O.Z0O_FILIAL = SB8.B8_FILIAL " + _ENTER_ +;
        "  			  AND Z0O.Z0O_LOTE = SB8.B8_LOTECTL " + _ENTER_ +;
        "  			  AND Z0O.Z0O_DATATR = ' ' AND Z0O.D_E_L_E_T_ = ' ' ),0),2) [MEGA_CAL_PROJETADO] " + _ENTER_ +;
        "         from "+RetSqlName("SB8")+" (nolock) SB8 " + _ENTER_ +;
        "    left join "+RetSqlName("Z0O")+" (nolock) Z0O ON  " + _ENTER_ +;
        "              Z0O_FILIAL = B8_FILIAL " + _ENTER_ +;
        "  		and Z0O_LOTE = B8_LOTECTL  " + _ENTER_ +;
        "  		and (Z0O_DATATR = ' ' AND Z0O_DATATR < GETDATE()) " + _ENTER_ +;
        "  		and Z0O.D_E_L_E_T_ = ' '  " + _ENTER_ +;
        "         join "+RetSqlName("Z08")+" (nolock) Z08 ON " + _ENTER_ +;
        "  	        Z08_FILIAL = B8_FILIAL " + _ENTER_ +;
        "  		AND Z08_CODIGO = B8_X_CURRA " + _ENTER_ +;
        "  		AND Z08.D_E_L_E_T_ = ' '  " + _ENTER_ +;
        "        where --SB8.B8_FILIAL  = '01' " + _ENTER_ +;
        "              SB8.B8_SALDO   <> 0 " + _ENTER_ +;
        "          and SB8.D_E_L_E_T_ = ' ' " + _ENTER_ +;
        "          and B8_X_CURRA <> ' '  " + _ENTER_ +;
        "  		--and B8_LOTECTL = '153-27' " + _ENTER_ +;
        "   GROUP BY B8_FILIAL " + _ENTER_ +;
        "          , Z08_LINHA " + _ENTER_ +;
        "          , Z08_CODIGO " + _ENTER_ +;
        "  		, Z08_CONFNA " + _ENTER_ +;
        "          , B8_LOTECTL " + _ENTER_ +;
        "          , B8_X_CURRA " + _ENTER_ +;
        "  		, Z0O_SEXO " + _ENTER_ +;
        "  		, Z0O_RACA " + _ENTER_ +;
        "          , Z0O_DINITR " + _ENTER_ +;
        "          , Z0O_PESOPR " + _ENTER_ +;
        "          , Z0O_GMD " + _ENTER_ +;
        "  		, Z0O_MCALPR " + _ENTER_ +;
        "    --ORDER BY B8_FILIAL,Z08_CONFNA, CURRAL " + _ENTER_ +;
        "  ), " + _ENTER_ +;
        "  HISTORICO AS (  " + _ENTER_ +;
        "    SELECT Z0W_FILIAL " + _ENTER_ +;
        "         , Z0W_DATA " + _ENTER_ +;
        "         , Z0W_LOTE " + _ENTER_ +;
        "  	    , Z0W_CURRAL " + _ENTER_ +;
        " 	    , ISNULL((" + _ENTER_ +;
        " 		    SELECT CASE Z05_DIETA " + _ENTER_ +;
        " 		             WHEN 'ADAPTACAO01' THEN 'ADAPT1'" + _ENTER_ +;
        " 				     WHEN 'ADAPTACAO01S' THEN 'ADAPT1'" + _ENTER_ +;
        " 				     WHEN 'ADAPTACAO02' THEN 'ADAPT2'" + _ENTER_ +;
        " 				     WHEN 'ADAPTACAO02S' THEN 'ADAPT2'" + _ENTER_ +;
        " 				     WHEN 'ADAPTACAO03' THEN 'ADAPT3'" + _ENTER_ +;
        " 				     WHEN 'ADAPTACAO03S' THEN 'ADAPT3'" + _ENTER_ +;
        " 				     WHEN 'ADAPTACAO03,FINAL' THEN 'ADAPT3/FINAL' " + _ENTER_ +;
        " 				     WHEN 'ADAPTACAO03S,FINALS' THEN 'ADAPT3/FINAL'                                          " + _ENTER_ +;
        " 				     WHEN 'FINAL' THEN 'FINAL'" + _ENTER_ +;
        " 				     WHEN 'FINALS' THEN 'FINAL'" + _ENTER_ +;
        " 				     ELSE Z05_DIETA" + _ENTER_ +;
        " 				     END DIETA " + _ENTER_ +;
        " 		          FROM "+RetSqlName("Z05")+" (nolock) Z05 WHERE Z05_FILIAL = Z0W_FILIAL AND Z05_LOTE = Z0W_LOTE AND Z05_DATA = Z0W_DATA AND Z05.D_E_L_E_T_ = ' ' ),'') DIETA" + _ENTER_ +;
        "  	   , SUM(Z0W_QTDPRE) Z0W_QTDPRE " + _ENTER_ +;
        " 	   , ISNULL((SELECT SUM(Z06_KGMSTR) FROM "+RetSqlName("Z06")+" (nolock) Z06 WHERE Z06_FILIAL = Z0W_FILIAL AND Z06_DATA = Z0W_DATA AND Z06_LOTE = Z0W_LOTE AND Z06.D_E_L_E_T_ = ' '),'') KG_MS " + _ENTER_ +;
        "  	   , ROUND(SUM(CASE WHEN Z0W.Z0W_PESDIG > 0 THEN Z0W.Z0W_PESDIG ELSE Z0W.Z0W_QTDREA END),2) Z0W_QTDREA " + _ENTER_ +;
        "  	   , Z0I_NOTMAN " + _ENTER_ +;
        "  	   , Z0I_NOTTAR " + _ENTER_ +;
        "      FROM "+RetSqlName("Z0W")+" (nolock) Z0W " + _ENTER_ +;
        "  	JOIN DADOS D ON  " + _ENTER_ +;
        "  	     D.FILIAL = Z0W_FILIAL " + _ENTER_ +;
        "  	 AND Z0W_LOTE = D.LOTE " + _ENTER_ +;
        "  	 AND Z0W_DATA >= DATEADD(D,-" + cValToChar(nDiasHist) + ",GETDATE()) " + _ENTER_ +;
        "  	 AND Z0W.D_E_L_E_T_ = ' '  " + _ENTER_ +;
        "  	JOIN "+RetSqlName("Z0I")+" (nolock) Z0I ON  " + _ENTER_ +;
        "  	     Z0I_FILIAL = Z0W_FILIAL " + _ENTER_ +;
        "  	 AND Z0I_LOTE = Z0W_LOTE " + _ENTER_ +;
        "  	 AND Z0I.Z0I_DATA = Z0W_DATA " + _ENTER_ +;
        "  	 AND Z0I.D_E_L_E_T_ =' '  " + _ENTER_ +;
        "     WHERE Z0W.D_E_L_E_T_ =' '  " + _ENTER_ +;
        "     GROUP BY Z0W_FILIAL " + _ENTER_ +;
        "         , Z0W_DATA " + _ENTER_ +;
        "         , Z0W_LOTE " + _ENTER_ +;
        "  	   , Z0W_CURRAL " + _ENTER_ +;
        "  	   , Z0I_NOTMAN " + _ENTER_ +;
        "  	   , Z0I_NOTTAR " + _ENTER_ +;
        "  	   --ORDER BY Z0W_LOTE, Z0W_DATA ASC " + _ENTER_ +;
        "  ) " + _ENTER_ +;
        "   --SELECT DISTINCT DIETA FROM HISTORICO " + _ENTER_ +;
        "  SELECT D.* " + _ENTER_ +;
        " 	  , isnull((SELECT TOP(1) Z0I_NOTTAR FROM "+RetSqlName("Z0I")+" Z0I WHERE Z0I_FILIAL = FILIAL AND Z0I_LOTE = LOTE AND Z0I.D_E_L_E_T_ = ' ' AND Z0I_DATA = (SELECT MAX(Z0I_DATA) FROM "+RetSqlName("Z0I")+" WHERE Z0I_FILIAL = '0101001' AND D_E_L_E_T_ =' '  )),'') ULTIMANOITE " + _ENTER_ +;
        " 	  --, isnull((SELECT TOP(1) Z0I_NOTTAR FROM "+RetSqlName("Z0I")+" Z0I WHERE Z0I_FILIAL = FILIAL AND Z0I_LOTE = LOTE AND Z0I.D_E_L_E_T_ = ' ' AND Z0I_DATA = CONVERT(DATE,GETDATE(), 103) ),'') ULTIMANOITE " + _ENTER_ +;
        " 	  , ROUND(ISNULL((SELECT TOP 1 HI.KG_MS FROM HISTORICO HI WHERE D.FILIAL = HI.Z0W_FILIAL AND D.LOTE = HI.Z0W_LOTE ORDER BY HI.Z0W_DATA DESC ),0) / (PESO + (DIAS_DE_COCHO * GMD_ESPERADO))*100,3) CMS" + _ENTER_ +;
        "     , H.DIETA[DIETA]" + _ENTER_ +;
        " 	  , H.KG_MS" + _ENTER_ +;
        " 	  , PESO + (DIAS_DE_COCHO * GMD_ESPERADO) PESO_PROJETADO" + _ENTER_ +;
        "       , H.Z0W_DATA [DATAx] " + _ENTER_ +;
        "       , H.Z0I_NOTMAN [NOTA_MANHA] " + _ENTER_ +;
        "  	 , H.Z0I_NOTTAR [NOTA_NOITE] " + _ENTER_ +;
        "  	 , H.Z0W_QTDPRE [KG_PREV] " + _ENTER_ +;
        "  	 , (SELECT Z05_CABECA FROM "+RetSqlName("Z05")+" Z05 WHERE Z05_DATA = H.Z0W_DATA and Z05_LOTE = H.Z0W_LOTE AND Z05.D_E_L_E_T_ = '') [CABECAS] " + _ENTER_ +;
        "  	 , H.Z0W_QTDREA [KG_TOTAL] " + _ENTER_ +;
        "    FROM DADOS D " + _ENTER_ +;
        "    LEFT JOIN HISTORICO H ON " + _ENTER_ +;
        "         D.FILIAL = H.Z0W_FILIAL " + _ENTER_ +;
        "     AND D.LOTE = H.Z0W_LOTE " + _ENTER_ +;
        "  ORDER BY LOCALx, LINHA, LOTE, DATAx DESC"

        MPSysOpenQuery( cQry, cAlias )

        While (cAlias)->( !EOF() )

            if cLotes <> (cAlias)->LOTE
                oHeaderJson := JsonObject():New()

                oHeaderJson[ "FILIAL" ]             := (cAlias)->FILIAL
                oHeaderJson[ "LINHA" ]              := AllTrim( (cAlias)->LINHA )
                oHeaderJson[ "LOCAL" ]              := (cAlias)->LOCALx
                oHeaderJson[ "LOTE" ]               := AllTrim( cLotes := (cAlias)->LOTE )
                oHeaderJson[ "CURRAL" ]             := AllTrim( (cAlias)->CURRAL )
                oHeaderJson[ "QTDE" ]               := (cAlias)->QTDE
                oHeaderJson[ "PESO" ]               := (cAlias)->PESO
                oHeaderJson[ "SEXO" ]               := AllTrim( (cAlias)->SEXO )
                oHeaderJson[ "RACA" ]               := AllTrim( (cAlias)->RACA )
                oHeaderJson[ "DATA_INICIO" ]        := (cAlias)->DATA_INICIO
                oHeaderJson[ "DIAS_DE_COCHO" ]      := (cAlias)->DIAS_DE_COCHO
                oHeaderJson[ "MEGA_CAL" ]           := (cAlias)->MEGA_CAL
                oHeaderJson[ "GMD_ESPERADO" ]       := (cAlias)->GMD_ESPERADO
                oHeaderJson[ "MEGA_CAL_ATUAL" ]     := (cAlias)->MEGA_CAL_ATUAL
                oHeaderJson[ "MEGA_CAL_PROJETADO" ] := (cAlias)->MEGA_CAL_PROJETADO
                oHeaderJson[ "CMS" ]                := (cAlias)->CMS
                oHeaderJson[ "PESO_PROJETADO" ]     := (cAlias)->PESO_PROJETADO
                oHeaderJson[ "ULTIMANOITE" ]        := (cAlias)->ULTIMANOITE
                // oHeaderJson[ "DATAx" ]              := (cAlias)->DATAx
                // oHeaderJson[ "NOTA_MANHA" ]         := (cAlias)->NOTA_MANHA
                // oHeaderJson[ "NOTA_NOITE" ]         := (cAlias)->NOTA_NOITE
                // oHeaderJson[ "KG_PREV" ]            := (cAlias)->KG_PREV
                // oHeaderJson[ "KG_TOTAL" ]           := (cAlias)->KG_TOTAL
                // oHeaderJson[ "KG_MS" ]              := (cAlias)->KG_MS
                // oHeaderJson[ "DIETA" ]              := AllTrim((cAlias)->DIETA)
            EndIf

            aAdd( aHistorico, JsonObject():New() )
            aHistorico[len(aHistorico)]["DATA"]       := sToD( (cAlias)->DATAx )
            aHistorico[len(aHistorico)]["NOTA_MANHA"] := AllTrim( (cAlias)->NOTA_MANHA )
            aHistorico[len(aHistorico)]["NOTA_NOITE"] := AllTrim( (cAlias)->NOTA_NOITE )
            aHistorico[len(aHistorico)]["KG_PREV"]    := (cAlias)->KG_PREV
            aHistorico[len(aHistorico)]["KG_TOTAL"]   := (cAlias)->KG_TOTAL
            aHistorico[len(aHistorico)]["KG_MS"]      := (cAlias)->KG_MS
            aHistorico[len(aHistorico)]["DIETA"]      := AllTrim((cAlias)->DIETA)
            aHistorico[len(aHistorico)]["CABECAS"]    := (cAlias)->CABECAS

            (cAlias)->( dbSkip() )

            If (cAlias)->( EOF() ) .OR. cLotes <> (cAlias)->LOTE
                oHeaderJson[ "HISTORICO" ] := aHistorico
                aHistorico := {}
                cRet += Iif(Empty(cRet),"",",") + oHeaderJson:toJson()
            EndIf

        EndDo
        cRet := '[' + cRet + ']'
        (cAlias)->( dbCloseArea() )
    Else

        oHeaderJson["CODIGO"       ] := 99
        oHeaderJson["DESCRICAO"    ] := "ENDPOINT BAIAS NAO LOCALIZADO"
        cRet := oHeaderJson:toJson()

    EndIf
    self:SetResponse( cRet )

    FreeObj( oHeaderJson )

Return .T.

WsMethod POST NotasDasBaias WSSERVICE WSNotaCocho

    Local aArea     := GetArea()
    Local lRet      := .T.
    Local oJson     := JsonObject():New()
    Local oResponse := JsonObject():New()
    Local cBody     := self:GetContent()
    Local cDateTime := FWTimeStamp(5)

    DbSelectArea("ZWS")
    ZWS->(DBSetOrder( 1 ))

    If !Empty(cBody)

        cError  := oJson:FromJson(cBody)
        If Empty(cError)

            oResponse["code"] 				:= "200"
            oResponse["message"] 			:= EncodeUTF8("Ok - Json Recebido com sucesso")
            oResponse["error"] 				:= ""
            oResponse["totvs_sync_date"] 	:= cDateTime

            cQry := "SELECT MAX(ZWS_CODIGO) AS ZWS_CODIGO FROM "+RetSqlName("ZWS")+" (nolock) WHERE D_E_L_E_T_ = ' '"
            cCod := StrZero(Val(MpSySExecScalar( cQry , "ZWS_CODIGO")) + 1,TamSx3("ZWS_CODIGO")[1])
            // Gravao dos dados
            RecLock("ZWS", .T.)
                ZWS->ZWS_CODIGO := cCod
                ZWS->ZWS_TIPO   := "J"
                ZWS->ZWS_STATUS := "R"
                ZWS->ZWS_WSDATA := MsDate()
                ZWS->ZWS_WSHORA := Time()
                ZWS->ZWS_METODO := "POST NotasDasBaias"
                ZWS->ZWS_CONTEU := cBody
                ZWS->ZWS_RESULT := (cResult := oResponse:toJson())
                ZWS->(MsUnLock())
            ConfirmSX8()
            // Fim da gravao

            /* MB : 17.06.2024 
                -> Confmando o procesorme sugesto do Toshio, estarei chasamento do json recebido diretamente da
                WS aps gravacao na tabela intermediria. */
            U_fIntegrar( 'U' )
        Else
            
            oResponse["code"] 				:= "406"
            oResponse["message"] 			:= ""
            oResponse["error"] 				:= "Erro ao converter JSON: " + cError
            oResponse["totvs_sync_date"] 	:= cDateTime
            cResult := oResponse:toJson()

        EndIf
        Self:SetResponse( cResult )
    EndIf

    If Valtype(oJson) == "O"
        FreeObj(oJson)
        oJson := NIL
    EndIf

    If Valtype(oResponse) == "O"
        FreeObj(oResponse)
        oResponse := NIL
    EndIf

    RestArea(aArea)
Return lRet

/*
    MB : 27.03.2024
*/
WsMethod GET CadastroDasNotas WSSERVICE WSNotaCocho

    Local oHeaderJson := JsonObject():New()
    Local cAlias      := GetNextAlias()
    Local cQry        := ""
    Local cRet        := ""

    self:SetContentType("application/json")

    If Len(self:aURLParms) > 0 .AND. "GET_" + Upper(self:aURLParms[1]) == ProcName()

        cQry := " WITH DADOS AS ( " + _ENTER_ +;
                " select Z0G_FILIAL [FILIAL] " + _ENTER_ +;
                       ", CASE Z0G_DIETA" + _ENTER_ +;
				            "  WHEN 'FINAL' THEN 'FINAL'" + _ENTER_ +;
				            "  WHEN 'FINALS' THEN 'FINAL'" + _ENTER_ +;
				            "  WHEN 'ADAPTACAO03' THEN 'ADAPT3'" + _ENTER_ +;
				            "  WHEN 'ADAPTACAO03S' THEN 'ADAPT3'" + _ENTER_ +;
				            "  WHEN 'ADAPTACAO02' THEN 'ADAPT2'" + _ENTER_ +;
				            "  WHEN 'ADAPTACAO02S' THEN 'ADAPT2'" + _ENTER_ +;
				            "  WHEN 'ADAPTACAO01' THEN 'ADAPT1'" + _ENTER_ +;
				            "  WHEN 'ADAPTACAO01S' THEN 'ADAPT1'" + _ENTER_ +;
				            "  ELSE Z0G_DIETA END  [DIETA] " + _ENTER_ +;
            "      , Z0G_DESCRI [DESCRICAO] " + _ENTER_ +;
            "      , Z0G_CODIGO [CODIGO_NOTA] " + _ENTER_ +;
            "      , Z0G_PERAJU [PERC_AJUSTE] " + _ENTER_ +;
            "      , Z0G_ZERTRT [ZERA_PRIM_TRATO] " + _ENTER_ +;
            " FROM  Z0G010 (nolock) Z0G " + _ENTER_ +;
            " WHERE Z0G_MSBLQL <> 1 AND Z0G_FILIAL = '0101001' " + _ENTER_ +;
            "   AND Z0G.D_E_L_E_T_ =' ' " + _ENTER_ +;
            "   ) SELECT DISTINCT * FROM DADOS "

        MPSysOpenQuery( cQry, cAlias )

        While (cAlias)->( !EOF() )

            oHeaderJson                      := JsonObject():New()
            oHeaderJson[ "FILIAL" ]          := (cAlias)->FILIAL
            oHeaderJson[ "DIETA" ]           := AllTrim( (cAlias)->DIETA )
            oHeaderJson[ "DESCRICAO" ]       := AllTrim( (cAlias)->DESCRICAO )
            oHeaderJson[ "CODIGO_NOTA" ]     := AllTrim( (cAlias)->CODIGO_NOTA )
            oHeaderJson[ "PERC_AJUSTE" ]     := (cAlias)->PERC_AJUSTE
            oHeaderJson[ "ZERA_PRIM_TRATO" ] := (cAlias)->ZERA_PRIM_TRATO

            cRet += Iif(Empty(cRet),"",",") + oHeaderJson:toJson()

            (cAlias)->( dbSkip() )
        EndDo
        cRet := '[' + cRet + ']'
        (cAlias)->( dbCloseArea() )

    Else

        oHeaderJson["CODIGO"       ] := 99
        oHeaderJson["DESCRICAO"    ] := "ENDPOINT BAIAS NAO LOCALIZADO"
        cRet := oHeaderJson:toJson()

    EndIf
    self:SetResponse( cRet )
    FreeObj( oHeaderJson )

Return .T.
