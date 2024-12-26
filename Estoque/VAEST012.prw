#include "Protheus.ch"
#include "TopConn.ch"

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  25.01.2017                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function VAEST012()

Local cAlias  := "Z09"
Local cTitulo := "Cadastro de Idades"
Local cVldDel := ".T."
Local cVldAlt := ".T." 

	AxCadastro(cAlias,cTitulo,cVldDel,cVldAlt)
Return nil

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  25.01.2017                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function ComTamCpo()
Local cCodigo := Upper(AllTrim(&(ReadVar())))
	If !Empty(cCodigo)
		If Len(cCodigo) < TamSX3(SubStr(ReadVar(),4))[1]
			&(ReadVar()) := StrZero( Val(cCodigo) , TamSX3(SubStr(ReadVar(),4))[1] )
		Else
			&(ReadVar()) := cCodigo	
		EndIf
	EndIf
Return .T.