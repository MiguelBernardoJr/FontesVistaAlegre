#include "Protheus.ch"
#include "TopConn.ch"


/*--------------------------------------------------------------------------------,
 | Principal: 			                                    		              |
 | Func:                             	          	            	          	  |
 | Autor: Miguel Martins Bernardo Junior	            	          	  		  |
 | Data:  09.10.2019	            	          	            	              |
 | Desc:                                                           	              |
 '--------------------------------------------------------------------------------|
 | Obs.:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------*/
User Function FECHAMES()		// u_FECHAMES()
 
	Local DtFinaceir := GETMV("MV_DATAFIN")
	Local DtContabil := GETMV("MV_DBLQMOV")
	local aPosSX1 	 := {}
	
	Private cPerg 	 := "FECHAMES"

	If MsgYesNo("Sr.(a) <b>" + AllTrim( cUserName ) + "</b> essa rotina atualizará os parâmetros de movimentação de ESTOQUE, FINANCEIRO e Contabil. " +;
				"Após a data informada nenhum movimento estoque/financeiro/contabil será permitido. A data atual informada " +;
				"para o financeiro é: " + DTOC(DtFinaceir) + "<br>" +;
				"e para o contabil é: " + DTOC(DtContabil) + ", deseja prosseguir?","Atenção")     

		ValidPerg()
		
		aPosSX1 := { { cPerg, "01", DtFinaceir },;
					 { cPerg, "02", sToD('') },; 
					 { cPerg, "03", DtContabil },; 
					 { cPerg, "04", sToD('') } }
		U_PosSX1(aPosSX1)
		
		If !Pergunte(cPerg,.t.)
		    Return
		Endif                     
		
		If MV_PAR01<>MV_PAR02
			If !Empty(MV_PAR02)
				PutMV("MV_DATAFIN",DTOS(MV_PAR02))                                                                 
				PutMV("MV_DATAREC",DTOS(MV_PAR02))                                                                 
			EndIf
		Endif
		If MV_PAR03<>MV_PAR04
			If !Empty(MV_PAR04)
				PutMV("MV_DBLQMOV",DTOS(MV_PAR04))
			EndIf
		EndIf
		DocEmail() // Documentar alteracoes por email
		
		Aviso("Configuração atual dos parâmetros","As data ficaram configuradas na seguinte maneira: " + CRLF+;
			  "Financeiro: " + DTOC(GETMV("MV_DATAFIN")) + CRLF +;
			  "Contabil: " + DTOC(GETMV("MV_DBLQMOV")),{"OK"},1)       
	Endif                 
Return


/*--------------------------------------------------------------------------------,
 | Principal: 			                                    		              |
 | Func:                             	          	            	          	  |
 | Autor: Miguel Martins Bernardo Junior	            	          	  		  |
 | Data:  09.10.2019	            	          	            	              |
 | Desc:                                                           	              |
 '--------------------------------------------------------------------------------|
 | Obs.:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------*/
Static Function DocEmail()
Local xAssunto  := "Alteração dos parâmetros de fechamento"
Local xaDados 	:= {}
Local xHTM		:= ""

Local xEmail	:= GetMV("MB_FCHAMES",,"valeria.buzaneli@vistaalegre.agr.br,"+;
									   "aderaldo.evangelista@vistaalegre.agr.br,"+;
									   "camila.martins@vistaalegre.agr.br,"+;
									   "miguel.bernardo@vistaalegre.agr.br,"+;
									   "arthur.toshio@vistaalegre.agr.br") // Emails que receberao o email da funcao FECHAMES

	// xEmail := "miguel.bernardo@vistaalegre.agr.br"
	
	aAdd( xaDados, { "LogoTipo", "\workflow\images\logoM.jpg" } )

	aTelEmp:= FisGetTel(SM0->M0_TEL)
	cTelEmp := "" //IIF(aTelDest[1] > 0,U_ConvType(aTelDest[1],3),"") // Código do Pais
	cTelEmp += "("+ IIF(aTelEmp[2] > 0,U_ConvType(aTelEmp[2],3),"") + ") " // Código da Área
	cTelEmp += IIF(aTelEmp[3] > 0,U_ConvType(aTelEmp[3],9),"") // Código do Telefone
	//cFoneEmp:= "Telefone: " + cFoneEmp 

	xHTM := '<HTML><BODY>'
	xHTM += '<hr>'
	xHTM += '<p  style="word-spacin g: 0; line-height: 100%; margin-top: 0; margin-bottom: 0">'
	xHTM += '<b><font face="Verdana" SIZE=3>' + SM0->M0_NOMECOM + '</b></p>'
	xHTM += '<br>'                                                                                            
	xHTM += '<font face="Verdana" SIZE=3>'+Alltrim( SM0->M0_ENDENT )+" - "+Alltrim(SM0->M0_BAIRENT)
	xHTM += 		" - CEP: "+alltrim(SM0->M0_CEPENT)+" - Fone/Fax "+ cTelEmp + '</p>'
	xHTM += '<hr>'
	cTitulo := "Configuração dos Parâmetros de fechamento do sistema"
	xHTM += '<b><font face="Verdana" SIZE=3>'+cTitulo+'</b></p>'
	xHTM += '<hr>'
	xHTM += '<font face="Verdana" SIZE=2>Data: ' + dtoc(date()) + ' Hora: ' + time() + '</p>'
	xHTM += '<br><br>'      
	xHTM += '<div>'
	xHTM += 'PARÂMETROS:'
	xHTM += '<br>'      
	xHTM += 'Finceiro: '+ DTOC(GETMV("MV_DATAFIN"))
	xHTM += '<br>'
	xHTM += 'Contabil: '+ DTOC(GETMV("MV_DBLQMOV"))
	xHTM += '<br>'
	xHTM += '<br>'
	xHTM += 'Parâmetros alterados por: <b>' + AllTrim( cUserName ) + '</b>'
	xHTM += '</div>'      
	xHTM += '</BODY></HTML>'
	
	MemoWrite( "C:\totvs_relatorios\fechames.html", xHTM )

	Processa({ || u_EnvMail(xEmail	,;			//_cPara
					"" 				,;		//_cCc
					""					,;		//_cBCC
					xAssunto			,;		//_cTitulo
					xaDados				,;		//_aAnexo
					xHTM				,;		//_cMsg
					.T.)},"Enviando e-mail...")	//_lAudit
Return nil


/*--------------------------------------------------------------------------------,
 | Principal: 			                                    		              |
 | Func:                             	          	            	          	  |
 | Autor: Miguel Martins Bernardo Junior	            	          	  		  |
 | Data:  09.10.2019	            	          	            	              |
 | Desc:                                                           	              |
 '--------------------------------------------------------------------------------|
 | Obs.:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------*/
Static Function ValidPerg()
Local _sAlias, i, j
_sAlias := Alias()

dbSelectArea("SX1")
dbSetOrder(1)

aRegs:={}

cPerg := PADR(cPerg,10)
 
// AADD(aRegs,{cPerg,"01","Data?"               ,"","","MV_CH1","D",8,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
// aAdd(aRegs,{cPerg,"02","Atualiza Financeiro?","","","MV_CH2","N",1,0,2,"C","","MV_PAR02","Não","","",""      ,"","Sim","","","","","","","","","","","","","","","","","","","","U","","","",""})
// aAdd(aRegs,{cPerg,"03","Atualiza Contabil?"  ,"","","MV_CH3","N",1,0,1,"C","","MV_PAR03","Não","","",""      ,"","Sim","","","","","","","","","","","","","","","","","","","","U","","","",""})
AADD(aRegs,{cPerg,"01","Dt Financeiro De:"     ,"","","MV_CH1","D",8,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"02","Dt Financeiro Para:"   ,"","","MV_CH2","D",8,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"03","Dt Contabilidade De:"  ,"","","MV_CH3","D",8,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
AADD(aRegs,{cPerg,"04","Dt Contabilidade Para:","","","MV_CH4","D",8,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

For i := 1 to Len(aRegs) 
     If !dbSeek(cPerg+aRegs[i,2])
          RecLock("SX1",.T.)
	          For j := 1 to FCount()
	               If j <= Len(aRegs[i])
	               	   FieldPut(j,aRegs[i,j])
	               Endif
	          Next j
          MsUnlock()
          dbCommit()
     EndIf
Next i
 
 dbSelectArea(_sAlias)
Return

/*
User Function ConvType(xValor,nTam,nDec)

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
*/
