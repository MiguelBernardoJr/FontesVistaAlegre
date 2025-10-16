#INCLUDE "TOTVS.CH"

/*
    MB : 29/08/2025
        -> Atualizar Tabela Z0O
*/
User Function VATRTMB1( cLote ) // U_VATRTMB1( '1-40' ) // U_VATRTMB1()

    Local cAliasF      := GetNextAlias()
    Local cZ0OAlias    := ""
    Local _cQry        := ""
    Local cCopy        := {}
    Local lDivergencia := .F.
    Local nI           := 0
    Local nCMS_Prev    := 0
    Local nGordura     := 0

    Default cLote      := ""

    If Type("cFilAnt") == "C" .and. TCIsConnected()
        ConOut("Ambiente Protheus aberto e pronto para uso")
    Else
        RpcSetEnv( "01", "0101001" ) //Abro o ambiente, pois o mesmo não encontrava-se aberto
        ConOut("Setando ambiente")
        cEmpAnt:= FWCodEmp()
    EndIf
    ConOut("Empresa logada: " + cEmpAnt)

    nCMS_Prev    := GetMV( 'MB_CMDPREV' ,, 2.1)
    nGordura     := GetMV( 'MB_GORDURA' ,, 27)

    // 2a. versao
    _cQry := ""
    _cQry += " WITH PorLote AS ( " + CRLF
    _cQry += "    SELECT  " + CRLF
    _cQry += "      SB8.B8_FILIAL AS Filial,  " + CRLF
    _cQry += "      SB8.B8_X_CURRA AS Curral,  " + CRLF
    _cQry += "      SB8.B8_LOTECTL AS LOTE,  " + CRLF
    _cQry += "      SUM(SB8.B8_SALDO) AS TotalQtde " + CRLF
    _cQry += "    FROM " + RetSqlName('SB8') + " (NOLOCK) SB8  " + CRLF
    _cQry += "    JOIN " + RetSqlName('SB1') + " (NOLOCK) SB1   " + CRLF
    _cQry += "      ON SB1.B1_COD      = SB8.B8_PRODUTO  " + CRLF
    _cQry += "     AND SB1.D_E_L_E_T_ = ' '  " + CRLF
    _cQry += "    WHERE SB8.D_E_L_E_T_ = ' '  " + CRLF
    _cQry += "      AND SB8.B8_LOTECTL IN (  " + CRLF
    _cQry += "          SELECT DISTINCT B8_LOTECTL  " + CRLF
    _cQry += "          FROM " + RetSqlName('SB8') + " (NOLOCK) SB8  " + CRLF
    _cQry += "          WHERE B8_X_CURRA <> ' '  " + CRLF
    _cQry += "            AND B8_SALDO > 0  " + CRLF
    _cQry += "            AND D_E_L_E_T_ = ' '  " + CRLF
    _cQry += "      )  " + CRLF
    _cQry += "    GROUP BY B8_FILIAL, SB8.B8_X_CURRA, SB8.B8_LOTECTL " + CRLF
    _cQry += " ),  " + CRLF
    _cQry += " DadosPrincipais AS ( " + CRLF
    _cQry += "    -- Pega os dados do registro com maior B8_SALDO por lote " + CRLF
    _cQry += "    SELECT  " + CRLF
    _cQry += "      SB8.B8_FILIAL AS Filial, " + CRLF
    _cQry += "      SB8.B8_X_CURRA AS Curral, " + CRLF
    _cQry += "      SB8.B8_LOTECTL AS LOTE, " + CRLF
    _cQry += "      SB8.B8_XDATACO, " + CRLF
    _cQry += "      SB8.B8_XPESOCO AS PesoMedio, " + CRLF
    _cQry += "      SB1.B1_X_SEXO AS Sexo, " + CRLF
    _cQry += "      SB1.B1_XRACA AS Raca, " + CRLF
    _cQry += "      ROW_NUMBER() OVER (PARTITION BY SB8.B8_LOTECTL ORDER BY SB8.B8_SALDO DESC) AS rn " + CRLF
    _cQry += "    FROM " + RetSqlName('SB8') + " (NOLOCK) SB8  " + CRLF
    _cQry += "    JOIN " + RetSqlName('SB1') + " (NOLOCK) SB1   " + CRLF
    _cQry += "      ON SB1.B1_COD = SB8.B8_PRODUTO  " + CRLF
    _cQry += "     AND SB1.D_E_L_E_T_ = ' '  " + CRLF
    _cQry += "    WHERE SB8.D_E_L_E_T_ = ' '  " + CRLF
    _cQry += "      AND SB8.B8_LOTECTL IN (  " + CRLF
    _cQry += "          SELECT DISTINCT B8_LOTECTL  " + CRLF
    _cQry += "          FROM " + RetSqlName('SB8') + " (NOLOCK) SB8  " + CRLF
    _cQry += "          WHERE B8_X_CURRA <> ' '  " + CRLF
    _cQry += "            AND B8_SALDO > 0  " + CRLF
    _cQry += "            AND D_E_L_E_T_ = ' '  " + CRLF
    _cQry += "      ) " + CRLF
    _cQry += " ), " + CRLF
    _cQry += " SB8_CTE AS (  " + CRLF
    _cQry += "    SELECT   " + CRLF
    _cQry += "      p.Filial,  " + CRLF
    _cQry += "      dp.Curral,  " + CRLF
    _cQry += "      p.LOTE,  " + CRLF
    _cQry += "      dp.Sexo,  " + CRLF
    _cQry += "      dp.Raca,  " + CRLF
    _cQry += "      p.TotalQtde AS QtdeAnimais,  " + CRLF
    _cQry += "      dp.B8_XDATACO, " + CRLF
    _cQry += "      ROUND(dp.PesoMedio, 2) AS PesoMedioInicial  " + CRLF
    _cQry += "    FROM PorLote p  " + CRLF
    _cQry += "    INNER JOIN DadosPrincipais dp   " + CRLF
    _cQry += "      ON p.LOTE = dp.LOTE  " + CRLF
    _cQry += "      AND dp.rn = 1  -- Pega apenas o registro com maior B8_SALDO " + CRLF
    _cQry += " )  " + CRLF
    _cQry += " --SELECT * FROM SB8_CTE  " + CRLF
    _cQry += " , BASE AS (  " + CRLF
    _cQry += "          SELECT DISTINCT  " + CRLF
    _cQry += "          sb.Filial,  " + CRLF
    _cQry += "          sb.Curral,  " + CRLF
    _cQry += "          sb.LOTE,  " + CRLF
    _cQry += "          Sexo,  " + CRLF
    _cQry += "          Raca,  " + CRLF
    _cQry += "          B8_XDATACO, " + CRLF
    _cQry += "          sb.PesoMedioInicial,  " + CRLF
    _cQry += "         --  ROUND(   " + CRLF
    _cQry += "         --              (" + cValToChar(nCMS_Prev) + "/100)  " + CRLF
    _cQry += "         --              *   " + CRLF
    _cQry += "         --              ROUND(  " + CRLF
    _cQry += "         --                  (sb.PesoMedioInicial +   " + CRLF
    _cQry += "         --                  ((509.6 + (0.4697 * (sb.PesoMedioInicial * 0.96)) - (46.54 * ROUND(CASE WHEN sb.Sexo IN ('MACHO','INTEIRO') THEN -0.12 ELSE 0 END + 1.33 + (0.0036 * (sb.PesoMedioInicial * 0.96)),6))) * (" + cValToChar(nGordura/100) + "/0.28) +  " + CRLF
    _cQry += "         --                  CASE  " + CRLF
    _cQry += "         --                     CASE  " + CRLF
    _cQry += "         --                     WHEN sb.PesoMedioInicial = 0 THEN 0  " + CRLF
    _cQry += "         --                     WHEN sb.PesoMedioInicial/30.0 <= 11 THEN 4  " + CRLF
    _cQry += "         --                     WHEN sb.PesoMedioInicial/30.0 <= 13 THEN 5  " + CRLF
    _cQry += "         --                     WHEN sb.PesoMedioInicial/30.0 <= 15 THEN 6  " + CRLF
    _cQry += "         --                     WHEN sb.PesoMedioInicial/30.0 <= 17 THEN 7  " + CRLF
    _cQry += "         --                     ELSE 8  " + CRLF
    _cQry += "         --                 END   " + CRLF
    _cQry += "         --                 WHEN 4 THEN -33.2  " + CRLF
    _cQry += "         --                 WHEN 5 THEN 0  " + CRLF
    _cQry += "         --                 WHEN 6 THEN 33.2  " + CRLF
    _cQry += "         --                 WHEN 7 THEN 66.4  " + CRLF
    _cQry += "         --                 WHEN 8 THEN 99.6  " + CRLF
    _cQry += "         --                 END )  " + CRLF
    _cQry += "         --                  ) / 2.0  " + CRLF
    _cQry += "         --              ,2)  " + CRLF
    _cQry += "         --              * sg.G1_ENERG, 2) AS KgMcalPrevisao,  " + CRLF
    _cQry += "         sg.G1_ENERG, " + CRLF
    _cQry += "  " + CRLF
    _cQry += "          CASE  " + CRLF
    _cQry += "              WHEN sb.PesoMedioInicial = 0 THEN 0  " + CRLF
    _cQry += "              WHEN sb.PesoMedioInicial/30.0 <= 11 THEN 4  " + CRLF
    _cQry += "              WHEN sb.PesoMedioInicial/30.0 <= 13 THEN 5  " + CRLF
    _cQry += "              WHEN sb.PesoMedioInicial/30.0 <= 15 THEN 6  " + CRLF
    _cQry += "              WHEN sb.PesoMedioInicial/30.0 <= 17 THEN 7  " + CRLF
    _cQry += "              ELSE 8  " + CRLF
    _cQry += "          END AS Tamanho,  " + CRLF
    _cQry += "  " + CRLF
    _cQry += "          ROUND(  " + CRLF
    _cQry += "                  CASE WHEN sb.Sexo IN ('MACHO','INTEIRO')   " + CRLF
    _cQry += "                  THEN -0.12   " + CRLF
    _cQry += "                  ELSE 0   " + CRLF
    _cQry += "                  END   " + CRLF
    _cQry += "                  + 1.33 + (0.0036 * (sb.PesoMedioInicial * 0.96))  " + CRLF
    _cQry += "          , 2) AS FS,  " + CRLF
    _cQry += "          ROUND(  " + CRLF
    _cQry += "              CASE  " + CRLF
    _cQry += "              WHEN sb.Sexo = 'FEMEA' THEN  " + CRLF
    _cQry += "                  (  " + CRLF
    _cQry += "                  (  " + CRLF
    _cQry += "                      551.5  " + CRLF
    _cQry += "                      - 0.2482 * (sb.PesoMedioInicial * 0.96)  " + CRLF
    _cQry += "                      + 0.00119 * POWER(sb.PesoMedioInicial * 0.96, 2)  " + CRLF
    _cQry += "                      - 39.84 * ROUND(CASE WHEN sb.Sexo IN ('MACHO','INTEIRO') THEN -0.12 ELSE 0 END + 1.33 + (0.0036 * (sb.PesoMedioInicial * 0.96)),6)  " + CRLF
    _cQry += "                  )  " + CRLF
    _cQry += "                  * (" + cValToChar(nGordura/100) + " / 0.28)  " + CRLF
    _cQry += "                  )  " + CRLF
    _cQry += "              WHEN sb.Sexo IN ( 'MACHO', 'INTEIRO', 'CAPAO','CASTRADO' ) THEN  " + CRLF
    _cQry += "                  (  " + CRLF
    _cQry += "                  (  " + CRLF
    _cQry += "                      509.6  " + CRLF
    _cQry += "                      + 0.4697 * (sb.PesoMedioInicial * 0.96)  " + CRLF
    _cQry += "                      - 46.54 * ROUND(CASE WHEN sb.Sexo IN ('MACHO','INTEIRO') THEN -0.12 ELSE 0 END + 1.33 + (0.0036 * (sb.PesoMedioInicial * 0.96)),6)  " + CRLF
    _cQry += "                  )  " + CRLF
    _cQry += "                  * (" + cValToChar(nGordura/100) + " / 0.28)  " + CRLF
    _cQry += "                  )  " + CRLF
    _cQry += "              ELSE  " + CRLF
    _cQry += "                  NULL  " + CRLF
    _cQry += "              END  " + CRLF
    _cQry += "              +  " + CRLF
    _cQry += "              CASE  " + CRLF
    _cQry += "                 CASE  " + CRLF
    _cQry += "                 WHEN sb.PesoMedioInicial = 0 THEN 0  " + CRLF
    _cQry += "                 WHEN sb.PesoMedioInicial/30.0 <= 11 THEN 4  " + CRLF
    _cQry += "                 WHEN sb.PesoMedioInicial/30.0 <= 13 THEN 5  " + CRLF
    _cQry += "                 WHEN sb.PesoMedioInicial/30.0 <= 15 THEN 6  " + CRLF
    _cQry += "                 WHEN sb.PesoMedioInicial/30.0 <= 17 THEN 7  " + CRLF
    _cQry += "                 ELSE 8  " + CRLF
    _cQry += "             END   " + CRLF
    _cQry += "             WHEN 4 THEN -33.2  " + CRLF
    _cQry += "             WHEN 5 THEN 0  " + CRLF
    _cQry += "             WHEN 6 THEN 33.2  " + CRLF
    _cQry += "             WHEN 7 THEN 66.4  " + CRLF
    _cQry += "             WHEN 8 THEN 99.6  " + CRLF
    _cQry += "             END   " + CRLF
    _cQry += "          , 2) AS PesoFinalPrevisto,  " + CRLF
    _cQry += "  " + CRLF
    _cQry += "         --  ROUND(  " + CRLF
    _cQry += "         --      (sb.PesoMedioInicial +   " + CRLF
    _cQry += "         --      ((509.6 + (0.4697 * (sb.PesoMedioInicial * 0.96)) - (46.54 * ROUND(CASE WHEN sb.Sexo IN ('MACHO','INTEIRO') THEN -0.12 ELSE 0 END + 1.33 + (0.0036 * (sb.PesoMedioInicial * 0.96)),6))) * (" + cValToChar(nGordura/100) + "/0.28) +  " + CRLF
    _cQry += "         --      CASE  " + CRLF
    _cQry += "         --         CASE  " + CRLF
    _cQry += "         --         WHEN sb.PesoMedioInicial = 0 THEN 0  " + CRLF
    _cQry += "         --         WHEN sb.PesoMedioInicial/30.0 <= 11 THEN 4  " + CRLF
    _cQry += "         --         WHEN sb.PesoMedioInicial/30.0 <= 13 THEN 5  " + CRLF
    _cQry += "         --         WHEN sb.PesoMedioInicial/30.0 <= 15 THEN 6  " + CRLF
    _cQry += "         --         WHEN sb.PesoMedioInicial/30.0 <= 17 THEN 7  " + CRLF
    _cQry += "         --         ELSE 8  " + CRLF
    _cQry += "         --     END   " + CRLF
    _cQry += "         --     WHEN 4 THEN -33.2  " + CRLF
    _cQry += "         --     WHEN 5 THEN 0  " + CRLF
    _cQry += "         --     WHEN 6 THEN 33.2  " + CRLF
    _cQry += "         --     WHEN 7 THEN 66.4  " + CRLF
    _cQry += "         --     WHEN 8 THEN 99.6  " + CRLF
    _cQry += "         --     END )  " + CRLF
    _cQry += "         --      ) / 2.0  " + CRLF
    _cQry += "         --  ,2) AS PesoMedio, " + CRLF
    _cQry += "          G1_ENERG AS Energia  " + CRLF
    _cQry += "          FROM SB8_CTE AS sb " + CRLF
    _cQry += "          INNER JOIN " + RetSqlName('SG1') + " (NOLOCK) AS sg  " + CRLF
    _cQry += "              ON sg.G1_COD = 'FINAL' " + CRLF
    _cQry += "             AND sg.D_E_L_E_T_ = ' '  " + CRLF
    _cQry += "          WHERE sb.LOTE IN ( " + CRLF
    _cQry += "              SELECT DISTINCT B8_LOTECTL  " + CRLF
    _cQry += "              FROM " + RetSqlName('SB8') + " (NOLOCK) SB8  " + CRLF
    _cQry += "              WHERE B8_X_CURRA <> ' '  " + CRLF
    _cQry += "                AND B8_SALDO > 0  " + CRLF
    _cQry += "                AND D_E_L_E_T_ = ' '  " + CRLF
    _cQry += "          )  " + CRLF
    _cQry += " ) , " + CRLF
    _cQry += " --SELECT * FROM SB8_CTE WHERE LOTE = '113-33' " + CRLF
    _cQry += " Calc AS ( " + CRLF
    _cQry += " SELECT   " + CRLF
    _cQry += "          rTrim(Filial) AS FILIAL,   " + CRLF
    _cQry += "          rTrim(Curral) AS CURRAL,   " + CRLF
    _cQry += "          rTrim(LOTE)   AS LOTE,   " + CRLF
    _cQry += "          CASE   " + CRLF
    _cQry += "              WHEN rTrim(Sexo) = 'MACHO'  THEN 'Inteiro'  " + CRLF
    _cQry += "              WHEN rTrim(Sexo) = 'FEMEA'  THEN 'Femea'  " + CRLF
    _cQry += "              WHEN rTrim(Sexo) = 'CAPAO'  THEN 'Castrado'  " + CRLF
    _cQry += "              ELSE 'OUTRO'  " + CRLF
    _cQry += "          END AS SEXO,  " + CRLF
    _cQry += "          rTrim(Raca) as Raca, " + CRLF
    _cQry += "          B8_XDATACO, " + CRLF
    _cQry += "          PesoMedioInicial AS B8_XPESOCO_PesoMedioInicial,   " + CRLF
    _cQry += "          PesoFinalPrevisto AS Z0O_PESOPR_PesoFinalPrevisto,  " + CRLF
    _cQry += "           " + CRLF
    _cQry += "          Round( (PesoMedioInicial+PesoFinalPrevisto)/2, 2) " + CRLF
    _cQry += "          -- PesoMedio AS  " + CRLF
    _cQry += "          Z0O_PESO_PesoMedio,  " + CRLF
    _cQry += "          -- KgMcalPrevisao AS  " + CRLF
    _cQry += "         Round( (" + cValToChar(nCMS_Prev) + "/100) * (PesoMedioInicial+PesoFinalPrevisto)/2  * G1_ENERG, 2) " + CRLF
    _cQry += "          Z0O_MCALPR_KgMcalPrevisao,   " + CRLF
    _cQry += "          Tamanho AS Z0O_TAMCAR_Tamanho,   " + CRLF
    _cQry += "          FS AS Z0O_FS,  " + CRLF
    _cQry += "          Energia  " + CRLF
    _cQry += " FROM BASE   " + CRLF
    _cQry += " -- WHERE LOTE = '113-33'  " + CRLF
    _cQry += " ),  " + CRLF
    _cQry += " Divergencias AS ( " + CRLF
    _cQry += "   SELECT " + CRLF
    _cQry += "     c.FILIAL, " + CRLF
    _cQry += "     c.CURRAL, " + CRLF
    _cQry += "     c.LOTE, " + CRLF
    _cQry += "     c.SEXO, " + CRLF
    _cQry += "     c.Raca, " + CRLF
    _cQry += "     c.B8_XDATACO, " + CRLF
    _cQry += "     c.B8_XPESOCO_PesoMedioInicial, " + CRLF
    _cQry += "     z.Z0O_PESOIN PESOIN_Z0O, " + CRLF
    _cQry += "     c.Z0O_PESOPR_PesoFinalPrevisto, " + CRLF
    _cQry += "     ISNULL(z.Z0O_PESOPR, 0) AS PESOPR_Z0O, " + CRLF
    _cQry += "     c.Z0O_PESO_PesoMedio, " + CRLF
    _cQry += "     ISNULL( z.Z0O_PESO, 0) AS PESO_Z0O, " + CRLF
    _cQry += "     c.Z0O_MCALPR_KgMcalPrevisao, " + CRLF
    _cQry += "     ISNULL( z.Z0O_MCALPR, 0) AS MCALPR_Z0O, " + CRLF
    _cQry += "     c.Z0O_TAMCAR_Tamanho, " + CRLF
    _cQry += "     ISNULL( z.Z0O_TAMCAR, 0) AS TAMCAR_Z0O, " + CRLF
    _cQry += "     c.Z0O_FS, " + CRLF
    _cQry += "     ISNULL( z.Z0O_FS, 0 ) AS FS_Z0O, " + CRLF
    _cQry += "     c.Energia, " + CRLF
    _cQry += "     ISNULL( z.Z0O_ENERGI, 0) AS ENERGI_Z0O, " + CRLF
    _cQry += "     z.Z0O_CMSPRE " + CRLF
    _cQry += "   FROM Calc c " + CRLF
    _cQry += "   LEFT JOIN " + RetSqlName('Z0O') + " z " + CRLF
    _cQry += "       ON RTRIM(c.LOTE) = RTRIM(z.Z0O_LOTE) " + CRLF
    _cQry += "      AND z.Z0O_LOTE + CAST(z.R_E_C_N_O_ AS VARCHAR) " + CRLF
    _cQry += "          IN ( SELECT z2.Z0O_LOTE + CAST(MAX(z2.R_E_C_N_O_) AS VARCHAR) CHAVE " + CRLF
    _cQry += "               FROM " + RetSqlName('Z0O') + " z2 " + CRLF
    _cQry += "               WHERE z2.D_E_L_E_T_ = ' ' " + CRLF
    _cQry += "               GROUP BY z2.Z0O_LOTE " + CRLF
    _cQry += "             ) " + CRLF
    _cQry += "     AND z.D_E_L_E_T_ = ' ' " + CRLF
    _cQry += "   WHERE  " + CRLF
    _cQry += "        ISNULL(c.B8_XPESOCO_PesoMedioInicial, 0)  <> ISNULL(z.Z0O_PESOIN, 0) " + CRLF
    _cQry += "     OR ISNULL(c.Z0O_PESOPR_PesoFinalPrevisto, 0) <> ISNULL(z.Z0O_PESOPR, 0) " + CRLF
    _cQry += "     OR ISNULL(c.Z0O_PESO_PesoMedio, 0)           <> ISNULL(z.Z0O_PESO, 0) " + CRLF
    _cQry += "     OR ISNULL(c.Z0O_MCALPR_KgMcalPrevisao, 0)    <> ISNULL(z.Z0O_MCALPR, 0) " + CRLF
    _cQry += "     OR ISNULL(c.Z0O_TAMCAR_Tamanho, 0)           <> ISNULL(z.Z0O_TAMCAR, 0) " + CRLF
    _cQry += "     OR ISNULL(c.Z0O_FS, 0)                       <> ISNULL(z.Z0O_FS, 0) " + CRLF
    _cQry += "     OR ISNULL(c.Energia, 0)                      <> ISNULL(z.Z0O_ENERGI, 0) " + CRLF
    _cQry += "     OR " + cValToChar( nCMS_Prev ) + "           <> ISNULL(z.Z0O_CMSPRE, 0) " + CRLF
    _cQry += " ) " + CRLF
    _cQry += " SELECT * FROM Divergencias " + CRLF

    If !Empty( cLote ) // // U_VATRTMB1('1-40      ')
        _cQry += " WHERE LOTE = '" + cLote + "' " + CRLF
    EndIf

    _cQry += " ORDER BY FILIAL, CURRAL, LOTE " + CRLF
    // _cQry += " ORDER BY 1, 2 "

    // dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAliasF),.F.,.F.)  // U_VATRTMB1()
    // MsAguarde({|| MPSysOpenQuery( _cQry, cAliasF,, "TOPCONN")}, "Executando consulta SQL...")
    MsAguarde({|| MPSysOpenQuery( _cQry, cAliasF)}, "Executando consulta SQL...")

    While !(cAliasF)->(EOF())

        // cHtml += "<tr><td>" + (cAliasF)->FILIAL + "</td><td>" + (cAliasF)->CURRAL + "</td><td>" + (cAliasF)->LOTE + "</td></tr>"

        _cQry := ""+;
            " SELECT 		R_E_C_N_O_  RECNO, *  " + CRLF +;
            " FROM 		" + RetSqlName('Z0O') + CRLF +;
            " WHERE     	D_E_L_E_T_ = ' ' AND  " + CRLF +;
            "   			Z0O_LOTE + CAST(R_E_C_N_O_ AS VARCHAR) IN ( " + CRLF +;
            " 			SELECT 		Z0O_LOTE +  " + CRLF +;
            " 						CAST(MAX(R_E_C_N_O_ ) AS VARCHAR) CHAVE  " + CRLF +;
            " 						-- Z0O_LOTE, MAX(R_E_C_N_O_ ) RECNO, " + CRLF +;
            " 			FROM 		" + RetSqlName('Z0O') + CRLF +;
            " 			WHERE     	 " + CRLF +;
            " 						Z0O_LOTE = '" + (cAliasF)->LOTE + "' AND " + CRLF +;
            " 						D_E_L_E_T_ = ' ' " + CRLF +;
            " 			GROUP BY 	Z0O_LOTE " + CRLF +;
            " ) "
        cZ0OAlias    := GetNextAlias()
        dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cZ0OAlias),.F.,.F.)

        If !(cZ0OAlias)->(EOF())

            Z0O->(DbGoTo( (cZ0OAlias)->RECNO ))

            lDivergencia := Z0O->Z0O_PESOIN <> (cAliasF)->B8_XPESOCO_PesoMedioInicial .OR.;
                Z0O->Z0O_ENERGI <> (cAliasF)->Energia .OR.;
                Z0O->Z0O_CMSPRE <> nCMS_Prev
            If lDivergencia

                cCopy :={}
                For nI := 1 to Z0O->(fCount())
                    aAdd( cCopy, { Z0O->(FieldName( nI )), Z0O->(FieldGet(nI)) } )
                Next nI

                // Atualizar tabela atual, para na sequencia abrir a proxima
                RecLock( 'Z0O', .F.)
                If Empty( Z0O->Z0O_DATATR )
                    Z0O->Z0O_DATATR := dDataBase
                EndIf
                Z0O->(MsUnLock())

                // U_VATRTMB1() // U_VATRTMB1( '1-40' )
                RecLock( 'Z0O', .T.)
                For nI := 1 to Len(cCopy) // Z0O->(fCount())
                    Z0O->&(cCopy[ nI, 01 ]) := cCopy[ nI, 02 ]
                Next nI
                Z0O->Z0O_DATAIN := dDataBase+1
                Z0O->Z0O_DATATR := sToD("")
                Z0O->Z0O_PESOPR := (cAliasF)->Z0O_PESOPR_PesoFinalPrevisto
                Z0O->Z0O_PESO   := (cAliasF)->Z0O_PESO_PesoMedio
                Z0O->Z0O_MCALPR := (cAliasF)->Z0O_MCALPR_KgMcalPrevisao
                Z0O->Z0O_TAMCAR := (cAliasF)->Z0O_TAMCAR_Tamanho
                Z0O->Z0O_FS     := (cAliasF)->Z0O_FS
                Z0O->Z0O_PESOIN := (cAliasF)->B8_XPESOCO_PesoMedioInicial
                Z0O->Z0O_ENERGI := (cAliasF)->Energia
                Z0O->Z0O_CMSPRE := nCMS_Prev
                Z0O->(MsUnLock())

            EndIf

        Else

            // U_VATRTMB1()      // U_VATRTMB1( '1-40' )
            RecLock( 'Z0O', .T.)
            Z0O->Z0O_FILIAL := xFilial('Z0O')
            Z0O->Z0O_LOTE   := (cAliasF)->LOTE
            Z0O->Z0O_DATAIN := dDataBase
            Z0O->Z0O_DATATR := sToD("")
            Z0O->Z0O_PESOPR := (cAliasF)->Z0O_PESOPR_PesoFinalPrevisto
            Z0O->Z0O_PESO   := (cAliasF)->Z0O_PESO_PesoMedio
            Z0O->Z0O_MCALPR := (cAliasF)->Z0O_MCALPR_KgMcalPrevisao
            Z0O->Z0O_TAMCAR := (cAliasF)->Z0O_TAMCAR_Tamanho
            Z0O->Z0O_FS     := (cAliasF)->Z0O_FS
            Z0O->Z0O_PESOIN := (cAliasF)->B8_XPESOCO_PesoMedioInicial
            Z0O->Z0O_ENERGI := (cAliasF)->Energia
            Z0O->Z0O_CMSPRE := nCMS_Prev
            Z0O->Z0O_CODPLA := "999999"
            Z0O->Z0O_DIAIN := "002"
            Z0O->Z0O_SEXO   := IIF( AllTrim((cAliasF)->SEXO) == "Inteiro", "M", IIF( AllTrim((cAliasF)->SEXO) == "Femea", "F", "C" ) )
            Z0O->Z0O_GORDUR := nGordura
            Z0O->Z0O_RACA   := (cAliasF)->Raca

            If AllTrim((cAliasF)->Raca) == "ANGUS"
                Z0O->Z0O_MCAPV := 6.23
            ElseIf AllTrim((cAliasF)->SEXO) == "Inteiro"
                Z0O->Z0O_MCAPV := 6.21
            Else // If AllTrim((cAliasF)->SEXO) == "Femea" ou Capao
                Z0O->Z0O_MCAPV := 6.25
            EndIf
            Z0O->Z0O_DCESP   := 100
            Z0O->Z0O_DTABAT  := STOD((cAliasF)->B8_XDATACO) + Z0O->Z0O_DCESP

            If AllTrim((cAliasF)->SEXO) == "Inteiro"
                Z0O->Z0O_GMD    := 1.6
            Else
                Z0O->Z0O_GMD    := 1.4
            EndIf

            Z0O->(MsUnLock())
        EndIf
        (cZ0OAlias)->(dbCloseArea())

        (cAliasF)->(dbSkip())
    EndDo

    (cAliasF)->(dbCloseArea())
Return nil
