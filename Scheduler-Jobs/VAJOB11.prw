#include "rwmake.ch"
#include "ap5mail.ch"
#include "topconn.ch" 
#include "protheus.ch"
#include "TbiConn.ch"

/*--------------------------------------------------------------------------------,
 | Principal: 					U_VAJOB08()                                       |
 | Func:  fQuadro1()                                                              |
 | Autor: Arthur Toshio														      |
 | Data:  20.05.2019                                                              |
 | Desc:  Job que faz envio de email com a relação de lotes com pendencia de      | 
 |        pendencia de vinculo com curral, e plano Nutricional                    |
 | Regra: 1- Envio todos dias as 12:00 horas;                                     |
 |        2- Envio de 3 dias retroativos;                                         |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function VAJOB11()

	ConOut('VAJOB11(): ' + Time())
	
	If Type("oMainWnd") == "U"
		ConOut('oMainWnd: ' + Time())
		U_RunFunc("U_JOB11VA()",'01','01',3) // Gravar pedido de venda customizado.
	Else
		ConOut('Else oMainWnd: ' + Time())
		U_JOB11VA()
	EndIf
	
	/*
	PREPARE ENVIRONMENT EMPRESA ( '01' ) FILIAL ( '01' ) MODULO "CFG"
	U_JOB11VA()
	RESET ENVIRONMENT
	*/
return nil


User Function JOB11VA()

//Local lEnvia		:= .F.  
Local cJobChv		:= 'JOB11' 	// codigo da chave na tabela da sx5, pra incluir emails para envio do job
Local cJobSX5		:= 'Z2'		// tabela da SX5 onde serao selecionados os emails para envio
Local xHTM 			:= ""  
Local cTelEmp		:= ""
Local aTelEmp		:= ""
Local lImpCab1		:= .T.
Local xaDados		:= {}
// ================================================================
Local _cQry 		:= ""
Local _cAlias		:= GetNextAlias()
Local aAprov		:= {} // Aprovadores

ConOut("[VAJOB11] " + DTOC(DATE()) + ' ' + TIME())

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
xHTM += '<b><font face="Verdana" SIZE=3>Este email apresenta a listagem dos lotes com pendencia de vínculo de Curral e vínculo com Plano Nutricional.</b></p>'
xHTM += '<hr>'
xHTM += '<b><As informações devem ser regularizadas, pois são utilizadas na rotina de Plano de Trato, Cadastro das Notas de Coho</b></p>'
xHTM += '<font face="Verdana" SIZE=3>Data: ' + dtoc(date()) + ' Hora: ' + time() + ' - [VAJOB11]</p>'
xHTM += '<br>'      


_cQry := "  " +CRLF
_cQry += " WITH  " +CRLF
_cQry += "  LOTES  " +CRLF
_cQry += "   AS ( " +CRLF
_cQry += "       SELECT B8_FILIAL, B8_LOTECTL, B8_X_CURRA, SUM(B8_SALDO) B8_SALDO, Z08_TIPO, Z08_LINHA, Z08_SEQUEN " +CRLF
_cQry += "         FROM " + RetSqlName("SB8") + " B8 " +CRLF
_cQry += "    LEFT JOIN " + RetSqlName("Z08") + " Z08 ON " +CRLF
_cQry += "   		     --Z08_FILIAL = B8_FILIAL " +CRLF
_cQry += "       	     Z08_CODIGO = B8_X_CURRA " +CRLF
_cQry += "   	     AND Z08.D_E_L_E_T_ = ' '  " +CRLF
_cQry += "   	   WHERE B8_SALDO > 0 " +CRLF
_cQry += "     GROUP BY B8_FILIAL, B8_LOTECTL, B8_X_CURRA, Z08_TIPO, Z08_LINHA, Z08_SEQUEN " +CRLF
_cQry += " 	) " +CRLF
_cQry += " , PLANO  " +CRLF
_cQry += "     AS ( " +CRLF
_cQry += " 		SELECT DISTINCT L.*, Z0M_CODIGO,  Z0M_DESCRI, Z0O_DIAIN, Z0O_DATAIN, " +CRLF
_cQry += " 		CASE WHEN Z0M_CODIGO IS NULL AND B8_X_CURRA <> ' ' THEN '1-PLANO NUTRICIONAL'  " +CRLF
_cQry += " 		     WHEN Z0M_CODIGO IS NULL AND B8_X_CURRA = ' '  THEN '2-PLANO NUTRICIONAL / CURRAL' " +CRLF
_cQry += " 			 ELSE '3-NORMAL' END PENDENCIA " +CRLF
_cQry += " 		FROM LOTES L  " +CRLF
_cQry += "     LEFT JOIN " + RetSqlName("Z0O") + " Z0O ON " +CRLF
_cQry += "       	     Z0O_FILIAL = L.B8_FILIAL " +CRLF
_cQry += "          AND Z0O.Z0O_LOTE = L.B8_LOTECTL " +CRLF
_cQry += "          AND Z0O.D_E_L_E_T_ = ' '  " +CRLF
_cQry += "    LEFT JOIN " + RetSqlName("Z0M") + " Z0M ON  " +CRLF
_cQry += " 	  	     Z0M.Z0M_FILIAL = Z0O.Z0O_FILIAL " +CRLF
_cQry += " 	     AND Z0M.Z0M_CODIGO = Z0O_CODPLA " +CRLF
_cQry += " 	     AND Z0M.D_E_L_E_T_ = ' '  " +CRLF
_cQry += " 		 ) " +CRLF
_cQry += " 		  " +CRLF
_cQry += " 		 SELECT B8_FILIAL, B8_LOTECTL, B8_X_CURRA, B8_SALDO, PENDENCIA " +CRLF
_cQry += " 		  FROM PLANO " +CRLF
_cQry += " 		 WHERE PENDENCIA <> '3-NORMAL' " +CRLF
_cQry += " 	   ORDER BY PENDENCIA, B8_FILIAL, Z08_TIPO, Z08_LINHA, Z08_SEQUEN " +CRLF

dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.)

If (lImpCab1 := !(_cAlias)->(Eof()) )		// U_VAJOB08()
	xHTM += '<br>'      			
	xHTM += '<br>'
	xHTM += '<b><font face="Verdana" SIZE=1>
	xHTM += '<table width="85%" BORDER=1>'
	xHTM += '	<tr BGCOLOR=#778899 >'
	xHTM += '		<td align=center><b><font color=#F5F5F5>Filial</b></font></td>'
	xHTM += '		<td align=center><b><font color=#F5F5F5>Lote</b></font></td>'
	xHTM += '		<td align=center><b><font color=#F5F5F5>Curral</b></font></td>'
	xHTM += '		<td align=center><b><font color=#F5F5F5>Saldo</b></font></td>'
	xHTM += '		<td align=center><b><font color=#F5F5F5>Pendencia</b></font></td>'
	xHTM += '	</tr>'	
EndIf

While !(_cAlias)->(Eof())

	xHTM += '	<tr>'
	xHTM += '		<td align=left >'+AllTrim((_cAlias)->B8_FILIAL)+'</td>'
	xHTM += '		<td align=left >'+AllTrim((_cAlias)->B8_LOTECTL)+'</td>'
	xHTM += '		<td align=left >'+AllTrim((_cAlias)->B8_X_CURRA)+'</td>'  
	xHTM += '		<td align=center >'+Transform( (_cAlias)->B8_SALDO, X3Picture('B8_SALDO') )+'</td>'
	xHTM += '		<td align=center >'+AllTrim((_cAlias)->PENDENCIA)+'</td>'
	xHTM += '	</tr>'	

	(_cAlias)->(dbSkip())

EndDo           
(_cAlias)->(dbCloseArea())
_cAlias		:= GetNextAlias()

xHTM += '</table>' // fim da tabela de pedidos		
xHTM += '<br>'
xHTM += '</BODY></HTML>'

if lImpCab1 // lEnvia				// a

	xAssunto:= "V@ Protheus - Lotes com pendência de Curral e Plano Nutricional"
	xAnexo  := ""                                           
	xDe     := "protheus@vistalegre.agr.br"             
	xCopia  := ""
	xEmail  := ""
	
	xaDados := {}
	aAdd( xaDados, { "LogoTipo", "\workflow\images\logoM.jpg" } )

	cQuery := " SELECT X5_CHAVE, X5_DESCRI "
	cQuery += " FROM "+RetSqlName('SX5')+" SX5 "
	cQuery += " WHERE X5_TABELA = '"+cJobSX5+ "'"
	cQuery += " AND SUBSTRING(X5_CHAVE,1,5)  = '"+cJobChv+"'  "
	cQuery += " AND D_E_L_E_T_<>'*' "  
	cQuery += " ORDER BY X5_CHAVE "  
	
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, cQuery ),(_cAlias),.F.,.F.)

	xEmail := ""
	While !(_cAlias)->(Eof())
		
		xEmail  += Iif(Empty(xEmail),"",", ") + alltrim(lower( (_cAlias)->X5_DESCRI)) 
		
		(_cAlias)->(dbSkip())
	EndDo
	
	 //xEmail := "arthur.toshio@vistaalegre.agr.br" //"miguel.bernardo@vistaalegre.agr.br" 
	If !Empty(xEmail)
	
		ConOut("Para: " + xEmail )
		MemoWrite( "C:\totvs_relatorios\VAJOB11.html", xHTM )
		
		Processa({ || u_EnvMail(xEmail	,;			//_cPara
						xCopia 				,;		//_cCc
						""					,;		//_cBCC
						xAssunto			,;		//_cTitulo
						xaDados				,;		//_aAnexo
						xHTM				,;		//_cMsg
						.T.)},"Enviando e-mail...")	//_lAudit
	EndIf
	
	(_cAlias)->(dbCloseArea())
Else
	ConOut('SQL nao retornou resultado.')
endif	

ConOut("Fim do Job [VAJOB11]: " + DTOC(DATE()) + ' ' + TIME())

return   



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