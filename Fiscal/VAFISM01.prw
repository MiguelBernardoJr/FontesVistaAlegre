#include "protheus.ch"
#include "topconn.ch"

//Acerto de PIS e COFINS
User Function VAFISM01()
Local cPerg  := "VAFISM01"     
Local cQry   := "" 
Local nErro  := 0 
Local aNotas := {}   
Local lOk    := .T.  
Local cTES   := ""
	
	If Aviso("Atenção!", "Este é um processo crítico de recálculo de impostos, só o utilize se tiver certeza. Deseja continuar?", {"Sim", "Não"}) = 2
		Return
	EndIf
	
	ValidPerg(cPerg)
	If !Pergunte(cPerg, .T.)
		Return
	EndIf 
	
	Processa({|| RunCont() },"Efetuando o cálculo dos impostos ...") 
Return

Static Function RunCont()  
	Local cQry   := "" 
	Local nErro  := 0 
	Local aNotas := {}   
	Local lOk    := .T.  
	
	ProcRegua(0)     
		
	//Notas de saida ou ambas
	If mv_par09 = 1 .Or. mv_par09 = 3  
	    
	    //Armazena as notas primeiramente, de acordo com filtro do usuario
		cQry := "SELECT D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, R_E_C_N_O_ AS REC FROM " + RetSqlName("SD2")                                        		
		cQry += " WHERE D2_FILIAL  >= '" + mv_par01       + "' AND D2_FILIAL  <= '" + mv_par02       + "' "	
		cQry += "   AND D2_EMISSAO >= '" + DToS(mv_par03) + "' AND D2_EMISSAO <= '" + DToS(mv_par04) + "' "			
		cQry += "   AND D2_DOC     >= '" + mv_par05       + "' AND D2_DOC     <= '" + mv_par06       + "' "
		cQry += "   AND D2_SERIE   >= '" + mv_par07       + "' AND D2_SERIE   <= '" + mv_par08       + "' "
		cQry += "   AND D_E_L_E_T_ <> '*' " 		
		
		TcQuery cQry New Alias "ITNOTAS"
		
		//Zerar Campos Ref. PIS/COFINS nas notas Selecionadas
		
		cQry := "UPDATE " + RetSqlName("SD2") + " SET "
		//COFINS
		cQry += " D2_ALQIMP5 =  0, " //Aliquota
		cQry += " D2_VALIMP5 =  0, " //Valor imposto
		cQry += " D2_BASIMP5 =  0, " //Base imposto
		cQry += " D2_TNATREC =  0, " //Tabela Nat. Receita
		cQry += " D2_CNATREC =  0, " //Cod. Tab. Nat. Receita
		//PIS
		cQry += " D2_ALQIMP6 =  0, " //Aliquota
		cQry += " D2_VALIMP6 =  0, " //Valor imposto
		cQry += " D2_BASIMP6 =  0  " //Base imposto
		cQry += " WHERE D2_FILIAL  >= '" + mv_par01       + "' AND D2_FILIAL  <= '" + mv_par02       + "' "	
		cQry += "   AND D2_EMISSAO >= '" + DToS(mv_par03) + "' AND D2_EMISSAO <= '" + DToS(mv_par04) + "' "			
		cQry += "   AND D2_DOC     >= '" + mv_par05       + "' AND D2_DOC     <= '" + mv_par06       + "' "
		cQry += "   AND D2_SERIE   >= '" + mv_par07       + "' AND D2_SERIE   <= '" + mv_par08       + "' "
		cQry += "   AND D_E_L_E_T_ <> '*' " 			

  	    //Log do script SQL
    	//MemoWrit("c:\nfs_zeraitens.txt", cQry)
		
		nErro := 0
		nErro := TcSqlExec(cQry)
		If nErro <> 0	
			Aviso("Atenção", "Ocorreu um erro ao zerar dados de PIS/COFINS nas notas de saída (itens). Verifique.", {"Ok"})
			lOk := .F.
		EndIf 
					
		// Recalcular os Valores de PIS/COFINS conforme Regras da TES
		
		dbselectarea("ITNOTAS")
		dbgotop()
		
		While ! ITNOTAS->(Eof())
		   
		   dbselectarea("SD2")
		   dbgoto(ITNOTAS->REC)
		   If !sd2->(eof())
		      
		      // Verifica se Tes Calcula PIS/COFINS
		      dbselectarea("SF4")
		      dbsetorder(1)
		      If dbseek(xFilial("SF4")+sd2->d2_tes)

		         // PIS (Imposto 6)
		         If sf4->f4_piscof == '1' .or. sf4->f4_piscof == '3' // PIS ou Ambos
 	                nAliqPIS := GetMv("MV_TXPIS")
		            If nAliqPIS > 0
		              dbselectarea("SD2")
		              RecLock("SD2",.F.)
		                sd2->d2_alqimp6 := nAliqPis
		                sd2->d2_basimp6 := sd2->d2_total * ((100-sf4->f4_basepis)/100) // Considera Redução de Base
						sd2->d2_tnatrec := SF4->f4_tnatrec // Tabela Nat. Receita
						sd2->d2_cnatrec := SF4->f4_cnatrec	// Cod. Tab. Nat. Receita	
					   If sf4->f4_cstpis $ '06' // Aliquota Zero
  		                  sd2->d2_valimp6 := 0		                
		                Else
  		                  sd2->d2_valimp6 := sd2->d2_basimp6 * ( sd2->d2_alqimp6 / 100 ) 
  		                Endif 
		              MsUnlock()  
                    Endif
		         Endif 
		        
		         // Cofins (Imposto 5)
		         If sf4->f4_piscof == '2' .or. sf4->f4_piscof == '3' // Cofins ou Ambos
 		            nAliqCof := GetMv("MV_TXCOFIN") 		            
		            If nAliqCof > 0
		              dbselectarea("SD2")
		              RecLock("SD2",.F.)
		                sd2->d2_alqimp5 := nAliqCof
		                sd2->d2_basimp5 := sd2->d2_total * ((100-sf4->f4_basecof)/100) // Considera Redução de Base
						sd2->d2_tnatrec := sf4->F4_tnatrec // Tabela Nat. Receita
						sd2->d2_cnatrec := sf4->F4_cnatrec // Cod. Tab. Nat. Receita	
      		            If sf4->f4_cstcof $ '06' // Aliquota Zero		         
		                  sd2->d2_valimp5 := 0
		                Else  
		                  sd2->d2_valimp5 := sd2->d2_basimp5 * ( sd2->d2_alqimp5 / 100 )
		                Endif  
		              MsUnlock()  
                    Endif		           
		         Endif 		         
		         
		      Endif
		      
		   Endif				
		   
		   ITNOTAS->(Dbskip())
		   
		Enddo 		
							
		//Atualização dos cabeçalhos das notas
		//COFINS
		cQry := "UPDATE " + RetSqlName("SF2") + " SET "
		//cQry += " F2_VALIMP5 = (SELECT SUM(D2_VALIMP5) FROM " + RetSqlName("SD2") + " WHERE D2_FILIAL = F2_FILIAL AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = F2_LOJA AND D_E_L_E_T_ <> '*'), "
		//cQry += " F2_BASIMP5 = (SELECT SUM(D2_BASIMP5) FROM " + RetSqlName("SD2") + " WHERE D2_FILIAL = F2_FILIAL AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = F2_LOJA AND D_E_L_E_T_ <> '*'), "
		//PIS
		//cQry += " F2_VALIMP6 = (SELECT SUM(D2_VALIMP6) FROM " + RetSqlName("SD2") + " WHERE D2_FILIAL = F2_FILIAL AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = F2_LOJA AND D_E_L_E_T_ <> '*'), "
		//cQry += " F2_BASIMP6 = (SELECT SUM(D2_BASIMP6) FROM " + RetSqlName("SD2") + " WHERE D2_FILIAL = F2_FILIAL AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND D2_CLIENTE = F2_CLIENTE AND D2_LOJA = F2_LOJA AND D_E_L_E_T_ <> '*')  "



		cQry += " F2_VALIMP5 = "
		cQry += "IsNull((SELECT SUM(D2_VALIMP5) FROM " + RetSqlName("SD2") + " "
		cQry += "                WHERE D2_FILIAL = F2_FILIAL "
		cQry += "                AND D2_DOC = F2_DOC "
		cQry += "                AND D2_SERIE = F2_SERIE "
		cQry += "                AND D2_CLIENTE = F2_CLIENTE "
		cQry += "                AND D2_LOJA = F2_LOJA "
		cQry += "                AND D_E_L_E_T_ <> '*'),0), "
		cQry += "  F2_BASIMP5 = "
		cQry += "IsNull((SELECT SUM(D2_BASIMP5) FROM " + RetSqlName("SD2") + " "
		cQry += "                WHERE D2_FILIAL = F2_FILIAL "
		cQry += "                AND D2_DOC = F2_DOC "
		cQry += "                AND D2_SERIE = F2_SERIE "
		cQry += "                AND D2_CLIENTE = F2_CLIENTE "
		cQry += "                AND D2_LOJA = F2_LOJA "
		cQry += "                AND D_E_L_E_T_ <> '*'),0), "
		cQry += " F2_VALIMP6 = "
		cQry += "IsNull((SELECT SUM(D2_VALIMP6) FROM " + RetSqlName("SD2") + " "
		cQry += "                WHERE D2_FILIAL = F2_FILIAL "
		cQry += "                AND D2_DOC = F2_DOC "
		cQry += "                AND D2_SERIE = F2_SERIE "
		cQry += "                AND D2_CLIENTE = F2_CLIENTE "
		cQry += "                AND D2_LOJA = F2_LOJA "
		cQry += "                AND D_E_L_E_T_ <> '*'),0), "
		cQry += " F2_BASIMP6 = "
		cQry += "IsNull((SELECT SUM(D2_BASIMP6) FROM " + RetSqlName("SD2") + " "
		cQry += "                WHERE D2_FILIAL = F2_FILIAL "
		cQry += "                AND D2_DOC = F2_DOC "
		cQry += "                AND D2_SERIE = F2_SERIE "
		cQry += "                AND D2_CLIENTE = F2_CLIENTE "
		cQry += "                AND D2_LOJA = F2_LOJA "
		cQry += "                AND D_E_L_E_T_ <> '*'),0) "

		cQry += " WHERE F2_FILIAL  >= '" + mv_par01       + "' AND F2_FILIAL  <= '" + mv_par02       + "' "	
		cQry += "   AND F2_EMISSAO >= '" + DToS(mv_par03) + "' AND F2_EMISSAO <= '" + DToS(mv_par04) + "' "			
		cQry += "   AND F2_DOC     >= '" + mv_par05       + "' AND F2_DOC     <= '" + mv_par06       + "' "
		cQry += "   AND F2_SERIE   >= '" + mv_par07       + "' AND F2_SERIE   <= '" + mv_par08       + "' "
		cQry += "   AND D_E_L_E_T_ <> '*' " 			

  	    //Log do script SQL
		//MemoWrit("c:\nfs_cabec.txt", cQry)
			
		nErro := 0
		nErro := TcSqlExec(cQry)
		//Alert(nErro)
		If nErro <> 0	
			Aviso("Atenção", "Erro ao Atualizar os Totalizadores da Nota de Saída.", {"Ok"})
			lOk := .F.
		EndIf 	 
				
		//Tudo ok com o processo
		If lOk		
			Aviso("Atenção", "Atualização das notas de saída concluída com sucesso. É necessário reprocessar os livros fiscais.", {"Ok"})
		EndIf
    
  	    ITNOTAS->(dbclosearea())        

	EndIf 
	
	
	//Notas de entrada ou ambas
	If mv_par09 = 2 .Or. mv_par09 = 3     	
	
	    //Armazena as notas primeiramente, de acordo com filtro do usuario
		cQry := "SELECT D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, R_E_C_N_O_ AS REC FROM " + RetSqlName("SD1")                                        		
		cQry += " WHERE D1_FILIAL  >= '" + mv_par01       + "' AND D1_FILIAL  <= '" + mv_par02       + "' "	
		cQry += "   AND D1_DTDIGIT >= '" + DToS(mv_par03) + "' AND D1_DTDIGIT <= '" + DToS(mv_par04) + "' "			
		cQry += "   AND D1_DOC     >= '" + mv_par05       + "' AND D1_DOC     <= '" + mv_par06       + "' "
		cQry += "   AND D1_SERIE   >= '" + mv_par07       + "' AND D1_SERIE   <= '" + mv_par08       + "' "
		cQry += "   AND D_E_L_E_T_ <> '*' " 		
		
		TcQuery cQry New Alias "ITNOTAS"
		
		//Zerar Campos Ref. PIS/COFINS nas notas Selecionadas
		
		cQry := "UPDATE " + RetSqlName("SD1") + " SET "
		//COFINS
		cQry += " D1_ALQIMP5 =  0, " //Aliquota
		cQry += " D1_VALIMP5 =  0, " //Valor imposto
		cQry += " D1_BASIMP5 =  0, " //Base imposto
		cQry += " D1_TNATREC =  0, " //Tab Nat. Receita
		cQry += " D1_CNATREC =  0, " //Cod. Nat. Receita
		//PIS
		cQry += " D1_ALQIMP6 =  0, " //Aliquota
		cQry += " D1_VALIMP6 =  0, " //Valor imposto
		cQry += " D1_BASIMP6 =  0  " //Base imposto

		cQry += " WHERE D1_FILIAL  >= '" + mv_par01       + "' AND D1_FILIAL  <= '" + mv_par02       + "' "	
		cQry += "   AND D1_DTDIGIT >= '" + DToS(mv_par03) + "' AND D1_DTDIGIT <= '" + DToS(mv_par04) + "' "			
		cQry += "   AND D1_DOC     >= '" + mv_par05       + "' AND D1_DOC     <= '" + mv_par06       + "' "
		cQry += "   AND D1_SERIE   >= '" + mv_par07       + "' AND D1_SERIE   <= '" + mv_par08       + "' "
		cQry += "   AND D_E_L_E_T_ <> '*' " 			

  	    //Log do script SQL
        //MemoWrit("c:\nfe_zeraitens.txt", cQry)
		
		nErro := 0
		nErro := TcSqlExec(cQry)
		If nErro <> 0	
			Aviso("Atenção", "Ocorreu um erro ao zerar dados de PIS/COFINS nas notas de entrada (itens). Verifique.", {"Ok"})
			lOk := .F.
		EndIf 
					
		// Recalcular os Valores de PIS/COFINS conforme Regras da TES
		
		dbselectarea("ITNOTAS")
		dbgotop()
		
		While ! ITNOTAS->(Eof())
		   
		   dbselectarea("SD1")
		   dbgoto(ITNOTAS->REC)
		   If !sd1->(eof())
		      
		      // Verifica se Tes Calcula PIS/COFINS
		      dbselectarea("SF4")
		      dbsetorder(1)
		      If dbseek(xFilial("SF4")+sd1->d1_tes)

		         // PIS (Imposto 6)
		         If sf4->f4_piscof == '1' .or. sf4->f4_piscof == '3' // PIS ou Ambos
		            nAliqPIS := GetMv("MV_TXPIS")
		            If nAliqPIS > 0
		              dbselectarea("SD1")
		              RecLock("SD1",.F.)
		                sd1->d1_alqimp6 := nAliqPis
		                sd1->d1_basimp6 := sd1->d1_total * ((100-sf4->f4_basepis)/100) // Considera Redução de Base
		                sd1->d1_valimp6 := sd1->d1_basimp6 * ( sd1->d1_alqimp6 / 100 )
						sd1->d1_tnatrec := sf4->F4_tnatrec // Tabela Nat. Receita
						sd1->d1_cnatrec := sf4->F4_cnatrec // Cod. Tab. Nat. Receita	
		              MsUnlock()  
                    Endif
		         Endif 
		                          
		         // Cofins (Imposto 5)
		         If sf4->f4_piscof == '2' .or. sf4->f4_piscof == '3' // Cofins ou Ambos
		            nAliqCof := GetMv("MV_TXCOFIN")
		            If nAliqCof > 0
		              dbselectarea("SD1")
		              RecLock("SD1",.F.)
		                sd1->d1_alqimp5 := nAliqCof
		                sd1->d1_basimp5 := sd1->d1_total * ((100-sf4->f4_basecof)/100) // Considera Redução de Base
		                sd1->d1_valimp5 := sd1->d1_basimp5 * ( sd1->d1_alqimp5 / 100 )  
		                sd1->d1_tnatrec := sf4->F4_tnatrec // Tabela Nat. Receita
						sd1->d1_cnatrec := sf4->F4_cnatrec // Cod. Tab. Nat. Receita	

		              MsUnlock()  
                    Endif		           
		         Endif 		         
		         
		      Endif
		      
		   Endif				
		   
		   ITNOTAS->(Dbskip())
		   
		Enddo 		
							
		//Atualização dos cabeçalhos das notas
		//COFINS
		cQry := "UPDATE " + RetSqlName("SF1") + " SET "
		cQry += " F1_VALIMP5 = (SELECT SUM(D1_VALIMP5) FROM " + RetSqlName("SD1") + " WHERE D1_FILIAL = F1_FILIAL AND D1_DOC = F1_DOC AND D1_SERIE = F1_SERIE AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA AND D_E_L_E_T_ <> '*'), "
		cQry += " F1_BASIMP5 = (SELECT SUM(D1_BASIMP5) FROM " + RetSqlName("SD1") + " WHERE D1_FILIAL = F1_FILIAL AND D1_DOC = F1_DOC AND D1_SERIE = F1_SERIE AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA AND D_E_L_E_T_ <> '*'), "
		//PIS
		cQry += " F1_VALIMP6 = (SELECT SUM(D1_VALIMP6) FROM " + RetSqlName("SD1") + " WHERE D1_FILIAL = F1_FILIAL AND D1_DOC = F1_DOC AND D1_SERIE = F1_SERIE AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA AND D_E_L_E_T_ <> '*'), "
		cQry += " F1_BASIMP6 = (SELECT SUM(D1_BASIMP6) FROM " + RetSqlName("SD1") + " WHERE D1_FILIAL = F1_FILIAL AND D1_DOC = F1_DOC AND D1_SERIE = F1_SERIE AND D1_FORNECE = F1_FORNECE AND D1_LOJA = F1_LOJA AND D_E_L_E_T_ <> '*')  "
		cQry += " WHERE F1_FILIAL  >= '" + mv_par01       + "' AND F1_FILIAL  <= '" + mv_par02       + "' "	
		cQry += "   AND F1_DTDIGIT >= '" + DToS(mv_par03) + "' AND F1_DTDIGIT <= '" + DToS(mv_par04) + "' "			
		cQry += "   AND F1_DOC     >= '" + mv_par05       + "' AND F1_DOC     <= '" + mv_par06       + "' "
		cQry += "   AND F1_SERIE   >= '" + mv_par07       + "' AND F1_SERIE   <= '" + mv_par08       + "' "
		cQry += "   AND D_E_L_E_T_ <> '*' " 			

  	    //Log do script SQL
		//MemoWrit("c:\nfe_cabec.txt", cQry)
			
		nErro := 0
		nErro := TcSqlExec(cQry)
		If nErro <> 0	
			Aviso("Atenção", "Erro ao Atualizar os Totalizadores da Nota de Entrada.", {"Ok"})
			lOk := .F.
		EndIf 	 
		
		//Tudo ok com o processo
		If lOk		
			Aviso("Atenção", "Atualização das notas de entrada concluída com sucesso. É necessário reprocessar os livros fiscais.", {"Ok"})
		EndIf				
                            
	EndIf                   
	
If select("ITNOTAS") > 0
	ITNOTAS->(dbclosearea())	
Endif
		
Return                     

Static Function ValidPerg(cPerg)        

	_sAlias	:=	Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg 	:=	PADR(cPerg,10)
	aRegs	:=	{}
	//                                                                                                      -- 02 03 04 05 -- 07 08 09 10 -- 12 13 14 15 -- 17 18 19 20 -- 22 23 24 F3
	AADD(aRegs,{cPerg,"01","Filial De        ?",Space(20),Space(20),"mv_ch1","C",02,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","SM0",""})
	AADD(aRegs,{cPerg,"02","Filial Até       ?",Space(20),Space(20),"mv_ch2","C",02,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","SM0",""})
	AADD(aRegs,{cPerg,"03","Data De          ?",Space(20),Space(20),"mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"04","Data Até         ?",Space(20),Space(20),"mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"05","Nota Fiscal De   ?",Space(20),Space(20),"mv_ch5","C",09,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"06","Nota Fiscal Até  ?",Space(20),Space(20),"mv_ch6","C",09,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"07","Série De         ?",Space(20),Space(20),"mv_ch7","C",03,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"08","Série Até        ?",Space(20),Space(20),"mv_ch8","C",03,0,0,"G","","mv_par08","","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"09","Recalcular Para  ?",Space(20),Space(20),"mv_ch9","N",01,0,0,"C","","mv_par09","NF Saída","","","","","NF Entrada","","","","","Ambas","","","","","","","","","","","","","","","","","","","",""})
	

	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				FieldPut(j,aRegs[i,j])
			Next
			MsUnlock()
			dbCommit()
		Endif
	Next
	
	dbSelectArea(_sAlias)
	
Return
