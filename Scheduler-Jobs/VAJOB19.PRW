#Include "Totvs.ch"
User Function VAJOB19()
    ConOut('VAJOB13(): ' + Time())
	
	If Type("oMainWnd") == "U"
		ConOut('oMainWnd: ' + Time())
		U_RunFunc("U_JOB19VA()",'01','01',3) 
	Else
		ConOut('Else oMainWnd: ' + Time())
		U_JOB19VA()
	EndIf
Return

User Function JOB19VA()
   	Local aArea     := FWGetArea()
 
    Private cPerg      := "VARELM01"
    Private cTitulo    := "Relatorio Baia e Pasto"
 
	
	//seta o ambiente com a empresa 99 filial 01 com os direitos do usuário administrador, módulo CTB
	//RpcSetEnv( "01","0101", "Administrador", " ", "CTB", "CTBA102", {}, , , ,  )
	
	/************* Processamentos *************/
	
		/*******COMANDOS *********/
		Pergunte( cPerg, .F.)

		MV_PAR01 := 3
		MV_PAR02 := 100
		MV_PAR03 := 0
		MV_PAR04 := dDataBase
		MV_PAR05 := dDataBase
		MV_PAR06 := 1
		MV_PAR07 := 2
		MV_PAR08 := 2
		MV_PAR09 := 2
		
		U_RELM01VA()
		
		conout('Tempo de processamento: ' + ElapTime( cTimeINI, Time() ) )
	
	//RpcClearEnv() //Encerra o ambiente, fechando as devidas conexões

	FWRestArea(aArea)
Return
