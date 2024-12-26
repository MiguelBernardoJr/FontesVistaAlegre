#INCLUDE "TOTVS.CH"
#INCLUDE "RWMAKE.CH" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"


/*--------------------------------------------------------------------------------,
 | Principal: 			            U_VAESTMB1()            		              |
 | Func:  VAESTMB1()	            	          	            	          	  |
 | Autor: Miguel Martins Bernardo Junior	            	          	  		  |
 | Data:  04.09.2019	            	          	            	              |
 | Desc:  "Apontamento de Operações"                               	              |
 '--------------------------------------------------------------------------------|
 | Obs.:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------*/
User Function VAESTMB1()

Local oBrowse 	  := nil
Local aRotina 	  := MenuDef()
Private cCadastro := "Apontamento de Operações"

//Instãnciando FWMBrowse - Somente com dicionário de dados
oBrowse := FWMBrowse():New()
//Setando a tabela de cadastro de Autor/Interprete
oBrowse:SetAlias("ZAO")
//Setando a descrição da rotina
oBrowse:SetDescription( cCadastro )

//Legendas
// oBrowse:SetFilterDefault( "Z02_TPARQ == '3'" )
// oBrowse:AddLegend( "Z02_TPARQ == '3'", "YELLOW"	, "Batida" )

//Ativa a Browse
oBrowse:Activate()

Return nil


/*--------------------------------------------------------------------------------,
 | Principal: 			            U_VAESTMB1()            		              |
 | Func:  VAESTMB1()	            	          	            	          	  |
 | Autor: Miguel Martins Bernardo Junior	            	          	  		  |
 | Data:  04.09.2019	            	          	            	              |
 | Desc:  "Apontamento de Operações"                               	              |
 '--------------------------------------------------------------------------------|
 | Obs.:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------*/
Static Function MenuDef()
	Local aRotina := {{ "Pesquisar"     , "axPesqui"  , 0, 1, 0 },;
					  { "Visualizar"    , "axVisual"  , 0, 2, 0 },;
					  { "Incluir"		, "U_ESTMB1VA", 0, 3, 0 },;
					  { "Altera"        , "axAltera"  , 0, 4, 0 },; 
					  { "Excluir"       , "axDeleta"  , 0, 5, 0 } }
Return aRotina


/*--------------------------------------------------------------------------------,
 | Principal: 			            U_VAESTMB1()            		              |
 | Func:  VAESTMB1()	            	          	            	          	  |
 | Autor: Miguel Martins Bernardo Junior	            	          	  		  |
 | Data:  04.09.2019	            	          	            	              |
 | Desc:  "Apontamento de Operações"                               	              |
 '--------------------------------------------------------------------------------|
 | Obs.:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------*/
User Function ESTMB1VA(cAlias, nReg, nOpc)
// Local nGDOpc     := GD_INSERT +  GD_UPDATE + GD_DELETE
Local lRet		 := .T.
Local cCpoNao	 := "ZAO_DATA" // ,ZAO_HORA"

// Local aSize		  := {}
// Local aObjects     := {}
// Local aInfo		  := {}
// Local aPObjs       := {}

//+-----------------------------------------------+
//| Montando aHeader para a Getdados              |
//+-----------------------------------------------+
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("ZAO")

nUsado  := 0
aHeader := {}
aCols	:= {}

While !Eof() .And. (X3_ARQUIVO == "ZAO")    
	If X3USO(X3_USADO) .AND. cNivel >= X3_NIVEL .AND.;
		!(AllTrim(X3_CAMPO) $ cCpoNao)
		
		nUsado := nUsado+1        
		AADD(aHeader,{ TRIM(X3_TITULO),;
					   X3_CAMPO,;
					   X3_PICTURE,;
					   X3_TAMANHO,;
					   X3_DECIMAL,;
					   ".T."/*"ExecBlock('Md2valid',.f.,.f.)"*/,;
					   X3_USADO,;
					   X3_TIPO,;
					   X3_ARQUIVO,;
					   X3_CONTEXT } )
	Endif    
	dbSkip()
EndDo

//+-----------------------------------------------+
//| Montando aCols para a GetDados                |
//+-----------------------------------------------+
aCols := Array(1,nUsado+1)
dbSelectArea("Sx3")
dbSeek("ZAO")
nUsado := 0

While !Eof() .And. (X3_ARQUIVO == "ZAO")    
	IF X3USO(X3_USADO) .AND. cNivel >= X3_NIVEL .AND.;
		!(AllTrim(X3_CAMPO) $ cCpoNao)
		
		nUsado := nUsado+1        
		
		If nOpc == 3           
			IF x3_tipo == "C"             
				aCols[1, nUsado]  :=  SPACE(X3_TAMANHO)                
			Elseif x3_tipo == "N"                    
				aCols[1, nUsado]  :=  0                
			Elseif x3_tipo == "D"
				aCols[1, nUsado]  :=  dDataBase
			Elseif x3_tipo == "M"
				aCols[1, nUsado]  :=  ""
			Else
				aCols[1, nUsado]  :=  .F.
			Endif
		Endif
	Endif   
	dbSkip()
EndDo
aCols[1, nUsado+1]  :=  .F.
	
	//+----------------------------------------------+
	//| Variaveis do Rodape do Modelo 2				 |
	//+----------------------------------------------+
	nLinGetD := 0
	
	//+----------------------------------------------+
	//| Titulo da Janela                             |
	//+----------------------------------------------+
	cTitulo :=  cCadastro // "Apontamento de Operações"
	
	//+----------------------------------------------+
	//| Variaveis do Cabecalho do Modelo 2           |
	//+----------------------------------------------+
	dData    := Date()
	// cHora	 := Time()
	
	//+----------------------------------------------+
	//| Array com descricao dos campos do Cabecalho  |
	//+----------------------------------------------+
	aC := {}
	AADD(aC,{"dData", {20, 10}, "Data:" ,,,, })
	// AADD(aC,{"cHora", {20, 90}, "Hora:","99:99:99",,,})
	// AADD(aC,{"cCliente" ,{15,10} ,"Cod. do Cliente","@!",'ExecBlock("MD2VLCLI",.F.,.F.)',"SA1",}) 
	/*
	Parâmetros:
	cTitulo Título da janela
	aCab Array contendo as informações que serão exibidas no cabeçalho na forma de
	Enchoice()
	aCab[n, 1] (Caractere) := Nome da variável private que será vinculada ao
	campo da Enchoice().
	aCab[n, 2] (Array) := Array com as coordenadas do campo na tela {Linha,
	Coluna}
	aCab[n, 3] (Caractere) := Título do campo na tela
	aCab[n, 4] (Caractere) := Picture de formatação do get() do campo.
	aCab[n, 5] (Caractere) := Função de validação do get() do campo.
	aCab[n, 6] (Caractere) := Nome da consulta padrão que será executada
	para o campo via tecla F3
	aCab[n, 7] (Lógico) := Se o campo estará livre para digitação.
	*/
	
	//+----------------------------------------------+
	//| Array com descricao dos campos do Rodape     |
	//+----------------------------------------------+
	aR := {}
	AADD(aR,{"nLinGetD" ,{85, 10}, "Linha na GetDados", "@E 999",,,.F.})
	
	//+----------------------------------------------+
	//| Array com coordenadas da GetDados no modelo2 |
	//+----------------------------------------------+
	// aSize := MsAdvSize( .T. )
	// AAdd( aObjects, { 100 , 100, .T. , .T. } )
	// aInfo  := { aSize[1], aSize[2], aSize[3], aSize[4], 0, 0}
	// aPObjs := MsObjSize(aInfo, aObjects, .T., .F.) 
	// aCGD := { aPObjs[1,1], aPObjs[1,2], aPObjs[1,3], aPObjs[1,4]}	// 
	// aCGD := {44,5,118,315}
	// aCGD := { 55, 10, 150, 600}
	aCGD := {55, 0, 80, 270}
	
	//+----------------------------------------------+
	//| Validacoes na GetDados da Modelo 2           |
	//+----------------------------------------------+
	lLinhaOk  :=  "U_fLinhaOK()"
	lTudoOk   :=  "U_fTudoOK()"
	
	//+----------------------------------------------+
	//| Chamada da Modelo2                           |
	
	//+----------------------------------------------+
	// lRet = .T. se confirmou
	// lRet = .F. se cancelou
	lRet := Modelo2(cTitulo,aC,aR,aCGD,nOpc,lLinhaOk,lTudoOk,;
						/* aGetsD */,;
						/* bF4 */ ,;
						/* cIniCpos */ ,;
						/* nMax */ ,;
						/* aCordW */ ,;
						/* lDelGetD */ ,;
						.T./* lMaximazed */ ,;
						/* aButtons */ )
	If lRet
		// Alert('Gravar')
		
			For nL := 1 to Len(aCols)
				If !aCols[ nL, len(aCols[nL])] // linha deletada.
					RecLock( 'ZAO', nOpc )
				
						ZAO->ZAO_FILIAL	:= xFilial('ZAO')
						ZAO->ZAO_DATA   := dData
						
						U_GrvCpo( "ZAO", aCols, aHeader, nL )
						
						// For nC := 1 to Len(aHeader)
						// 	&( aHeader[ nC, 2] ) := aCols[ nL, nC ]
						// Next nC
						
					ZAO->(MsUnLock())
				EndIf
			Next nL
		
	Else
		MsgAlert('O operação foi <b>cancelada</b>.')
	EndIf
	
Return nil

User Function fLinhaOK()
// Local lRet := MsgYesNo("[fLinhaOK] Deseja continuar? Sim/Não")
	nLinGetD := Len(aCols)
Return .T. // lRet

User Function fTudoOK()
// Local lRet := MsgYesNo("[fTudoOK] Deseja continuar? Sim/Não")
Return .T. // lRet

User Function retESTMB1( )

Local nPosLin  := O:nAt

Local nPosE	   := aScan(aHeader, {|x| x[2] == "ZAO_PESOEN" })
Local nEntrada := Iif( Empty(aCols[ nPosLin, nPosE]), 0, aCols[ nPosLin, nPosE] )

Local nPosS    := aScan(aHeader, {|x| x[2] == "ZAO_PESOSA" })
Local nSaida   := Iif( Empty(aCols[ nPosLin, nPosS]), 0, aCols[ nPosLin, nPosS] )

Return Abs( nEntrada - nSaida )


/*--------------------------------------------------------------------------------,
 | Principal: 			             U_VAESTMB2()          	       				  |
 | Func:  VAESTMB2()	            	          	            	          	  |
 | Autor: Miguel Martins Bernardo Junior	            	          	  	 	  |
 | Data:  30.08.2019	            	          	            	          	  |
 | Desc:                                                 	            	  	  |
 '--------------------------------------------------------------------------------|
 | Obs.:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------*/
/* User Function VAESTMB2()

Local cAlias  := "ZAO"
Local cTitulo := "Apontamento de Operações"
Local cVldDel := ".T."
Local cVldAlt := ".T." 

	AxCadastro(cAlias,cTitulo,cVldDel,cVldAlt)
Return nil
 */
/*
U_VAESTMB2()
*/
