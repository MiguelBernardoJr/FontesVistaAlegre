#Include "Totvs.ch"
#Include "Rwmake.ch" 
#Include "Protheus.ch"
#Include "TopConn.ch"
#INCLUDE "XMLXFUN.CH"

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  13.11.2018                                                              |
 | Desc:  Cadastro de Lançamentos de Limpeza de Baia;                             |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function  VAESTM01()	// U_VAESTM01()


Local cAlias  := "ZLB"
Local cTitulo := "Lançamento das Limpezas das Baia"
Local cVldDel := ".T."
Local cVldAlt := ".T." 

	AxCadastro(cAlias,cTitulo,cVldDel,cVldAlt)
	
Return nil

