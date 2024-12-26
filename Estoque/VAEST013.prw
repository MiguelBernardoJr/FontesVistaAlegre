#include "Protheus.ch"
#include "TopConn.ch"

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  25.01.2017                                                              |
 | Desc:  Processamento da ERA no cadastro do produto. Atualizando campo de idade |
 |        do animal e Era.                                                        |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function VAEST013()

Local aArea 	 := GetArea()
Local _cQry 	 := ""
Local _TMP       := GetNextAlias()

Local cPerg	 	:= 'VAEST013'

Local nI		:= 0

CriaSX1(cPerg)
If !Pergunte(cPerg,.T.)
	Return nil 
EndIf

_cQry := " with  " + CRLF
_cQry += " AnimalxEra as  " + CRLF
_cQry += " ( " + CRLF
_cQry += " 	SELECT B1.R_E_C_N_O_ R_E_C_N_O_, B1_XIDADE IDADE_ANTERIOR, DATEDIFF(MONTH, CONVERT(DATETIME, B1_DTNASC, 103), GETDATE()) IDADE_ATUAL,  " + CRLF
_cQry += " 	B1_COD, B1_DESC, " + CRLF
_cQry += " 	Z09_ITEM, Z09_DESCRI, Z09_RACA, Z09_SEXO, Z09_IDAINI, Z09_IDAFIM " + CRLF
_cQry += " 	FROM " + RetSqlName('SB1') + " B1 " + CRLF
_cQry += " 	join " + RetSqlName('Z09') + " Z9 ON B1_FILIAL='"+xFilial('SB1')+"' AND Z09_FILIAL='"+xFilial('Z09')+"' AND B1_XANIMAL=Z09_CODIGO AND B1.D_E_L_E_T_=' ' AND Z9.D_E_L_E_T_=' '  " + CRLF
_cQry += " 	WHERE " + CRLF
_cQry += " 			B1_COD BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'  " + CRLF
_cQry += " 			AND B1_MSBLQL<>'1' " + CRLF
_cQry += " ), " + CRLF
_cQry += "  " + CRLF
_cQry += " Atualizar as " + CRLF
_cQry += " ( " + CRLF
_cQry += " 	SELECT R_E_C_N_O_, B1_COD, B1_DESC, Z09_ITEM, Z09_DESCRI, Z09_RACA, Z09_SEXO, IDADE_ANTERIOR, IDADE_ATUAL " + CRLF
_cQry += " 	FROM AnimalxEra " + CRLF
_cQry += " 	WHERE  " + CRLF
//_cQry += " 		IDADE_ANTERIOR <> IDADE_ATUAL AND  " + CRLF
_cQry += " 		IDADE_ATUAL BETWEEN Z09_IDAINI AND Z09_IDAFIM " + CRLF
_cQry += " ) " + CRLF
_cQry += "  " + CRLF
_cQry += " SELECT * FROM Atualizar "

DbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_TMP),.F.,.F.)
	
While !(_TMP)->(Eof())
	nI+=1
	SB1->(DbGoTo((_TMP)->R_E_C_N_O_))
	
	RecLock('SB1', .F.)                                       
		SB1->B1_XANIITE := (_TMP)->Z09_ITEM
		SB1->B1_XIDADE  := AllTrim(Str((_TMP)->IDADE_ATUAL))
		SB1->B1_X_ERA   := (_TMP)->Z09_DESCRI
		SB1->B1_XRACA	:= (_TMP)->Z09_RACA // alterando a RAÇA pq o produto pode ter sido trocado o codigo de relacionamento da ERA: B1_XANIMAL
		SB1->B1_X_SEXO  := (_TMP)->Z09_SEXO // alterando o SEXO pq o produto pode ter sido trocado o codigo de relacionamento da ERA: B1_XANIMAL
	SB1->(MsUnlock())

	(_TMP)->(DbSkip())
EndDo
If nI > 0 
	Aviso("Aviso", "Proceso finalizado com Sucesso!" + CRLF + ;
					"Foram ajustados: " + StrZero(nI, 3) + " cadastros.", {"Ok"},3)
EndIf
(_TMP)->(DbCloseArea())
RestArea(aArea)
Return nil


/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  25.01.2017                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function CriaSX1(cPerg)
	Local nI      := 0
	Local aPerg   := {}

	SX1->(DbSetOrder(1))
	If SX1->( DbSeek( cPerg ) )
		Return nil
	EndIf

	aAdd(aPerg,{ "Produto De: " , "C" , TamSX3('B1_COD')[1] , 00 , "G" , "" , "" , "" , "" , "", "SB1" })
	aAdd(aPerg,{ "Produto Ate:" , "C" , TamSX3('B1_COD')[1] , 00 , "G" , "" , "" , "" , "" , "", "SB1" })

	For nI := 1 to Len( aPerg )
		RecLock( "SX1" , .T. )
			SX1->X1_GRUPO     := cPerg
			SX1->X1_ORDEM     := StrZero( nI , 2 )
			SX1->X1_VARIAVL   := "MV_CH"  + Upper( Chr( nI + 96 ) )
			SX1->X1_VAR01     := "MV_PAR" + Upper( StrZero( nI , 2 ) )
			SX1->X1_PRESEL    := 1
			SX1->X1_PERGUNT   := aPerg[ nI , 01 ]
			SX1->X1_TIPO      := aPerg[ nI , 02 ]
			SX1->X1_TAMANHO   := aPerg[ nI , 03 ]
			SX1->X1_DECIMAL   := aPerg[ nI , 04 ]
			SX1->X1_GSC       := aPerg[ nI , 05 ]
			SX1->X1_DEF01     := aPerg[ nI , 06 ]
			SX1->X1_DEF02     := aPerg[ nI , 07 ]
			SX1->X1_DEF03     := aPerg[ nI , 08 ]
			SX1->X1_DEF04     := aPerg[ nI , 09 ]
			SX1->X1_DEF05     := aPerg[ nI , 10 ]
			SX1->X1_F3        := aPerg[ nI , 11 ]
		SX1->( MsUnlock() )
	Next nI
Return nil



/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  26.01.2017                                                              |
 | Desc:  Validacao com compartamento igual de um gatilho. A opartir de uma Sele- |
 |        cao preencher os campos envolvendo o controle de ERA.                   |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function VAEST13A()
Local aArea 	 := GetArea()
Local _cQry 	 := ""
Local _TMP       := GetNextAlias()
Local nMeses

RegToMemory( "Z05", INCLUI )
If Empty(M->B1_DTNASC)
	ShowHelpDlg("VAEST13A-01", 	{'Nao foi localizado informacao no campo de Data de Nascimento.'}, ,;
								{"Por Favor verifique o campo para continuar !!!"}, )
Else
	nMeses := DateDiffMonth( M->B1_DTNASC , dDataBase ) //Apura Diferenca em Meses entre duas Datas	

	_cQry := " select Z09_ITEM, Z09_DESCRI, Z09_RACA, Z09_SEXO  " + CRLF
	_cQry += " from Z09010  " + CRLF
	_cQry += " where  " + CRLF
	_cQry += " 		Z09_FILIAL='"+xFilial('Z09')+"' " + CRLF
	_cQry += " 	and Z09_CODIGO = '"+M->B1_XANIMAL+"' " + CRLF
	_cQry += " 	and "+AllTrim(Str(nMeses))+" BETWEEN Z09_IDAINI AND Z09_IDAFIM " + CRLF
	_cQry += " 	and D_E_L_E_T_=' '  " + CRLF

	DbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_TMP),.F.,.F.)
	If !(_TMP)->(Eof())   
		M->B1_XANIITE := (_TMP)->Z09_ITEM
		M->B1_X_ERA   := (_TMP)->Z09_DESCRI
		M->B1_XRACA   := (_TMP)->Z09_RACA
		M->B1_X_SEXO  := (_TMP)->Z09_SEXO
	EndIf
	(_TMP)->(DbCloseArea())
EndIf
RestArea(aArea)
Return .T.