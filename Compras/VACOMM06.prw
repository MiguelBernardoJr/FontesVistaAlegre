#INCLUDE "RWMAKE.CH" 
#INCLUDE "TOTVS.CH"   
#INCLUDE "PROTHEUS.CH"


User Function AfterLogin()                                   
// Local cId   := ParamIXB[1]
//Local cNome := ParamIXB[2]

// usuario responsavel pelo cadsatro dos indicies
Local UsuRespons := GetMV('JR_USUINDI' , , '000031,000052')
Local dIndAtu    := GetMV('JR_INDIATU' , , sToD(''))

Public _lMDIMJ := .F.

if  cModulo == 'COM' ;
	.and. __cUserId $ UsuRespons ;
	.and. dIndAtu <> dDataBase
	
	If U_M06Tab(,,,.T.)
		PutMV("JR_INDIATU", dDataBase)
	EndIf
EndIf                
_lMDIMJ := .T.
return nil
 

User function M06Init(nOpc)
Local cRet := ""

if _lMDIMJ
	If nOpc == 1   // INIBRW
		cRet := POSICIONE("ZCI",1,XFILIAL("ZCI")+ZSI->ZSI_CODIGO,"ZCI_INDICE")                  
	Else
		cRet := iIf(!INCLUI .AND. ALTERA,POSICIONE("ZCI",1,XFILIAL("ZCI")+ZSI->ZSI_CODIGO,"ZCI_INDICE"),"")
	EndIf
EndIf

Return cRet

/*--------------------------------------------------------------------------------,
 | Autor:  Miguel Martins Bernardo Junior                                         |
 | Data:   21.07.2017                                                             |
 | Client: V@                                                                     |
 | Desc:   Esta rotina é responsavel por realizar o CADASTRO dos valores dos      |
 |         indices. Serie de Indices;                                             |
 |         Desenvolvido com funcao MsNewGetDados: Modelo2                         |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function VACOMM06()
Private cCadastro  := "Valores dos Indices x Data"
Private cAlias     := "ZSI" 
Private aRotina    := MenuDef()
	//estanciamento da classe mark
	oMark := FWMBrowse():New()
	
	//tabela que sera utilizada
	oMark:SetAlias( cAlias )   

	oMark:SetMenuDef("VACOMM06")
		
	//Titulo
	oMark:SetDescription( cCadastro )
    
	//oMark:SetFilterDefault(cFiltro)
	 
	oMark:Activate()
Return Nil

Static Function MenuDef()
Local aRotina := { {'Pesquisar',        'axPesqui', 0, 1 },;
                   {'Visualizar',       'axVisual', 0, 2 },; // {'Inclui',           'axInclui', 0, 3 },;
                   {'Alterar',          'axAltera', 0, 4 },;
                   {'Excluir',          'axDeleta', 0, 5 },;
                   {'Incluir-Tabela',   'U_M06Tab', 0, 3 } }
Return aRotina


Static Function	fLoadInd(aClAux)
	Local aArea	 := GetArea()
	Local _cQry  := ""
	Local cAlias := CriaTrab(,.F.)
	Local aAux	 := {}
	
	_cQry := " 	Select * from  " + RetSQLName('ZCI') + CRLF
	_cQry += "  where ZCI_FILIAL='"+xFilial('ZCI')+"' " + CRLF
	_cQry += "    and ZCI_COTGAD = 'S' " + CRLF
	_cQry += "    and d_e_l_e_t_ = ' ' "

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,,ChangeQuery(_cQry)),(cAlias),.F.,.F.)    
	
	if (cAlias)->(Eof())
		aAux := aClone( aClAux )
	else
		While !(cAlias)->(Eof())
			aClAux[ 2 ] := (cAlias)->ZCI_CODIGO
			aClAux[ 3 ] := (cAlias)->ZCI_INDICE
			aAdd( aAux, aClone(aClAux) )
			(cAlias)->(DbSkip())
		EndDo
	EndIf
	(cAlias)->(DbCloseArea())
	RestArea(aArea)
Return aAux

/*--------------------------------------------------------------------------------,
 | Autor:  Miguel Martins Bernardo Junior                                         |
 | Data:   24.07.2017                                                             |
 | Client: V@                                                                     |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function M06Tab( cAlias, nReg, nOpc, lLoadInd )

Local cTitulo      := "Valores dos Indices x Data"
Local aCab         := {}
                   
Local aHeader      := {}
Local aCols        := {}
Local aColsR       := {}
Local aCriaCols    := {}

Local nOpcA        
local nGDOpc       := GD_INSERT + GD_UPDATE + GD_DELETE
local aSize        := {}

Private oDlg       := nil
Private oGetDados  := nil
Private aGets      := {}
Private aTela      := {}

Default lLoadInd	:= .F.

aHeader   := APBuildHeader("ZSI")
aCriaCols := A610CriaCols( "ZSI", aHeader, , {|| .F.})
aCols     := aCriaCols[1]
aColsR    := aCriaCols[2]

if lLoadInd
	aCols := fLoadInd( aClone( aCriaCols[1,1] ) )
EndIf

// nao utilizei modelo 2, pois precisei chamar esta tela do PE afterlogin,
// com isso nao consegui deixar a tela centralizada, por nao haver oDlg;
// lRetMod2 := Modelo2( cTitulo,;    // Titulo da Janela
			  // {} /* aCab */,;     // Array com os campos do cabeçalho
			  // {} /* aR */,;       // Array com os campos do rodapé
			  // {} /* aCGD */ ,;    // Array com as coordenadas da getdados
			  // 3,;                 // Modo de operação (3=Incluir;4=Alterar;5=Excluir)
			  // "U_VA6LinOK()" 	  /* "AllwaysTrue()" */,;   // Validação da LinhaOk
			  // "U_VA6AllOK()" 	  /* "AllwaysTrue()" */,;   // Validação do TudoOk
			  // Nil,;               // Array com os campos da getdados que serão editáveis
			  // Nil,;               // Bloco de código para a tecla F4
			  // Nil,;               // String com os campos que serão inicializados quando seta para baixo
			  // 999,;               // Número máximo de elementos da getdados
			  // {0,0,300,500} /* Nil */,;               // Coordenados windows
			  // .T.,;               // Permitie deletar itens da Getdados
			  // .F. )               // Maximiza a tela?
                                                  
aSize := MsAdvSize( )

DEFINE MSDIALOG oDlg TITLE OemToAnsi(cTitulo) From aSize[7],0 TO aSize[6]*0.50, aSize[5]*0.50 PIXEL of oMainWnd
   
oGetDados := MsNewGetDados():New( 0, 0, 0, 0, nGDOpc, "U_VA6LinOK", , , , , , , , , ;
		   								oDlg, aClone(aHeader), aClone(aCols) )
oGetDados:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT

ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg,;
										 { || nOpcA := 1, Iif( Obrigatorio(aGets, aTela) .and. U_VA6AllOK(), oDlg:End(), nOpcA := 0)},;
										 { || nOpcA := 0, oDlg:End() },, /*aButtons*/)

If (lRetMod2 := nOpcA==1)
	Begin Transaction     
		A610GravaCol(oGetDados:aCols, aHeader, aColsR, "ZSI",{|| .T. } )
	End Transaction
/*Else
	ShowHelpDlg("Aviso", ;
				{"Esta operacao foi cancelada." },,;
				{"Nenhum registro alterado em banco de dados."},5)    */
EndIf
Return lRetMod2


/*--------------------------------------------------------------------------------,
 | Autor:  Miguel Martins Bernardo Junior                                         |
 | Data:   24.07.2017                                                             |
 | Client: V@                                                                     |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function VA6LinOK()
Local lRet := .T.

If Empty(oGetDados:aCols[ n, 1])
	ShowHelpDlg("Vazio", ;
				{"O campo: [DATA] não foi informado."+CRLF+"Linha: " + cValToChar(n) },,;
				{"Operacao de inserir nova linha sera cancelada."},5)    
	Return .F.
EndIf
If oGetDados:aCols[ n, 1] > dDataBase
	ShowHelpDlg("Vazio", ;
				{"O campo: [DATA] esta com data maior que a data atual."+CRLF+"Linha: " + cValToChar(n) },,;
				{"Operacao de inserir nova linha sera cancelada."},5)    
	Return .F.
EndIf
If Empty(oGetDados:aCols[ n, 2])
	ShowHelpDlg("Vazio", ;
			{"O campo: [CODIGO] não foi informado."+CRLF+"Linha: " + cValToChar(n) },,;
			{"Operacao de inserir nova linha sera cancelada."},5)    
	Return .F.
EndIf
If Empty(oGetDados:aCols[ n, 3])
	ShowHelpDlg("Vazio", ;
			{"Cadastro de Indice nao encontrado. Verifique a coluna [CODIGO]"+CRLF+"Linha: " + cValToChar(n) },,;
			{"Operacao de inserir nova linha sera cancelada."},5)    
	Return .F.
EndIf
/* 
Zé mandou tirar, de modo que permite o cadastro com valor igual a zero
If oGetDados:aCols[ n, 4] == 0
	lRet := .F.      
	ShowHelpDlg("Vazio", ;
		{"O campo: [VALOR] não foi informado."+CRLF+"Linha: " + cValToChar(n) },,;
		{"Operacao de inserir nova linha sera cancelada."},5)    
	Return .F.
EndIf
 */
// Este roda todo o acols, marcando as linhas que ja se encontram cadastrada
If Len(oGetDados:aCols) > 1
	for nI:=1 to Len(oGetDados:aCols)-1
		if !oGetDados:aCols[nI,Len(oGetDados:aCols[1])]
			for nJ:=nI+1 to Len(oGetDados:aCols)
				if !oGetDados:aCols[nJ,Len(oGetDados:aCols[1])]
					if DtoS(oGetDados:aCols[nI,1]) + oGetDados:aCols[nI,2] == DtoS(oGetDados:aCols[nJ,1]) + oGetDados:aCols[nJ,2]
						lRet := .F.      
						ShowHelpDlg("Linha Repetida", ;
									{"O indice: " + AllTrim(oGetDados:aCols[nI,3]) + " já esta utilizado na linha: " + cValToChar(nI)},,;
									{"Digite um indice ainda não cadastrado ou altere o indice utilizado na linha: " + cValToChar(nI) },5)    
						exit
					Endif
				EndIf
			Next nJ
		EndIf
	Next nI
EndIf
	
Return lRet

/*--------------------------------------------------------------------------------,
 | Autor:  Miguel Martins Bernardo Junior                                         |
 | Data:   24.07.2017                                                             |
 | Client: V@                                                                     |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function VA6AllOK()
Local lRet := .T.
	for nI:=1 to Len(oGetDados:aCols)
		if !oGetDados:aCols[nI,Len(oGetDados:aCols[1])]
			ZSI->(DbSetOrder(1)) // ZSI_FILIAL+DTOS(ZSI_DATA)+ZSI_CODIGO
			If ZSI->(DbSeek( xFilial('ZSI') + dToS(oGetDados:aCols[nI,1])+ oGetDados:aCols[nI,2] ))
				lRet := .F.
				oGetDados:aCols[nI,Len(oGetDados:aCols[1])] := .T.
				ShowHelpDlg("Linha Repetida", ;
								{"O Indice: " + AllTrim(oGetDados:aCols[nI,3]) + " ja possui cadastro para o dia: " + dToC(oGetDados:aCols[nI,1]) + CRLF + "Linha: " + cValToChar(nI) },,;
								{"Operacao de confirmação do cadastro sera cancelada para conferencia"},5)    
			EndIf
		EndIf
	Next nI
	If !lRet // xVar := ClassMethArr( oGetDados , .T. ) // Magica
		oGetDados:ForceRefresh()
	EndIf
Return lRet


/* DOCUMENTACAO

Tabela:			ZSI
Descricao:		SERIE DO INDICE - VALOR DO IND
Ac. Filial:		Compartilhado
Ac. Unidade:	Compartilhado
Ac. Empresa:	Compartilhado
X2_UNICO:		ZSI_FILIAL+ZSI_DATA+ZSI_CODIGO
------------------------------------------------

Campo: 			ZSI_DATA
Tipo:			Data
Tamanho:		8
Decimal:		0	
Contexto:		Real
Propriedade:	Alterar
Titulo:			Data  
Descricao:		Data do Cadastro
Inic. Padrao:	dDataBase
Uso:			Usado, Browse  
Help:			Data sugerida automaticamente, porem 
				com permissão de alteração;
------------------------------------------------

Campo: 			ZSI_CODIGO
Tipo:			Caracter
Tamanho:		6
Decimal:		0	
Contexto:		Real
Propriedade:	Visualizar
Titulo:			Codigo
Descricao:		Codigo do Indice     
Cons. Padrao:	ZCI
Uso:			Usado, Browse  
Trigger:		S
Help:			Este campo possui pesquisa para o cadastro 
				de índices;
------------------------------------------------

Campo: 			ZSI_DESCRI
Tipo:			Caracter
Tamanho:		30
Decimal:		0	
Contexto:		Virtual
Propriedade:	Visualizar
Titulo:			Descricao
Descricao:		Descricao do Indice
Uso:			Usado, Browse  
------------------------------------------------

Campo: 			ZSI_VALOR 
Tipo:			Numerico
Tamanho:		6
Decimal:		2	
Contexto:		Real
Propriedade:	Alterar
Titulo:			Valor  
Descricao:		Valor do Indice
Uso:			Usado, Browse  
Help:			Valor do índice do dia especificado
------------------------------------------------

===================> Indice <===================
Chave:			ZSI_FILIAL+DTOS(ZSI_DATA)+ZSI_CODIGO
Descricao:		Codigo
Mostra Pesq.	Sim
------------------------------------------------


==================> Gatilho <==================
Campo:			ZSI_CODIGO
Sequencia:		001
Regra:			ZCI_INDICE                                                                                     
cDomin:			ZSI_DESCRI
Tipo:			P
Seek:			N
Alias:			ZCI
Ordem:			1
Chave:			xFilial('ZCI')+M->ZSI_CODIGO                                                                             
Proprio:		U


==================> Parametros <==================
Var:			JR_INDIATU
Tipo:			D
Descric:		Variavel utilizada para controle no PE: AfterLogin
Desc1:			Ao entrar no sistema no sistema pela primeira vez,
Desc2:			no dia, devera cadastrar os indices.              
Conteudo:		* NAO CADASTRAR NADA. ATUALIZADO AUTOMATICAMENTE PELO SISTEMA
/*
