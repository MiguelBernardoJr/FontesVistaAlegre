#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'FWMVCDEF.CH' 

/********************

Necessário criar tabelas Z0C, Z0D e Z0E
Necessário criar consulta padrão específica para produtos bovinos e consulta padrão de pedidos de compras

********************/
 
//------------------------------------------------------------------- 
User Function VAMVCA02() 
Local oBrowse 
Private	lInterProd := .F.
 
oBrowse := FWMBrowse():New() 
oBrowse:SetAlias('SB8') 
oBrowse:SetDescription( 'Alteração de localização de lotes' ) 
//oBrowse:AddLegend( "Z0C_STATUS=='1'", "GREEN" , "Aberto"       ) 
//oBrowse:AddLegend( "Z0C_STATUS=='2'", "GREY"  , "Cancelado"    ) 
//oBrowse:AddLegend( "Z0C_STATUS=='3'", "RED"   , "Efetivado"    )
 //Filtrando
    oBrowse:SetFilterDefault("SB8->B8_SALDO>0")
oBrowse:Activate() 
 
Return NIL 
 
//------------------------------------------------------------------- 
Static Function MenuDef() 
Local aRotina := {} 
ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.VAMVCA02' OPERATION 2 ACCESS 0 
//ADD OPTION aRotina TITLE 'Incluir'    ACTION 'u_AddZ0C()' OPERATION 3 ACCESS 0 
ADD OPTION aRotina TITLE 'Alterar Curral por Lote' ACTION 'U_MudaCurr()' OPERATION 4 ACCESS 0 
//ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.VAMVCA01' OPERATION 5 ACCESS 0 
//ADD OPTION aRotina TITLE 'Cancelar'   ACTION 'VIEWDEF.VAMVCA01' OPERATION 8 ACCESS 0 
//ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.VAMVCA01' OPERATION 9 ACCESS 0 
Return aRotina 
 
//------------------------------------------------------------------- 
Static Function ModelDef() 
 
// Cria as estruturas a serem usadas no Modelo de Dados 
Local oStruObj := FWFormStruct( 1, 'SB8' ) 
Local oModel // Modelo de dados construído 

oModel:= MPFormModel():New("VAMDLA02",/*Pre-Validacao*/,/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)
oModel:AddFields('OBJMASTER',/*cOwner*/,oStruObj)

oModel:SetPrimaryKey( { "B8_FILIAL", "B8_PRODUTO", "B8_LOCAL", "B8_LOTECTL" } )
 
// Adiciona a descrição do Modelo de Dados 
oModel:SetDescription( 'MANUTENÇÃO DE SALDOS DE LOTES' ) 
 
// Adiciona a descrição dos Componentes do Modelo de Dados 
oModel:GetModel( 'OBJMASTER' ):SetDescription( 'Dados do Saldo' )
 
// Retorna o Modelo de dados 
Return oModel

//------------------------------------------------------------------- 
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado 
Local oModel   := FWLoadModel( 'VAMVCA02' ) 
// Cria a estrutura a ser acrescentada na View 
Local oStruObj := FWFormStruct( 2, 'SB8' )
// Inicia a View com uma View ja existente 
Local oView    := FWFormView():New()

// Altera o Modelo de dados quer será utilizado 
oView:SetModel( oModel )
 
oView:AddField( 'VIEW_OBJ', oStruObj, 'OBJMASTER' ) 
 
// Criar "box" horizontal para receber algum elemento da view 
oView:CreateHorizontalBox( 'EMCIMA'  , 100 ) 
 
// Relaciona o identificador (ID) da View com o "box" para exibicao 
oView:SetOwnerView( 'VIEW_OBJ', 'EMCIMA'    ) 

// Liga a identificacao do componente
oView:EnableTitleView( 'VIEW_OBJ', "DADOS DO SALDO" ) 

oView:SetCloseOnOk( { ||.T. } )
 
Return oView

//------------------------------------------------------------------- 
Static Function GeraSX1()
	Local aArea 	:= GetArea()
	Local i	  		:= 0
	Local j     	:= 0
	Local lInclui	:= .F.
	Local aHelpPor	:= {}
	Local aHelpSpa	:= {}
	Local aHelpEng	:= {}
	Local cTexto    := ''
	
	aRegs := {}

	AADD(aRegs,{cPerg,"01","Novo Curral","","","mv_ch1","C",12,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","Z08","N","","",""})
	
	dbSelectArea("SX1")
	dbSetOrder(1)
	For i := 1 To Len(aRegs)
	 If lInclui := !dbSeek(cPerg + aRegs[i,2])
		 RecLock("SX1", lInclui)
		  For j := 1 to FCount()
		   If j <= Len(aRegs[i])
		    FieldPut(j,aRegs[i,j])
		   Endif
		  Next
		 MsUnlock()
		EndIf

		aHelpPor := {}; aHelpSpa := {}; aHelpEng := {}
		PutSX1Help("P."+AllTrim(cPerg)+strzero(i,2)+".",aHelpPor,aHelpEng,aHelpSpa)

	Next
	
	RestArea(aArea)
Return('SX1: ' + cTexto  + CHR(13) + CHR(10))

//------------------------------------------------------------------- 
User Function MudaCurr()
local aArea 	:= GetArea()
local cAliasQry := GetNextAlias()
local cAliasVld := GetNextAlias()
local cRecnoPed := 0
local nQtdReg 	:= 0
Local cMsg		:= ""

Private cPerg 	:= "VAMCUR" 

	beginSQL alias cAliasQry
		%noParser%
		select count(1) QTDREG
		  from %table:SB8% SB8
		 where B8_FILIAL=%xFilial:SB8% and SB8.%notDel%
		   and B8_LOTECTL=%exp:SB8->B8_LOTECTL%
	endSQL
	if !(cAliasQry)->(Eof())
		nQtdReg := (cAliasQry)->QTDREG
	endIf
	(cAliasQry)->(dbCloseArea())

	if msgYesNo("O lote atual está localizado no curral ["+AllTrim(SB8->B8_X_CURRA)+"], deseja alterar?")
		/***********************************************
		 Define os parametros para a execucao da rotina
		***********************************************/
		cPerg := PADR(cPerg,Len(SX1->X1_GRUPO))
		GeraSX1()
		
		if !Pergunte(cPerg,.T.)
			msgAlert("Alteração cancelada pelo usuário.")
			RestArea(aArea)
			return
		else
			cNovoCur := allTrim(MV_PAR01)
		
			// MJ: 21.05.2019 - validacao para nao permitir DIFERENTES lotes para IGUAIS currais;
			If !Empty(cNovoCur)	
				beginSQL alias cAliasVld
					%noParser%
					SELECT  B8_LOTECTL, COUNT(B8_LOTECTL) QTDREG
					FROM	%table:SB8% SB8
					WHERE	B8_FILIAL  =  %xFilial:SB8%
						AND B8_LOTECTL <> %exp:SB8->B8_LOTECTL%
						AND B8_X_CURRA =  %exp:cNovoCur%
						AND B8_SALDO   >  0
						AND SB8.%notDel%
					GROUP BY B8_LOTECTL
					ORDER BY B8_LOTECTL
				endSQL
				if !(cAliasVld)->(Eof())
					cMsg := ""
					While !(cAliasVld)->(Eof())
						cMsg += iIf(Empty(cMsg),"",", ") + AllTrim((cAliasVld)->B8_LOTECTL)
						(cAliasVld)->(DbSkip())
					endDo
					
					msgAlert("O novo Curral: " + cNovoCur + ' já esta sendo usado para o(s) lote(s):' +CRLF+ ;
							  cMsg +CRLF+;
							  'Esta operação será cancelada.')
							  
				else
					If msgYesNo("Existem " + cValToChar(nQtdReg) + " produtos no mesmo lote do produto selecionado, deseja alterar todos para o mesmo curral?")
						if nQtdReg > 1 
							cUpd := "update " + retSQLName("SB8")
							cUpd += "   set B8_X_CURRA = '"+cNovoCur+ "'" + CRLF
							cUpd += " where B8_FILIAL ='"+SB8->B8_FILIAL + "'" + CRLF
							cUpd += "   and B8_LOTECTL='"+SB8->B8_LOTECTL+ "'" + CRLF
							cUpd += "   and B8_X_CURRA='"+SB8->B8_X_CURRA+ "'" + CRLF // and B8_SALDO>0 
							cUpd += "   and D_E_L_E_T_=' '"
							
							if (TCSqlExec(cUpd) < 0)
								Alert("Erro ao atualizar. " + TCSQLError())
							endif
						else
							recLock("SB8", .F.)
								SB8->B8_X_CURRA := cNovoCur
							msUnlock()
						endIf
						msgAlert("Curral alterado com sucesso para ["+cNovoCur+"].")
					EndIf
				endIf
				(cAliasVld)->(dbCloseArea())	
			EndIf		
			
		endIf
	endIf

RestArea(aArea)
return