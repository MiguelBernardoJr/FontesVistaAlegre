#Include "Rwmake.ch" 
#Include "Protheus.ch"
#Include "TopConn.ch"
#Include "Totvs.ch"

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  06.04.2017                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Regra: Validacao para ver se todos os itens da solicitacao estao liberados.    |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function VACOMM02( cFilSC, cNumSC )
Local aArea		:= GetArea()
Local _cQry 	:= ""
Local cAlias	:= GetNextAlias()
Local lContinua	:= .F.

_cQry := " SELECT R_E_C_N_O_ RECNO " + CRLF
_cQry += " FROM " + RetSqlName('SC1') + CRLF
_cQry += " WHERE  " + CRLF
_cQry += " 	C1_FILIAL='"+cFilSC+"' " + CRLF
_cQry += " AND C1_NUM='"+cNumSC+"'  " + CRLF
_cQry += " AND C1_APROV <> 'L' " + CRLF
_cQry += " AND D_E_L_E_T_=' '  "

If Select(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAlias),.F.,.F.) 

lContinua := (cAlias)->(Eof())
If lContinua
	// nao foi encontrado nenhuma solicitacao com o campo C1_APROV <> 'L'
	COMM02VA( cFilSC, cNumSC )
EndIf

(cAlias)->(DbCloseArea())

RestArea(aArea)
Return nil

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  06.04.2017                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Regra: 1- Tem na tabela de preco um produto para o fornecedor.                 |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function COMM02VA( cFilSC, cNumSC )

Local aArea			:= GetArea()
Local _cQry 		:= ""
Local cAlias		:= GetNextAlias()
Local cCodTes    	:= GetMV("MV_TESIMPC",,"001")

local _cUserIDOld   := __cUserID
local cUserNameOld  := cUserName
local cUsuarioOld   := cUsuario

Local aUser			:= {}

Private lMsErroAuto := .F.
Private lErroAuto   := .F.
PRIVATE cA120Forn  	:= ""
PRIVATE cA120Loj    := ""

PswOrder( 2 ) // indice por Nome
PswSeek("defcomp", .T.)  // Pesquisa o Nome no cadastro de usuario
aUser := PSWRET( 1 )

If Len(aUser) > 0
	__cUserID := aUser[1][1]
	cUserName := aUser[1][2]
	cUsuario  := aUser[1][1]+aUser[1][2]

	// Abre tabelas envolvidas
	DbSelectArea("SC7")
	DbSetOrder(1)

	DbSelectArea("SB1")
	DbSetOrder(1)

	aCab   := {}
	aItem  := {}
	aItens := {}                       
	
	SC1->(DbSetOrder(1)) // 1: C1_FILIAL+C1_NUM+C1_ITEM
	If SC1->(DbSeek(cFilSC + cNumSC))
		While !SC1->(Eof()) .and. SC1->C1_NUM==cNumSC
			If Empty(SC1->C1_PEDIDO) .and. SB1->(DbSeek(xFilial("SB1") + SC1->C1_PRODUTO ))

				_cQry := " SELECT AIA_CODFOR, AIA_LOJFOR, AIA_CONDPG, AIA_CODTAB, AIA_DESCRI, AIB_PRCCOM " + CRLF
				_cQry += " FROM " + RetSqlName('AIA') + " A " + CRLF
				_cQry += " JOIN " + RetSqlName('AIB') + " B ON AIA_FILIAL=AIB_FILIAL AND AIA_CODFOR=AIB_CODFOR AND AIA_LOJFOR=AIB_LOJFOR AND AIA_CODTAB=AIB_CODTAB AND A.D_E_L_E_T_=' ' AND B.D_E_L_E_T_=' ' " + CRLF
				_cQry += " WHERE " + CRLF
				_cQry += " 	AIA_FILIAL='"+cFilSC+"' " + CRLF
				_cQry += " AND AIB_CODPRO='"+SC1->C1_PRODUTO+"' " + CRLF
				_cQry += " AND AIA_DATATE >= CONVERT(VARCHAR, GETDATE(),112) " + CRLF
				_cQry += " ORDER BY A.R_E_C_N_O_ DESC " + CRLF

				If Select(cAlias) > 0
					(cAlias)->(DbCloseArea())
				EndIf

				dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAlias),.F.,.F.) 

				If (cAlias)->(Eof())
					Aviso('AVISO', 'Nao foi localizado nenhuma tabela ativa para o produto: ' + Alltrim(SC1->C1_PRODUTO), {'Ok'})	
				Else
				
					cA120Forn  := (cAlias)->AIA_CODFOR
					cA120Loj   := (cAlias)->AIA_LOJFOR
					
					If Len(aCab) == 0
						_cCodigo := GetSX8Num('SC7','C7_NUM')
						AAdd( aCab,  { "C7_FILIAL"	, xFilial("SC7")	        , Nil } )
						AAdd( aCab,  { "C7_TIPO"	, "1"				        , Nil } )
						AAdd( aCab,  { "C7_NUM"		, _cCodigo 				    , Nil } )
						AAdd( aCab,  { "C7_EMISSAO"	, Z0B->Z0B_DATA				, Nil } )
						AAdd( aCab,  { "C7_FORNECE" , cA120Forn      			, Nil } )
						AAdd( aCab,  { "C7_LOJA"	, cA120Loj					, Nil } )
						AAdd( aCab,  { "C7_COND"	, (cAlias)->AIA_CONDPG		, Nil } )
						AAdd( aCab,  { "C7_CONTATO"	, "AUTO"					, Nil } )
						AAdd( aCab,  { "C7_FILENT"	, xFilial("SC7")			, Nil } )
					EndIf
			
					aItem := {}
					AAdd( aItem, { "C7_ITEM"	, SC1->C1_ITEM				, Nil } )
					AAdd( aItem, { "C7_PRODUTO"	, SC1->C1_PRODUTO			, Nil } )
					AAdd( aItem, { "C7_UM"		, SC1->C1_UM				, Nil } )
					AAdd( aItem, { "C7_QUANT"	, SC1->C1_QUANT				, Nil } )
					AAdd( aItem, { "C7_PRECO"	, (cAlias)->AIB_PRCCOM		, Nil } )
					AAdd( aItem, { "C7_TOTAL"	, (cAlias)->AIB_PRCCOM*SC1->C1_QUANT , Nil } )
					AAdd( aItem, { "C7_LOCAL"	, SC1->C1_LOCAL      		, Nil } )
					AAdd( aItem, { "C7_NUMSC"	, SC1->C1_NUM				, Nil } )
					AAdd( aItem, { "C7_ITEMSC"	, SC1->C1_ITEM				, Nil } ) // AAdd( aItem, { "C7_DINICOM"	, SC1->C1_DATPRF 			, Nil } )
					AAdd( aItem, { "C7_DATPRF"	, SC1->C1_DATPRF 			, Nil } )
					
					If Empty(SB1->B1_TE)
						AAdd( aItem, { "C7_TES"	, SB1->B1_TE				, Nil } )
					Else
						AAdd( aItem, { "C7_TES"	, cCodTes					, Nil } )
					EndIf
					
					aAdd(aItens, aItem)
				EndIf
				(cAlias)->(DbCloseArea())
			EndIf
			
			SC1->(DbSkip())
		EndDo
		
		If Len(aItens) > 0 
			Begin Transaction
				MSExecAuto({|x,y,z|Mata120(1,x,y,z)}, aCab, aItens, 3 )
				
				If lMsErroAuto      
					lErroAuto := .T.
					RollbackSX8()
					MostraErro()
					DisarmTransaction()
				Else
					ConfirmSX8()
				EndIf
			End Transaction
		EndIf
		
	EndIf
	
	__cUserID  := _cUserIDOld
	cUserName := cUserNameOld
	cUsuario  := cUsuarioOld
EndIf

RestArea(aArea)
Return nil