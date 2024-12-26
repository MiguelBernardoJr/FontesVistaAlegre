#include "rwmake.ch"
#include "ap5mail.ch"
#include "topconn.ch" 
#include "protheus.ch"

/*--------------------------------------------------------------------------------,
 | Principal: 					U_VAJOB06()                                       |
 | Func:  fQuadro1()                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  25.05.2018                                                              |
 | Desc:  Job que faz envio de email de notas fiscas canceladas:                  |
 |                                                                                |
 | Regra: 1- Envio todos dias as 12:00 horas;                                     |
 |        2- Envio de 3 dias retroativos;                                         |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function VAJOB06()              // U_VAJOB06()

If Type("oMainWnd") == "U"
	U_RunFunc("U_JOB06VA()",'01','01',3) // Gravar pedido de venda customizado.
Else
	U_JOB06VA()
EndIf

Return

User Function JOB06VA()
//Local lEnvia		:= .F.  
Local cJobChv		:= 'JOB06' 	// codigo da chave na tabela da sx5, pra incluir emails para envio do job
Local cJobSX5		:= 'Z2'		// tabela da SX5 onde serao selecionados os emails para envio
Local xHTM 			:= ""  
Local nQtdDias		:= 0 
Local nPedAtra		:= 0
Local nTotAtra		:= 0
Local cTelEmp		:= ""
Local aTelEmp		:= ""
Local lImpCab1		:= .T.
Local lImpCab2		:= .T.
Local cC7Obs		:= ""
Local dDiaDe 		:= MsDate()-GetMV('VA_DIASCAN',,5) // Dias retroativos para envio do email;
Local xaDados		:= {}
Local JOBMAIL		:= GetNextAlias()

// If FindFunction("RPCSETTYPE")
    // RPCSetType(3)
// Endif

// //PREPARE ENVIRONMENT empresa "01" filial "01"  
// RPCSETENV("01","01","","","SIGACOM","vistaalegre",{})

ConOut("[VAJOB06] " + DTOC(DATE()) + ' ' + TIME())

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
xHTM += '<b><font face="Verdana" SIZE=3>Notas Fiscais Canceladas a partir do dia: '+ DTOC(dDiaDe) +' ate a data ATUAL</b></p>'
xHTM += '<hr>'
xHTM += '<font face="Verdana" SIZE=1>* * *  com base no campo data de entrega no item do pedido de compras (somente liberados) * * * [VAJOB06]</p>'
xHTM += '<font face="Verdana" SIZE=3>Data: ' + dtoc(date()) + ' Hora: ' + time() + '</p>'
xHTM += '<br>'      

cQuery := " SELECT  FT_FILIAL, FT_NFISCAL, FT_SERIE, FT_TIPOMOV, FT_EMISSAO, FT_DTCANC, FT_OBSERV,  " + CRLF
cQuery += " 		FT_CLIEFOR, FT_LOJA, A2_NOME, A2_MUN, A2_EST, FT_PRODUTO, B1_DESC,  " + CRLF
cQuery += " 		FT_QUANT, FT_PRCUNIT, FT_TOTAL, FT_BASEICM, FT_VALICM, FT_CHVNFE, " + CRLF
cQuery += " SUBSTRING(F3_USERLGA, 11, 1) + SUBSTRING(F3_USERLGA, 15, 1) + " + CRLF
cQuery += "          SUBSTRING(F3_USERLGA, 2, 1) + SUBSTRING(F3_USERLGA, 6, 1) + " + CRLF
cQuery += "          SUBSTRING(F3_USERLGA, 10, 1) + SUBSTRING(F3_USERLGA, 14, 1) + " + CRLF
cQuery += "          SUBSTRING(F3_USERLGA, 1, 1) + SUBSTRING(F3_USERLGA, 5, 1) + " + CRLF
cQuery += "          SUBSTRING(F3_USERLGA, 9, 1) + SUBSTRING(F3_USERLGA, 13, 1) + " + CRLF
cQuery += "          SUBSTRING(F3_USERLGA, 17, 1) + SUBSTRING(F3_USERLGA, 4, 1) + " + CRLF
cQuery += "          SUBSTRING(F3_USERLGA, 8, 1) Usuario " + CRLF
cQuery += " FROM SFT010  FT  " + CRLF
cQuery += " JOIN SF3010 F3 ON FT_FILIAL+FT_NFISCAL+FT_SERIE=F3_FILIAL+F3_NFISCAL+F3_SERIE  " + CRLF
cQuery += " 					AND FT.D_E_L_E_T_=' ' AND F3.D_E_L_E_T_=' '  " + CRLF
cQuery += " JOIN SA2010 ON  " + CRLF
cQuery += " FT_CLIEFOR = A2_COD " + CRLF
cQuery += " AND FT_LOJA = A2_LOJA  " + CRLF
cQuery += " JOIN SB1010 ON " + CRLF
cQuery += " B1_COD = FT_PRODUTO " + CRLF
cQuery += " WHERE FT_DTCANC >= '" + DtoS(dDiaDe) + "'  " + CRLF
cQuery += " AND SA2010.D_E_L_E_T_ = ' '  " + CRLF
cQuery += " AND FT_FORMUL = 'S' " + CRLF
cQuery += "  " + CRLF
cQuery += " UNION  " + CRLF
cQuery += "  " + CRLF
cQuery += " SELECT  FT_FILIAL, FT_NFISCAL, FT_SERIE, FT_TIPOMOV, FT_EMISSAO, FT_DTCANC, FT_OBSERV,  		 " + CRLF
cQuery += " FT_CLIEFOR, FT_LOJA, A1_NOME, A1_MUN, A1_EST, FT_PRODUTO, B1_DESC,  		 " + CRLF
cQuery += " FT_QUANT, FT_PRCUNIT, FT_TOTAL, FT_BASEICM, FT_VALICM, FT_CHVNFE, " + CRLF
cQuery += " SUBSTRING(F3_USERLGA, 11, 1) + SUBSTRING(F3_USERLGA, 15, 1) + " + CRLF
cQuery += "          SUBSTRING(F3_USERLGA, 2, 1) + SUBSTRING(F3_USERLGA, 6, 1) + " + CRLF
cQuery += "          SUBSTRING(F3_USERLGA, 10, 1) + SUBSTRING(F3_USERLGA, 14, 1) + " + CRLF
cQuery += "          SUBSTRING(F3_USERLGA, 1, 1) + SUBSTRING(F3_USERLGA, 5, 1) + " + CRLF
cQuery += "          SUBSTRING(F3_USERLGA, 9, 1) + SUBSTRING(F3_USERLGA, 13, 1) + " + CRLF
cQuery += "          SUBSTRING(F3_USERLGA, 17, 1) + SUBSTRING(F3_USERLGA, 4, 1) + " + CRLF
cQuery += "          SUBSTRING(F3_USERLGA, 8, 1) Usuario " + CRLF
cQuery += " FROM SFT010  FT  " + CRLF
cQuery += " JOIN SF3010 F3 ON FT_FILIAL+FT_NFISCAL+FT_SERIE=F3_FILIAL+F3_NFISCAL+F3_SERIE  " + CRLF
cQuery += " 					AND FT.D_E_L_E_T_=' ' AND F3.D_E_L_E_T_=' '  " + CRLF
cQuery += "  JOIN SA1010 ON   " + CRLF
cQuery += " 			FT_CLIEFOR	= A1_COD  " + CRLF
cQuery += " 		AND FT_LOJA		= A1_LOJA   " + CRLF
cQuery += "  JOIN SB1010 ON  " + CRLF
cQuery += "  B1_COD = FT_PRODUTO  " + CRLF
cQuery += "  WHERE FT_DTCANC >= '" + DtoS(dDiaDe) + "'  " + CRLF
cQuery += "  AND SA1010.D_E_L_E_T_ = ' '   " + CRLF
cQuery += "  -- AND FT_FORMUL = 'S'  --- formulario proprio " + CRLF
cQuery += " ORDER BY FT_FILIAL, FT_DTCANC, FT_NFISCAL, FT_SERIE "

If Select("TSFT") <> 0
	TSFT->(dbCloseArea())
Endif

TCQuery cQuery Alias "TSFT" New

If (lImpCab1 := !Eof())		// U_VAJOB06()
	xHTM += '<br>'      			
	xHTM += '<br>'
	xHTM += '<b><font face="Verdana" SIZE=1>
	xHTM += '<table width="85%" BORDER=1>'
	xHTM += '	<tr BGCOLOR=#778899 >'
	xHTM += '		<td Width=250><b><font color=#F5F5F5>Filial/Nota/Serie</b></font></td>'
	xHTM += '		<td Width=58 ><b><font color=#F5F5F5>Tp. Movim.</b></font></td>'
	xHTM += '		<td Width=80 ><b><font color=#F5F5F5>Dt. Emissão</b></font></td>'
	xHTM += '		<td Width=75 ><b><font color=#F5F5F5>Dt. Cancelamento</b></font></td>'
	xHTM += '		<td Width=80 ><b><font color=#F5F5F5>Usuario</b></font></td>'
	xHTM += '		<td Width=166><b><font color=#F5F5F5>Observação</b></font></td>'
	xHTM += '		<td Width=300><b><font color=#F5F5F5>Cliente/Fornec./Loja-Nome</b></font></td>'
	xHTM += '		<td Width=269><b><font color=#F5F5F5>Municipio</b></font></td>'
	xHTM += '		<td Width=49 ><b><font color=#F5F5F5>Estado</b></font></td>'
	xHTM += '		<td Width=176><b><font color=#F5F5F5>Produto</b></font></td>'
	xHTM += '		<td Width=537><b><font color=#F5F5F5>Descrição</b></font></td>'
	xHTM += '		<td Width=71 ><b><font color=#F5F5F5>Quant</b></font></td>'
	xHTM += '		<td Width=79 ><b><font color=#F5F5F5>Preço Unit.</b></font></td>'
	xHTM += '		<td Width=64 ><b><font color=#F5F5F5>Total</b></font></td>'
	xHTM += '		<td Width=80 ><b><font color=#F5F5F5>Base ICMS</b></font></td>'
	xHTM += '		<td Width=72 ><b><font color=#F5F5F5>R$ ICMS</b></font></td>'
	xHTM += '		<td Width=100><b><font color=#F5F5F5>Chave</b></font></td>'
	xHTM += '	</tr>'	
EndIf

While !Eof()

	xHTM += '	<tr>'
	xHTM += '		<td Width=60  align=left >'+AllTrim(TSFT->FT_FILIAL)+AllTrim(TSFT->FT_NFISCAL)+AllTrim(TSFT->FT_SERIE)+'</td>'
	xHTM += '		<td Width=58  align=left >'+iif(TSFT->FT_TIPOMOV=="E","Entrada","Saida")+'</td>'
	xHTM += '		<td Width=80  align=left >'+SUBSTR(TSFT->FT_EMISSAO,7,2)+'/'+SUBSTR(TSFT->FT_EMISSAO,5,2)+'/'+SUBSTR(TSFT->FT_EMISSAO,1,4)+'</td>'
	xHTM += '		<td Width=75  align=left >'+SUBSTR(TSFT->FT_DTCANC,7,2)+'/'+SUBSTR(TSFT->FT_DTCANC,5,2)+'/'+SUBSTR(TSFT->FT_DTCANC,1,4)+'</td>'
	xHTM += '		<td Width=80  align=left >'+AllTrim( UsrRetName(TSFT->Usuario) )+'</td>'
	xHTM += '		<td Width=166 align=left >'+AllTrim(TSFT->FT_OBSERV)+'</td>'
	xHTM += '		<td Width=300 align=left >'+AllTrim(TSFT->FT_CLIEFOR)+AllTrim(TSFT->FT_LOJA)+'-'+AllTrim(TSFT->A2_NOME)+'</td>'
	xHTM += '		<td Width=269 align=left >'+AllTrim(TSFT->A2_MUN)+'</td>'
	xHTM += '		<td Width=49  align=left >'+AllTrim(TSFT->A2_EST)+'</td>'
	xHTM += '		<td Width=176 align=left >'+AllTrim(TSFT->FT_PRODUTO)+'</td>'
	xHTM += '		<td Width=537 align=left >'+AllTrim(TSFT->B1_DESC)+'</td>'
	xHTM += '		<td Width=71  align=right>'+StrTran(Transform(TSFT->FT_QUANT 	, X3Picture('FT_QUANT'	 )	),",00","")+'</td>'
	xHTM += '		<td Width=79  align=right>'+Transform(TSFT->FT_PRCUNIT 	, X3Picture('FT_PRCUNIT' )  )+'</td>'
	xHTM += '		<td Width=64  align=right>'+Transform(TSFT->FT_TOTAL 	, X3Picture('FT_TOTAL'	 )  )+'</td>'
	xHTM += '		<td Width=80  align=right>'+Transform(TSFT->FT_BASEICM 	, X3Picture('FT_BASEICM' )  )+'</td>'
	xHTM += '		<td Width=72  align=right>'+Transform(TSFT->FT_VALICM 	, X3Picture('FT_VALICM'  )  )+'</td>'
	xHTM += '		<td Width=100  align=right>'+AllTrim(TSFT->FT_CHVNFE) +'</td>'
	xHTM += '	</tr>'	


	TSFT->(dbSkip())

EndDo           
xHTM += '</table>' // fim da tabela de pedidos		
xHTM += '<br>'
xHTM += '</BODY></HTML>'

if lImpCab1 // lEnvia				// U_VAJOB06()

	xAssunto:= "Protheus Schedule - Notas Fiscais Canceladas"
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
	
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, cQuery ),(JOBMAIL),.F.,.F.)

	xEmail := ""
	While !(JOBMAIL)->(Eof())
		
		xEmail  += Iif(Empty(xEmail),"",", ") + alltrim(lower( (JOBMAIL)->X5_DESCRI)) 
		
		(JOBMAIL)->(dbSkip())
	EndDo
	
	// xEmail := "miguel.bernardo@vistaalegre.agr.br" // , arthur.toshio@vistaalegre.agr.br"
	If !Empty(xEmail)
	
		ConOut("Para: " + xEmail )
		MemoWrite( "C:\totvs_relatorios\VAJOB06.html", xHTM )
		
		Processa({ || u_EnvMail(xEmail	,;			//_cPara
						xCopia 				,;		//_cCc
						""					,;		//_cBCC
						xAssunto			,;		//_cTitulo
						xaDados				,;		//_aAnexo
						xHTM				,;		//_cMsg
						.T.)},"Enviando e-mail...")	//_lAudit
	EndIf
	
	(JOBMAIL)->(dbCloseArea())
Else
	ConOut('SQL nao retornou resultado.')
endif	

// SET FILTER TO

ConOut("Fim do Job [VAJOB06]: " + DTOC(DATE()) + ' ' + TIME())

// RPCCLEARENV()

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