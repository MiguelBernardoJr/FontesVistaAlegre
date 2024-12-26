#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} NGPER015
Relatório TAF x Folha

@author Jorge Paiva
@since 28/07/2020
/*/
User Function NGPER015()

Local aArea    := GetArea()
Private oExcel := nil 
private aPergs := {}
 
Processa({|| fProcRel()},"Aguarde...","Carregando Registros...")

RestArea(aArea)  
return   

      
Static Function fProcRel()

Local cTab     	:= GetNextAlias() 
local cEmpresa  := CapitalAce(SM0->M0_NOMECOM) 
local cTitulo   := "Relatório de Folha x TAF"  
local nRegAtu   := 0
local nTotReg   := 0
local cChave	:= ''
local cArqXML   := "RELTAF_"+ALLTrim( DTOS(DATE())+"_"+StrTran( time(),':',''))
local cQuery	:= ''
local nDec1		:= TamSX3("RD_VALOR")[2]
local nDec2		:= 2
local nDec3		:= 8
local cPrefixo  := ""
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

ProcRegua(0)

If !fPergunte()
	Return
endif

if MV_PAR04 == '132' 
	cPerTaf	:= substr(MV_PAR03,1,4)
else
	cPerTaf	:= MV_PAR03
endif	

If Select(cTab) > 0
	(cTab)->(DbCloseArea())
EndIf

cQuery	:= " SELECT count(*) XCONT " 
cQuery	+= " FROM "+RetSqlName("SRD")+" SRD "
//cQuery	+= " WHERE SRD.RD_FILIAL = '" + xFilial("SRD") + "' "
cQuery	+= "  WHERE SRD.RD_PERIODO = '" + MV_PAR03 + "' "
cQuery	+= "  AND SRD.RD_ROTEIR = '" + UPPER(MV_PAR04) + "' "
cQuery	+= "  AND SRD.D_E_L_E_T_ = ' ' "
TCQUERY cQuery ALIAS (cTab) NEW
(cTab)->(dbGotop())

if (cTab)->XCONT > 0
	cPrefixo := "RD"
else
	If Select(cTab) > 0
		(cTab)->(DbCloseArea())
	EndIf
	cQuery	:= " SELECT count(*) XCONT " 
	cQuery	+= " FROM "+RetSqlName("SRC")+" SRC "
	///cQuery	+= " WHERE SRC.RC_FILIAL = '" + xFilial("SRC") + "' "
	cQuery	+= "  WHERE SRC.RC_PERIODO = '" + MV_PAR03 + "' "
	cQuery	+= "  AND SRC.RC_ROTEIR = '" + UPPER(MV_PAR04) + "' "
	cQuery	+= "  AND SRC.D_E_L_E_T_ = ' ' "
	TCQUERY cQuery ALIAS (cTab) NEW
	(cTab)->(dbGotop())
	if (cTab)->XCONT > 0
		cPrefixo := "RC"
	endif	
endif

If empty(cPrefixo)
	MsgStop("Informações não encontradas para o periodo (" +MV_PAR03+ "), verifique os parâmetros! " )
	Return
endif

cQuery	:= " SELECT "  +CRLF +;
cQuery	+= "        Y.FILIAL, " +CRLF +;
cQuery	+= "        Y.DIF_BASE, " +CRLF +;
cQuery	+= "        Y.DIF_DESCONT , " +CRLF +;
cQuery	+= "        Y.FOL_LIQ - Y.TAF_LIQ_1210 DIF_LIQUIDO,  " +CRLF +;
cQuery	+= "        Y.VAL_134, " +CRLF +;
cQuery	+= "        Y.VAL_147, " +CRLF +;
cQuery	+= "        Y.VAL_218, " +CRLF +;
cQuery	+= "        Y.VAL_164, " +CRLF +;
cQuery	+= "        Y.VAL_122, " +CRLF +;
cQuery	+= "        Y.VAL_123, "  +CRLF +;
cQuery	+= "        Y.DIS_VAL_134_147, " +CRLF +;
cQuery	+= "        Y.DIS_FOL_VAL_134_147, " +CRLF +;
cQuery	+= "        Y.FOL_BASE_SUSPENSAO, " +CRLF +;
cQuery	+= "        Y.TAF_BASE_SUSPENSAO, " +CRLF +;
cQuery	+= "        Y.FOL_SAL_FAMILIA, " +CRLF +;
cQuery	+= "        Y.FOL_AUX_MATER, " +CRLF +;
cQuery	+= "        Y.FOL_MEDIA_SAL_MATER, " +CRLF +;
cQuery	+= "        Y.PERC_AC_TRAB, " +CRLF +;
cQuery	+= "        Y.OCORR_SEFIP, " +CRLF +;
cQuery	+= "        Y.MAT_FOLHA, " +CRLF +;
cQuery	+= "        Y.NOME, " +CRLF +;
cQuery	+= "        Y.CPF, " +CRLF +;
cQuery	+= "        Y.PIS, " +CRLF +;
cQuery	+= "        Y.ID_TAF, " +CRLF +;
cQuery	+= "        Y.MAT_TAF, " +CRLF +;
cQuery	+= "        Y.SITUACAO, " +CRLF +;
cQuery	+= "        Y.ADMISSAO, " +CRLF +;
cQuery	+= "        Y.DEMISSAO, " +CRLF +;
cQuery	+= "        Y.FOL_LIQ LIQFOL, " +CRLF +;
cQuery	+= "        Y.TAF_LIQ_1210 LIQ1210, "  +CRLF +;
cQuery	+= "        Y.FOL_BASE_INSS BASEINSSF, " +CRLF +;
cQuery	+= "        Y.TAF_BASE_INSS BASEINSST, " +CRLF +;
cQuery	+= "        Y.FOL_DESC_INSS DESCINSSF, " +CRLF +;
cQuery	+= "        Y.TAF_DESC_INSS DESCINSST, " +CRLF +;
cQuery	+= "        Y.C_CUSTO, " +CRLF +;
cQuery	+= "        Y.C_CUSTO_DESC, " +CRLF +;
cQuery	+= "        Y.FOL_PROTOC_1200, " +CRLF +;
cQuery	+= "        Y.RES_PROTOC_1200 " +CRLF +;
cQuery	+= " FROM ( " +CRLF +;
cQuery	+= " SELECT "  +CRLF +;
cQuery	+= "        X.FILIAL, " +CRLF +;
cQuery	+= "        X.FOL_BASE_INSS-X.TAF_BASE_INSS DIF_BASE, " +CRLF +;
cQuery	+= "        X.FOL_DESC_INSS-X.TAF_DESC_INSS DIF_DESCONT, " +CRLF +;
cQuery	+= "        X.MAT_FOLHA, " +CRLF +;
cQuery	+= "        X.NOME, " +CRLF +;
cQuery	+= "        X.CPF, " +CRLF +;
cQuery	+= "        X.ID_TAF, " +CRLF +;
cQuery	+= "        X.MAT_TAF, " +CRLF +;
cQuery	+= "        x.PIS, " +CRLF +;
cQuery	+= "        X.SITUACAO, " +CRLF +;
cQuery	+= "        X.ADMISSAO, " +CRLF +;
cQuery	+= "        X.DEMISSAO, " +CRLF +;
cQuery	+= "        X.FOL_LIQ, " +CRLF +;
cQuery	+= "        NVL( " +CRLF +;
cQuery	+= "         (SELECT SUM(T3R.T3R_VLRLIQ) " +CRLF +;
cQuery	+= "          FROM "+RetSqlName("T3P")+" T3P,"+RetSqlName("T3Q")+" T3Q, "+RetSqlName("T3R")+" T3R " +CRLF +;
cQuery	+= "          WHERE T3P.T3P_FILIAL = X.FILIAL " +CRLF +;
cQuery	+= "           AND T3P.T3P_BENEFI = X.ID_TAF " +CRLF +;
cQuery	+= "           AND T3P.T3P_PERAPU = '"+cPerTaf+"' " +CRLF +;
cQuery	+= "           AND T3P.T3P_ATIVO = '1' " +CRLF +;
cQuery	+= "           AND T3P.T3P_STATUS = '4' "    +CRLF +;
cQuery	+= "           AND T3P.D_E_L_E_T_ = ' ' "    +CRLF +;
cQuery	+= "           AND T3Q.T3Q_FILIAL = T3P.T3P_FILIAL " +CRLF +;
cQuery	+= "           AND T3Q.T3Q_ID = T3P.T3P_ID " +CRLF +;
cQuery	+= "           AND T3Q.T3Q_VERSAO = T3P.T3P_VERSAO " +CRLF +;
cQuery	+= "           AND T3Q.D_E_L_E_T_ = ' ' "    +CRLF +;
cQuery	+= "           AND T3R.T3R_FILIAL = T3Q.T3Q_FILIAL " +CRLF +;
cQuery	+= "           AND T3R.T3R_ID = T3Q.T3Q_ID " +CRLF +;
cQuery	+= "           AND T3R.T3R_VERSAO = T3Q.T3Q_VERSAO " +CRLF +;
cQuery	+= "           AND T3R.T3R_TPPGTO = T3Q.T3Q_TPPGTO " +CRLF +;
cQuery	+= "           and T3Q.T3Q_DTPGTO = T3R.T3R_DTPGTO " +CRLF +;
cQuery	+= "           AND ( "  +CRLF +;
cQuery	+= "                (T3R.T3R_IDEDMD LIKE '%' || '"+cPerTaf+"' || 'FOL%' AND T3Q.T3Q_TPPGTO = '1'  ) "  +CRLF +;
cQuery	+= "                or "  +CRLF +;
cQuery	+= "                (T3R.T3R_IDEDMD LIKE '%' || '"+cPerTaf+"' || 'AUT%' AND T3Q.T3Q_TPPGTO = '1'  ) "  +CRLF +;
cQuery	+= "                or "  +CRLF +;
cQuery	+= "                (substring(T3R.T3R_IDEDMD,1,1) = 'R' AND T3Q.T3Q_TPPGTO = '2'  ) "  +CRLF +;
cQuery	+= "                ) " +CRLF +;
cQuery	+= "           AND T3R.D_E_L_E_T_ = ' ' ),0) TAF_LIQ_1210, "  +CRLF +;
cQuery	+= "        X.FOL_BASE_INSS, " +CRLF +;
cQuery	+= "        X.TAF_BASE_INSS, " +CRLF +;
cQuery	+= "        X.FOL_DESC_INSS, " +CRLF +;
cQuery	+= "        X.TAF_DESC_INSS, " +CRLF +;
cQuery	+= "        X.VAL_134, " +CRLF +;
cQuery	+= "        X.VAL_147, " +CRLF +;
cQuery	+= "        X.VAL_218, " +CRLF +;
cQuery	+= "        X.VAL_164, " +CRLF +;
cQuery	+= "        X.VAL_122, " +CRLF +;
cQuery	+= "        X.VAL_123, " +CRLF +;
cQuery	+= "        X.DIS_VAL_134_147, " +CRLF +;
cQuery	+= "        X.DIS_FOL_VAL_134_147, " +CRLF +;
cQuery	+= "        (CASE "  +CRLF +;
cQuery	+= "            WHEN X.DIS_VAL_134_147 > 0 "  +CRLF +;
cQuery	+= "             THEN X.DIS_VAL_134_147 + X.VAL_134 + X.VAL_147 "  +CRLF +;
cQuery	+= "            ELSE X.VAL_134 + X.VAL_147 "  +CRLF +;
cQuery	+= "        END) "  +CRLF +;
cQuery	+= "        FOL_BASE_SUSPENSAO, " +CRLF +;
cQuery	+= "        X.FOL_SAL_FAMILIA, " +CRLF +;
cQuery	+= "        X.FOL_AUX_MATER, " +CRLF +;
cQuery	+= "        X.FOL_MEDIA_SAL_MATER, " +CRLF +;
cQuery	+= "        X.TAF_BASE_SUSPENSAO, " +CRLF +;
cQuery	+= "        X.PERC_AC_TRAB, " +CRLF +;
cQuery	+= "        X.OCORR_SEFIP, " +CRLF +;
cQuery	+= "        X.C_CUSTO, " +CRLF +;
cQuery	+= "        X.C_CUSTO_DESC, " +CRLF +;
cQuery	+= "        ( SELECT MAX(C91.C91_PROTUL) "    +CRLF +;
cQuery	+= "          FROM "+RetSqlName("C91")+" C91  " +CRLF +;
cQuery	+= "          WHERE C91.C91_FILIAL = X.FILIAL " +CRLF +;
cQuery	+= "          AND C91.C91_TRABAL = X.ID_TAF " +CRLF +;
cQuery	+= "          AND C91.C91_PERAPU = '"+cPerTaf+"' " +CRLF +;
cQuery	+= "          AND C91.C91_ATIVO = '1' " +CRLF +;
cQuery	+= "          AND C91.C91_STATUS = '4' "    +CRLF +;
cQuery	+= "          AND C91.D_E_L_E_T_ = ' ' ) FOL_PROTOC_1200, "   +CRLF +;
cQuery	+= "        ( SELECT MAX(CMD.CMD_PROTUL) "    +CRLF +;
cQuery	+= "          FROM "+RetSqlName("CMD")+" CMD "  +CRLF +;
cQuery	+= "          WHERE CMD.CMD_FILIAL = X.FILIAL " +CRLF +;
cQuery	+= "          AND CMD.CMD_FUNC = X.ID_TAF " +CRLF +;
cQuery	+= "          AND substring(CMD.CMD_DTDESL,1,6) = '"+cPerTaf+"' " +CRLF +;
cQuery	+= "          AND CMD.CMD_ATIVO = '1' " +CRLF +;
cQuery	+= "          AND CMD.CMD_STATUS = '4' "    +CRLF +;
cQuery	+= "          AND CMD.D_E_L_E_T_ = ' ' ) RES_PROTOC_1200 "   +CRLF +;
cQuery	+= " FROM ( " +CRLF +;
cQuery	+= " SELECT " +CRLF +;
cQuery	+= "       NVL( " +CRLF +;
cQuery	+= "       (SELECT SUM(S"+cPrefixo+"."+cPrefixo+"_VALOR) "  +CRLF +;
cQuery	+= "        FROM "+RetSqlName("S"+cPrefixo)+" S"+cPrefixo+", "+RetSqlName("SRA")+" RA "  +CRLF +;
cQuery	+= "        WHERE S"+cPrefixo+"."+cPrefixo+"_FILIAL = RA.RA_FILIAL " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_MAT = RA.RA_MAT " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_PERIODO = '"+MV_PAR03+"' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_ROTEIR = '"+MV_PAR04+"' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_PD = 'V52' " +CRLF +;
cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC " +CRLF +;
cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT " +CRLF +;
cQuery	+= "         AND RA.D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+".D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "        ),0) V52, "          +CRLF +;
cQuery	+= "        SRA.RA_FILIAL FILIAL, "  +CRLF +;
cQuery	+= "        SRA.RA_MAT MAT_FOLHA, " +CRLF +;
cQuery	+= "        SRA.RA_NOME NOME, " +CRLF +;
cQuery	+= "        SRA.RA_CIC CPF, " +CRLF +;
cQuery	+= "        (CASE "  +CRLF +;
cQuery	+= "           WHEN SRA.RA_PROCES = '00003' " +CRLF +;
cQuery	+= "              THEN "    +CRLF +;
cQuery	+= "                (select MAX(C9V.C9V_ID) "  +CRLF +;
cQuery	+= "                 FROM "+RetSqlName("C9V")+" C9V " +CRLF +;
cQuery	+= "                 WHERE C9V.C9V_FILIAL = SRA.ra_filial " +CRLF +;
cQuery	+= "                  AND C9V.C9V_CPF = SRA.RA_CIC " +CRLF +;
cQuery	+= "                  AND C9V.C9V_ATIVO = '1' " +CRLF +;
cQuery	+= "                  AND C9V.C9V_STATUS = '4' "   +CRLF +;
cQuery	+= "                  AND C9V.D_E_L_E_T_ = ' ') "  +CRLF +;
cQuery	+= "           ELSE " +CRLF +;
cQuery	+= "                (select MAX(C9V.C9V_ID) "  +CRLF +;
cQuery	+= "                 FROM "+RetSqlName("C9V")+" C9V " +CRLF +;
cQuery	+= "                 WHERE C9V.C9V_FILIAL = SRA.ra_filial " +CRLF +;
cQuery	+= "                  AND C9V.C9V_MATRIC = SRA.RA_CODUNIC " +CRLF +;
cQuery	+= "                  AND C9V.C9V_ATIVO = '1' " +CRLF +;
cQuery	+= "                  AND C9V.C9V_STATUS = '4' "   +CRLF +;
cQuery	+= "                  AND C9V.D_E_L_E_T_ = ' ') "  +CRLF +;
cQuery	+= "        END ) ID_TAF,  " +CRLF +;
cQuery	+= "        SRA.RA_CODUNIC MAT_TAF, " +CRLF +;
cQuery	+= "        (CASE  " +CRLF +;
cQuery	+= "             WHEN SRA.RA_SITFOLH = ' ' " +CRLF +;
cQuery	+= "              THEN 'ATIVO' " +CRLF +;
cQuery	+= "             WHEN SRA.RA_SITFOLH = 'D' OR (SRA.RA_DEMISSA <= TO_CHAR(SYSDATE,'YYYYMMDD') AND SRA.RA_DEMISSA <> ' ') " +CRLF +;
cQuery	+= "              THEN 'DEMITIDO' " +CRLF +;
cQuery	+= "             WHEN SRA.RA_SITFOLH = 'A' "  +CRLF +;
cQuery	+= "              THEN 'AFASTADO' "            +CRLF +;
cQuery	+= "             WHEN SRA.RA_SITFOLH = 'F' "  +CRLF +;
cQuery	+= "              THEN 'FERIAS' "  +CRLF +;
cQuery	+= "             ELSE SRA.RA_SITFOLH "           +CRLF +;
cQuery	+= "         END) SITUACAO, " +CRLF +;
cQuery	+= "         SRA.RA_ADMISSA ADMISSAO, " +CRLF +;
cQuery	+= "         SRA.RA_DEMISSA DEMISSAO, "  +CRLF +;
cQuery	+= "      NVL( " +CRLF +;
cQuery	+= "       (SELECT SUM(S"+cPrefixo+"."+cPrefixo+"_VALOR) "  +CRLF +;
cQuery	+= "        FROM "+RetSqlName("S"+cPrefixo+"")+" S"+cPrefixo+", "+RetSqlName("SRA")+" RA "  +CRLF +;
cQuery	+= "        WHERE S"+cPrefixo+"."+cPrefixo+"_FILIAL = RA.RA_FILIAL " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_MAT = RA.RA_MAT " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_PERIODO = '"+MV_PAR03+"' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_ROTEIR = '"+MV_PAR04+"' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_PD IN (SELECT SRV.RV_COD "  +CRLF +;
cQuery	+= "                          FROM "+RetSqlName("SRV")+" SRV " +CRLF +;
cQuery	+= "                           WHERE SRV.RV_CODFOL IN ('0047','0126','0303') " +CRLF +;
cQuery	+= "                            AND SRV.D_E_L_E_T_ = ' ') " +CRLF +;
cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC " +CRLF +;
cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT " +CRLF +;
cQuery	+= "         AND RA.D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+".D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "        ),0) FOL_LIQ, "   +CRLF +;
cQuery	+= "       NVL( " +CRLF +;
cQuery	+= "       (SELECT SUM(S"+cPrefixo+"."+cPrefixo+"_VALOR) "  +CRLF +;
cQuery	+= "        FROM "+RetSqlName("S"+cPrefixo+"")+" S"+cPrefixo+", "+RetSqlName("SRA")+" RA "  +CRLF +;
cQuery	+= "        WHERE S"+cPrefixo+"."+cPrefixo+"_FILIAL = RA.RA_FILIAL " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_MAT = RA.RA_MAT " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_PERIODO = '"+MV_PAR03+"' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_ROTEIR = '"+MV_PAR04+"' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_PD IN(SELECT SRV.RV_COD "  +CRLF +;
cQuery	+= "                          FROM "+RetSqlName("SRV")+" SRV " +CRLF +;
cQuery	+= "                           WHERE SRV.RV_CODFOL IN ('0013','0014','0019','0020','0338','0399','0221','0273') " +CRLF +;
cQuery	+= "                            AND SRV.D_E_L_E_T_ = ' ') " +CRLF +;
cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC " +CRLF +;
cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT " +CRLF +;
cQuery	+= "         AND RA.D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+".D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "        ),0) FOL_BASE_INSS, "   +CRLF +;
cQuery	+= "        NVL( " +CRLF +;
cQuery	+= "        (SELECT SUM(T2R.T2R_VALOR) " +CRLF +;
cQuery	+= "         FROM "+RetSqlName("T2M")+" T2M, "+RetSqlName("T2R")+" T2R "  +CRLF +;
cQuery	+= "         WHERE T2M.T2M_CPFTRB = SRA.RA_CIC " +CRLF +;
cQuery	+= "          AND T2M.T2M_PERAPU = '"+cPerTaf+"' "  +CRLF +;
cQuery	+= "          AND T2M.T2M_FILIAL = T2R.T2R_FILIAL " +CRLF +;
cQuery	+= "          AND T2M.T2M_VERSAO = T2R.T2R_VERSAO " +CRLF +;
cQuery	+= "          AND (T2R.T2R_MATRIC = SRA.RA_CODUNIC  or SRA.RA_PROCES = '00003') " +CRLF +;
cQuery	+= "          AND T2M.D_E_L_E_T_ = ' ' "  +CRLF +;
cQuery	+= "          AND T2R.D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "          AND T2R.T2R_TPVLR IN (SELECT T2T_ID "  +CRLF +;
cQuery	+= "                                FROM "+RetSqlName("T2T")+" T2T "  +CRLF +;
cQuery	+= "                                WHERE T2T.T2T_CODIGO BETWEEN '11' AND '19' "  +CRLF +;
cQuery	+= "                                 AND T2T.D_E_L_E_T_ = ' ' ) " +CRLF +;
cQuery	+= "          AND T2M.R_E_C_N_O_ IN (SELECT MAX(T2MX.R_E_C_N_O_) " +CRLF +;
cQuery	+= "                                 FROM "+RetSqlName("T2M")+" T2MX " +CRLF +;
cQuery	+= "                                 WHERE T2MX.T2M_FILIAL = T2M.T2M_FILIAL " +CRLF +;
cQuery	+= "                                  AND T2MX.T2M_CPFTRB = T2M.T2M_CPFTRB " +CRLF +;
cQuery	+= "                                  AND T2MX.T2M_PERAPU = T2M.T2M_PERAPU "  +CRLF +;
cQuery	+= "                                  AND T2MX.D_E_L_E_T_ = ' ') "  +CRLF +;
cQuery	+= "         ),0) TAF_BASE_INSS, " +CRLF +;
cQuery	+= "       NVL( " +CRLF +;
cQuery	+= "       (SELECT SUM(S"+cPrefixo+"."+cPrefixo+"_VALOR) "  +CRLF +;
cQuery	+= "        FROM "+RetSqlName("S"+cPrefixo+"")+" S"+cPrefixo+", "+RetSqlName("SRA")+" RA "  +CRLF +;
cQuery	+= "        WHERE S"+cPrefixo+"."+cPrefixo+"_FILIAL = RA.RA_FILIAL " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_MAT = RA.RA_MAT " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_PERIODO = '"+MV_PAR03+"' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_ROTEIR = '"+MV_PAR04+"' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_PD IN(SELECT SRV.RV_COD "  +CRLF +;
cQuery	+= "                          FROM "+RetSqlName("SRV")+" SRV " +CRLF +;
cQuery	+= "                          WHERE SRV.RV_CODFOL IN ('0064','0065','0070','0340','0401') " +CRLF +;
cQuery	+= "                           AND SRV.D_E_L_E_T_ = ' ') " +CRLF +;
cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC " +CRLF +;
cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT " +CRLF +;
cQuery	+= "         AND RA.D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+".D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "         ),0) FOL_DESC_INSS, "   +CRLF +;
cQuery	+= "        NVL( " +CRLF +;
cQuery	+= "        (SELECT SUM(T2O.T2O_VRCPSE) " +CRLF +;
cQuery	+= "         FROM "+RetSqlName("T2M")+" T2M,  "+RetSqlName("T2R")+" T2R, "+RetSqlName("T2O")+" T2O "   +CRLF +;
cQuery	+= "         WHERE T2M.T2M_CPFTRB = SRA.RA_CIC " +CRLF +;
cQuery	+= "          AND T2M.T2M_PERAPU = '"+cPerTaf+"' "  +CRLF +;
cQuery	+= "          AND (T2R.T2R_MATRIC = SRA.RA_CODUNIC or SRA.RA_PROCES = '00003') " +CRLF +;
cQuery	+= "          AND T2R.T2R_FILIAL = T2M.T2M_FILIAL " +CRLF +;
cQuery	+= "          AND T2R.T2R_VERSAO = T2M.T2M_VERSAO "   +CRLF +;
cQuery	+= "          AND T2O.T2O_FILIAL = T2R.T2R_FILIAL "   +CRLF +;
cQuery	+= "          AND T2O.T2O_VERSAO = T2R.T2R_VERSAO "  +CRLF +;
cQuery	+= "          AND T2O.T2O_IDCODR IN (SELECT C6R_ID "  +CRLF +;
cQuery	+= "                                 FROM "+RetSqlName("C6R")+" C6R "  +CRLF +;
cQuery	+= "                                 WHERE C6R.C6R_CODIGO in ('108201','108221','109901') "  +CRLF +;
cQuery	+= "                                  AND C6R.D_E_L_E_T_ = ' ' ) "          +CRLF +;
cQuery	+= "          AND T2O.D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "          AND T2M.D_E_L_E_T_ = ' ' "  +CRLF +;
cQuery	+= "          AND T2R.D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "          AND T2R.R_E_C_N_O_ = (SELECT MAX(T2RX.R_E_C_N_O_) " +CRLF +;
cQuery	+= "                                 FROM "+RetSqlName("T2R")+" T2RX " +CRLF +;
cQuery	+= "                                 WHERE T2RX.T2R_FILIAL = T2R.T2R_FILIAL " +CRLF +;
cQuery	+= "                                  AND T2RX.T2R_VERSAO = T2R.T2R_VERSAO " +CRLF +;
cQuery	+= "                                  AND (T2RX.T2R_MATRIC = SRA.RA_CODUNIC or SRA.RA_PROCES = '00003') " +CRLF +;
cQuery	+= "                                  AND T2RX.D_E_L_E_T_ = ' ') "  +CRLF +;
cQuery	+= "          AND T2M.R_E_C_N_O_ = (SELECT MAX(T2MX.R_E_C_N_O_) " +CRLF +;
cQuery	+= "                                 FROM "+RetSqlName("T2M")+" T2MX " +CRLF +;
cQuery	+= "                                 WHERE T2MX.T2M_FILIAL = T2M.T2M_FILIAL " +CRLF +;
cQuery	+= "                                  AND T2MX.T2M_CPFTRB = T2M.T2M_CPFTRB " +CRLF +;
cQuery	+= "                                  AND T2MX.T2M_PERAPU = T2M.T2M_PERAPU "  +CRLF +;
cQuery	+= "                                  AND T2MX.D_E_L_E_T_ = ' ') "                          +CRLF +;
cQuery	+= "         ),0) TAF_DESC_INSS, " +CRLF +;
cQuery	+= "       NVL( " +CRLF +;
cQuery	+= "       (SELECT SUM(S"+cPrefixo+"."+cPrefixo+"_VALOR) "  +CRLF +;
cQuery	+= "        FROM "+RetSqlName("S"+cPrefixo+"")+" S"+cPrefixo+", "+RetSqlName("SRA")+" RA "  +CRLF +;
cQuery	+= "        WHERE S"+cPrefixo+"."+cPrefixo+"_FILIAL = RA.RA_FILIAL " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_MAT = RA.RA_MAT " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_PERIODO = '"+MV_PAR03+"' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_ROTEIR = '"+MV_PAR04+"' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_PD IN(SELECT SRV.RV_COD "  +CRLF +;
cQuery	+= "                          FROM "+RetSqlName("SRV")+" SRV " +CRLF +;
cQuery	+= "                          WHERE SRV.RV_CODFOL IN ('0017','0108') " +CRLF +;
cQuery	+= "                           AND SRV.D_E_L_E_T_ = ' ') " +CRLF +;
cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC " +CRLF +;
cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT " +CRLF +;
cQuery	+= "         AND RA.D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+".D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "        ),0) BASEFGTSFO, "           +CRLF +;
cQuery	+= "       NVL( " +CRLF +;
cQuery	+= "       (SELECT SUM(S"+cPrefixo+"."+cPrefixo+"_VALOR) "  +CRLF +;
cQuery	+= "        FROM "+RetSqlName("S"+cPrefixo+"")+" S"+cPrefixo+", "+RetSqlName("SRA")+" RA "  +CRLF +;
cQuery	+= "        WHERE S"+cPrefixo+"."+cPrefixo+"_FILIAL = RA.RA_FILIAL " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_MAT = RA.RA_MAT " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_PERIODO = '"+MV_PAR03+"' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_ROTEIR = '"+MV_PAR04+"' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_PD IN(SELECT SRV.RV_COD "  +CRLF +;
cQuery	+= "                          FROM "+RetSqlName("SRV")+" SRV " +CRLF +;
cQuery	+= "                          WHERE SRV.RV_CODFOL IN ('0018','0109') " +CRLF +;
cQuery	+= "                           AND SRV.D_E_L_E_T_ = ' ') " +CRLF +;
cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC " +CRLF +;
cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT " +CRLF +;
cQuery	+= "         AND RA.D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+".D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "        ),0) VALFGTSFO, "   +CRLF +;
cQuery	+= "       NVL( " +CRLF +;
cQuery	+= "       (SELECT SUM(S"+cPrefixo+"."+cPrefixo+"_VALOR) "  +CRLF +;
cQuery	+= "        FROM "+RetSqlName("S"+cPrefixo+"")+" S"+cPrefixo+", "+RetSqlName("SRA")+" RA "  +CRLF +;
cQuery	+= "        WHERE S"+cPrefixo+"."+cPrefixo+"_FILIAL = RA.RA_FILIAL " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_MAT = RA.RA_MAT " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_PERIODO = '"+MV_PAR03+"' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_ROTEIR = '"+MV_PAR04+"' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_PD IN(SELECT SRV.RV_COD "  +CRLF +;
cQuery	+= "                          FROM "+RetSqlName("SRV")+" SRV " +CRLF +;
cQuery	+= "                          WHERE SRV.RV_CODFOL = '0077' " +CRLF +;
cQuery	+= "                           AND SRV.D_E_L_E_T_ = ' ') " +CRLF +;
cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC " +CRLF +;
cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT " +CRLF +;
cQuery	+= "         AND RA.D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+".D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "        ),0) VAL_134, " +CRLF +;
cQuery	+= "       NVL( " +CRLF +;
cQuery	+= "       (SELECT SUM(S"+cPrefixo+"."+cPrefixo+"_VALOR) "  +CRLF +;
cQuery	+= "        FROM "+RetSqlName("S"+cPrefixo+"")+" S"+cPrefixo+", "+RetSqlName("SRA")+" RA "  +CRLF +;
cQuery	+= "        WHERE S"+cPrefixo+"."+cPrefixo+"_FILIAL = RA.RA_FILIAL " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_MAT = RA.RA_MAT " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_PERIODO = '"+MV_PAR03+"' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_ROTEIR = '"+MV_PAR04+"' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_PD IN(SELECT SRV.RV_COD "  +CRLF +;
cQuery	+= "                          FROM "+RetSqlName("SRV")+" SRV " +CRLF +;
cQuery	+= "                          WHERE SRV.RV_CODFOL = '0090' " +CRLF +;
cQuery	+= "                           AND SRV.D_E_L_E_T_ = ' ') " +CRLF +;
cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC " +CRLF +;
cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT " +CRLF +;
cQuery	+= "         AND RA.D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+".D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "        ),0) VAL_147, " +CRLF +;
cQuery	+= "       NVL( " +CRLF +;
cQuery	+= "       (SELECT SUM(S"+cPrefixo+"."+cPrefixo+"_VALOR) "  +CRLF +;
cQuery	+= "        FROM "+RetSqlName("S"+cPrefixo+"")+" S"+cPrefixo+",  "+RetSqlName("SRA")+" RA "  +CRLF +;
cQuery	+= "        WHERE S"+cPrefixo+"."+cPrefixo+"_FILIAL = RA.RA_FILIAL " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_MAT = RA.RA_MAT " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_PERIODO = '"+MV_PAR03+"' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_ROTEIR = '"+MV_PAR04+"' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_PD IN(SELECT SRV.RV_COD "  +CRLF +;
cQuery	+= "                          FROM  "+RetSqlName("SRV")+" SRV " +CRLF +;
cQuery	+= "                          WHERE SRV.RV_CODFOL = '0253' " +CRLF +;
cQuery	+= "                           AND SRV.D_E_L_E_T_ = ' ') " +CRLF +;
cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC " +CRLF +;
cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT " +CRLF +;
cQuery	+= "         AND RA.D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+".D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "        ),0) VAL_218, " +CRLF +;
cQuery	+= "       NVL( " +CRLF +;
cQuery	+= "       (SELECT SUM(S"+cPrefixo+"."+cPrefixo+"_VALOR) "  +CRLF +;
cQuery	+= "        FROM  "+RetSqlName("S"+cPrefixo+"")+" S"+cPrefixo+",  "+RetSqlName("SRA")+" RA "  +CRLF +;
cQuery	+= "        WHERE S"+cPrefixo+"."+cPrefixo+"_FILIAL = RA.RA_FILIAL " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_MAT = RA.RA_MAT " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_PERIODO = '"+MV_PAR03+"' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_ROTEIR = '"+MV_PAR04+"' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_PD IN(SELECT SRV.RV_COD "  +CRLF +;
cQuery	+= "                          FROM  "+RetSqlName("SRV")+" SRV " +CRLF +;
cQuery	+= "                          WHERE SRV.RV_CODFOL = '0115' " +CRLF +;
cQuery	+= "                           AND SRV.D_E_L_E_T_ = ' ') " +CRLF +;
cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC " +CRLF +;
cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT " +CRLF +;
cQuery	+= "         AND RA.D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+".D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "        ),0) VAL_164, "	    +CRLF +;
cQuery	+= "       NVL( " +CRLF +;
cQuery	+= "       (SELECT SUM(S"+cPrefixo+"."+cPrefixo+"_VALOR) "  +CRLF +;
cQuery	+= "        FROM  "+RetSqlName("S"+cPrefixo+"")+" S"+cPrefixo+",  "+RetSqlName("SRA")+" RA "  +CRLF +;
cQuery	+= "        WHERE S"+cPrefixo+"."+cPrefixo+"_FILIAL = RA.RA_FILIAL " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_MAT = RA.RA_MAT " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_PERIODO = '"+MV_PAR03+"' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_ROTEIR = '"+MV_PAR04+"' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_PD IN(SELECT SRV.RV_COD "  +CRLF +;
cQuery	+= "                          FROM  "+RetSqlName("SRV")+" SRV " +CRLF +;
cQuery	+= "                          WHERE SRV.RV_CODFOL = '0041' " +CRLF +;
cQuery	+= "                           AND SRV.D_E_L_E_T_ = ' ') " +CRLF +;
cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC " +CRLF +;
cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT " +CRLF +;
cQuery	+= "         AND RA.D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+".D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "        ),0) VAL_122, " +CRLF +;
cQuery	+= "       NVL( " +CRLF +;
cQuery	+= "       (SELECT SUM(S"+cPrefixo+"."+cPrefixo+"_VALOR) "  +CRLF +;
cQuery	+= "        FROM  "+RetSqlName("S"+cPrefixo+"")+" S"+cPrefixo+",  "+RetSqlName("SRA")+" RA "  +CRLF +;
cQuery	+= "        WHERE S"+cPrefixo+"."+cPrefixo+"_FILIAL = RA.RA_FILIAL " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_MAT = RA.RA_MAT " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_PERIODO = '"+MV_PAR03+"' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_ROTEIR = '"+MV_PAR04+"' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_PD IN(SELECT SRV.RV_COD "  +CRLF +;
cQuery	+= "                          FROM  "+RetSqlName("SRV")+" SRV " +CRLF +;
cQuery	+= "                          WHERE SRV.RV_CODFOL = '0042' " +CRLF +;
cQuery	+= "                           AND SRV.D_E_L_E_T_ = ' ') " +CRLF +;
cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC " +CRLF +;
cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT " +CRLF +;
cQuery	+= "         AND RA.D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+".D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "        ),0) VAL_123, "	      +CRLF +;
cQuery	+= "       NVL( " +CRLF +;
cQuery	+= "       (SELECT SUM(S"+cPrefixo+"."+cPrefixo+"_VALOR) "  +CRLF +;
cQuery	+= "        FROM  "+RetSqlName("S"+cPrefixo+"")+" S"+cPrefixo+",  "+RetSqlName("SRA")+" RA "  +CRLF +;
cQuery	+= "        WHERE S"+cPrefixo+"."+cPrefixo+"_FILIAL = RA.RA_FILIAL " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_MAT = RA.RA_MAT " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_PERIODO = '"+MV_PAR03+"' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_ROTEIR = '"+MV_PAR04+"' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_PD IN(SELECT SRV.RV_COD "  +CRLF +;
cQuery	+= "                          FROM  "+RetSqlName("SRV")+" SRV " +CRLF +;
cQuery	+= "                          WHERE SRV.RV_FILIAL = '  ' " +CRLF +;
cQuery	+= "                           AND SRV.RV_CODFOL IN ('0034') " +CRLF +;
cQuery	+= "                           AND SRV.D_E_L_E_T_ = ' ') " +CRLF +;
cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC " +CRLF +;
cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT " +CRLF +;
cQuery	+= "         AND RA.D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+".D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "        ),0) FOL_SAL_FAMILIA, "    +CRLF +;
cQuery	+= "       NVL( " +CRLF +;
cQuery	+= "       (SELECT SUM(S"+cPrefixo+"."+cPrefixo+"_VALOR) "  +CRLF +;
cQuery	+= "        FROM  "+RetSqlName("S"+cPrefixo+"")+" S"+cPrefixo+",  "+RetSqlName("SRA")+" RA "  +CRLF +;
cQuery	+= "        WHERE S"+cPrefixo+"."+cPrefixo+"_FILIAL = RA.RA_FILIAL " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_MAT = RA.RA_MAT " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_PERIODO = '"+MV_PAR03+"' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_ROTEIR = '"+MV_PAR04+"' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_PD IN(SELECT SRV.RV_COD "  +CRLF +;
cQuery	+= "                          FROM  "+RetSqlName("SRV")+" SRV " +CRLF +;
cQuery	+= "                          WHERE SRV.RV_FILIAL = '  ' " +CRLF +;
cQuery	+= "                           AND ( SRV.RV_CODFOL IN ('0040','1446') or SRV.RV_COD = '884' ) " +CRLF +;
cQuery	+= "                           AND SRV.D_E_L_E_T_ = ' ') " +CRLF +;
cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC " +CRLF +;
cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT " +CRLF +;
cQuery	+= "         AND RA.D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+".D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "        ),0) FOL_AUX_MATER, "      +CRLF +;
cQuery	+= "       NVL( " +CRLF +;
cQuery	+= "       (SELECT SUM(S"+cPrefixo+"."+cPrefixo+"_VALOR) "  +CRLF +;
cQuery	+= "        FROM  "+RetSqlName("S"+cPrefixo+"")+" S"+cPrefixo+",  "+RetSqlName("SRA")+" RA  " +CRLF +;
cQuery	+= "        WHERE S"+cPrefixo+"."+cPrefixo+"_FILIAL = RA.RA_FILIAL " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_MAT = RA.RA_MAT " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_PERIODO = '"+MV_PAR03+"' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_ROTEIR = '"+MV_PAR04+"' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_PD IN(SELECT SRV.RV_COD "  +CRLF +;
cQuery	+= "                          FROM  "+RetSqlName("SRV")+" SRV " +CRLF +;
cQuery	+= "                          WHERE SRV.RV_FILIAL = '  ' " +CRLF +;
cQuery	+= "                           AND SRV.RV_CODFOL IN ('0407','1447') " +CRLF +;
cQuery	+= "                           AND SRV.D_E_L_E_T_ = ' ') " +CRLF +;
cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC " +CRLF +;
cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT " +CRLF +;
cQuery	+= "         AND RA.D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+".D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "        ),0) FOL_MEDIA_SAL_MATER, " +CRLF +;
cQuery	+= "       NVL( " +CRLF +;
cQuery	+= "       (SELECT SUM(RHH.RHH_VALOR) "  +CRLF +;
cQuery	+= "        FROM  "+RetSqlName("RHH")+" RHH " +CRLF +;
cQuery	+= "        WHERE RHH.RHH_FILIAL = SRA.RA_FILIAL " +CRLF +;
cQuery	+= "         AND RHH.RHH_MAT = SRA.RA_MAT " +CRLF +;
cQuery	+= "         AND substring(RHH.RHH_DATA,1,4) = substring('"+MV_PAR03+"',1,4) " +CRLF +;
cQuery	+= "         AND RHH.RHH_DATA <= '"+MV_PAR03+"' " +CRLF +;
cQuery	+= "         AND RHH.RHH_MESANO = '"+MV_PAR03+"' " +CRLF +;
cQuery	+= "         AND RHH.RHH_ROTEIR = '"+MV_PAR04+"' " +CRLF +;
cQuery	+= "         AND RHH.RHH_VB IN(SELECT SRV.RV_COD "  +CRLF +;
cQuery	+= "                          FROM  "+RetSqlName("SRV")+" SRV " +CRLF +;
cQuery	+= "                          WHERE SRV.RV_CODFOL IN ('0077','0090') " +CRLF +;
cQuery	+= "                           AND SRV.D_E_L_E_T_ = ' ') " +CRLF +;
cQuery	+= "         AND RHH.D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "        ),0) DIS_VAL_134_147, " +CRLF +;
cQuery	+= "        NVL( " +CRLF +;
cQuery	+= "       (SELECT SUM(S"+cPrefixo+"."+cPrefixo+"_VALOR) "  +CRLF +;
cQuery	+= "        FROM  "+RetSqlName("S"+cPrefixo+"")+" S"+cPrefixo+",  "+RetSqlName("SRA")+" RA "  +CRLF +;
cQuery	+= "        WHERE S"+cPrefixo+"."+cPrefixo+"_FILIAL = RA.RA_FILIAL " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_MAT = RA.RA_MAT " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_PERIODO = '"+MV_PAR03+"' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_ROTEIR = '"+MV_PAR04+"' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+"."+cPrefixo+"_PD = '886' " +CRLF +;
cQuery	+= "         AND RA.RA_CIC = SRA.RA_CIC " +CRLF +;
cQuery	+= "         AND RA.RA_MAT = SRA.RA_MAT " +CRLF +;
cQuery	+= "         AND RA.D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "         AND S"+cPrefixo+".D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "        ),0) DIS_FOL_VAL_134_147, " +CRLF +;
cQuery	+= "       NVL( " +CRLF +;
cQuery	+= "        (SELECT SUM(T2R.T2R_VALOR) " +CRLF +;
cQuery	+= "         FROM  "+RetSqlName("T2M")+" T2M,  "+RetSqlName("T2R")+" T2R "  +CRLF +;
cQuery	+= "         WHERE T2M.T2M_CPFTRB = SRA.RA_CIC " +CRLF +;
cQuery	+= "          AND T2M.T2M_PERAPU = '"+cPerTaf+"' "  +CRLF +;
cQuery	+= "          AND T2M.T2M_FILIAL = T2R.T2R_FILIAL " +CRLF +;
cQuery	+= "          AND T2M.T2M_VERSAO = T2R.T2R_VERSAO " +CRLF +;
cQuery	+= "          AND (T2R.T2R_MATRIC = SRA.RA_CODUNIC or SRA.RA_PROCES = '00003') " +CRLF +;
cQuery	+= "          AND T2M.D_E_L_E_T_ = ' '  " +CRLF +;
cQuery	+= "          AND T2R.D_E_L_E_T_ = ' ' " +CRLF +;
cQuery	+= "          AND T2R.T2R_TPVLR IN (SELECT T2T_ID "  +CRLF +;
cQuery	+= "                                FROM  "+RetSqlName("T2T")+" T2T "  +CRLF +;
cQuery	+= "                                WHERE T2T.T2T_CODIGO IN ('95','98') " +CRLF +;
cQuery	+= "                                 AND T2T.D_E_L_E_T_ = ' ' ) " +CRLF +;
cQuery	+= "          AND T2M.R_E_C_N_O_ IN (SELECT MAX(T2MX.R_E_C_N_O_) " +CRLF +;
cQuery	+= "                                 FROM  "+RetSqlName("T2M")+" T2MX " +CRLF +;
cQuery	+= "                                 WHERE T2MX.T2M_FILIAL = T2M.T2M_FILIAL " +CRLF +;
cQuery	+= "                                  AND T2MX.T2M_CPFTRB = T2M.T2M_CPFTRB " +CRLF +;
cQuery	+= "                                  AND T2MX.T2M_PERAPU = T2M.T2M_PERAPU "  +CRLF +;
cQuery	+= "                                  AND T2MX.D_E_L_E_T_ = ' ') "  +CRLF +;
cQuery	+= "         ),0) TAF_BASE_SUSPENSAO, " +CRLF +;
cQuery	+= "        ra_percsat PERC_AC_TRAB, " +CRLF +;
cQuery	+= "        ra_ocorren OCORR_SEFIP, " +CRLF +;
cQuery	+= "        SRA.RA_CC C_CUSTO, " +CRLF +;
cQuery	+= "        SRA.RA_PIS PIS, " +CRLF +;
cQuery	+= "        (SELECT MAX(CTT.CTT_DESC01) "  +CRLF +;
cQuery	+= "         FROM  "+RetSqlName("CTT")+" CTT "  +CRLF +;
cQuery	+= "          WHERE CTT.CTT_CUSTO = SRA.RA_CC "  +CRLF +;
cQuery	+= "          AND RTRIM(CTT.CTT_FILIAL) = substring(RA_FILIAL,1,2) "    +CRLF +;
cQuery	+= "          AND CTT.D_E_L_E_T_ = ' ') C_CUSTO_DESC "                          +CRLF +;
cQuery	+= " FROM  "+RetSqlName("SRA")+" SRA " +CRLF +;   //cQuery	+= " WHERE SRA.RA_FILIAL = '"+xFilial("SRA")+"' " 
cQuery	+= "  WHERE SRA.D_E_L_E_T_ = ' ' "  +CRLF +;
cQuery	+= "  AND EXISTS " +CRLF +;
cQuery	+= "  (SELECT * " +CRLF +;
cQuery	+= "   FROM  "+RetSqlName("S"+cPrefixo+"")+" S"+cPrefixo+" " +CRLF +;
cQuery	+= "   WHERE S"+cPrefixo+"."+cPrefixo+"_FILIAL = SRA.RA_FILIAL " +CRLF +;
cQuery	+= "    AND S"+cPrefixo+"."+cPrefixo+"_MAT = SRA.RA_MAT " +CRLF +;
cQuery	+= "    AND S"+cPrefixo+"."+cPrefixo+"_PERIODO = '"+MV_PAR03+"' " +CRLF +;
cQuery	+= "    AND S"+cPrefixo+"."+cPrefixo+"_ROTEIR = '"+MV_PAR04+"' " +CRLF +;
cQuery	+= "    AND S"+cPrefixo+".D_E_L_E_T_ = ' ' ) "  +CRLF +;
cQuery	+= " ) X ) Y ORDER BY Y.NOME "  

MemoWrite("C:\TOTVS_RELATORIOS\NFPER015.SQL", cQuery)
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
oExcel:AddPlanilha('Relatorio',{20,50,60,170,80,120,50,50,120,50,50,80,80,80,80,80,80,80,80,80,60,60},0)

//oExcel:AddLinha(20)
//oExcel:AddCelula(cEmpresa,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,16) 
///oExcel:AddLinha(15)
///oExcel:AddCelula( dtoc(DATE()),0,'L',cFonte1,10,cCorFont1,.T.,.T.,cCorFun1,,,,,.T.,2,16) 
///oExcel:AddLinha(15)
//oExcel:AddLinha(20)
//oExcel:AddCelula(cTitulo + " - Filial: " + cFilAnt,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,,cCorFun1,,,,,.T.,2,16)  
    
oExcel:AddLinha(20)
oExcel:AddLinha(12) 
oExcel:AddCelula()  
oExcel:AddCelula("Filial"  	     		,0,'L',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Mat. Folha"  			,0,'L',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Nome"	  				,0,'L',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("CPF"					,0,'L',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("ID TAF"				,0,'L',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Mat. TAF"	  			,0,'L',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Centro de Custo"		,0,'L',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.) 
oExcel:AddCelula("Desc. C Custo"		,0,'L',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Situacao"				,0,'L',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Admissao"	  			,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Demissao"				,0,'C',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("FOL-Liquido"			,0,'R',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("TAF-Liq. 1210"		,0,'R',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("FOL-Base INSS"		,0,'R',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("TAF-Base INSS"		,0,'R',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("FOL-Desc. INSS"		,0,'R',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("TAF-Desc. INSS"		,0,'R',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Dif. Base INSS"		,0,'R',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Dif. INSS"			,0,'R',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
oExcel:AddCelula("Dif. Liquido"			,0,'R',cCab1Fon,cCab1TamF,cCab1CorF,.T.,.T.,cCab1Fun ,.T.,.T.,.T.,.T.)
                  
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

	oExcel:AddLinha(14) 
	oExcel:AddCelula()   

	cCorFun2 := "#FFFFFF"    
	oExcel:AddCelula( (cTab)->FILIAL	 	,0		 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->MAT_FOLHA	 	,0		 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->NOME	 		,0		 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->CPF	 		,0		 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->ID_TAF	 	,0		 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->MAT_TAF	 	,0		 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->C_CUSTO	 	,0		 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->C_CUSTO_DESC 	,0		 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->SITUACAO	 	,0		 ,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( cTemp1				,0		 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( cTemp2				,0		 ,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->LIQFOL		,nDec1	 ,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->LIQ1210		,nDec1	 ,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->BASEINSSF		,nDec1	 ,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->BASEINSST		,nDec1	 ,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->DESCINSSF		,nDec1	 ,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 
	oExcel:AddCelula( (cTab)->DESCINSST		,nDec1	 ,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 

	cCorFun2 := "#FFFFFF"
	if (cTab)->DIF_BASE > 0.03 .or. (cTab)->DIF_BASE < -0.03
		cCorFun2 := "#FF0000"
	endif	 
	oExcel:AddCelula( (cTab)->DIF_BASE		,nDec1	 ,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.)

	cCorFun2 := "#FFFFFF"
	if (cTab)->DIF_DESCONT > 0.03 .or. (cTab)->DIF_DESCONT < -0.03
		cCorFun2 := "#FF0000"
	endif	 
	oExcel:AddCelula( (cTab)->DIF_DESCONT	,nDec1	 ,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 

	cCorFun2 := "#FFFFFF"
	if (cTab)->DIF_LIQUIDO > 0.03 .or. (cTab)->DIF_LIQUIDO < -0.03
		cCorFun2 := "#FF0000"
	endif	 
	oExcel:AddCelula( (cTab)->DIF_LIQUIDO	,nDec1	 ,'R',cFonte2,nTamFont2,cCorFont2,,,cCorFun2,.T.,.T.,.T.,.T.) 

	IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(99,2)) + "%")	

   	(cTab)->(DbSkip())                
EndDo    

fGeraParametros()
oExcel:SaveXml(Alltrim(MV_PAR05),cArqXML,.F.) 

nRegAtu++
IncProc("Gerando Relatorio - Status: " + IIF((nRegAtu/nTotReg)*100 <= 99, StrZero((nRegAtu/nTotReg)*100,2), STRZERO(100,3)) + "%")	
return
 
 
 
 //Gera parametros
Static Function fGeraParametros()

local nCont		 := 0 
local cCorFundo  := ""
local cTitulo	 := 'Parametros'

local cFonte1    := 'Calibri' 
local nTamFont1  := 9
local cCorFont1  := '#FFFFFF'
local cCorFund1  := '#4F81BD'

local cFonte2    := 'Arial' 
local nTamFont2  := 9
local cCorFont2  := '#000000'

local cCorFundo  := ''

aPergs[1,3] := MV_PAR01 
aPergs[2,3] := MV_PAR02  
aPergs[3,3] := MV_PAR03     
aPergs[4,3] := MV_PAR04     
aPergs[5,3] := MV_PAR05     

oExcel:AddPlanilha('Parametros',{30,80,120,270})
oExcel:AddLinha(18)
oExcel:AddCelula(cTitulo,0,'C','Arial',12,'#FFFFFF',,,'#4F81BD',,,,,.T.,2,2) 
oExcel:AddLinha(15)
oExcel:AddLinha(12) 
oExcel:AddCelula()
oExcel:AddCelula( "Sequencia" ,0,'C',cFonte1,nTamFont1,cCorFont1,.T.,.T.,cCorFund1,.T.,.T.,.T.,.T.) 
oExcel:AddCelula( "Pergunta"  ,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,.T.,cCorFund1,.T.,.T.,.T.,.T.) 
oExcel:AddCelula( "Conteudo"  ,0,'L',cFonte1,nTamFont1,cCorFont1,.T.,.T.,cCorFund1,.T.,.T.,.T.,.T.) 

for nCont := 1 to Len(aPergs)	
	
	if MOD(nCont,2) > 0 
        cCorFundo := '#DCE6F1'	
	else
		cCorFundo := '#B8CCE4'	
	endif	  

	oExcel:AddLinha(16) 
	oExcel:AddCelula()
	oExcel:AddCelula( strzero(nCont,2) ,0,'C',cFonte2,nTamFont2,cCorFont2,,,cCorFundo,.T.,.T.,.T.,.T.)  
	oExcel:AddCelula( aPergs[nCont,2]  ,0,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFundo,.T.,.T.,.T.,.T.)  
	oExcel:AddCelula( aPergs[nCont,3]  ,0,'L',cFonte2,nTamFont2,cCorFont2,,,cCorFundo,.T.,.T.,.T.,.T.) // Conteudo 

next aPergs
Return 
     
          
       
//Perguntas
Static Function fPergunte()

local cLoad	    := "ORTR722P" + cEmpAnt
local cFileName := RetCodUsr() +"_"+ cLoad
local lRet		:= .F.

MV_PAR01 := space(6)
MV_PAR02 := space(6)
MV_PAR03 := space(6)
MV_PAR04 := space(3)
MV_PAR05 := space(200)

aAdd( aPergs ,{1,"Matricula De " 	,MV_PAR01  ,"" ,".t."  		,'SRA' ,'.T.',80,.F.})	
aAdd( aPergs ,{1,"Matricula Até" 	,MV_PAR02  ,"" ,"NAOVAZIO()",'SRA' ,'.T.',80,.F.})	
aAdd( aPergs ,{1,"Periodo (AAAAMM)"	,MV_PAR03  ,"" ,"NAOVAZIO()",''    ,'.T.',80,.F.})	
aAdd( aPergs ,{1,"Roteiro" 			,MV_PAR04  ,"" ,"NAOVAZIO()",''    ,'.T.',80,.F.})	
aAdd( aPergs ,{6,"Pasta Destino"    ,SPACE(200),"" ,".t.","",80,.F.," ","C:\",128+16} )
	
If ParamBox(aPergs ,"Relatório de FOLHA x TAF",,,,,,,,cLoad,.T.,.T.)  
    lRet := .T.
 	if empty(MV_PAR05) 
		MV_PAR05 := AllTrim(GetTempPath()) 	
	endif  		
endif	
return lRet

