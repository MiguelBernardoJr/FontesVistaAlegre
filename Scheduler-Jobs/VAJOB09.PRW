#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH" 
#INCLUDE "RWMAKE.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

/*--------------------------------------------------------------------------------,
 | Principal: 					U_VAJOB09()                                       |
 | Func:  fQuadro1()                                                              |
 | Autor: Arthur Toshio														      |
 | Data:  25.05.2018                                                              |
 | Desc:  Job que faz envio de email com a relação de lotes faturados sem         | 
 |        informação de peso de saída                                             |
 | Regra: 1- Envio todos dias as 12:00 horas;                                     |
 |        2- Envio de 3 dias retroativos;                                         |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function VAJOB09()              // U_VAJOB09()

If Type("oMainWnd") == "U"
	U_RunFunc("U_JOB09VA()",'01','01',3) // Gravar pedido de venda customizado.
Else
	U_JOB09VA()
EndIf

Return nil


/* MJ : 24.10.2018 */
User Function JOB09VA() // U_JOB09VA()

Local xHTM 			:= ""  
Local cTelEmp		:= ""
Local aTelEmp		:= ""
Local lImpCab1		:= .T.
Local xaDados		:= {}
Local _cQry 		:= ""
Local _cQry 		:= ""
Local _cQry 		:= ""
Local lTemDados		:= .F.

Local cJobChv		:= 'JOB09' 	// codigo da chave na tabela da sx5, pra incluir emails para envio do job
Local cJobSX5		:= 'Z2'		// tabela da SX5 onde serao selecionados os emails para envio
//Local _cAliasP    := GetNextAlias()
// Local _cAliasE    := GetNextAlias()
Local cPath 	 	:= "C:\totvs_relatorios\"
Local cArquivo   	:= cPath + "VAJOB09_" + ; // __cUserID+"_"+;
						DtoS(dDataBase)+; 
						"_"+; 
						StrTran(SubS(Time(),1,5),":","")+;
						".xml"
						
    ConOut("[VAJOB09] " + DTOC(DATE()) + ' ' + TIME())
	
	ConOut('SQL Principal retornou resultado: ' + Time())
	aTelEmp:= FisGetTel(SM0->M0_TEL)
	cTelEmp := "" //IIF(aTelDest[1] > 0,ConvType(aTelDest[1],3),"") // Código do Pais
	cTelEmp += "("+ IIF(aTelEmp[2] > 0,ConvType(aTelEmp[2],3),"") + ") " // Código da Área
	cTelEmp += IIF(aTelEmp[3] > 0,ConvType(aTelEmp[3],9),"") // Código do Telefone
	//cFoneEmp:= "Telefone: " + cFoneEmp 
	
	// Processar SQL
	_cQry := "  WITH CONTRATO AS (  " +CRLF
	_cQry += "  SELECT ZBC_FILIAL,ZCC_CODIGO, ZBC_PEDIDO, ZCC_PAGFUT, ZCC_NOMFOR, ZCC_NOMCOR, ZBC_PRDDES, ZBC_PRODUT, SUM(ZBC_QUANT) QUANTIDADE , " +CRLF 
	_cQry += " ZBC_DTENTR,  ZCC_DTVCTO, ZBC_PESO, ZBC_VLFRPG, ZBC_ICFRVL, ZBC_VLRCOM,  ZBC_CODFOR, ZBC_LOJFOR  " +CRLF
	_cQry += "  FROM ZCC010 ZCC  " +CRLF
	_cQry += "  JOIN  ZBC010 ZBC ON   " +CRLF
	_cQry += "        ZCC_FILIAL = ZBC_FILIAL AND   " +CRLF
	_cQry += "        ZCC_CODIGO = ZBC_CODIGO AND  " +CRLF
	_cQry += "  	  ZBC.D_E_L_E_T_ = ' '  " +CRLF
	_cQry += "  JOIN  ZIC010 ZIC ON  " +CRLF
	_cQry += "  	  ZIC_FILIAL = ZCC_FILIAL AND  " +CRLF
	_cQry += "  	  ZIC_CODIGO = ZCC_CODIGO AND  " +CRLF
	_cQry += "  	  ZIC_VERSAO = ZCC_VERSAO AND   " +CRLF
	_cQry += "  	  ZIC.D_E_L_E_T_ = ' '  " +CRLF
	_cQry += "  WHERE ZCC_PAGFUT = 'N' AND   " +CRLF
	_cQry += "  	  ZIC_ITEM = ZBC_ITEZIC AND  " +CRLF
	_cQry += "  	  ZCC_DTVCTO = ' ' AND  " +CRLF
	_cQry += "  	  ZCC.D_E_L_E_T_ = ' ' AND  " +CRLF
	_cQry += "  	  ZBC_PEDIDO <> ' '  AND   " +CRLF
	_cQry += "  	  (ZBC.ZBC_TEMFRE <> 'N' AND ZBC.ZBC_VLFRPG  = 0) AND  " +CRLF
	_cQry += "  	  (ZBC.ZBC_TEMICF <> 'N' AND ZBC.ZBC_ICFRVL  = 0) AND  " +CRLF
	_cQry += "  	  (ZBC.ZBC_TEMCOM <> 'N' AND ZBC.ZBC_VLRCOM  = 0) AND  " +CRLF
	_cQry += "  	  ZBC_PRODUT IN ( SELECT D1_COD   " +CRLF
	_cQry += "  							FROM SD1010 D1  " +CRLF
	_cQry += "  						   WHERE D1.D1_FILIAL = ZBC.ZBC_FILIAL AND   " +CRLF
	_cQry += "  							     D1.D1_COD = ZBC_PRODUT AND   " +CRLF
	_cQry += "  								 D1_FORNECE = ZBC_CODFOR AND   " +CRLF
	_cQry += "  								 D1_LOJA = ZBC_LOJFOR AND   " +CRLF
	_cQry += "  								 D1.D_E_L_E_T_ = ' '   " +CRLF
	_cQry += "  						)  " +CRLF
	_cQry += "  GROUP BY ZBC_FILIAL, ZCC_CODIGO, ZBC_PEDIDO, ZCC_CODCOR, ZCC_PAGFUT, ZCC_NOMFOR, ZCC_NOMCOR, ZBC_PRODUT, " +CRLF
	_cQry += "  ZBC_PRDDES, ZBC_DTENTR, ZCC_DTVCTO, ZBC_PESO, ZBC_VLFRPG, ZBC_ICFRVL,  ZBC_VLRCOM, ZBC_CODFOR, ZBC_LOJFOR  " +CRLF
	_cQry += "  ) --SELECT * FROM CONTRATO  " +CRLF
	_cQry += "  SELECT ZBC_FILIAL, ZCC_CODIGO, ZBC_PEDIDO, ZCC_NOMFOR,  ZCC_NOMCOR, ZBC_PRDDES, ZBC_PRODUT,QUANTIDADE , ZBC_DTENTR," +CRLF  
	_cQry += "   CASE WHEN ZCC_PAGFUT = 'S' THEN 'SIM' " +CRLF
	_cQry += "        WHEN ZCC_PAGFUT = 'N' THEN 'NAO' " +CRLF
	_cQry += "  	  ELSE 'NAO DEFINIDO' END AS ZCC_PAGFUT, " +CRLF
	_cQry += "  ZCC_DTVCTO, ZBC_PESO, ZBC_VLFRPG, ZBC_ICFRVL, ZBC_VLRCOM, SUM(D1_QUANT) QTRECEBIDA, QUANTIDADE-SUM(D1_QUANT) QTD_ARECEBER  " +CRLF
	_cQry += "   FROM CONTRATO C  " +CRLF
	_cQry += "    JOIN SD1010 D1 ON   " +CRLF
	_cQry += "  	  D1_FILIAL = C.ZBC_FILIAL AND   " +CRLF
	_cQry += "  	  D1_FORNECE = C.ZBC_CODFOR AND  " +CRLF
	_cQry += "  	  D1_LOJA = C.ZBC_LOJFOR AND   " +CRLF
	_cQry += "  	  D1_COD = C.ZBC_PRODUT AND  " +CRLF
	_cQry += "  	  D1.D1_PEDIDO = C.ZBC_PEDIDO AND   " +CRLF
	_cQry += "  	  D1_TIPO = 'N' AND  " +CRLF
	_cQry += "  	  D1.D_E_L_E_T_ = ' '  " +CRLF
	_cQry += "  	    " +CRLF
	_cQry += " GROUP BY ZBC_FILIAL, ZCC_CODIGO, ZBC_PEDIDO, ZCC_NOMFOR, ZCC_NOMCOR, ZCC_PAGFUT, ZBC_PRDDES, ZBC_PRODUT, QUANTIDADE, " +CRLF 
	_cQry += "  ZBC_DTENTR,  ZCC_DTVCTO, ZBC_PESO, ZBC_VLFRPG, ZBC_ICFRVL, ZBC_VLRCOM  " +CRLF
	_cQry += " HAVING QUANTIDADE-SUM(D1_QUANT) = 0  " +CRLF
	_cQry += " ORDER BY ZBC_FILIAL, ZBC_PEDIDO  " +CRLF
	
	If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
		MemoWrite( StrTran(cArquivo,".xml","") + "_JOB09A.sql" , _cQry)
	EndIf
	
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry), "cAliasP", .f.,.f.) 
	
	xHTM := '<HTML><BODY>'
	xHTM += '<hr>'
	xHTM += '<p  style="word-spacing: 0; line-height: 100%; margin-top: 0; margin-bottom: 0">'
	xHTM += '<b><font face="Verdana" SIZE=3>' + SM0->M0_NOMECOM + '</b></p>'
	xHTM += '<br>'                                                                                            
	//xHTM += '<font face="Verdana" SIZE=3>'+Alltrim( SM0->M0_ENDENT )+" - "+Alltrim(SM0->M0_BAIRENT)
	//xHTM += 		" - CEP: "+alltrim(SM0->M0_CEPENT)+" - Fone/Fax "+ cTelEmp + '</p>'
	xHTM += '<hr>'
	xHTM += '<b><font face="Verdana" SIZE=3>Negociações de compra animal pendente atualizar informações</b></p>'
	xHTM += '<hr>'
	//xHTM += '<font face="Verdana" SIZE=1>* * *  Com base nas notas fiscais de venda sem preenchimento de Peso de Saída e Data de abate * * *</p>'
	xHTM += '<font face="Verdana" SIZE=3>Data: ' + dtoc(date()) + ' Hora: ' + time() + ' - [VAJOB09]</p>'
	xHTM += '<br>'      
	xHTM += '<br>'
	xHTM += '<p><b>Relação das compras de gado com pendencia no preenchimento das informações que fazem composição dos custos de aquisição</b></p>'
	xHTM += '<p>Este e-mail será enviado com base no preenchimento dos campos <b> R$ Frete, R$ ICMS Frete, R$ Comissão.</b></p>
	xHTM += '<p font SIZE=2>**Caso a compra não tenha a incidência das informações destacadas neste e-mail, utilizar os campos <b> Frete?, ICMS Frete?, Comissão?</b> que devem ser preenchidos de acordo com cada situação.</p>
	
	
	xHTM += '<br>'
	
	If !cAliasP->(Eof()) 		// U_VAJOB09()
		lImpCab1 := .T.
		xHTM += '<br>'      			
		xHTM += '<br>'
		xHTM += '<p font face="Verdana" SIZE=3><b>1º PENDENTE - FRETE, ICMS FRETE, COMISSÃO</b></p>'
		xHTM += '<b><font face="Verdana" SIZE=1>
		xHTM += '<table width="85%" BORDER=1>'
		xHTM += '	<tr BGCOLOR=#2b472a >'
		xHTM += '		<td align=center><b><font color=#F5F5F5>Filial</b></font></td>'
		xHTM += '		<td align=center><b><font color=#F5F5F5>Contrato</b></font></td>'
		xHTM += '		<td align=center><b><font color=#F5F5F5>Pedido</b></font></td>'
		xHTM += '		<td align=center><b><font color=#F5F5F5>Fornecedor</b></font></td>'
		xHTM += '		<td align=center><b><font color=#F5F5F5>Corretor</b></font></td>'
		xHTM += '		<td align=center><b><font color=#F5F5F5>Era</b></font></td>'
		xHTM += '		<td align=center><b><font color=#F5F5F5>Qtd Comprada</b></font></td>'
		xHTM += '		<td align=center><b><font color=#F5F5F5>Pagto Futuro</b></font></td>'
		xHTM += '		<td align=center><b><font color=#F5F5F5>Data.Vcto Contrato</b></font></td>'
		xHTM += '		<td align=center><b><font color=#F5F5F5>Peso Compra</b></font></td>'
		xHTM += '		<td BGCOLOR=#ee3e2b align=center><b><font color=#F5F5F5>R$ Frete</b></font></td>'
		xHTM += '		<td BGCOLOR=#ee3e2b align=center><b><font color=#F5F5F5>R$ ICMS Frete</b></font></td>'
		xHTM += '		<td BGCOLOR=#ee3e2b align=center><b><font color=#F5F5F5>R$ Comissao</b></font></td>'
		xHTM += '		<td align=center><b><font color=#F5F5F5>Qtd Recebida</b></font></td>'
		xHTM += '		<td align=center><b><font color=#F5F5F5>A Receber</b></font></td>'
		xHTM += '	</tr>'			
	EndIf
	
	While !cAliasP->(Eof())
		xHTM += '	<tr>'
		xHTM += '		<td align=left   >'+AllTrim(cAliasP->ZBC_FILIAL)+'</td>'
		xHTM += '		<td align=left   >'+AllTrim(cAliasP->ZCC_CODIGO)+'</td>'
		xHTM += '		<td align=left   >'+AllTrim(cAliasP->ZBC_PEDIDO)+'</td>'
		xHTM += '		<td align=left   >'+AllTrim(cAliasP->ZCC_NOMFOR)+'</td>'
		xHTM += '		<td align=left   >'+AllTrim(cAliasP->ZCC_NOMCOR)+'</td>'
		xHTM += '		<td align=left   >'+AllTrim(cAliasP->ZBC_PRDDES)+'</td>'
		xHTM += '		<td align=center >'+Transform( cAliasP->QUANTIDADE, X3Picture('D2_TOTAL') )+'</td>'
		xHTM += '		<td align=left   >'+AllTrim(cAliasP->ZCC_PAGFUT)+'</td>'
		xHTM += '		<td align=left   >'+dToC( stod(cAliasP->ZCC_DTVCTO) ) +'</td>'
		xHTM += '		<td align=left   >'+Transform( cAliasP->ZBC_PESO, "@E 999,999.99" )+'</td>'
		xHTM += '		<td BGCOLOR=#91bdbb align=left   >'+Transform( cAliasP->ZBC_VLFRPG, "@E 999,999,999.99" )+'</td>'
		xHTM += '		<td BGCOLOR=#91bdbb align=left   >'+Transform( cAliasP->ZBC_ICFRVL, "@E 999,999.99" )+'</td>'
		xHTM += '		<td BGCOLOR=#91bdbb align=left   >'+Transform( cAliasP->ZBC_VLRCOM, "@E 999,999.99" )+'</td>'
		xHTM += '		<td align=center >'+Transform( cAliasP->QTRECEBIDA, "@E 999,999.99" )+'</td>'
		xHTM += '		<td align=center >'+Transform( cAliasP->QTD_ARECEBER, "@E 999,999.99" )+'</td>'
		xHTM += '	</tr>'	
		
		cAliasP->(dbSkip())

	EndDo   
	cAliasP->(dbCloseArea())
	
	xHTM += '</table>' // fim da tabela de pedidos		
	xHTM += '<br>'
	
	
	_cQry := "  WITH CONTRATO AS (  " +CRLF
	_cQry += "  	 SELECT ZBC_FILIAL,ZCC_CODIGO, ZBC_PEDIDO, ZCC_PAGFUT, ZCC_NOMFOR, ZCC_NOMCOR, ZBC_PRDDES, ZBC_PRODUT, SUM(ZBC_QUANT) QUANTIDADE ,  " +CRLF
	_cQry += "  	ZBC_DTENTR,  ZCC_DTVCTO, ZBC_PESO, ZBC_VLFRPG, ZBC_ICFRVL, ZBC_VLRCOM,  ZBC_CODFOR, ZBC_LOJFOR  " +CRLF
	_cQry += "  	 FROM ZCC010 ZCC  " +CRLF
	_cQry += "  	 JOIN  ZBC010 ZBC ON   " +CRLF
	_cQry += "  	       ZCC_FILIAL = ZBC_FILIAL AND   " +CRLF
	_cQry += "  	       ZCC_CODIGO = ZBC_CODIGO AND  " +CRLF
	_cQry += "  	 	  ZBC.D_E_L_E_T_ = ' '  " +CRLF
	_cQry += "  	 JOIN  ZIC010 ZIC ON  " +CRLF
	_cQry += "  	 	  ZIC_FILIAL = ZCC_FILIAL AND  " +CRLF
	_cQry += "  	 	  ZIC_CODIGO = ZCC_CODIGO AND  " +CRLF
	_cQry += "  	 	  ZIC_VERSAO = ZCC_VERSAO AND   " +CRLF
	_cQry += "  	 	  ZIC.D_E_L_E_T_ = ' '  " +CRLF
	_cQry += "  	 WHERE ZCC_PAGFUT = 'N' AND   " +CRLF
	_cQry += "  	 	  ZIC_ITEM = ZBC_ITEZIC AND  " +CRLF
	_cQry += "  	 	  ZCC_DTVCTO = ' ' AND  " +CRLF
	_cQry += "  	 	  ZCC.D_E_L_E_T_ = ' ' AND  " +CRLF
	_cQry += "  	 	  ZBC_PEDIDO <> ' '  AND   " +CRLF
	_cQry += "  	 	  (ZBC.ZBC_TEMFRE <> 'N' AND ZBC.ZBC_VLFRPG  <> 0) AND  " +CRLF
	_cQry += "  	 	  (ZBC.ZBC_TEMICF <> 'N' AND ZBC.ZBC_ICFRVL  <> 0) AND  " +CRLF
	_cQry += "  	 	  (ZBC.ZBC_TEMCOM <> 'N' AND ZBC.ZBC_VLRCOM  = 0) AND  " +CRLF
	_cQry += "  	 	  ZBC_PRODUT IN ( SELECT D1_COD   " +CRLF
	_cQry += "  	 							FROM SD1010 D1  " +CRLF
	_cQry += "  	 						   WHERE D1.D1_FILIAL = ZBC.ZBC_FILIAL AND   " +CRLF
	_cQry += "  	 							     D1.D1_COD = ZBC_PRODUT AND   " +CRLF
	_cQry += "  	 								 D1_FORNECE = ZBC_CODFOR AND   " +CRLF
	_cQry += "  	 								 D1_LOJA = ZBC_LOJFOR AND   " +CRLF
	_cQry += "  	 								 D1.D_E_L_E_T_ = ' '   " +CRLF
	_cQry += "  	 						)  " +CRLF
	_cQry += "  	 GROUP BY ZBC_FILIAL, ZCC_CODIGO, ZBC_PEDIDO, ZCC_CODCOR, ZCC_PAGFUT, ZCC_NOMFOR, ZCC_NOMCOR, ZBC_PRODUT, " +CRLF
	_cQry += "  	 ZBC_PRDDES, ZBC_DTENTR, ZCC_DTVCTO, ZBC_PESO, ZBC_VLFRPG, ZBC_ICFRVL,  ZBC_VLRCOM, ZBC_CODFOR, ZBC_LOJFOR  " +CRLF
	_cQry += "  	 ) --SELECT * FROM CONTRATO  " +CRLF
	_cQry += "  	 SELECT ZBC_FILIAL, ZCC_CODIGO, ZBC_PEDIDO, ZCC_NOMFOR,  ZCC_NOMCOR, ZBC_PRDDES, ZBC_PRODUT,QUANTIDADE , ZBC_DTENTR,  " +CRLF
	_cQry += "  	  CASE WHEN ZCC_PAGFUT = 'S' THEN 'SIM' " +CRLF
	_cQry += "  	       WHEN ZCC_PAGFUT = 'N' THEN 'NAO' " +CRLF
	_cQry += "  	 	  ELSE 'NAO DEFINIDO' END AS ZCC_PAGFUT, " +CRLF
	_cQry += "  	 ZCC_DTVCTO, ZBC_PESO, ZBC_VLFRPG, ZBC_ICFRVL, ZBC_VLRCOM, SUM(D1_QUANT) QTRECEBIDA, QUANTIDADE-SUM(D1_QUANT) QTD_ARECEBER  " +CRLF
	_cQry += "  	  FROM CONTRATO C  " +CRLF
	_cQry += "  	   JOIN SD1010 D1 ON   " +CRLF
	_cQry += "  	 	  D1_FILIAL = C.ZBC_FILIAL AND   " +CRLF
	_cQry += "  	 	  D1_FORNECE = C.ZBC_CODFOR AND  " +CRLF
	_cQry += "  	 	  D1_LOJA = C.ZBC_LOJFOR AND   " +CRLF
	_cQry += "  	 	  D1_COD = C.ZBC_PRODUT AND  " +CRLF
	_cQry += "  	 	  D1.D1_PEDIDO = C.ZBC_PEDIDO AND   " +CRLF
	_cQry += "  	 	  D1_TIPO = 'N' AND  " +CRLF
	_cQry += "  	 	  D1.D_E_L_E_T_ = ' '  " +CRLF
	_cQry += "  	 	    " +CRLF  
	_cQry += "  	GROUP BY ZBC_FILIAL, ZCC_CODIGO, ZBC_PEDIDO, ZCC_NOMFOR, ZCC_NOMCOR, ZCC_PAGFUT, ZBC_PRDDES, ZBC_PRODUT, QUANTIDADE,  " +CRLF
	_cQry += "  	 ZBC_DTENTR,  ZCC_DTVCTO, ZBC_PESO, ZBC_VLFRPG, ZBC_ICFRVL, ZBC_VLRCOM  " +CRLF
	_cQry += "  	HAVING QUANTIDADE-SUM(D1_QUANT) = 0  " +CRLF
	_cQry += "  	ORDER BY ZBC_FILIAL, ZBC_PEDIDO  " +CRLF
	
	If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
		MemoWrite( StrTran(cArquivo,".xml","") + "_JOB09B.sql" , _cQry)
	EndIf
	
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry), "cAliasA", .f.,.f.)
	
	If !cAliasA->(Eof()) 		// U_VAJOB09()
		lImpCab1 := .T.
		xHTM += '<br>'      			
		xHTM += '<br>'
		xHTM += '<p font face="Verdana" SIZE=3><b>2º PENDENTE PREENCHIMENTO COMISSÃO</b></p>'
		xHTM += '<b><font face="Verdana" SIZE=1>
		xHTM += '<table width="85%" BORDER=1>'
		xHTM += '	<tr BGCOLOR=#2b472a >'
		xHTM += '		<td align=center><b><font color=#F5F5F5>Filial</b></font></td>'
		xHTM += '		<td align=center><b><font color=#F5F5F5>Contrato</b></font></td>'
		xHTM += '		<td align=center><b><font color=#F5F5F5>Pedido</b></font></td>'
		xHTM += '		<td align=center><b><font color=#F5F5F5>Fornecedor</b></font></td>'
		xHTM += '		<td align=center><b><font color=#F5F5F5>Corretor</b></font></td>'
		xHTM += '		<td align=center><b><font color=#F5F5F5>Era</b></font></td>'
		xHTM += '		<td align=center><b><font color=#F5F5F5>Qtd Comprada</b></font></td>'
		xHTM += '		<td align=center><b><font color=#F5F5F5>Pagto Futuro</b></font></td>'
		xHTM += '		<td align=center><b><font color=#F5F5F5>Data.Vcto Contrato</b></font></td>'
		xHTM += '		<td align=center><b><font color=#F5F5F5>Peso Compra</b></font></td>'
		xHTM += '		<td align=center><b><font color=#F5F5F5>R$ Frete</b></font></td>'
		xHTM += '		<td align=center><b><font color=#F5F5F5>R$ ICMS Frete</b></font></td>'
		xHTM += '		<td BGCOLOR=#ee3e2b align=center><b><font color=#F5F5F5>R$ Comissao</b></font></td>'
		xHTM += '		<td align=center><b><font color=#F5F5F5>Qtd Recebida</b></font></td>'
		xHTM += '		<td align=center><b><font color=#F5F5F5>A Receber</b></font></td>'
		xHTM += '	</tr>'	
		
	EndIf
	While !cAliasA->(Eof())
		xHTM += '	<tr>'
		xHTM += '		<td align=left   >'+AllTrim(cAliasA->ZBC_FILIAL)+'</td>'
		xHTM += '		<td align=left   >'+AllTrim(cAliasA->ZCC_CODIGO)+'</td>'
		xHTM += '		<td align=left   >'+AllTrim(cAliasA->ZBC_PEDIDO)+'</td>'
		xHTM += '		<td align=left   >'+AllTrim(cAliasA->ZCC_NOMFOR)+'</td>'
		xHTM += '		<td align=left   >'+AllTrim(cAliasA->ZCC_NOMCOR)+'</td>'
		xHTM += '		<td align=left   >'+AllTrim(cAliasA->ZBC_PRDDES)+'</td>'
		xHTM += '		<td align=center >'+Transform( cAliasA->QUANTIDADE, X3Picture('D2_TOTAL') )+'</td>'
		xHTM += '		<td align=left   >'+AllTrim(cAliasA->ZCC_PAGFUT)+'</td>'
		xHTM += '		<td align=left   >'+dToC( stod(cAliasA->ZCC_DTVCTO) ) +'</td>'
		xHTM += '		<td align=left   >'+Transform( cAliasA->ZBC_PESO, "@E 999,999.99" )+'</td>'
		xHTM += '		<td align=left   >'+Transform( cAliasA->ZBC_VLFRPG, "@E 999,999,999.99" )+'</td>'
		xHTM += '		<td align=left   >'+Transform( cAliasA->ZBC_ICFRVL, "@E 999,999.99" )+'</td>'
		xHTM += '		<td BGCOLOR=#91bdbb align=left   >'+Transform( cAliasA->ZBC_VLRCOM, "@E 999,999.99" )+'</td>'
		xHTM += '		<td align=center >'+Transform( cAliasA->QTRECEBIDA, "@E 999,999.99" )+'</td>'
		xHTM += '		<td align=center >'+Transform( cAliasA->QTD_ARECEBER, "@E 999,999.99" )+'</td>'
		xHTM += '	</tr>'	
	
		cAliasA->(dbSkip())

	EndDo           
	cAliasA->(dbCloseArea())
	
	xHTM += '</table>' // fim da tabela de pedidos		
	xHTM += '<br>'
	
	
	_cQry := " WITH CONTRATO AS (  " +CRLF
	_cQry += "	 SELECT ZBC_FILIAL,ZCC_CODIGO, ZBC_PEDIDO, ZCC_PAGFUT, ZCC_NOMFOR, ZCC_NOMCOR, ZBC_PRDDES, ZBC_PRODUT, SUM(ZBC_QUANT) QUANTIDADE ,  " +CRLF
	_cQry += "	ZBC_DTENTR,  ZCC_DTVCTO, ZBC_PESO, ZBC_VLFRPG, ZBC_ICFRVL, ZBC_VLRCOM,  ZBC_CODFOR, ZBC_LOJFOR  " +CRLF
	_cQry += "	 FROM ZCC010 ZCC  " +CRLF
	_cQry += "	 JOIN  ZBC010 ZBC ON   " +CRLF
	_cQry += "	       ZCC_FILIAL = ZBC_FILIAL AND   " +CRLF
	_cQry += "	       ZCC_CODIGO = ZBC_CODIGO AND  " +CRLF
	_cQry += "	 	  ZBC.D_E_L_E_T_ = ' '  " +CRLF
	_cQry += "	 JOIN  ZIC010 ZIC ON  " +CRLF
	_cQry += "	 	  ZIC_FILIAL = ZCC_FILIAL AND  " +CRLF
	_cQry += "	 	  ZIC_CODIGO = ZCC_CODIGO AND  " +CRLF
	_cQry += "	 	  ZIC_VERSAO = ZCC_VERSAO AND   " +CRLF
	_cQry += "	 	  ZIC.D_E_L_E_T_ = ' '  " +CRLF
	_cQry += "	 WHERE ZCC_PAGFUT = 'N' AND   " +CRLF
	_cQry += "	 	  ZIC_ITEM = ZBC_ITEZIC AND  " +CRLF
	_cQry += "	 	  ZCC_DTVCTO = ' ' AND  " +CRLF
	_cQry += "	 	  ZCC.D_E_L_E_T_ = ' ' AND  " +CRLF
	_cQry += "	 	  ZBC_PEDIDO <> ' '  AND   " +CRLF
	_cQry += "	 	  (ZBC.ZBC_TEMFRE <> 'N' AND ZBC.ZBC_VLFRPG  = 0) AND  " +CRLF
	_cQry += "	 	  (ZBC.ZBC_TEMICF <> 'N' AND ZBC.ZBC_ICFRVL  = 0) AND  " +CRLF
	_cQry += "	 	  (ZBC.ZBC_TEMCOM <> 'N' AND ZBC.ZBC_VLRCOM  <> 0) AND  " +CRLF
	_cQry += "	 	  ZBC_PRODUT IN ( SELECT D1_COD   " +CRLF
	_cQry += "	 							FROM SD1010 D1  " +CRLF
	_cQry += "	 						   WHERE D1.D1_FILIAL = ZBC.ZBC_FILIAL AND   " +CRLF
	_cQry += "	 							     D1.D1_COD = ZBC_PRODUT AND   " +CRLF
	_cQry += "	 								 D1_FORNECE = ZBC_CODFOR AND   " +CRLF
	_cQry += "	 								 D1_LOJA = ZBC_LOJFOR AND   " +CRLF
	_cQry += "	 								 D1.D_E_L_E_T_ = ' '   " +CRLF
	_cQry += "	 						) " +CRLF
	_cQry += "							AND" +CRLF
	_cQry += "		 (ZBC_FILIAL + ZBC_CODIGO + ZBC_VERSAO + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + ZBC_VERPED) IN " +CRLF
	_cQry += "	( " +CRLF
	_cQry += "		SELECT ZBC_FILIAL + ZBC_CODIGO + MAX(ZBC_VERSAO) + ZBC_ITEM + ZBC_ITEZIC + ZBC_PEDIDO + ZBC_ITEMPC + MAX(ZBC_VERPED) " +CRLF
	_cQry += "		FROM ZBC010 " +CRLF
	_cQry += "		WHERE D_E_L_E_T_=' ' " +CRLF
	_cQry += "		GROUP BY ZBC_FILIAL, ZBC_CODIGO, ZBC_ITEM, ZBC_ITEZIC, ZBC_PEDIDO, ZBC_ITEMPC " +CRLF
	_cQry += "	) " +CRLF
	_cQry += "	 GROUP BY ZBC_FILIAL, ZCC_CODIGO, ZBC_PEDIDO, ZCC_CODCOR, ZCC_PAGFUT, ZCC_NOMFOR, ZCC_NOMCOR, ZBC_PRODUT, " +CRLF
	_cQry += "	 ZBC_PRDDES, ZBC_DTENTR, ZCC_DTVCTO, ZBC_PESO, ZBC_VLFRPG, ZBC_ICFRVL,  ZBC_VLRCOM, ZBC_CODFOR, ZBC_LOJFOR  " +CRLF
	_cQry += "	 )  " +CRLF
	_cQry += "	 SELECT ZBC_FILIAL, ZCC_CODIGO, ZBC_PEDIDO, ZCC_NOMFOR,  ZCC_NOMCOR, ZBC_PRDDES, ZBC_PRODUT,QUANTIDADE , ZBC_DTENTR,  " +CRLF
	_cQry += "	  CASE WHEN ZCC_PAGFUT = 'S' THEN 'SIM' " +CRLF
	_cQry += "	       WHEN ZCC_PAGFUT = 'N' THEN 'NAO' " +CRLF
	_cQry += "	 	  ELSE 'NAO DEFINIDO' END AS ZCC_PAGFUT, " +CRLF
	_cQry += "	 ZCC_DTVCTO, ZBC_PESO, ZBC_VLFRPG, ZBC_ICFRVL, ZBC_VLRCOM, SUM(D1_QUANT) QTRECEBIDA, QUANTIDADE-SUM(D1_QUANT) QTD_ARECEBER  " +CRLF
	_cQry += "	  FROM CONTRATO C  " +CRLF
	_cQry += "	   JOIN SD1010 D1 ON   " +CRLF
	_cQry += "	 	  D1_FILIAL = C.ZBC_FILIAL AND   " +CRLF
	_cQry += "	 	  D1_FORNECE = C.ZBC_CODFOR AND  " +CRLF
	_cQry += "	 	  D1_LOJA = C.ZBC_LOJFOR AND   " +CRLF
	_cQry += "	 	  D1_COD = C.ZBC_PRODUT AND  " +CRLF
	_cQry += "	 	  D1.D1_PEDIDO = C.ZBC_PEDIDO AND   " +CRLF
	_cQry += "	 	  D1_TIPO = 'N' AND  " +CRLF
	_cQry += "	 	  D1.D_E_L_E_T_ = ' '  " +CRLF
	_cQry += "	 	    " +CRLF
	_cQry += "	GROUP BY ZBC_FILIAL, ZCC_CODIGO, ZBC_PEDIDO, ZCC_NOMFOR, ZCC_NOMCOR, ZCC_PAGFUT, ZBC_PRDDES, ZBC_PRODUT, QUANTIDADE,  " +CRLF
	_cQry += "	 ZBC_DTENTR,  ZCC_DTVCTO, ZBC_PESO, ZBC_VLFRPG, ZBC_ICFRVL, ZBC_VLRCOM  " +CRLF
	_cQry += "	HAVING QUANTIDADE-SUM(D1_QUANT) = 0  " +CRLF
	_cQry += "	ORDER BY ZBC_FILIAL, ZBC_PEDIDO  " +CRLF
	
	If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
		MemoWrite( StrTran(cArquivo,".xml","") + "_JOB09C.sql" , _cQry)
	EndIf
	
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry), "cAliasF", .f.,.f.)
	
	If !cAliasF->(Eof()) 		// U_VAJOB09()
		lImpCab1 := .T.
		xHTM += '<br>'      			
		xHTM += '<br>'
		xHTM += '<p font face="Verdana" SIZE=3><b>3º PENDENTE - FRETE, ICMS FRETE</b></p>'
		xHTM += '<b><font face="Verdana" SIZE=1>
		xHTM += '<table width="85%" BORDER=1>'
		xHTM += '	<tr BGCOLOR=#2b472a >'
		xHTM += '		<td align=center><b><font color=#F5F5F5>Filial</b></font></td>'
		xHTM += '		<td align=center><b><font color=#F5F5F5>Contrato</b></font></td>'
		xHTM += '		<td align=center><b><font color=#F5F5F5>Pedido</b></font></td>'
		xHTM += '		<td align=center><b><font color=#F5F5F5>Fornecedor</b></font></td>'
		xHTM += '		<td align=center><b><font color=#F5F5F5>Corretor</b></font></td>'
		xHTM += '		<td align=center><b><font color=#F5F5F5>Era</b></font></td>'
		xHTM += '		<td align=center><b><font color=#F5F5F5>Qtd Comprada</b></font></td>'
		xHTM += '		<td align=center><b><font color=#F5F5F5>Pagto Futuro</b></font></td>'
		xHTM += '		<td align=center><b><font color=#F5F5F5>Data.Vcto Contrato</b></font></td>'
		xHTM += '		<td align=center><b><font color=#F5F5F5>Peso Compra</b></font></td>'
		xHTM += '		<td BGCOLOR=#ee3e2b align=center><b><font color=#F5F5F5>R$ Frete</b></font></td>'
		xHTM += '		<td BGCOLOR=#ee3e2b align=center><b><font color=#F5F5F5>R$ ICMS Frete</b></font></td>'
		xHTM += '		<td align=center><b><font color=#F5F5F5>R$ Comissao</b></font></td>'
		xHTM += '		<td align=center><b><font color=#F5F5F5>Qtd Recebida</b></font></td>'
		xHTM += '		<td align=center><b><font color=#F5F5F5>A Receber</b></font></td>'
		xHTM += '	</tr>'			
	EndIf
	
	While !cAliasF->(Eof())
		xHTM += '	<tr>'
		xHTM += '		<td align=left   >'+AllTrim(cAliasF->ZBC_FILIAL)+'</td>'
		xHTM += '		<td align=left   >'+AllTrim(cAliasF->ZCC_CODIGO)+'</td>'
		xHTM += '		<td align=left   >'+AllTrim(cAliasF->ZBC_PEDIDO)+'</td>'
		xHTM += '		<td align=left   >'+AllTrim(cAliasF->ZCC_NOMFOR)+'</td>'
		xHTM += '		<td align=left   >'+AllTrim(cAliasF->ZCC_NOMCOR)+'</td>'
		xHTM += '		<td align=left   >'+AllTrim(cAliasF->ZBC_PRDDES)+'</td>'
		xHTM += '		<td align=center >'+Transform( cAliasF->QUANTIDADE, X3Picture('D2_TOTAL') )+'</td>'
		xHTM += '		<td align=left   >'+AllTrim(cAliasF->ZCC_PAGFUT)+'</td>'
		xHTM += '		<td align=left   >'+dToC( stod(cAliasF->ZCC_DTVCTO) ) +'</td>'
		xHTM += '		<td align=left   >'+Transform( cAliasF->ZBC_PESO, "@E 999,999.99" )+'</td>'
		xHTM += '		<td BGCOLOR=#91bdbb align=left   >'+Transform( cAliasF->ZBC_VLFRPG, "@E 999,999,999.99" )+'</td>'
		xHTM += '		<td BGCOLOR=#91bdbb align=left   >'+Transform( cAliasF->ZBC_ICFRVL, "@E 999,999.99" )+'</td>'
		xHTM += '		<td align=left   >'+Transform( cAliasF->ZBC_VLRCOM, "@E 999,999.99" )+'</td>'
		xHTM += '		<td align=center >'+Transform( cAliasF->QTRECEBIDA, "@E 999,999.99" )+'</td>'
		xHTM += '		<td align=center >'+Transform( cAliasF->QTD_ARECEBER, "@E 999,999.99" )+'</td>'
		xHTM += '	</tr>'	
		
		cAliasF->(dbSkip())

	EndDo   
	cAliasF->(dbCloseArea())
	
	xHTM += '</table>' // fim da tabela de pedidos		
	xHTM += '<br>'
	
	xHTM += '</BODY></HTML>'

	if lImpCab1 // lEnvia				// U_VAJOB09()

		_cQry := " SELECT X5_CHAVE, X5_DESCRI "
		_cQry += " FROM "+RetSqlName('SX5')+" SX5 "
		_cQry += " WHERE X5_TABELA = '"+cJobSX5+"' "
		_cQry += " AND SUBSTRING(X5_CHAVE,1,5)  = '"+cJobChv+"'  "
		_cQry += " AND D_E_L_E_T_<>'*' "  
		_cQry += " ORDER BY X5_CHAVE "  
		
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry), "cAliasE",.F.,.F.)

		ConOut('SQL do e-Mail retornou resultado: ' + Time())
		
		xAssunto:= "Informações Pendentes - Compra de Gado"
		xAnexo  := ""                                           
		xDe     := "protheus@vistalegre.agr.br"             
		xCopia  := ""
		xEmail  := ""
		
		xaDados := {}
		aAdd( xaDados, { "LogoTipo", "\workflow\images\logoM.jpg" } )

		xEmail := ""
		While !cAliasE->(Eof())
			
			xEmail  += Iif(Empty(xEmail),"",", ") + alltrim(lower( cAliasE->X5_DESCRI)) 
			
			cAliasE->(dbSkip())
		EndDo
		
		// xEmail := "miguel.bernardo@vistaalegre.agr.br" // , arthur.toshio@vistaalegre.agr.br"
		If !Empty(xEmail)
		
			ConOut("Para: " + xEmail )
			MemoWrite( StrTran(cArquivo,".xml","") + "_JOB09D.HTML" , xHTM)
			
			Processa({ || u_EnvMail(xEmail	,;			//_cPara
							xCopia 				,;		//_cCc
							""					,;		//_cBCC
							xAssunto			,;		//_cTitulo
							xaDados				,;		//_aAnexo
							xHTM				,;		//_cMsg
							.T.)},"Enviando e-mail...")	//_lAudit
		EndIf
		
		cAliasE->(dbCloseArea())
	Else
		ConOut('SQL nao retornou resultado.')
	endif		

ConOut("Fim do Job [VAJOB09]: " + DTOC(DATE()) + ' ' + TIME())

return nil



Static Function ConvType(xValor,nTam,nDec)

Local cNovo := ""
DEFAULT nDec := 0
Do Case
	Case ValType(xValor)=="N"
		If xValor <> 0
			cNovo := AllTrim(Str(xValor,nTam,nDec))	
		Else	
			cNovo := "0"
		EndIf
	Case ValType(xValor)=="D"
		cNovo := FsDateConv(xValor,"YYYYMMDD")
		cNovo := SubStr(cNovo,1,4)+"-"+SubStr(cNovo,5,2)+"-"+SubStr(cNovo,7)
	Case ValType(xValor)=="C"
		If nTam==Nil
			xValor := AllTrim(xValor)
		EndIf
		DEFAULT nTam := 60
		cNovo := AllTrim(EnCodeUtf8(NoAcento(SubStr(xValor,1,nTam))))
EndCase
Return(cNovo)
