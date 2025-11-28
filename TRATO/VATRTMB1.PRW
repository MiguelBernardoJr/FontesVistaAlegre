#INCLUDE "TOTVS.CH"

#IFNDEF _ENTER_
	#DEFINE _ENTER_ (Chr(13)+Chr(10))
	// Alert("miguel")
#ENDIF 

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
    Local lIsJob       := .T.

    Default cLote      := ""

    ConOut( Replicate("-", 100) )
    ConOut( "Inicio processamento fonte: VATRTMB1.PRW")

    If Type("cFilAnt") == "C" .and. TCIsConnected()
        ConOut("Ambiente Protheus aberto e pronto para uso")
        lIsJob := .F.
    Else
        RpcSetEnv( "01", "0101001" ) //Abro o ambiente, pois o mesmo não encontrava-se aberto
        ConOut("Setando ambiente")
        cEmpAnt:= FWCodEmp()
    EndIf
    ConOut("Empresa logada: " + cEmpAnt)
    ConOut("Variavel lIsJob: " + cValToChar(lIsJob))

    nCMS_Prev    := GetMV( 'MB_CMDPREV' ,, 2.1)
    nGordura     := GetMV( 'MB_GORDURA' ,, 27)

    // 2a. versao
    _cQry := ""
    _cQry += " WITH PorLote AS ( " + _ENTER_
    _cQry += "    SELECT  " + _ENTER_
    _cQry += "      SB8.B8_FILIAL AS Filial,  " + _ENTER_
    _cQry += "      SB8.B8_X_CURRA AS Curral,  " + _ENTER_
    _cQry += "      SB8.B8_LOTECTL AS LOTE,  " + _ENTER_
    _cQry += "      SUM(SB8.B8_SALDO) AS TotalQtde " + _ENTER_
    _cQry += "    FROM " + RetSqlName('SB8') + " (NOLOCK) SB8  " + _ENTER_
    _cQry += "    JOIN " + RetSqlName('SB1') + " (NOLOCK) SB1   " + _ENTER_
    _cQry += "      ON SB1.B1_COD      = SB8.B8_PRODUTO  " + _ENTER_
    _cQry += "     AND SB1.D_E_L_E_T_ = ' '  " + _ENTER_
    _cQry += "    WHERE SB8.D_E_L_E_T_ = ' '  " + _ENTER_
    _cQry += "      AND SB8.B8_LOTECTL IN (  " + _ENTER_
    _cQry += "          SELECT DISTINCT B8_LOTECTL  " + _ENTER_
    _cQry += "          FROM " + RetSqlName('SB8') + " (NOLOCK) SB8  " + _ENTER_
    _cQry += "          WHERE B8_X_CURRA <> ' '  " + _ENTER_
    _cQry += "            AND B8_SALDO > 0  " + _ENTER_
    _cQry += "            AND D_E_L_E_T_ = ' '  " + _ENTER_
    _cQry += "      )  " + _ENTER_
    _cQry += "    GROUP BY B8_FILIAL, SB8.B8_X_CURRA, SB8.B8_LOTECTL " + _ENTER_
    _cQry += " ),  " + _ENTER_
    _cQry += " DadosPrincipais AS ( " + _ENTER_
    _cQry += "    -- Pega os dados do registro com maior B8_SALDO por lote " + _ENTER_
    _cQry += "    SELECT  " + _ENTER_
    _cQry += "      SB8.B8_FILIAL AS Filial, " + _ENTER_
    _cQry += "      SB8.B8_X_CURRA AS Curral, " + _ENTER_
    _cQry += "      SB8.B8_LOTECTL AS LOTE, " + _ENTER_
    _cQry += "      SB8.B8_XDATACO, " + _ENTER_
    _cQry += "      SB8.B8_XPESOCO AS PesoMedio, " + _ENTER_
    _cQry += "      SB1.B1_X_SEXO AS Sexo, " + _ENTER_
    _cQry += "      SB1.B1_XRACA AS Raca, " + _ENTER_
    _cQry += "      ROW_NUMBER() OVER (PARTITION BY SB8.B8_LOTECTL ORDER BY SB8.B8_SALDO DESC) AS rn " + _ENTER_
    _cQry += "    FROM " + RetSqlName('SB8') + " (NOLOCK) SB8  " + _ENTER_
    _cQry += "    JOIN " + RetSqlName('SB1') + " (NOLOCK) SB1   " + _ENTER_
    _cQry += "      ON SB1.B1_COD = SB8.B8_PRODUTO  " + _ENTER_
    _cQry += "     AND SB1.D_E_L_E_T_ = ' '  " + _ENTER_
    _cQry += "    WHERE SB8.D_E_L_E_T_ = ' '  " + _ENTER_
    _cQry += "      AND SB8.B8_LOTECTL IN (  " + _ENTER_
    _cQry += "          SELECT DISTINCT B8_LOTECTL  " + _ENTER_
    _cQry += "          FROM " + RetSqlName('SB8') + " (NOLOCK) SB8  " + _ENTER_
    _cQry += "          WHERE B8_X_CURRA <> ' '  " + _ENTER_
    _cQry += "            AND B8_SALDO > 0  " + _ENTER_
    _cQry += "            AND D_E_L_E_T_ = ' '  " + _ENTER_
    _cQry += "      ) " + _ENTER_
    _cQry += " ), " + _ENTER_
    _cQry += " SB8_CTE AS (  " + _ENTER_
    _cQry += "    SELECT   " + _ENTER_
    _cQry += "      p.Filial,  " + _ENTER_
    _cQry += "      dp.Curral,  " + _ENTER_
    _cQry += "      p.LOTE,  " + _ENTER_
    _cQry += "      dp.Sexo,  " + _ENTER_
    _cQry += "      dp.Raca,  " + _ENTER_
    _cQry += "      p.TotalQtde AS QtdeAnimais,  " + _ENTER_
    _cQry += "      dp.B8_XDATACO, " + _ENTER_
    _cQry += "      ROUND(dp.PesoMedio, 2) AS PesoMedioInicial  " + _ENTER_
    _cQry += "    FROM PorLote p  " + _ENTER_
    _cQry += "    INNER JOIN DadosPrincipais dp   " + _ENTER_
    _cQry += "      ON p.LOTE = dp.LOTE  " + _ENTER_
    _cQry += "      AND dp.rn = 1  -- Pega apenas o registro com maior B8_SALDO " + _ENTER_
    _cQry += " )  " + _ENTER_
    _cQry += " --SELECT * FROM SB8_CTE  " + _ENTER_
    _cQry += " , BASE AS (  " + _ENTER_
    _cQry += "          SELECT DISTINCT  " + _ENTER_
    _cQry += "          sb.Filial,  " + _ENTER_
    _cQry += "          sb.Curral,  " + _ENTER_
    _cQry += "          sb.LOTE,  " + _ENTER_
    _cQry += "          Sexo,  " + _ENTER_
    _cQry += "          Raca,  " + _ENTER_
    _cQry += "          B8_XDATACO, " + _ENTER_
    _cQry += "          sb.PesoMedioInicial,  " + _ENTER_
    _cQry += "         --  ROUND(   " + _ENTER_
    _cQry += "         --              (" + cValToChar(nCMS_Prev) + "/100)  " + _ENTER_
    _cQry += "         --              *   " + _ENTER_
    _cQry += "         --              ROUND(  " + _ENTER_
    _cQry += "         --                  (sb.PesoMedioInicial +   " + _ENTER_
    _cQry += "         --                  ((509.6 + (0.4697 * (sb.PesoMedioInicial * 0.96)) - (46.54 * ROUND(CASE WHEN sb.Sexo IN ('MACHO','INTEIRO') THEN -0.12 ELSE 0 END + 1.33 + (0.0036 * (sb.PesoMedioInicial * 0.96)),6))) * (" + cValToChar(nGordura/100) + "/0.28) +  " + _ENTER_
    _cQry += "         --                  CASE  " + _ENTER_
    _cQry += "         --                     CASE  " + _ENTER_
    _cQry += "         --                     WHEN sb.PesoMedioInicial = 0 THEN 0  " + _ENTER_
    _cQry += "         --                     WHEN sb.PesoMedioInicial/30.0 <= 11 THEN 4  " + _ENTER_
    _cQry += "         --                     WHEN sb.PesoMedioInicial/30.0 <= 13 THEN 5  " + _ENTER_
    _cQry += "         --                     WHEN sb.PesoMedioInicial/30.0 <= 15 THEN 6  " + _ENTER_
    _cQry += "         --                     WHEN sb.PesoMedioInicial/30.0 <= 17 THEN 7  " + _ENTER_
    _cQry += "         --                     ELSE 8  " + _ENTER_
    _cQry += "         --                 END   " + _ENTER_
    _cQry += "         --                 WHEN 4 THEN -33.2  " + _ENTER_
    _cQry += "         --                 WHEN 5 THEN 0  " + _ENTER_
    _cQry += "         --                 WHEN 6 THEN 33.2  " + _ENTER_
    _cQry += "         --                 WHEN 7 THEN 66.4  " + _ENTER_
    _cQry += "         --                 WHEN 8 THEN 99.6  " + _ENTER_
    _cQry += "         --                 END )  " + _ENTER_
    _cQry += "         --                  ) / 2.0  " + _ENTER_
    _cQry += "         --              ,2)  " + _ENTER_
    _cQry += "         --              * sg.G1_ENERG, 2) AS KgMcalPrevisao,  " + _ENTER_
    _cQry += "         sg.G1_ENERG, " + _ENTER_
    _cQry += "  " + _ENTER_
    _cQry += "          CASE  " + _ENTER_
    _cQry += "              WHEN sb.PesoMedioInicial = 0 THEN 0  " + _ENTER_
    _cQry += "              WHEN sb.PesoMedioInicial/30.0 <= 11 THEN 4  " + _ENTER_
    _cQry += "              WHEN sb.PesoMedioInicial/30.0 <= 13 THEN 5  " + _ENTER_
    _cQry += "              WHEN sb.PesoMedioInicial/30.0 <= 15 THEN 6  " + _ENTER_
    _cQry += "              WHEN sb.PesoMedioInicial/30.0 <= 17 THEN 7  " + _ENTER_
    _cQry += "              ELSE 8  " + _ENTER_
    _cQry += "          END AS Tamanho,  " + _ENTER_
    _cQry += "  " + _ENTER_
    _cQry += "          ROUND(  " + _ENTER_
    _cQry += "                  CASE WHEN sb.Sexo IN ('MACHO','INTEIRO')   " + _ENTER_
    _cQry += "                  THEN -0.12   " + _ENTER_
    _cQry += "                  ELSE 0   " + _ENTER_
    _cQry += "                  END   " + _ENTER_
    _cQry += "                  + 1.33 + (0.0036 * (sb.PesoMedioInicial * 0.96))  " + _ENTER_
    _cQry += "          , 2) AS FS,  " + _ENTER_
    _cQry += "          ROUND(  " + _ENTER_
    _cQry += "              CASE  " + _ENTER_
    _cQry += "              WHEN sb.Sexo = 'FEMEA' THEN  " + _ENTER_
    _cQry += "                  (  " + _ENTER_
    _cQry += "                  (  " + _ENTER_
    _cQry += "                      551.5  " + _ENTER_
    _cQry += "                      - 0.2482 * (sb.PesoMedioInicial * 0.96)  " + _ENTER_
    _cQry += "                      + 0.00119 * POWER(sb.PesoMedioInicial * 0.96, 2)  " + _ENTER_
    _cQry += "                      - 39.84 * ROUND(CASE WHEN sb.Sexo IN ('MACHO','INTEIRO') THEN -0.12 ELSE 0 END + 1.33 + (0.0036 * (sb.PesoMedioInicial * 0.96)),6)  " + _ENTER_
    _cQry += "                  )  " + _ENTER_
    _cQry += "                  * (" + cValToChar(nGordura/100) + " / 0.28)  " + _ENTER_
    _cQry += "                  )  " + _ENTER_
    _cQry += "              WHEN sb.Sexo IN ( 'MACHO', 'INTEIRO', 'CAPAO','CASTRADO' ) THEN  " + _ENTER_
    _cQry += "                  (  " + _ENTER_
    _cQry += "                  (  " + _ENTER_
    _cQry += "                      509.6  " + _ENTER_
    _cQry += "                      + 0.4697 * (sb.PesoMedioInicial * 0.96)  " + _ENTER_
    _cQry += "                      - 46.54 * ROUND(CASE WHEN sb.Sexo IN ('MACHO','INTEIRO') THEN -0.12 ELSE 0 END + 1.33 + (0.0036 * (sb.PesoMedioInicial * 0.96)),6)  " + _ENTER_
    _cQry += "                  )  " + _ENTER_
    _cQry += "                  * (" + cValToChar(nGordura/100) + " / 0.28)  " + _ENTER_
    _cQry += "                  )  " + _ENTER_
    _cQry += "              ELSE  " + _ENTER_
    _cQry += "                  NULL  " + _ENTER_
    _cQry += "              END  " + _ENTER_
    _cQry += "              +  " + _ENTER_
    _cQry += "              CASE  " + _ENTER_
    _cQry += "                 CASE  " + _ENTER_
    _cQry += "                 WHEN sb.PesoMedioInicial = 0 THEN 0  " + _ENTER_
    _cQry += "                 WHEN sb.PesoMedioInicial/30.0 <= 11 THEN 4  " + _ENTER_
    _cQry += "                 WHEN sb.PesoMedioInicial/30.0 <= 13 THEN 5  " + _ENTER_
    _cQry += "                 WHEN sb.PesoMedioInicial/30.0 <= 15 THEN 6  " + _ENTER_
    _cQry += "                 WHEN sb.PesoMedioInicial/30.0 <= 17 THEN 7  " + _ENTER_
    _cQry += "                 ELSE 8  " + _ENTER_
    _cQry += "             END   " + _ENTER_
    _cQry += "             WHEN 4 THEN -33.2  " + _ENTER_
    _cQry += "             WHEN 5 THEN 0  " + _ENTER_
    _cQry += "             WHEN 6 THEN 33.2  " + _ENTER_
    _cQry += "             WHEN 7 THEN 66.4  " + _ENTER_
    _cQry += "             WHEN 8 THEN 99.6  " + _ENTER_
    _cQry += "             END   " + _ENTER_
    _cQry += "          , 2) AS PesoFinalPrevisto,  " + _ENTER_
    _cQry += "  " + _ENTER_
    _cQry += "         --  ROUND(  " + _ENTER_
    _cQry += "         --      (sb.PesoMedioInicial +   " + _ENTER_
    _cQry += "         --      ((509.6 + (0.4697 * (sb.PesoMedioInicial * 0.96)) - (46.54 * ROUND(CASE WHEN sb.Sexo IN ('MACHO','INTEIRO') THEN -0.12 ELSE 0 END + 1.33 + (0.0036 * (sb.PesoMedioInicial * 0.96)),6))) * (" + cValToChar(nGordura/100) + "/0.28) +  " + _ENTER_
    _cQry += "         --      CASE  " + _ENTER_
    _cQry += "         --         CASE  " + _ENTER_
    _cQry += "         --         WHEN sb.PesoMedioInicial = 0 THEN 0  " + _ENTER_
    _cQry += "         --         WHEN sb.PesoMedioInicial/30.0 <= 11 THEN 4  " + _ENTER_
    _cQry += "         --         WHEN sb.PesoMedioInicial/30.0 <= 13 THEN 5  " + _ENTER_
    _cQry += "         --         WHEN sb.PesoMedioInicial/30.0 <= 15 THEN 6  " + _ENTER_
    _cQry += "         --         WHEN sb.PesoMedioInicial/30.0 <= 17 THEN 7  " + _ENTER_
    _cQry += "         --         ELSE 8  " + _ENTER_
    _cQry += "         --     END   " + _ENTER_
    _cQry += "         --     WHEN 4 THEN -33.2  " + _ENTER_
    _cQry += "         --     WHEN 5 THEN 0  " + _ENTER_
    _cQry += "         --     WHEN 6 THEN 33.2  " + _ENTER_
    _cQry += "         --     WHEN 7 THEN 66.4  " + _ENTER_
    _cQry += "         --     WHEN 8 THEN 99.6  " + _ENTER_
    _cQry += "         --     END )  " + _ENTER_
    _cQry += "         --      ) / 2.0  " + _ENTER_
    _cQry += "         --  ,2) AS PesoMedio, " + _ENTER_
    _cQry += "          G1_ENERG AS Energia  " + _ENTER_
    _cQry += "          FROM SB8_CTE AS sb " + _ENTER_
    _cQry += "          INNER JOIN " + RetSqlName('SG1') + " (NOLOCK) AS sg  " + _ENTER_
    _cQry += "              ON sg.G1_COD = 'FINAL' " + _ENTER_
    _cQry += "             AND sg.D_E_L_E_T_ = ' '  " + _ENTER_
    _cQry += "          WHERE sb.LOTE IN ( " + _ENTER_
    _cQry += "              SELECT DISTINCT B8_LOTECTL  " + _ENTER_
    _cQry += "              FROM " + RetSqlName('SB8') + " (NOLOCK) SB8  " + _ENTER_
    _cQry += "              WHERE B8_X_CURRA <> ' '  " + _ENTER_
    _cQry += "                AND B8_SALDO > 0  " + _ENTER_
    _cQry += "                AND D_E_L_E_T_ = ' '  " + _ENTER_
    _cQry += "          )  " + _ENTER_
    _cQry += " ) , " + _ENTER_
    _cQry += " --SELECT * FROM SB8_CTE WHERE LOTE = '113-33' " + _ENTER_
    _cQry += " Calc AS ( " + _ENTER_
    _cQry += " SELECT   " + _ENTER_
    _cQry += "          rTrim(Filial) AS FILIAL,   " + _ENTER_
    _cQry += "          rTrim(Curral) AS CURRAL,   " + _ENTER_
    _cQry += "          rTrim(LOTE)   AS LOTE,   " + _ENTER_
    _cQry += "          CASE   " + _ENTER_
    _cQry += "              WHEN rTrim(Sexo) = 'MACHO'  THEN 'Inteiro'  " + _ENTER_
    _cQry += "              WHEN rTrim(Sexo) = 'FEMEA'  THEN 'Femea'  " + _ENTER_
    _cQry += "              WHEN rTrim(Sexo) = 'CAPAO'  THEN 'Castrado'  " + _ENTER_
    _cQry += "              ELSE 'OUTRO'  " + _ENTER_
    _cQry += "          END AS SEXO,  " + _ENTER_
    _cQry += "          rTrim(Raca) as Raca, " + _ENTER_
    _cQry += "          B8_XDATACO, " + _ENTER_
    _cQry += "          PesoMedioInicial AS B8_XPESOCO_PesoMedioInicial,   " + _ENTER_
    _cQry += "          PesoFinalPrevisto AS Z0O_PESOPR_PesoFinalPrevisto,  " + _ENTER_
    _cQry += "           " + _ENTER_
    _cQry += "          Round( (PesoMedioInicial+PesoFinalPrevisto)/2, 2) " + _ENTER_
    _cQry += "          -- PesoMedio AS  " + _ENTER_
    _cQry += "          Z0O_PESO_PesoMedio,  " + _ENTER_
    _cQry += "          -- KgMcalPrevisao AS  " + _ENTER_
    _cQry += "         Round( (" + cValToChar(nCMS_Prev) + "/100) * (PesoMedioInicial+PesoFinalPrevisto)/2  * G1_ENERG, 2) " + _ENTER_
    _cQry += "          Z0O_MCALPR_KgMcalPrevisao,   " + _ENTER_
    _cQry += "          Tamanho AS Z0O_TAMCAR_Tamanho,   " + _ENTER_
    _cQry += "          FS AS Z0O_FS,  " + _ENTER_
    _cQry += "          Energia  " + _ENTER_
    _cQry += " FROM BASE   " + _ENTER_
    _cQry += " -- WHERE LOTE = '113-33'  " + _ENTER_
    _cQry += " ),  " + _ENTER_
    _cQry += " Divergencias AS ( " + _ENTER_
    _cQry += "   SELECT " + _ENTER_
    _cQry += "     c.FILIAL, " + _ENTER_
    _cQry += "     c.CURRAL, " + _ENTER_
    _cQry += "     c.LOTE, " + _ENTER_
    _cQry += "     c.SEXO, " + _ENTER_
    _cQry += "     c.Raca, " + _ENTER_
    _cQry += "     c.B8_XDATACO, " + _ENTER_
    _cQry += "     c.B8_XPESOCO_PesoMedioInicial, " + _ENTER_
    _cQry += "     z.Z0O_PESOIN PESOIN_Z0O, " + _ENTER_
    _cQry += "     c.Z0O_PESOPR_PesoFinalPrevisto, " + _ENTER_
    _cQry += "     ISNULL(z.Z0O_PESOPR, 0) AS PESOPR_Z0O, " + _ENTER_
    _cQry += "     c.Z0O_PESO_PesoMedio, " + _ENTER_
    _cQry += "     ISNULL( z.Z0O_PESO, 0) AS PESO_Z0O, " + _ENTER_
    _cQry += "     c.Z0O_MCALPR_KgMcalPrevisao, " + _ENTER_
    _cQry += "     ISNULL( z.Z0O_MCALPR, 0) AS MCALPR_Z0O, " + _ENTER_
    _cQry += "     c.Z0O_TAMCAR_Tamanho, " + _ENTER_
    _cQry += "     ISNULL( z.Z0O_TAMCAR, 0) AS TAMCAR_Z0O, " + _ENTER_
    _cQry += "     c.Z0O_FS, " + _ENTER_
    _cQry += "     ISNULL( z.Z0O_FS, 0 ) AS FS_Z0O, " + _ENTER_
    _cQry += "     c.Energia, " + _ENTER_
    _cQry += "     ISNULL( z.Z0O_ENERGI, 0) AS ENERGI_Z0O, " + _ENTER_
    _cQry += "     z.Z0O_CMSPRE " + _ENTER_
    _cQry += "   FROM Calc c " + _ENTER_
    _cQry += "   LEFT JOIN " + RetSqlName('Z0O') + " z " + _ENTER_
    _cQry += "       ON RTRIM(c.LOTE) = RTRIM(z.Z0O_LOTE) " + _ENTER_
    _cQry += "      AND z.Z0O_LOTE + CAST(z.R_E_C_N_O_ AS VARCHAR) " + _ENTER_
    _cQry += "          IN ( SELECT z2.Z0O_LOTE + CAST(MAX(z2.R_E_C_N_O_) AS VARCHAR) CHAVE " + _ENTER_
    _cQry += "               FROM " + RetSqlName('Z0O') + " z2 " + _ENTER_
    _cQry += "               WHERE z2.D_E_L_E_T_ = ' ' " + _ENTER_
    _cQry += "               GROUP BY z2.Z0O_LOTE " + _ENTER_
    _cQry += "             ) " + _ENTER_
    _cQry += "     AND z.D_E_L_E_T_ = ' ' " + _ENTER_
    _cQry += "   WHERE  " + _ENTER_
    _cQry += "        ISNULL(c.B8_XPESOCO_PesoMedioInicial, 0)  <> ISNULL(z.Z0O_PESOIN, 0) " + _ENTER_
    _cQry += "     OR ISNULL(c.Z0O_PESOPR_PesoFinalPrevisto, 0) <> ISNULL(z.Z0O_PESOPR, 0) " + _ENTER_
    _cQry += "     OR ISNULL(c.Z0O_PESO_PesoMedio, 0)           <> ISNULL(z.Z0O_PESO, 0) " + _ENTER_
    _cQry += "     OR ISNULL(c.Z0O_MCALPR_KgMcalPrevisao, 0)    <> ISNULL(z.Z0O_MCALPR, 0) " + _ENTER_
    _cQry += "     OR ISNULL(c.Z0O_TAMCAR_Tamanho, 0)           <> ISNULL(z.Z0O_TAMCAR, 0) " + _ENTER_
    _cQry += "     OR ISNULL(c.Z0O_FS, 0)                       <> ISNULL(z.Z0O_FS, 0) " + _ENTER_
    _cQry += "     OR ISNULL(c.Energia, 0)                      <> ISNULL(z.Z0O_ENERGI, 0) " + _ENTER_
    _cQry += "     OR " + cValToChar( nCMS_Prev ) + "           <> ISNULL(z.Z0O_CMSPRE, 0) " + _ENTER_
    _cQry += " ) " + _ENTER_
    _cQry += " SELECT * FROM Divergencias " + _ENTER_

    If !lIsJob .AND. !Empty( cLote ) // U_VATRTMB1('1-40      ') // U_VATRTMB1
        
        ConOut( "Processamento unico para o lote: " + cValToChar(cLote) )
        _cQry += " WHERE LOTE = '" + cValToChar(cLote) + "' " + _ENTER_

    EndIf

    _cQry += " ORDER BY FILIAL, CURRAL, LOTE " + _ENTER_
    // _cQry += " ORDER BY 1, 2 "

    // dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAliasF),.F.,.F.)  // U_VATRTMB1()
    // MsAguarde({|| MPSysOpenQuery( _cQry, cAliasF,, "TOPCONN")}, "Executando consulta SQL...")
    MsAguarde({|| MPSysOpenQuery( _cQry, cAliasF)}, "Executando consulta SQL...")

    While !(cAliasF)->(EOF())

        // cHtml += "<tr><td>" + (cAliasF)->FILIAL + "</td><td>" + (cAliasF)->CURRAL + "</td><td>" + (cAliasF)->LOTE + "</td></tr>"
<<<<<<< HEAD
=======

        ConOut( "Curral: " + AllTrim((cAliasF)->CURRAL) + " - Lote: " + AllTrim((cAliasF)->LOTE) )
>>>>>>> Igor

        _cQry := ""+;
            " SELECT 		R_E_C_N_O_  RECNO, *  " + _ENTER_ +;
            " FROM 		" + RetSqlName('Z0O') + _ENTER_ +;
            " WHERE     	D_E_L_E_T_ = ' ' AND  " + _ENTER_ +;
            "   			Z0O_LOTE + CAST(R_E_C_N_O_ AS VARCHAR) IN ( " + _ENTER_ +;
            " 			SELECT 		Z0O_LOTE +  " + _ENTER_ +;
            " 						CAST(MAX(R_E_C_N_O_ ) AS VARCHAR) CHAVE  " + _ENTER_ +;
            " 						-- Z0O_LOTE, MAX(R_E_C_N_O_ ) RECNO, " + _ENTER_ +;
            " 			FROM 		" + RetSqlName('Z0O') + _ENTER_ +;
            " 			WHERE     	 " + _ENTER_ +;
            " 						Z0O_LOTE = '" + (cAliasF)->LOTE + "' AND " + _ENTER_ +;
            " 						D_E_L_E_T_ = ' ' " + _ENTER_ +;
            " 			GROUP BY 	Z0O_LOTE " + _ENTER_ +;
            " ) "
        cZ0OAlias    := GetNextAlias()
        dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cZ0OAlias),.F.,.F.)

        If !(cZ0OAlias)->(EOF())

            ConOut( "A T U A L I Z A N D O  registro existente na Z0O para o lote: " + AllTrim((cAliasF)->LOTE) )

            Z0O->(DbGoTo( (cZ0OAlias)->RECNO ))

            lDivergencia := Z0O->Z0O_PESOIN <> (cAliasF)->B8_XPESOCO_PesoMedioInicial .OR.;
                Z0O->Z0O_ENERGI <> (cAliasF)->Energia .OR.;
                Z0O->Z0O_CMSPRE <> nCMS_Prev
            If lDivergencia

                ConOut( "" )
                ConOut("Divergencia encontrada:" )
                ConOut("    PESOIN: " + cValToChar(Z0O->Z0O_PESOIN) + " -> " + cValToChar((cAliasF)->B8_XPESOCO_PesoMedioInicial) )
                ConOut("    ENERGI: " + cValToChar(Z0O->Z0O_ENERGI) + " -> " + cValToChar((cAliasF)->Energia) )
                ConOut("    CMSPRE: " + cValToChar(Z0O->Z0O_CMSPRE) + " -> " + cValToChar(nCMS_Prev) )
                ConOut( "" )

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

            ConOut( "I N S E R I N D O   novo registro na Z0O para o lote: " + AllTrim((cAliasF)->LOTE) )

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

    ConOut( "Processamento finalizado fonte: VATRTMB1.PRW" )
    ConOut( Replicate("-", 100) )

Return nil
