//**********************************************
// Relatório Auxiliar de DMG
//**********************************************
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"  
#INCLUDE "RWMAKE.CH"    
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"


/*               
___________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VACOMR04   ¦ Autor ¦ Arthur Toshio	    ¦ Data ¦ 06/07/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Relatório auxiliar de retistro de DMG 		    		  ¦¦¦
¦¦¦          ¦      									  		  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ Especifico Vista Alegre                                    ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/

//Constantes 
#DEFINE PAD_RIGHT 	1 

#DEFINE COL_1		0000
#DEFINE COL_2		0300
#DEFINE COL_3		0550
#DEFINE COL_4		0700
#DEFINE COL_5		0900
#DEFINE COL_6		1100
#DEFINE COL_7		1700 
#DEFINE COL_8		3000
#DEFINE EXTESAO 	3200
#DEFINE CENTRO  	1500
#DEFINE CDIREITO 	2900

User Function VACOMR04()

Private cPerg

	nOrdem   :=0
	tamanho  :="P"
	limite   :=80
	titulo   :=PADC("VACOMR04",74)
	cDesc1   :=PADC("Relatorio auxiliar DMG",74)
	cDesc2   :=""
	cDesc3   :=""
	aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
	nomeprog :="VACOMR04"
	cPerg    :="VACOMR04"
	nLastKey := 0
	wnrel    := "VACOMR04"
	cQuery	 :=""

	ValidPerg(cPerg)
	
	If Pergunte(cPerg, .T.)
		MsgRun("Gerando Relatorio, Aguarde...","",{|| CursorWait(),ImprRel(@cPerg),CursorArrow()})
	Endif

	
Return                        

///**************************************************************************
///PERGUNTAS DO RELATÓRIO
///**************************************************************************
Static Function ValidPerg(cPerg)
Local _sAlias,i,j

	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(cPerg,10)
	aRegs:={}                                                  

	AADD(aRegs,{cPerg,"01","Filial De             ?",Space(20),Space(20),"mv_ch1","C",02,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"02","Filial Ate            ?",Space(20),Space(20),"mv_ch2","C",02,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"03","Emissao de         	  ?",Space(20),Space(20),"mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"04","Emissao até        	  ?",Space(20),Space(20),"mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"05","Livro	        	  ?",Space(20),Space(20),"mv_ch5","N",08,0,0,"C","","mv_par05","Entrada","","","","","Saída","","","","","Ambos","","","","","","","","","","","","","","","","","","",""})
	//AADD(aRegs,{cPerg,"05","Forn/Cli De       	  ?",Space(20),Space(20),"mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","FOR","","","","",""})
	//AADD(aRegs,{cPerg,"06","Forn/Cli Ate      	  ?",Space(20),Space(20),"mv_ch6","C",06,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","FOR","","","","",""})
	
	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				FieldPut(j,aRegs[i,j])
			Next
			MsUnlock()
			dbCommit()
		EndIf
	Next
	dbSelectArea(_sAlias)
	
Return



//relatorio de insumos via excel
// 1a. Versao
Static Function ImprRel(cPerg)           
Local aArea 	:= getArea()
Local cQuery	:= ''
Local cAba1 	:= "Rel. Notas Fiscais"
Local cTable1	:= "Relatório Auxiliar de registro de entrada/saída - DMG" 	
Local nVlFrete	:= 0
// Tratamento para Excel
Private oExcel
Private oExcelApp
Private cArquivo  := GetTempPath()+'VAESTR04_Aux_DMG'+StrTran(dToC(dDataBase), '/', '-')+'_'+StrTran(Time(), ':', '-')+'.xml'

/*
-- LISTA REGISTRO DE NOTA FISCAL DE ENTRADA CONFORME LAYOUT DA PLANILHA AUXILIAR DO DMG
SELECT 
	   'NF'			AS		ESPECIE,
	   D1_SERIE		AS		SERIE,
	   D1_DOC		AS		NUMERO,
	   D1_EMISSAO	AS		EMISSAO,
	   D1_QUANT		AS		ENTRADA,
	   ''			AS		SAÍDA,
	   A2_NOME		AS		NOME,
	   A2_INSCR 	AS		INSCR_EST,
	   A2_MUN		AS		MUNICIPIO,
	   A2_EST		AS		UF,
	   --CASE PARA SEPARAR AS COLUNAS
	   CASE WHEN D1_COD = '010001' THEN D1_QUANT END AS BOI,
	   CASE WHEN D1_COD = '010002' THEN D1_QUANT 
	        WHEN D1_COD = '010008' THEN D1_QUANT END AS VACAS,
	   CASE WHEN D1_COD = '010003' THEN D1_QUANT END AS GARROTE,
	   CASE WHEN D1_COD = '010004' THEN D1_QUANT END AS	NOVILHA,
	   CASE WHEN D1_COD = '010005' THEN D1_QUANT 
			WHEN D1_COD = '010009' THEN D1_QUANT END AS BEZERRO,
	   CASE WHEN D1_COD = '010006' THEN D1_QUANT 
	        WHEN D1_COD = '010010' THEN D1_QUANT END AS BEZERRA
  FROM SD1010 D1, SA2010 A2
 WHERE D1.D_E_L_E_T_ = '' AND A2.D_E_L_E_T_ = ''
   AND D1_FORNECE = A2.A2_COD
   AND D1_GRUPO = '01'
   AND D1_EMISSAO BETWEEN '20160901' AND '20160930'

UNION ALL


-- LISTA REGISTRO DE NOTA FISCAL DE SAÍDA CONFORME LAYOUT DA PLANILHA AUXILIAR DO DMG
SELECT 'NF'			AS		ESPECIE,
	   D2_SERIE		AS		SERIE,
	   D2_DOC		AS		NUMERO,
	   D2_EMISSAO	AS		EMISSAO,
	   ''			AS		ENTRADA,
	   D2_QUANT		AS		SAÍDA,
	   A1_NOME		AS		NOME,
	   A1_INSCR		AS		INSCRI_EST,
	   A1_MUN		AS		MUNICIPIO,
	   A1_EST		AS		UF,
	   --CASE PARA SEPARAR AS COLUNAS
	   CASE	WHEN B1_DESC LIKE 'TOURO'		THEN D2_QUANT		END	AS		TOURO,
	   CASE WHEN B1_DESC LIKE 'BOI%'		THEN D2_QUANT		END AS		BOI,
	   CASE WHEN B1_DESC LIKE 'VACA%'		THEN D2_QUANT		END AS		VACA,
	   CASE WHEN B1_DESC LIKE 'GARROTE%'	THEN D2_QUANT		END AS		GARROTE,
	   CASE WHEN B1_DESC LIKE 'NOVILHA%'	THEN D2_QUANT		END AS		NOVILHA,
	   CASE WHEN B1_DESC LIKE 'BEZERRO%'	THEN D2_QUANT		END AS		BEZERRO,
	   CASE WHEN B1_DESC LIKE 'BEZERRA%'	THEN D2_QUANT		END AS		BEZERRA
  FROM SD2010 D2, SA1010 A1, SB1010 B1
 WHERE D2.D_E_L_E_T_ = '' AND A1.D_E_L_E_T_ = ''
   AND (D2_CLIENTE = A1_COD AND D2_LOJA = A1_LOJA)
   AND D2_COD = B1_COD
   AND D2_QUANT <> '0'
   AND (D2_GRUPO = '01' OR D2_GRUPO = '05' OR D2_GRUPO = 'BOV')
   AND D2_EMISSAO BETWEEN '20170101' AND '20170113'
 
  
*/

// LISTA NFS DE ENTRADA
cQuery := " SELECT "
cQuery += " 'NF_ENTR'	AS		ORIGEM,"
cQuery += " D1_FILIAL	AS		FILIAL, "
cQuery += " 'NF'		AS		ESPECIE, "
cQuery += " D1_SERIE	AS		SERIE, "
cQuery += " D1_DOC		AS		NUMERO, "
cQuery += " D1_EMISSAO	AS		EMISSAO, "
cQuery += " D1_QUANT	AS		ENTRADA, "
cQuery += " ''			AS		SAIDA," 
cQuery += " A2_NOME		AS		NOME, "
cQuery += " A2_INSCR 	AS		INSCRI_EST, "
cQuery += " A2_MUN		AS		MUNICIPIO, "
cQuery += " A2_EST		AS		UF, "
cQuery += " CASE WHEN B1_DESC LIKE 'TOURO%' 	THEN D1_QUANT 		END AS TOURO, "
cQuery += "	CASE WHEN B1_DESC LIKE 'BOI%'		THEN D1_QUANT		END AS	BOI, "
cQuery += "	CASE WHEN B1_DESC LIKE 'VACA%'		THEN D1_QUANT		END AS	VACAS, "
cQuery += "	CASE WHEN B1_DESC LIKE 'GARROTE%'	THEN D1_QUANT		END AS GARROTE, "
cQuery += "	CASE WHEN B1_DESC LIKE 'NOVILHA%'	THEN D1_QUANT		END AS	NOVILHA, "
cQuery += "	CASE WHEN B1_DESC LIKE 'BEZERRO%'	THEN D1_QUANT 		END AS BEZERRO, "
cQuery += "	CASE WHEN B1_DESC LIKE 'BEZERRA%'	THEN D1_QUANT 		END AS BEZERRA "
cQuery += " FROM "+RetSqlName('SD1')+" D1, "+RetSqlName('SA2')+" A2, "+RetSqlName('SB1')+" B1 " 
cQuery += " WHERE D1.D_E_L_E_T_ = '' AND A2.D_E_L_E_T_ = '' "
cQuery += " AND D1_QUANT <> '0'"
cQuery += " AND D1_FILIAL BETWEEN '"+MV_PAR01+"' 	AND '"+MV_PAR02+"' "
cQuery += " AND D1_FORNECE = A2.A2_COD AND D1_LOJA = A2_LOJA "
cQuery += " AND D1_COD = B1_COD  "
cQuery += " AND (D1_GRUPO = '01' OR D1_GRUPO = '05' OR D1_GRUPO = 'BOV' )"
cQuery += " AND D1_TIPO <> 'C' "
cQuery += " AND D1_EMISSAO BETWEEN '"+DtOS(MV_PAR03)+"' 	AND '"+DtOS(MV_PAR04)+"' "

// LISTA NFS DE SAÍDA
cQyery1 := ""
cQuery1 := " SELECT "
cQuery1 += " 'NF_SAID'	AS		ORIGEM,"
cQuery1 += " D2_FILIAL	AS		FILIAL, "
cQuery1 += " 'NF'		AS		ESPECIE, "
cQuery1 += " D2_SERIE	AS		SERIE, "
cQuery1 += " D2_DOC		AS		NUMERO, "
cQuery1 += " D2_EMISSAO	AS		EMISSAO, "
cQuery1 += " ''			AS		ENTRADA, "
cQuery1 += " D2_QUANT	AS		SAIDA, "
cQuery1 += " A1_NOME	AS		NOME, "
cQuery1 += " A1_INSCR	AS		INSCRI_EST, "
cQuery1 += " A1_MUN		AS		MUNICIPIO, "
cQuery1 += " A1_EST		AS		UF, "
cQuery1 += "CASE WHEN B1_DESC LIKE 'TOURO%'		THEN D2_QUANT		END	AS		TOURO, "
cQuery1 += "CASE WHEN B1_DESC LIKE 'BOI%'		THEN D2_QUANT		END AS		BOI, "
cQuery1 += "CASE WHEN B1_DESC LIKE 'VACA%'		THEN D2_QUANT		END AS		VACAS, "
cQuery1 += "CASE WHEN B1_DESC LIKE 'GARROTE%'	THEN D2_QUANT		END AS		GARROTE, "
cQuery1 += "CASE WHEN B1_DESC LIKE 'NOVILHA%'	THEN D2_QUANT		END AS		NOVILHA, "
cQuery1 += "CASE WHEN B1_DESC LIKE 'BEZERRO%'	THEN D2_QUANT		END AS		BEZERRO, "
cQuery1 += "CASE WHEN B1_DESC LIKE 'BEZERRA%'	THEN D2_QUANT		END AS		BEZERRA "
cQuery1 += " FROM "+RetSqlName('SD2')+" D2, "+RetSqlName('SA1')+" A1, "+RetSqlName('SB1')+" B1 "
cQuery1 += " WHERE D2.D_E_L_E_T_ = '' AND A1.D_E_L_E_T_ = '' "
cQuery1 += " AND (D2_CLIENTE = A1_COD AND D2_LOJA = A1_LOJA) "
cQuery1 += " AND D2_COD = B1_COD "
cQuery1 += " AND D2_QUANT <> '0' "
cQuery1 += " AND D2_FILIAL BETWEEN '"+MV_PAR01+"' 	AND '"+MV_PAR02+"' "
cQuery1 += " AND (D2_GRUPO = '01' OR D2_GRUPO = '05' OR D2_GRUPO = 'BOV') "
cQuery1 += " AND D2_EMISSAO BETWEEN '"+DtOS(MV_PAR03)+"' 	AND '"+DtOS(MV_PAR04)+"' "
cQuery2 := " ORDER BY FILIAL, ORIGEM, EMISSAO, NUMERO, NOME"


// ESTRUTURA A QUERY DE ACORDO COM A OPÇÃO SELECIONADA 
If mv_par05 == 1 				//  Se usuário selecionar NFs de Entrada (SD1)
	cQueryResult := cQuery
	cQueryResult += cQuery2
ElseIf mv_par05 == 2   			// Se usuário seleccionar NFs de Saída (SD2)
	cQueryResult := cQuery1
	cQueryResult += cQuery2
ElseIf mv_par05 == 3			// Se usuário selecionar NF Entrada/Saída (Union SD1 e SD2)
 	cQueryResult := cQuery
	cQueryResult += " UNION ALL "
	cQueryResult += cQuery1
	cQueryResult += cQuery2
Endif

Memowrite("C:\TOTVS\VACOMR04A.txt",cQueryResult)	// Gera Arquivo de texto

If Select("TSC9") <> 0
	TSC9->(dbCloseArea())
EndIf

TCQuery cQueryResult Alias "TSC9" New

oExcel := FWMSExcel():New()
		
	
//Aba 01 - Relatorio 
oExcel:AddworkSheet(cAba1)

	//Criando a Tabela
	//FWMsExcelEx():AddColumn(< cWorkSheet >, < cTable >, < cColumn >, < nAlign >, < nFormat >, < lTotal >)-> NIL
	oExcel:AddTable(cAba1,cTable1)
	oExcel:AddColumn(cAba1,cTable1,"Filial",			1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Especie",			1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Série",				1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Número",			1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Data",				1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Entradas",			1,1,.T.) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Saídas",			1,1,.T.) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Forn/Cli",			1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Insc Est",			1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Municipio",			1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"UF",				1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Touro",				1,1,.T.) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Boi",				1,1,.T.) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Vacas",				1,1,.T.) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Garrote",			1,1,.T.) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Novilha",			1,1,.T.) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Bezerro",	  		1,1,.T.) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Bezerra",			1,1,.T.) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Total",				1,1,.T.) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"",					1,1)	
	dbSelectArea ("TSC9")
	dbGoTop()
	
	
	While !(TSC9->(Eof()))
		
			
			//nQtdTotal := 
			oExcel:AddRow(cAba1,cTable1,{	TSC9->FILIAL,;				// FILIAL
											TSC9->ESPECIE,;					// ESPECIE NF
											TSC9->SERIE,;					// SERIE NF
											TSC9->NUMERO,;					// NUMERO NF
											dToC(Stod(TSC9->EMISSAO)),;		// DATA DA EMISSAO
											TSC9->ENTRADA,;					// QUANTIDADE ENTRADA
											TSC9->SAIDA,;					// QUANTIDADE SAIDA
											TSC9->NOME,;					// RAZÃO SOCIAL FORNECEDOR / CLIENTE
											TSC9->INSCRI_EST,;				// INSCRICAO ESTADUAL
											TSC9->MUNICIPIO,;				// MUNICIPIO
											TSC9->UF,;						// ESTADO
											TSC9->TOURO,;					// QUANTIDADE TOURO
											TSC9->BOI,;						// QUANTIDADE BOI
											TSC9->VACAS,;                   // QUANTIDADE VACAS
											TSC9->GARROTE,;                 // QUANTIDADE GARROTE
											TSC9->NOVILHA,;                 // QUANTIDADE NOVILHA
											TSC9->BEZERRO,;                 // QUANTIDADE BEZERRO
											TSC9->BEZERRA,;                 // QUANTIDADE BEZERRA
											TSC9->TOURO + TSC9->BOI + TSC9->VACAS + TSC9->GARROTE + TSC9->NOVILHA + TSC9->BEZERRO + TSC9->BEZERRA,;
											""} )
									TSC9->(dbSkip())
	EndDo

	oExcel:Activate()
	oExcel:GetXMLFile(cArquivo)
			
	//Abrindo o excel e abrindo o arquivo xml
	oExcelApp := MsExcel():New() 			//Abre uma nova conexão com Excel
	oExcelApp:WorkBooks:Open(cArquivo) 		//Abre uma planilha
	oExcelApp:SetVisible(.T.) 				//Visualiza a planilha
	oExcelApp:Destroy()						//Encerra o processo do gerenciador de tarefas

RestArea(aArea)
return   
	