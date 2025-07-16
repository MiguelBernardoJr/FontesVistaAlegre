#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include "Fileio.ch"
#INCLUDE "FWMBROWSE.CH"
#Include "TryException.ch"

//Variáveis Estáticas
Static cTitulo := "Importação de Batida"

/*---------------------------------------------------------------------*
 | Func:  VAEST005                                                     |
 | Autor: Miguel Martins Bernardo Junior                               |
 | Data:  06.12.2016                                                   |
 | Desc:  Criação de rotina de importacao com MVC                      |
 | Obs.:  -                                                            |
 *---------------------------------------------------------------------*/
User Function VAEST005()
	
	Local oBrowse 
	Private lPTO	 	:= .T.
	Private cLogFile 	:= ""
	Private _cBatida	:= CriaVar('Z03_BATIDA', .F.)
	Private _cOperad    := CriaVar('Z03_OPERAD', .F.)
	Private _cNomRec    := CriaVar('Z03_DIETA' , .F.)
	Private _cReceit    := CriaVar('Z03_RECEIT', .F.)
	Private _nTotPro    := CriaVar('Z03_TOTPRO', .F.)
	
	//Instãnciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()
	
	//Setando a tabela de cadastro de Autor/Interprete
	oBrowse:SetAlias("Z02")

	//Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)
	
	oBrowse:SetFilterDefault( "Z02_TPARQ == '3'" )
	
	//Legendas
	oBrowse:AddLegend( "Z02_TPARQ == '3'", "YELLOW"	, "Batida" )
	
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
	ADD OPTION aRotina TITLE 'Visualizar' 	   ACTION 'VIEWDEF.VAEST005' OPERATION 2 ACCESS 0 
	ADD OPTION aRotina TITLE 'Incluir' 	   	   ACTION 'VIEWDEF.VAEST005' OPERATION 3 ACCESS 0 
	ADD OPTION aRotina TITLE 'Excluir' 	   	   ACTION 'VIEWDEF.VAEST005' OPERATION 5 ACCESS 0 
	ADD OPTION aRotina TITLE 'Imprimir' 	   ACTION 'VIEWDEF.VAEST005' OPERATION 8 ACCESS 0 
	ADD OPTION aRotina TITLE 'Importar Batida' ACTION 'u_Est05Bat()'     OPERATION 3 ACCESS 0 
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
	Local oModel	:= FWLoadModel('VAEST005')
	
	Local oStPai	:= FWFormStruct(2, 'Z02')
	Local oStFilho	:= FWFormStruct(2, 'Z03')
	Local oStTot1	:= FWCalcStruct(oModel:GetModel('TOT_SALDO1'))
	
	//Estruturas das tabelas e campos a serem considerados
	// Local aStruZ02	:= Z02->(DbStruct())
	// Local aStruZ03	:= Z03->(DbStruct())

	//Criando a View
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	//Adicionando os campos do cabeçalho e o grid dos filhos
	oView:AddField('VIEW_Z02' , oStPai	 , 'Z02MASTER')
	oView:AddGrid ('VIEW_Z03' , oStFilho , 'Z03DETAIL')
	oView:AddField('VIEW_TOT1', oStTot1  , 'TOT_SALDO1')
	
	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('BVIEW_Z02' , 15 )
	oView:CreateHorizontalBox('BVIEW_Z03' , 75 )
	oView:CreateHorizontalBox('EMBAIXO'   , 10 )
	oView:CreateVerticalBox('EMBESQ'  	  , 50 , 'EMBAIXO' )
	
	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_Z02'	,'BVIEW_Z02' )
	oView:SetOwnerView('VIEW_Z03'	,'BVIEW_Z03' )
	oView:SetOwnerView('VIEW_TOT1'	,'EMBESQ')
	
	//Habilitando título
	oView:EnableTitleView('VIEW_Z02','Cabecalho de Importacao')
	oView:EnableTitleView('VIEW_Z03','Cadastro das Batidas')
	
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
	Local oStFilho 		:= FWFormStruct(1, 'Z03')
	Local aZ03Rel		:= {}
	 
	oStFilho:SetProperty( 'Z03_BATIDA' , MODEL_FIELD_INIT, {|| Iif(lPTO,_cBatida,nil) })
	oStFilho:SetProperty( 'Z03_OPERAD' , MODEL_FIELD_INIT, {|| Iif(lPTO,_cOperad,nil) })
	oStFilho:SetProperty( 'Z03_DIETA', MODEL_FIELD_INIT, {|| Iif(lPTO,_cNomRec,nil) })
	oStFilho:SetProperty( 'Z03_RECEIT' , MODEL_FIELD_INIT, {|| Iif(lPTO,_cReceit,nil) })
	oStFilho:SetProperty( 'Z03_TOTPRO' , MODEL_FIELD_INIT, {|| Iif(lPTO,_nTotPro,nil) })
	
	//Criando o modelo e os relacionamentos
	oModel := MPFormModel():New('EST005')
	
	oModel:AddFields('Z02MASTER',/*cOwner*/,oStPai)
	oModel:AddGrid('Z03DETAIL','Z02MASTER',oStFilho,bLinePre/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner Ã© para quem pertence
	
	//Fazendo o relacionamento entre o Pai e Filho
	aAdd(aZ03Rel, {'Z03_FILIAL', 'Z02_FILIAL' } )
	aAdd(aZ03Rel, {'Z03_SEQUEN', 'Z02_SEQUEN' } )
	
	oModel:SetRelation('Z03DETAIL', aZ03Rel, Z03->(IndexKey(1))) //IndexKey -> quero a ordenação e depois filtrado
	oModel:GetModel('Z03DETAIL'):SetUniqueLine({"Z03_FILIAL","Z03_SEQUEN","Z03_BATIDA","Z03_INSUMO"})	//Não repetir informações ou combinações {"CAMPO1","CAMPO2","CAMPOX"}
	oModel:SetPrimaryKey( {"Z02_FILIAL","Z02_SEQUEN"} )
	
	//Setando as descrições
	oModel:SetDescription("Rotina de Integração de Batida")
	oModel:GetModel('Z02MASTER'):SetDescription('Cabecalho de Importacao')
	oModel:GetModel('Z03DETAIL'):SetDescription('Cadastro das Batidas')
	
	//Adicionando totalizadores
	oModel:AddCalc('TOT_SALDO1', 'Z02MASTER', 'Z03DETAIL', 'Z03_TOTPRO', 'XX_TOTAL' , 'COUNT', , , "Total Imp. Batida:" ) 
	
Return oModel

/*---------------------------------------------------------------------*
 | Func:  EST005                                                       |
 | Autor: Miguel Martins Bernardo Junior                               |
 | Data:  06.12.2016                                                   |
 | Desc:  Chamada a pontos de entrada                                  |
 | Obs.:  -                                                            |
 *---------------------------------------------------------------------*/
User Function EST005()
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
Local i			 := 0

If cClasse == 'FWFORMGRID'
	nQtdLinhas := oObj:GetQtdLine()
	nLinha     := oObj:nLine
EndIf

If lPTO
	If cIdPonto ==  'FORMLINEPOS'  // Na validação total da linha do formulário GRID. (requer retorno lógico)
		_cBatida := oObj:ACOLS[1][3]
		_cOperad := oObj:ACOLS[1][6]
		_cNomRec := oObj:ACOLS[1][7]
		_cReceit := oObj:ACOLS[1][8]
		_nTotPro := oObj:ACOLS[1][9]

		If nQtdLinhas > 1
			For i:= 2 to nQtdLinhas
				oObj:GoLine(i)
				oObj:LoadValue( 'Z03_BATIDA', _cBatida )
				oObj:LoadValue( 'Z03_OPERAD', _cOperad )
				oObj:LoadValue( 'Z03_DIETA',  _cNomRec )
				oObj:LoadValue( 'Z03_RECEIT', _cReceit )
				oObj:LoadValue( 'Z03_TOTPRO', _nTotPro )
			Next i
			oObj:GoLine(nLinha)
		EndIf
	
	ElseIf cIdPonto ==  'MODELCOMMITTTS'
		
 		If  oObj:NOPERATION == 3
		
			aDados:=ProcADADOS(oObj:ADEPENDENCY[1][2][1][3]:ACOLS)
			
			RecLock('Z02',.F.)
				Z02->Z02_CONTEU := U_ATOS(aDados)
				Z02->Z02_TPARQ  := '3'
			Z02->(MsUnLock())
			
			cUpd := "update " + retSQLName("Z03") +" "+CRLF
			cUpd += "   set Z03_FILIAL='"+xFilial('Z03')+ "'"+CRLF
			cUpd += " where Z03_FILIAL=' '  " + CRLF
			cUpd += "   and Z03_SEQUEN='"+Z02->Z02_SEQUEN+ "'"+CRLF
			cUpd += "   and D_E_L_E_T_=' ' "+CRLF
		   
			BeginTran()
				TryException
					if (TCSqlExec(cUpd) < 0)
						DisarmTransaction()
						UserException("TCSQLError() " + TCSQLError())
					endif                    	 
					
					If !Empty(aDados) // :=ProcADADOS(oObj:ADEPENDENCY[1][2][1][3]:ACOLS))
						ExecMestre(aDados, Z02->Z02_SEQUEN)
					EndIf
				CatchException Using oException
					lRet := .F.					
					ConOut(oException:ErrorStack)
					u_ShowException(oException)
					DisarmTransaction()
				EndException
			EndTran()

		ElseIf oObj:NOPERATION == 5
		
			cUpd := "update " + retSQLName("Z03") +" "+CRLF
			cUpd += "   set D_E_L_E_T_='*'"+CRLF
			cUpd += " where Z03_FILIAL='"+xFilial('Z03')+ "'" + CRLF
			cUpd += "   and Z03_SEQUEN='"+Z02->Z02_SEQUEN+ "'"+CRLF
			cUpd += "   and D_E_L_E_T_=' ' "+CRLF
		
			BeginTran() // Begin Transaction  
				if (TCSqlExec(cUpd) < 0)
					lRet := .F.
					userException("TCSQLError() " + TCSQLError())
					DisarmTransaction()
				endif
			EndTran() // End Transaction
		EndIf	

	ElseIf cIdPonto ==  'MODELPOS'

		If  oObj:NOPERATION == 3
			For i:= 2 to Len( oObj:ADEPENDENCY[1][2][1][3]:ACOLS )
				oObj:ADEPENDENCY[1][2][1][3]:ACOLS[i,3] := _cBatida
				oObj:ADEPENDENCY[1][2][1][3]:ACOLS[i,6] := _cOperad
				oObj:ADEPENDENCY[1][2][1][3]:ACOLS[i,7] := _cNomRec
				oObj:ADEPENDENCY[1][2][1][3]:ACOLS[i,8] := _cReceit
				oObj:ADEPENDENCY[1][2][1][3]:ACOLS[i,9] := _nTotPro
			Next i   
			
			if !Empty( aDados:=ProcADADOS(oObj:ADEPENDENCY[1][2][1][3]:ACOLS) )
				For i := 1 to len(aDados) 
					// Valida Existencia do arquivo processado, caso tenha, ignora todo o processo;
					Z03->(DbSetOrder(2)) // Z03_FILIAL+Z03_BATIDA+Z03_INSUMO+Z03_SEQUEN
					If Z03->(DbSeek( xFilial('Z03') + PadR(aDados[i,01], TamSX3('Z03_BATIDA')[1]) + PadR(aDados[i,08], TamSX3('Z03_INSUMO')[1]) ))
						MsgStop("Batida: [" + AllTrim(aDados[i,01]) + "], Insumo [" + AllTrim(aDados[i,08]) + "]" + CRLF + "já se encontra processado." + CRLF + "Esta Operação será cancelada.")
						lRet := .F.
						exit
					EndIf
				Next i    
			EndIf

		ElseIf oObj:NOPERATION == 5
			cAlias    	:= GetNextAlias()
			_cQry := " select distinct Z03_NUMOP
			_cQry += " from " + RetSQLName('z03')
			_cQry += " where
			_cQry += " 	   z03_filial='"+xFilial('Z03')+"'
			_cQry += " and z03_sequen='"+Z02->Z02_SEQUEN+"'
			_cQry += " and d_e_l_e_t_ = ' ' "

			DbUseArea(.T.,'TOPCONN',TCGENQRY(,,ChangeQuery(_cQry)),(cAlias),.F.,.F.)

			TryException
				BeginTran()  
					While !(cAlias)->(Eof())
						U_vaest002(SubS((cAlias)->Z03_NUMOP,1,TamSX3('C2_NUM')[1]))
						(cAlias)->(DbSkip())
					EndDo
				EndTran()
			CatchException Using oException
				lRet := .F.
				u_ShowException(oException)
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
User Function fChaveSX8(cTab, cCampo, cGrupo, cInfo, cNotNull )
Local cCod 		 := StrZero( 1 , TamSX3(cCampo)[1] )
Local _cQry 	 := ""
Local cAlias     := GetNextAlias()
Default cGrupo   := ""
Default cInfo	 := ""
Default cNotNull := ""

_cQry := " SELECT " + cTab +"_FILIAL, "

If !Empty(cGrupo)
	_cQry += cGrupo + ", "
EndIf

_cQry += " MAX("+cCampo+") SEQUEN " + CRLF
_cQry += " FROM " + RetSQLName(cTab) + CRLF
_cQry += " WHERE " + CRLF
_cQry += " 		"+ cTab +"_FILIAL='"+xFilial(cTab)+ "'" + CRLF
If !Empty(cGrupo)
	_cQry += " and " + cGrupo + "='" + cInfo + "'" + CRLF
EndIf            
If !Empty(cNotNull)
	_cQry += cNotNull + CRLF
EndIf
_cQry += " and  D_E_L_E_T_ = ' ' " + CRLF
_cQry += " group by " + cTab +"_FILIAL "

If !Empty(cGrupo)
	_cQry += ", " + cGrupo + CRLF
EndIf

DbUseArea(.T.,'TOPCONN',TCGENQRY(,,ChangeQuery(_cQry)),(cAlias),.F.,.F.)

If !(cAlias)->(Eof())
	cCod := Soma1( (cAlias)->SEQUEN )
EndIf

Return cCod

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
		aAdd(aDadAux , { aDados[i][03], ;
						 DtoC(aDados[i][04]), ;
						 aDados[i][05], ;
						 aDados[i][06], ;
						 aDados[i][07], ;
						 aDados[i][08], ;
						 AllTrim(Str(aDados[i][09])), ;
						 aDados[i][10], ;
						 aDados[i][11], ;
						 AllTrim(Str(aDados[i][12])) } )
	EndIf
next i

Return aDadAux



/*---------------------------------------------------------------------*
 | Func:  Est05Bat                                                      |
 | Autor: Miguel Martins Bernardo Junior                               |
 | Data:  06.12.2016                                                   |
 | Desc:  Importação da Batida                                         |
 | Obs.:  -                                                            |
 *---------------------------------------------------------------------*/
User Function Est05Bat()
	Local aSay		:= {}
	Local aButton	:= {}
	Local nOpc		:= 0
	Local Titulo	:= 'Importação de Batidas'
	Local cDesc		:= 'Esta rotina fará a ' + lower(Titulo)
	Local cDesc		+= ', confome estrutura definida na tabela Z03.'
	Local lOk		:= .T.

	aAdd(aSay, cDesc)
	
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
			If (lOk := Z03RunProc( aDados, cNomeFile ))
				ApMsgInfo( 'Processamento terminado com sucesso.', 'ATENÇÃO' ) 
			EndIf
		EndTran()
	CatchException Using oException
		DisarmTransaction() 
		u_ShowException(oException)
		ConOut(oException:ErrorStack)
	EndException
return lOk

/*---------------------------------------------------------------------*
 | Func:  Z03RunProc                                                   |
 | Autor: Miguel Martins Bernardo Junior                               |
 | Data:  06.12.2016                                                   |
 | Desc:  Importação da Batida                                         |
 | Obs.:  -                                                            |
 *---------------------------------------------------------------------*/
Static Function Z03RunProc( aDados, cNomeFile )
Local aArea		  := GetArea()
Local lRet 		  := .F.
Local aCposCab	  := {}
Local aCposDet	  := {}
Local aAux		  := {}
local cInsumo     := "" 
local cReceita    := ""
Local i           := 0
Private cSequencia  := "" 

If !Empty(aDados)
	If len(aDados[1]) == 10 // qtd de campos do arquivo de batida
		lRet := .T.
		aSort( aDados ,,, {|x,y| x[1]+x[6]+x[8] < y[1]+y[6]+y[8] } )	
		
		cSequencia  := u_fChaveSX8('Z02','Z02_SEQUEN')  
		
		aAdd( aCposCab, { 'Z02_FILIAL' , xFilial('Z02') } )
		aAdd( aCposCab, { 'Z02_SEQUEN' , cSequencia 	 } )
		aAdd( aCposCab, { 'Z02_ARQUIV' , cNomeFile 		 } )
		aAdd( aCposCab, { 'Z02_DTIMP'  , MsDate()		 } )
		aAdd( aCposCab, { 'Z02_TPARQ'  , '3'			 } ) // 3 = Z03 - Batida
		aAdd( aCposCab, { 'Z02_CONTEU' , U_ATOS(aDados)	 } )
		
		ProcRegua(len(aDados))
		
		For i := 1 to len(aDados) 
		
            if cToD(aDados[i,02]) <>  dDataBase
                UserException("Erro na linha [" + AllTrim(Str(i)) + "]. A data do Trato definida no arquivo [" + aDados[i,01] + "] é diferente da data base [" + DToC(dDataBase) + "].") 
            endif 
		    
		    
		    // Valida Existencia do arquivo processado, caso tenha, ignora todo o processo;
			Z03->(DbSetOrder(2)) // Z03_FILIAL+Z03_BATIDA+Z03_INSUMO+Z03_SEQUEN
			If Z03->(DbSeek( xFilial('Z03') + PadR(aDados[i,01], TamSX3('Z03_BATIDA')[1]) + PadR(aDados[i,08], TamSX3('Z03_INSUMO')[1]) ))
				UserException("Batida: [" + AllTrim(aDados[i,01]) + "], Insumo [" + AllTrim(aDados[i,08]) + "]" + CRLF + "já se encontra processado." + CRLF + "Esta Operação será cancelada.")
			EndIf
			
			if GetNewPar("VA_CODPROD","PROTHEUS") != "PROTHEUS"
				if Empty(cReceita := AllTrim(u_GetExata(aDados[i][06]))) 
	                UserException("O código do produto tipo receita [" + AllTrim(aDados[i][06]) + "] não possui contrapartida para código de produto do Protheus.") 
				endif
				aDados[i][06] := cReceita
				 
	            if Empty(cInsumo  := AllTrim(u_GetExata(aDados[i][08])))
	                UserException("O código do produto tipo insumo [" + AllTrim(aDados[i][08]) + "] não possui contrapartida para código de produto do Protheus.") 
				endif
				aDados[i][08] := cInsumo
			endif
			
			aAux := {}
			aAdd( aAux, { 'Z03_FILIAL'  , xFilial('Z03')     } )
			aAdd( aAux, { 'Z03_SEQUEN'  , cSequencia         } ) 
			aAdd( aAux, { 'Z03_BATIDA'  , aDados[i,01]       } ) 
			aAdd( aAux, { 'Z03_DTIMP'	, cToD(aDados[i,02]) } ) 
			aAdd( aAux, { 'Z03_HRIMP'	, aDados[i,03] 		 } ) 
			aAdd( aAux, { 'Z03_OPERAD'	, aDados[i,04] 		 } ) 
			aAdd( aAux, { 'Z03_DIETA'	, aDados[i,05] 		 } ) 
			aAdd( aAux, { 'Z03_RECEIT'	, aDados[i][06]	     } ) 
			aAdd( aAux, { 'Z03_TOTPRO'	, Val(aDados[i,07])  } ) 
			aAdd( aAux, { 'Z03_INSUMO'	, aDados[i][08]      } ) 
			aAdd( aAux, { 'Z03_DESCRI'	, aDados[i,09]       } ) 
			aAdd( aAux, { 'Z03_QTDE'	, Val(aDados[i,10])  } ) 
			aAdd( aCposDet, aAux )		
		Next i
		
        if lRet
    		If U_ImportMVC( 'Z02', 'Z03', aCposCab, aCposDet, 'VAEST005' )
    			ExecMestre(aDados, cSequencia)
    		Else
    			lRet := .F. 
    		EndIf	
        endif
	else
        UserException("O arquivo processado possui a quantidade de campos diferente de 10. Nao se trata de um arquivo de Batida.")	
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
Static Function ExecMestre(aDados, cSequencia)

Local aAux 		:= {}
Local cArmz 	:= "01"
Local cBatida 	:= aDados[1,01]
Local cCodPro	:= ""
Local nQuant	:= 0
Local i 		:= 0
Local cUpd		:= ""

Private cNumOp	:= ""

If Len(aDados)>0
	_cMSG := Z03xSB2Sld020( cSequencia )
	If !Empty(_cMSG)
		MemoWrite( GetTempPath() + "BATIDA_"+AllTrim(cSequencia)+".TXT" , _cMSG)
		userException(_cMSG)
	EndIf
EndIf

For i := 1 to len(aDados)
	
	If cBatida <> aDados[i,01]
		cCodPro := aDados[i-1,06] // "257"
		nQuant 	:= Val(aDados[i-1,07])

		//Alert('Chamar Funcao do Mestre')
		u_vaest003(cCodPro, nQuant, cArmz, aAux)

		If !Empty(cNumOp)		
			cUpd := "update " + retSQLName("Z03") +" "+CRLF
			cUpd += "   set Z03_NUMOP='"+cNumOp+ "'"+CRLF
			cUpd += " where Z03_FILIAL='"+xFilial('Z03')+ "'"+CRLF
			cUpd += "   and Z03_SEQUEN='"+Z02->Z02_SEQUEN+ "'"+CRLF
			cUpd += "   and Z03_BATIDA='"+cBatida+ "'" + CRLF
			cUpd += "   and D_E_L_E_T_=' ' "+CRLF
		   
			if (TCSqlExec(cUpd) < 0)
				UserException("TCSQLError() " + TCSQLError())
			Else	
				cNumOp := ""
			endif
		EndIf
		
		aAux := {}     
		cBatida := aDados[i,01]
	EndIf

	aAdd( aAux, { aDados[i,08] , cArmz , Val(aDados[i,10]) } ) 
	
Next i
i--
If i>0
	// Enviar ultima BATIDA
	cCodPro := aDados[i,06] // "257"
	nQuant 	:= Val(aDados[i,07])
	
	//Alert('Chamar Funcao do Mestre')
	u_vaest003(cCodPro, nQuant, cArmz, aAux)

	If !Empty(cNumOp)		
		cUpd := "update " + retSQLName("Z03") +" "+CRLF
		cUpd += "   set Z03_NUMOP='"+cNumOp+ "'"+CRLF
		cUpd += " where Z03_FILIAL='"+xFilial('Z03')+ "'"+CRLF
		cUpd += "   and Z03_SEQUEN='"+Z02->Z02_SEQUEN+ "'"+CRLF
		cUpd += "   and Z03_BATIDA='"+cBatida+ "'" + CRLF
		cUpd += "   and D_E_L_E_T_=' ' "+CRLF
	   
		if (TCSqlExec(cUpd) < 0)
			UserException("TCSQLError() " + TCSQLError())
		Else	
			cNumOp := ""
		endif
	EndIf
EndIf

Return nil

/*---------------------------------------------------------------------*
 | Func:  ImpFile                                                      |
 | Autor: Miguel Martins Bernardo Junior                               |
 | Data:  06.12.2016                                                   |
 | Desc:  Importação da Batida                                         |
 | Obs.:  -                                                            |
 *---------------------------------------------------------------------*/
User Function ImpFile(cNomeFile)

Local nCont		:= 0
Local cLinha 	:= ""  
Local nLinha 	:= 0
Local aDados 	:= {}
Local nTamLinha := 0
Local nTamArq	:= 0
Local cFileErro := ""
Local nHandle	:= 0

	if Empty( cNomeFile )
		cNomeFile := cGetFile( "Todos (*.*)", 'Selecione o arquivo', , ;
							"D:\" , .T. , ;
							(GETF_LOCALHARD) )
	EndIf

	While !FT_FUse(cNomeFile) <> -1
		cNomeFile := cGetFile( "Todos (*.*)", 'Selecione o arquivo', , ;
										"D:\" , .T. , ;
										(GETF_LOCALHARD) )
	EndDo

	ProcRegua(FT_FLASTREC())
	// If FT_FRecno() > 1
		FT_FGotop()
	// EndIf
	
	While ( !FT_FEof() )

		nCont++
		IncProc('Importando Linha: ' + Alltrim(Str(nCont)) )
		
		cLinha := FT_FREADLN()
		clinha := FwNoAccent( cLinha )
		clinha := U_ClearLine( clinha )                  
		
		If !Empty( clinha )
			aAdd(aDados,Separa(cLinha,";",.T.))
		EndIf
		
		FT_FSKIP()
	EndDo	
	
	FT_FUse()
	// EndIf	

Return aDados

User Function ClearLine(cLine, lEspaco)
Local i                      
Local nLen := Len(cLine)     

Default lEspaco := .T.

For i := 1 To nLen
	nChar := Asc(SubStr(cLine, i, 1))
	If nChar > 127 .or. nChar < 32
		cLine := StrTran(cLine,Chr(nChar),"#%*")
	EndIf
Next  

If lEspaco
	cLine := StrTran(cLine, "#%*", "")
EndIf

Return cLine

//------------------------------------------------------------------- 
// Importacao dos dados 
//------------------------------------------------------------------- 
User Function ImportMVC( cMaster, cDetail, aCpoMaster, aCpoDetail, cModel ) 

Local oModel, oAux, oStruct
Local nI 		:= 0
Local nJ 		:= 0
Local nPos 		:= 0
Local lRet		:= .T.
Local aAux 
Local aC 
Local aH 
Local nItErro 
Local lAux

dbSelectArea( cDetail ) 
dbSetOrder( 1 )

dbSelectArea( cMaster ) 
dbSetOrder( 1 )

// Aqui ocorre o instânciamento do modelo de dados (Model)
// Neste exemplo instanciamos o modelo de dados do fonte COMP022_MVC 
// que é a rotina de manutenção de musicas
oModel := FWLoadModel( cModel )

// Temos que definir qual a operação deseja: 3 - Inclusão / 4 - Alteração / 5 - Exclusão
oModel:SetOperation( 3 )

// Antes de atribuirmos os valores dos campos temos que ativar o modelo 
oModel:Activate()

// Instanciamos apenas a parte do modelo referente aos dados de cabeçalho 
oAux := oModel:GetModel( cMaster + 'MASTER' )

// Obtemos a estrutura de dados do cabeçalho 
oStruct := oAux:GetStruct()
aAux := oStruct:GetFields()

If lRet
	For nI := 1 To Len( aCpoMaster )
		// Verifica se os campos passados existem na estrutura do cabeçalho
		If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aCpoMaster[nI][1] ) } ) ) > 0

			// É feita a atribuição do dado ao campo do Model do cabeçalho
			If !( lAux := oModel:SetValue( cMaster + 'MASTER', aCpoMaster[nI][1], aCpoMaster[nI][2] ) )

				// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
				// o método SetValue retorna .F. 
				lRet := .F.
				Exit 
			EndIf
		EndIf 
	Next
EndIf 

If lRet
	// Instanciamos apenas a parte do modelo referente aos dados do item 
	oAux := oModel:GetModel( cDetail + 'DETAIL' )

	// Obtemos a estrutura de dados do item
	oStruct := oAux:GetStruct()
	aAux 	:= oStruct:GetFields()
	nItErro	:= 0
	
	For nI := 1 to Len(aCpoDetail)
		// Incluímos uma linha nova
		// ATENÇÃO: Os itens são criados em uma estrutura de grid (FORMGRID) portanto já é criada uma primeira linha
		//branco automaticamente, desta forma começamos a inserir novas linhas a partir da 2a vez
		If nI > 1
			// Incluímos uma nova linha de item
			If ( nItErro := oAux:AddLine() ) <> nI
				// Se por algum motivo o método AddLine() não consegue incluir a linha, 
				// ele retorna a quantidade de linhas já
				// existem no grid. Se conseguir retorna a quantidade mais 1
				lRet := .F.
				Exit 
			EndIf
		EndIf
		
		For nJ := 1 To Len( aCpoDetail[nI] )
			// Verifica se os campos passados existem na estrutura de item
			If ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aCpoDetail[nI][nJ][1] ) } ) ) > 0
				If !( lAux := oModel:SetValue( cDetail + 'DETAIL', aCpoDetail[nI][nJ][1], aCpoDetail[nI][nJ][2] ) )
					// Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
					// o método SetValue retorna .F.
					lRet := .F. 
					nItErro := nI 
					Exit
				EndIf 
			EndIf
		Next
		If !lRet
			Exit 
		EndIf
	Next
EndIf

If lRet	
	// Faz-se a validação dos dados, note que diferentemente das tradicionais "rotinas automáticas"
	// neste momento os dados não são gravados, são somente validados. 
	If ( lRet := oModel:VldData() )
		// Se os dados foram validados faz-se a gravação efetiva dos dados (commit)
		begin transaction
        tryexception
		
		    oModel:CommitData() 
		
        catchException Using oException
            u_ShowException(oException)
            DisarmTransaction()
            Final("O sistema será finalizado para manter a integridade dos dados...")
        EndException
		end transaction 
	EndIf
EndIf

If !lRet
	// Se os dados não foram validados obtemos a descrição do erro para gerar
	// LOG ou mensagem de aviso
	aErro := oModel:GetErrorMessage()

	if !Empty(aErro[1])
	    AutoGrLog( "Id do formulário de origem: " + ' [' + AllToChar( aErro[1] ) + ']' )
    endif
    if !Empty(aErro[2])
	    AutoGrLog( "Id do campo de origem: "	  + ' [' + AllToChar( aErro[2] ) + ']' )
    endif
    if !Empty(aErro[3])
	    AutoGrLog( "Id do formulário de erro: "   + ' [' + AllToChar( aErro[3] ) + ']' )
    endif
    if !Empty(aErro[4])
	    AutoGrLog( "Id do campo de erro: "	      + ' [' + AllToChar( aErro[4] ) + ']' )
    endif
    if !Empty(aErro[5])
	    AutoGrLog( "Id do erro: "	     		  + ' [' + AllToChar( aErro[5] ) + ']' )
    endif
    if !Empty(aErro[6])
	    AutoGrLog( "Mensagem do erro: "    		  + ' [' + AllToChar( aErro[6] ) + ']' )
    endif
    if !Empty(aErro[7])
	    AutoGrLog( "Mensagem da solução: " 		  + ' [' + AllToChar( aErro[7] ) + ']' )
    endif
    if !Empty(aErro[8])
	    AutoGrLog( "Valor atribuído: "     		  + ' [' + AllToChar( aErro[8] ) + ']' )
    endif
    if !Empty(aErro[9])
        AutoGrLog( "Valor anterior: "	   		  + ' [' + AllToChar( aErro[9] ) + ']' )
    endif
	
	MostraErro()
EndIf

// Desativamos o Model
oModel:DeActivate()

Return lRet

/*/{Protheus.doc} u_GetExata
    Retorna o código do produto protheus (B1_COD) que faz relação com o código do produto Exata (B1_X_CODEX).
    
@type function
@author JRScatolon Informatica

@param cProduto, Caractere, Código do produto exata.

@return Caractere, Código do produto protheus, caso seja encontrado ou vazio, caso não seja identificada a contrapartida.
/*/
user function GetExata(cProduto)
local aArea := GetArea()
local cCodPro := ""

DbSelectArea("SB1")
DBOrderNickname("CODEXATA")

if SB1->(DbSeek(xFilial("SB1")+cProduto))
    cCodPro := SB1->B1_COD
endif

if !Empty(aArea)
    RestArea(aArea)
endif
return cCodPro


user function ShowException(oException)
	if !Empty(cLogFile)
	    u_MsgInf("Erro ao processar Arquivo: " + CRLF + oException:Description + CRLF + MemoRead(cLogFile), oException:Description, FunName())
	else
		MsgStop("Erro ao processar Arquivo: " + CRLF + oException:Description)
	endif
	ConOut(oException:ErrorStack)
	cLogFile := ""
return nil


/* MJ : 24.07.2018
	Validar SQL; */
Static Function Z03xSB2Sld020( cSequencia )

Local _cQry 	:= ""
Local _cAlias   := CriaTrab(,.F.)   
Local _cMSG		:= ""

_cQry := " WITH BATIDAS AS ( " + CRLF
_cQry += " 		SELECT	 Z03_FILIAL FILIAL, rTrim(Z03_INSUMO) PRODUTO, SUM(Z03_QTDE) QUANT " + CRLF
_cQry += " 		FROM	 " + RetSQLName('Z03') + "  " + CRLF
_cQry += " 		WHERE	 Z03_SEQUEN ='" + cSequencia + "' AND  " + CRLF
_cQry += " 				 D_E_L_E_T_=' '  " + CRLF
_cQry += " 		GROUP BY Z03_FILIAL, Z03_INSUMO " + CRLF
_cQry += " ), " + CRLF
_cQry += "  " + CRLF
_cQry += " SALDO_B2 AS ( " + CRLF
_cQry += " 		SELECT	B2_FILIAL FILIAL, rTrim(B2_COD) PRODUTO, SUM(B2_QATU) QUANT " + CRLF
_cQry += " 		FROM	" + RetSQLName('SB2') + " SB2 " + CRLF
_cQry += " 		JOIN " + RetSQLName('SB1') + " SB1 ON B1_COD = B2_COD AND 	B2_LOCAL='01' AND SB2.D_E_L_E_T_=' ' " + CRLF
_cQry += " 		WHERE	B2_LOCAL=B1_LOCPAD AND SB2.D_E_L_E_T_=' ' " + CRLF
_cQry += " 		GROUP BY B2_FILIAL, B2_COD " + CRLF
_cQry += " ) " + CRLF
_cQry += "  " + CRLF
_cQry += " SELECT B.FILIAL, B.PRODUTO, rTrim(B1_DESC) DESCRICAO, B.QUANT QTD_APONT, S.QUANT QTD_SB2, B.QUANT-S.QUANT DIFERENCA " + CRLF
_cQry += " FROM BATIDAS B " + CRLF
_cQry += " JOIN SALDO_B2 S ON B.FILIAL=S.FILIAL AND B.PRODUTO=S.PRODUTO " + CRLF
_cQry += " 					AND B.QUANT > S.QUANT " + CRLF
_cQry += " JOIN " + RetSQLName('SB1') + "  B1 ON B1_FILIAL=' ' AND B1_COD=B.PRODUTO AND B1.D_E_L_E_T_=' ' " + CRLF
_cQry += " ORDER BY B.FILIAL, B.PRODUTO " + CRLF

MemoWrite( "C:\TOTVS_RELATORIOS\VAEST005.SQL" , _cQry)

dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.)

While !(_cAlias)->(Eof())

	_cMSG 	+= Iif( Empty(_cMSG), CRLF + "Saldo não é suficiente para o(s) produto(s): " + CRLF, "" )
	_cMSG	+= AllTrim( (_cAlias)->PRODUTO ) + "-" + AllTrim( (_cAlias)->DESCRICAO )
	_cMSG	+= ", demanda: "    + AllTrim(Transform( (_cAlias)->QTD_APONT, '@E 999,999,999.99')) 
	_cMSG	+= ", disponivel: " + AllTrim(Transform( (_cAlias)->QTD_SB2  , '@E 999,999,999.99'))
	_cMSG	+= ", diferença: "  + AllTrim(Transform( (_cAlias)->DIFERENCA, '@E 999,999,999.9999')) + CRLF
	
	(_cAlias)->(DbSkip())
EndDo

(_cAlias)->(DbCloseArea())
Return _cMSG


/* 
	Bibliotecas:
		- https://terminaldeinformacao.com/2015/08/26/exemplos-de-rotinas-mvc-em-advpl/
*/

/* 
MJ : 05.12.2016
	# Processamento para importacao de Batida e Trato;

SB1 - Produto - Tabela ja existente
Campo: 			B1_XLOTE
Tipo:			1-Caracter
Tamanho: 		10
Contexto:		1-Real
Propriedade:	1-Alterar
Titulo:			Lote
Descricao:		Lote
Help:			Informacao de Lote importado no arquivo de trato.
================================================	
INDICE
SB1
Chave: 			B1_FILIAL+B1_XLOTE+B1_COD 
Nicname:		B1LOTE    
Descricao:		Lote+Codigo
Mostra pesq.	X
================================================	
	
Tabela Z02 - Importacao
Prefixo: 		Z02
Descricao:		IMPORTACAO BATIDA E TRATO
Ac. Filial:		2-Exclusivo
Ac. Unidade:	2-Exclusivo
Ac. Empresa:	2-Exclusivo
================================================	
Campo: 			Z02_SEQUEN
Tipo:			1-Caracter
Tamanho: 		10
Contexto:		1-Real
Propriedade:	2-Visualizar
Titulo:			Sequencial
Descricao:		Sequencial
Help:			Campo automatico para registrar a importacao. Cada importacao Ã© um codigo;
Inic. Padrao:	u_fChaveSX8('Z02','Z02_SEQUEN')                                                                                                 
Uso:			Usado, Browse
------------------------------------------------
Campo: 			Z02_ARQUIV
Tipo:			1-Caracter
Tamanho: 		254
Contexto:		1-Real
Propriedade:	1-Alterar
Titulo:			Nome Arquivo
Descricao:		Nome Arquivo
Uso:			Usado, Browse
------------------------------------------------
Campo: 			Z02_DTIMP 
Tipo:			4-Data
Contexto:		1-Real
Propriedade:	1-Alterar
Titulo:			Dt. Import
Descricao:		Data importacao
Inic. Padrao:	dDataBase
Uso:			Usado, Browse
------------------------------------------------
Campo: 			Z02_TPARQ  
Tipo:			1-Caracter
Contexto:		1-Real
Propriedade:	2-Visualizar
Titulo:			Tp Arquivo  
Descricao:		Tipo de Arquivo          
Uso:			Usado, Browse
------------------------------------------------
Campo: 			Z02_CONTEU  
Tipo:			5-Memo
Contexto:		1-Real
Propriedade:	1-Alterar
Titulo:			Conteudo
Descricao:		Conteudo do Arquivo
Usu:			[Obrigatorio: NAO | Usado: NAO | Browse: NAO]
================================================
DICIONARIO / INDICES
Z02
Chave: 			Z02_FILIAL+Z02_SEQUEN                                                                                                                                           
Descricao:		Sequencial
Mostra pesq.	X


################################################

Tabela Z03 
Prefixo: 		Z03
Descricao:		IMPORTACAO DA BATIDA
Ac. Filial:		2-Exclusivo
Ac. Unidade:	2-Exclusivo
Ac. Empresa:	2-Exclusivo
================================================	
Campo: 			Z03_SEQUEN
Tipo:			1-Caracter
Tamanho: 		10
Contexto:		1-Real
Propriedade:	2-Visualizar
Titulo:			Sequencial
Descricao:		Sequencial
Help:			Campo definido na Z02_SEQUEN
Inic. Padrao:	M->Z02_SEQUEN
Uso:			Usado, Browse
------------------------------------------------
Campo: 			Z03_BATIDA
Tipo:			1-Caracter
Tamanho: 		10
Contexto:		1-Real
Propriedade:	1-Alterar
Titulo:			Batida Seq 
Descricao:		Batida
Uso:			Usado, Browse
------------------------------------------------
Campo: 			Z03_DTIMP 
Tipo:			4-Data
Contexto:		1-Real
Propriedade:	1-Alterar
Titulo:			Dt. Import
Descricao:		Data importacao
Inic. Padrao:	dDataBase
Uso:			Usado, Browse
------------------------------------------------
Campo: 			Z03_HRIMP 
Tipo:			1-Caracter
Tamanho:		5
Contexto:		1-Real
Propriedade:	1-Alterar
Titulo:			Hr. Import
Descricao:		Hora importacao
Inic. Padrao:	Time()
Uso:			Usado, Browse
------------------------------------------------
Campo: 			Z03_OPERAD 
Tipo:			1-Caracter
Tamanho:		10
Contexto:		1-Real
Propriedade:	1-Alterar
Titulo:			Operador
Descricao:		Operador
Uso:			Usado, Browse
------------------------------------------------
Campo: 			Z03_DIETA  
Tipo:			1-Caracter
Tamanho:		30
Contexto:		1-Real
Propriedade:	1-Alterar
Titulo:			Dieta
Descricao:		Dieta
Uso:			Usado, Browse
------------------------------------------------
Campo: 			Z03_RECEIT  
Tipo:			1-Caracter
Tamanho:		15
Contexto:		1-Real
Propriedade:	1-Alterar
Titulo:			Receita
Descricao:		Receita
Uso:			Usado, Browse
------------------------------------------------
Campo: 			Z03_TOTPRO  
Tipo:			2-Numerico
Tamanho:		12,4
Formato:		@E 9,999,999.9999                            
Contexto:		1-Real
Propriedade:	1-Alterar
Titulo:			Total Prod
Descricao:		Total Produzido          
Uso:			Usado, Browse
------------------------------------------------
Campo: 			Z03_INSUMO  
Tipo:			1-Caracter
Tamanho:		15
Contexto:		1-Real
Propriedade:	1-Alterar
Titulo:			Insumos     
Descricao:		Insumos     
Uso:			Usado, Browse
------------------------------------------------
Campo: 			Z03_DESCRI  
Tipo:			1-Caracter
Tamanho:		30
Contexto:		1-Real
Propriedade:	1-Alterar
Titulo:			Descricao   
Descricao:		Descricao   
Uso:			Usado, Browse
------------------------------------------------
Campo: 			Z03_QTDE    
Tipo:			2-Numerico
Tamanho:		12,4
Formato:		@E 9,999,999.9999                            
Contexto:		1-Real
Propriedade:	1-Alterar
Titulo:			Quantidade  
Descricao:		Quantidade      
Uso:			Usado, Browse
================================================
Campo: 			Z03_NUMOP
Tipo:			1-Caracter
Tamanho:		15
Contexto:		1-Real
Propriedade:	1-Alterar
Titulo:			Num OP  
Descricao:		Num Ordem de producao
Uso:			Usado, Browse
================================================
DICIONARIO / INDICES
Z03
Chave: 			Z03_FILIAL+Z03_SEQUEN+Z03_BATIDA+Z03_INSUMO
Ordem:			1
Descricao:		Sequencial+Batida+Insumo
Mostra pesq.	X
================================================
Chave: 			Z03_FILIAL+Z03_BATIDA+Z03_INSUMO+Z03_SEQUEN
Ordem:			2
Descricao:		Batida+Insumo+Sequencia



################################################

Tabela Z04 
Prefixo: 		Z04
Descricao:		IMPORTACAO DO TRATO
Ac. Filial:		2-Exclusivo
Ac. Unidade:	2-Exclusivo
Ac. Empresa:	2-Exclusivo
================================================	
Campo: 			Z04_SEQUEN
Tipo:			1-Caracter
Tamanho: 		10
Contexto:		1-Real
Propriedade:	2-Visualizar
Titulo:			Sequencial
Descricao:		Sequencial
Help:			Campo definido na Z02_SEQUEN
Inic. Padrao:	M->Z02_SEQUEN
Uso:			Usado, Browse
------------------------------------------------
Campo: 			Z04_CURRAL
Tipo:			1-Caracter
Tamanho: 		10
Contexto:		1-Real
Propriedade:	1-Alterar
Titulo:			Curral
Descricao:		Curral
Uso:			Usado, Browse
------------------------------------------------
Campo: 			Z04_DTIMP 
Tipo:			4-Data
Contexto:		1-Real
Propriedade:	1-Alterar
Titulo:			Dt. Import
Descricao:		Data importacao
Inic. Padrao:	dDataBase
Uso:			Usado, Browse
------------------------------------------------
Campo: 			Z04_HRIMP 
Tipo:			1-Caracter
Tamanho:		5
Contexto:		1-Real
Propriedade:	1-Alterar
Titulo:			Hr. Import
Descricao:		Hora importacao
Inic. Padrao:	Time()
Uso:			Usado, Browse
------------------------------------------------
Campo: 			Z04_LOTE
Tipo:			1-Caracter
Tamanho: 		10
Contexto:		1-Real
Propriedade:	1-Alterar
Titulo:			Lote
Descricao:		Lote
Uso:			Usado, Browse
------------------------------------------------
Campo: 			Z04_NROCAB
Tipo:			2-Numerico
Tamanho: 		10,0
Formato:		@E 9,999,999,999
Contexto:		1-Real
Propriedade:	1-Alterar
Titulo:			Nro Cabecas
Descricao:		Nro Cabecas
Uso:			Usado, Browse
------------------------------------------------
Campo: 			Z04_DIETA  
Tipo:			1-Caracter
Tamanho:		30
Contexto:		1-Real
Propriedade:	1-Alterar
Titulo:			Dieta
Descricao:		Dieta
Uso:			Usado, Browse
------------------------------------------------
Campo: 			Z04_TOTREA
Tipo:			2-Numerico
Tamanho:		12,4
Formato:		@E 9,999,999.9999                            
Contexto:		1-Real
Propriedade:	1-Alterar
Titulo:			Tot. Realiza
Descricao:		Tot. Realizado
Uso:			Usado, Browse
------------------------------------------------
Campo: 			Z04_TOTAPR
Tipo:			2-Numerico
Tamanho:		12,4
Formato:		@E 9,999,999.9999                            
Contexto:		1-Real
Propriedade:	1-Alterar
Titulo:			Tot. Aprop  
Descricao:		Tot. Aprop  
Uso:			Usado, Browse
------------------------------------------------
Campo: 			Z04_NUMOP
Tipo:			5-Memo
Contexto:		1-Real
Propriedade:	1-Alterar
Titulo:			Num OP  
Descricao:		Num Ordem de producao
Uso:			Usado, Browse
================================================
DICIONARIO / INDICES
Z04
Chave: 			Z04_FILIAL+Z04_SEQUEN+Z04_LOTE
Ordem:			1
Descricao:		Sequencial+Lote
Mostra pesq.	X

################################################
	
*/
