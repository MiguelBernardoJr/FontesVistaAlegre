#Include "Rwmake.ch" 
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "Totvs.ch"
#Include "TryException.ch"

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  28.03.2017                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function VACOMM01(lDeleta)
Local aArea 	:= GetArea()
Local lRet		:= .T.

If cEmpAnt == '01'
	DbSelectArea("SC7")
	SC7->(DbSetOrder(1))

	TryException
		BeginTran()	
			For nI := 1 to Len(aCols)   
				If !Empty(cNFiscal) .and. !Empty(cSerie)
					lRet := SE3Comiss( lDeleta , aCols[nI] )
				EndIf
				
				If !lRet
					DisarmTransaction()
					exit    					 
				EndIf
			Next nI
		EndTran()
	CatchException Using oException
		Alert("Erro ao processar geração de comissão: " + CRLF + oException:Description)
		ConOut(oException:ErrorStack)
		DisarmTransaction() 
	EndException
EndIf

RestArea(aArea)
Return lRet

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  29.03.2017                                                              |
 | Desc:  Função copiada do fonte VACOMA03; Desenvolvida por outra consultoria,   |
 |       será necessaria algumas adaptaçães;                                      |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function SE3Comiss( lDeleta, _aCols )

Local aAreaSC7  := SC7->(GetArea())
Local aAreaSE3  := SE3->(GetArea())
Local aAutCom 	:= {}
Local lGravaE3	:= .T.   
Local lSubstE3 	:= .F.

Local cC7NUM    := _aCols[ aScan( aHeader ,{ |x| x[2] == 'D1_PEDIDO '} ) ]
Local cC7ITEM   := _aCols[ aScan( aHeader ,{ |x| x[2] == 'D1_ITEMPC '} ) ]
Local dEmissao  := _aCols[ aScan( aHeader ,{ |x| x[2] == 'D1_EMISSAO'} ) ]

Private LGRAVA

DbSelectArea("SC7")
SC7->(DbSetOrder(1))
If Dbseek (xFilial('SC7') + cC7NUM + cC7ITEM )
	
	DbSelectArea("SE3")
	SE3->(DbSetOrder(1)) 
	If Dbseek( xFilial('SE3')+'COM'+ cNFiscal + SUBSTR(SC7->C7_ITEM,3,2) + SUBSTR(SC7->C7_ITEM,3,2) + SC7->C7_X_CORRE ) 
		If lDeleta
			If Empty(SE3->E3_DATA)
				lSubstE3		:= .T.
			Else
				Alert('Esta operacao sera cancelada, pois a Comissao foi processada no dia: '+DtoC(SE3->E3_DATA))
				lGravaE3 := .F.
			EndIf	
		Else
		
			If MsgYesNo("Ja Existe um Registro de Comissao para este pedido!!!"+CRLF+"Deseja susbtitui-lo?")
				lGravaE3	:= .T.
				lSubstE3	:= .T.
			Else
				lGravaE3	:= .F.	
			Endif
		EndIf
	Endif

    If lGravaE3
		
		If lSubstE3
			RecLock("SE3",.F.)
				dbDelete()
			SE3->(MsUnLock())
		Endif	             

		If !lDeleta            
			If Posicione( 'SA3', 1, xFilial('SA3')+SC7->C7_X_CORRE, 'A3_PAGACOM' ) <> 'N'
				//Gerando Comissao
				aAdd(aAutCom,{"E3_VEND"		, SC7->C7_X_CORRE , Nil} )
				aAdd(aAutCom,{"E3_NUM"		, cNFiscal		  , Nil} )
				aAdd(aAutCom,{"E3_SERIE"	, cSerie		  , Nil} )
				aAdd(aAutCom,{"E3_EMISSAO"	, dEmissao		  , Nil} )               	
				aAdd(aAutCom,{"E3_CODCLI"	, '000002'		  , Nil} )
				aAdd(aAutCom,{"E3_LOJA"		, '01'			  , Nil} )
				aAdd(aAutCom,{"E3_BASE"		, SC7->C7_X_COMIS/SC7->C7_QUANT*_aCols[ aScan( aHeader ,{ |x| x[2] == 'D1_QUANT  '} ) ] , Nil} )    // foi feito desta forma para nao gerar problemas de arredondamento no calculo da porcentagem  (valor base sera a comissao e % sera 100%)
				aAdd(aAutCom,{"E3_PORC"		, 100			  , Nil} )    // foi feito desta forma para nao gerar problemas de arredondamento no calculo da porcentagem
				aAdd(aAutCom,{"E3_PREFIXO"	, 'COM'			  , Nil} )
				aAdd(aAutCom,{"E3_PARCELA"	, SUBSTR(SC7->C7_ITEM,3,2), Nil} )
				aAdd(aAutCom,{"E3_TIPO"		, "DH"			  , Nil} )
				aAdd(aAutCom,{"E3_PEDIDO"	, SC7->C7_NUM	  , Nil} )
				aAdd(aAutCom,{"E3_SEQ"		, SUBSTR(SC7->C7_ITEM,3,2), Nil} ) 
				aAdd(aAutCom,{"E3_VENCTO"	, dEmissao		  , Nil} ) // tratar a data de vencimento
				aAdd(aAutCom,{"E3_BAIEMI"	, 'E'			  , Nil} ) 
				aAdd(aAutCom,{"E3_ORIGEM"	, 'C'			  , Nil} ) 
				aAdd(aAutCom,{"E3_CODPROD"	, _aCols[ aScan( aHeader ,{ |x| x[2] == 'D1_COD    '} ) ], Nil} )
				aAdd(aAutCom,{"E3_DESCPRO"	, Posicione('SB1',1, xFilial('SB1')+_aCols[ aScan( aHeader ,{ |x| x[2] == 'D1_COD    '} ) ], 'B1_DESC'), Nil} ) 
				aAdd(aAutCom,{"E3_QTDPROD"	, _aCols[ aScan( aHeader ,{ |x| x[2] == 'D1_QUANT  '} ) ], Nil} )
				// aAdd(aAutCom,{"E3_VLRPROD"	, SC7->C7_X_COMIS/SC7->C7_QUANT, Nil} )
				aAdd(aAutCom,{"E3_VLRPROD"	, _aCols[ aScan( aHeader ,{ |x| x[2] == 'D1_TOTAL  '} ) ], Nil} )
				
				//MSExecAuto({|x,y| Mata490(x,y)},aAutCom,3)
				Mata490(aAutCom,3)
			EndIf
		EndIf	
		
	Endif  	
Endif 

RestArea(aAreaSE3)
RestArea(aAreaSC7)

Return lGravaE3


/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  29.03.2017                                                              |
 | Desc:  Função copiada do fonte VACOMA03; Desenvolvida por outra consultoria,   |
 |       será necessaria algumas adaptaçães;                                      |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function M01VldDel()
Local aArea		:= GetArea()
Local lRet 		:= .T.
Local _cQry     := ""
Local cAlias    := ""


DbSelectArea("SE3")
SE3->(DbSetOrder(1)) 
//If Dbseek( xFilial('SE3')+'COM'+ cNFiscal + SUBSTR(SC7->C7_ITEM,3,2) + SUBSTR(SC7->C7_ITEM,3,2) + SC7->C7_X_CORRE ) 
If Dbseek( xFilial('SE3') + 'COM' + cNFiscal )

	_cQry := " SELECT R_E_C_N_O_ " + CRLF
	_cQry += " FROM " + RetSqlName('SE3') + CRLF
	_cQry += " WHERE " + CRLF
	_cQry += " 	   E3_FILIAL='"+xFilial('SE3')+"' " + CRLF
	_cQry += " AND E3_PREFIXO='COM' " + CRLF
	_cQry += " AND E3_NUM='"+cNFiscal+"' " + CRLF
	_cQry += " AND E3_DATA=' ' " + CRLF

	cAlias := CriaTrab(,.F.)   
	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf
		
	DbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAlias),.F.,.F.) 

	lRet := !(cAlias)->(Eof())

	(cAlias)->(DbCloseArea())
	
EndIf
RestArea(aArea)
Return lRet


/*
DOCUMENTACAO

criar campos:

A3_PAGACOM
Caracter
Tamanho: 1
Titulo: Paga Comissao            
Lista Opcoes: S=Sim;N=Nao                                                                                                                     
Inic. Padrao: "S"                                                                                                                             
Browse: Sim

*/