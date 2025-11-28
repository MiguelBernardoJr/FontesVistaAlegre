#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"

STATIC _ENTER_    := (Chr(13)+Chr(10))

WSRESTFUL VAPCPA19 DESCRIPTION "WebService REST para Roterização de Confinamento"
    WsMethod GET ConfinamentoGeral;
        DESCRIPTION "Listagem do cadastro de notas com a percentagem de ajustes";
        Path "/ConfinamentoGeral" ; // Path "/baias || /baia//s/{id}" ; WsSyntax "/CadastroDasNotas" ; // Path "/baias || /baias/{id}" ;
        Produces APPLICATION_JSON // ; TTalk "v1"

    WsMethod GET RotasDasBaias;
        DESCRIPTION "Historico de notas de cocho de todas as baias";
        Path "/RotasDasBaias" ;
        WsSyntax "/RotasDasBaias" ;
        Produces APPLICATION_JSON // ; TTalk "v1"

    WsMethod GET CoresDasRotas;
        DESCRIPTION "Historico de notas de cocho de todas as baias";
        Path "/CoresDasRotas" ; // Path "/baias || /baias/{id}" ; WsSyntax "/NotasDasBaias" ; // Path "/baias || /baias/{id}" ;
        WsSyntax "/CoresDasRotas" ;
        Produces APPLICATION_JSON // ; TTalk "v1"

END WSRESTFUL

//json principal
//User Function PCP19J1()
WsMethod GET ConfinamentoGeral WSSERVICE VAPCPA19

	Local jResponse     := JsonObject():New()
    Local cQry          := ''
    Local cAlias        := ''
	Local cBakConf := ""
	Local cBakLin  := ""
	Local oLinhaObj := NIL        // Objeto para a linha atual
	Local aLinhas  := {}         // Array nativo ADVPL para as linhas do confinamento
	Local aSequencias := {}        // Array nativo ADVPL para as sequências da linha

    cQry := " SELECT DISTINCT Z08.Z08_CONFNA AS CONF, Z08.Z08_TIPO AS TIPO, Z08.Z08_CODIGO, Z08.Z08_LINHA AS LINHA, Z08.Z08_SEQUEN AS SEQ "  + CRLF
	cQry += "      , ISNULL(SB8.B8_LOTECTL, 'SEM LOTE') AS LOTE, Z05.Z05_CABECA AS QUANT, (SELECT MAX(Z0M1.Z0M_VERSAO) FROM " + RetSqlName("Z0M") + " Z0M1 WHERE Z0M1.Z0M_CODIGO = Z0O.Z0O_CODPLA AND Z0M1.D_E_L_E_T_ = ' ') AS PLANO "  + CRLF
	cQry += "      , DATEDIFF(day, (SELECT MIN(SB8A.B8_XDATACO) FROM " + RetSqlName("SB8") + " SB8A WHERE SB8A.B8_LOTECTL = SB8.B8_LOTECTL AND SB8A.B8_FILIAL = '" + xFilial("SB8") + "' AND SB8A.B8_SALDO > 0 AND SB8A.D_E_L_E_T_ <> '*'),  GETDATE()) AS DIAS "  //DATEDIFF(day, SB8.B8_XDATACO,  GETDATE()) AS DIAS,  + CRLF
	cQry += "      --, Z05.Z05_DIETA AS DIETA "  + CRLF
	cQry += "      , Z0R.Z0R_DATA AS DTTRT, Z0R.Z0R_VERSAO AS VERSAO, Z0T.Z0T_ROTA AS ROTA "   + CRLF
	cQry += "      , (SELECT DISTINCT(SB1.B1_DESC) FROM " + RetSqlName("SB1") + " SB1 WHERE SB1.B1_COD = Z05.Z05_DIETA) AS DIEDSC "  //AND Z06.Z06_CURRAL = Z08.Z08_CODIGO + CRLF
	cQry += "      , Z05_DIETA DIETA" + CRLF
	cQry += "      , (SELECT COUNT(Z06.Z06_TRATO)  FROM " + RetSqlName("Z06") + " Z06 WHERE Z06.D_E_L_E_T_ <> '*' AND Z06.Z06_FILIAL = '" + xFilial('Z06') + "' AND Z06.Z06_DATA = Z0R.Z0R_DATA AND Z06.Z06_VERSAO = Z0R.Z0R_VERSAO AND Z06.Z06_LOTE = SB8.B8_LOTECTL) AS NRTRT "  + CRLF
	cQry += "      , (SELECT SUM(Z04.Z04_TOTREA)   FROM " + RetSqlName("Z04") + " Z04 WHERE Z04.Z04_DTIMP  = DATEADD(dd, -1, cast('"+DtoS(Date())+"' as datetime)) AND Z04.Z04_FILIAL = '" + xFilial('Z04') + "' AND Z04.D_E_L_E_T_ <> '*' AND Z04.Z04_LOTE = SB8.B8_LOTECTL) AS Z04_TOTREA "  + CRLF
	cQry += "      , (SELECT Z05A.Z05_KGMNDI FROM " + RetSqlName("Z05") + " Z05A WHERE Z05A.Z05_DATA = DATEADD(DAY, -1, Z0R.Z0R_DATA) AND Z05A.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*') AS KGMN "  + CRLF
	cQry += "      , (SELECT Z05A.Z05_KGMSDI FROM " + RetSqlName("Z05") + " Z05A WHERE Z05A.Z05_DATA = DATEADD(DAY, -1, Z0R.Z0R_DATA) AND Z05A.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*') AS KGMS "  + CRLF
	cQry += "      , (SELECT Z05A.Z05_KGMNDI FROM " + RetSqlName("Z05") + " Z05A WHERE Z05A.Z05_DATA = Z0R.Z0R_DATA AND Z05A.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*') AS KGMNDIA "  + CRLF
	cQry += "      , (SELECT Z05A.Z05_KGMSDI FROM " + RetSqlName("Z05") + " Z05A WHERE Z05A.Z05_DATA = Z0R.Z0R_DATA AND Z05A.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*') AS KGMSDIA "  + CRLF
	cQry += " FROM " + RetSqlName("Z08") + " Z08 "  + CRLF
	cQry += " LEFT JOIN " + RetSqlName("SB8") + " SB8 ON SB8.B8_X_CURRA = Z08.Z08_CODIGO AND SB8.B8_FILIAL = '" + xFilial("SB8") + "' AND SB8.D_E_L_E_T_ <> '*' AND SB8.B8_SALDO > 0 "  + CRLF
	cQry += " LEFT JOIN " + RetSqlName("Z0O") + " Z0O ON Z0O.Z0O_LOTE = SB8.B8_LOTECTL AND ('"+DtoS(Date())+"' BETWEEN Z0O.Z0O_DATAIN AND Z0O.Z0O_DATATR OR (Z0O.Z0O_DATAIN <= '"+DtoS(Date())+"' AND Z0O.Z0O_DATATR = '        ')) AND Z0O.Z0O_FILIAL = '" + xFilial("Z0O") + "' AND Z0O.D_E_L_E_T_ <> '*' "  + CRLF
	cQry += " LEFT JOIN " + RetSqlName("Z0R") + " Z0R ON Z0R.Z0R_DATA = '"+DtoS(Date())+"' AND Z0R.Z0R_VERSAO = '0001' AND Z0R.Z0R_FILIAL = '" + xFilial("Z0R") + "' AND Z0R.D_E_L_E_T_ <> '*' "  + CRLF
	cQry += " LEFT JOIN " + RetSqlName("Z05") + " Z05 ON Z05.Z05_DATA = Z0R.Z0R_DATA AND Z05.Z05_VERSAO = Z0R.Z0R_VERSAO AND Z05.Z05_LOTE = SB8.B8_LOTECTL AND Z05.Z05_FILIAL = '" + xFilial("Z05") + "' AND Z05.D_E_L_E_T_ <> '*' "  //AND Z05.Z05_CURRAL = SB8.B8_X_CURRA + CRLF
	cQry += " LEFT JOIN " + RetSqlName("Z0T") + " Z0T ON Z0T.Z0T_DATA = Z0R.Z0R_DATA AND Z0T.Z0T_VERSAO = Z0R.Z0R_VERSAO AND Z0T.Z0T_CURRAL = Z08_CODIGO AND Z0T.Z0T_FILIAL = '" + xFilial("Z0T") + "' AND Z0T.D_E_L_E_T_ <> '*' "  //Z0T.Z0T_LINHA = Z08.Z08_LINHA AND Z0T.Z0T_SEQUEN = Z08.Z08_SEQUEN + CRLF
	cQry += " WHERE Z08.D_E_L_E_T_ <> '*' "  + CRLF
	cQry += "   AND Z08.Z08_FILIAL = '" + xFilial("Z08") + "' AND Z08.Z08_CONFNA <> '' "  + CRLF
	cQry += "   AND Z08.Z08_MSBLQL <> '1' "  + CRLF
	cQry += IIf(.F., " AND SB8.B8_SALDO > 0 ", "")  + CRLF
	cQry += " GROUP BY Z08.Z08_CONFNA, Z08.Z08_TIPO, Z08.Z08_CODIGO, Z08.Z08_LINHA, Z08.Z08_SEQUEN, SB8.B8_LOTECTL, Z05.Z05_CABECA, Z0O.Z0O_CODPLA, Z05.Z05_DIETA, Z05.Z05_KGMNDI, Z05.Z05_KGMSDI, Z0R.Z0R_DATA, Z0R.Z0R_VERSAO, Z0T.Z0T_ROTA, Z05_FILIAL, Z05_VERSAO, Z05_DATA, Z05_LOTE"  //SB8.B8_XDATACO, + CRLF
	cQry += " ORDER BY Z08.Z08_CONFNA, Z08.Z08_TIPO, Z08.Z08_LINHA, Z08.Z08_SEQUEN, Z08.Z08_CODIGO "  + CRLF

	cAlias := MpSysOpenQry(cQry)

	if (cALias)->(EOF())
        Self:setStatus(500)
        jResponse['errorId']  := 'ALL003'
        jResponse['error']    := 'Registro(s) não encontrado(s)'
        jResponse['solution'] := 'A consulta de registros não retornou nenhuma informação'
    Else
        WHILE !(cAlias)->(EOF())
			// Verifica mudança de Confinamento
			IF cBakConf != (cAlias)->CONF
				// Cria um novo objeto que conterá as linhas e será o VALOR da chave CONF
				oConfValue := JsonObject():New()
				
				// Cria um novo array nativo ADVPL para as linhas deste confinamento
				aLinhas := {}
				oConfValue['Linhas'] := aLinhas  // Atribui o array de linhas ao objeto de valor do confinamento

				// Atribui o 'oConfValue' ao 'jResponse' usando o valor de CONF como chave
				jResponse[(cAlias)->CONF] := oConfValue
				
				cBakConf := (cAlias)->CONF
				cBakLin := "" // Reseta a linha para forçar a criação de nova linha
			ENDIF

			// Verifica mudança de Linha
			IF cBakLin != (cAlias)->LINHA
				// Cria um novo objeto para a linha
				oLinhaObj := JsonObject():New()
				oLinhaObj['Linha'] := (cAlias)->LINHA // Adiciona a chave 'Linha'
				
				// Cria um novo array nativo ADVPL para as sequências desta linha
				aSequencias := {}
				oLinhaObj['Sequencias'] := aSequencias // Atribui o array de sequências ao objeto da linha
				
				// Adiciona o objeto de linha ao array de linhas do confinamento atual
				AAdd(aLinhas, oLinhaObj)
				
				cBakLin := (cAlias)->LINHA
			ENDIF

			// Cria um novo objeto para os dados da sequência atual
			oSequenciaData := JsonObject():New()
			oSequenciaData['SEQ']     	:= (cAlias)->SEQ
			oSequenciaData['LOTE']    	:= ALLTRIM((cAlias)->LOTE)
			oSequenciaData['QUANT']   	:= (cAlias)->QUANT
			oSequenciaData['PLANO']   	:= Alltrim((cAlias)->PLANO)
			oSequenciaData['DIAS']    	:= (cAlias)->DIAS
			oSequenciaData['DIETA']   	:= Alltrim((cAlias)->DIETA)
			oSequenciaData['KGMN_DIA']	:= IIf((cAlias)->DIAS = 1, (cAlias)->KGMN, (cAlias)->KGMNDIA )
			oSequenciaData['KGMS_DIA']	:= IIf((cAlias)->DIAS == 1, (cAlias)->KGMS, (cAlias)->KGMSDIA )
			oSequenciaData['ROTA']  	:= (cAlias)->ROTA
			oSequenciaData['CONF']   	:= (cAlias)->CONF
			oSequenciaData['Z08_CODIGO']:= Alltrim((cAlias)->Z08_CODIGO)
			oSequenciaData['DIEDSC']    := Alltrim((cAlias)->DIEDSC)
			
			// Adiciona o objeto de dados da sequência ao array de sequências da linha atual
			AAdd(aSequencias, oSequenciaData)

			(cAlias)->(DbSkip())
        EndDo

    EndIf
    (cAlias)->(DbCloseArea())

    Self:SetResponse(jResponse:toJSON())

	MemoWrite("C:\totvs_relatorios\PCP19J1.txt" , jResponse:toJSON())
Return .T.

//json cor da rota
//User Function PCP19J2()
WsMethod GET RotasDasBaias WSSERVICE VAPCPA19
	Local jResponse     := JsonObject():New()
    Local cQry          := ''
    Local cAlias        := ''
	Local aSequencias := {}        // Array nativo ADVPL para as sequências da linha

    cQry := "SELECT DISTINCT (ZRT_ROTA) as ZRT_ROTA, ZRT_COR "+ CRLF
    cQry += "FROM "+RetSqlName("ZRT")+"  " + CRLF
    cQry += "WHERE D_E_L_E_T_ = ''" + CRLF

	cAlias := MpSysOpenQry(cQry)
    
    _cQry := " SELECT Z05_NROTRA " + CRLF
	_cQry += "  FROM " + RetSqlName("Z0T") + " Z0T" + CRLF
	_cQry += "  JOIN " + RetSqlName("Z05") + " Z05 " + CRLF
	_cQry += "        ON Z0T_FILIAL = Z05_FILIAL " + CRLF
	_cQry += "       AND Z05_DATA   = Z0T_DATA " + CRLF
	_cQry += "       AND Z0T_CURRAL = Z05_CURRAL  " + CRLF
	_cQry += "       AND Z05.D_E_L_E_T_ = ' '" + CRLF
	_cQry += " WHERE Z0T_FILIAL = '" + FwXFilial("Z0T") + "' " + CRLF
	_cQry += "   AND Z05_DATA   = '"+DtoS(Date())+"' " + CRLF
	_cQry += "   AND Z0T_ROTA   = ? " + CRLF
	_cQry += "   AND Z0T.D_E_L_E_T_ = ' '" + CRLF

    oExecRota := FwExecStatement():New(_cQry)

	if (cALias)->(EOF())
        Self:setStatus(500)
        jResponse['errorId']  := 'ALL003'
        jResponse['error']    := 'Registro(s) não encontrado(s)'
        jResponse['solution'] := 'A consulta de registros não retornou nenhuma informação'
    Else
        WHILE !(cAlias)->(EOF())
        	oExecRota:SetString(1,AllTrim((cAlias)->ZRT_ROTA))
            nQtdTrato := oExecRota:ExecScalar("Z05_NROTRA")

			oSequenciaData := JsonObject():New()
			oSequenciaData['ROTA']     	:= AllTrim((cAlias)->ZRT_ROTA)
			oSequenciaData['COR']    	:= AllTrim((cAlias)->ZRT_COR)
			oSequenciaData['QTD']    	:= nQtdTrato

			// Adiciona o objeto de dados da sequência ao array de sequências da linha atual
			AAdd(aSequencias, oSequenciaData)

			(cAlias)->(DbSkip())
        EndDo

        jResponse["ROTAS"] := aSequencias

    EndIf
    (cAlias)->(DbCloseArea())
    oExecRota:Destroy()

	Self:SetResponse(jResponse:toJSON())
Return .t.
//Cores da Dieta
//User Function PCP19J3()
WsMethod GET CoresDasDietas WSSERVICE VAPCPA19
    Local jResponse     := JsonObject():New()
    Local cQry          := ''
    Local cAlias        := ''
    Local aSequencias 	:= {} // Array nativo ADVPL para as sequências da linha

    cQry := " select Z05_DIETA from "+RetSqlName("Z05")+" " + CRLF
    cQry += "    WHERE Z05_DATA = '"+DtoS(Date())+"'  " + CRLF
    cQry += "    AND D_E_L_E_T_ = '' " + CRLF
    cQry += "    GROUP BY Z05_DIETA " + CRLF

    cALias := MpSysOpenQuery(cQry)

    if (cALias)->(EOF())
        Self:setStatus(500)
        jResponse['errorId']  := 'ALL003'
        jResponse['error']    := 'Registro(s) não encontrado(s)'
        jResponse['solution'] := 'A consulta de registros não retornou nenhuma informação'
    Else
        nCrAux  := 0

        While !((cALias)->(EOF()))

                oSequenciaData := JsonObject():New()
                oSequenciaData['DIETA']    	:= AllTrim((cAlias)->Z05_DIETA)
                oSequenciaData['COR']    	:= getMv("VA_CRDIE" + StrZero(++nCrAux, 2))
                // Adiciona o objeto de dados da sequência ao array de sequências da linha atual
                AAdd(aSequencias, oSequenciaData)

            (cALias)->(DBSkip())
        EndDo

        jResponse["CORES_DIETAS"] := aSequencias

    EndIf
    (cAlias)->(DbCloseArea())

	Self:SetResponse(jResponse:toJSON())
    //MemoWrite("C:\totvs_relatorios\PCP19J3.txt" , jResponse:toJSON())
Return

