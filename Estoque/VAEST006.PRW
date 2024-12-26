#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "Fileio.ch"
#INCLUDE "FWMBROWSE.CH"
#Include "TryException.ch"

//Variáveis Estáticas
Static cTitulo := "Importação do Trato"

/*---------------------------------------------------------------------*
 | Func:  VAEST006                                                     |
 | Autor: Miguel Martins Bernardo Junior                               |
 | Data:  06.12.2016                                                   |
 | Desc:  Criação de rotina de importacao com MVC                      |
 | Obs.:  -                                                            |
 *---------------------------------------------------------------------*/
User Function VAEST006()
	
	Local oBrowse 
	Private lPTO	:= .T.
	Private cLogFile := ""
	
	//Instãnciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()
	
	//Setando a tabela de cadastro de Autor/Interprete
	oBrowse:SetAlias("Z02")

	//Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)
	
	oBrowse:SetFilterDefault( "Z02_TPARQ == '4'" )
	
	//Legendas
	oBrowse:AddLegend( "Z02_TPARQ == '4'", "BLUE"   , "Trato" )

	//Ativa a Browse
	oBrowse:Activate()
	
Return nil

/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Autor: Miguel Martins Bernardo Junior                               |
 | Data:  06.12.2016                                                   |
 | Desc:  Criação do menu MVC                                          |
 | Obs.:  -                                                            |
 *---------------------------------------------------------------------*/
Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE "Pesquisar"  	   ACTION "PesqBrw"          OPERATION 1 ACCESS 0 DISABLE MENU
	ADD OPTION aRotina TITLE 'Visualizar' 	   ACTION 'VIEWDEF.VAEST006' OPERATION 2 ACCESS 0 
	ADD OPTION aRotina TITLE 'Incluir' 	   	   ACTION 'VIEWDEF.VAEST006' OPERATION 3 ACCESS 0 
	ADD OPTION aRotina TITLE 'Excluir' 	   	   ACTION 'VIEWDEF.VAEST006' OPERATION 5 ACCESS 0 
	ADD OPTION aRotina TITLE 'Imprimir' 	   ACTION 'VIEWDEF.VAEST006' OPERATION 8 ACCESS 0 
	ADD OPTION aRotina TITLE 'Importar Trato'  ACTION 'u_Est06Trato()'   OPERATION 3 ACCESS 0 
	// ADD OPTION aRotina TITLE 'Copiar' 	   	   ACTION 'VIEWDEF.VAEST006' OPERATION 9 ACCESS 0 
Return aRotina

/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Autor: Miguel Martins Bernardo Junior                               |
 | Data:  06.12.2016                                                   |
 | Desc:  Criação da visão MVC                                         |
 | Obs.:  -                                                            |
 *---------------------------------------------------------------------*/
Static Function ViewDef()
	Local oView		:= Nil
	Local oModel	:= FWLoadModel('VAEST006')
	
	Local oStPai	:= FWFormStruct(2, 'Z02')
	Local oStFilho	:= FWFormStruct(2, 'Z04')
	Local oStTot1	:= FWCalcStruct(oModel:GetModel('TOT_SALDO1'))
	
	//Estruturas das tabelas e campos a serem considerados
	Local aStruZ02	:= Z02->(DbStruct())
	Local aStruZ04	:= Z04->(DbStruct())

	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	//Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField('VIEW_Z02' , oStPai	 , 'Z02MASTER')
	oView:AddGrid ('VIEW_Z04' , oStFilho , 'Z04DETAIL')
	oView:AddField('VIEW_TOT1', oStTot1  , 'TOT_SALDO1')
	
	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('BVIEW_Z02' , 15 )
	oView:CreateHorizontalBox('BVIEW_Z04' , 75 )
	oView:CreateHorizontalBox('EMBAIXO'   , 10 )
	oView:CreateVerticalBox('EMBESQ'  	  , 50 , 'EMBAIXO' )
	
	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_Z02'	,'BVIEW_Z02' )
	oView:SetOwnerView('VIEW_Z04'	,'BVIEW_Z04' )
	oView:SetOwnerView('VIEW_TOT1'	,'EMBESQ')
	
	//Habilitando título
	oView:EnableTitleView('VIEW_Z02','Cabecalho de Importacao')
	oView:EnableTitleView('VIEW_Z04','Cadastro de Trato')
	
	oStPai:RemoveField("Z02_TPARQ")
Return oView

/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Autor: Miguel Martins Bernardo Junior                               |
 | Data:  06.12.2016                                                   |
 | Desc:  Criação do modelo de dados MVC                               |
 | Obs.:  -                                                            |
 *---------------------------------------------------------------------*/
Static Function ModelDef()
	Local oModel 		:= Nil
	Local oStPai 		:= FWFormStruct(1, 'Z02')
	Local oStFilho 		:= FWFormStruct(1, 'Z04')
	Local aZ04Rel		:= {}
	
	//Criando o modelo e os relacionamentos
	oModel := MPFormModel():New('EST006')
	
	oModel:AddFields('Z02MASTER',/*cOwner*/,oStPai)
	oModel:AddGrid('Z04DETAIL','Z02MASTER',oStFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner Ã© para quem pertence
	
	//Fazendo o relacionamento entre o Pai e Filho
	aAdd(aZ04Rel, {'Z04_FILIAL', 'Z02_FILIAL' } )
	aAdd(aZ04Rel, {'Z04_SEQUEN', 'Z02_SEQUEN' } )
	
	oModel:SetRelation('Z04DETAIL', aZ04Rel, Z04->(IndexKey(1))) //IndexKey -> quero a ordenação e depois filtrado
	// removido para aceitar entrada de dados em duplicidade...
	// Solicitação: Toshio
	// Data 2017/01/20
	//oModel:GetModel('Z04DETAIL'):SetUniqueLine({"Z04_FILIAL","Z04_SEQUEN","Z04_LOTE"})	//Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}
	oModel:SetPrimaryKey( {"Z02_FILIAL","Z02_SEQUEN"} )
	
	//Setando as descrições
	oModel:SetDescription("Rotina de Integração de Trato")
	oModel:GetModel('Z02MASTER'):SetDescription('Cabecalho de Importacao')
	oModel:GetModel('Z04DETAIL'):SetDescription('Integração dos Tratos')
	
	//Adicionando totalizadores
	oModel:AddCalc('TOT_SALDO1', 'Z02MASTER', 'Z04DETAIL', 'Z04_CURRAL', 'XX_TOTAL' , 'COUNT', , , "Total Imp. Trato:" ) 
Return oModel



/*---------------------------------------------------------------------*
 | Func:  EST006                                                       |
 | Autor: Miguel Martins Bernardo Junior                               |
 | Data:  06.12.2016                                                   |
 | Desc:  Chamada a pontos de entrada                                  |
 | Obs.:  -                                                            |
 *---------------------------------------------------------------------*/
User Function EST006()
Local aArea		 := GetArea()
Local lRet 		 := .T.
Local aParam     := PARAMIXB
Local oObj       := aParam[1]
Local cIdPonto   := aParam[2]
Local cIdModel   := oObj:GetId()
Local cClasse    := oObj:ClassName()

Local nLinha     := 0
Local nQtdLinhas := 0
Local cMsg       := ''
Local aDados	 := {}
Local aAux		 := {}
Local cUpd		 := ""
Local cAlias	 := ""
Local _cQry		 := ""
Local xVar		 := {}
Local nI		 := 0

If cClasse == 'FWFORMGRID'
	nQtdLinhas := oObj:GetQtdLine()
	nLinha     := oObj:nLine
EndIf

If lPTO
	If cIdPonto ==  'MODELCOMMITTTS'
		
		If  oObj:NOPERATION == 3

			aDados:=ProcADADOS(oObj:ADEPENDENCY[1][2][1][3]:ACOLS)

			RecLock('Z02',.F.)
				Z02->Z02_CONTEU := U_ATOS(aDados)
				Z02->Z02_TPARQ  := '4'
			Z02->(MsUnLock())

			cUpd := "update " + retSQLName("Z04") +" "+CRLF
			cUpd += "   set Z04_FILIAL='"+xFilial('Z04')+"'"+CRLF
			cUpd += " where Z04_FILIAL=' '  " + CRLF
			cUpd += "   and Z04_SEQUEN='"+Z02->Z02_SEQUEN+"' "+CRLF
			cUpd += "   and D_E_L_E_T_=' ' "+CRLF
		   
			if (TCSqlExec(cUpd) < 0)
				UserException("TCSQLError() " + TCSQLError())
				DisarmTransaction() 
			endif

			If !Empty(aDados) // :=ProcADADOS(oObj:ADEPENDENCY[1][2][1][3]:ACOLS))
				tryexception
					ExecMestre(aDados)
					ApMsgInfo( 'Processamento terminado com sucesso.', 'ATENÇÃO' ) 
				CatchException Using oException
					u_ShowException(oException)
					DisarmTransaction()
					Final("O sistema será finalizado para manter a integridade dos dados...")
				EndException
			EndIf
			
		ElseIf oObj:NOPERATION == 5
		
			cUpd := "update " + retSQLName("Z04") +" "+CRLF
			cUpd += "   set D_E_L_E_T_='*'"+CRLF
			cUpd += " where Z04_FILIAL='"+xFilial('Z04')+"' " + CRLF
			cUpd += "   and Z04_SEQUEN='"+Z02->Z02_SEQUEN+"' "+CRLF
			cUpd += "   and D_E_L_E_T_=' ' "+CRLF
		
			if (TCSqlExec(cUpd) < 0)
				UserException("TCSQLError() " + TCSQLError())
				DisarmTransaction() 
			endif
		EndIf	

	ElseIf cIdPonto ==  'MODELPOS'

		If oObj:NOPERATION == 5
			
			cAlias    	:= GetNextAlias()
			_cQry := " select R_E_C_N_O_ RECNO " + CRLF
			_cQry += " from " + RetSQLName('Z04') + CRLF
			_cQry += " where " + CRLF
			_cQry += " 	   Z04_filial='"+xFilial('Z04')+"' " + CRLF
			_cQry += " and Z04_sequen='"+Z02->Z02_SEQUEN+"' " + CRLF
			_cQry += " and d_e_l_e_t_ = ' ' "
			
			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,ChangeQuery(_cQry)),(cAlias),.F.,.F.)
			TryException
				BeginTran()  			
					While !(cAlias)->(Eof())
					
						Z04->(DbGoTo((cAlias)->RECNO))
					
						xVar := &(Z04->Z04_NUMOP)
						
						For nI:=1 to Len(xVar)
							// U_vaest002(SubS(xVar[nI],1,TamSX3('C2_NUM')[1]))
							U_vaest002( xVar[nI] )
						Next nI
						
						(cAlias)->(DbSkip())
					EndDo
				EndTran()
			CatchException Using oException
				MsgStop("Erro ao processar Arquivo: " + CRLF + oException:Description)
				ConOut(oException:ErrorStack)
				DisarmTransaction() 
			EndException

			(cAlias)->(DbCloseArea())
		EndIf
	EndIf
EndIf
RestArea(aArea)
Return lRet


/*---------------------------------------------------------------------*
 | Func:  ProcADADOS                                                   |
 | Autor: Miguel Martins Bernardo Junior                               |
 | Data:  06.12.2016                                                   |
 | Desc:  Mandar para o ExecAuto apenas as linhas Ativas               |
 | Obs.:  -                                                            |
 *---------------------------------------------------------------------*/
Static Function ProcADADOS(aDados)
Local aDadAux := {}
Local i       := 0

For i:=1 to len(aDados)       
	aDados[i][2] := M->Z02_SEQUEN
	If !aDados[i, len(aDados[1])]
		aAdd(aDadAux , { DtoC(aDados[i][04]), ; // Z04_DTIMP
						 aDados[i][05], ;		// Z04_HRIMP
						 aDados[i][03], ;		// Z04_CURRAL
						 aDados[i][06], ;		// Z04_LOTE
						 AllTrim(Str(aDados[i][07])), ;
						 aDados[i][08], ;
						 AllTrim(Str(aDados[i][09])), ;
						 AllTrim(Str(aDados[i][10])), ;  
						 AllTrim(aDados[i][12])} )
	EndIf
next i

Return aDadAux



/*---------------------------------------------------------------------*
 | Func:  Est06Trato                                                   |
 | Autor: Miguel Martins Bernardo Junior                               |
 | Data:  07.12.2016                                                   |
 | Desc:  Importação do Trato - Alimentacao 						   |
 | Obs.:  -                                                            |
 *---------------------------------------------------------------------*/
User Function Est06Trato()
	Local aSay		:= {}
	Local aButton	:= {}
	Local nOpc		:= 0
	Local Titulo	:= 'Importação do Trato/Alimentação'
	Local cDesc		:= 'Esta rotina fará a ' + lower(Titulo)
	Local cDesc		+= ', confome estrutura definida '
	Local cDesc2	:= 'na tabela Z04.'
	Local lOk		:= .T.
	
	aAdd(aSay, cDesc)
	aAdd(aSay, cDesc2)
	
	aAdd( aButton, { 1, .T., { || nOpc := 1, FechaBatch() } } ) 
	aAdd( aButton, { 2, .T., { || FechaBatch() } } )
	
	FormBatch( Titulo, aSay, aButton ) 
	If nOpc == 1
		lPTO	:= .F.
		Processa( { || lOk := procAux()  },'Aguarde','Processando...',.F.) 
		lPTO	:= .T.
	EndIf 
	
Return nil

/*---------------------------------------------------------------------*
 | Func:  procAux                                                      |
 | Autor: Miguel Martins Bernardo Junior                               |
 | Data:  08.12.2016                                                   |
 | Desc:  Função Auxilar para mensagens de erro ser apresentadas de    |
 |        dentro do TryException.                                      |
 | Obs.:  -                                                            |
 *---------------------------------------------------------------------*/
Static Function procAux()
Local lOk 			:= .F.
Local cNomeFile	  	:= ""
Local aDados	  	:= U_ImpFile(@cNomeFile)
Private cNumOp  	:= ""
	TryException
		BeginTran()  
			If (lOk := Z04RunProc( aDados, cNomeFile ))
				ApMsgInfo( 'Processamento terminado com sucesso.', 'ATENÇÃO' ) 
			Else
				MsgStop( 'Processamento realizado com problemas.', 'ATENÇÃO' ) 
				DisarmTransaction() 
			EndIf
		EndTran()
	CatchException Using oException
		u_ShowException(oException)
		ConOut(oException:ErrorStack)
		DisarmTransaction() 
	EndException
return lOk


/*---------------------------------------------------------------------*
 | Func:  Z04RunProc                                                   |
 | Autor: Miguel Martins Bernardo Junior                               |
 | Data:  06.12.2016                                                   |
 | Desc:  Importação do Trato 										   |
 | Obs.:  -                                                            |
 *---------------------------------------------------------------------*/
Static Function Z04RunProc( aDados, cNomeFile )
Local aArea		  := GetArea()
Local lRet 		  := .F.
Local aCposCab	  := {}
Local aCposDet	  := {}
Local aAux		  := {}
Local cSequencia  := "" 
//local cInsumo     := "" 
local cReceita    := ""

If !Empty(aDados)
	If len(aDados[1]) == 10 // qtd de campos do arquivo de trato
		lRet := .T.
		
		cSequencia  := u_fChaveSX8('Z02','Z02_SEQUEN')  
		
		aAdd( aCposCab, { 'Z02_FILIAL'  , xFilial('Z02') } )
		aAdd( aCposCab, { 'Z02_SEQUEN' , cSequencia 	 } )
		aAdd( aCposCab, { 'Z02_ARQUIV' , cNomeFile 		 } )
		aAdd( aCposCab, { 'Z02_DTIMP'  , dDataBase       } )
		aAdd( aCposCab, { 'Z02_TPARQ'  , '4'			 } ) // 4 = Z04 - Trato
		aAdd( aCposCab, { 'Z02_CONTEU' , U_ATOS(aDados)	 } )
		
		ProcRegua(len(aDados))
		
		For i := 1 to len(aDados)
			
            if cToD(aDados[i,01]) <>  dDataBase
                UserException("Erro na linha [" + AllTrim(Str(i)) + "]. A data do Trato definida no arquivo [" + aDados[i,01] + "] é diferente da data base [" + DToC(dDataBase) + "].") 
            endif 
			if GetNewPar("VA_CODPROD","PROTHEUS") != "PROTHEUS"
				if Empty(cReceita := AllTrim(u_GetExata(aDados[i][06]))) 
	                UserException("Erro na linha [" + AllTrim(Str(i)) + "]. O código do produto tipo receita [" + AllTrim(aDados[i][06]) + "] não possui contrapartida para código de produto do Protheus.") 
				endif
				aDados[i][06] := cReceita
			endif
			aAux := {}
						
			aAdd( aAux, { 'Z04_FILIAL'  , xFilial('Z04') 	 } )
			aAdd( aAux, { 'Z04_SEQUEN'  , cSequencia     	 } ) 
			aAdd( aAux, { 'Z04_DTIMP'	, cToD(aDados[i,01]) } ) 
			aAdd( aAux, { 'Z04_HRIMP'	, aDados[i,02] 		 } ) 
			aAdd( aAux, { 'Z04_CURRAL'  , aDados[i,03]   	 } ) 
			aAdd( aAux, { 'Z04_LOTE'	, aDados[i,04]   	 } ) 
			aAdd( aAux, { 'Z04_NROCAB'	, Val(aDados[i,05])  } ) 
			aAdd( aAux, { 'Z04_DIETA'	, aDados[i][06]		 } ) 
			aAdd( aAux, { 'Z04_TOTREA'	, Val(aDados[i,07])  } ) 
			aAdd( aAux, { 'Z04_TOTAPR'	, Val(aDados[i,08])  } ) 
			aAdd( aAux, { 'Z04_ARMAZE'	, aDados[i,09]       } ) 
			aAdd( aAux, { 'Z04_ARMDIE'	, aDados[i,10]       } ) 
			aAdd( aCposDet, aAux )		
		Next i
		
		If U_ImportMVC( 'Z02', 'Z04', aCposCab, aCposDet, 'VAEST006' )
		
			ExecMestre(aDados)
			
		Else
			lRet := .F. 
		EndIf
	else
        UserException("O arquivo processado possui a quantidade de campos diferente de 10. Nao se trata de um arquivo de Trato.")	
	EndIf
EndIf
RestArea(aArea)
Return lRet


/*---------------------------------------------------------------------*
 | Func:  ExecMestre                                                   |
 | Autor: Miguel Martins Bernardo Junior                               |
 | Data:  09.12.2016                                                   |
 | Desc:  Chamada ao ExecAuto Desenvolvido pelo Andre                  |
 | Obs.:  -                                                            |
 *---------------------------------------------------------------------*/
static function ExecMestre(aDados)
local aAux 		:= {}
local cArmz 	:= "01"
local cCodPro	:= ""
local nQuant	:= 0
local i 		:= 0
local cUpd		:= ""
local aNumOp	:= {}

for i := 1 to len(aDados)
	// indice: B1LOTE    
	// campo: B1_XLOTE
	// procIndividuo( cLote , cRacao, nQuant, cArmz )
	// procIndividuo( aDados[i,04], Upper(aDados[i,06]), Val(aDados[i,08]), aDados[i,09] )
	aNumOp	:= {}
	AAdd( aNumOp , u_vaest004( aDados[i,04], Upper(aDados[i,06]), Val(aDados[i,08]), aDados[i,09], aDados[i,10] ) )
	
	if !Empty(aNumOp)
		Z04->(DbSetOrder(1))
		if Z04->(DbSeek(xFilial('Z04')+Z02->Z02_SEQUEN+aDados[i,04]))
			RecLock('Z04', .F.)
				Z04->Z04_NUMOP := u_AToS(aNumOp)
			Z04->(MsUnLock())	
		endIf		
	endIf
next i

Return nil


/*---------------------------------------------------------------------*
 | Func:  procIndividuo                                                |
 | Autor: Miguel Martins Bernardo Junior                               |
 | Data:  08.12.2016                                                   |
 | Desc:  Importação do Trato - Processamento por individuo 		   |
 | Obs.:  -                                                            |
 *---------------------------------------------------------------------*/
Static Function procIndividuo( cLote , cRacao, nQuant, cArmz )
Local nRegistros	:= 0
Local cAlias		:= GetNextAlias()
Local cQry 			:= ""
// Local cRacaoCod		:= ""
Local aNumOp		:= {}

	cQry := " SELECT B1_COD " + CRLF
	cQry += " FROM " + RetSQLName('SB1') + CRLF
	cQry += " WHERE " + CRLF
	cQry += " 		B1_FILIAL  = '" + xFilial('SB1') + "' " + CRLF
	cQry += " 	and B1_XLOTE   = '" + cLote + "' " + CRLF
	cQry += " 	AND D_E_L_E_T_ = ' ' "

	DbUseArea(.T.,'TOPCONN',TCGENQRY(,,ChangeQuery(cQry)),(cAlias),.F.,.F.)
	
	(cAlias)->(DbEval({|| nRegistros++ }))
	If nRegistros == 0
		UserException("Nao foi encontrado nenhum animal para o Lote: ["+cLote+"]. Por favor Verifique." )
	EndIf
	
	// If Empty( cRacaoCod := Posicione('SB1', 3, xFilial('SB1')+PadR(cRacao,TamSX3('B1_DESC')[1]), 'B1_COD' ) )
		// UserExceptionUserException("Nao foi encontrada a racão [" + cRacao + "] nenhum alimentação para o Lote: ["+cLote+"]. Por favor Verifique." )
	// EndIf
	
	aNumOp	:= {}
	(cAlias)->(DbGoTop())
	While !(cAlias)->(Eof())
		// aAdd( aNumOp , u_vaest004( (cAlias)->B1_COD, cRacaoCod, nQuant/nRegistros, cArmz ) )
		aAdd( aNumOp , u_vaest004( (cAlias)->B1_COD, cRacao, nQuant/nRegistros, cArmz ) )
		(cAlias)->(DbSkip())
	EndDo	
	(cAlias)->(DbCloseArea())

	Z04->(DbSetOrder(1))
	If Z04->(DbSeek(xFilial('Z04')+Z02->Z02_SEQUEN+cLote))
		RecLock('Z04', .F.)
			Z04->Z04_NUMOP := u_AtOs(aNumOp)
		Z04->(MsUnLock())	
	EndIf		
Return  nil

/* 
	Bibliotecas:
		- https://terminaldeinformacao.com/2015/08/26/exemplos-de-rotinas-mvc-em-advpl/
*/
