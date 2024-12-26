
//Bibliotecas 
#Include "Protheus.ch"
#Include "Totvs.ch"
#Include "Topconn.ch"   
#include "rwmake.ch" 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ VACOM01 Autor ³ Henrique Magalhaes   ³ Data ³ 19.06.2015³  ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descrição ³ AxCadastro para SD1 - ITENS DE NOTAS FISCAIS             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³  Usado para usuario poder filtrar/exportar excel           ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*
User Function VACOMA01()
Local   aArea 		:= GetArea()  
Private cCadastro	:= "Itens de Notas Fiscais"
Private aRotina		:= {}

	//Adicionando rotinas padrão
	aRotina := {{ OemToAnsi("Pesquisar")  ,"PesqBrw"	,0,1},;
				{ OemToAnsi("Visualizar") ,"AxVisual"	,0,2}}
 
//AxCadastro( <cAlias>, <cTitulo>, <cVldExc>, <cVldAlt>)
AxCadastro("SD1", OemToAnsi(cCadastro), '.F.','.F.')
Restarea(aArea)
Return    
*/

User Function VACOMA01()
	Local cAliasAux 	:= "SD1"
	Local aArea         := GetArea()
	Private cCadastro 	:= "Itens de Notas Fiscais"
	Private aRotina 	:= {}
	
	//Funções do menu
	AADD(aRotina,{"Pesquisar" ,"AxPesqui",0,1})
	AADD(aRotina,{"Visualizar","AxVisual",0,2})
	AADD(aRotina,{"Ajust.Custo","u_V1AltCC",0,4})
	AADD(aRotina,{"Visual.Chave","u_V1VisChv",0,2})
	
	//Posicionando na tabela e abrindo o mBrowse
	DbSelectArea("SD1")
	SD1->(dbSetOrder(1)) //Lote+OP
	mBrowse(6,1,22,75,cAliasAux)
	
	SD1->(DbCloseArea())
	RestArea(aArea)
Return


User Function V1VisChv()
	Local aArea := getArea()
	SetPrvt("_cChvnfe")
	//1 - F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO                                                                                                            
	//2 - F1_FILIAL+F1_FORNECE+F1_LOJA+F1_DOC                                                                                                                             
	
	_cChvnfe 	:= Posicione ("SF1",1,SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_TIPO,"F1_CHVNFE") 
	 
	@ 100,200 To 350,600 Dialog oDlgCC Title "Chave Nf-e: " + SD1->D1_SERIE + "-" + SD1->D1_DOC +  ""
	@ 010,010 Say "Chave:" 
	@ 010,030 Get _cChvnfe 	Size 140,15 
	@ 090,020 Button "Confirmar" Size 40,15 Action _Sair()
	@ 090,120 Button "Sair" Size 40,15 Action _Sair()
	 
	Activate Dialog oDlgCC Centered
	
	RestArea(aArea)
Return Nil                   


User Function V1AltCC()
	SetPrvt("_cCCusto,_cItemC, _cClasse")
	
	_cCCusto 	:= SD1->D1_CC 
	_cItemC 	:= SD1->D1_ITEMCTA   
	_cClasse 	:= SD1->D1_CLVL  
	 
	@ 100,200 To 350,600 Dialog oDlgCC Title "Altera CC da NF/Item: " + SD1->D1_SERIE + "-" + SD1->D1_DOC + "  Item: " +  SD1->D1_ITEM + ""
	@ 010,020 Say "Local:" 
	@ 010,070 Get _cClasse 	Size 40,15 F3 "CTH"
	@ 030,020 Say "Processo:"
	@ 030,070 Get _cItemC 	Size 40,15  F3 "CTDX1"
	@ 050,020 Say "C.Custo:"
	@ 050,070 Get _cCCusto 	Size 40,15 F3 "CTT_X" 	
	@ 090,020 Button "Confirmar" Size 40,15 Action _Confirmar() 
	@ 090,120 Button "Sair" Size 40,15 Action _Sair()
	 
	Activate Dialog oDlgCC Centered

Return Nil                   

//***************************
Static Function _Confirmar()
	Processa({|| RptDetail()})
	Close(oDlgCC) 
Return
 
//***************************
Static Function RptDetail()
    Begin Transaction   
   	// Alteração na tabela SE2.	
		Reclock("SD1",.F.)
		SD1->D1_CC 		:=	_cCCusto 	
		SD1->D1_ITEMCTA	:= 	_cItemC 	
		SD1->D1_CLVL 	:= 	_cClasse  
		MsUnlock("SD1") 	    
 	End Transaction 	
Return Nil
 
//*************************
Static Function _Sair()
	Close(oDlgCC)
Return Nil




