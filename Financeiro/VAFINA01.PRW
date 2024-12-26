//Cadastro de Prefixos de Titulos Válidos
User Function VAFINA01()
	Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
	Local cVldExc := ".F." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
	
	Private cString := "SZ2"
	
	dbSelectArea("SZ2")
	dbSetOrder(1)
	
	AxCadastro(cString,"Prefixos Financeiros",cVldExc,cVldAlt)	
Return