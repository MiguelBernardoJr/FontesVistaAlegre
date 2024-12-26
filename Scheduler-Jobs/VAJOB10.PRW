#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH" 
#INCLUDE "RWMAKE.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "FILEIO.CH"

/*--------------------------------------------------------------------------------,
 | Principal: 					U_VAJOB10()                                       |
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
User Function VAJOB10()              // U_VAJOB10()

If Type("oMainWnd") == "U"
	U_RunFunc("U_JOB10VA()",'01','01',3) // Gravar pedido de venda customizado.
Else
	U_JOB10VA()
EndIf
Return nil


/* MJ : 24.10.2018 */
User Function JOB10VA() 

Local xHTM 			:= ""  
Local cTelEmp		:= ""
Local aTelEmp		:= ""
Local lImpCab1		:= .T.
Local xaDados		:= {}
Local cCodigo		:= ""
Local _cQry 		:= ""
Local lTemDados		:= .F.

Local cJobChv		:= 'JOB10' 	// codigo da chave na tabela da sx5, pra incluir emails para envio do job
Local cJobSX5		:= 'Z2'		// tabela da SX5 onde serao selecionados os emails para envio
Local cAliasP    := GetNextAlias()
Local cAliasE    := GetNextAlias()
Local cPath 	 	:= "C:\totvs_relatorios\"
Local cArquivo   	:= cPath + "JOB10_" + ; // __cUserID+"_"+;
						DtoS(dDataBase)+; 
						"_"+; 
						StrTran(SubS(Time(),1,5),":","")+;
						".xml"
 						
    ConOut("[VAJOB10] " + DTOC(DATE()) + ' ' + TIME())

	// Processar SQL
	
	_cQry := "  WITH PROD_RACAO		   " +CRLF
	_cQry += "    AS (		   " +CRLF
	_cQry += "        SELECT D3.D3_FILIAL					    FILIAL,		   " +CRLF
	_cQry += "        	   D3.D3_COD					    CODIGO,		   " +CRLF
	_cQry += "        	   B1.B1_DESC					    DESCRICAO, 		   " +CRLF
	_cQry += "        	   D3.D3_UM						    UM,    					   " +CRLF
	_cQry += "           	   D3.D3_OP							OP,		   " +CRLF
	_cQry += "    		   D3.D3_EMISSAO					EMISSAO,     		   " +CRLF
	_cQry += "        	   SUM(D3.D3_QUANT)					QTD,		   " +CRLF
	_cQry += "        	   SUM(D3.D3_CUSTO1)				CUSTO		   " +CRLF
	_cQry += "  		   , B1_X_TRATO   " +CRLF
	_cQry += "        FROM "+retSQLName("SD3")+" D3		   " +CRLF
	_cQry += "        JOIN "+retSQLName("SB1")+" B1 ON 		   " +CRLF
	_cQry += "        D3_COD = B1_COD 		   " +CRLF
	_cQry += "        WHERE D3.D3_TM = '001'		   " +CRLF
	_cQry += "        AND D3.D3_EMISSAO BETWEEN '"+DToS(ddatabase-8)+"' AND '"+DToS(ddatabase-1)+"'  " +CRLF
	_cQry += "        AND D3.D_E_L_E_T_ = ' '  		   " +CRLF
	_cQry += "        AND B1.D_E_L_E_T_ = ' ' 		   " +CRLF
	_cQry += "        AND B1_X_TRATO = '1'		   " +CRLF
	_cQry += "        --AND D3.D3_COD = '030013'		   " +CRLF
	_cQry += "        GROUP BY D3.D3_FILIAL, D3.D3_COD, B1_DESC, D3.D3_UM, D3.D3_EMISSAO, D3.D3_OP		   " +CRLF
	_cQry += "  	  , B1_X_TRATO   " +CRLF
	_cQry += "        --ORDER BY D3.D3_COD,  			   " +CRLF
	_cQry += "        	   --D3.D3_EMISSAO					   " +CRLF
	_cQry += "    	),		   " +CRLF
	_cQry += "    INS_CARR		   " +CRLF
	_cQry += "    AS (		   " +CRLF
	_cQry += "    	SELECT P.FILIAL, P.CODIGO, D3.D3_FILIAL, D3_COD, D3.D3_EMISSAO, SUM(D3_QUANT) QTD, SUM(D3_CUSTO1) CUSTO FROM "+retSQLName("SD3")+" D3		   " +CRLF
	_cQry += "    	  JOIN PROD_RACAO P ON		   " +CRLF
	_cQry += "    	       D3.D3_FILIAL				=			P.FILIAL		   " +CRLF
	_cQry += "    	   AND D3.D3_OP					=			P.OP		   " +CRLF
	_cQry += "    	   AND D3.D3_EMISSAO			=			P.EMISSAO		   " +CRLF
	_cQry += "    	   AND D3.D3_COD				<>			P.CODIGO		     " +CRLF
	_cQry += "    	   AND D3_CF					LIKE		'RE%'		   " +CRLF
	_cQry += "    	 WHERE D3.D_E_L_E_T_			=			' ' 		   " +CRLF
	_cQry += "    	 GROUP BY P.FILIAL, P.CODIGO, D3.D3_FILIAL, D3.D3_COD, D3_EMISSAO		   " +CRLF
	_cQry += "    	)		   " +CRLF
	_cQry += "    	SELECT P.B1_X_TRATO,   " +CRLF
	_cQry += "  		   P.FILIAL,		   " +CRLF
	_cQry += "    		   P.CODIGO, 		   " +CRLF
	_cQry += "  			   P.DESCRICAO,		   " +CRLF
	_cQry += "    		   P.UM,		   " +CRLF
	_cQry += "    		   P.EMISSAO, 		   " +CRLF
	_cQry += "    		   SUM(P.QTD) QUANTIDADE,  " +CRLF
	_cQry += "    		   SUM(P.CUSTO)/SUM(P.QTD) CUSTO_MEDIO,   " +CRLF
	_cQry += "    		   SUM(P.CUSTO) CUSTO_TOTAL   " +CRLF
	_cQry += "    	FROM PROD_RACAO P		   " +CRLF
	_cQry += "    	--WHERE	 CODIGO NOT IN ('030006','030007')   " +CRLF
	_cQry += "    	GROUP BY P.B1_X_TRATO,   " +CRLF
	_cQry += "  			 P.FILIAL, 		   " +CRLF
	_cQry += "    		     P.CODIGO, 		   " +CRLF
	_cQry += "  			 P.DESCRICAO,	   " +CRLF
	_cQry += "    			 P.UM,		   " +CRLF
	_cQry += "    			 P.EMISSAO		   " +CRLF
	_cQry += "    	ORDER BY P.B1_X_TRATO,  " +CRLF
	_cQry += "    	 		 P.FILIAL,	  " +CRLF
	_cQry += "    			 P.CODIGO, 	  " +CRLF
	_cQry += "    	 		 P.EMISSAO	  " +CRLF
	
	
	If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
		MemoWrite( StrTran(cArquivo,".xml","") + "_JOB10.sql" , _cQry)
	EndIf

	DbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry), (cAliasP), .T.,.T.)
	
	ConOut('SQL Principal retornou resultado: ' + Time())
	aTelEmp:= FisGetTel(SM0->M0_TEL)
	cTelEmp := "" //IIF(aTelDest[1] > 0,ConvType(aTelDest[1],3),"") // Código do Pais
	cTelEmp += "("+ IIF(aTelEmp[2] > 0,ConvType(aTelEmp[2],3),"") + ") " // Código da Área
	cTelEmp += IIF(aTelEmp[3] > 0,ConvType(aTelEmp[3],9),"") // Código do Telefone
	//cFoneEmp:= "Telefone: " + cFoneEmp 

	xHTM := '<HTML><BODY>'
	xHTM += '<hr>'
	xHTM += '<p  style="word-spacing: 0; line-height: 100%; margin-top: 0; margin-bottom: 0">'
	xHTM += '<b><font face="Verdana" SIZE=3>' + SM0->M0_NOMECOM + '</b></p>'
	xHTM += '<br>'                                                                                            
	xHTM += '<font face="Verdana" SIZE=3>'+Alltrim( SM0->M0_ENDENT )+" - "+Alltrim(SM0->M0_BAIRENT)
	xHTM += 		" - CEP: "+alltrim(SM0->M0_CEPENT)+" - Fone/Fax "+ cTelEmp + '</p>'
	xHTM += '<hr>'
	xHTM += '<b><font face="Verdana" SIZE=3>Resumo da Produção - Fabrica de ração entre '+DtoC(dDatabase-8)+' e '+DtoC(dDatabase-1)+'</b></p>'
	xHTM += '<hr>'
	//xHTM += '<font face="Verdana" SIZE=1>* * *  Com base nas notas fiscais de venda sem preenchimento de Peso de Saída e Data de abate * * *</p>'
	xHTM += '<font face="Verdana" SIZE=3>Data: ' + dtoc(date()) + ' Hora: ' + time() + ' - [VAJOB10]</p>'
	xHTM += '<br>'      
	xHTM += '<br>'



	cCodigo := ""			// U_VAJOB10()
    lEnvia := !(cAliasP)->(Eof())
	While !(cAliasP)->(Eof())
		If  cCodigo <> AllTrim((cAliasP)->CODIGO)
			xHTM += '<br>'      			
			xHTM += '<br>'
			xHTM += '<b><font face="Verdana" SIZE=1>
			// Cabecalho Pedido
			xHTM += '<table BORDER=1>'
			xHTM += '	<tr BGCOLOR=#698B69 >'
			xHTM += '		<td><b><font color=#F5F5F5>Filial</b></font></td>'
			xHTM += '		<td><b><font color=#F5F5F5>Codigo</b></font></td>'
			xHTM += '		<td><b><font color=#F5F5F5>Descricao</b></font></td>'
			xHTM += '		<td><b><font color=#F5F5F5>Unid Medida</b></font></td>'
			xHTM += '	</tr>'	

			xHTM += '	<tr>'
			xHTM += '		<td>'+AllTrim((cAliasP)->FILIAL)+'</td>'
			xHTM += '		<td>'+AllTrim((cAliasP)->CODIGO)+'</td>'
			xHTM += '		<td>'+AllTrim((cAliasP)->DESCRICAO)+'</td>'
			xHTM += '		<td>'+AllTrim((cAliasP)->UM)+'</td>'
			xHTM += '	</tr>'	
			
			xHTM += '</table>'
			lImpCab1 := .T.			
		EndIf
		cCodigo 	:= AllTrim((cAliasP)->CODIGO)		// U_VAJOB10()

		If lImpCab1
			xHTM += '<b><font face="Verdana" SIZE=1>
			xHTM += '<table BORDER=1>'
			xHTM += '	<tr BGCOLOR=#778899 >'
			xHTM += '		<td><b><font color=#F5F5F5>Data</b></font></td>'
			xHTM += '		<td><b><font color=#F5F5F5>Quantidade</b></font></td>'
			xHTM += '		<td><b><font color=#F5F5F5>Custo Medio (KG)</b></font></td>'
			xHTM += '		<td><b><font color=#F5F5F5>Custo Total</b></font></td>'
			xHTM += '	</tr>'
			lImpCab1 := .F.	
		Endif

		xHTM += '	<tr>'
		xHTM += '		<td>'+dToC( stod((cAliasP)->EMISSAO) ) +'</td>'
		xHTM += '		<td align=right>'+AllTrim(Transform( (cAliasP)->QUANTIDADE , "@R 999,999,999.99" ) )+'</td>'
		xHTM += '		<td align=right>'+AllTrim(Transform( (cAliasP)->CUSTO_MEDIO, "@R 999,999,999.99" ) )+'</td>'
		xHTM += '		<td align=right>'+AllTrim(Transform( (cAliasP)->CUSTO_TOTAL, "@R 999,999,999.99" ) )+'</td>'
		xHTM += '	</tr>'
		// Endif
   		
   		(cAliasP)->(dbSkip())
		
		If  cCodigo <> AllTrim((cAliasP)->CODIGO) .or. (cAliasP)->(Eof())
			xHTM += '</table>' // fim da tabela de pedidos
			xHTM += '<br>'
		EndIf
    EndDo  
	(cAliasP)->(dbCloseArea())
	xHTM += '<br>'
	xHTM += '</BODY></HTML>'

	if lEnvia				// U_VAJOB10()

		_cQry := " SELECT X5_CHAVE, X5_DESCRI "
		_cQry += " FROM "+RetSqlName('SX5')+" SX5 "
		_cQry += " WHERE X5_TABELA = '"+cJobSX5+"' "
		_cQry += " AND SUBSTRING(X5_CHAVE,1,5)  = '"+cJobChv+"'  "
		_cQry += " AND D_E_L_E_T_<>'*' "  
		_cQry += " ORDER BY X5_CHAVE "  
		
		DbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry), (cAliasE),.F.,.F.)

		ConOut('SQL do e-Mail retornou resultado: ' + Time())
		
		xAssunto:= "Resumo Produção - Fabrica de Ração"
		xAnexo  := ""                                           
		xDe     := "protheus@vistalegre.agr.br"             
		xCopia  := ""
		xEmail  := ""
		
		xaDados := {}
		aAdd( xaDados, { "LogoTipo", "\workflow\images\logoM.jpg" } )

		xEmail := ""
		While !(cAliasE)->(Eof())
			
			xEmail  += Iif(Empty(xEmail),"",", ") + alltrim(lower( (cAliasE)->X5_DESCRI)) 
			
			(cAliasE)->(dbSkip())
		EndDo
		
		// xEmail := "miguel.bernardo@vistaalegre.agr.br, arthur.toshio@vistaalegre.agr.br"
		//xEmail += ", miguel.bernardo@vistaalegre.agr.br"
		If !Empty(xEmail)
		
			ConOut("Para: " + xEmail )
			MemoWrite( "C:\totvs_relatorios\VAJOB10.html", xHTM )
			
			Processa({ || u_EnvMail(xEmail	,;			//_cPara
							xCopia 				,;		//_cCc
							""					,;		//_cBCC
							xAssunto			,;		//_cTitulo
							xaDados				,;		//_aAnexo
							xHTM				,;		//_cMsg
							.T.)},"Enviando e-mail...")	//_lAudit
		EndIf
		
		(cAliasE)->(dbCloseArea())
	Else
		ConOut('SQL nao retornou resultado.')
	endif		

ConOut("Fim do Job [VAJOB10]: " + DTOC(DATE()) + ' ' + TIME())

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
