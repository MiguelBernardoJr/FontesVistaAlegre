#INCLUDE "TOTVS.CH"
#INCLUDE "TryException.ch"
#INCLUDE "FileIO.ch"

#DEFINE __TRACO__ Replicate("-", 100 )
#DEFINE ENTER CHR(13)+CHR(10)

/*--------------------------------------------------------------------------------,
 | Principal: 			            U_VAMONWS()             		              |
 | Func:  VAMONWS()	            	          	            	          	      |
 | Autor: Miguel Martins Bernardo Junior	            	          	  		  |
 | Data:  21.12.2021	            	          	            	              |
 | Desc:  "Monitor de Controle de integrações"                     	              |
 '--------------------------------------------------------------------------------|
 | Obs.:                                                                          |
 |                                                                                |
'--------------------------------------------------------------------------------*/
User Function VAMONWS()    // U_VAMONWS()
    Local cAlias      := "ZWS"
    Local oBrowse 	  := nil
    Local aCores      := { {"ZWS->ZWS_STATUS == 'R'", "BR_BRANCO"  },;
                           {"ZWS->ZWS_STATUS == 'P'", "BR_AMARELO" },;
                           {"ZWS->ZWS_STATUS == 'O'", "BR_VERDE"   },;
                           {"ZWS->ZWS_STATUS == 'E'", "BR_VERMELHO"} }

    Private cCadastro := "Logs de operação"
    Private aRotina 	  := MenuDef()

    //Instanciando FWMBrowse - Somente com dicionário de dados
    oBrowse := FWMBrowse() :New()
    //Setando a tabela de cadastro de Autor/Interprete
    oBrowse:SetAlias(cAlias)
    //Setando a descrição da rotina
    oBrowse:SetDescription( cCadastro )

    //Legendas
    // oBrowse:SetFilterDefault( "Z02_TPARQ == '3'" )
    oBrowse:AddLegend( "ZWS->ZWS_STATUS == 'R'", "BR_BRANCO"  , "Recebido"   )
    oBrowse:AddLegend( "ZWS->ZWS_STATUS == 'P'", "BR_AMARELO" , "Processando" )
    oBrowse:AddLegend( "ZWS->ZWS_STATUS == 'O'", "BR_VERDE"   , "Finalizado"  )
    oBrowse:AddLegend( "ZWS->ZWS_STATUS == 'E'", "BR_VERMELHO", "Erro"        )

    SetKey(VK_F10, {|| U_fIntegrar('U') })
    SetKey(VK_F11, {|| U_fIntegrar('L') })

    //Ativa a Browse
    oBrowse:Activate()

Return Nil

Static FUnction Menudef()
    Local aRotina := { { "Integrar (F10)"        , "U_fIntegrar('U')", 0, 4 },;
                       { "Visualizar"            , "axVisual"        , 0, 2 },;
                       { "Alterar"               , "axAltera"        , 0, 4 },;
                       { "Excluir"               , "axDeleta"        , 0, 5 },;
                       { "Integrar em Lote (F11)", "U_fIntegrar('L')", 0, 4 } }
Return aRotina


/*--------------------------------------------------------------------------------,
 | Principal: 			            U_SchAppPt()             		              |
 | Func:  	  SchAppPt()          	          	            	          	      |
 | Autor:     Miguel Martins Bernardo Junior	            	          	  	  |
 | Data:      04.01.2022	            	          	            	          |
 | Desc:      Schedule de processamento da integracao do APP da portaria.         |
 '--------------------------------------------------------------------------------|
 | Obs.:                                                                          |
 |                                                                                |
'--------------------------------------------------------------------------------*/
User Function SchAppPt() // U_SchAppPt()
    If Type("oMainWnd") == "U"
        ConOut("")
        ConOut("")
        ConOut("")
        ConOut("")
        ConOut("[SchAppPt] Chamada por Schedule: " + Time())
        U_RunFunc("U_fIntegrar('L')",'01','01',3)
    Else
        U_fIntegrar("L")
    EndIf
Return nil

/*--------------------------------------------------------------------------------,
 | Principal: 			            U_VAMONWS()             		              |
 | Func:  VAMONWS()	            	          	            	          	      |
 | Autor: Miguel Martins Bernardo Junior	            	          	  		  |
 | Data:  21.12.2021	            	          	            	              |
 | Desc:  "Monitor de Controle de integrações"                     	              |
 '--------------------------------------------------------------------------------|
 | Obs.:                                                                          |
 |                                                                                |
'--------------------------------------------------------------------------------*/
User Function fIntegrar( cOpc )
    Local aArea        := GetArea()
    Local lErro        := .F.
    Local nQtdCiclos   := 1000

    Private lLOOP      := .T. // deixa job em Loop, sem finalizar
    Private nCoProcPVI := 0 // Contagem de processo/Ciclos, reiniciar de tempo em tempo para forcar que o servico nao fique parado

    If Type("cSemaforo") == "U"
        Public  cSemaforo := ""
    EndIf

    Default cOpc       := "L"

    If cOpc == "L"

        While lLOOP

            nCoProcPVI += 1
            ConOut('Contador de Processos/Ciclos: ' + StrZero(nCoProcPVI, 4) )

            dbUseArea(.T.,'TOPCONN',TCGENQRY(,,;
                _cQry := " SELECT   ISNULL(MAX(R_E_C_N_O_),0) RECNO " + ENTER +; // _cQry := " SELECT   ISNULL(MIN(R_E_C_N_O_),0) RECNO " + ENTER +;
                " FROM      ZWS010 " + ENTER +;
                " WHERE " + ENTER +;
                "           ZWS_STATUS = 'R' " + ENTER +;
                "       AND D_E_L_E_T_ = ' '";
                ),"TEMPSQL",.F.,.F.)

            If !TEMPSQL->(Eof()) .AND. TEMPSQL->RECNO > 0
                ZWS->(DbGoTo( TEMPSQL->RECNO ) )
                cSemaforo := "Recno ZWS " + cValToChar( ZWS->(Recno()) )
                If ( lErro := IntEmLote() )
                    ConOut( "Erro no processamento do Schedule: " + cValToChar(ZWS->(Recno())) )
                    // exit
                EndIf
                Sleep( 1000*1 )
            Else
                ConOut( "1-Time: " + Time() )
                Sleep( 1000*10 )
                ConOut( "2-Time: " + Time() )
                // lLOOP := .F.
                // Exit
            EndIf
            TEMPSQL->(DbCloseArea())

            If nCoProcPVI >= nQtdCiclos
                // Sleep(Randomize(1000,10000))
                ConOut( "3-Time: " + Time() )
                Sleep( 1000*30 )
                ConOut( "4-Time: " + Time() )
                lLOOP := .F.
            EndIf
        EndDo

    Else
        cSemaforo := "Recno ZWS " + cValToChar( ZWS->(Recno()) )
        lErro := IntEmLote()
    EndIf
    If lErro
        DisarmTransaction()
    EndIf

    If !lLOOP
        Final("O proceso de integracao chegou a " + cValToChar(nQtdCiclos) +;
            " ciclos e por isso sera reiniciado. Por favor aguarde um momento.")
    EndIf

    RestArea(aArea)
Return lErro


/*--------------------------------------------------------------------------------,
 | Principal : 			                        		                          |
 | Func:     : Integração em Lote  	          	            	          	      |
 | Autor: Miguel Martins Bernardo Junior	            	          	  		  |
 | Data:  28.12.2021	            	          	            	              |
 | Desc:  Rotina para realizar a integração                                       |
 '--------------------------------------------------------------------------------|
 | Obs.:                                                                          |
 |                                                                                |
'--------------------------------------------------------------------------------*/
Static Function IntEmLote()

    Local aArea       := {} // GetArea()
    Local lErro       := .T.
    Local nInicio     := Time()
    Local oResult     := nil // JsonObject():New()
    Local nI          := 0
    Local lInclui     := .T.
    Local cHora       := ""
    Local cQryCur     := ""

    Local nZ0I_CODIGO := 0
    Local nPos        := 0
    Local sDataQry       := ""
    Local cPeriodo    := ""

    ConOut(" ")
    ConOut("Inicio - " + FunName() + ": " + nInicio )

    // If ZWS->ZWS_STATUS == "O"
    //     MsgInfo( "A integração de codigo: " + ZWS->ZWS_CODIGO + " ja foi processada com Sucesso. Esta operacao sera cancelada.",;
    //              "Aviso")
    //     Return lErro
    // EndIf

    aArea   := GetArea()
    oResult := JsonObject():New()
    // nAux := At("-", ZWS->ZWS_METODO)
    TryException
        BeginTran()

        ConOut( cSemaforo )
        While !LockByName(cSemaforo,.F., .F., .T.)
            Sleep(500)
        EndDo

        RecLock( "ZWS", .F. )
        ZWS->ZWS_SCHDTA := MsDate()
        ZWS->ZWS_SCHHRA := Time()
        ZWS->ZWS_STATUS := "P" // I=Importado para ZFL

        If AllTrim(ZWS->ZWS_METODO) == "POST NotasDasBaias"

            oResult:FromJson( DecodeUTF8( __cTxt := ZWS->ZWS_CONTEU ) )
            aSort( oResult:CURRAIS,,, { |x,y| x:CURRAL < y:CURRAL } )
            
            /* 
                Igor Oliveira - 2023-10-16
                Ajuste solicitado pelo Toshio.
                Se nota de cocho for de noite e hora > 21hrs pegar próxima data
            */
            cHora := Substr(oResult:DATA, 12, 5)
            cPeriodo := ""
            For nI := 1 to Len(oResult:currais)
                if ValType(oResult:currais[nI]['NOTA_MANHA']) <> "U"
                    cPeriodo := "MANHA"
                    exit
                elseif ValType(oResult:currais[nI]['NOTA_NOITE']) <> "U"
                    cPeriodo := "NOITE"
                    exit
                endif
            Next nI

            if cPeriodo == "MANHA" // Mantem o comportamento original
                sDataQry := DTOS(DaySub(cToD( Left(oResult:DATA, 10) ), 1))                               
                sDataRec := DTOS(cToD( Left(oResult:DATA, 10) ))
            else
                if (Val(SubStr(Time(),1,2)) >= 21 .and. cToD( Left(oResult:DATA, 10) ) == Date()) .or.;
                   (Val(SubStr(Time(),1,2)) <= 5  .and. DaySum(cToD( Left(oResult:DATA, 10) ), 1) == Date())

                    sDataQry  := DTOS(cToD( Left(oResult:DATA, 10) ))
                    sDataRec  := DTOS(DaySum(cToD( Left(oResult:DATA, 10) ),1))
                else // Se for a data de hoje e hora < 21:00 // mantem o comportamento original
                    sDataQry := DTOS(DaySub(cToD( Left(oResult:DATA, 10) ), 1))               
                    sDataRec := DTOS(cToD( Left(oResult:DATA, 10) ))
                endif
            endif

            cQryCur := "" + ENTER
            // cQryCur := " USE TotvsAntigo " + ENTER
            cQryCur += " SELECT Z08.Z08_LINHA AS LINHA, Z08.Z08_SEQUEN AS SEQ, Z08.Z08_CODIGO AS CURRAL, SB8.B8_LOTECTL AS LOTE " + ENTER
            //cQryCur += "       ,(SELECT SUM(Z04.Z04_TOTREA) FROM " + RetSqlName("Z04") +  " Z04 WHERE Z04.Z04_DTIMP  = DATEADD(dd, -1, cast('" + DTOS(cToD( Left(oResult:DATA, 10) )) + "' as datetime)) AND Z04.Z04_FILIAL = '" + FWxFilial("Z04") + "' AND Z04.D_E_L_E_T_ <> '*' AND Z04.Z04_LOTE = SB8.B8_LOTECTL) AS TOTREA " + ENTER
            //cQryCur += "       ,(SELECT SUM(Z04.Z04_TOTAPR) FROM " + RetSqlName("Z04") +  " Z04 WHERE Z04.Z04_DTIMP  = DATEADD(dd, -1, cast('" + DTOS(cToD( Left(oResult:DATA, 10) )) + "' as datetime)) AND Z04.Z04_FILIAL = '" + FWxFilial("Z04") + "' AND Z04.D_E_L_E_T_ <> '*' AND Z04.Z04_LOTE = SB8.B8_LOTECTL) AS TOTAPR " + ENTER
            cQryCur += "       ,(SELECT SUM(Z0WA.Z0W_QTDPRE) Z0W_QTDPRE  FROM " + RetSqlName("Z0W") +  " Z0WA WHERE Z0WA.Z0W_DATA  = '" + sDataQry + "' AND Z0WA.Z0W_FILIAL = '" + FWxFilial("Z05") + "' AND Z0WA.D_E_L_E_T_ <> '*' AND Z0WA.Z0W_LOTE = SB8.B8_LOTECTL ) AS  TOTAPR " + ENTER
            cQryCur += "       ,(SELECT SUM(Z0WA.Z0W_QTDREA) Z0W_QTDREA  FROM " + RetSqlName("Z0W") +  " Z0WA WHERE Z0WA.Z0W_DATA  = '" + sDataQry + "' AND Z0WA.Z0W_FILIAL = '" + FWxFilial("Z05") + "' AND Z0WA.D_E_L_E_T_ <> '*' AND Z0WA.Z0W_LOTE = SB8.B8_LOTECTL ) AS  TOTREA " + ENTER
            cQryCur += "       ,(SELECT Z05A.Z05_DIETA  FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(sToD(sDataQry), 5)) + "' AND Z05A.Z05_FILIAL = '" + FWxFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_CURRAL = Z08.Z08_CODIGO) AS DIETD5 " + ENTER
            cQryCur += "       ,(SELECT Z05A.Z05_KGMSDI FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(sToD(sDataQry), 5)) + "' AND Z05A.Z05_FILIAL = '" + FWxFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_CURRAL = Z08.Z08_CODIGO) AS  KGMSD5 " + ENTER
            cQryCur += "       ,(SELECT Z05A.Z05_CMSPN  FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(sToD(sDataQry), 5)) + "' AND Z05A.Z05_FILIAL = '" + FWxFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_CURRAL = Z08.Z08_CODIGO) AS  CMSPV5  " + ENTER
            cQryCur += "       ,(SELECT Z0IA.Z0I_NOTMAN FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(sToD(sDataQry), 5)) + "' AND Z0IA.Z0I_FILIAL = '" + FWxFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = SB8.B8_LOTECTL) AS NOTMD5 " + ENTER
            cQryCur += "       ,(SELECT Z0IA.Z0I_NOTTAR FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(sToD(sDataQry), 5)) + "' AND Z0IA.Z0I_FILIAL = '" + FWxFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = SB8.B8_LOTECTL) AS NOTTD5 " + ENTER
            cQryCur += "       ,(SELECT Z0IA.Z0I_NOTNOI FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(sToD(sDataQry), 5)) + "' AND Z0IA.Z0I_FILIAL = '" + FWxFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = SB8.B8_LOTECTL) AS NOTND5 " + ENTER
            cQryCur += "       ,(SELECT Z05A.Z05_DIETA  FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(sToD(sDataQry), 4)) + "' AND Z05A.Z05_FILIAL = '" + FWxFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_CURRAL = Z08.Z08_CODIGO) AS DIETD4 " + ENTER
            cQryCur += "       ,(SELECT Z05A.Z05_KGMSDI FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(sToD(sDataQry), 4)) + "' AND Z05A.Z05_FILIAL = '" + FWxFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_CURRAL = Z08.Z08_CODIGO) AS  KGMSD4 " + ENTER
            cQryCur += "       ,(SELECT Z05A.Z05_CMSPN  FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(sToD(sDataQry), 4)) + "' AND Z05A.Z05_FILIAL = '" + FWxFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_CURRAL = Z08.Z08_CODIGO) AS  CMSPV4 " + ENTER
            cQryCur += "       ,(SELECT Z0IA.Z0I_NOTMAN FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(sToD(sDataQry), 4)) + "' AND Z0IA.Z0I_FILIAL = '" + FWxFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = SB8.B8_LOTECTL) AS NOTMD4 " + ENTER
            cQryCur += "       ,(SELECT Z0IA.Z0I_NOTTAR FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(sToD(sDataQry), 4)) + "' AND Z0IA.Z0I_FILIAL = '" + FWxFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = SB8.B8_LOTECTL) AS NOTTD4 " + ENTER
            cQryCur += "       ,(SELECT Z0IA.Z0I_NOTNOI FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(sToD(sDataQry), 4)) + "' AND Z0IA.Z0I_FILIAL = '" + FWxFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = SB8.B8_LOTECTL) AS NOTND4 " + ENTER
            cQryCur += "       ,(SELECT Z05A.Z05_DIETA  FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(sToD(sDataQry), 3)) + "' AND Z05A.Z05_FILIAL = '" + FWxFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_CURRAL = Z08.Z08_CODIGO) AS DIETD3 " + ENTER
            cQryCur += "       ,(SELECT Z05A.Z05_KGMSDI FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(sToD(sDataQry), 3)) + "' AND Z05A.Z05_FILIAL = '" + FWxFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_CURRAL = Z08.Z08_CODIGO) AS  KGMSD3 " + ENTER
            cQryCur += "       ,(SELECT Z05A.Z05_CMSPN  FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(sToD(sDataQry), 3)) + "' AND Z05A.Z05_FILIAL = '" + FWxFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_CURRAL = Z08.Z08_CODIGO) AS  CMSPV3 " + ENTER
            cQryCur += "       ,(SELECT Z0IA.Z0I_NOTMAN FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(sToD(sDataQry), 3)) + "' AND Z0IA.Z0I_FILIAL = '" + FWxFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = SB8.B8_LOTECTL) AS NOTMD3 " + ENTER
            cQryCur += "       ,(SELECT Z0IA.Z0I_NOTTAR FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(sToD(sDataQry), 3)) + "' AND Z0IA.Z0I_FILIAL = '" + FWxFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = SB8.B8_LOTECTL) AS NOTTD3 " + ENTER
            cQryCur += "       ,(SELECT Z0IA.Z0I_NOTNOI FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(sToD(sDataQry), 3)) + "' AND Z0IA.Z0I_FILIAL = '" + FWxFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = SB8.B8_LOTECTL) AS NOTND3 " + ENTER
            cQryCur += "       ,(SELECT Z05A.Z05_DIETA  FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(sToD(sDataQry), 2)) + "' AND Z05A.Z05_FILIAL = '" + FWxFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_CURRAL = Z08.Z08_CODIGO) AS DIETD2 " + ENTER
            cQryCur += "       ,(SELECT Z05A.Z05_KGMSDI FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(sToD(sDataQry), 2)) + "' AND Z05A.Z05_FILIAL = '" + FWxFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_CURRAL = Z08.Z08_CODIGO) AS  KGMSD2 " + ENTER
            cQryCur += "       ,(SELECT Z05A.Z05_CMSPN  FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + DTOS(DaySub(sToD(sDataQry), 2)) + "' AND Z05A.Z05_FILIAL = '" + FWxFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_CURRAL = Z08.Z08_CODIGO) AS  CMSPV2 " + ENTER
            cQryCur += "       ,(SELECT Z0IA.Z0I_NOTMAN FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(sToD(sDataQry), 2)) + "' AND Z0IA.Z0I_FILIAL = '" + FWxFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = SB8.B8_LOTECTL) AS NOTMD2 " + ENTER
            cQryCur += "       ,(SELECT Z0IA.Z0I_NOTTAR FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(sToD(sDataQry), 2)) + "' AND Z0IA.Z0I_FILIAL = '" + FWxFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = SB8.B8_LOTECTL) AS NOTTD2 " + ENTER
            cQryCur += "       ,(SELECT Z0IA.Z0I_NOTNOI FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + DTOS(DaySub(sToD(sDataQry), 2)) + "' AND Z0IA.Z0I_FILIAL = '" + FWxFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = SB8.B8_LOTECTL) AS NOTND2 " + ENTER
            cQryCur += "       ,(SELECT Z05A.Z05_DIETA  FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + sDataQry + "' AND Z05A.Z05_FILIAL = '" + FWxFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_CURRAL = Z08.Z08_CODIGO) AS DIETD1 " + ENTER
            cQryCur += "       ,(SELECT Z05A.Z05_KGMSDI FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + sDataQry + "' AND Z05A.Z05_FILIAL = '" + FWxFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_CURRAL = Z08.Z08_CODIGO) AS  KGMSD1" + ENTER
            cQryCur += "       ,(SELECT Z05A.Z05_CMSPN  FROM " + RetSqlName("Z05") +  " Z05A WHERE Z05A.Z05_DATA  = '" + sDataQry + "' AND Z05A.Z05_FILIAL = '" + FWxFilial("Z05") + "' AND Z05A.D_E_L_E_T_ <> '*' AND Z05A.Z05_LOTE = SB8.B8_LOTECTL AND Z05A.Z05_CURRAL = Z08.Z08_CODIGO) AS  CMSPV1" + ENTER
            cQryCur += "       ,(SELECT Z0IA.Z0I_NOTMAN FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + sDataQry + "' AND Z0IA.Z0I_FILIAL = '" + FWxFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = SB8.B8_LOTECTL) AS NOTMD1 " + ENTER
            cQryCur += "       ,(SELECT Z0IA.Z0I_NOTTAR FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + sDataQry + "' AND Z0IA.Z0I_FILIAL = '" + FWxFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = SB8.B8_LOTECTL) AS NOTTD1 " + ENTER
            cQryCur += "       ,(SELECT Z0IA.Z0I_NOTNOI FROM " + RetSqlName("Z0I") +  " Z0IA WHERE Z0IA.Z0I_DATA  = '" + sDataQry + "' AND Z0IA.Z0I_FILIAL = '" + FWxFilial("Z0I") + "' AND Z0IA.D_E_L_E_T_ <> '*' AND Z0IA.Z0I_LOTE = SB8.B8_LOTECTL) AS NOTND1 " + ENTER
            cQryCur += " FROM       " + RetSqlName("SB8") +  " SB8 " + ENTER
            cQryCur += " RIGHT JOIN " + RetSqlName("Z08") +  " Z08 ON Z08.Z08_CODIGO = SB8.B8_X_CURRA AND Z08.Z08_FILIAL = '" + FWxFilial("Z08") + "' AND Z08.D_E_L_E_T_ <> '*' " + ENTER
            cQryCur += " WHERE SB8.D_E_L_E_T_ <> '*' AND SB8.B8_X_CURRA <> '' AND SB8.B8_FILIAL = '" + FWxFilial("SB8") + "' " + ENTER
            cQryCur += "   AND SB8.B8_SALDO > 0 " + ENTER
            cQryCur += " GROUP BY Z08.Z08_LINHA, Z08.Z08_SEQUEN, SB8.B8_X_CURRA, SB8.B8_LOTECTL, Z08.Z08_CODIGO " + ENTER
            cQryCur += " ORDER BY Z08.Z08_CODIGO--Z08.Z08_LINHA, Z08.Z08_SEQUEN, SB8.B8_LOTECTL " + ENTER

            MPSysOpenQuery( cQryCur, "QRYCUR" )

            DBSelectArea("Z0I")
            Z0I->(DBSetOrder(1))

            nZ0I_CODIGO := 0
            While (!(QRYCUR->(EOF())))

                If !Empty(QRYCUR->CURRAL)
                    If (nPos := aScan( oResult:Currais, { |x|;
                            AllTrim(x:CURRAL) + AllTrim(x:LOTE) == AllTrim(QRYCUR->CURRAL) + AllTrim(QRYCUR->LOTE) } ) ) == 0

                        ConOut("Registro nao encontrado na lista de currais")
                    Else

                        If !Empty(QRYCUR->CURRAL)
                            /* Fonte da nota de cocho new : VAPCPA16  */
                            Z0I->(DBSetOrder( 3 ))
                            lInclui := !Z0I->(DBSeek( oResult:Currais[ nPos ]:FILIAL + QRYCUR->LOTE + sDataRec))

                            RecLock("Z0I", lInclui)

                            Z0I->Z0I_FILIAL := oResult:Currais[ nPos ]:FILIAL // FWxFilial("Z0I")
                            Z0I->Z0I_DATA   := sToD(sDataRec)
                            Z0I->Z0I_CURRAL := QRYCUR->CURRAL
                            Z0I->Z0I_LOTE   := QRYCUR->LOTE

                            Z0I->Z0I_RUA    := QRYCUR->LINHA
                            Z0I->Z0I_SEQUEN := QRYCUR->SEQ
                            Z0I->Z0I_CODIGO := StrZero( ++nZ0I_CODIGO, TamSx3('Z0I_CODIGO')[1])

                            Z0I->Z0I_TOTPRE := QRYCUR->TOTAPR
                            Z0I->Z0I_TOTREA := QRYCUR->TOTREA
                            Z0I->Z0I_DATLOG := cToD( Left(oResult:DATA, 10) )
                            Z0I->Z0I_HORLOG := cHora
                            // Z0I->Z0I_NOTMAN := Space(6)
                            // se diferente de null, entao atualiza campo
                            If ValType( oResult:Currais[ nPos ]:NOTA_MANHA ) == "C"
                                Z0I->Z0I_NOTMAN := oResult:Currais[ nPos ]:NOTA_MANHA
                            EndIf
                            // Z0I->Z0I_NOTNOI := Space(6)
                            /* 
                                Igor Oliveira - 2023-10-16
                                Ajuste solicitado pelo Toshio.
                                Colocar as notas de cocho da noite no campo Z0I_NOTTAR - NOTA TARDE
                            */
                            If ValType( oResult:Currais[ nPos ]:NOTA_NOITE ) == "C"
                                Z0I->Z0I_NOTTAR := oResult:Currais[ nPos ]:NOTA_NOITE
                            EndIf
                            If ValType( oResult:Currais[ nPos ]:AJUSTE ) == "C"
                                Z0I->Z0I_AJUSTE := Val( oResult:Currais[ nPos ]:AJUSTE )
                            EndIf
                            // Z0I->Z0I_NOTTAR := Space(6)
                        EndIf

                        Z0I->(MsUnlock())
                    EndIf
                EndIf

                QRYCUR->(DBSkip())

            EndDo

            QRYCUR->(DBCloseArea())

        EndIf

        MBSaveLog():FULLWrite(, .F.,;
            "Json Recebido: " + __cTxt,;
            /* cEmpLog */, /* cFilLog */, /* cRootLog */ )

        ZWS->ZWS_CHVPRO := Z0I->Z0I_FILIAL + DtoS(Z0I->Z0I_DATA) //  Z0I->Z0I_CODIGO
        ZWS->ZWS_TABELA := "Z0I"
        ZWS->ZWS_RESULT	:= ZWS->ZWS_RESULT + ENTER + __TRACO__ + ENTER + __cTxt
        // EndIf

        ZWS->ZWS_STATUS := "O" // O=OK
        ZWS->(MsUnlock())

        UnLockByName(cSemaforo,.F., .F., .T.)
        lErro := .F.

    EndTran()
    CatchException Using oException

    RecLock( "ZWS", .F. )
    ZWS->ZWS_RESULT	:= ZWS->ZWS_RESULT + ENTER + __TRACO__ + ENTER + __cTxt
    ZWS->ZWS_STATUS := "E" // E=Erro
    ZWS->(MsUnlock())

    DisarmTransaction() // cancelar operacao, nao grava szg, szh
    ConOut('Erro ao integrar ZWS: ' + oException:Description )
    MsgAlert('Erro ao integrar ZWS: ' + oException:Description )
    EndException

    ConOut("Fim - " + FunName() + ": " + Time() + " Tempo de Processamento: " + ElapTime( nInicio, Time()) )
    RestArea(aArea)
Return lErro
