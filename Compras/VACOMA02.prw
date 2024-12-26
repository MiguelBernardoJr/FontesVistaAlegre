//Bibliotecas 
#Include "Protheus.ch"
#Include "Totvs.ch"
#Include "Topconn.ch"
#include "rwmake.ch" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ VACOM02 Autor ³ Henrique Magalhaes    ³ Data ³ 12.08.2015³  ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descrição ³ AxCadastro para SE2 - TITULOS FINACEIROS                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³  Usado para usuario poder filtrar/exportar excel           ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


User Function VACOMA02()
	Local cAliasAux 	:= "SE2"
	Local aArea         := GetArea()
	Private cCadastro 	:= "Titulos a Pagar CC"
	Private aRotina 	:= {}
	
	//Funções do menu
	AADD(aRotina,{"Pesquisar" ,"AxPesqui",0,1})
	AADD(aRotina,{"Visualizar","AxVisual",0,2})
	AADD(aRotina,{"Ajust.Custo","u_V2AltCC",0,4})
	
	//Posicionando na tabela e abrindo o mBrowse
	DbSelectArea("SE2")
	SE2->(dbSetOrder(1)) //Lote+OP    
	//Set Filter To 'FINA'$E2_ORIGEM
	mBrowse(6,1,22,75,cAliasAux)
	
	DbSelectArea("SE2")
	//Set Filter To
	SE2->(DbCloseArea())
	RestArea(aArea)
Return




User Function V2AltCC()
	SetPrvt("_cCCusto,_cItemC, _cClasse")
	
	_cCCusto 	:= SE2->E2_CCD 
	_cItemC 	:= SE2->E2_ITEMD   
	_cClasse 	:= SE2->E2_CLVLDB  
	 
	@ 100,200 To 350,600 Dialog oDlgCC Title "Altera CC do Titulo: " + SE2->E2_PREFIXO + "-" + SE2->E2_NUM + "" 
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
		Reclock("SE2",.F.)
		SE2->E2_CCD 	:=	_cCCusto 	
		SE2->E2_ITEMD 	:= 	_cItemC 	
		SE2->E2_CLVLDB 	:= 	_cClasse  
		MsUnlock("SE2") 	    
 	End Transaction 	
Return Nil
 
//*************************
Static Function _Sair()
	Close(oDlgCC)
Return Nil
