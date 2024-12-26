//**********************************************
// Listagem Trato Animal
//**********************************************
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"  
#INCLUDE "RWMAKE.CH"    
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

/*/{Protheus.doc} VAESTR06
//TODO Descrição auto-gerada.
@author atoshio
@since 01/08/2017
@version undefined

@type function
/*/
user function VAESTR06()


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

Private cPerg

	nOrdem   :=0
	tamanho  :="P"
	limite   :=80
	titulo   :=PADC("VAESTR06",74)
	cDesc1   :=PADC("Listagem - Produção (Trato Animal)",74)
	cDesc2   :=""
	cDesc3   :=""
	aReturn  := { "Especial", 1,"Administracao", 1, 2, 1,"",1 }
	nomeprog :="VAESTR06"
	cPerg    :="VAESTR06"
	nLastKey := 0
	wnrel    := "VAESTR06"
	cQuery	 :=""

	ValidPerg(cPerg)
	
//	While Pergunte(cPerg, .T.)
//		MsgRun("Gerando Relatorio, Aguarde...","",{|| CursorWait(),ImprRel(@cPerg),CursorArrow()})
//	Enddo

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
	cPerg := PADR(cPerg,5)
	aRegs:={}                                                  

	AADD(aRegs,{cPerg,"01","Filial De             ?",Space(20),Space(20),"mv_ch1","C",02,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"02","Filial Ate            ?",Space(20),Space(20),"mv_ch2","C",02,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"03","Emissao de         	  ?",Space(20),Space(20),"mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"04","Emissao até        	  ?",Space(20),Space(20),"mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"05","Lote                  ?",Space(20),Space(20),"mv_chc","C",50,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	

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
Local cAba1 	:= "Trato Animal"
Local cTable1	:= "Listagem do Trato animal" 
// Tratamento para Excel
Private oExcel
Private oExcelApp
Private cArquivo  := GetTempPath()+'VAESTR06_'+StrTran(dToC(dDataBase), '/', '-')+'.xml'

/*
		SELECT D31.D3_FILIAL				AS		FILIAL,
			   D3.D3_COD					AS		CODIGO, 
			   B11.B1_DESC					AS		DESCRICAO,		
			   B11.B1_XLOTE					AS		LOTE,
			   D3.D3_TM						AS		TM,
			   F5.F5_TEXTO					AS		DESC_TM,
			   D31.D3_COD					AS		COD_INSUMO,
			   B1.B1_DESC					AS		DESC_INSUMO,
			   SUBSTRING(D31.D3_EMISSAO,7,2) + '/' + SUBSTRING(D31.D3_EMISSAO,5,2) + '/' + SUBSTRING(D31.D3_EMISSAO,1,4) AS DATA_EMISS, 
			   D31.D3_QUANT					AS		QT_INSUMO,
			   CONVERT(NUMERIC(8,2),(D31.D3_CUSTO1/D31.D3_QUANT)) AS CUSTO_UNIT,
			   CONVERT(NUMERIC(8,2),D31.D3_CUSTO1)	AS		CUSTO
		  FROM SD3010 D3 
	INNER JOIN SD3010 D31 ON
			   D31.D3_OP				=				D3.D3_OP
		   AND D31.D_E_L_E_T_			=				' ' 
		   AND D31.D3_GRUPO				=				'03'
	INNER JOIN SB1010 B11 ON
		       B11.B1_COD				=				D3.D3_COD
		   AND B11.D_E_L_E_T_			=				' ' 
	INNER JOIN SF5010 F5 ON
			   F5_CODIGO = D3.D3_TM
		   AND F5.D_E_L_E_T_			=				' '
	INNER JOIN SB1010 B1 ON
			   D31.D3_COD				=				B1.B1_COD
	     WHERE D3.D3_FILIAL				BETWEEN			'01'		AND			'15'
		   AND D3.D3_COD				IN				('84-6','BOV000000000392')--('108-12','95-6')
		   AND D3.D3_EMISSAO			BETWEEN			'20170101' AND '20170802'
	       AND D3.D3_CF					=				'PR0' 
	       AND D3.D_E_L_E_T_			=				' ' 
	  ORDER BY D31.D3_FILIAL, 
			   D3.D3_COD, 
			   D31.D3_EMISSAO
*/

cQuery += "    " + CRLF
cQuery += "  WITH LOTE AS (  " + CRLF
cQuery += "    " + CRLF
cQuery += "   		SELECT 'LOTE'						                         AS		TIPO,  " + CRLF
cQuery += "  			   D31.D3_FILIAL				                         AS		FILIAL,    " + CRLF
cQuery += "   			   D3.D3_COD					                         AS		CODIGO,     " + CRLF
cQuery += "   			   B11.B1_DESC					                         AS		DESCRICAO,		    " + CRLF
cQuery += "   			   D3.D3_LOTECTL				                         AS		LOTE,  " + CRLF
cQuery += "  			   --B11.B1_XLOTE				                         AS		LOTE,    " + CRLF
cQuery += "   			   D3.D3_QUANT					                         AS		QT_ANIMAIS,    " + CRLF
cQuery += "   			   D3.D3_TM						                         AS		TM,    " + CRLF
cQuery += "   			   F5.F5_TEXTO					                         AS		DESC_TM,    " + CRLF
cQuery += "   			   D31.D3_COD					                         AS		COD_INSUMO,    " + CRLF
cQuery += "   			   B1.B1_DESC					                         AS		DESC_INSUMO,    " + CRLF
cQuery += "   			   D31.D3_EMISSAO				                         AS		DATA_EMISS,     " + CRLF
cQuery += "   			   D31.D3_QUANT					                         AS		QT_INSUMO,    " + CRLF
cQuery += "   			   (D31.D3_CUSTO1/D31.D3_QUANT)                          AS 	CUSTO_UNIT,    " + CRLF
cQuery += "   			   D31.D3_CUSTO1				                         AS		CUSTO,    " + CRLF
cQuery += "                --SUM(D3C.D3_QUANT)					                 AS		QT_PROD, " + CRLF
cQuery += "                (SUM(D3C.D3_CUSTO1)/SUM(D3C.D3_QUANT))                AS     MEDIO_PROD, " + CRLF
cQuery += "                ((SUM(D3C.D3_CUSTO1)/SUM(D3C.D3_QUANT))*D31.D3_QUANT) AS     TOTAL_P_PR " + CRLF
cQuery += "                --SUM(D3C.D3_CUSTO1)			AS		CUSTO_PROD  " + CRLF
cQuery += "   		  FROM " + RetSqlName('SD3') + " D3     " + CRLF
cQuery += "   	INNER JOIN " + RetSqlName('SD3') + " D31 ON    " + CRLF
cQuery += "   			   D31.D3_OP				=				D3.D3_OP    " + CRLF
cQuery += "   		   AND D31.D_E_L_E_T_			=				' '     " + CRLF
cQuery += "   		   AND D31.D3_GRUPO				=				'03'    " + CRLF
cQuery += "    	INNER JOIN " + RetSqlName('SD3') + " D3C ON " + CRLF
cQuery += "    		       D3C.D3_FILIAL			=				D31.D3_FILIAL " + CRLF
cQuery += "    		   AND D3C.D3_COD				=				D31.D3_COD " + CRLF
cQuery += "    		   AND D3C.D3_TM				=				'001' " + CRLF
cQuery += "    		   AND D3C.D3_EMISSAO			=				D3.D3_EMISSAO " + CRLF
cQuery += "   	INNER JOIN " + RetSqlName('SB1') + " B11 ON    " + CRLF
cQuery += "   		       B11.B1_COD				=				D3.D3_COD    " + CRLF
cQuery += "   		   AND B11.D_E_L_E_T_			=				' '     " + CRLF
cQuery += "   	INNER JOIN " + RetSqlName('SF5') + " F5 ON    " + CRLF
cQuery += "   			   F5_CODIGO = D3.D3_TM    " + CRLF
cQuery += "   		   AND F5.D_E_L_E_T_			=				' '    " + CRLF
cQuery += "   	INNER JOIN " + RetSqlName('SB1') + " B1 ON    " + CRLF
cQuery += "   			   D31.D3_COD				=				B1.B1_COD    " + CRLF
cQuery += "   	     WHERE D3.D3_FILIAL				BETWEEN			'01'		AND			'15'    " + CRLF
cQuery += "   AND D3.D3_LOTECTL						=				'"+MV_PAR05+"'  " + CRLF
cQuery += "   		   AND D3.D3_EMISSAO			BETWEEN			'"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"'    " + CRLF
cQuery += "   	       AND D3.D3_CF					=				'PR0'     " + CRLF
cQuery += "  		   AND D3.D3_ESTORNO			<>				'S'  " + CRLF
cQuery += "   	       AND D3.D_E_L_E_T_			=				' '     " + CRLF
cQuery += "  		   AND D3.D3_LOTECTL			<>				' '   " + CRLF
cQuery += "       GROUP BY D31.D3_FILIAL				, " + CRLF
cQuery += "		   		   D3.D3_COD					,  " + CRLF
cQuery += "		   		   B11.B1_DESC					,  " + CRLF
cQuery += "		   		   D3.D3_LOTECTL				,  " + CRLF
cQuery += "		   		   --B11.B1_XLOTE			    ,  " + CRLF
cQuery += "		   		   D3.D3_QUANT					,  " + CRLF
cQuery += "		   		   D3.D3_TM					    ,  " + CRLF	
cQuery += "		   		   F5.F5_TEXTO					,  " + CRLF
cQuery += "		   		   D31.D3_COD					,  " + CRLF
cQuery += "		   		   B1.B1_DESC					,  " + CRLF
cQuery += "		   		   D31.D3_EMISSAO				,  " + CRLF
cQuery += "		   		   D31.D3_QUANT				,	   " + CRLF
cQuery += "		   		   D31.D3_CUSTO1	               " + CRLF
cQuery += "    " + CRLF
cQuery += "  ),  " + CRLF
cQuery += "    " + CRLF
cQuery += "  ESTOQUE AS(  " + CRLF
cQuery += "   		SELECT 'ANTIGO'						                         AS		TIPO,  " + CRLF
cQuery += "  			   D31.D3_FILIAL				                         AS		FILIAL,    " + CRLF
cQuery += "   			   D3.D3_COD					                         AS		CODIGO,     " + CRLF
cQuery += "   			   B11.B1_DESC					                         AS		DESCRICAO,		    " + CRLF
cQuery += "   			   --D3.D3_LOTECTL				                         AS		LOTE1,  " + CRLF
cQuery += "  			   B11.B1_XLOTE					                         AS		LOTE,    " + CRLF
cQuery += "   			   D3.D3_QUANT					                         AS		QT_ANIMAIS,    " + CRLF
cQuery += "   			   D3.D3_TM						                         AS		TM,    " + CRLF
cQuery += "   			   F5.F5_TEXTO					                         AS		DESC_TM,    " + CRLF
cQuery += "   			   D31.D3_COD					                         AS		COD_INSUMO,    " + CRLF
cQuery += "   			   B1.B1_DESC					                         AS		DESC_INSUMO,    " + CRLF
cQuery += "   			   D31.D3_EMISSAO				                         AS		DATA_EMISS,     " + CRLF
cQuery += "   			   D31.D3_QUANT					                         AS		QT_INSUMO,    " + CRLF
cQuery += "   			   (D31.D3_CUSTO1/D31.D3_QUANT)                          AS 	CUSTO_UNIT,    " + CRLF
cQuery += "   			   D31.D3_CUSTO1				                         AS		CUSTO,    " + CRLF
cQuery += "   			   --SUM(D3C.D3_QUANT)					                 AS		QT_PROD,    " + CRLF
cQuery += "   			   (SUM(D3C.D3_CUSTO1)/SUM(D3C.D3_QUANT))                AS     MEDIO_PROD,    " + CRLF
cQuery += "   			   ((SUM(D3C.D3_CUSTO1)/SUM(D3C.D3_QUANT))*D31.D3_QUANT) AS     TOTAL_P_PR    " + CRLF
cQuery += "   			   --SUM(D3C.D3_CUSTO1)			AS		CUSTO_PROD    " + CRLF
cQuery += "   		  FROM " + RetSqlName('SD3') + " D3     " + CRLF
cQuery += "   	INNER JOIN " + RetSqlName('SD3') + " D31 ON    " + CRLF
cQuery += "   			   D31.D3_OP				=				D3.D3_OP    " + CRLF
cQuery += "   		   AND D31.D_E_L_E_T_			=				' '     " + CRLF
cQuery += "   		   AND D31.D3_GRUPO				=				'03'    " + CRLF
cQuery += "     INNER JOIN " + RetSqlName('SD3') + " D3C ON     " + CRLF
cQuery += "   		       D3C.D3_FILIAL			=				D31.D3_FILIAL     " + CRLF
cQuery += "   		   AND D3C.D3_COD				=				D31.D3_COD     " + CRLF
cQuery += "    		   AND D3C.D3_EMISSAO			=				D3.D3_EMISSAO " + CRLF
cQuery += "   		   AND D3C.D3_TM				=				'001'      " + CRLF
cQuery += "   	INNER JOIN " + RetSqlName('SB1') + " B11 ON    " + CRLF
cQuery += "   		       B11.B1_COD				=				D3.D3_COD    " + CRLF
cQuery += "   		   AND B11.D_E_L_E_T_			=				' '     " + CRLF
cQuery += "   	INNER JOIN " + RetSqlName('SF5') + " F5 ON    " + CRLF
cQuery += "   			   F5_CODIGO 				= 				D3.D3_TM    " + CRLF
cQuery += "   		   AND F5.D_E_L_E_T_			=				' '    " + CRLF
cQuery += "   	INNER JOIN " + RetSqlName('SB1') + " B1 ON    " + CRLF
cQuery += "   			   D31.D3_COD				=				B1.B1_COD    " + CRLF
cQuery += "  		   --AND B1.B1_XLOTE				LIKE				'26-15%'  " + CRLF
cQuery += "   	     WHERE D3.D3_FILIAL				BETWEEN			'01'		AND			'15'    " + CRLF
cQuery += "  		   --AND D3.D3_COD				IN				('BOV000000000906','BOV000000000907','BOV000000000920')   " + CRLF
cQuery += "  		   --AND D3.D3_LOTECTL			=				'26-15'  " + CRLF
cQuery += "             AND B11.B1_XLOTE				=			'"+MV_PAR05+"'  " + CRLF
cQuery += "  		   AND D3.D3_EMISSAO			BETWEEN			'"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' " + CRLF
cQuery += "   	       AND D3.D3_CF					=				'PR0'     " + CRLF
cQuery += "  		   AND D3.D3_ESTORNO			<>				'S'  " + CRLF
cQuery += "  		   AND D3.D3_TM					=				'002'  " + CRLF
cQuery += "   	       AND D3.D_E_L_E_T_			=				' '   " + CRLF
cQuery += "  		   AND D3.D3_LOTECTL			=				' '     " + CRLF
cQuery += " 	  GROUP BY D31.D3_FILIAL				,	        " + CRLF
cQuery += " 	           D3.D3_COD					,	        " + CRLF
cQuery += " 	           B11.B1_DESC					,	        " + CRLF
cQuery += " 	           --D3.D3_LOTECTL				,	        " + CRLF
cQuery += " 	           B11.B1_XLOTE					,	        " + CRLF
cQuery += " 	           D3.D3_QUANT					,	        " + CRLF
cQuery += " 	           D3.D3_TM						,		    " + CRLF
cQuery += " 	           F5.F5_TEXTO					,	        " + CRLF
cQuery += " 	           D31.D3_COD					,	        " + CRLF
cQuery += " 	           B1.B1_DESC					,	        " + CRLF
cQuery += " 	           D31.D3_EMISSAO				,	        " + CRLF
cQuery += " 	           D31.D3_QUANT					,		    " + CRLF
cQuery += " 	           D31.D3_CUSTO1					        " + CRLF
cQuery += "  )  " + CRLF
cQuery += "  SELECT * FROM LOTE  " + CRLF
cQuery += "  UNION   " + CRLF
cQuery += "  SELECT * FROM ESTOQUE   " + CRLF
cQuery += "  ORDER BY 11,3  " + CRLF

/*cQuery += " 		SELECT D31.D3_FILIAL				AS		FILIAL,  " + CRLF
cQuery += " 			   D3.D3_COD					AS		CODIGO,   " + CRLF
cQuery += " 			   B11.B1_DESC					AS		DESCRICAO,		  " + CRLF
cQuery += " 			   B11.B1_XLOTE					AS		LOTE,  " + CRLF
cQuery += " 			   D3.D3_QUANT					AS		QT_ANIMAIS,  " + CRLF 
cQuery += " 			   D3.D3_TM						AS		TM,  " + CRLF
cQuery += " 			   F5.F5_TEXTO					AS		DESC_TM,  " + CRLF
cQuery += " 			   D31.D3_COD					AS		COD_INSUMO,  " + CRLF
cQuery += " 			   B1.B1_DESC					AS		DESC_INSUMO,  " + CRLF
cQuery += " 			   D31.D3_EMISSAO				AS		DATA_EMISS,   " + CRLF
cQuery += " 			   D31.D3_QUANT					AS		QT_INSUMO,  " + CRLF
cQuery += " 			   (D31.D3_CUSTO1/D31.D3_QUANT) AS 		CUSTO_UNIT,  " + CRLF
cQuery += " 			   D31.D3_CUSTO1				AS		CUSTO  " + CRLF
cQuery += " 		  FROM "+RetSqlName("SD3")+" D3   " + CRLF
cQuery += " 	INNER JOIN "+RetSqlName("SD3")+" D31 ON  " + CRLF
cQuery += " 			   D31.D3_OP				=				D3.D3_OP  " + CRLF
cQuery += " 		   AND D31.D_E_L_E_T_			=				' '   " + CRLF
cQuery += " 		   AND D31.D3_GRUPO				=				'03'  " + CRLF
cQuery += " 	INNER JOIN "+RetSqlName("SB1")+" B11 ON  " + CRLF
cQuery += " 		       B11.B1_COD				=				D3.D3_COD  " + CRLF
cQuery += " 		   AND B11.D_E_L_E_T_			=				' '   " + CRLF
cQuery += " 	INNER JOIN "+RetSqlName("SF5")+" F5 ON  " + CRLF
cQuery += " 			   F5_CODIGO = D3.D3_TM  " + CRLF
cQuery += " 		   AND F5.D_E_L_E_T_			=				' '  " + CRLF
cQuery += " 	INNER JOIN "+RetSqlName("SB1")+" B1 ON  " + CRLF
cQuery += " 			   D31.D3_COD				=				B1.B1_COD  " + CRLF
cQuery += " 	     WHERE D3.D3_FILIAL				BETWEEN			'"+MV_PAR01+"'		AND			'"+MV_PAR02+"'  " + CRLF
//cQuery += " 		   AND D3.D3_COD				IN				('"+MV_PAR05+"')  " + CRLF
cProdIn := ""
If !Empty(MV_PAR05)
	aProdIn := StrTokArr(AllTrim(MV_PAR05),";")	
	For nCont := 1 To Len(aProdIn)
		cProdIn += If(Empty(cProdIn),"'",",'") + aProdIn[nCont] + "'"
	Next		
	cQuery += 	" AND D3.D3_COD				IN				("+cProdIn+") "       + CRLF
EndIf

cQuery += " 		   AND D3.D3_EMISSAO			BETWEEN			'"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"'  " + CRLF
cQuery += " 	       AND D3.D3_CF					=				'PR0'   " + CRLF
cQuery += " 	       AND D3.D_E_L_E_T_			=				' '   " + CRLF
cQuery += " 	  ORDER BY D31.D3_FILIAL,   " + CRLF
cQuery += " 			   D3.D3_COD,   " + CRLF
cQuery += " 			   D31.D3_EMISSAO  " + CRLF
*/


If Select("TSD3") <> 0	TSD3->(dbCloseArea())EndifTCQuery cQuery Alias "TSD3" Newmemowrite("C:\TOTVS_RELATORIOS\VAESTR06.SQL", cQuery)oExcel := FWMSExcel():New()

//Aba 01 - Relatorio oExcel:AddworkSheet(cAba1)	//Criando a Tabela	//FWMsExcelEx():AddColumn(< cWorkSheet >, < cTable >, < cColumn >, < nAlign >, < nFormat >, < lTotal >)-> NIL	oExcel:AddTable(cAba1,cTable1)	oExcel:AddColumn(cAba1,cTable1,"Tipo",   				1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Filial",				1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Cod. Produto",			1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Descricao",				1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"N. Lote",				1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Qtd Animais",			3,2,.T.) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"TM",					1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Descricao TM",			1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Cod. Insumo",			1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Descr. Insumo",			1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Data Emissao",			1,1) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Qtde Insumo",			3,2,.T.) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Custo Médio",			3,3,.T.) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Custo Total",			3,3,.T.) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Custo Méd Procucao",	3,3,.T.) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Custo Total Procucao",	3,3,.T.) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"Diferenca",				3,3,.T.) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	oExcel:AddColumn(cAba1,cTable1,"",						1,1,) //1 = Modo Texto; 2 = Valor sem R$; 3 = Valor com R$
	
	//FWMsExcelEx():AddColumn(< cWorkSheet >, < cTable >, < cColumn >, < nAlign >, < nFormat >, < lTotal >)-> NIL

	dbSelectArea("TSD3")
	dbGotop()
	cPedido := "ZYX9999"
	While !(TSD3->(Eof()))
	   		// alimentar dados na planilha	
	
	oExcel:AddRow(cAba1,cTable1,{	TSD3->TIPO,;
									U_BuscaSM0(TSD3->FILIAL),;
									TSD3->CODIGO,;
									TSD3->DESCRICAO,;
									TSD3->LOTE,;
									TSD3->QT_ANIMAIS,;
									TSD3->TM,;
									TSD3->DESC_TM,;
									TSD3->COD_INSUMO,;
									TSD3->DESC_INSUMO,;
									dToC(Stod(TSD3->DATA_EMISS)),;
									TSD3->QT_INSUMO,;
									TSD3->CUSTO_UNIT,;
									TSD3->CUSTO,;
									TSD3->MEDIO_PROD,;
									TSD3->TOTAL_P_PR,;
									TSD3->CUSTO-TSD3->TOTAL_P_PR, ;
									"" } )
		TSD3->(dbSkip())
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
	
