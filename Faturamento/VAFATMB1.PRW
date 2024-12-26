#INCLUDE "TOTVS.CH"
#INCLUDE "RWMAKE.CH" 
#INCLUDE "PROTHEUS.CH"


/*--------------------------------------------------------------------------------,
 | Principal: 					   U_VAFATMB1()          		            	  |
 | Func:  VAFATMB1()	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  04.09.2019	            	          	            	              |
 | Desc:  Permitir acesso via programação para alterar parametro de validação da  |
 '          Nota Fiscal.                                                          |
 '--------------------------------------------------------------------------------|
 | Obs.:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------*/
User Function VAFATMB1()
// Local cPerg		:= "VAFATMB1"

// Informa se haverá consulta da NFE/CTE no portal da SEFAZ; .T. = Sim; .F. = Não.
Local lValChave := GetMV("MV_CHVNFE") 

If MsgYesNo("Atualmente o Parametro esta configurado para:" + Iif(lValChave," "," NÃO ") + "VALIDAR a chave da Nota Fiscal."+CRLF+;
		CRLF+"Deseja INVERTER a configuração do parametro ?")

	lValChave := !lValChave
	If lValChave
		PutMV("MV_CHVNFE", ".T.")
	Else
		PutMV("MV_CHVNFE", ".F.")
	EndIf
	
	MsgInfo("O Parametro ficou configurado para:" + Iif(lValChave," "," NÃO ") + "VALIDAR a chave da Nota Fiscal.")
EndIf

Return nil