#include "rwmake.ch"
#include "ap5mail.ch"
#include "topconn.ch" 
#include "protheus.ch"
#include "TbiConn.ch"

/*---------------------------------------------------------------------------------, 
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 31.12.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Enviar Titulos com adiantamento em aberto;                           |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '---------------------------------------------------------------------------------*/
User Function VAJOB12()

	ConOut('VAJOB12(): ' + Time())
	
	If Type("oMainWnd") == "U"
		ConOut('oMainWnd: ' + Time())
		U_RunFunc("U_JOB12VA()",'01','01',3) // Gravar pedido de venda customizado.
	Else
		ConOut('Else oMainWnd: ' + Time())
		U_JOB12VA()
	EndIf
	
return nil


User Function JOB12VA()

//Local lEnvia		:= .F.  
Local cJobChv		:= 'JOB12' 	// codigo da chave na tabela da sx5, pra incluir emails para envio do job
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

ConOut("[VAJOB12] " + DTOC(DATE()) + ' ' + TIME())

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
xHTM += '<b><font face="Verdana" SIZE=3>Este email apresenta uma listagem de Adiantamentos (A Pagar) em aberto e fornecedor com saldo de título a pagar.</b></p>'
xHTM += '<br>'      
xHTM += '<b><font face="Verdana" SIZE=2>Verificar a última Coluna "Saldo Tit." se o mesmo fornecedor possui saldo a ser compensado.</b></p>'
xHTM += '<font face="Verdana" SIZE=3>Data: ' + dtoc(date()) + ' Hora: ' + time() + ' - [VAJOB12]</p>'
xHTM += '<br>'      



_cQry := "SELECT * " + CRLF +;
		 " FROM ( " + CRLF +;
		 " 	SELECT E2_FILIAL, E2_PREFIXO, E2_TIPO, E2_NUM, E2_NATUREZ, E2_FORNECE,  " + CRLF +;
		 " 				E2_LOJA, A2_NOME, E2_EMISSAO, E2_VENCTO, E2_HIST, E2_VALOR, E2_SALDO, " + CRLF +;
		 " 				ISNULL((SELECT SUM(E2P.E2_SALDO)  " + CRLF +;
		 " 						FROM SE2010 E2P  " + CRLF +;
		 " 						WHERE E2P.E2_FILIAL+E2P.E2_FORNECE+E2P.E2_LOJA = E2.E2_FILIAL+E2.E2_FORNECE+E2.E2_LOJA  " + CRLF +;
		 " 						  AND E2_SALDO > 0 AND E2P.D_E_L_E_T_ = ' '  " + CRLF +;
		 " 						  AND E2.E2_PREFIXO <> 'ADT'  " + CRLF +;
		 " 						  AND E2.E2_TIPO <> 'PA' ),0) SALDO_TIT " + CRLF +;
		 " 		   FROM SE2010 E2 " + CRLF +;
		 " 		   JOIN SA2010 A2 ON A2_FILIAL = ' ' AND A2_COD+A2_LOJA = E2_FORNECE+E2_LOJA AND A2.D_E_L_E_T_ = ' '  " + CRLF +;
		 " 		  WHERE E2_TIPO = 'PA'  " + CRLF +;
		 " 			AND E2_SALDO > 0  " + CRLF +;
		 " 			AND E2.D_E_L_E_T_ = ' '  " + CRLF +;
		 " ) DADOS " + CRLF +;
		 " ORDER BY CONVERT(DATE, E2_VENCTO) "

dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.)

If (lImpCab1 := !(_cAlias)->(Eof()) )		// U_VAJOB08()
	xHTM += '<br>'      			
	xHTM += '<br>'
	xHTM += '<b><font face="Verdana" SIZE=1>'
	xHTM += '<table width="85%" BORDER=1>'
	xHTM += '	<tr BGCOLOR=#778899 >'
	xHTM += '		<td align=center><b><font color=#F5F5F5>Filial</b></font></td>'
	xHTM += '		<td align=center><b><font color=#F5F5F5>Prefixo</b></font></td>'
	xHTM += '		<td align=center><b><font color=#F5F5F5>Tipo</b></font></td>'
	xHTM += '		<td align=center><b><font color=#F5F5F5>Num</b></font></td>'
	xHTM += '		<td align=center><b><font color=#F5F5F5>Natureza</b></font></td>'
	xHTM += '		<td align=center><b><font color=#F5F5F5>Fornecedor-Loja</b></font></td>'
	xHTM += '		<td align=center><b><font color=#F5F5F5>Emissao</b></font></td>'
	xHTM += '		<td align=center><b><font color=#F5F5F5>Vencimento</b></font></td>'
	xHTM += '		<td align=center><b><font color=#F5F5F5>Historico</b></font></td>'
	xHTM += '		<td align=center><b><font color=#F5F5F5>Valor ADT</b></font></td>'
	xHTM += '		<td align=center><b><font color=#F5F5F5>Saldo ADT</b></font></td>'
	xHTM += '		<td align=center><b><font color=#F5F5F5>Saldo Tit.</b></font></td>'
	xHTM += '	</tr>'	
EndIf

While !(_cAlias)->(Eof()) // U_VAJOB12()

	xHTM += '	<tr>'
	xHTM += '		<td align=left>'+AllTrim((_cAlias)->E2_FILIAL)+'</td>'
	xHTM += '		<td align=left>'+AllTrim((_cAlias)->E2_PREFIXO)+'</td>'
	xHTM += '		<td align=left>'+AllTrim((_cAlias)->E2_TIPO)+'</td>'  
	xHTM += '		<td align=left>'+AllTrim((_cAlias)->E2_NUM)+'</td>'  
	xHTM += '		<td align=left>'+AllTrim((_cAlias)->E2_NATUREZ)+'</td>'  
	xHTM += '		<td align=left>'+AllTrim((_cAlias)->E2_FORNECE)+'/'+AllTrim((_cAlias)->E2_LOJA)+': '+AllTrim((_cAlias)->A2_NOME)+'</td>'
	xHTM += '		<td align=center>'+dToC( stod((_cAlias)->E2_EMISSAO) ) +'</td>'
	xHTM += '		<td align=center>'+dToC( stod((_cAlias)->E2_VENCTO ) ) +'</td>'
	xHTM += '		<td align=center>'+AllTrim((_cAlias)->E2_HIST)+'</td>'
	xHTM += '		<td align=center>'+Transform( (_cAlias)->E2_VALOR, X3Picture('E2_VALOR') )+'</td>'
	xHTM += '		<td align=center>'+Transform( (_cAlias)->E2_SALDO, X3Picture('E2_SALDO') )+'</td>'
	xHTM += '		<td align=center>'+Transform( (_cAlias)->SALDO_TIT, X3Picture('E2_SALDO') )+'</td>'
	xHTM += '	</tr>'	

	(_cAlias)->(dbSkip())

EndDo           
(_cAlias)->(dbCloseArea())
_cAlias		:= GetNextAlias()

xHTM += '</table>' // fim da tabela de pedidos		
xHTM += '<br>'
xHTM += '</BODY></HTML>'

if lImpCab1 // lEnvia				// a

	xAssunto:= "V@ Protheus - Adiantamentos em Aberto"
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
		MemoWrite( "C:\totvs_relatorios\VAJOB12.html", xHTM )
		
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

ConOut("Fim do Job [VAJOB12]: " + DTOC(DATE()) + ' ' + TIME())

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