#include "rwmake.ch"
#include "ap5mail.ch"
#include "topconn.ch" 
#include "protheus.ch"

/*                  
_____________________________________________________________________________
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦Programa  ¦ VAJOB05   ¦ Autor ¦ Henrique Magalhaes   ¦ Data ¦ 02/05/16 ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦Descriçào ¦ Job para informar por e-mail Pedidos compras a entregar    ¦¦¦
¦¦¦          ¦ (INSUMOS)     									  ¦¦¦
¦¦+----------+------------------------------------------------------------¦¦¦
¦¦¦ Uso      ¦ Scheduler                                                  ¦¦¦
¦¦+-----------------------------------------------------------------------+¦¦
¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦¦
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
*/
       

//Tarefa JOB para enviar e-mail com a relacao de pedidos de compras a entregar (apenas para pedidos de INSUMOS)
// 1a. Versao
User Function VAJOB05()             

Local lEnvia		:= .F.  
Local cJobChv		:= 'JOB05' 	// codigo da chave na tabela da sx5, pra incluir emails para envio do job
Local cJobSX5		:= 'Z2'		// tabela da SX5 onde serao selecionados os emails para envio
Local xHTM 			:= ""  
Local nPedVlr		:= 0
Local nPedQtd		:= 0
Local nPedQtje		:= 0
Local nTotVlr		:= 0
Local nTotQtd		:= 0
Local nTotQtje		:= 0
Local cPedido		:= ""
Local nQtdDias		:= 0 
Local nPedAtra		:= 0
Local nTotAtra		:= 0
Local cDiaSem		:= cValtoChar(dow(DATE())) // dia da semana 1-Sunday  2-Monday 3-Tuesday  4-Wednesday  5-Thursday  6-Friday  7-Saturday
Local cDiaDe		:= ""
Local cDiaAte		:= ""
Local cTelEmp		:= ""
Local aTelEmp		:= ""
Local lImpCab1		:= .T.
Local lImpCab2		:= .T.
Local cC7Obs		:= ""
If FindFunction("RPCSETTYPE")
    RPCSetType(3)
Endif

//PREPARE ENVIRONMENT empresa "01" filial "01"  
RPCSETENV("01","01","","","SIGACOM","VASCHED",{})
Qout("Verificando Fornecedores X Pedidos de Compras a Entregar"+DTOC(DATE())+' '+TIME())

//dbSelectArea("SM0")
//dbSeek("0101", .T. )  

Do Case
	Case cDiaSem$"1;2;3;4;5"
		cDiaDe	:= dtos(DATE())  
		cDiaAte	:= dtos(DATE()+(30-Val(cDiaSem)))
	Case cDiaSem$"6"
		cDiaDe	:= dtos(DATE()+3)  
		cDiaAte	:= dtos(DATE()+(8))
	Case cDiaSem$"7"
		cDiaDe	:= dtos(DATE()+2)  
		cDiaAte	:= dtos(DATE()+(7))
EndCase

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
xHTM += '<font face="Verdana" SIZE=3>'+Alltrim( SM0->M0_ENDENT )+" - "+Alltrim(SM0->M0_BAIRENT)+" - CEP: "+alltrim(SM0->M0_CEPENT)+" - Fone/Fax "+ cTelEmp + '</p>'
xHTM += '<hr>'
xHTM += '<b><font face="Verdana" SIZE=3>Pedidos de Compras (Insumos) Pendentes - Programacao Recebimento: '+DTOC(STOD(cDiaDe))+'  a  '+DTOC(STOD(cDiaAte))+'</b></p>'
xHTM += '<hr>'
xHTM += '<font face="Verdana" SIZE=1>* * *  com base no campo data de entrega no item do pedido de compras (somente liberados) * * * [VAJOB05]</p>'
xHTM += '<font face="Verdana" SIZE=3>Data: ' + dtoc(date()) + ' Hora: ' + time() + '</p>'
xHTM += '<br>'      


cQuery := " SELECT C7_FILIAL, C7_NUM, C7_FORNECE, C7_LOJA, A2_NOME, A2_MUN, A2_EST, A2_END, A2_BAIRRO,  C7_EMISSAO, " 
cQuery += " C7_DATPRF, C7_ITEM, C7_PRODUTO, C7_DESCRI, C7_OBS, C7_CONAPRO, C7_X_DESIM, C7_X_DESUM, "
cQuery += " C7_X_PESO, C7_X_RENDP, C7_X_REND, C7_X_ARROV, C7_X_ARROQ, C7_X_TOTAL, C7_X_VLUNI, C7_X_TOICM, C7_X_CORRE, A3_NOME, C7_X_COMIS, C7_X_COMIP, C7_X_VLICM, "
cQuery += " CAST(C7_X_LIMIM AS NUMERIC(15,2)) AS C7_X_LIMIM, CAST(C7_X_LIMUM AS NUMERIC(15,2)) AS C7_X_LIMUM, "
cQuery += " CAST(C7_QUANT AS NUMERIC(15,3)) AS C7_QUANT, CAST(C7_QUJE AS NUMERIC(15,3)) AS C7_QUJE, CAST(C7_PRECO AS NUMERIC(15,2)) AS C7_PRECO,  "    
cQuery += " CAST(C7_TOTAL AS NUMERIC(15,2)) AS C7_TOTAL, CAST(C7_VALIPI AS NUMERIC(15,2)) AS C7_VALIPI, CAST(C7_VLDESC AS NUMERIC(15,2)) AS C7_VLDESC, "
cQuery += " CAST(C7_DESPESA AS NUMERIC(15,2)) AS C7_DESPESA, CAST(C7_VALFRE AS NUMERIC(15,2)) AS C7_VALFRE, "
cQuery += " CAST(C7_TOTAL+C7_VALIPI+C7_VALFRE+C7_DESPESA-C7_VLDESC AS NUMERIC(15,2)) AS TOTALPED "
cQuery += " FROM "+RetSqlName('SC7')+" SC7 "
cQuery += " LEFT JOIN "+RetSqlName('SB1')+" SB1 ON (B1_FILIAL='"+FWxFilial("SB1")+"' AND B1_COD=C7_PRODUTO AND SB1.D_E_L_E_T_<>'*') "
cQuery += " LEFT JOIN "+RetSqlName('SA2')+" SA2 ON (A2_FILIAL='"+FWxFilial("SA2")+"' AND A2_COD=C7_FORNECE AND A2_LOJA=C7_LOJA AND SA2.D_E_L_E_T_<>'*') "
cQuery += " LEFT JOIN "+RetSqlName('SA3')+" SA3 ON (A3_FILIAL='"+FWxFilial("SA3")+"' AND A3_COD=C7_X_CORRE AND SA3.D_E_L_E_T_<>'*') "
cQuery += " WHERE C7_EMISSAO >= '20100101' "  // AND C7_DATPRF BETWEEN  '"+cDiaDe+"' AND '" + cDiaAte + "'  "
cQuery += " AND C7_QUANT - C7_QUJE > 0 AND C7_CONAPRO <> 'B' AND C7_RESIDUO <> 'S' "
cQuery += " AND B1_GRUPO IN ('02') " // insumos
cQuery += " AND SC7.D_E_L_E_T_ <> '*' "
cQuery += " ORDER BY C7_FILIAL, C7_EMISSAO, C7_NUM, C7_ITEM "


If Select("TSC7") <> 0
	TSC7->(dbCloseArea())
Endif

TCQuery cQuery Alias "TSC7" New

dbSelectArea("TSC7")
dbGotop()
cPedido := "ZYX999"
While !Eof()
		If cPedido <> TSC7->C7_NUM
			xHTM += '<br>'      			
			xHTM += '<br>'
			xHTM += '<b><font face="Verdana" SIZE=1>
			// Cabecalho Pedido
			xHTM += '<table width="85%" BORDER=1>'
			xHTM += '<tr BGCOLOR=#698B69 >'
			xHTM += '<td Width=05%><b><font color=#F5F5F5>Filial</b></font></td>'
			xHTM += '<td Width=10%><b><font color=#F5F5F5>Pedido</b></font></td>'
			xHTM += '<td Width=10%><b><font color=#F5F5F5>Emissao</b></font></td>'
			xHTM += '<td Width=45%><b><font color=#F5F5F5>Fornecedor</b></font></td>'
			xHTM += '<td Width=30%><b><font color=#F5F5F5>Municipio/UF</b></font></td>'
			xHTM += '</tr>'	

			xHTM += '<tr>'
			xHTM += '<td Width=05%>'+TSC7->C7_FILIAL+'</td>'
			xHTM += '<td Width=10%>'+TSC7->C7_NUM+'</td>'
			xHTM += '<td Width=10%>'+SUBSTR(TSC7->C7_EMISSAO,7,2)+'/'+SUBSTR(TSC7->C7_EMISSAO,5,2)+'/'+SUBSTR(TSC7->C7_EMISSAO,1,4)+'</td>'
			xHTM += '<td Width=45% align=left>'+ALLTRIM(TSC7->C7_FORNECE)+'-'+ALLTRIM(TSC7->C7_LOJA) +': ' + ALLTRIM(TSC7->A2_NOME) + '</td>
			xHTM += '<td Width=30% align=left>'+TSC7->A2_MUN + "-" + TSC7->A2_EST + '</td>
			xHTM += '</tr>'	
			cC7Obs		:= 	u_SC7OBS(TSC7->C7_FILIAL, TSC7->C7_NUM)
			If !Empty(cC7Obs)
				xHTM += '<tr>'
				xHTM += '<td colspan=6 Width=100%>'+cC7Obs+'</td>'
				xHTM += '</tr>'	
			Endif
			xHTM += '</table>'
			lImpCab1 := .T.			
		Else
			lImpCab1 := .F. 			
		Endif

		cPedido 	:= TSC7->C7_NUM
		nPedQtd		+= TSC7->C7_QUANT
		nPedQtje	+= TSC7->C7_QUJE
		nPedVlr     += TSC7->TOTALPED

		nTotQtd		+= TSC7->C7_QUANT
		nTotQtje	+= TSC7->C7_QUJE
		nTotVlr     += TSC7->TOTALPED
		nQtdDias    := STOD(TSC7->C7_DATPRF) - DATE() 

		If lImpCab1
			xHTM += '<b><font face="Verdana" SIZE=1>
			xHTM += '<table width="85%" BORDER=1>'
			xHTM += '<tr BGCOLOR=#778899 >'
			xHTM += '<td Width=13%><b><font color=#F5F5F5>Item/Produto</b></font></td>'
			xHTM += '<td Width=09%><b><font color=#F5F5F5>Quantidade</b></font></td>'
			xHTM += '<td Width=09%><b><font color=#F5F5F5>Entregue</b></font></td>'
			xHTM += '<td Width=09%><b><font color=#F5F5F5>Pendente</b></font></td>'
			xHTM += '<td Width=09%><b><font color=#F5F5F5>R$ Unitario</b></font></td>'
			xHTM += '<td Width=10%><b><font color=#F5F5F5>R$ Total</b></font></td>'
			xHTM += '<td Width=07%><b><font color=#F5F5F5>Desc.Impu.</b></font></td>'
			xHTM += '<td Width=07%><b><font color=#F5F5F5>Desc.Umid.</b></font></td>'
			xHTM += '<td Width=07%><b><font color=#F5F5F5>Lim.Impu.</b></font></td>'
			xHTM += '<td Width=07%><b><font color=#F5F5F5>Lim.Umid.</b></font></td>'
			xHTM += '<td Width=08%><b><font color=#F5F5F5>Previsao Entrega</b></font></td>'
			xHTM += '<td Width=05%><b><font color=#F5F5F5>Dias</b></font></td>'
			xHTM += '</tr>'	
		Endif

		xHTM += '<tr>'
		xHTM += '<td Width=13%>'+alltrim(TSC7->C7_DESCRI)+'</td>'
		xHTM += '<td Width=09% align=right>'+Transform(TSC7->C7_QUANT,PesqPict("SC7","C7_QUANT"))+'</td>'
		xHTM += '<td Width=09% align=right>'+Transform(TSC7->C7_QUJE,PesqPict("SC7","C7_QUANT"))+'</td>'
		xHTM += '<td Width=09% align=right>'+Transform(TSC7->C7_QUANT-TSC7->C7_QUJE,PesqPict("SC7","C7_QUANT"))+'</td>'
		xHTM += '<td Width=09% align=right>'+Transform(TSC7->C7_PRECO,PesqPict("SC7","C7_PRECO"))+'</td>'
		xHTM += '<td Width=10% align=right>'+Transform(TSC7->TOTALPED,PesqPict("SC7","C7_TOTAL"))+'</td>'
		xHTM += '<td Width=07% align=right>'+IIF(TSC7->C7_X_DESIM="S",'Sim','Nao')+'</td>'
		xHTM += '<td Width=07% align=right>'+IIF(TSC7->C7_X_DESUM="S",'Sim','Nao')+'</td>'
		xHTM += '<td Width=07% align=right>'+'0'/* Transform(TSC7->C7_X_LIMIM,PesqPict("SC7","C7_LIMIM")) */+'</td>'
		xHTM += '<td Width=07% align=right>'+'0'/* Transform(TSC7->C7_X_LIMUM,PesqPict("SC7","C7_LIMUM")) */+'</td>'
		xHTM += '<td Width=08%>'+SUBSTR(TSC7->C7_DATPRF,7,2)+'/'+SUBSTR(TSC7->C7_DATPRF,5,2)+'/'+SUBSTR(TSC7->C7_DATPRF,1,4)+'</td>'
		xHTM += '<td Width=05% align=right>'+Transform(nQtdDias ,"@E 999,999")+'</td>'
		xHTM += '</tr>'	


   		lEnvia:= .T.
    	TSC7->(dbSkip())

   		If cPedido <> TSC7->C7_NUM .or. TSC7->(EOF())
			xHTM += '<tr BGCOLOR=#CFCFCF >' // gray 81
			xHTM += '<td Width=13%><b>Sub-Total Pedido: '+cPedido+'</b></td>'
			xHTM += '<td Width=09% align=right><b>'+Transform(nPedQtd  ,PesqPict("SC7","C7_QUANT") )+'</b></td>'
			xHTM += '<td Width=09% align=right><b>'+Transform(nPedQtje ,PesqPict("SC7","C7_QUANT") )+'</b></td>'
			xHTM += '<td Width=09% align=right><b>'+Transform(nPedQtd - nPedQtje,PesqPict("SC7","C7_QUANT") )+'</b></td>'
			xHTM += '<td Width=09% align=right><b> </b></td>'
			xHTM += '<td Width=10% align=right><b>'+Transform(nPedVlr,PesqPict("SC7","C7_TOTAL") )+'</b></td>'
			xHTM += '<td colspan="6" Width=41% align=left>_</td>'
			xHTM += '</tr>'	
			xHTM += '</table>' // fim da tabela de pedidos
			xHTM += '<br>'
			If !TSC7->(EOF())
				//cPedido 	:= TSC7->C7_NUM
				nPedVlr		:= 0 
				nPedQtd		:= 0
			    nPedQtje	:= 0
			Endif
		Endif
EndDo           

xHTM += '<b><font face="Verdana" SIZE=1>
xHTM += '<table width="85%" BORDER=1>'
xHTM += '<tr BGCOLOR=#9C9C9C>'
xHTM += '<td Width=13%>TOTAL PEDIDOS DE COMPRAS DE INSUMOS A ENTREGAR/PENDENTES</td>'
xHTM += '<td Width=09% align=right><b>'+Transform(nTotQtd  ,PesqPict("SC7","C7_QUANT") )+'</b></td>'
xHTM += '<td Width=09% align=right><b>'+Transform(nTotQtje ,PesqPict("SC7","C7_QUANT") )+'</b></td>'
xHTM += '<td Width=09% align=right><b>'+Transform(nTotQtd - nTotQtje,PesqPict("SC7","C7_QUANT") )+'</b></td>'
xHTM += '<td Width=09% align=right><b> </b></td>'
xHTM += '<td Width=10% align=right><b>'+Transform(nTotVlr,PesqPict("SC7","C7_TOTAL"))+'</b></td>'
xHTM += '<td colspan="6" Width=41% align=left>_</td>'
xHTM += '</tr>'
xHTM += '</table>' // fim da tabela de pedidos
xHTM += '<br>'
xHTM += '<br>'
xHTM += '<br>'


xHTM += '<br>'
xHTM += '<br>'
xHTM += '</BODY></HTML>'

                                                
if lEnvia

	xAssunto:= "Protheus Workflow - Pedidos de Compras (Insumos)"
	xAnexo  := ""                                           
	xDe     := "protheus@vistalegre.agr.br"             
	xCopia  := ""
	xEmail  := ""
	xaDados := {}


		cQuery := " SELECT X5_CHAVE, X5_DESCRI "
		cQuery += " FROM "+RetSqlName('SX5')+" SX5 "
		cQuery += " WHERE X5_TABELA = '"+cJobSX5+"' "
		cQuery += " AND SUBSTRING(X5_CHAVE,1,5)  = '"+cJobChv+"'  "
		cQuery += " AND D_E_L_E_T_<>'*' "  
		cQuery += " ORDER BY X5_CHAVE "  
	
		If Select("JOBMAIL") <> 0
			JOBMAIL->(dbCloseArea())
		Endif
		TCQuery cQuery Alias "JOBMAIL" New	
		dbSelectArea("JOBMAIL")
		dbGotop()
		While !Eof()
			xEmail  := alltrim(lower(JOBMAIL->X5_DESCRI))
			If !Empty(xEmail)
				ConOut("Para: "+ xEmail )
				MemoWrite( "D:\_TMP_\VAJOB05_"+xEmail+".html", xHTM )
				Processa({ || u_EnvMail(xEmail	,;			//_cPara
								xCopia 				,;			//_cCc
								""					,;			//_cBCC
								xAssunto			,;			//_cTitulo
								xaDados				,;			//_aAnexo
								xHTM				,;			//_cMsg
								.T.)},"Enviando e-mail...")		//_lAudit
			EndIf
			JOBMAIL->(dbSkip())	
		EndDo
		If Select("JOBMAIL") <> 0
			JOBMAIL->(dbCloseArea())
		Endif


endif	

SET FILTER TO

Qout("Fim do Job para envio de pedidos de compras a entregar "+DTOC(DATE())+' '+TIME())

	RPCCLEARENV()

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
