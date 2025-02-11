#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "parmtype.ch"
#INCLUDE "TOTVS.CH"
/* Igor Oliveira 06/2022
    Consulta para Funcionarios */
User Function RAMatSX()
    Local aArea			:= GetArea()
	Local cFunBkp 		:= FunName()
	Local lRet 			
	//Private _cMat		:= CriaVar('Z0U_MAT', .F.)
	SetFunName("SracFUN")
	
	lRet := SracFUN()
	
	SetFunName(cFunBkp)
	RestArea(aArea)
RETURN lRet

User Function SracFUN()
    Local aArea			:= GetArea()
    Local _cQry  		:= ""
    /* Local lRet   		:= .F. */
	Local _cMat         
	
	
	if Type("uRetorno") == 'U'
		public uRetorno
	endif

	uRetorno := ''

	_cQry := " SELECT RA_MAT " + CRLF
	_cQry += "			, RA_NOME " + CRLF
	_cQry += "		    , R_E_C_N_O_ SRARECNO " + CRLF
	_cQry += "	FROM " + RetSqlName("SRA")+ " " + CRLF
	_cQry += "	WHERE RA_FILIAL = '"+FWxFilial("SRA")+"'" + CRLF
	_cQry += "	AND RA_DEMISSA = ''  " + CRLF
	_cQry += "	AND D_E_L_E_T_ = '' " + CRLF
	_cQry += "	ORDER BY 1" + CRLF

	MsgAlert("TESTE", "Atencao")
	 
    if u_F3Qry( _cQry, 'MATRICULA', 'SRARECNO', @uRetorno,, { "RA_MAT", "RA_NOME" } )
       	 SRA->(DbGoto( uRetorno ))
			_cMat 	:= SRA->RA_MAT
		 lRet := .t. 
    endif

if aArea[1] <> "SRA"
    RestArea( aArea )
endif
RETURN _cMat
