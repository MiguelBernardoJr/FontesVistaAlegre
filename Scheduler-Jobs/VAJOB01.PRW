#include "rwmake.ch"
#include "ap5mail.ch"
#include "topconn.ch" 
#include "protheus.ch"

/*                  
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VAJOB01   ¦ Autor ¦ Henrique Magalhaes   ¦ Data ¦ 07/10/11 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Job para informar por e-mail Titulos a Pagar Pendentes     ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ Scheduler                                           		  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
       

//Tarefa JOB para enviar e-mail com a relacao de titulos a pagar pendentes (em atraso)

User Function VAJOB01()             

Local lEnvia		:= .F.
Local xHTM 			:= ""  
Local nTitVlr		:= 0 
Local nTitSld		:= 0 
Local nTotVlr		:= 0
Local nTotSld		:= 0
Local nProtVlr		:= 0
Local nProtSld		:= 0
Local nNCCVlr		:= 0
Local nNCCSld		:= 0
Local cCliente		:= ""
Local nQtdDias		:= 0 
Local aDados		:= ""

//if FindFunction("RPCSETTYPE")
//    RPCSetType(3)
//endif

//PREPARE ENVIRONMENT empresa "01" filial "01"  

//RPCSETENV("01","01","","","SIGAFIN","VASCHED",{})

Qout("Verificando Fornecedores X Titulos em Atraso "+DTOC(DATE())+' '+TIME())

//dbSelectArea("SM0")
//dbSeek("0101", .T. )  


xHTM := '<HTML><BODY>'
xHTM += '<hr>'
xHTM += '<p  style="word-spacing: 0; line-height: 100%; margin-top: 0; margin-bottom: 0">'
xHTM += '<b><font face="Verdana" SIZE=3>' + SM0->M0_NOMECOM + '</b></p>'
xHTM += '<br>'                                                                                            
xHTM += '<font face="Verdana" SIZE=3>'+Alltrim( SM0->M0_ENDENT )+" - "+Alltrim(SM0->M0_BAIRENT)+" - CEP: "+alltrim(SM0->M0_CEPENT)+" - Fone/Fax ("+Substr(SM0->M0_TEL,4,2)+") "+Substr(SM0->M0_TEL,7,4)+"-"+Substr(SM0->M0_TEL,11,4) + '</p>'
xHTM += '<hr>'
xHTM += '<b><font face="Verdana" SIZE=3>Titulos a Pagar em atraso (maior que 3 dias apos vencimento real)</b></p>'
//xHTM += '<hr>'
//xHTM += '<font face="Verdana" SIZE=3>* * *  E-MAIL ENVIADO EM FASE DE TESTE (REALIZEM A ANÁLISE DOS TITULOS GERADOS) * * *</p>'
xHTM += '<font face="Verdana" SIZE=3>Data: ' + dtoc(date()) + ' Hora: ' + time() + '</p>'
xHTM += '<br>'	
xHTM += '<br>'      

xHTM += '<b><font face="Verdana" SIZE=1>
xHTM += '<table BORDER=1>'
xHTM += '<tr BGCOLOR=#191970 >'
xHTM += '<td Width= 4%><b><font color=#F5F5F5>Filial</b></font></td>'
xHTM += '<td Width=15%><b><font color=#F5F5F5>Prx\Titulo\Tipo\Parcela</b></font></td>'
xHTM += '<td Width=08%><b><font color=#F5F5F5>Emissao</b></font></td>'
xHTM += '<td Width=08%><b><font color=#F5F5F5>Vencimento</b></font></td>'
xHTM += '<td Width=05%><b><font color=#F5F5F5>Dias</b></font></td>'
xHTM += '<td Width=10%><b><font color=#F5F5F5>Valor Original</b></font></td>'
xHTM += '<td Width=10%><b><font color=#F5F5F5>Saldo do Titulo</b></font></td>'
xHTM += '<td Width=40%><b><font color=#F5F5F5>Fornecedor</b></font></td>
xHTM += '</tr>'	


cQuery := " SELECT E2_FILIAL, E2_PREFIXO, E2_NUM, E2_TIPO, E2_PARCELA, E2_FORNECE, E2_LOJA, E2_EMISSAO, E2_VENCREA, E2_VALOR, E2_SALDO, A2_NOME, A2_MUN, A2_EST, E2_NATUREZ "
cQuery += " FROM "+RetSqlName('SE2')+" SE2 "
cQuery += " LEFT JOIN "+RetSqlName('SA2')+" SA2 ON (A2_FILIAL='' AND E2_FORNECE=A2_COD AND E2_LOJA=A2_LOJA  AND SA2.D_E_L_E_T_<>'*') "
cQuery += " WHERE "
cQuery += " E2_SALDO > 0 AND E2_VENCREA < '"+ dtos(date()-3) +"' " 
cQuery += " AND E2_VENCREA >= '' " //AND E2_TIPO<>'PA' "
cQuery += " AND SE2.D_E_L_E_T_<>'*' "
cQuery += " ORDER BY E2_VENCREA, E2_NATUREZ, E2_FORNECE, E2_LOJA, E2_FILIAL, E2_PREFIXO, E2_NUM, E2_TIPO, E2_PARCELA, E2_EMISSAO  "


If Select("TSE2") <> 0
	TSE2->(dbCloseArea())
Endif

TCQuery cQuery Alias "TSE2" New

dbSelectArea("TSE2")
dbGotop()
// mudar ordem por data e natureza
cCliente := TSE2->E2_FORNECE+TSE2->E2_LOJA
cCliNome := ALLTRIM(TSE2->A2_NOME)
While !Eof()              
	If !(Alltrim(TSE2->E2_TIPO)$"NDF;PA") //.and. !(TSE1->E1_SITUACA$"5;6;7;F;G;H;")
		nTotVlr		+= TSE2->E2_VALOR 
		nTotSld     += TSE2->E2_SALDO
		nTitVlr		+= TSE2->E2_VALOR
		nTitSld		+= TSE2->E2_SALDO
		nQtdDias    := DDATABASE - STOD(TSE2->E2_VENCREA) 	
		xHTM += '<tr>'
		xHTM += '<td Width=4%>'+TSE2->E2_FILIAL+'</td>'
		xHTM += '<td Width=15%>'+TSE2->E2_PREFIXO+'\'+TSE2->E2_NUM+'\'+TSE2->E2_TIPO+IIF(!EMPTY(TSE2->E2_PARCELA),'\'+TSE2->E2_PARCELA,"")+'</td>'
		xHTM += '<td Width=08%>'+SUBSTR(TSE2->E2_EMISSAO,7,2)+'/'+SUBSTR(TSE2->E2_EMISSAO,5,2)+'/'+SUBSTR(TSE2->E2_EMISSAO,1,4)+'</td>'
		xHTM += '<td Width=08%>'+SUBSTR(TSE2->E2_VENCREA,7,2)+'/'+SUBSTR(TSE2->E2_VENCREA,5,2)+'/'+SUBSTR(TSE2->E2_VENCREA,1,4)+'</td>'
		xHTM += '<td Width=05% align=right>'+Transform(nQtdDias ,"@E 999,999")+'</td>'
		xHTM += '<td Width=10% align=right>'+Transform(TSE2->E2_VALOR,"@E 999,999,999.99")+'</td>'
		xHTM += '<td Width=10% align=right>'+Transform(TSE2->E2_SALDO,"@E 999,999,999.99")+'</td>'
		xHTM += '<td Width=40% align=left>'+TSE2->E2_FORNECE + "-" + TSE2->E2_LOJA + "  " + ALLTRIM(TSE2->A2_NOME) + '</td>
		xHTM += '</tr>'	
	   	lEnvia:= .T.
	EndIf

    TSE2->(dbSkip())

   	If cCliente <> TSE2->E2_FORNECE+TSE2->E2_LOJA .or. TSE2->(EOF()) 
   		If nTitSld>0
			xHTM += '<tr BGCOLOR=#CFCFCF >' // gray 81
			xHTM += '<td colspan="5" Width=40%><b>Sub-Total Fornecedor: '+cCliNome+'</b></td>'
			xHTM += '<td Width=10% align=right><b>'+Transform(nTitVlr,"@E 999,999,999.99")+'</b></td>'
			xHTM += '<td Width=10% align=right><b>'+Transform(nTitSld,"@E 999,999,999.99")+'</b></td>'
			xHTM += '<td Width=40% align=left>_</td>'
			xHTM += '</tr>'	
		EnDif	
		If !TSE2->(EOF())
			cCliente := TSE2->E2_FORNECE+TSE2->E2_LOJA
			cCliNome := ALLTRIM(TSE2->A2_NOME)
			nTitVlr	:= 0 
			nTitSld	:= 0
		Endif
	Endif
EndDo           

xHTM += '<tr BGCOLOR=#9C9C9C>'
xHTM += '<td colspan="5" Width=40%>TOTAL GERAL TITULOS EM ABERTO</td>'
xHTM += '<td Width=10% align=right><b>'+Transform(nTotVlr,"@E 999,999,999.99")+'</b></td>'
xHTM += '<td Width=10% align=right><b>'+Transform(nTotSld,"@E 999,999,999.99")+'</b></td>'
xHTM += '<td Width=40% align=left>_</td>'
xHTM += '</tr>'
xHTM += '</table>' // fim da tabela de titulos

xHTM += '<br>'
xHTM += '<br>'
xHTM += '<br>'

xHTM += '<hr>'
xHTM += '<b><font face="Verdana" SIZE=3>Titulos Tipo NDF/PA em aberto</b></p>'
xHTM += '<b><font face="Verdana" SIZE=1>
xHTM += '<table BORDER=1>'
xHTM += '<tr BGCOLOR=#191970 >'
xHTM += '<td Width= 4%><b><font color=#F5F5F5>Filial</b></font></td>'
xHTM += '<td Width=15%><b><font color=#F5F5F5>Prx\Titulo\Tipo\Parcela</b></font></td>'
xHTM += '<td Width=08%><b><font color=#F5F5F5>Emissao</b></font></td>'
xHTM += '<td Width=08%><b><font color=#F5F5F5>Vencimento</b></font></td>'
xHTM += '<td Width=05%><b><font color=#F5F5F5>Dias</b></font></td>'
xHTM += '<td Width=10%><b><font color=#F5F5F5>Valor Original</b></font></td>'
xHTM += '<td Width=10%><b><font color=#F5F5F5>Saldo do Titulo</b></font></td>'
xHTM += '<td Width=40%><b><font color=#F5F5F5>Fornecedor</b></font></td>
xHTM += '</tr>'	

dbSelectArea("TSE2") // apenas NCC
dbGotop()
nNCCVlr		:= 0
nNCCSld		:= 0
While !Eof()
	if Alltrim(TSE2->E2_TIPO)$"NDF;PA" 
		nNCCVlr		+= TSE2->E2_VALOR
		nNCCSld		+= TSE2->E2_SALDO
		nQtdDias    := DDATABASE - STOD(TSE2->E2_VENCREA) 
		xHTM += '<tr>'
		xHTM += '<td Width=4%>'+TSE2->E2_FILIAL+'</td>'
		xHTM += '<td Width=15%>'+TSE2->E2_PREFIXO+'\'+TSE2->E2_NUM+'\'+TSE2->E2_TIPO + IIF( !EMPTY(TSE2->E2_PARCELA) ,'\'+TSE2->E2_PARCELA,"")+'</td>'
		xHTM += '<td Width=08%>'+SUBSTR(TSE2->E2_EMISSAO,7,2)+'/'+SUBSTR(TSE2->E2_EMISSAO,5,2)+'/'+SUBSTR(TSE2->E2_EMISSAO,1,4)+'</td>'
		xHTM += '<td Width=08%>'+SUBSTR(TSE2->E2_VENCREA,7,2)+'/'+SUBSTR(TSE2->E2_VENCREA,5,2)+'/'+SUBSTR(TSE2->E2_VENCREA,1,4)+'</td>'
		xHTM += '<td Width=05% align=right>'+Transform(nQtdDias ,"@E 999,999")+'</td>'
		xHTM += '<td Width=10% align=right>'+Transform(TSE2->E2_VALOR,"@E 999,999,999.99")+'</td>'
		xHTM += '<td Width=10% align=right>'+Transform(TSE2->E2_SALDO,"@E 999,999,999.99")+'</td>'
		xHTM += '<td Width=40% align=left>'+TSE2->E2_FORNECE + "-" + TSE2->E2_LOJA + "  " + ALLTRIM(TSE2->A2_NOME) + '</td>
		xHTM += '</tr>'	
	EndIf
    TSE2->(dbSkip())
EndDo
xHTM += '<tr BGCOLOR=#9C9C9C >'
xHTM += '<td colspan="5" Width=40%>TOTAL DE NCC/RA EM ABERTO</td>'
xHTM += '<td Width=10% align=right><b>'+Transform(nNCCVlr,"@E 999,999,999.99")+'</b></td>'
xHTM += '<td Width=10% align=right><b>'+Transform(nNCCSld,"@E 999,999,999.99")+'</b></td>'
xHTM += '<td Width=40% align=left>_</td>'
xHTM += '</tr>'
xHTM += '</table>' // fim da tabela de NCC

xHTM += '<br>
xHTM += '<br>'
xHTM += '</BODY></HTML>'

//Memowrite("D:\Totvs\vajob01_xx.htm",xHTM)                                                

if lEnvia
	xAssunto:= "Protheus Workflow - Titulos da carteira a Pagar pendentes (com Atraso maior que 3 dias)"
	xAnexo  := ""                                           
	xDe     := "protheus@vistalegre.agr.br"              
	xCopia  := "henriquemds@totvs.com.br"
	xEmail  := "henriquemds@hotmail.com"  // comentar depois
//	u_EnvJob01(xDe,xemail,xAssunto,xHTM,xAnexo,xCopia)


	aDados := {}
//	aAdd(aDados, {"vajob01_"+DTOC( DDATABASE)+".htm", "\vajob01_"+DTOC( DDATABASE)+".htm"})
//	aAdd(aDados, {"vajob01_xx.htm", "D:\Totvs\vajob01_xx.htm"})
//	aAdd(aDados, {"vajob01_XS.htm", "\vajob01_xs.htm"})
//	aAdd(aDados, {"ID_conf_cxa.rpm", "\conf_cxa.rpm"})

	Processa({|| u_EnvMail( xDe 		,;			//_cPara
							xCopia 		,;			//_cCc
							""			,;			//_cBCC
							xAssunto,;				//_cTitulo
							aDados,;				//_aAnexo
							xHTM,;					//_cMsg
							.T.)},"Enviando e-mail...")		//_lAudit

Return(Nil)

//	cQuery := " SELECT X5_CHAVE, X5_DESCRI "
//	cQuery += " FROM "+RetSqlName('SX5')+" SX5 "
//	cQuery += " WHERE X5_TABELA = 'Z9' "
//	cQuery += " AND SUBSTRING(X5_CHAVE,1,3)  = 'J01'  "
//	cQuery += " AND D_E_L_E_T_<>'*' "  
//	cQuery += " ORDER BY X5_CHAVE "  

//	If Select("JOBMAIL") <> 0
//		JOBMAIL->(dbCloseArea())
//	Endif
//	TCQuery cQuery Alias "JOBMAIL" New	
//	dbSelectArea("JOBMAIL")
//	dbGotop()
//	While !Eof()
//		xEmail  := alltrim(lower(JOBMAIL->X5_DESCRI))
//		u_EnvJob01(xDe,xemail,xAssunto,xHTM,xAnexo,xCopia)
//		JOBMAIL->(dbSkip())		
//	EndDo
	
endif	

SET FILTER TO

Qout("Fim do Job para envio de titulos em atraso "+DTOC(DATE())+' '+TIME())

//RPCCLEARENV()
return   



User Function EnvJob01(cDe,cPara,cAssunto,cBody,cAtach,cCopia)

CONNECT SMTP SERVER GetMV("MV_RELSERV") ;
ACCOUNT GetMV("MV_RELACNT") PASSWORD GetMV("MV_RELPSW") RESULT lOk

If !lOK
	cErro:=MailGetErr()
	Qout("Erro ao Conectar o Servidor - "+cErro)
	Return .F.
EndIf

//SERVIDOR COM AUTENTICAÇÃO                

lRelauth := getnewpar("MV_RELAUTH",.F.)
if lRelAuth
   lOk:=mailauth(GetMV("MV_RELACNT"),GetMV("MV_RELPSW"))
	If !lOK
		cErro:=MailGetErr()
		Qout("Erro ao conectar com autenticacao - " + cErro)
		lOk := MailSmtpOff( )
		Return .F.
	endif
endif
                                                                  
SEND MAIL FROM cDe TO cPara CC cCopia SUBJECT cAssunto BODY cBody ATTACHMENT cAtach RESULT lOK

If !lOK
	cErro:=MailGetErr()
	Qout("Erro ao Enviar Mensagem - " + cErro)
	lOk := MailSmtpOff( )
	Return .F.
EndIf

Qout("Email de comunicação enviado")

lOk := MailSmtpOff()

If !lOK
	Qout("Erro ao Desconectar do Servidor")
	Return .F.
EndIf

Return .T.

User Function EnviaJ1(cDe,cPara,cAssunto,cBody,cAtach,cCopia)


Qout("MV_RELACNT: "+GetMV("MV_RELACNT")+ "  / MV_RELPSW: "+GetMV("MV_RELPSW")+ "  / MV_RELSERV: "+GetMV("MV_RELSERV") )

CONNECT SMTP SERVER GetMV("MV_RELSERV") ;
ACCOUNT GetMV("MV_RELACNT") PASSWORD GetMV("MV_RELPSW") RESULT lOk

If !lOK
	cErro:=MailGetErr()
	Qout("Erro ao Conectar o Servidor - "+cErro)
	Return .F.
EndIf

//SERVIDOR COM AUTENTICAÇÃO                

lRelauth := getnewpar("MV_RELAUTH",.F.)
if lRelAuth
   lOk:=mailauth(GetMV("MV_RELACNT"),GetMV("MV_RELPSW")) 
	If !lOK
		cErro:=MailGetErr()
		Qout("Erro ao conectar com autenticacao - " + cErro)
		lOk := MailSmtpOff( )
		Return .F.
	endif
endif

SEND MAIL FROM cDe TO cPara CC cCopia SUBJECT cAssunto BODY cBody ATTACHMENT cAtach RESULT lOK

If !lOK
	cErro:=MailGetErr()
	Qout("Erro ao Enviar Mensagem - " + cErro)
	lOk := MailSmtpOff( )
	Return .F.
EndIf

Qout("Email de comunicação enviado")

lOk := MailSmtpOff()

If !lOK
	Qout("Erro ao Desconectar do Servidor")
	Return .F.
EndIf

Return .T.
