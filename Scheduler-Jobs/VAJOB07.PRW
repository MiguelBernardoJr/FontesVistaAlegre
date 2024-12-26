#include "rwmake.ch"
#include "ap5mail.ch"
#include "topconn.ch" 
#include "protheus.ch"

/*--------------------------------------------------------------------------------,
 | Principal: 					U_VAJOB07()                                       |
 | Func:  fQuadro1()                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  25.05.2018                                                              |
 | Desc:  Job que faz envio de email das solicitacoes nao aprovadas               |
 |                                                                                |
 | Regra: 1- Envio todos dias as 12:00 horas;                                     |
 |        2- Envio de 3 dias retroativos;                                         |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function VAJOB07()              // U_VAJOB07()

If Type("oMainWnd") == "U"
	U_RunFunc("U_JOB07VA()",'01','01',3) // Gravar pedido de venda customizado.
Else
	U_JOB07VA()
EndIf

Return

User Function JOB07VA()
//Local lEnvia		:= .F.  
Local cJobChv		:= 'JOB07' 	// codigo da chave na tabela da sx5, pra incluir emails para envio do job
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

ConOut("[VAJOB07] " + DTOC(DATE()) + ' ' + TIME())

_cQry := " SELECT	Z0A_USERID, Z0A_NOME, CONVERT(INT,Z0A_SEQ) Z0A_SEQ
_cQry += " FROM		Z0A010 
_cQry += " WHERE	Z0A_FILIAL=' ' AND Z0A_MSBLQL<>'1' AND D_E_L_E_T_= ' '

dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.)

While !(_cAlias)->(Eof())
	aAdd( aAprov, { (_cAlias)->Z0A_USERID, (_cAlias)->Z0A_NOME, (_cAlias)->Z0A_SEQ } )	
	(_cAlias)->(dbSkip())
EndDo
(_cAlias)->(dbCloseArea())
_cAlias		:= GetNextAlias()

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
xHTM += '<b><font face="Verdana" SIZE=3>Todas as Solicitações pendentes de liberação pelos aprovadores</b></p>'
xHTM += '<hr>'
xHTM += '<font face="Verdana" SIZE=1>* * *  com base nas solicitações de compras (Tabela SC1) * * * [VAJOB07]</p>'
xHTM += '<font face="Verdana" SIZE=3>Data: ' + dtoc(date()) + ' Hora: ' + time() + '</p>'
xHTM += '<br>'      


_cQry := " SELECT " + CRLF
 _cQry += " 	C1_FILIAL, C1_NUM, C1_ITEM, C1_PRODUTO, C1_DESCRI, C1_QUANT-C1_QUJE QT_PENDENTE, C1_CC, C1_ITEMCTA, C1_OBS, C1_EMISSAO, C1_SOLICIT, " + CRLF
_cQry += "  C1_XAPROV, C1_DATPRF -- , C1_APROV, C1_NOMAPRO " + CRLF
_cQry += " FROM SC1010  " + CRLF
_cQry += " WHERE	D_E_L_E_T_=' ' " + CRLF
_cQry += " 	AND C1_APROV <> 'L' " + CRLF
_cQry += " 	AND C1_QUJE < C1_QUANT " + CRLF
_cQry += " 	AND C1_EMISSAO >= '20180801' " + CRLF // COMECAMOS NESSA DATA, IGNORANDO SOLICITACOES ANTERIORES;
_cQry += " ORDER BY C1_FILIAL, C1_NUM DESC, C1_ITEM " + CRLF
dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.)

If (lImpCab1 := !(_cAlias)->(Eof()) )		// U_VAJOB07()
	xHTM += '<br>'      			
	xHTM += '<br>'
	xHTM += '<b><font face="Verdana" SIZE=1>
	xHTM += '<table width="85%" BORDER=1>'
	xHTM += '	<tr BGCOLOR=#778899 >'
	xHTM += '		<td align=center><b><font color=#F5F5F5>Filial/Pedido/Item</b></font></td>'
	xHTM += '		<td align=center><b><font color=#F5F5F5>Codigo/Descricao do Produto</b></font></td>'
	xHTM += '		<td align=center><b><font color=#F5F5F5>Qtd. Pendente</b></font></td>'
	xHTM += '		<td align=center><b><font color=#F5F5F5>Dt. Emissão</b></font></td>'
	xHTM += '		<td align=center><b><font color=#F5F5F5>Dt. Prev. Necessidade</b></font></td>'
	xHTM += '		<td align=center><b><font color=#F5F5F5>C. Custo</b></font></td>'
	xHTM += '		<td align=center><b><font color=#F5F5F5>Item Conta</b></font></td>'
	xHTM += '		<td align=center><b><font color=#F5F5F5>Solicitante</b></font></td>'
	xHTM += '		<td align=center><b><font color=#F5F5F5>Aprov. Pendentes</b></font></td>'
	xHTM += '		<td align=center><b><font color=#F5F5F5>Observação</b></font></td>'
	xHTM += '	</tr>'	
EndIf

While !(_cAlias)->(Eof())

	xHTM += '	<tr>'
	xHTM += '		<td align=left >'+AllTrim((_cAlias)->C1_FILIAL)+"-"+AllTrim((_cAlias)->C1_NUM)+"-"+AllTrim((_cAlias)->C1_ITEM)+'</td>'
	xHTM += '		<td align=left >'+AllTrim((_cAlias)->C1_PRODUTO)+"-"+AllTrim((_cAlias)->C1_DESCRI)+'</td>'
	xHTM += '		<td align=right>'+Transform( (_cAlias)->QT_PENDENTE, X3Picture('C1_QUANT') )+'</td>'
	xHTM += '		<td align=left >'+dToC( stod((_cAlias)->C1_EMISSAO) ) +'</td>'
	xHTM += '		<td align=left >'+dToC( stod((_cAlias)->C1_DATPRF) ) +'</td>'
	xHTM += '		<td align=left >'+AllTrim((_cAlias)->C1_CC)+'</td>'
	xHTM += '		<td align=left >'+AllTrim((_cAlias)->C1_ITEMCTA)+'</td>'
	xHTM += '		<td align=left >'+AllTrim((_cAlias)->C1_SOLICIT)+'</td>'
	xHTM += '		<td align=left >'+ProcAprovador(aAprov, (_cAlias)->C1_XAPROV)+'</td>'
	xHTM += '		<td align=left >'+AllTrim((_cAlias)->C1_OBS)+'</td>'
	xHTM += '	</tr>'	

	(_cAlias)->(dbSkip())

EndDo           
(_cAlias)->(dbCloseArea())
_cAlias		:= GetNextAlias()

xHTM += '</table>' // fim da tabela de pedidos		
xHTM += '<br>'
xHTM += '</BODY></HTML>'

if lImpCab1 // lEnvia				// U_VAJOB07()

	xAssunto:= "Protheus Schedule - Solicitações não aprovadas"
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
		MemoWrite( "C:\totvs_relatorios\VAJOB07.html", xHTM )
		
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

ConOut("Fim do Job [VAJOB07]: " + DTOC(DATE()) + ' ' + TIME())

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

/* 
	MJ : 14.08.2018
		=> Processa campo customizado dos aprovadores; 
*/
Static Function ProcAprovador(aAprov, xAprov)
Local cRet 	:= ""
Local nI	:= ""

For nI := 1 to Len( aAprov )
	If SubS( xAprov, aAprov[ nI, 3 ], 1 ) <> "L"
		cRet += Iif( Empty(cRet),"",", ") + AllTrim( aAprov[ nI, 2 ] )
	EndIf
Next nI

Return cRet
