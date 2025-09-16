#include "Protheus.ch"
#include "TopConn.ch"

/*--------------------------------------------------------------------------------,
 | Principal: U_ALTOPER                                                           |
 | Autor: Miguel Martins Bernardo Junior (Adaptado por Especialista Protheus)     |
 | Data: 16/09/2025                                                               |
 | Desc: Rotina para alteração dos operadores principais do sistema,            |
 |       registrados no parâmetro MV_OPERADO. Inclui verificação de arquivos      |
 |       já gerados para a data corrente.                                         |
 '--------------------------------------------------------------------------------*/
User Function U_ALTOPER()

	//-- Variaveis
	Local cOldOper    := GetMV("MV_OPERADO")
	Local aOperador   := StrTokArr(cOldOper + ";",";")
	Local cOper1_Old  := Iif(Len(aOperador) >= 1, aOperador[1], "")
	Local cOper2_Old  := Iif(Len(aOperador) >= 2, aOperador[2], "")
	Local cOper1_New  := ""
	Local cOper2_New  := ""
	Local cNewOper    := ""
	Local aPosSX1 	  := {}
	Local cQuery      := ""
	Local cAlias      := GetNextAlias()
	
	//-- Identificador unico da pergunta
	Private cPerg 	  := "ALTOPER"

	//-- Mensagem inicial para o usuario
	If MsgYesNo("Sr.(a) <b>" + AllTrim( cUserName ) + "</b>, esta rotina altera os operadores do parâmetro <b>MV_OPERADO</b>." +;
				"<br><br><b>Operador 1 Atual:</b> " + cOper1_Old +;
				"<br><b>Operador 2 Atual:</b> " + cOper2_Old +;
				"<br><br>Deseja prosseguir com a alteração?","Atenção")

		//-- Cria/Valida as perguntas no dicionario SX1
		ValidPerg()
		
		//-- Preenche as perguntas com os valores atuais
		aPosSX1 := { { cPerg, "01", cOper1_Old },;
					 { cPerg, "02", cOper2_Old } }
		U_PosSX1(aPosSX1)
		
		//------------------------------------------------------------------------------------
		//-- INICIO: Bloco de Verificação de Arquivos Gerados (Conforme solicitado)
		//------------------------------------------------------------------------------------
		cQuery := " SELECT Z0X.R_E_C_N_O_ "
		cQuery += "  FROM " + RetSqlName("Z0X") + " Z0X "
		cQuery += "  JOIN " + RetSqlName("Z0Y") + " Z0Y ON (Z0X.Z0X_CODIGO = Z0Y.Z0Y_CODEI AND Z0Y.D_E_L_E_T_ = ' ' ) "
		cQuery += " WHERE Z0X.Z0X_DATA = '" + DtoS(dDatabase) + "' " //-- Utiliza a data atual (dDatabase)
		cQuery += "   AND (Z0Y.Z0Y_OPER1 <> ' ' OR Z0Y.Z0Y_OPER2 <> ' ' ) "
		cQuery += "   AND Z0X.D_E_L_E_T_ = ' ' "
		
		//-- Executa a query em um alias temporario
		dbUseArea(.T., "TOPCONN", cQuery, cAlias, .F., .T.)
		
		//-- Se a query retornar algum registro, exibe o alerta
		If (cAlias)->(!Eof())
			Aviso("Atenção", "Já existem arquivos gerados para a data atual", {"OK"}, 3) // Icone de Atenção
		Endif
		
		//-- Fecha o alias temporario
		(cAlias)->(dbCloseArea())
		//------------------------------------------------------------------------------------
		//-- FIM: Bloco de Verificação de Arquivos Gerados
		//------------------------------------------------------------------------------------
		
		//-- Exibe a tela de perguntas para o usuario
		If Pergunte(cPerg, .T.)
			
			cOper1_New := AllTrim(MV_PAR01)
			cOper2_New := AllTrim(MV_PAR02)
			cNewOper   := cOper1_New + ";" + cOper2_New

			//-- Verifica se houve alteracao e se os campos estao preenchidos
			If cNewOper != cOldOper .And. !Empty(cOper1_New) .And. !Empty(cOper2_New)
				
				BeginSxi()
				PutMV("MV_OPERADO", cNewOper)
				EndSxi()

				//-- Envia e-mail documentando a alteracao
				DocEmail(cOldOper, cNewOper)
				
				Aviso("Parâmetro Atualizado", "O parâmetro MV_OPERADO foi atualizado com sucesso." + CRLF + CRLF +;
					  "Operador 1: " + cOper1_New + CRLF +;
					  "Operador 2: " + cOper2_New, {"OK"}, 1)
			Else
				Aviso("Atenção", "Nenhuma alteração foi realizada no parâmetro.", {"OK"}, 3)
			Endif
		
		Endif
	Endif
	
Return

/*--------------------------------------------------------------------------------,
 | Func: DocEmail                                                                 |
 | Desc: Envia um e-mail formatado com os detalhes da alteração do parâmetro.    |
 '--------------------------------------------------------------------------------*/
Static Function DocEmail(cOperadoresAnt, cOperadoresNov)
	
	Local xAssunto  := "Alteração do Parâmetro de Operadores (MV_OPERADO)"
	Local xaDados 	:= {}
	Local xHTM		:= ""
	Local cTelEmp   := ""
	Local aTelEmp   := {}
	Local cTitulo   := "Alteração do Parâmetro de Operadores do Sistema"
	
	//-- Array com operadores antigos e novos
	Local aOperAnt  := StrTokArr(cOperadoresAnt + ";", ";")
	Local aOperNov  := StrTokArr(cOperadoresNov + ";", ";")

	//-- Busca os nomes dos operadores para enriquecer o e-mail
	Local cNomeOp1Ant := AllTrim(Posicione("Z0U", 1, xFilial("Z0U") + aOperAnt[1], "Z0U_NOME"))
	Local cNomeOp2Ant := AllTrim(Posicione("Z0U", 1, xFilial("Z0U") + aOperAnt[2], "Z0U_NOME"))
	Local cNomeOp1Nov := AllTrim(Posicione("Z0U", 1, xFilial("Z0U") + aOperNov[1], "Z0U_NOME"))
	Local cNomeOp2Nov := AllTrim(Posicione("Z0U", 1, xFilial("Z0U") + aOperNov[2], "Z0U_NOME"))
	
	//-- Lista de e-mails que receberão a notificação
	Local xEmail	:= GetMV("MV_OPERADO",,"ricardo.cristofano@vistaalegre.agr.br,"+;
									   "ana.lima@vistaalegre.agr.br,"+;
									   "lorrayne.teles@vistaalegre.agr.br,"+;
									   "ti@vistaalegre.agr.br,")

	aAdd( xaDados, { "LogoTipo", "\workflow\images\logoM.jpg" } )

	//-- Montagem do corpo do e-mail em HTML
	xHTM := '<HTML><BODY style="font-family: Verdana, sans-serif; font-size: 10pt;">'
	xHTM += '<hr>'
	xHTM += '<p><b><font SIZE=3>' + SM0->M0_NOMECOM + '</b></p>'
	xHTM += '<hr>'
	xHTM += '<p><b><font SIZE=3>' + cTitulo + '</b></p>'
	xHTM += '<hr>'
	xHTM += '<p>Data: ' + dtoc(date()) + ' | Hora: ' + time() + '</p>'
	xHTM += '<br>'      
	xHTM += '<p>O parâmetro <b>MV_OPERADO</b> foi alterado por: <b>' + AllTrim(cUserName) + '</b></p>'
	xHTM += '<br>'
	
	xHTM += '<table border="1" cellpadding="5" cellspacing="0" style="border-collapse: collapse;">'
	xHTM += '<tr bgcolor="#f2f2f2"><th></th><th>Código</th><th>Nome do Operador</th></tr>'
	xHTM += '<tr><td><b>DE (Operador 1):</b></td><td>' + aOperAnt[1] + '</td><td>' + cNomeOp1Ant + '</td></tr>'
	xHTM += '<tr><td><b>DE (Operador 2):</b></td><td>' + aOperAnt[2] + '</td><td>' + cNomeOp2Ant + '</td></tr>'
	xHTM += '<tr><td><b>PARA (Operador 1):</b></td><td>' + aOperNov[1] + '</td><td>' + cNomeOp1Nov + '</td></tr>'
	xHTM += '<tr><td><b>PARA (Operador 2):</b></td><td>' + aOperNov[2] + '</td><td>' + cNomeOp2Nov + '</td></tr>'
	xHTM += '</table>'
	
	xHTM += '</BODY></HTML>'
	
	//-- Função de envio de e-mail (utilizando a mesma do fonte original)
	Processa({ || u_EnvMail(xEmail, "", "", xAssunto, xaDados, xHTM, .T.) }, "Enviando e-mail...")
	
Return nil


/*--------------------------------------------------------------------------------,
 | Func: ValidPerg                                                                |
 | Desc: Cria ou valida a estrutura de perguntas (SX1) para a rotina.             |
 '--------------------------------------------------------------------------------*/
Static Function ValidPerg()
	Local aRegs 	:= {}
	Local cGrupoPerg:= PADR(cPerg, 10)
	Local i, j
	Local _sAlias 	:= Alias()

	dbSelectArea("SX1")
	dbSetOrder(1)
	
	//-- Estrutura das perguntas para o parametro MV_OPERADO
	//-- Pergunta 1: Operador 1
	AADD(aRegs, {cGrupoPerg, "01", "Operador 1", "", "", "MV_CH1", "C", 6, 0, 0, "G", "", "MV_PAR01",;
	             "", "", "@!", 'Posicione("Z0U", 1, xFilial("Z0U") + ALLTRIM(MV_PAR01), "Z0U_NOME") <> "" ',;
	             "Z0U", "Informe o código do primeiro operador. Pressione F3 para consultar."})
	
	//-- Pergunta 2: Operador 2
	AADD(aRegs, {cGrupoPerg, "02", "Operador 2", "", "", "MV_CH2", "C", 6, 0, 0, "G", "", "MV_PAR02",;
	             "", "", "@!", 'Posicione("Z0U", 1, xFilial("Z0U") + ALLTRIM(MV_PAR02), "Z0U_NOME") <> "" ',;
	             "Z0U", "Informe o código do segundo operador. Pressione F3 para consultar."})

	//-- Loop para gravar os registros na SX1, caso não existam
	For i := 1 to Len(aRegs)
		If !dbSeek(cGrupoPerg + aRegs[i,2])
			RecLock("SX1", .T.)
			For j := 1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j, aRegs[i,j])
				Endif
			Next j
			MsUnlock()
			dbCommit()
		EndIf
	Next i
 
	dbSelectArea(_sAlias)
Return
