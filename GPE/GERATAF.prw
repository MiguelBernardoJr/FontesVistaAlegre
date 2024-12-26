#include "Protheus.ch"                                                                    
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.ch"                                                                                                                             
#INCLUDE "TBICONN.CH"  
#INCLUDE "FONT.CH"          
#Define cEnt CHR(13) + CHR(10)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GERATAFº    Autor  ³JORGE PAIVA        º Data ³  23/11/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Rotina para gerar informações do funcionario               º±±

±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ STATEGRID                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function GERATAF() 

Private cArquivo  := GetTempPath()+'VAEST022_'+StrTran(dToC(dDataBase), '/', '-')+'_'+StrTran(Time(), ':', '-')+'.xml'

cPerg := Padr("GERATAF",10,"")
aSx1  := {}

Aadd(aSx1,{"GRUPO","ORDEM","PERGUNT"                       ,"VARIAVL","TIPO","TAMANHO","DECIMAL","GSC","VALID"      ,"VAR01"   ,"F3"  ,"DEF01" ,"DEF02" ,"DEF03"  ,"DEF04"  ,"DEF05"   ,"HELP"      })


Aadd(aSx1,{cPerg  ,"01"   ,"Matricula De.................?","mv_ch1" ,"C"   ,06       ,0        ,"G"  ,""           ,"mv_par01","SRA" ,""      ,""      ,""       ,""       ,""        ,".RHCCD."   })
Aadd(aSx1,{cPerg  ,"02"   ,"Matricula Ate................?","mv_ch2" ,"C"   ,06       ,0        ,"G"  ,"NaoVazio"   ,"mv_par02","SRA" ,""      ,""      ,""       ,""       ,""        ,".RHCCAT."  })                                                                                                                                                                                                                   
Aadd(aSx1,{cPerg  ,"03"   ,"Ano Mes (AAAAMM).............?","mv_ch3" ,"C"   ,06       ,0        ,"G"  ,"NaoVazio"   ,"mv_par03","" ,""      ,""      ,""       ,""       ,""        ,".RHCCAT."  })
Aadd(aSx1,{cPerg  ,"04"   ,"Local da Gravação............?","mv_ch4" ,"C"   ,30       ,0        ,"G"  ,"NaoVazio"   ,"mv_par04",""    ,""      ,""      ,""       ,""       ,""        ,""          })
Aadd(aSx1,{cPerg  ,"04"   ,"Filial de....................?","mv_ch5" ,"C"   ,02       ,0        ,"G"  ,"NaoVazio"   ,"mv_par05","SM0"    ,""      ,""      ,""       ,""       ,""        ,""          })
Aadd(aSx1,{cPerg  ,"04"   ,"Filial Ate...................?","mv_ch6" ,"C"   ,02       ,0        ,"G"  ,"NaoVazio"   ,"mv_par06","SM0"    ,""      ,""      ,""       ,""       ,""        ,""          })

fCriaSx1()

If !Pergunte(cPerg,.T.)
	Return
Endif

cPath := Alltrim(mv_par04)
cPath := If(Right(cPath,1) == "\",cPath,cPath+"\")

If ! ":" $ cPath
	MsgStop("Caminho Inválido !!!")
	Return
Endif

Processa({|| fGERA()  , "Aguarde a geracão de Planilha Comparativa do INSS...  [Proc 1/2]"})   

Return

********************************
Static Function fGERA()
********************************
LOCAL cArq      := "" 
Local cPath     := Alltrim(MV_PAR04)
Local oExcel    := FWMSEXCEL():New()  
local aq
//Criação da Planilha de Funcionários
		

// Inicio da aba Detalhada 

                   
oExcel:AddworkSheet("FUNCIONARIOS")    
oExcel:AddTable ("FUNCIONARIOS","DETALHADO")
oExcel:AddColumn("FUNCIONARIOS","DETALHADO","FILIAL",1,1,.f.)
oExcel:AddColumn("FUNCIONARIOS","DETALHADO","MATRICULA FOLHA",1,1,.f.)
oExcel:AddColumn("FUNCIONARIOS","DETALHADO","NOME",1,1,.f.)
oExcel:AddColumn("FUNCIONARIOS","DETALHADO","CPF",1,1,.f.)
oExcel:AddColumn("FUNCIONARIOS","DETALHADO","ID TAF",1,1,.f.)
oExcel:AddColumn("FUNCIONARIOS","DETALHADO","MAT TAF",1,1,.f.)
oExcel:AddColumn("FUNCIONARIOS","DETALHADO","SITUACAO",1,4,.f.)
oExcel:AddColumn("FUNCIONARIOS","DETALHADO","ADMISSAO",1,1,.f.)
oExcel:AddColumn("FUNCIONARIOS","DETALHADO","DEMISSAO",1,1,.f.)
oExcel:AddColumn("FUNCIONARIOS","DETALHADO","LIQ FOLHA",1,1,.f.)
oExcel:AddColumn("FUNCIONARIOS","DETALHADO","LIQ TAF",1,2,.F.)
oExcel:AddColumn("FUNCIONARIOS","DETALHADO","BASE INSS FOLHA",1,2,.F.)
oExcel:AddColumn("FUNCIONARIOS","DETALHADO","BASE INSS TAF",1,2,.F.)
oExcel:AddColumn("FUNCIONARIOS","DETALHADO","DESC INSS FOLHA",1,2,.F.)
oExcel:AddColumn("FUNCIONARIOS","DETALHADO","DESC INSS TAF",1,2,.F.)
oExcel:AddColumn("FUNCIONARIOS","DETALHADO","DIF INSS",1,2,.F.)


aPerf := {}
aPerf := fPerf1()  


IF LEN(aPerf) > 0

FOR aq := 1 TO LEN(aPerf)
		oExcel:AddRow("FUNCIONARIOS","DETALHADO" ,        {aPerf[aq,1],;
		                                                   aPerf[aq,2],;
		                                                   aPerf[aq,3],;
		                                                   aPerf[aq,4],;
		                                                   aPerf[aq,5],;
		                                                   aPerf[aq,6],;
		                                                   aPerf[aq,7],;
		                                                   aPerf[aq,8],;
		                                                   aPerf[aq,9],;
		                                                   aPerf[aq,10],;
		                                                   aPerf[aq,11],;
		                                                   aPerf[aq,12],;
		                                                   aPerf[aq,13],;
		                                                   aPerf[aq,14],;
		                                                   aPerf[aq,15],;
		                                                   aPerf[aq,16]  })
																	   
																	    
Next

ENDIF     

// Fim da aba Detalhada 







///Chama o MS Excel para impressão


oExcel:Activate()

If Right(cPath,len(cPath)) <> "\"
	cPath += "\"
Endif

oExcel:GetXMLFile(cPath+Alltrim("GESTAODEFUNCIONARIOS")+".xml")

IF ApOleClient("MsExcel")
	oExcelApp := MsExcel():New()
	oExcelApp:WorkBooks:Open(cPath+Alltrim("GESTAODEFUNCIONARIOS")+".xml")
	oExcelApp:SetVisible(.T.)
	oExcelApp:Destroy()
Else
	ShellExecute("open",cPath+Alltrim("GESTAODEFUNCIONARIOS")+".xml","","",1)
EndIf 






RETURN()





**************************
Static Function fCriaSx1()
**************************
Local X1, Z
SX1->(DbSetOrder(1))

If SX1->(!DbSeek(cPerg+aSx1[Len(aSx1),2]))
	SX1->(DbSeek(cPerg))
	While SX1->(!Eof()) .And. Alltrim(SX1->X1_GRUPO) == Alltrim(cPerg)
		SX1->(Reclock("SX1",.F.,.F.))
		SX1->(DbDelete())
		SX1->(MsunLock())
		SX1->(DbSkip())
	End
	For X1:=2 To Len(aSX1)
		SX1->(RecLock("SX1",.T.))
		For Z:=1 To Len(aSX1[1])
			cCampo := "X1_"+aSX1[1,Z]
			SX1->(FieldPut(FieldPos(cCampo),aSx1[X1,Z]))
		Next
		SX1->(MsunLock())
	Next
Endif




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³fPerf1    ºAutor  ³Jorge Paiva         º Data ³  23/11/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Monta Array para Aba Funcionarios                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ STATEGRID                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function  fPerf1()
Local aArea		:= GetArea()
Local aRet      := {}
Local cArq      := ""  
Local cQuery    := ""
Local cTipo		:= 2 // comeca com 2 pq era o SQL original.

beginSQL alias "TMP"
	%noParser%
	SELECT RFQ_STATUS 
	FROM %table:RFQ%
	WHERE RFQ_PERIOD = %exp:MV_PAR03% AND RFQ_PROCES = '00001' AND %notDel%
endSQL
if !TMP->(Eof())
	cTipo := TMP->RFQ_STATUS
endIf
TMP->(dbCloseArea())

// Alert('Tipo: ' + cTipo)

cQuery := MovQuery( cTipo )

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TMPSRA")

ProcRegua(0)

while !TMPSRA->(Eof()) 
	
	incproc("Detalhada ==> " + TMPSRA->MAT_FOLHA )  

	if Empty(TMPSRA->ADMISSAO)
		cTemp1 := "" 
	else
		cTemp1 := dtoc(STOD(TMPSRA->ADMISSAO))
	endif	
	if Empty(TMPSRA->DEMISSAO)
		cTemp2 := "" 
	else
		cTemp2 := dtoc(STOD(TMPSRA->DEMISSAO))
	endif	
	
	AADD(aRet,{   TMPSRA->FILIAL,;
				  TMPSRA->MAT_FOLHA,;
		          TMPSRA->NOME,;
		          TMPSRA->CPF,;
		          TMPSRA->ID_TAF,;
		          TMPSRA->MAT_TAF,;
		          TMPSRA->SITUACAO,;
		          cTemp1,;
		          cTemp2,;
		          TMPSRA->LIQFOL,;
		          TMPSRA->LIQ1210,;
		          TMPSRA->BASEINSSF,;
		          TMPSRA->BASEINSST	,;
		          TMPSRA->DESCINSSF,;
		          TMPSRA->DESCINSST,;
		          TMPSRA->DIF_DESCONT })
	
	TMPSRA->(DbSkip())

EndDo

TMPSRA->(DbClosearea())  

RestArea(aArea)
Return(aRet) 


Static Function MovQuery(cTipo)  
local cQuery := ""

If cTipo = '1'

cQuery := "	SELECT X.FILIAL, X.MAT_FOLHA,X.NOME,X.CPF,X.ID_TAF,X.MAT_TAF,X.SITUACAO,X.ADMISSAO,X.DEMISSAO,X.LIQFOL,  	" +CRLF
cQuery += "	ISNULL((SELECT SUM(T3R.T3R_VLRLIQ)FROM T3P010 T3P,T3Q010 T3Q, T3R010 T3R   	" +CRLF      
cQuery += "	WHERE T3P.T3P_FILIAL = X.FILIAL      "  +CRLF
cQuery += "	          AND T3P.T3P_BENEFI = X.ID_TAF            "  +CRLF
cQuery += "	          AND T3P.T3P_PERAPU = '"+MV_PAR03+"'      "  +CRLF
cQuery += "	          AND T3P.T3P_ATIVO = '1'    "  +CRLF
cQuery += "	          AND T3P.T3P_STATUS = '4'   "  +CRLF
cQuery += "	          AND T3P.D_E_L_E_T_ = ' '   "  +CRLF
cQuery += "	          AND T3Q.T3Q_FILIAL = T3P.T3P_FILIAL      "  +CRLF
cQuery += "	          AND T3Q.T3Q_ID = T3P.T3P_ID"  +CRLF
cQuery += "	          AND T3Q.T3Q_VERSAO = T3P.T3P_VERSAO      "  +CRLF
cQuery += "	          AND T3Q.T3Q_TPPGTO = '1'   "  +CRLF
cQuery += "	          AND SUBSTRING(T3Q.T3Q_DTPGTO,7,2) > '15' "  +CRLF
cQuery += "	          AND T3Q.D_E_L_E_T_ = ' '   "  +CRLF
cQuery += "	          AND T3R.T3R_FILIAL = T3Q.T3Q_FILIAL      "  +CRLF
cQuery += "	          AND T3R.T3R_ID = T3Q.T3Q_ID"  +CRLF
cQuery += "	          AND T3R.T3R_VERSAO = T3Q.T3Q_VERSAO      "  +CRLF
cQuery += "	          AND T3R.T3R_TPPGTO = T3Q.T3Q_TPPGTO      "  +CRLF
cQuery += "	          AND T3R.T3R_IDEDMD LIKE '%FOL%'          "  +CRLF
cQuery += "	          AND T3R.D_E_L_E_T_ = ' ' ),0) LIQ1210,   "  +CRLF
cQuery += "	       X.BASEINSSF,      "  +CRLF
cQuery += "	       X.BASEINSST,      "  +CRLF
cQuery += "	       X.DESCINSSF,      "  +CRLF
cQuery += "	       X.DESCINSST,      "  +CRLF
cQuery += "	       X.BASEFGTSFO,     "  +CRLF
cQuery += "	       X.VALFGTSFO,      "  +CRLF
cQuery += "	       X.DESCINSSF-X.DESCINSST DIF_DESCONT         "  +CRLF
cQuery += "	FROM (	SELECT SRA.RA_FILIAL FILIAL, SRA.RA_MAT MAT_FOLHA,SRA.RA_NOME NOME,SRA.RA_CIC CPF,  "  +CRLF
cQuery += "	       (select MAX(C9V.C9V_ID)       "  +CRLF
cQuery += "	        FROM C9V010 C9V         "  +CRLF
cQuery += "	        WHERE C9V.C9V_FILIAL = SRA.RA_FILIAL       "  +CRLF
cQuery += "	         AND C9V.C9V_MATRIC = SRA.RA_CODUNIC       "  +CRLF
cQuery += "	         AND C9V.C9V_ATIVO = '1'     "  +CRLF
cQuery += "	         AND C9V.C9V_STATUS = '4'    "  +CRLF
cQuery += "	         AND C9V.D_E_L_E_T_ = ' ') ID_TAF,         "  +CRLF
cQuery += "	       SRA.RA_CODUNIC MAT_TAF,       "  +CRLF
cQuery += "	       (CASE             "  +CRLF
cQuery += "	            WHEN SRA.RA_SITFOLH = ' '"  +CRLF
cQuery += "	             THEN 'ATIVO'"  +CRLF
cQuery += "	            WHEN SRA.RA_SITFOLH = 'D' OR (SRA.RA_DEMISSA <= " + DToS(Date()) + " AND SRA.RA_DEMISSA <> ' ') "
cQuery += "	             THEN 'DEMITIDO'     "  +CRLF
cQuery += "	            WHEN SRA.RA_SITFOLH = 'A'          "  +CRLF
cQuery += "	             THEN 'AFASTADO'     "  +CRLF
cQuery += "	            WHEN SRA.RA_SITFOLH = 'F'          "  +CRLF
cQuery += "	             THEN 'FERIAS'       "  +CRLF
cQuery += "	            ELSE SRA.RA_SITFOLH  "  +CRLF
cQuery += "	        END) SITUACAO,  "  +CRLF
cQuery += "	        SRA.RA_ADMISSA ADMISSAO, "  +CRLF
cQuery += "	        SRA.RA_DEMISSA DEMISSAO, "  +CRLF
cQuery += "	     ISNULL(            "  +CRLF
cQuery += "	      (SELECT SUM(SRD.RD_VALOR)  "  +CRLF
cQuery += "	       FROM SRD010 SRD, SRA010 RA    "  +CRLF
cQuery += "	       WHERE SRD.RD_FILIAL = RA.RA_FILIAL      "  +CRLF
cQuery += "	        AND SRD.RD_MAT = RA.RA_MAT             "  +CRLF
cQuery += "	        AND SRD.RD_PERIODO = '"+MV_PAR03+"'    "  +CRLF
cQuery += "	        AND SRD.RD_ROTEIR IN ('FOL','AUT')"  +CRLF
cQuery += "	        AND SRD.RD_PD IN(SELECT SRV.RV_COD     "  +CRLF
cQuery += "	           FROM SRV010 SRV  "  +CRLF
cQuery += "	            WHERE SRV.RV_FILIAL = ' '       "  +CRLF
cQuery += "	             AND SRV.RV_CODFOL IN ('0047')   "  +CRLF
cQuery += "	             AND SRV.D_E_L_E_T_ = ' ')       "  +CRLF
cQuery += "	        AND (SUBSTRING(SRA.RA_DEMISSA,1,6) >= SRD.RD_PERIODO OR SRA.RA_DEMISSA = ' ' ) "
cQuery += "	        AND RA.RA_CIC = SRA.RA_CIC             "  +CRLF
cQuery += "	        AND RA.D_E_L_E_T_ = ' '  "  +CRLF
cQuery += "	        AND SRD.D_E_L_E_T_ = ' ' "  +CRLF
cQuery += "	       ),0) LIQFOL,     "  +CRLF
cQuery += "	      ISNULL(           "  +CRLF
cQuery += "	      (SELECT SUM(SRD.RD_VALOR)  "  +CRLF
cQuery += "	       FROM SRD010 SRD, SRA010 RA    "  +CRLF
cQuery += "	       WHERE SRD.RD_FILIAL = RA.RA_FILIAL      "  +CRLF
cQuery += "	        AND SRD.RD_MAT = RA.RA_MAT             "  +CRLF
cQuery += "	        AND SRD.RD_PERIODO = '"+MV_PAR03+"'    "  +CRLF
cQuery += "	        AND SRD.RD_ROTEIR IN ('FOL','AUT')"  +CRLF
cQuery += "	        AND SRD.RD_PD IN(SELECT SRV.RV_COD     "  +CRLF
cQuery += "	           FROM SRV010 SRV  "  +CRLF
cQuery += "	            WHERE SRV.RV_FILIAL = ' '       "  +CRLF
cQuery += "	             AND SRV.RV_CODFOL IN ('0013','0014','0019','0020','0338')   "  +CRLF
cQuery += "	             AND SRV.D_E_L_E_T_ = ' ')       "  +CRLF
cQuery += "	        AND (SUBSTRING(SRA.RA_DEMISSA,1,6) >= SRD.RD_PERIODO OR SRA.RA_DEMISSA = ' ' ) "  +CRLF
cQuery += "	        AND RA.RA_CIC = SRA.RA_CIC             "  +CRLF
cQuery += "	        AND RA.D_E_L_E_T_ = ' '  "  +CRLF
cQuery += "	        AND SRD.D_E_L_E_T_ = ' ' "  +CRLF
cQuery += "	       ),0) BASEINSSF,  "  +CRLF
cQuery += "	       ISNULL(          "  +CRLF
cQuery += "	       (SELECT SUM(T2R.T2R_VALOR)"  +CRLF
cQuery += "	        FROM T2M010 T2M, T2R010 T2R  "  +CRLF
cQuery += "	        WHERE T2M.T2M_FILIAL = SRA.RA_FILIAL   "  +CRLF
cQuery += "	         AND T2M.T2M_CPFTRB = SRA.RA_CIC       "  +CRLF
cQuery += "	         AND T2M.T2M_PERAPU = '"+MV_PAR03+"'   "  +CRLF
cQuery += "	         AND T2M.T2M_FILIAL = T2R.T2R_FILIAL   "  +CRLF
cQuery += "	         AND T2M.T2M_VERSAO = T2R.T2R_VERSAO   "  +CRLF
cQuery += "	         AND T2R.T2R_MATRIC = SRA.RA_CODUNIC   "  +CRLF
cQuery += "	         AND T2R.T2R_TPVLR IN (SELECT T2T_ID   "  +CRLF
cQuery += "	   FROM T2T010 T2T        "  +CRLF
cQuery += "	   WHERE T2T.T2T_CODIGO BETWEEN '11' AND '19'"  +CRLF
cQuery += "	    AND T2T.D_E_L_E_T_ = ' ' ) "  +CRLF
cQuery += "	         AND T2M.D_E_L_E_T_ = ' '"  +CRLF
cQuery += "	         AND T2R.D_E_L_E_T_ = ' '"  +CRLF
cQuery += "	         AND T2M.R_E_C_N_O_ IN (SELECT MAX(T2MX.R_E_C_N_O_)"  +CRLF
cQuery += "	    FROM T2M010  T2MX     "  +CRLF
cQuery += "	    WHERE T2MX.T2M_FILIAL = T2M.T2M_FILIAL   "  +CRLF
cQuery += "	     AND T2MX.T2M_CPFTRB = T2M.T2M_CPFTRB    "  +CRLF
cQuery += "	     AND T2MX.T2M_PERAPU = T2M.T2M_PERAPU    "  +CRLF
cQuery += "	     AND T2MX.D_E_L_E_T_ = ' ')"  +CRLF
cQuery += "	        ),0) BASEINSST, "  +CRLF
cQuery += "	      ISNULL(           "  +CRLF
cQuery += "	      (SELECT SUM(SRD.RD_VALOR)  "  +CRLF
cQuery += "	       FROM SRD010 SRD, SRA010 RA    "  +CRLF
cQuery += "	       WHERE SRD.RD_FILIAL = RA.RA_FILIAL      "  +CRLF
cQuery += "	        AND SRD.RD_MAT = RA.RA_MAT             "  +CRLF
cQuery += "	        AND SRD.RD_PERIODO = '"+MV_PAR03+"'    "  +CRLF
cQuery += "	        AND SRD.RD_ROTEIR IN ('FOL','AUT')"  +CRLF
cQuery += "	        AND SRD.RD_PD IN(SELECT SRV.RV_COD     "  +CRLF
cQuery += "	           FROM SRV010 SRV  "  +CRLF
cQuery += "	           WHERE SRV.RV_FILIAL = ' '        "  +CRLF
cQuery += "	            AND SRV.RV_CODFOL IN ('0064','0065','0070','0340')           "  +CRLF
cQuery += "	            AND SRV.D_E_L_E_T_ = ' ')        "  +CRLF
cQuery += "	        AND (SUBSTRING(SRA.RA_DEMISSA,1,6) >= SRD.RD_PERIODO OR SRA.RA_DEMISSA = ' ' ) "
cQuery += "	        AND RA.RA_CIC = SRA.RA_CIC             "  +CRLF
cQuery += "	        AND RA.D_E_L_E_T_ = ' '  "  +CRLF
cQuery += "	        AND SRD.D_E_L_E_T_ = ' ' "  +CRLF
cQuery += "	       ),0) DESCINSSF,  "  +CRLF
cQuery += "	      ISNULL(           "  +CRLF
cQuery += "	       (SELECT SUM(T2O.T2O_VRCPSE)             "  +CRLF
cQuery += "	        FROM T2M010 T2M, T2O010 T2O  "  +CRLF
cQuery += "	        WHERE T2M.T2M_FILIAL = SRA.RA_FILIAL   "  +CRLF
cQuery += "	         AND T2M.T2M_CPFTRB = SRA.RA_CIC       "  +CRLF
cQuery += "	         AND T2M.T2M_PERAPU = '"+MV_PAR03+"'   "  +CRLF
cQuery += "	         AND T2M.T2M_FILIAL = T2O.T2O_FILIAL   "  +CRLF
cQuery += "	         AND T2M.T2M_VERSAO = T2O.T2O_VERSAO   "  +CRLF
cQuery += "	         AND T2O.T2O_IDCODR IN (SELECT C6R_ID  "  +CRLF
cQuery += "	   FROM C6R010 C6R        "  +CRLF
cQuery += "	   WHERE C6R.C6R_CODIGO = '108201'           "  +CRLF
cQuery += "	    AND C6R.D_E_L_E_T_ = ' ' ) "  +CRLF
cQuery += "	         AND T2M.D_E_L_E_T_ = ' '"  +CRLF
cQuery += "	         AND T2O.D_E_L_E_T_ = ' '"  +CRLF
cQuery += "	         AND T2M.R_E_C_N_O_ IN (SELECT MAX(T2MX.R_E_C_N_O_)"  +CRLF
cQuery += "	    FROM T2M010  T2MX     "  +CRLF
cQuery += "	    WHERE T2MX.T2M_FILIAL = T2M.T2M_FILIAL   "  +CRLF
cQuery += "	     AND T2MX.T2M_CPFTRB = T2M.T2M_CPFTRB    "  +CRLF
cQuery += "	     AND T2MX.T2M_PERAPU = T2M.T2M_PERAPU    "  +CRLF
cQuery += "	     AND T2MX.D_E_L_E_T_ = ' ')"  +CRLF
cQuery += "	        ),0) DESCINSST, "  +CRLF
cQuery += "	      ISNULL(           "  +CRLF
cQuery += "	      (SELECT SUM(SRD.RD_VALOR)  "  +CRLF
cQuery += "	       FROM SRD010 SRD, SRA010 RA    "  +CRLF
cQuery += "	       WHERE SRD.RD_FILIAL = RA.RA_FILIAL      "  +CRLF
cQuery += "	        AND SRD.RD_MAT = RA.RA_MAT             "  +CRLF
cQuery += "	        AND SRD.RD_PERIODO = '"+MV_PAR03+"'    "  +CRLF
cQuery += "	        AND SRD.RD_ROTEIR IN ('FOL','AUT')"  +CRLF
cQuery += "	        AND SRD.RD_PD IN(SELECT SRV.RV_COD     "  +CRLF
cQuery += "	           FROM SRV010 SRV  "  +CRLF
cQuery += "	           WHERE SRV.RV_FILIAL = ' '        "  +CRLF
cQuery += "	            AND SRV.RV_CODFOL IN ('0017','0108')           "  +CRLF
cQuery += "	            AND SRV.D_E_L_E_T_ = ' ')        "  +CRLF
cQuery += "	        AND (SUBSTRING(SRA.RA_DEMISSA,1,6) >= SRD.RD_PERIODO OR SRA.RA_DEMISSA = ' ' ) "  +CRLF
cQuery += "	        AND RA.RA_CIC = SRA.RA_CIC             "  +CRLF
cQuery += "	        AND RA.D_E_L_E_T_ = ' '  "  +CRLF
cQuery += "	        AND SRD.D_E_L_E_T_ = ' ' "  +CRLF
cQuery += "	       ),0) BASEFGTSFO, "  +CRLF
cQuery += "	        ISNULL(         "  +CRLF
cQuery += "	      (SELECT SUM(SRD.RD_VALOR)  "  +CRLF
cQuery += "	       FROM SRD010 SRD, SRA010 RA    "  +CRLF
cQuery += "	       WHERE SRD.RD_FILIAL = RA.RA_FILIAL      "  +CRLF
cQuery += "	        AND SRD.RD_MAT = RA.RA_MAT             "  +CRLF
cQuery += "	        AND SRD.RD_PERIODO = '"+MV_PAR03+"'    "  +CRLF
cQuery += "	        AND SRD.RD_ROTEIR IN ('FOL','AUT')"  +CRLF
cQuery += "	        AND SRD.RD_PD IN(SELECT SRV.RV_COD     "  +CRLF
cQuery += "	           FROM SRV010 SRV  "  +CRLF
cQuery += "	           WHERE SRV.RV_FILIAL = ' '        "  +CRLF
cQuery += "	            AND SRV.RV_CODFOL IN ('0018','0109')           "  +CRLF
cQuery += "	            AND SRV.D_E_L_E_T_ = ' ')        "  +CRLF
cQuery += "	        AND (SUBSTRING(SRA.RA_DEMISSA,1,6) >= SRD.RD_PERIODO OR SRA.RA_DEMISSA = ' ' ) " +CRLF
cQuery += "	        AND RA.RA_CIC = SRA.RA_CIC            "  +CRLF
cQuery += "	        AND RA.D_E_L_E_T_ = ' ' "  +CRLF
cQuery += "	        AND SRD.D_E_L_E_T_ = ' '"  +CRLF
cQuery += "	       ),0) VALFGTSFO  "  +CRLF
cQuery += "	FROM SRA010 SRA   "  +CRLF
cQuery += "	WHERE SRA.RA_FILIAL  BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'           "  +CRLF
cQuery += "	 AND SRA.RA_MAT between '"+MV_PAR01+"' and '"+MV_PAR02+"'"  +CRLF
//cQuery += "	 AND SRA.RA_PROCES <> '00003' "  +CRLF
cQuery += " 	 AND SRA.RA_RESCRAI <> '31'	           "  +CRLF
cQuery += "	 AND (SUBSTRING(SRA.RA_DEMISSA,1,6) >= '"+MV_PAR03+"' OR SRA.RA_DEMISSA = ' ' )   "  +CRLF
cQuery += "	 AND (SUBSTRING(SRA.RA_ADMISSA,1,6) <= '"+MV_PAR03+"' OR SRA.RA_ADMISSA = ' ' )  " +CRLF
cQuery += "	 AND SRA.D_E_L_E_T_ = ' '  " +CRLF
cQuery += "	) X"  +CRLF
cQuery += "	ORDER BY X.FILIAL, X.NOME " +CRLF

Else // If cTipo = '2' 

	cQuery := "	SELECT X.FILIAL, X.MAT_FOLHA,X.NOME,X.CPF,X.ID_TAF,X.MAT_TAF,X.SITUACAO,X.ADMISSAO,X.DEMISSAO,X.LIQFOL, " + CRLF
	cQuery += "	ISNULL((SELECT SUM(T3R.T3R_VLRLIQ)FROM T3P010 T3P,T3Q010 T3Q, T3R010 T3R " + CRLF                                  
	cQuery += "	WHERE T3P.T3P_FILIAL = X.FILIAL " + CRLF
	cQuery += "	          AND T3P.T3P_BENEFI = X.ID_TAF " + CRLF
	cQuery += "	          AND T3P.T3P_PERAPU = '"+MV_PAR03+"' " + CRLF
	cQuery += "	          AND T3P.T3P_ATIVO = '1' " + CRLF
	cQuery += "	          AND T3P.T3P_STATUS = '4' " + CRLF
	cQuery += "	          AND T3P.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "	          AND T3Q.T3Q_FILIAL = T3P.T3P_FILIAL " + CRLF
	cQuery += "	          AND T3Q.T3Q_ID = T3P.T3P_ID " + CRLF
	cQuery += "	          AND T3Q.T3Q_VERSAO = T3P.T3P_VERSAO " + CRLF
	cQuery += "	          AND T3Q.T3Q_TPPGTO = '1' " + CRLF
	cQuery += "	          AND SUBSTRING(T3Q.T3Q_DTPGTO,7,2) > '15' " + CRLF
	cQuery += "	          AND T3Q.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "	          AND T3R.T3R_FILIAL = T3Q.T3Q_FILIAL " + CRLF
	cQuery += "	          AND T3R.T3R_ID = T3Q.T3Q_ID " + CRLF
	cQuery += "	          AND T3R.T3R_VERSAO = T3Q.T3Q_VERSAO " + CRLF
	cQuery += "	          AND T3R.T3R_TPPGTO = T3Q.T3Q_TPPGTO " + CRLF
	cQuery += "	          AND T3R.T3R_IDEDMD LIKE '%FOL%' " + CRLF
	cQuery += "	          AND T3R.D_E_L_E_T_ = ' ' ),0) LIQ1210, " + CRLF
	cQuery += "	       X.BASEINSSF, " + CRLF
	cQuery += "	       X.BASEINSST, " + CRLF
	cQuery += "	       X.DESCINSSF, " + CRLF
	cQuery += "	       X.DESCINSST, " + CRLF
	cQuery += "	       X.BASEFGTSFO, " + CRLF
	cQuery += "	       X.VALFGTSFO, " + CRLF
	cQuery += "	       X.DESCINSSF-X.DESCINSST DIF_DESCONT " + CRLF
	cQuery += "	FROM (	SELECT SRA.RA_FILIAL FILIAL, SRA.RA_MAT MAT_FOLHA,SRA.RA_NOME NOME,SRA.RA_CIC CPF, " + CRLF
	cQuery += "	       (select MAX(C9V.C9V_ID) " + CRLF
	cQuery += "	        FROM C9V010 C9V " + CRLF
	cQuery += "	        WHERE C9V.C9V_FILIAL = SRA.RA_FILIAL " + CRLF
	cQuery += "	         AND C9V.C9V_MATRIC = SRA.RA_CODUNIC " + CRLF
	cQuery += "	         AND C9V.C9V_ATIVO = '1' " + CRLF
	cQuery += "	         AND C9V.C9V_STATUS = '4' " + CRLF
	cQuery += "	         AND C9V.D_E_L_E_T_ = ' ') ID_TAF, " + CRLF
	cQuery += "	       SRA.RA_CODUNIC MAT_TAF, " + CRLF
	cQuery += "	       (CASE " + CRLF
	cQuery += "	            WHEN SRA.RA_SITFOLH = ' ' " + CRLF
	cQuery += "	             THEN 'ATIVO' " + CRLF
	cQuery += "	            WHEN SRA.RA_SITFOLH = 'D' OR (SRA.RA_DEMISSA <= " + DToS(Date()) + " AND SRA.RA_DEMISSA <> ' ') "
	cQuery += "	             THEN 'DEMITIDO' " + CRLF
	cQuery += "	            WHEN SRA.RA_SITFOLH = 'A' " + CRLF
	cQuery += "	             THEN 'AFASTADO' " + CRLF
	cQuery += "	            WHEN SRA.RA_SITFOLH = 'F' " + CRLF
	cQuery += "	             THEN 'FERIAS' " + CRLF
	cQuery += "	            ELSE SRA.RA_SITFOLH " + CRLF
	cQuery += "	        END) SITUACAO, " + CRLF
	cQuery += "	        SRA.RA_ADMISSA ADMISSAO, " + CRLF
	cQuery += "	        SRA.RA_DEMISSA DEMISSAO, " + CRLF
	cQuery += "	     ISNULL( " + CRLF
	cQuery += "	      (SELECT SUM(SRD.RD_VALOR) " + CRLF
	cQuery += "	       FROM SRD010 SRD, SRA010 RA " + CRLF
	cQuery += "	       WHERE SRD.RD_FILIAL = RA.RA_FILIAL " + CRLF
	cQuery += "	        AND SRD.RD_MAT = RA.RA_MAT " + CRLF
	cQuery += "	        AND SRD.RD_PERIODO = '"+MV_PAR03+"' " + CRLF
	cQuery += "	        AND SRD.RD_ROTEIR IN ('FOL','AUT') " + CRLF
	cQuery += "	        AND SRD.RD_PD IN(SELECT SRV.RV_COD " + CRLF
	cQuery += "	                         FROM SRV010 SRV " + CRLF
	cQuery += "	                          WHERE SRV.RV_FILIAL = ' ' " + CRLF
	cQuery += "	                           AND SRV.RV_CODFOL IN ('0047') " + CRLF
	cQuery += "	                           AND SRV.D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "	        AND (SUBSTRING(SRA.RA_DEMISSA,1,6) >= SRD.RD_PERIODO OR SRA.RA_DEMISSA = ' ' ) "
	cQuery += "	        AND RA.RA_CIC = SRA.RA_CIC " + CRLF
	cQuery += "	        AND RA.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "	        AND SRD.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "	       ),0) LIQFOL, " + CRLF
	cQuery += "	      ISNULL( " + CRLF
	cQuery += "	      (SELECT SUM(SRD.RD_VALOR) " + CRLF
	cQuery += "	       FROM SRD010 SRD, SRA010 RA " + CRLF
	cQuery += "	       WHERE SRD.RD_FILIAL = RA.RA_FILIAL " + CRLF
	cQuery += "	        AND SRD.RD_MAT = RA.RA_MAT " + CRLF
	cQuery += "	        AND SRD.RD_PERIODO = '"+MV_PAR03+"' " + CRLF
	cQuery += "	        AND SRD.RD_ROTEIR IN ('FOL','AUT') " + CRLF
	cQuery += "	        AND SRD.RD_PD IN(SELECT SRV.RV_COD " + CRLF
	cQuery += "	                         FROM SRV010 SRV " + CRLF
	cQuery += "	                          WHERE SRV.RV_FILIAL = ' ' " + CRLF
	cQuery += "	                           AND SRV.RV_CODFOL IN ('0013','0014','0019','0020','0338') " + CRLF
	cQuery += "	                           AND SRV.D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "	        AND (SUBSTRING(SRA.RA_DEMISSA,1,6) >= SRD.RD_PERIODO OR SRA.RA_DEMISSA = ' ' ) "
	cQuery += "	        AND RA.RA_CIC = SRA.RA_CIC " + CRLF
	cQuery += "	        AND RA.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "	        AND SRD.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "	       ),0) BASEINSSF, " + CRLF
	cQuery += "	       ISNULL( " + CRLF
	cQuery += "	       (SELECT SUM(T2R.T2R_VALOR) " + CRLF
	cQuery += "	        FROM T2M010 T2M, T2R010 T2R " + CRLF
	cQuery += "	        WHERE T2M.T2M_FILIAL = SRA.RA_FILIAL " + CRLF
	cQuery += "	         AND T2M.T2M_CPFTRB = SRA.RA_CIC " + CRLF
	cQuery += "	         AND T2M.T2M_PERAPU = '"+MV_PAR03+"' " + CRLF
	cQuery += "	         AND T2M.T2M_FILIAL = T2R.T2R_FILIAL " + CRLF
	cQuery += "	         AND T2M.T2M_VERSAO = T2R.T2R_VERSAO " + CRLF
	cQuery += "	         AND T2R.T2R_MATRIC = SRA.RA_CODUNIC " + CRLF
	cQuery += "	         AND T2R.T2R_TPVLR IN (SELECT T2T_ID " + CRLF
	cQuery += "	                               FROM T2T010 T2T " + CRLF
	cQuery += "	                               WHERE T2T.T2T_CODIGO BETWEEN '11' AND '19' " + CRLF
	cQuery += "	                                AND T2T.D_E_L_E_T_ = ' ' ) " + CRLF
	cQuery += "	         AND T2M.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "	         AND T2R.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "	         AND T2M.R_E_C_N_O_ IN (SELECT MAX(T2MX.R_E_C_N_O_) " + CRLF
	cQuery += "	                                FROM T2M010  T2MX" + CRLF
	cQuery += "	                                WHERE T2MX.T2M_FILIAL = T2M.T2M_FILIAL " + CRLF
	cQuery += "	                                 AND T2MX.T2M_CPFTRB = T2M.T2M_CPFTRB" + CRLF
	cQuery += "	                                 AND T2MX.T2M_PERAPU = T2M.T2M_PERAPU" + CRLF
	cQuery += "	                                 AND T2MX.D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "	        ),0) BASEINSST, " + CRLF
	cQuery += "	      ISNULL( " + CRLF
	cQuery += "	      (SELECT SUM(SRD.RD_VALOR) " + CRLF
	cQuery += "	       FROM SRD010 SRD, SRA010 RA " + CRLF
	cQuery += "	       WHERE SRD.RD_FILIAL = RA.RA_FILIAL " + CRLF
	cQuery += "	        AND SRD.RD_MAT = RA.RA_MAT " + CRLF
	cQuery += "	        AND SRD.RD_PERIODO = '"+MV_PAR03+"' " + CRLF
	cQuery += "	        AND SRD.RD_ROTEIR IN ('FOL','AUT') " + CRLF
	cQuery += "	        AND SRD.RD_PD IN(SELECT SRV.RV_COD " + CRLF
	cQuery += "	                         FROM SRV010 SRV " + CRLF
	cQuery += "	                         WHERE SRV.RV_FILIAL = ' ' " + CRLF
	cQuery += "	                          AND SRV.RV_CODFOL IN ('0064','0065','0070','0340') " + CRLF
	cQuery += "	                          AND SRV.D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "	        AND (SUBSTRING(SRA.RA_DEMISSA,1,6) >= SRD.RD_PERIODO OR SRA.RA_DEMISSA = ' ' ) "
	cQuery += "	        AND RA.RA_CIC = SRA.RA_CIC " + CRLF
	cQuery += "	        AND RA.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "	        AND SRD.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "	       ),0) DESCINSSF, " + CRLF
	cQuery += "	      ISNULL( " + CRLF
	cQuery += "	       (SELECT SUM(T2O.T2O_VRCPSE) " + CRLF
	cQuery += "	        FROM T2M010 T2M, T2O010 T2O " + CRLF
	cQuery += "	        WHERE T2M.T2M_FILIAL = SRA.RA_FILIAL " + CRLF
	cQuery += "	         AND T2M.T2M_CPFTRB = SRA.RA_CIC " + CRLF
	cQuery += "	         AND T2M.T2M_PERAPU = '"+MV_PAR03+"' " + CRLF
	cQuery += "	         AND T2M.T2M_FILIAL = T2O.T2O_FILIAL " + CRLF
	cQuery += "	         AND T2M.T2M_VERSAO = T2O.T2O_VERSAO " + CRLF
	cQuery += "	         AND T2O.T2O_IDCODR IN (SELECT C6R_ID " + CRLF
	cQuery += "	                               FROM C6R010 C6R " + CRLF
	cQuery += "	                               WHERE C6R.C6R_CODIGO = '108201' " + CRLF
	cQuery += "	                                AND C6R.D_E_L_E_T_ = ' ' ) " + CRLF
	cQuery += "	         AND T2M.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "	         AND T2O.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "	         AND T2M.R_E_C_N_O_ IN (SELECT MAX(T2MX.R_E_C_N_O_) " + CRLF
	cQuery += "	                                FROM T2M010  T2MX" + CRLF
	cQuery += "	                                WHERE T2MX.T2M_FILIAL = T2M.T2M_FILIAL " + CRLF
	cQuery += "	                                 AND T2MX.T2M_CPFTRB = T2M.T2M_CPFTRB" + CRLF
	cQuery += "	                                 AND T2MX.T2M_PERAPU = T2M.T2M_PERAPU" + CRLF
	cQuery += "	                                 AND T2MX.D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "	        ),0) DESCINSST, " + CRLF
	cQuery += "	      ISNULL( " + CRLF
	cQuery += "	      (SELECT SUM(SRD.RD_VALOR) " + CRLF
	cQuery += "	       FROM SRD010 SRD, SRA010 RA " + CRLF
	cQuery += "	       WHERE SRD.RD_FILIAL = RA.RA_FILIAL " + CRLF
	cQuery += "	        AND SRD.RD_MAT = RA.RA_MAT " + CRLF
	cQuery += "	        AND SRD.RD_PERIODO = '"+MV_PAR03+"' " + CRLF
	cQuery += "	        AND SRD.RD_ROTEIR IN ('FOL','AUT') " + CRLF
	cQuery += "	        AND SRD.RD_PD IN(SELECT SRV.RV_COD " + CRLF
	cQuery += "	                         FROM SRV010 SRV " + CRLF
	cQuery += "	                         WHERE SRV.RV_FILIAL = ' ' " + CRLF
	cQuery += "	                          AND SRV.RV_CODFOL IN ('0017','0108') " + CRLF
	cQuery += "	                          AND SRV.D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "	        AND (SUBSTRING(SRA.RA_DEMISSA,1,6) >= SRD.RD_PERIODO OR SRA.RA_DEMISSA = ' ' ) "
	cQuery += "	        AND RA.RA_CIC = SRA.RA_CIC " + CRLF
	cQuery += "	        AND RA.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "	        AND SRD.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "	       ),0) BASEFGTSFO, " + CRLF
	cQuery += "	        ISNULL(" + CRLF
	cQuery += "	      (SELECT SUM(SRD.RD_VALOR) " + CRLF
	cQuery += "	       FROM SRD010 SRD, SRA010 RA " + CRLF
	cQuery += "	       WHERE SRD.RD_FILIAL = RA.RA_FILIAL " + CRLF
	cQuery += "	        AND SRD.RD_MAT = RA.RA_MAT " + CRLF
	cQuery += "	        AND SRD.RD_PERIODO = '"+MV_PAR03+"' " + CRLF
	cQuery += "	        AND SRD.RD_ROTEIR IN ('FOL','AUT') " + CRLF
	cQuery += "	        AND SRD.RD_PD IN(SELECT SRV.RV_COD " + CRLF
	cQuery += "	                         FROM SRV010 SRV " + CRLF
	cQuery += "	                         WHERE SRV.RV_FILIAL = ' ' " + CRLF
	cQuery += "	                          AND SRV.RV_CODFOL IN ('0018','0109') " + CRLF
	cQuery += "	                          AND SRV.D_E_L_E_T_ = ' ') " + CRLF
	cQuery += "	        AND (SUBSTRING(SRA.RA_DEMISSA,1,6) >= SRD.RD_PERIODO OR SRA.RA_DEMISSA = ' ' ) " +CRLF
	cQuery += "	        AND RA.RA_CIC = SRA.RA_CIC " + CRLF
	cQuery += "	        AND RA.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "	        AND SRD.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += "	       ),0) VALFGTSFO " + CRLF
	cQuery += "	FROM SRA010 SRA " + CRLF
	cQuery += "	WHERE SRA.RA_FILIAL  BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' " + CRLF
	cQuery += "	 AND SRA.RA_MAT between '"+MV_PAR01+"' and '"+MV_PAR02+"' " + CRLF
	//cQuery += "	 AND SRA.RA_PROCES <> '00003' " + CRLF
	cQuery += " 	 AND SRA.RA_RESCRAI <> '31'	 " + CRLF
	cQuery += "	 AND (SUBSTRING(SRA.RA_DEMISSA,1,6) >= '"+MV_PAR03+"' OR SRA.RA_DEMISSA = ' ' ) " + CRLF
	cQuery += "	 AND (SUBSTRING(SRA.RA_ADMISSA,1,6) <= '"+MV_PAR03+"' OR SRA.RA_ADMISSA = ' ' )  " +CRLF
	cQuery += "	 AND SRA.D_E_L_E_T_ = ' '  " +CRLF
	cQuery += "	) X " + CRLF
	cQuery += "	ORDER BY X.FILIAL, X.NOME " +CRLF

	MemoWrite(StrTran(cArquivo,".xml","")+"GERATAF.sql" , cQuery)
endif

Return cQuery
