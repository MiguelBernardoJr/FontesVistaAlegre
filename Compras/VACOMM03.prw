#Include "Rwmake.ch" 
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "Totvs.ch"

/* ===  D  O  C  U  M  E  N  T  A  Ç  Ã  O   ===
=======================================================================================


-> atualizar <-

Campo: 		A3_GERASE2
X3_VALID: 	Pertence("SNFP")
X3_CBOX: 	S=Contas a Pagar;F=Folha de Pagamento;N=Sem interface;P=Ped. Compras
---------------------------------------------------------------------------------------
Campo:		A3_FORNECE	
X3_WHEN:	M->A3_GERASE2 $ ("SP")                                      
---------------------------------------------------------------------------------------
Campo:		A3_LOJA   
X3_WHEN:	M->A3_GERASE2 $ ("SP")                                      

=======================================================================================

-> Criar <-
Campo: 		E3_XDTPGTO
Tipo:  		Data
Contexto:	Real
Propried.:  Visualizar
Titulo:		Dt. Pgto    
Descricao:	Dt. Processamento Pagto  
Help:		Este campo é preenchido automaticamente, no momento de executado a rotina: 
			"Atual. Pagto. Comiss";        
Uso:		Usado, Browse

---------------------------------------------------------------------------------------
Campo:		E3_XCODPED
Tipo:		Caracter
Tamanho:	6
Contexto:	Real
Propriedade:Alterar
Titulo:		Cod. Pedido 
DescriÃ§ão:	Cod. Pedido 
Help:		Preenchido na rotina VACOMM03, no processamento do titulo financeiro, com 
			o codigo: C7_NUM;
Browse:		SIM
---------------------------------------------------------------------------------------

Campo:		E3_XCODFOR
Tipo:		Caracter
Tamanho:	8
Contexto:	Real
Propriedade:Alterar
Titulo:		Cod. Fornec.
DescriÃ§ão:	Cod. Fornec.
Help:		Preenchido na rotina VACOMM03, no processamento do titulo financeiro, com 
			o codigo: C7_FORNECE+C7_LOJA;
Browse:		SIM
---------------------------------------------------------------------------------------
 

Campo:		E3_XOBSERV
Tipo:		Memo
Contexto:	Real
Propriedade:Alterar
Titulo:		Observacao  
DescriÃ§ão:	Observacao  
Help:		Campo de observacao, preenchido com informacoes de controle ao pagamento 
			dos titulos;
---------------------------------------------------------------------------------------

*/
 
 
/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  19.04.2017                                                              |
 | Desc:  Processamento a partir da rotina: "Atual. Pagto Comiss", para gerar o   |
 |       pedido de compras.                                                       |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function M530FIM()
	// Alert('PE: M530FIM')
	Processa( { || fGeraSC7() }, 'Gerando Pedido de Compras de Comissão.', 'Aguarde ...', .F. )
Return nil

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  19.04.2017                                                              |
 | Desc:  ExecAuto.                                                               |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fGeraSC7()

Local aArea			:= GetArea()
Local _cQry			:= ""
Local _cAlias		:= GetNextAlias()

Local cCodTes    	:= GetMV("JR_TESIMPC",,"001")
Local cProdCod    	:= GetMV("JR_PRDCOM3",,"170040") // PRODUTO COMISSAO SF1 -> SE3 -> SC7
Local cCodCond    	:= GetMV("JR_CONDPGT",,"001") 	 // CONDICAO DE PAGAMENTO

local _cUserIDOld   := __cUserID
local cUserNameOld  := cUserName
local cUsuarioOld   := cUsuario

Local aUser			:= {}
// Parametros:
Local _cEmisDe		:= MV_PAR02
Local _cEmisAte		:= MV_PAR03
Local _cVendDe		:= MV_PAR04
Local _cVendAte		:= MV_PAR05
Local _cDtPgto		:= MV_PAR06
Local _cFormaPg		:= MV_PAR12
Local _cConsFil 	:= MV_PAR13
Local _cFilDe		:= MV_PAR14
Local _cFilAte		:= MV_PAR15

Private lMsErroAuto := .F.
Private lErroAuto   := .F.

_cQry := " SELECT E3_FILIAL, A3_FORNECE, A3_LOJA, SUM(E3_COMIS) TOTAL_E3_COMIS " + CRLF
_cQry += " FROM SE3010 E3 " + CRLF
_cQry += " JOIN SA3010 A3 ON A3_FILIAL=' ' AND A3_COD=E3_VEND " + CRLF
_cQry += " 				AND A3.D_E_L_E_T_=' ' AND E3.D_E_L_E_T_=' ' " + CRLF
_cQry += " WHERE  " + CRLF

If _cConsFil == 1
	_cQry += " 	E3_FILIAL BETWEEN '" + _cFilDe + "' AND '" + _cFilAte + "' " + CRLF
Else
	_cQry += " 	E3_FILIAL BETWEEN '  ' AND 'ZZ' " + CRLF
EndIf

_cQry += " AND E3_VEND BETWEEN '"+_cVendDe+"' AND '"+_cVendAte+"' " + CRLF
_cQry += " AND E3_PREFIXO = 'COM' " + CRLF
_cQry += " AND E3_EMISSAO BETWEEN '"+DtoS(_cEmisDe)+"' AND '"+DtoS(_cEmisAte)+"' " + CRLF
_cQry += " AND E3_DATA = '" + dtoS(If( _cFormaPg == 1,SE3->E3_VENCTO,_cDtPgto)) + "' " + CRLF
_cQry += " AND E3_XDTPGTO=' ' " + CRLF
_cQry += " AND A3_PAGACOM='S' " + CRLF
_cQry += " AND A3_GERASE2='P' " + CRLF
_cQry += " AND A3_FORNECE<>' ' " + CRLF
_cQry += " GROUP BY E3_FILIAL, A3_FORNECE, A3_LOJA " + CRLF

DbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.) 
memowrite("C:\TOTVS_RELATORIOS\VACOMM03.txt", _cQry)
If !(_cAlias)->(Eof())

	PswOrder( 2 ) // indice por Nome
	PswSeek("administrador", .T.)  // Pesquisa o Nome no cadastro de usuario
	aUser := PSWRET( 1 )

	If Len(aUser) > 0
	
		__cUserID := aUser[1][1]
		cUserName := aUser[1][2]
		cUsuario  := aUser[1][1]+aUser[1][2]

		DbSelectArea("SC7")
		DbSetOrder(1)

		DbSelectArea("SB1")
		DbSetOrder(1)
		
		(_cAlias)->(DbGoTop())
		While !(_cAlias)->(Eof())

			aCab   := {}
			aItem  := {}
			aItens := {}                       

			_cCodigo := GetSX8Num('SC7','C7_NUM')
			AAdd( aCab,  { "C7_FILIAL"	, (_cAlias)->E3_FILIAL      , Nil } )
			AAdd( aCab,  { "C7_TIPO"	, "1"				        , Nil } )
			AAdd( aCab,  { "C7_NUM"		, _cCodigo 				    , Nil } )
			AAdd( aCab,  { "C7_EMISSAO"	, dDataBase					, Nil } )
			AAdd( aCab,  { "C7_FORNECE" , (_cAlias)->A3_FORNECE     , Nil } )
			AAdd( aCab,  { "C7_LOJA"	, (_cAlias)->A3_LOJA		, Nil } )
			AAdd( aCab,  { "C7_COND"	, cCodCond  				, Nil } )
			AAdd( aCab,  { "C7_CONTATO"	, "AUTO"					, Nil } )
			AAdd( aCab,  { "C7_FILENT"	, (_cAlias)->E3_FILIAL		, Nil } )
		
			aItem := {}
			AAdd( aItem, { "C7_ITEM"	, StrZero( 1, TamSX3('C7_ITEM')[1])	, Nil } )
			AAdd( aItem, { "C7_PRODUTO"	, Posicione('SB1', 1, xFilial('SB1')+cProdCod,'B1_COD') , Nil } )
			AAdd( aItem, { "C7_UM"		, SB1->B1_UM				, Nil } )
			AAdd( aItem, { "C7_QUANT"	, 1							, Nil } )
			AAdd( aItem, { "C7_PRECO"	, (_cAlias)->TOTAL_E3_COMIS , Nil } )
			AAdd( aItem, { "C7_TOTAL"	, (_cAlias)->TOTAL_E3_COMIS , Nil } )
			AAdd( aItem, { "C7_LOCAL"	, SB1->B1_LOCPAD      		, Nil } )
			// AAdd( aItem, { "C7_NUMSC"	, SC1->C1_NUM				, Nil } )
			// AAdd( aItem, { "C7_ITEMSC"	, SC1->C1_ITEM				, Nil } ) // AAdd( aItem, { "C7_DINICOM"	, SC1->C1_DATPRF 			, Nil } )
			// AAdd( aItem, { "C7_DATPRF"	, SC1->C1_DATPRF 			, Nil } )

			If Empty(SB1->B1_TE)
				AAdd( aItem, { "C7_TES"	, SB1->B1_TE				, Nil } )
			Else
				AAdd( aItem, { "C7_TES"	, cCodTes					, Nil } )
			EndIf
			aAdd(aItens, aItem)

			Begin Transaction
				MSExecAuto({|x,y,z|Mata120(1,x,y,z)}, aCab, aItens, 3 )
				If lMsErroAuto      
					lErroAuto := .T.
					RollbackSX8()
					MostraErro()
					DisarmTransaction()
				Else
				
					ConfirmSX8()
					
					_cUpd := " UPDATE SE3010 " + CRLF
					_cUpd += " 		  SET E3_XDTPGTO = CONVERT(VARCHAR, GETDATE(),112) " + CRLF
					_cUpd += " 		  	, E3_XCODPED = '" + _cCodigo + "'  " + CRLF
					_cUpd += " 		  	, E3_XCODFOR = '" + (_cAlias)->A3_FORNECE+(_cAlias)->A3_LOJA + "' " + CRLF
					_cUpd += " WHERE " + CRLF
					_cUpd += " 	R_E_C_N_O_ IN ( " + CRLF
					_cUpd += " 		SELECT E3.R_E_C_N_O_ " + CRLF
					_cUpd += " 		FROM SE3010 E3 " + CRLF
					_cUpd += " 		JOIN SA3010 A3 ON A3_FILIAL=' ' AND A3_COD=E3_VEND " + CRLF
					_cUpd += " 						AND A3.D_E_L_E_T_=' ' AND E3.D_E_L_E_T_=' ' " + CRLF
					_cUpd += " 		WHERE  " + CRLF
					
					If _cConsFil == 1
						_cUpd += " 	       E3_FILIAL BETWEEN '"+_cFilDe+"' AND '"+_cFilAte+"' " + CRLF
					Else
						_cUpd += " 	       E3_FILIAL BETWEEN '  ' AND 'ZZ' " + CRLF
					EndIf

					_cUpd += "         AND E3_VEND BETWEEN '"+_cVendDe+"' AND '"+_cVendAte+"' " + CRLF
					_cUpd += "         AND E3_PREFIXO = 'COM' " + CRLF
					_cUpd += "         AND E3_EMISSAO BETWEEN '"+DtoS(_cEmisDe)+"' AND '"+DtoS(_cEmisAte)+"' " + CRLF
					_cUpd += "         AND E3_DATA = '" + dtoS(If( _cFormaPg == 1,SE3->E3_VENCTO,_cDtPgto)) + "' " + CRLF
					_cUpd += "         AND E3_XDTPGTO =' ' " + CRLF
					_cUpd += "         AND A3_PAGACOM ='S' " + CRLF
					_cUpd += "         AND A3_GERASE2 ='P' " + CRLF
					_cUpd += " 		   AND A3_FORNECE = '" + (_cAlias)->A3_FORNECE + "' " + CRLF
					_cUpd += " 		   AND A3_LOJA    = '" + (_cAlias)->A3_LOJA + "' " + CRLF
					_cUpd += " ) "
					
					If (TCSQLExec(_cUpd) < 0)
						Alert("Erro ao cancelar notas do agendamento de entrega " + TCSQLError())
					endIf
					
				EndIf
			End Transaction
		
			(_cAlias)->(DbSkip())
		EndDo

		__cUserID  := _cUserIDOld
		cUserName := cUserNameOld
		cUsuario  := cUsuarioOld
		
	EndIf		
	
EndIf
(_cAlias)->(DbCloseArea())

RestArea(aArea)
Return nil

/* 
User Function M530OK()
	Alert('PE: M530OK')
Return .T.

User Function M530AGL()
	Alert('PE: M530AGL')
Return .T.
 */
 
 /*  
User Function M530TIT()
	Alert('PE: M530TIT')
Return nil

User Function MSE2530()
	Alert('PE: MSE2530')
Return nil
*/