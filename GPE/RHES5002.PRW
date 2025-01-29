#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/ RHES5002
@author  JORGE PAIVA
@since 01/12/2020
@version 1.0
@description Relatório Folha x TAF
@type function
/*/

User Function RHES5002()
Local aArea    := GetArea()
Private oExcel := nil 
Processa({|| fProcRel()},"Aguarde...","Carregando Registros...")
RestArea(aArea)  
return   

      
Static Function fProcRel()

Local cTab     	:= GetNextAlias() 
local cEmpresa  := CapitalAce(SM0->M0_NOMECOM) 
local cTitulo   := "Relatório de Folha x S-5002 (IRRF)"  
local nRegAtu   := 0
local nTotReg   := 0
local cQuery	:= ''
local nDec1		:= TamSX3("RD_VALOR")[2]
local cPerTaf	:= ""
local cCab1Fon	:= 'Calibri' 
local cCab1TamF	:= 8   
local cCab1CorF := '#FFFFFF'
local cCab1Fun	:= '#4F81BD'
local cFonte1	 := 'Arial'
local nTamFont1	 := 12   
local cCorFont1  := '#FFFFFF'
local cCorFun1	 := '#4F81BD'
local cFonte2	 := 'Arial'
local nTamFont2	 := 8   
local cCorFont2  := '#000000'
local cCorFun2	 := '#B8CCE4'
local cTemp1 	 := "" 
local cTemp2 	 := "" 
local cPerg 	 := "RHES5002" 

Private cPath 	 := "C:\totvs_relatorios\"
Private cArqXML  := cPerg+"_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':','')) 

ProcRegua(0)    

GeraX1(cPerg)

If Pergunte(cPerg, .T.)
	U_PrintSX1(cPerg)
        If Len( Directory(cPath + "*.*","D") ) == 0
            If Makedir(cPath) == 0
                ConOut('Diretorio Criado com Sucesso.')
                MsgAlert('Diretorio Criado com Sucesso: ' + cPath, 'Aviso')
            Else
                ConOut( "Não foi possivel criar o diretório. Erro: " + cValToChar( FError() ) )
                MsgAlert( "Não foi possivel criar o diretório. Erro: " + cValToChar( FError() ), 'Aviso' )
            EndIf
        EndIf

/* 		nHandle := FCreate(cArquivo)
        if nHandle = -1
            conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
        else */

			MV_PAR07 := Upper(MV_PAR07)
			MV_PAR05 := Alltrim(MV_PAR05)
			if Empty(MV_PAR05)
				MV_PAR05 := AllTrim(GetTempPath())
			endif	 	
/* 			if Right(MV_PAR05,1) <> '\'
				MV_PAR05 += '\' 
			endif */
			if MV_PAR07 == '132' 
				cPerTaf	:= substr(MV_PAR05,1,4)
			else
				cPerTaf	:= MV_PAR05
			endif	

			cQuery	:= " SELECT " + CRLF
			cQuery	+= "        X.FILIAL, "+ CRLF
			cQuery	+= "        X.MAT_FOLHA, "+ CRLF
			cQuery	+= "        X.NOME, "+ CRLF
			cQuery	+= "        X.CPF, "+ CRLF
			cQuery	+= "        X.ID_TAF, "+ CRLF
			cQuery	+= "        X.MAT_TAF, "+ CRLF
			cQuery	+= "        x.PIS, "+ CRLF
			cQuery	+= "        X.SITUACAO, "+ CRLF
			cQuery	+= "        X.ADMISSAO, "+ CRLF
			cQuery	+= "        X.DEMISSAO, "  + CRLF
			cQuery	+= "        (X.FOL_BASE_IRME + X.FOL_DED_IRME) FOLBASEME, "+ CRLF
			cQuery	+= "        X.TAF_BASE_IRME TAFBASEME, "+ CRLF
			cQuery	+= "        (X.FOL_BASE_IR13 + X.FOL_DED_IR13) FOLBASE13, "+ CRLF
			cQuery	+= "        X.TAF_BASE_IR13 TAFBASE13, "+ CRLF
			cQuery	+= "        (X.FOL_BASE_IRFE + X.FOL_DED_IRFE) FOLBASEFE, "+ CRLF
			cQuery	+= "        X.TAF_BASE_IRFE TAFBASEFE, "+ CRLF
			cQuery	+= "        X.FOL_RET_IRME FOLRETME, "+ CRLF
			cQuery	+= "        X.TAF_RET_IRME TAFRETME, "+ CRLF
			cQuery	+= "        X.FOL_RET_IR13 FOLRET13, "+ CRLF
			cQuery	+= "        X.TAF_RET_IR13 TAFRET13, "+ CRLF
			cQuery	+= "        X.FOL_RET_IRFE FOLRETFE, "+ CRLF
			cQuery	+= "        X.TAF_RET_IRFE TAFRETFE, "+ CRLF
			cQuery	+= "        X.FOL_DED_IRME FOLDEDME, "+ CRLF
			cQuery	+= "        X.TAF_DED_IRME TAFDEDME, "+ CRLF
			cQuery	+= "        X.FOL_DED_IR13 FOLDED13, "+ CRLF
			cQuery	+= "        X.TAF_DED_IR13 TAFDED13, "+ CRLF
			cQuery	+= "        X.FOL_DED_IRFE FOLDEDFE, "+ CRLF
			cQuery	+= "        X.TAF_DED_IRFE TAFDEDFE, "+ CRLF
			cQuery	+= "        X.FOL_DED_DEPIRME FOLDEDDEME, "+ CRLF
			cQuery	+= "        X.TAF_DED_DEPIRME TAFDEDDEME, "+ CRLF
			cQuery	+= "        X.FOL_DED_DEPIR13 FOLDEDDE13, "+ CRLF
			cQuery	+= "        X.TAF_DED_DEPIR13 TAFDEDDE13, "+ CRLF
			cQuery	+= "        X.FOL_DED_DEPIRFE FOLDEDDEFE, "+ CRLF
			cQuery	+= "        X.TAF_DED_DEPIRFE TAFDEDDEFE, "+ CRLF
			cQuery	+= "        X.FOL_RET_IRTOT FOLRETTOT, "+ CRLF
			cQuery	+= "        X.TAF_RET_IRTOT TAFRETTOT, "+ CRLF
			cQuery	+= " 	    (X.FOL_BASE_IRME + X.FOL_DED_IRME) - X.TAF_BASE_IRME DIFBASEME, "+ CRLF
			cQuery	+= " 	    (X.FOL_BASE_IR13 + X.FOL_DED_IR13) - X.TAF_BASE_IR13 DIFBASE13, "+ CRLF
			cQuery	+= " 	    (X.FOL_BASE_IRFE + X.FOL_DED_IRFE) - X.TAF_BASE_IRFE DIFBASEFE, "+ CRLF
			cQuery	+= " 	    X.FOL_RET_IRME - X.TAF_RET_IRME DIFRETME, "+ CRLF
			cQuery	+= " 	    X.FOL_RET_IR13 - X.TAF_RET_IR13 DIFRET13, "+ CRLF
			cQuery	+= " 	    X.FOL_RET_IRFE - X.TAF_RET_IRFE DIFRETFE, "+ CRLF
			cQuery	+= " 	    X.FOL_DED_IRME - X.TAF_DED_IRME DIFDEDME, "+ CRLF
			cQuery	+= " 	    X.FOL_DED_IR13 - X.TAF_DED_IR13 DIFDED13, "+ CRLF
			cQuery	+= " 	    X.FOL_DED_IRFE - X.TAF_DED_IRFE DIFDEDFE, "+ CRLF
			cQuery	+= " 	    X.FOL_DED_DEPIRME - X.TAF_DED_DEPIRME DIFDEDDEME, "+ CRLF
			cQuery	+= " 	    X.FOL_DED_DEPIR13 - X.TAF_DED_DEPIR13 DIFDEDDE13, "+ CRLF
			cQuery	+= " 	    X.FOL_DED_DEPIRFE - X.TAF_DED_DEPIRFE DIFDEDDEFE, "+ CRLF
			cQuery	+= " 	    X.FOL_RET_IRTOT - X.TAF_RET_IRTOT DIFIRTOT "	   + CRLF
			cQuery	+= " FROM ( "+ CRLF
			cQuery	+= " SELECT "     + CRLF
			cQuery	+= "        SRA.RA_FILIAL FILIAL, " + CRLF
			cQuery	+= "        SRA.RA_MAT MAT_FOLHA, "+ CRLF
			cQuery	+= "        SRA.RA_NOME NOME, "+ CRLF
			cQuery	+= "        SRA.RA_CIC CPF, "+ CRLF
			cQuery	+= "        SRA.RA_PIS PIS, "+ CRLF
			cQuery	+= "        (CASE " + CRLF
			cQuery	+= "           WHEN SRA.RA_PROCES = '00003' "+ CRLF
			cQuery	+= "              THEN "   + CRLF
			cQuery	+= "                (select MAX(C9V.C9V_ID) " + CRLF
			cQuery	+= "                 FROM "+RetSqlName("C9V")+"  C9V "+ CRLF
			cQuery	+= "                 WHERE C9V.C9V_FILIAL = SRA.ra_filial "+ CRLF
			cQuery	+= "                  AND C9V.C9V_CPF = SRA.RA_CIC "+ CRLF
			cQuery	+= "                  AND C9V.C9V_ATIVO = '1' "+ CRLF
			cQuery	+= "                  AND C9V.C9V_STATUS = '4' "  + CRLF
			cQuery	+= "                  AND C9V.D_E_L_E_T_ <> '*')  "+ CRLF
			cQuery	+= "           ELSE "+ CRLF
			cQuery	+= "                (select MAX(C9V.C9V_ID) " + CRLF
			cQuery	+= "                 FROM "+RetSqlName("C9V")+"  C9V "+ CRLF
			cQuery	+= "                 WHERE C9V.C9V_FILIAL = SRA.ra_filial "+ CRLF
			cQuery	+= "                  AND C9V.C9V_MATRIC = SRA.RA_CODUNIC "+ CRLF
			cQuery	+= "                  AND C9V.C9V_ATIVO = '1' "+ CRLF
			cQuery	+= "                  AND C9V.C9V_STATUS = '4' "  + CRLF
			cQuery	+= "                  AND C9V.D_E_L_E_T_ <> '*')  "+ CRLF
			cQuery	+= "        END ) ID_TAF, " + CRLF
			cQuery	+= "        SRA.RA_CODUNIC MAT_TAF, "+ CRLF
			cQuery	+= "        (CASE " + CRLF
			cQuery	+= "             WHEN SRA.RA_SITFOLH = '' "+ CRLF
			cQuery	+= "              THEN 'ATIVO' "+ CRLF
			cQuery	+= "             WHEN SRA.RA_SITFOLH = 'D' OR (SRA.RA_DEMISSA <= CONVERT(VARCHAR(8),GETDATE(),112) AND SRA.RA_DEMISSA <> '') "+ CRLF
			cQuery	+= "              THEN 'DEMITIDO' "+ CRLF
			cQuery	+= "             WHEN SRA.RA_SITFOLH = 'A' " + CRLF
			cQuery	+= "              THEN 'AFASTADO' "           + CRLF
			cQuery	+= "             WHEN SRA.RA_SITFOLH = 'F' " + CRLF
			cQuery	+= "              THEN 'FERIAS' " + CRLF
			cQuery	+= "             ELSE SRA.RA_SITFOLH "          + CRLF
			cQuery	+= "         END) SITUACAO, "+ CRLF
			cQuery	+= "         SRA.RA_ADMISSA ADMISSAO, "+ CRLF
			cQuery	+= "         SRA.RA_DEMISSA DEMISSAO, " + CRLF
			cQuery	+= "       ISNULL( "+ CRLF
			cQuery	+= "       (SELECT SUM(SRC.RC_VALOR) " + CRLF
			cQuery	+= "        FROM "+RetSqlName("SRC")+"  SRC, "+RetSqlName("SRA")+"  RA " + CRLF
			cQuery	+= "        WHERE SRC.RC_FILIAL = RA.RA_FILIAL "+ CRLF
			cQuery	+= "         AND SRC.RC_MAT = RA.RA_MAT "+ CRLF
			cQuery	+= "         AND SRC.RC_DATA   BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

			if MV_PAR07 == '132'  
				cQuery	+= "         AND SRC.RC_ROTEIR  = '132' " + CRLF
			else
				cQuery	+= "         AND SRC.RC_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
			endif

			cQuery	+= "         AND SRC.RC_PD IN(SELECT SRV.RV_COD "  + CRLF
			cQuery	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV " + CRLF
			cQuery	+= "                          					  WHERE SRV.RV_CODFOL IN ('0015','0016') " + CRLF
			cQuery	+= "                            					AND SRV.D_E_L_E_T_ <> '*') " + CRLF
			cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC " + CRLF
			cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT " + CRLF
			cQuery	+= "         AND RA.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "         AND SRC.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "        ),0) FOL_BASE_IRME, "   + CRLF
			cQuery	+= "        ISNULL( " + CRLF
			cQuery	+= "        (SELECT SUM(T2I.T2I_VLIRRF) " + CRLF
			cQuery	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I "  + CRLF
			cQuery	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC " + CRLF
			cQuery	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  " + CRLF
			cQuery	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL " + CRLF
			cQuery	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO " + CRLF
			cQuery	+= "          AND T2G.D_E_L_E_T_ <> '*' "  + CRLF
			cQuery	+= "          AND T2I.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID "  + CRLF
			cQuery	+= "                                 FROM "+RetSqlName("C8U")+"  C8U "  + CRLF
			cQuery	+= "                                 WHERE C8U.C8U_CODIGO = '11' "  + CRLF
			cQuery	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) " + CRLF
			cQuery	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) " + CRLF
			cQuery	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX " + CRLF
			cQuery	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN " + CRLF
			cQuery	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU "  + CRLF
			cQuery	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') "  + CRLF
			cQuery	+= "          ),0) TAF_BASE_IRME, " + CRLF
			cQuery	+= "       ISNULL( " + CRLF
			cQuery	+= "       (SELECT SUM(SRC.RC_VALOR) "  + CRLF
			cQuery	+= "        FROM "+RetSqlName("SRC")+"  SRC, "+RetSqlName("SRA")+"  RA "  + CRLF
			cQuery	+= "        WHERE SRC.RC_FILIAL = RA.RA_FILIAL " + CRLF
			cQuery	+= "         AND SRC.RC_MAT = RA.RA_MAT " + CRLF
			cQuery	+= "         AND SRC.RC_DATA   BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' " + CRLF

			if MV_PAR07 == '132'  
				cQuery	+= "         AND SRC.RC_ROTEIR  = '132' " + CRLF
			else
				cQuery	+= "         AND SRC.RC_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
			endif

			cQuery	+= "         AND SRC.RC_PD IN(SELECT SRV.RV_COD "  + CRLF
			cQuery	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV " + CRLF
			cQuery	+= "                          					  WHERE SRV.RV_CODFOL IN ('0027') " + CRLF
			cQuery	+= "                            					AND SRV.D_E_L_E_T_ <> '*') " + CRLF
			cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC " + CRLF
			cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT " + CRLF
			cQuery	+= "         AND RA.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "         AND SRC.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "        ),0) FOL_BASE_IR13, "   + CRLF
			cQuery	+= "        ISNULL( " + CRLF
			cQuery	+= "        (SELECT SUM(T2I.T2I_VLIRRF) " + CRLF
			cQuery	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I "  + CRLF
			cQuery	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC " + CRLF
			cQuery	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  " + CRLF
			cQuery	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL " + CRLF
			cQuery	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO " + CRLF
			cQuery	+= "          AND T2G.D_E_L_E_T_ <> '*' "  + CRLF
			cQuery	+= "          AND T2I.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID "  + CRLF
			cQuery	+= "                                 FROM "+RetSqlName("C8U")+"  C8U "  + CRLF
			cQuery	+= "                                 WHERE C8U.C8U_CODIGO = '12' "  + CRLF
			cQuery	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) " + CRLF
			cQuery	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) " + CRLF
			cQuery	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX " + CRLF
			cQuery	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN " + CRLF
			cQuery	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU "  + CRLF
			cQuery	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') "  + CRLF
			cQuery	+= "          ),0) TAF_BASE_IR13, " + CRLF
			cQuery	+= "       ISNULL( " + CRLF
			cQuery	+= "       (SELECT SUM(SRC.RC_VALOR) "  + CRLF
			cQuery	+= "        FROM "+RetSqlName("SRC")+"  SRC, "+RetSqlName("SRA")+"  RA "  + CRLF
			cQuery	+= "        WHERE SRC.RC_FILIAL = RA.RA_FILIAL " + CRLF
			cQuery	+= "         AND SRC.RC_MAT = RA.RA_MAT " + CRLF
			cQuery	+= "         AND SRC.RC_DATA BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' " + CRLF

			if MV_PAR07 == '132'  
				cQuery	+= "         AND SRC.RC_ROTEIR  = '132' " + CRLF
			else
				cQuery	+= "         AND SRC.RC_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
			endif

			cQuery	+= "         AND SRC.RC_PD IN(SELECT SRV.RV_COD " + CRLF
			cQuery	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
			cQuery	+= "                          					  WHERE SRV.RV_CODFOL IN ('0016','1562') "+ CRLF
			cQuery	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
			cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC "+ CRLF
			cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
			cQuery	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "         AND SRC.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "        ),0) FOL_BASE_IRFE, "  + CRLF
			cQuery	+= "        ISNULL( "+ CRLF
			cQuery	+= "        (SELECT SUM(T2I.T2I_VLIRRF) "+ CRLF
			cQuery	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I " + CRLF
			cQuery	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
			cQuery	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
			cQuery	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL "+ CRLF
			cQuery	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO "+ CRLF
			cQuery	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "          AND T2I.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID " + CRLF
			cQuery	+= "                                 FROM "+RetSqlName("C8U")+"  C8U " + CRLF
			cQuery	+= "                                 WHERE C8U.C8U_CODIGO = '13' " + CRLF
			cQuery	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) "+ CRLF
			cQuery	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
			cQuery	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
			cQuery	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
			cQuery	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
			cQuery	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
			cQuery	+= "          ),0) TAF_BASE_IRFE, "+ CRLF
			cQuery	+= "       ISNULL( "+ CRLF
			cQuery	+= "       (SELECT SUM(SRC.RC_VALOR) " + CRLF
			cQuery	+= "        FROM "+RetSqlName("SRC")+"  SRC, "+RetSqlName("SRA")+"  RA " + CRLF
			cQuery	+= "        WHERE SRC.RC_FILIAL = RA.RA_FILIAL "+ CRLF
			cQuery	+= "         AND SRC.RC_MAT = RA.RA_MAT "+ CRLF
			cQuery	+= "         AND SRC.RC_DATA BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

			if MV_PAR07 == '132'  
				cQuery	+= "         AND SRC.RC_ROTEIR  = '132' " + CRLF
			else
				cQuery	+= "         AND SRC.RC_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
			endif

			cQuery	+= "         AND SRC.RC_PD IN(SELECT SRV.RV_COD " + CRLF
			cQuery	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
			cQuery	+= "                          					  WHERE SRV.RV_CODFOL IN ('0066') "+ CRLF
			cQuery	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
			cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC "+ CRLF
			cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
			cQuery	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "         AND SRC.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "        ),0) FOL_RET_IRME, "  + CRLF
			cQuery	+= "        ISNULL( "+ CRLF
			cQuery	+= "        (SELECT SUM(T2I.T2I_VLIRRF) "+ CRLF
			cQuery	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I " + CRLF
			cQuery	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
			cQuery	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
			cQuery	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL "+ CRLF
			cQuery	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO "+ CRLF
			cQuery	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "          AND T2I.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID " + CRLF
			cQuery	+= "                                 FROM "+RetSqlName("C8U")+"  C8U " + CRLF
			cQuery	+= "                                 WHERE C8U.C8U_CODIGO = '31' " + CRLF
			cQuery	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) "+ CRLF
			cQuery	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
			cQuery	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
			cQuery	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
			cQuery	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
			cQuery	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
			cQuery	+= "          ),0) TAF_RET_IRME, "+ CRLF
			cQuery	+= "       ISNULL( "+ CRLF
			cQuery	+= "       (SELECT SUM(SRC.RC_VALOR) " + CRLF
			cQuery	+= "        FROM "+RetSqlName("SRC")+"  SRC, "+RetSqlName("SRA")+"  RA " + CRLF
			cQuery	+= "        WHERE SRC.RC_FILIAL = RA.RA_FILIAL "+ CRLF
			cQuery	+= "         AND SRC.RC_MAT = RA.RA_MAT "+ CRLF
			cQuery	+= "         AND SRC.RC_DATA BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

			if MV_PAR07 == '132'  
				cQuery	+= "         AND SRC.RC_ROTEIR  = '132' " + CRLF
			else
				cQuery	+= "         AND SRC.RC_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
			endif

			cQuery	+= "         AND SRC.RC_PD IN(SELECT SRV.RV_COD " + CRLF
			cQuery	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
			cQuery	+= "                          					  WHERE SRV.RV_CODFOL IN ('0071') "+ CRLF
			cQuery	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
			cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC "+ CRLF
			cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
			cQuery	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "         AND SRC.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "        ),0) FOL_RET_IR13, "  + CRLF
			cQuery	+= "        ISNULL( "+ CRLF
			cQuery	+= "        (SELECT SUM(T2I.T2I_VLIRRF) "+ CRLF
			cQuery	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I " + CRLF
			cQuery	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
			cQuery	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
			cQuery	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL "+ CRLF
			cQuery	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO "+ CRLF
			cQuery	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "          AND T2I.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID " + CRLF
			cQuery	+= "                                 FROM "+RetSqlName("C8U")+"  C8U " + CRLF
			cQuery	+= "                                 WHERE C8U.C8U_CODIGO = '32' " + CRLF
			cQuery	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) "+ CRLF
			cQuery	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
			cQuery	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
			cQuery	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
			cQuery	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
			cQuery	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
			cQuery	+= "          ),0) TAF_RET_IR13, "+ CRLF
			cQuery	+= "       ISNULL( "+ CRLF
			cQuery	+= "       (SELECT SUM(SRC.RC_VALOR) " + CRLF
			cQuery	+= "        FROM "+RetSqlName("SRC")+"  SRC, "+RetSqlName("SRA")+"  RA " + CRLF
			cQuery	+= "        WHERE SRC.RC_FILIAL = RA.RA_FILIAL "+ CRLF
			cQuery	+= "         AND SRC.RC_MAT = RA.RA_MAT "+ CRLF
			cQuery	+= "         AND SRC.RC_DATA BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

			if MV_PAR07 == '132'  
				cQuery	+= "         AND SRC.RC_ROTEIR  = '132' " + CRLF
			else
				cQuery	+= "         AND SRC.RC_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
			endif
 
			cQuery	+= "         AND SRC.RC_PD IN(SELECT SRV.RV_COD "  + CRLF
			cQuery	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV " + CRLF
			cQuery	+= "                          					  WHERE SRV.RV_CODFOL IN ('0067') " + CRLF
			cQuery	+= "                            					AND SRV.D_E_L_E_T_ <> '*') " + CRLF
			cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC " + CRLF
			cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT " + CRLF
			cQuery	+= "         AND RA.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "         AND SRC.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "        ),0) FOL_RET_IRFE, "   + CRLF
			cQuery	+= "        ISNULL( " + CRLF
			cQuery	+= "        (SELECT SUM(T2I.T2I_VLIRRF) " + CRLF
			cQuery	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I "  + CRLF
			cQuery	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC " + CRLF
			cQuery	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  " + CRLF
			cQuery	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL " + CRLF
			cQuery	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO " + CRLF
			cQuery	+= "          AND T2G.D_E_L_E_T_ <> '*' "  + CRLF
			cQuery	+= "          AND T2I.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID "  + CRLF
			cQuery	+= "                                 FROM "+RetSqlName("C8U")+"  C8U "  + CRLF
			cQuery	+= "                                 WHERE C8U.C8U_CODIGO = '33' "  + CRLF
			cQuery	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) " + CRLF
			cQuery	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) " + CRLF
			cQuery	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX " + CRLF
			cQuery	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN " + CRLF
			cQuery	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU "  + CRLF
			cQuery	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') "  + CRLF
			cQuery	+= "          ),0) TAF_RET_IRFE, " + CRLF
			cQuery	+= "       ISNULL( " + CRLF
			cQuery	+= "       (SELECT SUM(SRC.RC_VALOR) "  + CRLF
			cQuery	+= "        FROM "+RetSqlName("SRC")+"  SRC, "+RetSqlName("SRA")+"  RA "  + CRLF
			cQuery	+= "        WHERE SRC.RC_FILIAL = RA.RA_FILIAL " + CRLF
			cQuery	+= "         AND SRC.RC_MAT = RA.RA_MAT " + CRLF
			cQuery	+= "         AND SRC.RC_DATA BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' " + CRLF

			if MV_PAR07 == '132'  
				cQuery	+= "         AND SRC.RC_ROTEIR  = '132' " + CRLF
			else
				cQuery	+= "         AND SRC.RC_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
			endif

			cQuery	+= "         AND SRC.RC_PD IN(SELECT SRV.RV_COD " + CRLF
			cQuery	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
			cQuery	+= "                          					  WHERE SRV.RV_CODFOL IN ('0064') "+ CRLF
			cQuery	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
			cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC "+ CRLF
			cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
			cQuery	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "         AND SRC.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "        ),0) FOL_DED_IRME, "  + CRLF
			cQuery	+= "        ISNULL( "+ CRLF
			cQuery	+= "        (SELECT SUM(T2I.T2I_VLIRRF) "+ CRLF
			cQuery	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I " + CRLF
			cQuery	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
			cQuery	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
			cQuery	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL "+ CRLF
			cQuery	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO "+ CRLF
			cQuery	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "          AND T2I.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID " + CRLF
			cQuery	+= "                                 FROM "+RetSqlName("C8U")+"  C8U " + CRLF
			cQuery	+= "                                 WHERE C8U.C8U_CODIGO = '41' " + CRLF
			cQuery	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) "+ CRLF
			cQuery	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
			cQuery	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
			cQuery	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
			cQuery	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
			cQuery	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
			cQuery	+= "          ),0) TAF_DED_IRME, "+ CRLF
			cQuery	+= "       ISNULL( "+ CRLF
			cQuery	+= "       (SELECT SUM(SRC.RC_VALOR) " + CRLF
			cQuery	+= "        FROM "+RetSqlName("SRC")+"  SRC, "+RetSqlName("SRA")+"  RA " + CRLF
			cQuery	+= "        WHERE SRC.RC_FILIAL = RA.RA_FILIAL "+ CRLF
			cQuery	+= "         AND SRC.RC_MAT = RA.RA_MAT "+ CRLF
			cQuery	+= "         AND SRC.RC_DATA BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

			if MV_PAR07 == '132'  
				cQuery	+= "         AND SRC.RC_ROTEIR  = '132' " + CRLF
			else
				cQuery	+= "         AND SRC.RC_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
			endif

			cQuery	+= "         AND SRC.RC_PD IN(SELECT SRV.RV_COD " + CRLF
			cQuery	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
			cQuery	+= "                          					  WHERE SRV.RV_CODFOL IN ('0070') "+ CRLF
			cQuery	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
			cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC "+ CRLF
			cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
			cQuery	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "         AND SRC.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "        ),0) FOL_DED_IR13, "  + CRLF
			cQuery	+= "        ISNULL( "+ CRLF
			cQuery	+= "        (SELECT SUM(T2I.T2I_VLIRRF) "+ CRLF
			cQuery	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I " + CRLF
			cQuery	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
			cQuery	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
			cQuery	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL "+ CRLF
			cQuery	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO "+ CRLF
			cQuery	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "          AND T2I.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID " + CRLF
			cQuery	+= "                                 FROM "+RetSqlName("C8U")+"  C8U " + CRLF
			cQuery	+= "                                 WHERE C8U.C8U_CODIGO = '42' " + CRLF
			cQuery	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) "+ CRLF
			cQuery	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
			cQuery	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
			cQuery	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
			cQuery	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
			cQuery	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
			cQuery	+= "          ),0) TAF_DED_IR13, "+ CRLF
			cQuery	+= "       ISNULL( "+ CRLF
			cQuery	+= "       (SELECT SUM(SRC.RC_VALOR) " + CRLF
			cQuery	+= "        FROM "+RetSqlName("SRC")+"  SRC, "+RetSqlName("SRA")+"  RA " + CRLF
			cQuery	+= "        WHERE SRC.RC_FILIAL = RA.RA_FILIAL "+ CRLF
			cQuery	+= "         AND SRC.RC_MAT = RA.RA_MAT "+ CRLF
			cQuery	+= "         AND SRC.RC_DATA BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

			if MV_PAR07 == '132'  
				cQuery	+= "         AND SRC.RC_ROTEIR  = '132' " + CRLF
			else
				cQuery	+= "         AND SRC.RC_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
			endif

			cQuery	+= "         AND SRC.RC_PD IN(SELECT SRV.RV_COD " + CRLF
			cQuery	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
			cQuery	+= "                          					  WHERE SRV.RV_CODFOL IN ('0065') "+ CRLF
			cQuery	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
			cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC "+ CRLF
			cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
			cQuery	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "         AND SRC.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "        ),0) FOL_DED_IRFE, "  + CRLF
			cQuery	+= "        ISNULL( "+ CRLF
			cQuery	+= "        (SELECT SUM(T2I.T2I_VLIRRF) "+ CRLF
			cQuery	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I " + CRLF
			cQuery	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
			cQuery	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
			cQuery	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL "+ CRLF
			cQuery	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO "+ CRLF
			cQuery	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "          AND T2I.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID " + CRLF
			cQuery	+= "                                 FROM "+RetSqlName("C8U")+"  C8U " + CRLF
			cQuery	+= "                                 WHERE C8U.C8U_CODIGO = '43' " + CRLF
			cQuery	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) "+ CRLF
			cQuery	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
			cQuery	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
			cQuery	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
			cQuery	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
			cQuery	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
			cQuery	+= "          ),0) TAF_DED_IRFE, "+ CRLF
			cQuery	+= "       ISNULL( "+ CRLF
			cQuery	+= "       (SELECT SUM(SRC.RC_VALOR) " + CRLF
			cQuery	+= "        FROM "+RetSqlName("SRC")+"  SRC, "+RetSqlName("SRA")+"  RA " + CRLF
			cQuery	+= "        WHERE SRC.RC_FILIAL = RA.RA_FILIAL "+ CRLF
			cQuery	+= "         AND SRC.RC_MAT = RA.RA_MAT "+ CRLF
			cQuery	+= "         AND SRC.RC_DATA BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

			if MV_PAR07 == '132'  
				cQuery	+= "         AND SRC.RC_ROTEIR  = '132' " + CRLF
			else
				cQuery	+= "         AND SRC.RC_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
			endif

			cQuery	+= "         AND SRC.RC_PD IN(SELECT SRV.RV_COD " + CRLF
			cQuery	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
			cQuery	+= "                          					  WHERE SRV.RV_CODFOL IN ('0059') "+ CRLF
			cQuery	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
			cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC "+ CRLF
			cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
			cQuery	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "         AND SRC.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "        ),0) FOL_DED_DEPIRME, "  + CRLF
			cQuery	+= "        ISNULL( "+ CRLF
			cQuery	+= "        (SELECT SUM(T2I.T2I_VLIRRF) "+ CRLF
			cQuery	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I " + CRLF
			cQuery	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
			cQuery	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
			cQuery	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL "+ CRLF
			cQuery	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO "+ CRLF
			cQuery	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "          AND T2I.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID " + CRLF
			cQuery	+= "                                 FROM "+RetSqlName("C8U")+"  C8U " + CRLF
			cQuery	+= "                                 WHERE C8U.C8U_CODIGO = '56' " + CRLF
			cQuery	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) "+ CRLF
			cQuery	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
			cQuery	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
			cQuery	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
			cQuery	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
			cQuery	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
			cQuery	+= "          ),0) TAF_DED_DEPIRME, "+ CRLF
			cQuery	+= "       ISNULL( "+ CRLF
			cQuery	+= "       (SELECT SUM(SRC.RC_VALOR) " + CRLF
			cQuery	+= "        FROM "+RetSqlName("SRC")+"  SRC, "+RetSqlName("SRA")+"  RA " + CRLF
			cQuery	+= "        WHERE SRC.RC_FILIAL = RA.RA_FILIAL "+ CRLF
			cQuery	+= "         AND SRC.RC_MAT = RA.RA_MAT "+ CRLF
			cQuery	+= "         AND SRC.RC_DATA BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

			if MV_PAR07 == '132'  
				cQuery	+= "         AND SRC.RC_ROTEIR  = '132' " + CRLF
			else
				cQuery	+= "         AND SRC.RC_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
			endif

			cQuery	+= "         AND SRC.RC_PD IN(SELECT SRV.RV_COD " + CRLF
			cQuery	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
			cQuery	+= "                          					  WHERE SRV.RV_CODFOL IN ('0062') "+ CRLF
			cQuery	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
			cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC "+ CRLF
			cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
			cQuery	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "         AND SRC.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "        ),0) FOL_DED_DEPIR13, "  + CRLF
			cQuery	+= "        ISNULL( "+ CRLF
			cQuery	+= "        (SELECT SUM(T2I.T2I_VLIRRF) "+ CRLF
			cQuery	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I " + CRLF
			cQuery	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
			cQuery	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
			cQuery	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL "+ CRLF
			cQuery	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO "+ CRLF
			cQuery	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "          AND T2I.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID " + CRLF
			cQuery	+= "                                 FROM "+RetSqlName("C8U")+"  C8U " + CRLF
			cQuery	+= "                                 WHERE C8U.C8U_CODIGO = '57' " + CRLF
			cQuery	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) "+ CRLF
			cQuery	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
			cQuery	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
			cQuery	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
			cQuery	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
			cQuery	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
			cQuery	+= "          ),0) TAF_DED_DEPIR13, "+ CRLF
			cQuery	+= "       ISNULL( "+ CRLF
			cQuery	+= "       (SELECT SUM(SRC.RC_VALOR) " + CRLF
			cQuery	+= "        FROM "+RetSqlName("SRC")+"  SRC, "+RetSqlName("SRA")+"  RA " + CRLF
			cQuery	+= "        WHERE SRC.RC_FILIAL = RA.RA_FILIAL "+ CRLF
			cQuery	+= "         AND SRC.RC_MAT = RA.RA_MAT "+ CRLF
			cQuery	+= "         AND SRC.RC_DATA BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

			if MV_PAR07 == '132'  
				cQuery	+= "         AND SRC.RC_ROTEIR  = '132' " + CRLF
			else
				cQuery	+= "         AND SRC.RC_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
			endif

			cQuery	+= "         AND SRC.RC_PD IN(SELECT SRV.RV_COD " + CRLF
			cQuery	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
			cQuery	+= "                          					  WHERE SRV.RV_CODFOL IN ('0061','0062') "+ CRLF
			cQuery	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
			cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC "+ CRLF
			cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
			cQuery	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "         AND SRC.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "        ),0) FOL_DED_DEPIRFE, "  + CRLF
			cQuery	+= "        ISNULL( "+ CRLF
			cQuery	+= "        (SELECT SUM(T2I.T2I_VLIRRF) "+ CRLF
			cQuery	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I " + CRLF
			cQuery	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
			cQuery	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
			cQuery	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL "+ CRLF
			cQuery	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO "+ CRLF
			cQuery	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "          AND T2I.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID " + CRLF
			cQuery	+= "                                 FROM "+RetSqlName("C8U")+"  C8U " + CRLF
			cQuery	+= "                                 WHERE C8U.C8U_CODIGO = '58' " + CRLF
			cQuery	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) "+ CRLF
			cQuery	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
			cQuery	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
			cQuery	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
			cQuery	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
			cQuery	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
			cQuery	+= "          ),0) TAF_DED_DEPIRFE, "+ CRLF
			cQuery	+= "       ISNULL( "+ CRLF
			cQuery	+= "       (SELECT SUM(SRC.RC_VALOR) " + CRLF
			cQuery	+= "        FROM "+RetSqlName("SRC")+"  SRC, "+RetSqlName("SRA")+"  RA " + CRLF
			cQuery	+= "        WHERE SRC.RC_FILIAL = RA.RA_FILIAL "+ CRLF
			cQuery	+= "         AND SRC.RC_MAT = RA.RA_MAT "+ CRLF
			cQuery	+= "         AND SRC.RC_DATA BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

			if MV_PAR07 == '132' 
				cQuery	+= "         AND SRC.RC_ROTEIR  = '132' "+ CRLF
			else
				cQuery	+= "         AND SRC.RC_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
			endif

			cQuery	+= "         AND SRC.RC_PD IN(SELECT SRV.RV_COD " + CRLF
			cQuery	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
			cQuery	+= "                           					  WHERE SRV.RV_CODFOL IN ('0066','0071','0067') "+ CRLF
			cQuery	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
			cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC " + CRLF
			cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
			cQuery	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "         AND SRC.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "        ),0) FOL_RET_IRTOT, "  + CRLF
			cQuery	+= "        ISNULL( "+ CRLF
			cQuery	+= "        (SELECT SUM(T2J.T2J_VLDESC) "+ CRLF
			cQuery	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2J")+"  T2J " + CRLF
			cQuery	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
			cQuery	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
			cQuery	+= "          AND T2G.T2G_FILIAL = T2J.T2J_FILIAL "+ CRLF
			cQuery	+= "          AND T2G.T2G_VERSAO = T2J.T2J_VERSAO "+ CRLF
			cQuery	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "          AND T2J.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "          AND T2J.T2J_CTPCR IN (SELECT C6R_ID "+ CRLF
			cQuery	+= "                                FROM "+RetSqlName("C6R")+"  C6R " + CRLF
			cQuery	+= "                                WHERE C6R.C6R_CODIGO = '999999' " + CRLF
			cQuery	+= "                                 AND C6R.D_E_L_E_T_ <> '*' ) "+ CRLF
			cQuery	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
			cQuery	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
			cQuery	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
			cQuery	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
			cQuery	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
			cQuery	+= "          ),0) TAF_RET_IRTOT "+ CRLF
			cQuery	+= " FROM  "+RetSqlName("SRA")+"  SRA "+ CRLF
			cQuery	+= " WHERE SRA.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "  AND EXISTS "+ CRLF
			cQuery	+= "  (SELECT * "+ CRLF
			cQuery	+= "   FROM  "+RetSqlName("SRC")+"  SRC "+ CRLF
			cQuery	+= "   WHERE SRC.RC_FILIAL = SRA.RA_FILIAL "+ CRLF
			cQuery	+= "    AND SRC.RC_MAT = SRA.RA_MAT "+ CRLF
			cQuery	+= "    AND SRC.RC_PERIODO = '"+MV_PAR05+"' "+ CRLF
			if MV_PAR07 == '132' 
				cQuery	+= "         AND SRC.RC_ROTEIR  = '132' "+ CRLF
			else
				cQuery	+= "         AND SRC.RC_ROTEIR IN ('AUT','FOL') "+ CRLF
			endif
			cQuery	+= "    AND SRC.D_E_L_E_T_ <> '*' ) " + CRLF
			cQuery	+= " ) X   "+ CRLF

			cQuery	+= "UNION ALL   "+ CRLF

			cQuery	:= " SELECT " + CRLF
			cQuery	+= "        X.FILIAL, " + CRLF
			cQuery	+= "        X.MAT_FOLHA, " + CRLF
			cQuery	+= "        X.NOME, " + CRLF
			cQuery	+= "        X.CPF, " + CRLF
			cQuery	+= "        X.ID_TAF, " + CRLF
			cQuery	+= "        X.MAT_TAF, " + CRLF
			cQuery	+= "        x.PIS, " + CRLF
			cQuery	+= "        X.SITUACAO, " + CRLF
			cQuery	+= "        X.ADMISSAO, " + CRLF
			cQuery	+= "        X.DEMISSAO, "   + CRLF
			cQuery	+= "        (X.FOL_BASE_IRME + X.FOL_DED_IRME) FOLBASEME, " + CRLF
			cQuery	+= "        X.TAF_BASE_IRME TAFBASEME, " + CRLF
			cQuery	+= "        (X.FOL_BASE_IR13 + X.FOL_DED_IR13) FOLBASE13, " + CRLF
			cQuery	+= "        X.TAF_BASE_IR13 TAFBASE13, " + CRLF
			cQuery	+= "        (X.FOL_BASE_IRFE + X.FOL_DED_IRFE) FOLBASEFE, " + CRLF
			cQuery	+= "        X.TAF_BASE_IRFE TAFBASEFE, " + CRLF
			cQuery	+= "        X.FOL_RET_IRME FOLRETME, " + CRLF
			cQuery	+= "        X.TAF_RET_IRME TAFRETME, " + CRLF
			cQuery	+= "        X.FOL_RET_IR13 FOLRET13, " + CRLF
			cQuery	+= "        X.TAF_RET_IR13 TAFRET13, " + CRLF
			cQuery	+= "        X.FOL_RET_IRFE FOLRETFE, " + CRLF
			cQuery	+= "        X.TAF_RET_IRFE TAFRETFE, " + CRLF
			cQuery	+= "        X.FOL_DED_IRME FOLDEDME, "+ CRLF
			cQuery	+= "        X.TAF_DED_IRME TAFDEDME, "+ CRLF
			cQuery	+= "        X.FOL_DED_IR13 FOLDED13, "+ CRLF
			cQuery	+= "        X.TAF_DED_IR13 TAFDED13, "+ CRLF
			cQuery	+= "        X.FOL_DED_IRFE FOLDEDFE, "+ CRLF
			cQuery	+= "        X.TAF_DED_IRFE TAFDEDFE, "+ CRLF
			cQuery	+= "        X.FOL_DED_DEPIRME FOLDEDDEME, "+ CRLF
			cQuery	+= "        X.TAF_DED_DEPIRME TAFDEDDEME, "+ CRLF
			cQuery	+= "        X.FOL_DED_DEPIR13 FOLDEDDE13, "+ CRLF
			cQuery	+= "        X.TAF_DED_DEPIR13 TAFDEDDE13, "+ CRLF
			cQuery	+= "        X.FOL_DED_DEPIRFE FOLDEDDEFE, "+ CRLF
			cQuery	+= "        X.TAF_DED_DEPIRFE TAFDEDDEFE, "+ CRLF
			cQuery	+= "        X.FOL_RET_IRTOT FOLRETTOT, "+ CRLF
			cQuery	+= "        X.TAF_RET_IRTOT TAFRETTOT, "+ CRLF
			cQuery	+= " 	    (X.FOL_BASE_IRME + X.FOL_DED_IRME) - X.TAF_BASE_IRME DIFBASEME, "+ CRLF
			cQuery	+= " 	    (X.FOL_BASE_IR13 + X.FOL_DED_IR13) - X.TAF_BASE_IR13 DIFBASE13, "+ CRLF
			cQuery	+= " 	    (X.FOL_BASE_IRFE + X.FOL_DED_IRFE) - X.TAF_BASE_IRFE DIFBASEFE, "+ CRLF
			cQuery	+= " 	    X.FOL_RET_IRME - X.TAF_RET_IRME DIFRETME, "+ CRLF
			cQuery	+= " 	    X.FOL_RET_IR13 - X.TAF_RET_IR13 DIFRET13, "+ CRLF
			cQuery	+= " 	    X.FOL_RET_IRFE - X.TAF_RET_IRFE DIFRETFE, "+ CRLF
			cQuery	+= " 	    X.FOL_DED_IRME - X.TAF_DED_IRME DIFDEDME, "+ CRLF
			cQuery	+= " 	    X.FOL_DED_IR13 - X.TAF_DED_IR13 DIFDED13, "+ CRLF
			cQuery	+= " 	    X.FOL_DED_IRFE - X.TAF_DED_IRFE DIFDEDFE, "+ CRLF
			cQuery	+= " 	    X.FOL_DED_DEPIRME - X.TAF_DED_DEPIRME DIFDEDDEME, "+ CRLF
			cQuery	+= " 	    X.FOL_DED_DEPIR13 - X.TAF_DED_DEPIR13 DIFDEDDE13, "+ CRLF
			cQuery	+= " 	    X.FOL_DED_DEPIRFE - X.TAF_DED_DEPIRFE DIFDEDDEFE, "+ CRLF
			cQuery	+= " 	    X.FOL_RET_IRTOT - X.TAF_RET_IRTOT DIFIRTOT "	   + CRLF
			cQuery	+= " FROM ( "+ CRLF
			cQuery	+= " SELECT "     + CRLF
			cQuery	+= "        SRA.RA_FILIAL FILIAL, " + CRLF
			cQuery	+= "        SRA.RA_MAT MAT_FOLHA, "+ CRLF
			cQuery	+= "        SRA.RA_NOME NOME, "+ CRLF
			cQuery	+= "        SRA.RA_CIC CPF, "+ CRLF
			cQuery	+= "        SRA.RA_PIS PIS, "+ CRLF
			cQuery	+= "        (CASE " + CRLF
			cQuery	+= "           WHEN SRA.RA_PROCES = '00003' "+ CRLF
			cQuery	+= "              THEN "   + CRLF
			cQuery	+= "                (select MAX(C9V.C9V_ID) " + CRLF
			cQuery	+= "                 FROM "+RetSqlName("C9V")+"  C9V "+ CRLF
			cQuery	+= "                 WHERE C9V.C9V_FILIAL = SRA.ra_filial "+ CRLF
			cQuery	+= "                  AND C9V.C9V_CPF = SRA.RA_CIC "+ CRLF
			cQuery	+= "                  AND C9V.C9V_ATIVO = '1' "+ CRLF
			cQuery	+= "                  AND C9V.C9V_STATUS = '4' "  + CRLF
			cQuery	+= "                  AND C9V.D_E_L_E_T_ <> '*')  "+ CRLF
			cQuery	+= "           ELSE "+ CRLF
			cQuery	+= "                (select MAX(C9V.C9V_ID) " + CRLF
			cQuery	+= "                 FROM "+RetSqlName("C9V")+"  C9V "+ CRLF
			cQuery	+= "                 WHERE C9V.C9V_FILIAL = SRA.ra_filial "+ CRLF
			cQuery	+= "                  AND C9V.C9V_MATRIC = SRA.RA_CODUNIC "+ CRLF
			cQuery	+= "                  AND C9V.C9V_ATIVO = '1' "+ CRLF
			cQuery	+= "                  AND C9V.C9V_STATUS = '4' "  + CRLF
			cQuery	+= "                  AND C9V.D_E_L_E_T_ <> '*')  "+ CRLF
			cQuery	+= "        END ) ID_TAF, " + CRLF
			cQuery	+= "        SRA.RA_CODUNIC MAT_TAF, "+ CRLF
			cQuery	+= "        (CASE " + CRLF
			cQuery	+= "             WHEN SRA.RA_SITFOLH = '' "+ CRLF
			cQuery	+= "              THEN 'ATIVO' "+ CRLF
			cQuery	+= "             WHEN SRA.RA_SITFOLH = 'D' OR (SRA.RA_DEMISSA <= CONVERT(VARCHAR(8),GETDATE(),112) AND SRA.RA_DEMISSA <> '') "+ CRLF
			cQuery	+= "              THEN 'DEMITIDO' "+ CRLF
			cQuery	+= "             WHEN SRA.RA_SITFOLH = 'A' " + CRLF
			cQuery	+= "              THEN 'AFASTADO' "           + CRLF
			cQuery	+= "             WHEN SRA.RA_SITFOLH = 'F' " + CRLF
			cQuery	+= "              THEN 'FERIAS' " + CRLF
			cQuery	+= "             ELSE SRA.RA_SITFOLH "          + CRLF
			cQuery	+= "         END) SITUACAO, "+ CRLF
			cQuery	+= "         SRA.RA_ADMISSA ADMISSAO, "+ CRLF
			cQuery	+= "         SRA.RA_DEMISSA DEMISSAO, " + CRLF
			cQuery	+= "       ISNULL( "+ CRLF
			cQuery	+= "       (SELECT SUM(SRD.RD_VALOR) " + CRLF
			cQuery	+= "        FROM "+RetSqlName("SRD")+"  SRD, "+RetSqlName("SRA")+"  RA " + CRLF
			cQuery	+= "        WHERE SRD.RD_FILIAL = RA.RA_FILIAL "+ CRLF
			cQuery	+= "         AND SRD.RD_MAT = RA.RA_MAT "+ CRLF
			cQuery	+= "         AND SRD.RD_DATPGT BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

			if MV_PAR07 == '132'  
				cQuery	+= "         AND SRD.RD_ROTEIR  = '132' " + CRLF
			else
				cQuery	+= "         AND SRD.RD_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
			endif

			cQuery	+= "         AND SRD.RD_PD IN(SELECT SRV.RV_COD " + CRLF
			cQuery	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
			cQuery	+= "                          					  WHERE SRV.RV_CODFOL IN ('0015','0016') "+ CRLF
			cQuery	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
			cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC "+ CRLF
			cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
			cQuery	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "         AND SRD.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "        ),0) FOL_BASE_IRME, "  + CRLF
			cQuery	+= "        ISNULL( "+ CRLF
			cQuery	+= "        (SELECT SUM(T2I.T2I_VLIRRF) "+ CRLF
			cQuery	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I " + CRLF
			cQuery	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
			cQuery	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
			cQuery	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL "+ CRLF
			cQuery	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO "+ CRLF
			cQuery	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "          AND T2I.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID " + CRLF
			cQuery	+= "                                 FROM "+RetSqlName("C8U")+"  C8U " + CRLF
			cQuery	+= "                                 WHERE C8U.C8U_CODIGO = '11' " + CRLF
			cQuery	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) "+ CRLF
			cQuery	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
			cQuery	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
			cQuery	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
			cQuery	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
			cQuery	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
			cQuery	+= "          ),0) TAF_BASE_IRME, "+ CRLF
			cQuery	+= "       ISNULL( "+ CRLF
			cQuery	+= "       (SELECT SUM(SRD.RD_VALOR) " + CRLF
			cQuery	+= "        FROM "+RetSqlName("SRD")+"  SRD, "+RetSqlName("SRA")+"  RA " + CRLF
			cQuery	+= "        WHERE SRD.RD_FILIAL = RA.RA_FILIAL "+ CRLF
			cQuery	+= "         AND SRD.RD_MAT = RA.RA_MAT "+ CRLF
			cQuery	+= "         AND SRD.RD_DATPGT BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

			if MV_PAR07 == '132'  
				cQuery	+= "         AND SRD.RD_ROTEIR  = '132' " + CRLF
			else
				cQuery	+= "         AND SRD.RD_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
			endif

			cQuery	+= "         AND SRD.RD_PD IN(SELECT SRV.RV_COD "  + CRLF
			cQuery	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV " + CRLF
			cQuery	+= "                          					  WHERE SRV.RV_CODFOL IN ('0027') " + CRLF
			cQuery	+= "                            					AND SRV.D_E_L_E_T_ <> '*') " + CRLF
			cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC " + CRLF
			cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT " + CRLF
			cQuery	+= "         AND RA.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "         AND SRD.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "        ),0) FOL_BASE_IR13, "   + CRLF
			cQuery	+= "        ISNULL( " + CRLF
			cQuery	+= "        (SELECT SUM(T2I.T2I_VLIRRF) " + CRLF
			cQuery	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I "  + CRLF
			cQuery	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC " + CRLF
			cQuery	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  " + CRLF
			cQuery	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL " + CRLF
			cQuery	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO " + CRLF
			cQuery	+= "          AND T2G.D_E_L_E_T_ <> '*' "  + CRLF
			cQuery	+= "          AND T2I.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID "  + CRLF
			cQuery	+= "                                 FROM "+RetSqlName("C8U")+"  C8U "  + CRLF
			cQuery	+= "                                 WHERE C8U.C8U_CODIGO = '12' "  + CRLF
			cQuery	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) " + CRLF
			cQuery	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) " + CRLF
			cQuery	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX " + CRLF
			cQuery	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN " + CRLF
			cQuery	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU "  + CRLF
			cQuery	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') "  + CRLF
			cQuery	+= "          ),0) TAF_BASE_IR13, " + CRLF
			cQuery	+= "       ISNULL( " + CRLF
			cQuery	+= "       (SELECT SUM(SRD.RD_VALOR) "  + CRLF
			cQuery	+= "        FROM "+RetSqlName("SRD")+"  SRD, "+RetSqlName("SRA")+"  RA "  + CRLF
			cQuery	+= "        WHERE SRD.RD_FILIAL = RA.RA_FILIAL " + CRLF
			cQuery	+= "         AND SRD.RD_MAT = RA.RA_MAT " + CRLF
			cQuery	+= "         AND SRD.RD_DATPGT BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' " + CRLF

			if MV_PAR07 == '132'  
				cQuery	+= "         AND SRD.RD_ROTEIR  = '132' " + CRLF
			else
				cQuery	+= "         AND SRD.RD_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
			endif

			cQuery	+= "         AND SRD.RD_PD IN(SELECT SRV.RV_COD " + CRLF
			cQuery	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
			cQuery	+= "                          					  WHERE SRV.RV_CODFOL IN ('0016','1562') "+ CRLF
			cQuery	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
			cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC "+ CRLF
			cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
			cQuery	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "         AND SRD.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "        ),0) FOL_BASE_IRFE, "  + CRLF
			cQuery	+= "        ISNULL( "+ CRLF
			cQuery	+= "        (SELECT SUM(T2I.T2I_VLIRRF) "+ CRLF
			cQuery	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I " + CRLF
			cQuery	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
			cQuery	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
			cQuery	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL "+ CRLF
			cQuery	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO "+ CRLF
			cQuery	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "          AND T2I.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID " + CRLF
			cQuery	+= "                                 FROM "+RetSqlName("C8U")+"  C8U " + CRLF
			cQuery	+= "                                 WHERE C8U.C8U_CODIGO = '13' " + CRLF
			cQuery	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) "+ CRLF
			cQuery	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
			cQuery	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
			cQuery	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
			cQuery	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
			cQuery	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
			cQuery	+= "          ),0) TAF_BASE_IRFE, "+ CRLF
			cQuery	+= "       ISNULL( "+ CRLF
			cQuery	+= "       (SELECT SUM(SRD.RD_VALOR) " + CRLF
			cQuery	+= "        FROM "+RetSqlName("SRD")+"  SRD, "+RetSqlName("SRA")+"  RA " + CRLF
			cQuery	+= "        WHERE SRD.RD_FILIAL = RA.RA_FILIAL "+ CRLF
			cQuery	+= "         AND SRD.RD_MAT = RA.RA_MAT "+ CRLF
			cQuery	+= "         AND SRD.RD_DATPGT BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

			if MV_PAR07 == '132'  
				cQuery	+= "         AND SRD.RD_ROTEIR  = '132' " + CRLF
			else
				cQuery	+= "         AND SRD.RD_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
			endif

			cQuery	+= "         AND SRD.RD_PD IN(SELECT SRV.RV_COD " + CRLF
			cQuery	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
			cQuery	+= "                          					  WHERE SRV.RV_CODFOL IN ('0066') "+ CRLF
			cQuery	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
			cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC "+ CRLF
			cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
			cQuery	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "         AND SRD.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "        ),0) FOL_RET_IRME, "  + CRLF
			cQuery	+= "        ISNULL( "+ CRLF
			cQuery	+= "        (SELECT SUM(T2I.T2I_VLIRRF) "+ CRLF
			cQuery	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I " + CRLF
			cQuery	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
			cQuery	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
			cQuery	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL "+ CRLF
			cQuery	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO "+ CRLF
			cQuery	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "          AND T2I.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID " + CRLF
			cQuery	+= "                                 FROM "+RetSqlName("C8U")+"  C8U " + CRLF
			cQuery	+= "                                 WHERE C8U.C8U_CODIGO = '31' " + CRLF
			cQuery	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) "+ CRLF
			cQuery	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
			cQuery	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
			cQuery	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
			cQuery	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
			cQuery	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
			cQuery	+= "          ),0) TAF_RET_IRME, "+ CRLF
			cQuery	+= "       ISNULL( "+ CRLF
			cQuery	+= "       (SELECT SUM(SRD.RD_VALOR) " + CRLF
			cQuery	+= "        FROM "+RetSqlName("SRD")+"  SRD, "+RetSqlName("SRA")+"  RA " + CRLF
			cQuery	+= "        WHERE SRD.RD_FILIAL = RA.RA_FILIAL "+ CRLF
			cQuery	+= "         AND SRD.RD_MAT = RA.RA_MAT "+ CRLF
			cQuery	+= "         AND SRD.RD_DATPGT BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

			if MV_PAR07 == '132'  
				cQuery	+= "         AND SRD.RD_ROTEIR  = '132' " + CRLF
			else
				cQuery	+= "         AND SRD.RD_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
			endif

			cQuery	+= "         AND SRD.RD_PD IN(SELECT SRV.RV_COD " + CRLF
			cQuery	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
			cQuery	+= "                          					  WHERE SRV.RV_CODFOL IN ('0071') "+ CRLF
			cQuery	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
			cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC "+ CRLF
			cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
			cQuery	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "         AND SRD.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "        ),0) FOL_RET_IR13, "  + CRLF
			cQuery	+= "        ISNULL( "+ CRLF
			cQuery	+= "        (SELECT SUM(T2I.T2I_VLIRRF) "+ CRLF
			cQuery	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I " + CRLF
			cQuery	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
			cQuery	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
			cQuery	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL "+ CRLF
			cQuery	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO "+ CRLF
			cQuery	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "          AND T2I.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID " + CRLF
			cQuery	+= "                                 FROM "+RetSqlName("C8U")+"  C8U " + CRLF
			cQuery	+= "                                 WHERE C8U.C8U_CODIGO = '32' " + CRLF
			cQuery	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) "+ CRLF
			cQuery	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
			cQuery	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
			cQuery	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
			cQuery	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
			cQuery	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
			cQuery	+= "          ),0) TAF_RET_IR13, "+ CRLF
			cQuery	+= "       ISNULL( "+ CRLF
			cQuery	+= "       (SELECT SUM(SRD.RD_VALOR) " + CRLF
			cQuery	+= "        FROM "+RetSqlName("SRD")+"  SRD, "+RetSqlName("SRA")+"  RA " + CRLF
			cQuery	+= "        WHERE SRD.RD_FILIAL = RA.RA_FILIAL "+ CRLF
			cQuery	+= "         AND SRD.RD_MAT = RA.RA_MAT "+ CRLF
			cQuery	+= "         AND SRD.RD_DATPGT BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

			if MV_PAR07 == '132'  
				cQuery	+= "         AND SRD.RD_ROTEIR  = '132' " + CRLF
			else
				cQuery	+= "         AND SRD.RD_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
			endif

			cQuery	+= "         AND SRD.RD_PD IN(SELECT SRV.RV_COD "  + CRLF
			cQuery	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV " + CRLF
			cQuery	+= "                          					  WHERE SRV.RV_CODFOL IN ('0067') " + CRLF
			cQuery	+= "                            					AND SRV.D_E_L_E_T_ <> '*') " + CRLF
			cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC " + CRLF
			cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT " + CRLF
			cQuery	+= "         AND RA.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "         AND SRD.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "        ),0) FOL_RET_IRFE, "   + CRLF
			cQuery	+= "        ISNULL( " + CRLF
			cQuery	+= "        (SELECT SUM(T2I.T2I_VLIRRF) " + CRLF
			cQuery	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I "  + CRLF
			cQuery	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC " + CRLF
			cQuery	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  " + CRLF
			cQuery	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL " + CRLF
			cQuery	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO " + CRLF
			cQuery	+= "          AND T2G.D_E_L_E_T_ <> '*' "  + CRLF
			cQuery	+= "          AND T2I.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID "  + CRLF
			cQuery	+= "                                 FROM "+RetSqlName("C8U")+"  C8U "  + CRLF
			cQuery	+= "                                 WHERE C8U.C8U_CODIGO = '33' "  + CRLF
			cQuery	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) " + CRLF
			cQuery	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) " + CRLF
			cQuery	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX " + CRLF
			cQuery	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN " + CRLF
			cQuery	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU "  + CRLF
			cQuery	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') "  + CRLF
			cQuery	+= "          ),0) TAF_RET_IRFE, " + CRLF
			cQuery	+= "       ISNULL( " + CRLF
			cQuery	+= "       (SELECT SUM(SRD.RD_VALOR) "  + CRLF
			cQuery	+= "        FROM "+RetSqlName("SRD")+"  SRD, "+RetSqlName("SRA")+"  RA "  + CRLF
			cQuery	+= "        WHERE SRD.RD_FILIAL = RA.RA_FILIAL " + CRLF
			cQuery	+= "         AND SRD.RD_MAT = RA.RA_MAT " + CRLF
			cQuery	+= "         AND SRD.RD_DATPGT BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' " + CRLF

			if MV_PAR07 == '132'  
				cQuery	+= "         AND SRD.RD_ROTEIR  = '132' "+ CRLF
			else
				cQuery	+= "         AND SRD.RD_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
			endif

			cQuery	+= "         AND SRD.RD_PD IN(SELECT SRV.RV_COD "  + CRLF
			cQuery	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV " + CRLF
			cQuery	+= "                          					  WHERE SRV.RV_CODFOL IN ('0064') " + CRLF
			cQuery	+= "                            					AND SRV.D_E_L_E_T_ <> '*') " + CRLF
			cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC " + CRLF
			cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT " + CRLF
			cQuery	+= "         AND RA.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "         AND SRD.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "        ),0) FOL_DED_IRME, "   + CRLF
			cQuery	+= "        ISNULL( " + CRLF
			cQuery	+= "        (SELECT SUM(T2I.T2I_VLIRRF) " + CRLF
			cQuery	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I "  + CRLF
			cQuery	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC " + CRLF
			cQuery	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  " + CRLF
			cQuery	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL " + CRLF
			cQuery	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO " + CRLF
			cQuery	+= "          AND T2G.D_E_L_E_T_ <> '*' "  + CRLF
			cQuery	+= "          AND T2I.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID "  + CRLF
			cQuery	+= "                                 FROM "+RetSqlName("C8U")+"  C8U "  + CRLF
			cQuery	+= "                                 WHERE C8U.C8U_CODIGO = '41' "  + CRLF
			cQuery	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) " + CRLF
			cQuery	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) " + CRLF
			cQuery	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX " + CRLF
			cQuery	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN " + CRLF
			cQuery	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU "  + CRLF
			cQuery	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') "  + CRLF
			cQuery	+= "          ),0) TAF_DED_IRME, " + CRLF
			cQuery	+= "       ISNULL( " + CRLF
			cQuery	+= "       (SELECT SUM(SRD.RD_VALOR) "  + CRLF
			cQuery	+= "        FROM "+RetSqlName("SRD")+"  SRD, "+RetSqlName("SRA")+"  RA "  + CRLF
			cQuery	+= "        WHERE SRD.RD_FILIAL = RA.RA_FILIAL " + CRLF
			cQuery	+= "         AND SRD.RD_MAT = RA.RA_MAT " + CRLF
			cQuery	+= "         AND SRD.RD_DATPGT BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' " + CRLF

			if MV_PAR07 == '132'  
				cQuery	+= "         AND SRD.RD_ROTEIR  = '132' " + CRLF
			else
				cQuery	+= "         AND SRD.RD_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
			endif

			cQuery	+= "         AND SRD.RD_PD IN(SELECT SRV.RV_COD " + CRLF
			cQuery	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
			cQuery	+= "                          					  WHERE SRV.RV_CODFOL IN ('0070') "+ CRLF
			cQuery	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
			cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC "+ CRLF
			cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
			cQuery	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "         AND SRD.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "        ),0) FOL_DED_IR13, "  + CRLF
			cQuery	+= "        ISNULL( "+ CRLF
			cQuery	+= "        (SELECT SUM(T2I.T2I_VLIRRF) "+ CRLF
			cQuery	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I " + CRLF
			cQuery	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
			cQuery	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
			cQuery	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL "+ CRLF
			cQuery	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO "+ CRLF
			cQuery	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "          AND T2I.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID " + CRLF
			cQuery	+= "                                 FROM "+RetSqlName("C8U")+"  C8U " + CRLF
			cQuery	+= "                                 WHERE C8U.C8U_CODIGO = '42' " + CRLF
			cQuery	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) "+ CRLF
			cQuery	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
			cQuery	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
			cQuery	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
			cQuery	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
			cQuery	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
			cQuery	+= "          ),0) TAF_DED_IR13, "+ CRLF
			cQuery	+= "       ISNULL( "+ CRLF
			cQuery	+= "       (SELECT SUM(SRD.RD_VALOR) " + CRLF
			cQuery	+= "        FROM "+RetSqlName("SRD")+"  SRD, "+RetSqlName("SRA")+"  RA " + CRLF
			cQuery	+= "        WHERE SRD.RD_FILIAL = RA.RA_FILIAL "+ CRLF
			cQuery	+= "         AND SRD.RD_MAT = RA.RA_MAT "+ CRLF
			cQuery	+= "         AND SRD.RD_DATPGT BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

			if MV_PAR07 == '132'  
				cQuery	+= "         AND SRD.RD_ROTEIR  = '132' " + CRLF
			else
				cQuery	+= "         AND SRD.RD_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
			endif

			cQuery	+= "         AND SRD.RD_PD IN(SELECT SRV.RV_COD " + CRLF
			cQuery	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
			cQuery	+= "                          					  WHERE SRV.RV_CODFOL IN ('0065') "+ CRLF
			cQuery	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
			cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC "+ CRLF
			cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
			cQuery	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "         AND SRD.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "        ),0) FOL_DED_IRFE, "  + CRLF
			cQuery	+= "        ISNULL( "+ CRLF
			cQuery	+= "        (SELECT SUM(T2I.T2I_VLIRRF) "+ CRLF
			cQuery	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I " + CRLF
			cQuery	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
			cQuery	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
			cQuery	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL "+ CRLF
			cQuery	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO "+ CRLF
			cQuery	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "          AND T2I.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID " + CRLF
			cQuery	+= "                                 FROM "+RetSqlName("C8U")+"  C8U " + CRLF
			cQuery	+= "                                 WHERE C8U.C8U_CODIGO = '43' " + CRLF
			cQuery	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) "+ CRLF
			cQuery	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
			cQuery	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
			cQuery	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
			cQuery	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
			cQuery	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
			cQuery	+= "          ),0) TAF_DED_IRFE, "+ CRLF
			cQuery	+= "       ISNULL( "+ CRLF
			cQuery	+= "       (SELECT SUM(SRD.RD_VALOR) " + CRLF
			cQuery	+= "        FROM "+RetSqlName("SRD")+"  SRD, "+RetSqlName("SRA")+"  RA " + CRLF
			cQuery	+= "        WHERE SRD.RD_FILIAL = RA.RA_FILIAL "+ CRLF
			cQuery	+= "         AND SRD.RD_MAT = RA.RA_MAT "+ CRLF
			cQuery	+= "         AND SRD.RD_DATPGT BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

			if MV_PAR07 == '132'  
				cQuery	+= "         AND SRD.RD_ROTEIR  = '132' " + CRLF
			else
				cQuery	+= "         AND SRD.RD_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
			endif

			cQuery	+= "         AND SRD.RD_PD IN(SELECT SRV.RV_COD " + CRLF
			cQuery	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
			cQuery	+= "                          					  WHERE SRV.RV_CODFOL IN ('0059') "+ CRLF
			cQuery	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
			cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC "+ CRLF
			cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
			cQuery	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "         AND SRD.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "        ),0) FOL_DED_DEPIRME, "  + CRLF
			cQuery	+= "        ISNULL( "+ CRLF
			cQuery	+= "        (SELECT SUM(T2I.T2I_VLIRRF) "+ CRLF
			cQuery	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I " + CRLF
			cQuery	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
			cQuery	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
			cQuery	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL "+ CRLF
			cQuery	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO "+ CRLF
			cQuery	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "          AND T2I.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID " + CRLF
			cQuery	+= "                                 FROM "+RetSqlName("C8U")+"  C8U " + CRLF
			cQuery	+= "                                 WHERE C8U.C8U_CODIGO = '56' " + CRLF
			cQuery	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) "+ CRLF
			cQuery	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
			cQuery	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
			cQuery	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
			cQuery	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
			cQuery	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
			cQuery	+= "          ),0) TAF_DED_DEPIRME, "+ CRLF
			cQuery	+= "       ISNULL( "+ CRLF
			cQuery	+= "       (SELECT SUM(SRD.RD_VALOR) " + CRLF
			cQuery	+= "        FROM "+RetSqlName("SRD")+"  SRD, "+RetSqlName("SRA")+"  RA " + CRLF
			cQuery	+= "        WHERE SRD.RD_FILIAL = RA.RA_FILIAL "+ CRLF
			cQuery	+= "         AND SRD.RD_MAT = RA.RA_MAT "+ CRLF
			cQuery	+= "         AND SRD.RD_DATPGT BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

			if MV_PAR07 == '132'  
				cQuery	+= "         AND SRD.RD_ROTEIR  = '132' " + CRLF
			else
				cQuery	+= "         AND SRD.RD_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
			endif

			cQuery	+= "         AND SRD.RD_PD IN(SELECT SRV.RV_COD " + CRLF
			cQuery	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
			cQuery	+= "                          					  WHERE SRV.RV_CODFOL IN ('0062') "+ CRLF
			cQuery	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
			cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC "+ CRLF
			cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
			cQuery	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "         AND SRD.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "        ),0) FOL_DED_DEPIR13, "  + CRLF
			cQuery	+= "        ISNULL( "+ CRLF
			cQuery	+= "        (SELECT SUM(T2I.T2I_VLIRRF) "+ CRLF
			cQuery	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I " + CRLF
			cQuery	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
			cQuery	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
			cQuery	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL "+ CRLF
			cQuery	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO "+ CRLF
			cQuery	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "          AND T2I.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID " + CRLF
			cQuery	+= "                                 FROM "+RetSqlName("C8U")+"  C8U " + CRLF
			cQuery	+= "                                 WHERE C8U.C8U_CODIGO = '57' " + CRLF
			cQuery	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) "+ CRLF
			cQuery	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
			cQuery	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
			cQuery	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
			cQuery	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
			cQuery	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
			cQuery	+= "          ),0) TAF_DED_DEPIR13, "+ CRLF
			cQuery	+= "       ISNULL( "+ CRLF
			cQuery	+= "       (SELECT SUM(SRD.RD_VALOR) " + CRLF
			cQuery	+= "        FROM "+RetSqlName("SRD")+"  SRD, "+RetSqlName("SRA")+"  RA " + CRLF
			cQuery	+= "        WHERE SRD.RD_FILIAL = RA.RA_FILIAL "+ CRLF
			cQuery	+= "         AND SRD.RD_MAT = RA.RA_MAT "+ CRLF
			cQuery	+= "         AND SRD.RD_DATPGT BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

			if MV_PAR07 == '132'  
				cQuery	+= "         AND SRD.RD_ROTEIR  = '132' " + CRLF
			else
				cQuery	+= "         AND SRD.RD_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
			endif

			cQuery	+= "         AND SRD.RD_PD IN(SELECT SRV.RV_COD " + CRLF
			cQuery	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV "+ CRLF
			cQuery	+= "                          					  WHERE SRV.RV_CODFOL IN ('0061','0062') "+ CRLF
			cQuery	+= "                            					AND SRV.D_E_L_E_T_ <> '*') "+ CRLF
			cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC "+ CRLF
			cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT "+ CRLF
			cQuery	+= "         AND RA.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "         AND SRD.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "        ),0) FOL_DED_DEPIRFE, "  + CRLF
			cQuery	+= "        ISNULL( "+ CRLF
			cQuery	+= "        (SELECT SUM(T2I.T2I_VLIRRF) "+ CRLF
			cQuery	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2I")+"  T2I " + CRLF
			cQuery	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC "+ CRLF
			cQuery	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  "+ CRLF
			cQuery	+= "          AND T2G.T2G_FILIAL = T2I.T2I_FILIAL "+ CRLF
			cQuery	+= "          AND T2G.T2G_VERSAO = T2I.T2I_VERSAO "+ CRLF
			cQuery	+= "          AND T2G.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "          AND T2I.D_E_L_E_T_ <> '*' "+ CRLF
			cQuery	+= "          AND T2I.T2I_CTPVAL IN (SELECT C8U_ID " + CRLF
			cQuery	+= "                                 FROM "+RetSqlName("C8U")+"  C8U " + CRLF
			cQuery	+= "                                 WHERE C8U.C8U_CODIGO = '58' " + CRLF
			cQuery	+= "                                  AND C8U.D_E_L_E_T_ <> '*' ) "+ CRLF
			cQuery	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) "+ CRLF
			cQuery	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX "+ CRLF
			cQuery	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN "+ CRLF
			cQuery	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU " + CRLF
			cQuery	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') " + CRLF
			cQuery	+= "          ),0) TAF_DED_DEPIRFE, "+ CRLF
			cQuery	+= "       ISNULL( "+ CRLF
			cQuery	+= "       (SELECT SUM(SRD.RD_VALOR) " + CRLF
			cQuery	+= "        FROM "+RetSqlName("SRD")+"  SRD, "+RetSqlName("SRA")+"  RA " + CRLF
			cQuery	+= "        WHERE SRD.RD_FILIAL = RA.RA_FILIAL "+ CRLF
			cQuery	+= "         AND SRD.RD_MAT = RA.RA_MAT "+ CRLF
			cQuery	+= "         AND SRD.RD_DATPGT BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31' "+ CRLF

			if MV_PAR07 == '132' 
				cQuery	+= "         AND SRD.RD_ROTEIR  = '132' "+ CRLF
			else
				cQuery	+= "         AND SRD.RD_ROTEIR  = (CASE WHEN SRA.RA_PROCES = '00003' THEN 'AUT' ELSE 'FOL' END)  "+ CRLF
			endif

			cQuery	+= "         AND SRD.RD_PD IN(SELECT SRV.RV_COD "  + CRLF
			cQuery	+= "                          					  FROM "+RetSqlName("SRV")+"  SRV " + CRLF
			cQuery	+= "                           					  WHERE SRV.RV_CODFOL IN ('0066','0071','0067') " + CRLF
			cQuery	+= "                            					AND SRV.D_E_L_E_T_ <> '*') " + CRLF
			cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC "  + CRLF
			cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT " + CRLF
			cQuery	+= "         AND RA.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "         AND SRD.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "        ),0) FOL_RET_IRTOT, "   + CRLF
			cQuery	+= "        ISNULL( " + CRLF
			cQuery	+= "        (SELECT SUM(T2J.T2J_VLDESC) " + CRLF
			cQuery	+= "         FROM "+RetSqlName("T2G")+"  T2G, "+RetSqlName("T2J")+"  T2J "  + CRLF
			cQuery	+= "         WHERE T2G.T2G_CPFBEN = SRA.RA_CIC " + CRLF
			cQuery	+= "          AND T2G.T2G_PERAPU = '"+cPerTaf+"'  " + CRLF
			cQuery	+= "          AND T2G.T2G_FILIAL = T2J.T2J_FILIAL " + CRLF
			cQuery	+= "          AND T2G.T2G_VERSAO = T2J.T2J_VERSAO " + CRLF
			cQuery	+= "          AND T2G.D_E_L_E_T_ <> '*' "  + CRLF
			cQuery	+= "          AND T2J.D_E_L_E_T_ <> '*' " + CRLF
			cQuery	+= "          AND T2J.T2J_CTPCR IN (SELECT C6R_ID " + CRLF
			cQuery	+= "                                FROM "+RetSqlName("C6R")+"  C6R "  + CRLF
			cQuery	+= "                                WHERE C6R.C6R_CODIGO = '999999' "  + CRLF
			cQuery	+= "                                 AND C6R.D_E_L_E_T_ <> '*' ) " + CRLF
			cQuery	+= "          AND T2G.R_E_C_N_O_ IN (SELECT MAX(T2GX.R_E_C_N_O_) " + CRLF
			cQuery	+= "                                 FROM "+RetSqlName("T2G")+"  T2GX " + CRLF
			cQuery	+= "                                 WHERE T2GX.T2G_CPFBEN = T2G.T2G_CPFBEN " + CRLF
			cQuery	+= "                                  AND T2GX.T2G_PERAPU = T2G.T2G_PERAPU "  + CRLF
			cQuery	+= "                                  AND T2GX.D_E_L_E_T_ <> '*') "  + CRLF
			cQuery	+= "          ),0) TAF_RET_IRTOT " + CRLF
			cQuery	+= " FROM  "+RetSqlName("SRA")+"  SRA " + CRLF
			cQuery	+= " WHERE SRA.D_E_L_E_T_ <> '*' "  + CRLF
			cQuery	+= "  AND EXISTS " + CRLF
			cQuery	+= "  (SELECT * " + CRLF
			cQuery	+= "   FROM  "+RetSqlName("SRD")+"  SRD " + CRLF

			IF !Empty(MV_PAR01)
				cQuery	+= "   WHERE SRD.RD_FILIAL = '"+MV_PAR01+"' "+ CRLF
				cQuery	+= "   	AND SRD.RD_FILIAL = SRA.RA_FILIAL "+ CRLF
			else 
				cQuery	+= "   WHERE SRD.RD_FILIAL = SRA.RA_FILIAL "+ CRLF
			endif 

			if !Empty(MV_PAR03)
				cQuery	+= "    AND SRD.RD_MAT BETWEEN '"+MV_PAR03+"' AND '"+iif(AllTrim(MV_PAR04) != '',MV_PAR04,'ZZZZZZZ')+"' "+ CRLF
				cQuery	+= "    AND SRD.RD_MAT = SRA.RA_MAT "+ CRLF
			else 
				cQuery	+= "    AND SRD.RD_MAT = SRA.RA_MAT "+ CRLF
			endif 

			cQuery	+= "    AND SRD.RD_PERIODO = '"+MV_PAR05+"' "+ CRLF

			if !Empty(MV_PAR06)
				cQuery	+= "    and SRD.RD_CC = '"+MV_PAR06+"' "+ CRLF
			endif

			if MV_PAR07 == '132' 
				cQuery	+= "         AND SRD.RD_ROTEIR  = '132' "+ CRLF
			else
				cQuery	+= "         AND SRD.RD_ROTEIR IN ('AUT','FOL') "+ CRLF
			endif

			cQuery	+= "    AND SRD.D_E_L_E_T_ <> '*' ) " + CRLF
			cQuery	+= " ) X   "+ CRLF

			cQuery	+= "ORDER BY FILIAL,MAT_FOLHA " + CRLF

			cQuery	:= Upper(cQuery)	

			If !ExistDir( "C:\#QUERY" )

				MakeDir( "C:\#QUERY" )
			EndIf

			MEMOWRITE( "C:\#QUERY\RHES5002.SQL", cQuery )

			If Select(cTab) > 0
				(cTab)->(DbCloseArea())
			EndIf
			TCQUERY cQuery ALIAS (cTab) NEW
			(cTab)->(DbGoTop())
			Count To nTotReg 
			if nTotReg < 1
				MsgStop('Não existem registros para essa consulta, favor verificar os parâmetros!')
				return
			endif
			(cTab)->(dbGoTop())
			nTotReg += 2
			ProcRegua(nTotReg)

			nRegAtu++
			IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")	

			oExcel := ARSexcel():New()
			oExcel:AddPlanilha('Relatorio',{20,50,50,170,70,50,140,50,70,70,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,120,80,20},6)
			oExcel:AddLinha(20)
			oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,49) 
			oExcel:AddLinha(15)
			oExcel:AddCelula( dtoc(DATE()),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,49) 
			oExcel:AddLinha(15)
			oExcel:AddLinha(20)
			oExcel:AddCelula(cTitulo+" - Periodo: "+substr(MV_PAR05,1,4)+"-"+substr(MV_PAR05,5,2),0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,49)  
					
			oExcel:AddLinha(20)
			oExcel:AddLinha(12) 
			oExcel:AddCelula()  
			oExcel:AddCelula("Filial"  							,0,'L',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
			oExcel:AddCelula("Mat. Folha"  						,0,'L',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
			oExcel:AddCelula("Nome"	  							,0,'L',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
			oExcel:AddCelula("CPF"								,0,'L',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
			oExcel:AddCelula("ID TAF"							,0,'L',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
			oExcel:AddCelula("Mat. TAF"	  						,0,'L',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
			oExcel:AddCelula("Situacao"							,0,'L',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
			oExcel:AddCelula("Admissao"	  						,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
			oExcel:AddCelula("Demissao"							,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)

			oExcel:AddCelula("FOL- Base IRRF Mes"           	,0,'R',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
			oExcel:AddCelula("TAF- Base IRRF Mes"	            ,0,'R',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
			oExcel:AddCelula("Dif. Base IRRF Mensal"        	,0,'R',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)

			oExcel:AddCelula("FOL- Base IRRF 13 Sal"    	    ,0,'R',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
			oExcel:AddCelula("TAF- Base IRRF 13 Sal"    	    ,0,'R',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
			oExcel:AddCelula("Dif. Base IRRF 13"             	,0,'R',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)

			oExcel:AddCelula("FOL-Ret. IRRF Mensal"				,0,'R',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
			oExcel:AddCelula("TAF-Ret. IRRF Mensal"				,0,'R',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
			oExcel:AddCelula("Dif. Ret. IRRF Mensal"			,0,'R',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)

			oExcel:AddCelula("FOL-Ret. IRRF 13"					,0,'R',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
			oExcel:AddCelula("TAF-Ret. IRRF 13"	    			,0,'R',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
			oExcel:AddCelula("Dif. Ret. IRRF 13"				,0,'R',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
	
			While !(cTab)->(Eof())
				
				nRegAtu++
				
				if Empty((cTab)->ADMISSAO)
					cTemp1 := "" 
				else
					cTemp1 := dtoc(STOD((cTab)->ADMISSAO))
				endif
					
				if Empty((cTab)->DEMISSAO)
					cTemp2 := "" 
				else
					cTemp2 := dtoc(STOD((cTab)->DEMISSAO))
				endif	

				nBasFer := 0
				nBasFer := fBuscaFer((cTab)->FILIAL,(cTab)->MAT_FOLHA,'1')

				nDescFer := fBuscaFer((cTab)->FILIAL,(cTab)->MAT_FOLHA,'2')

				oExcel:AddLinha(14) 
				oExcel:AddCelula()   

				cCorFun2 := "#FFFFFF"
				oExcel:AddCelula( (cTab)->FILIAL	 	,0		 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
				oExcel:AddCelula( (cTab)->MAT_FOLHA	 	,0		 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
				oExcel:AddCelula( (cTab)->NOME	 		,0		 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
				oExcel:AddCelula( (cTab)->CPF	 		,0		 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
				oExcel:AddCelula( (cTab)->ID_TAF	 	,0		 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
				oExcel:AddCelula( (cTab)->MAT_TAF	 	,0		 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
				oExcel:AddCelula( (cTab)->SITUACAO	 	,0		 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
				oExcel:AddCelula( cTemp1				,0		 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
				oExcel:AddCelula( cTemp2				,0		 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
				
				oExcel:AddCelula( (cTab)->FOLBASEME	+ nBasFer	,nDec1	 ,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
				oExcel:AddCelula( (cTab)->TAFBASEME		,nDec1	 ,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
				
				//Verifica se existe diferença
				nDifBMes := 0
				nDifBMes :=  ((cTab)->FOLBASEME	+ nBasFer) - (cTab)->TAFBASEME
				cCorFun2 := "#FFFFFF"
				if nDifBMes > 0.03 .or. nDifBMes < -0.03
					cCorFun2 := "#FF0000"
				endif	 
				oExcel:AddCelula( nDifBMes		,nDec1	 ,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
				
				cCorFun2 := "#FFFFFF"
				oExcel:AddCelula( (cTab)->FOLBASE13		,nDec1	 ,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
				oExcel:AddCelula( (cTab)->TAFBASE13		,nDec1	 ,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
				
				//Verifica se existe diferença
				nDifB13 := 0
				nDifB13 :=  (cTab)->FOLBASE13 - (cTab)->TAFBASE13
				cCorFun2 := "#FFFFFF"
				if nDifB13 > 0.03 .or. nDifB13 < -0.03
					cCorFun2 := "#FF0000"
				endif	 
				oExcel:AddCelula( nDifB13		,nDec1	 ,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)
				
				cCorFun2 := "#FFFFFF"
				oExcel:AddCelula( (cTab)->FOLRETME + nDescFer		,nDec1	 ,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
				oExcel:AddCelula( (cTab)->TAFRETME		,nDec1	 ,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
				
				//Verifica se existe diferença
				nDifRMes := 0
				nDifRMes :=  ((cTab)->FOLRETME + nDescFer) - (cTab)->TAFRETME
				cCorFun2 := "#FFFFFF"
				if nDifRMes > 0.03 .or. nDifRMes < -0.03
					cCorFun2 := "#FF0000"
				endif	 
				oExcel:AddCelula( nDifRMes		,nDec1	 ,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)

				
				cCorFun2 := "#FFFFFF"
				oExcel:AddCelula( (cTab)->FOLRET13		,nDec1	 ,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
				oExcel:AddCelula( (cTab)->TAFRET13		,nDec1	 ,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
				
				//Verifica se existe diferença
				nDifR13 := 0
				nDifR13 :=  (cTab)->FOLRET13 - (cTab)->TAFRET13	
				cCorFun2 := "#FFFFFF"
				if nDifR13 > 0.03 .or. nDifR13 < -0.03
					cCorFun2 := "#FF0000"
				endif	 
				oExcel:AddCelula( nDifR13		,nDec1	 ,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)

				IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")	

				(cTab)->(DbSkip())                
			EndDo    
			//fGeraParametros(cTitulo,cPerg)
			oExcel:SaveXml(MV_PAR05,cArqXML,.T.) 
			nRegAtu++
			IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(100,3)) + "%")	
		//endif
	endif	
return


//Gera parametros
Static Function fGeraParametros(cTitulo,cPerg)
local nContReg   := 0 
local cCorFundo  := ""
local cTemp 	 := ""
local cFonte     := 'Arial' 
local cCorFontPd := '#000000'
ProcRegua(0)  
If !Empty(cPerg)

	oExcel:AddPlanilha('Parametros',{30,80,120,120})
	oExcel:AddLinha(30)
	oExcel:AddCelula(cTitulo,0,'C',cFonte,14,'#FFFFFF',,,'#4F81BD',,,,,.T.,2,2) 
	oExcel:AddLinha(20)
	oExcel:AddLinha(20) 
	oExcel:AddCelula()
	oExcel:AddCelula("Sequencia",0,'L',cFonte,10,cCorFontPd,.T.,.T.,'#4F81BD',.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Pergunta" ,0,'L',cFonte,10,cCorFontPd,.T.,.T.,'#4F81BD',.T.,.T.,.T.,.T.) 
	oExcel:AddCelula("Conteudo" ,0,'L',cFonte,10,cCorFontPd,.T.,.T.,'#4F81BD',.T.,.T.,.T.,.T.) 
	DbSelectArea("SX1")
	DbSetOrder(1)
	If MsSeek(Padr(cPerg,Len(X1_GRUPO),""))
		While !(SX1->(Eof())) .And. SX1->X1_GRUPO == Padr(cPerg,Len(X1_GRUPO),"")
			
			nContReg++ 
			if MOD(nContReg,2) > 0 
		        cCorFundo := '#DCE6F1'	
			else
				cCorFundo := '#B8CCE4'	
			endif	  

			oExcel:AddLinha(20) 
			oExcel:AddCelula()
			oExcel:AddCelula(SX1->X1_ORDEM,0,'L',cFonte,10,cCorFontPd,,,cCorFundo,.T.,.T.,.T.,.T.) // Seguencia
			oExcel:AddCelula(SX1->X1_PERGUNT,0,'L',cFonte,10,cCorFontPd,,,cCorFundo,.T.,.T.,.T.,.T.) // Pergunta
			
			if SX1->X1_TIPO == "N"
				If SX1->X1_GSC == "C"
					cTemp := &("SX1->X1_DEF0"+AllTrim(Str(&(SX1->X1_VAR01))))
				Else
					cTemp := &(SX1->X1_VAR01)
				EndIf 
			else
				cTemp := Alltrim(cValtoChar(&(SX1->X1_VAR01)))
			endif		            
		
			oExcel:AddCelula(cTemp,0,'L',cFonte,10,cCorFontPd,,,cCorFundo,.T.,.T.,.T.,.T.) // Conteudo 
			SX1->(DbSkip())
		End	
	EndIf	
EndIf
Return

Static Function GeraX1(cPerg)

Local _aArea	:= GetArea()
Local aRegs     := {}
Local nX		:= 0
Local nPergs	:= 0
Local i, j

//Conta quantas perguntas existem ualmente.
DbSelectArea('SX1')
DbSetOrder(1)
SX1->(DbGoTop())
If SX1->(DbSeek(cPerg))
	While !SX1->(Eof()) .And. X1_GRUPO = cPerg
		nPergs++
		SX1->(DbSkip())
	EndDo
EndIf

aAdd(aRegs,{cPerg, "01", "Filial de"        , "", "", "MV_CH1", "C" , 7, 0, 0 , "G", "", "MV_PAR01", "", "", "", ""         , "", "","","","","","","","","","","","","","","","","","","","SM0","S","","","","",{"Informe o código da filial desejada ou deixe em branco."     , "<F3 Disponivel>"}})
aAdd(aRegs,{cPerg, "02", "Filial até"       , "", "", "MV_CH2", "C" , 7, 0, 0 , "G", "", "MV_PAR02", "", "", "", "ZZZZZZZ"  , "", "","","","","","","","","","","","","","","","","","","","SM0","S","","","","",{"Informe o código da filial desejada ou deixe em branco."     , "<F3 Disponivel>"}})
aAdd(aRegs,{cPerg, "03", "Matrícula de"     , "", "", "MV_CH3", "C" , 6, 0, 0 , "G", "", "MV_PAR03", "", "", "", ""         , "", "","","","","","","","","","","","","","","","","","","","SRA","S","","","","",{"Informe a mátricula desejada ou deixe em branco."            , "<F3 Disponivel>"}})
aAdd(aRegs,{cPerg, "04", "Matrícula até"    , "", "", "MV_CH4", "C" , 6, 0, 0 , "G", "", "MV_PAR04", "", "", "", "ZZZZZZ"   , "", "","","","","","","","","","","","","","","","","","","","SRA","S","","","","",{"Informe a mátricula desejada ou deixe em branco."            , "<F3 Disponivel>"}})
aAdd(aRegs,{cPerg, "05", "Periodo (AAAAMM)" , "", "", "MV_CH5", "C" , 6, 0, 0 , "G", "", "MV_PAR05", "", "", "", ""         , "", "","","","","","","","","","","","","","","","","","","",""   ,"S","","","","",{"Informe a data desejada ou deixe em branco."                 , "<F3 Disponivel>"}})
aAdd(aRegs,{cPerg, "06", "Centro de Custo"  , "", "", "MV_CH6", "C" , 60, 0, 0, "G", "", "MV_PAR06", "", "", "", ""         , "", "","","","","","","","","","","","","","","","","","","","C1P","S","","","","",{"Informe o centro de custo desejada ou deixe em branco."      , "<F3 Disponivel>"}})
aAdd(aRegs,{cPerg, "07", "Roteiro"  		, "", "", "MV_CH7", "C" , 3, 0, 0 , "G", "", "MV_PAR07", "", "", "", ""         , "", "","","","","","","","","","","","","","","","","","","",""	,"s","","","","",{"Informe o centro de custo desejada ou deixe em branco."      , "<F3 Disponivel>"}})
//aAdd(aRegs,{cPerg, "08", "Situação"         , "", "", "MV_CH8", "C" , 60, 0, 0, "K", "", "MV_PAR08", "ATIVO", "", "", "", "", "DEMITIDO","","","","","AFASTADO","","","","","FERIAS","","","","","","","","","","U","","","",""})

//Se quantidade de perguntas for diferente, apago todas
SX1->(DbGoTop())
If nPergs <> Len(aRegs)
	For nX:=1 To nPergs
		If SX1->(DbSeek(cPerg))
			If RecLock('SX1',.F.)
				SX1->(DbDelete())
				SX1->(MsUnlock())
			EndIf
		EndIf
	Next nX
EndIf

// gravação das perguntas na tabela SX1
If nPergs <> Len(aRegs)
	dbSelectArea("SX1")
	dbSetOrder(1)
	For i := 1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
				For j := 1 to FCount()
					If j <= Len(aRegs[i])
						FieldPut(j,aRegs[i,j])
					Endif
				Next j
			MsUnlock()
		EndIf
	Next i
EndIf

RestArea(_aArea)

Return nil

/* Static Function fPergunte()

Local cLoad	    := "RHES5002" + cEmpAnt
Local lRet		:= .F.

MV_PAR03 := Space( TamSx3( "RA_MAT"    )[1] )
MV_PAR04 := Space( TamSx3( "RA_MAT"    )[1] )
MV_PAR03 := Space( 06 )
MV_PAR04 := Space( 03 )
MV_PAR05 := Space( 200 )


aAdd( aPergs, { 1, "Matrícula De "              , MV_PAR03  , ""          , ".T."                                  , 'SRA', '.T.', 070, .F. } )
aAdd( aPergs, { 1, "Matrícula Até"              , MV_PAR02  , ""          , "NAOVAZIO()"                           , 'SRA', '.T.', 070, .F. } )
aAdd( aPergs, { 1, "Periodo (AAAAMM):"          , MV_PAR03  , ""          , "NAOVAZIO()"                           , ''   , '.T.', 040, .F. } )
aAdd( aPergs, { 1, "Roteiro:"                   , MV_PAR04  , ""          , "NAOVAZIO()"                           , ''   , '.T.', 040, .F. } )
aAdd( aPergs ,{ 6, "Pasta Destino"              , "c:\temp\", ""          , "GetDire()"                            ,      ,        100, .F., " ", "C:\temp\", 128 + 16 } )



If ParamBox( aPergs, "Planilha de IRRF",,,,,,,, cLoad, .T., .T. )  

    lRet := .T.

 	If Empty( MV_PAR05 )

		MV_PAR05 := AllTrim( GetTempPath() )
	EndIf
EndIf


Return lRet */

STATIC FUNCTION FBUSCAFER(cFil,cMat,cTipo)

Local nRet := 0

cQry := GetnextAlias()

cQuery := "SELECT RR_FILIAL, RR_MAT, SUM(RR_VALOR) AS TOTAL                         "  
cQuery += "FROM " + RetSqlName("SRR") + " SRR, " + RetSqlName("SRV") + " SRV        " 
cQuery += " WHERE     SRR.D_E_L_E_T_ = ' '                                          "
cQuery += "       AND SRV.D_E_L_E_T_ = ' '                                          "
cQuery += "       AND RV_COD = RR_PD                                                "

IF cTipo = '1'
   cQuery += "       AND RV_CODFOL IN ('0016','0168')                               "
ELSE
   cQuery += "       AND RV_CODFOL IN ('0067','0237','0101')                        "
ENDIF

cQuery += "       AND RR_ROTEIR = 'FER'                                             "
cQuery += "       AND RR_DATAPAG BETWEEN '"+MV_PAR05+"01' AND '"+MV_PAR05+"31'      "
cQuery += "       AND RR_FILIAL = '"+cFil+"'  AND RR_MAT = '"+cMat+"'    "
cQuery += "GROUP BY RR_FILIAL, RR_MAT  " 

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cQry, .T., .T.)
DbSelectarea(cQry)

while !(cQry)->(eof())

   nRet  += (cQry)->TOTAL
   dbskip()

end
           
DBCLOSEAREA()


RETURN(nRet)
