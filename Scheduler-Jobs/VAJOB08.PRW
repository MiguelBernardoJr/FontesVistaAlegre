#include "rwmake.ch"
#include "ap5mail.ch"
#include "topconn.ch" 
#include "protheus.ch"

/*--------------------------------------------------------------------------------,
 | Principal: 					U_VAJOB08()                                       |
 | Func:  fQuadro1()                                                              |
 | Autor: Arthur Toshio														      |
 | Data:  25.05.2018                                                              |
 | Desc:  Job que faz envio de email com a relação de lotes faturados sem         | 
 |        informação de peso de saída                                          |
 | Regra: 1- Envio todos dias as 12:00 horas;                                     |
 |        2- Envio de 3 dias retroativos;                                         |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function VAJOB08()              // U_VAJOB08()

If Type("oMainWnd") == "U"
	U_RunFunc("U_JOB08VA()",'01','01',3) // Gravar pedido de venda customizado.
Else
	U_JOB08VA()
EndIf

Return

User Function JOB08VA()
//Local lEnvia		:= .F.  
Local cJobChv		:= 'JOB08' 	// codigo da chave na tabela da sx5, pra incluir emails para envio do job
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

ConOut("[VAJOB08] " + DTOC(DATE()) + ' ' + TIME())


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
xHTM += '<b><font face="Verdana" SIZE=3>Todas as NFs de venda sem peso de saída</b></p>'
xHTM += '<hr>'
xHTM += '<font face="Verdana" SIZE=1>* * *  Com base nas notas fiscais de venda sem preenchimento de Peso de Saída e Data de abate * * * [VAJOB08]</p>'
xHTM += '<font face="Verdana" SIZE=3>Data: ' + dtoc(date()) + ' Hora: ' + time() + '</p>'
xHTM += '<br>'      


_cQry := "    " +CRLF
_cQry += "  SELECT D2_FILIAL,  D2_DOC, D2_SERIE, D2_EMISSAO, D2_LOTECTL, B1_DESC, SUM(D2_QUANT) D2_QUANT, D2_XDTABAT, D2_XPESLIQ  " +CRLF
_cQry += "  FROM SD2010 D2  " +CRLF
_cQry += "  JOIN SB1010 B1 ON  " +CRLF
_cQry += "  B1_FILIAL = ' ' AND  " +CRLF
_cQry += "  B1_COD = D2_COD AND  " +CRLF
_cQry += "  B1.D_E_L_E_T_ = ' '   " +CRLF
_cQry += "  WHERE D2_GRUPO IN ('01','05','BOV')  " +CRLF
_cQry += "  AND D2.D_E_L_E_T_ = ' '   " +CRLF
_cQry += "  AND D2_CLIENTE = '000001'  " +CRLF
_cQry += "  AND D2_EMISSAO >= '20180801'-- AND '20181017'  " +CRLF
_cQry += "  AND D2_XPESLIQ = ' '   " +CRLF
_cQry += "  AND D2_XDTABAT = ' '   " +CRLF
_cQry += "  AND D2_TIPO = 'N'  " +CRLF
_cQry += "  GROUP BY D2_FILIAL,  D2_DOC, D2_SERIE, D2_EMISSAO, B1_DESC, D2_LOTECTL,  D2_XDTABAT, D2_XPESLIQ  " +CRLF
_cQry += "  ORDER BY D2_FILIAL, D2_EMISSAO DESC  " +CRLF
dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.)

If (lImpCab1 := !(_cAlias)->(Eof()) )		// U_VAJOB08()
	xHTM += '<br>'      			
	xHTM += '<br>'
	xHTM += '<b><font face="Verdana" SIZE=1>
	xHTM += '<table width="85%" BORDER=1>'
	xHTM += '	<tr BGCOLOR=#778899 >'
	xHTM += '		<td align=center><b><font color=#F5F5F5>Filial</b></font></td>'
	xHTM += '		<td align=center><b><font color=#F5F5F5>Nota Fiscal</b></font></td>'
	xHTM += '		<td align=center><b><font color=#F5F5F5>Série</b></font></td>'
	xHTM += '		<td align=center><b><font color=#F5F5F5>Dt Emissão</b></font></td>'
	xHTM += '		<td align=center><b><font color=#F5F5F5>Lote (Baia)</b></font></td>'
	xHTM += '		<td align=center><b><font color=#F5F5F5>Descrição</b></font></td>'
	xHTM += '		<td align=center><b><font color=#F5F5F5>Quantidade</b></font></td>'
	xHTM += '		<td align=center><b><font color=#F5F5F5>Data de Abate</b></font></td>'
	xHTM += '		<td align=center><b><font color=#F5F5F5>Peso Liquido</b></font></td>'
	xHTM += '	</tr>'	
EndIf

While !(_cAlias)->(Eof())

	xHTM += '	<tr>'
	xHTM += '		<td align=left >'+AllTrim((_cAlias)->D2_FILIAL)+'</td>'
	xHTM += '		<td align=left >'+AllTrim((_cAlias)->D2_DOC)+'</td>'
	xHTM += '		<td align=left >'+AllTrim((_cAlias)->D2_SERIE)+'</td>'
	xHTM += '		<td align=left >'+dToC( stod((_cAlias)->D2_EMISSAO) ) +'</td>'
	xHTM += '		<td align=left >'+AllTrim((_cAlias)->D2_LOTECTL)+'</td>'
	xHTM += '		<td align=left >'+AllTrim((_cAlias)->B1_DESC)+'</td>'
	xHTM += '		<td align=right>'+Transform( (_cAlias)->D2_QUANT, X3Picture('D2_QUANT') )+'</td>'	
	xHTM += '		<td align=left >'+dToC( stod((_cAlias)->D2_XDTABAT) ) +'</td>'
	xHTM += '		<td align=right>'+Transform( (_cAlias)->D2_XPESLIQ, X3Picture('D2_QUANT') )+'</td>'
	xHTM += '	</tr>'	

	(_cAlias)->(dbSkip())

EndDo           
(_cAlias)->(dbCloseArea())
_cAlias		:= GetNextAlias()

xHTM += '</table>' // fim da tabela de pedidos		
xHTM += '<br>'
xHTM += '</BODY></HTML>'

if lImpCab1 // lEnvia				// U_VAJOB08()

	xAssunto:= "Saída de Animais sem peso de Saída"
	xAnexo  := ""                                           
	xDe     := "protheus@vistalegre.agr.br"             
	xCopia  := ""
	xEmail  := ""
	
	xaDados := {}
	aAdd( xaDados, { "LogoTipo", "\workflow\images\logoM.jpg" } )

	cQuery := " SELECT X5_CHAVE, X5_DESCRI "
	cQuery += " FROM "+RetSqlName('SX5')+" SX5 "
	cQuery += " WHERE X5_TABELA = '"+cJobSX5+"' "
	cQuery += " AND SUBSTRING(X5_CHAVE,1,5)  = '"+cJobChv+"'  "
	cQuery += " AND D_E_L_E_T_<>'*' "  
	cQuery += " ORDER BY X5_CHAVE "  
	
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, cQuery ),(_cAlias),.F.,.F.)

	xEmail := ""
	While !(_cAlias)->(Eof())
		
		xEmail  += Iif(Empty(xEmail),"",", ") + alltrim(lower( (_cAlias)->X5_DESCRI)) 
		
		(_cAlias)->(dbSkip())
	EndDo
	
	// xEmail := "miguel.bernardo@vistaalegre.agr.br" // , arthur.toshio@vistaalegre.agr.br"
	If !Empty(xEmail)
	
		ConOut("Para: " + xEmail )
		MemoWrite( "C:\totvs_relatorios\VAJOB08.html", xHTM )
		
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

ConOut("Fim do Job [VAJOB08]: " + DTOC(DATE()) + ' ' + TIME())

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
