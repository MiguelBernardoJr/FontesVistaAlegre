USER FUNCTION MT103CPS()
	Local lAtivo  := SuperGetMv("MV_DESQIVE",,.T.) 
	
	if lAtivo
		// Ponto de chamada ConexãoNF-e sempre como primeira instrução.
		U_GTPE022()
	endif 
	//If
		//	Regra existente
		//	[...]
	//EndIf

Return
