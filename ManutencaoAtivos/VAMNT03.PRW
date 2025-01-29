#include "PROTHEUS.CH"
#include "TOPCONN.CH"
#include "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "TOTVS.CH"  
#include "parmtype.ch"

#DEFINE GD_NOME     1
#DEFINE GD_CONTEUDO 2

Static cTitulo := "Apontamento de Fretes"

User Function VAMNT03()
    Local aArea     	:= GetArea()
	Local oBrowse
	Local cFunBkp   	:= FunName()
    Private cArquivo    := "C:\TOTVS_RELATORIOS\"
	Private _nRet 	    := CriaVar('ZPB_PESOL'  , .F.)
	Private _cRet 	    := CriaVar('A2_COD'  	, .F.)
	Private aCampos := {"ZVF_OPESO" ,;
						"ZVF_ODATA" ,;
						"ZVF_SDATA" ,;
						"ZVF_ZPBCOD",;
						"ZVF_NF"    ,;
						"ZVF_FORN"  ,;
						"ZVF_LOJA"  ,;
						"ZVF_NFOR"  ,;
						"ZVF_END"   ,;
						"ZVF_EST"   ,;
						"ZVF_CMUN"  ,;
						"ZVF_MUN"   ,;
						"ZVF_DMUN"  ,;
						"ZVF_DDMUN" ,;
						"ZVF_DEST"  ,;
						"ZVF_PROD"  ,;
						"ZVF_DESC"  ,;
						"ZVF_MANIF" ,;
						"ZVF_MOT"   ,;
						"ZVF_NMOT"  ,;
						"ZVF_PLACA" ,;
						"ZVF_ICTA"  ,;
						"ZVF_PLC1"  ,;
						"ZVF_ITCC1" ,;
						"ZVF_PLC2"  ,;
						"ZVF_ITCC2" ,;
						"ZVF_OKM" 	,;
						"ZVF_KMF" 	,;
						"ZVF_KMT" 	,;
						"ZVF_VALOR" ,;
						"ZVF_HORAS" ,;
						"ZVF_OHORA" ,;
						"ZVF_PEDAGI",;
						"ZVF_CLASSE",;
						"ZVF_DESC01",;
						"ZVF_CC"	}
	Private lBusZPB := .F.

	SetFunName("VAMNT03")
	//Cria um browse para a ZVF, filtrando somente a tabela 00 (cabeçalho das tabelas
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZVF")

	oBrowse:AddLegend( "ZVF->ZVF_STATUS == 'A'", "GREEN",	"Aberto" )
	oBrowse:AddLegend( "ZVF->ZVF_STATUS == 'F'", "RED",		"Fechado" )

	//oBrowse:SetFilterDefault("ZVF->ZVF_DATA == '"+DTOS(dDataBase)+"'")
	oBrowse:SetDescription(cTitulo)
	oBrowse:Activate()

	SetFunName(cFunBkp)
	RestArea(aArea)
Return 

Static Function MenuDef()
	Local aRot := {}

	ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.VAMNT03' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.VAMNT03' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.VAMNT03' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.VAMNT03' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
Return aRot


Static Function ModelDef()
	Local oModel   	:= Nil
	Local oStPai   	:= FWFormStruct(1, 'ZVF')
    Local nI
    Local aGatilhos := {}

    aAdd(aGatilhos, FWStruTriggger( "ZVF_PROD"	,"ZVF_DESC" ,"alltrim(SB1->B1_DESC)" 	,.t.,"SB1",1,"FWXfilial('SB1') + M->ZVF_PROD"                   ,NIL,"01"))
	aAdd(aGatilhos, FWStruTriggger( "ZVF_MOT" 	,"ZVF_NMOT" ,"alltrim(DA4->DA4_NOME)"	,.t.,"DA4",1,"FWXfilial('DA4') + M->ZVF_MOT"                    ,NIL,"01"))
	aAdd(aGatilhos, FWStruTriggger( "ZVF_LOJA"	,"ZVF_NFOR" ,"alltrim(SA2->A2_NOME)" 	,.t.,"SA2",1,"FWXfilial('SA2') + M->ZVF_FORN + M->ZVF_LOJA"  	,"M->ZVF_COMBO == 'F'","01"))
    aAdd(aGatilhos, FWStruTriggger( "ZVF_LOJA"	,"ZVF_END" 	,"alltrim(SA2->A2_END)" 	,.t.,"SA2",1,"FWXfilial('SA2') + M->ZVF_FORN + M->ZVF_LOJA"  	,"M->ZVF_COMBO == 'F'","02"))
    aAdd(aGatilhos, FWStruTriggger( "ZVF_LOJA"	,"ZVF_NFOR" ,"alltrim(SA1->A1_NOME)" 	,.t.,"SA1",1,"FWXfilial('SA1') + M->ZVF_FORN + M->ZVF_LOJA"  	,"M->ZVF_COMBO == 'C'","03"))
    aAdd(aGatilhos, FWStruTriggger( "ZVF_LOJA"	,"ZVF_END" 	,"ALLTRIM(SA1->A1_END)" 	,.t.,"SA1",1,"FWXfilial('SA1') + M->ZVF_FORN + M->ZVF_LOJA"  	,"M->ZVF_COMBO == 'C'","04"))
    
    //aAdd(aGatilhos, FWStruTriggger( "ZVF_OPESO"	,"ZVF_ODATA" 	,"U_MNT03PE()" 				,.f.,""   ,nil,""  												,NIL,"01"))

	aAdd(aGatilhos, FWStruTriggger( "ZVF_CMUN"	,"ZVF_EST" 	,"ALLTRIM(CC2->CC2_EST)" 	,.t.,"CC2",3,"FWXfilial('CC2') + M->ZVF_CMUN"  					,NIL,"01"))
    aAdd(aGatilhos, FWStruTriggger( "ZVF_CMUN"	,"ZVF_MUN" 	,"ALLTRIM(CC2->CC2_MUN)" 	,.t.,"CC2",3,"FWXfilial('CC2') + M->ZVF_CMUN"  					,NIL,"02"))
	aAdd(aGatilhos, FWStruTriggger( "ZVF_DMUN"	,"ZVF_DEST" ,"ALLTRIM(CC2->CC2_EST)" 	,.t.,"CC2",3,"FWXfilial('CC2') + M->ZVF_DMUN"  					,NIL,"01"))
    aAdd(aGatilhos, FWStruTriggger( "ZVF_DMUN"	,"ZVF_DDMUN","ALLTRIM(CC2->CC2_MUN)" 	,.t.,"CC2",3,"FWXfilial('CC2') + M->ZVF_DMUN"  					,NIL,"02"))
    
	aAdd(aGatilhos, FWStruTriggger( "ZVF_PLACA"	,"ZVF_ICTA" ,"ALLTRIM(ST9->T9_ITEMCTA)" ,.t.,"ST9",19,"FWXfilial('ST9') + M->ZVF_PLACA" 				,NIL,"01"))
	aAdd(aGatilhos, FWStruTriggger( "ZVF_PLACA"	,"ZVF_PLC1" ,"ALLTRIM(ST9->T9_X_CC1)" 	,.t.,"ST9",19,"FWXfilial('ST9') + M->ZVF_PLACA"  				,NIL,"02"))
	aAdd(aGatilhos, FWStruTriggger( "ZVF_PLACA"	,"ZVF_PLC2" ,"ALLTRIM(ST9->T9_X_CC2)" 	,.t.,"ST9",19,"FWXfilial('ST9') + M->ZVF_PLACA" 				,NIL,"03"))
	aAdd(aGatilhos, FWStruTriggger( "ZVF_PLC1"	,"ZVF_ITCC1","ALLTRIM(ST9->T9_ITEMCTA)" ,.t.,"ST9",19,"FWXfilial('ST9') + M->ZVF_PLC1"  				,NIL,"01"))
	aAdd(aGatilhos, FWStruTriggger( "ZVF_PLC2"	,"ZVF_ITCC2","ALLTRIM(ST9->T9_ITEMCTA)" ,.t.,"ST9",19,"FWXfilial('ST9') + M->ZVF_PLC2" 					,NIL,"01"))

	aAdd(aGatilhos, FWStruTriggger( "ZVF_CLASSE","ZVF_DESC01","ALLTRIM(CTH->CTH_DESC01)",.t.,"CTH",1,"FWXfilial('CTH') + M->ZVF_CLASSE" 					,NIL,"01"))

    For nI := 1 To Len(aGatilhos)
        oStPai:AddTrigger(  aGatilhos[nI][01],; //Campo Origem
							aGatilhos[nI][02],; //Campo Destino
							aGatilhos[nI][03],; //Bloco de código na validação da execução do gatilho
							aGatilhos[nI][04])  //Bloco de código de execução do gatilho
    Next

    oStPai:SetProperty('ZVF_OHORA', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "U_MNT03HR()")) //validação
    oStPai:SetProperty('ZVF_HORAS', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "U_MNT03HR()")) //validação
    oStPai:SetProperty('ZVF_KMF'  , MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "U_MNT03KM()")) //validação
    oStPai:SetProperty('ZVF_OKM'  , MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "U_MNT03KM()")) //validação
    oStPai:SetProperty('ZVF_PLACA', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "U_MNT03PL()")) //validação
    oStPai:SetProperty('ZVF_PLC1' , MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "U_MNT03PL()")) //validação
    oStPai:SetProperty('ZVF_PLC2' , MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "U_MNT03PL()")) //validação
    oStPai:SetProperty('ZVF_OPESO', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "U_MNT03PS()")) //validação
    oStPai:SetProperty('ZVF_FORN' , MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "U_MNT03FN()")) //validação
    oStPai:SetProperty('ZVF_COMBO', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, "U_MNT03CB()")) //validação

	//Criando o FormModel, adicionando o Cabeçalho e Grid
	oModel := MPFormModel():New("MNT03M",/*Pre-Validacao*/,  /*Pos-Validacao*/,  /*Commit*/,/*Cancel*/)

	oModel:AddFields("ZVFMASTER",/*cOwner*/ ,oStPai  )
	
	oModel:SetPrimaryKey({ })

	//Setando outras informações do Modelo de Dados
	oModel:SetDescription("Dados do Cadastro "+cTitulo)
	oModel:GetModel("ZVFMASTER"):SetDescription("Formulário do Cadastro "+cTitulo)

    oModel:InstallEvent("VLD_MODEL", , MNT03EVENT():New(oModel))
Return oModel

Static Function ViewDef()
	Local oModel     := FWLoadModel("VAMNT03")
	Local oStPai     := FWFormStruct(2, 'ZVF')
	Local oView      := FWFormView():New()

	oView:SetModel(oModel)
	oView:AddField("VIEW_CAB" , oStPai  , "ZVFMASTER")

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CABEC', 100)

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_CAB'  ,'CABEC')

	//Habilitando título
	oView:EnableTitleView('VIEW_CAB','Cabeçalho - ' + cTitulo)

	//Tratativa padrão para fechar a tela
	oView:SetCloseOnOk( { |oView| .T. } )

Return oView

User Function MNT03M()
	Local aParam 		:= PARAMIXB
	Local xRet 			:= .T.
	Local cIdPonto 		:= ''
	Local cIdModel 		:= ''
	Local cIdIXB5		:= ''
	Local cIdIXB4		:= ''
	Local oModel 	 	:= nil
	Local oCab 			:= nil
	Local aSaveLines 	:= FWSaveRows()

	If aParam <> NIL
		oObj := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]

		if len(aParam) >= 4
			cIdIXB4  := aParam[4]
		endif 

		if len(aParam) >= 5
			cIdIXB5  := aParam[5]
		endif

		if Alltrim(cIdPonto) == "FORMPRE" .and. cIdModel == 'ZVFMASTER' .AND. cIdIXB4 == 'SETVALUE' .and. AllTrim(cIdIXB5) $ 'ZVF_SDATA|ZVF_ODATA|ZVF_FORN|ZVF_PROD|ZVF_MOT|ZVF_PLACA|ZVF_HORAS|ZVF_OHORA'
			oModel 	 	:= FwModelActivate()
			oCab 		:= oModel:GetModel("ZVFMASTER")

			if oCab:GetValue("ZVF_OPESO") != 0 
				iF MSGYESNO( "Alterar esse campo com o peso preenchido, irá apagar todos os campos do cadastro!", "Continua?" )
					LimparDados()
				else
					xRet := .f.
				endif
			endif 
		endif
	endif
	FWRestRows( aSaveLines )
return xRet

User Function MNT03HR()
	Local lRet 			:= .T.
	Local cCampo 		:= SubStr(ReadVar(),4,len(ReadVar()))
	Local cHora			:= &(ReadVar())

	IF cCampo == "ZVF_HORAS"	
		IF !(Left(cHora,2)>='00' .And. Left(cHora,2)<'24' .And. Right(cHora,2)>='00' .And. Right(cHora,2)<='59')
			lRet := .F.
		endif
	ELSEIF cCampo == "ZVF_OHORA"	
		IF !(Left(cHora,2)>='00' .And. Left(cHora,2)<'24' .And. Right(cHora,2)>='00' .And. Right(cHora,2)<='59')
			lRet := .F.
		endif
	endif
Return lRet

User Function MNT03KM()
	Local oModel		:= FWModelActive()
	Local oStruct 		:= oModel:GetModel("ZVFMASTER")
	Local lRet 			:= .T.
	Local cCampo 		:= SubStr(ReadVar(),4,len(ReadVar()))
	Local nKM			:= &(ReadVar())

	IF cCampo == 'ZVF_KMF'	
		if nKM < oStruct:GetValue("ZVF_OKM")
			lRet := .F. 
			oModel:SetErrorMessage("","","","","Km Inválido", 'KM final não pode ser menor que o Inicial!', "") 
		endif 
	ELSE
		if oStruct:GetValue("ZVF_KMF") != 0
			if nKM > oStruct:GetValue("ZVF_KMF")
				lRet := .F.
				oModel:SetErrorMessage("","","","","Km Inválido", 'KM Inicial não pode ser maior que o Final!', "") 
			endif 
		endif
	ENDIF 
	if lRet 
		oStruct:SetValue("ZVF_KMT",oStruct:GetValue("ZVF_KMF") - oStruct:GetValue("ZVF_OKM"))
	endif 
Return lRet 
//Validação dos campos ZVF_PLC1, ZVF_PLC2 e ZVF_PLACA
User Function MNT03PL()
	Local oModel		:= FWModelActive()
	Local oStruct 		:= oModel:GetModel("ZVFMASTER")
	Local lRet 			:= .T.
	Local cCampo 		:= SubStr(ReadVar(),4,len(ReadVar()))
	Local cPlaca 		:= &(ReadVar())
	Local cQry 			:= ""

	cQry := "select * from "+RetSqlName("ZVF")+" WHERE ZVF_STATUS = 'A' AND "+cCampo+" = '"+ALLTRIM(cPlaca)+"' AND D_E_L_E_T_ = ''"
	MpSysOpenQuery(cQry,"TMP")
	
	IF !TMP->(EOF())
		lRet := .F.
		oModel:SetErrorMessage("","","","","Placa Inválida", 'Placa está com outro frete em aberto: ' + CRLF+;
															'' + CRLF +;
															'Placa: '+cPlaca+' ' + CRLF+;
															'Cod:   '+TMP->ZVF_COD+' ' + CRLF +;
															'' + CRLF +;
															'Termine o cadastro que está em aberto para cadastrar outro!', "")
		TMP->(DBCLOSEAREA(  ))
	else 
		if cCampo == 'ZVF_PLC1'
			if cPlaca == oStruct:GetValue("ZVF_PLACA") .OR. cPlaca == oStruct:GetValue("ZVF_PLC2")
				lRet := .F.
				oModel:SetErrorMessage("","","","","Placa Inválida", 'Placa já está inserida no cadastro', "") 
			endif 
		ELSEif cCampo == 'ZVF_PLC2'
			if cPlaca == oStruct:GetValue("ZVF_PLACA") .OR. cPlaca == oStruct:GetValue("ZVF_PLC1")
				lRet := .F.
				oModel:SetErrorMessage("","","","","Placa Inválida", 'Placa já está inserida no cadastro', "") 
			endif
		ELSEif cCampo == 'ZVF_PLACA'
			if cPlaca == oStruct:GetValue("ZVF_PLC2") .OR. cPlaca == oStruct:GetValue("ZVF_PLC1")
				lRet := .F.
				oModel:SetErrorMessage("","","","","Placa Inválida", 'Placa já está inserida no cadastro', "") 
			endif
		ENDIF
	ENDIF

	if lRet 
		cQry := "SELECT T9_ITEMCTA FROM "+RetSqlName("ST9")+" WHERE T9_PLACA = '"+cPlaca+"'"
		MpSysOpenQuery(cQry,"TMP")
		if !TMP->(EOF())
			if cCampo == 'ZVF_PLC1'
				oStruct:SetValue("ZVF_ITCC1",TMP->T9_ITEMCTA)
			elseIF cCampo == 'ZVF_PLC2'
				oStruct:SetValue("ZVF_ITCC2",TMP->T9_ITEMCTA)
			ELSE 
				oStruct:SetValue("ZVF_ICTA" ,TMP->T9_ITEMCTA)
			endif 
		ENDIF 
		TMP->(DBCLOSEAREA(  ))
	endif 
Return lRet

User Function MNT03PS()
	Local nPeso 		:= &(ReadVar())
	Local lRet := .T.
	
	if !lBusZPB
		lRet := .F.
	elseif nPeso == 0
		LimparDados()
	endif

	lBusZPB := .F.
Return lRet 
//GATILHO PARA PEGAR ULTIMOS REGISTROS E PREENCHER PLACA DAS CARRETAS A PARTIR DA PLACA DO CAVALO
User Function T03GPS()
	Local oModel	:= FWModelActive()
	Local oCab 		:= oModel:GetModel("ZVFMASTER")
	Local cQry 		:= ""
	Local cRet 		:= ''

	cQry := "select TOP 1 * from "+RetSqlName("ZVF")+" WHERE ZVF_PLACA = '"+oCab:GetValue("ZVF_PLACA")+"' ORDER BY R_E_C_N_O_ DESC "

	MpSysOpenQuery(cQry,"TMP")

	if !TMP->(EOF())
		cRet := TMP->ZVF_PLC1
		oCab:SetValue("ZVF_ITCC1" ,TMP->ZVF_ITCC1)
		oCab:SetValue("ZVF_PLC2" ,TMP->ZVF_PLC2)
		oCab:SetValue("ZVF_ITCC2",TMP->ZVF_ITCC2)
	endif
	
	TMP->(DBCLOSEAREA(  ))

Return cRet 

Static Function LimparDados()
	Local oModel	:= FWModelActive()
	Local oCab 		:= oModel:GetModel("ZVFMASTER")
	Local nI 

	For nI := 1 To Len(aCampos)
		if !EMPTY(oCab:GetValue(aCampos[nI])) 
			if ValType(oCab:GetValue(aCampos[nI])) == "D"
				oCab:LoadValue(aCampos[nI], dDataBase) 
			elseif ValType(oCab:GetValue(aCampos[nI])) == "C"
				oCab:LoadValue(aCampos[nI], Space(TamSx3(aCampos[nI])[1])) 
			elseif ValType(oCab:GetValue(aCampos[nI])) == "N"
				oCab:LoadValue(aCampos[nI], 0) 
			endif 
		endif
	Next nI
Return 
//Iniciador Padrão Campo ZVF_FORN
// retornar a2_nome
User Function MNT03IN()
	Local cRet

	IF ZVF->ZVF_COMBO = 'F'
		cRet := Posicione("SA2",1,FWXfilial("SA2")+ZVF->ZVF_FORN+ZVF->ZVF_LOJA,"A2_NOME")
	ELSEIF ZVF->ZVF_COMBO = 'C'
		cRet := Posicione("SA1",1,FWXfilial("SA1")+ZVF->ZVF_FORN+ZVF->ZVF_LOJA,"A1_NOME")
	ENDIF 
Return cRet 

User Function MNT03CF(cTipo)
	Local oModel	:= FWModelActive()
	Local oCab 		:= oModel:GetModel("ZVFMASTER")
    Local _cQry  		:= ""
	Local lRet 		:= .T.
	Local aCampos 	:= {}
	Local aHeader, aCols := {}

	if cTipo == '1'
		if EMPTY(oCab:GetValue("ZVF_COMBO")) 
			lRet := .F.	
			oModel:SetErrorMessage("","","","","Erro", 'Preencha o Campo combo!', "") 
		else
			if oCab:GetValue("ZVF_COMBO") == 'F'
				AADD(aCampos, {"Código"    	, "_QRY1->A2_COD" 	})
				AADD(aCampos, {"Loja" 		, "_QRY1->A2_LOJA"	})
				AADD(aCampos, {"Nome"		, "_QRY1->A2_NOME" 	})
				AADD(aCampos, {"CNPJ"  		, "_QRY1->A2_CGC"	})
				AADD(aCampos, {"Municipio"  , "_QRY1->A2_MUN"	})
				AADD(aCampos, {"Endereço"   , "_QRY1->A2_END"	})
				AADD(aCampos, {"Recno"  	, "_QRY1->SA2RECNO"	})
				
				_cQry 	:= "SELECT A2_COD, A2_LOJA, A2_NOME,A2_CGC,A2_MUN,A2_END,R_E_C_N_O_ SA2RECNO FROM " + RetSqlName("SA2")+ " WHERE D_E_L_E_T_ = ''"
				aHeader := {{nil,nil,nil,nil,nil,nil,nil}}
				aCols := {{nil,nil,nil,nil,nil,nil,nil}}
				aFiltros := {"Código","Fornecedor"/* ,"Data Saida","Data Chegada" */ /* ,"CPF/CNPJ" */}
				U_PPlaca(aHeader,aCols,aCampos,_cQry,cTipo,aFiltros,"Pesquisa - Fornecedores")
			else 
				AADD(aCampos, {"Código"    	, "_QRY1->A1_COD" 	})
				AADD(aCampos, {"Loja" 		, "_QRY1->A1_LOJA"	})
				AADD(aCampos, {"Nome"		, "_QRY1->A1_NOME" 	})
				AADD(aCampos, {"CNPJ"  		, "_QRY1->A1_CGC"	})
				AADD(aCampos, {"Municipio"  , "_QRY1->A1_MUN"	})
				AADD(aCampos, {"Endereço"   , "_QRY1->A1_END"	})
				AADD(aCampos, {"Recno"  	, "_QRY1->SA1RECNO"	})
				
				_cQry := "SELECT A1_COD,A1_LOJA,A1_NOME,A1_CGC,A1_MUN,A1_END,R_E_C_N_O_ SA1RECNO FROM " + RetSqlName("SA1")+ " WHERE D_E_L_E_T_ = ''"
				aHeader := {{nil,nil,nil,nil,nil,nil,nil}}
				aCols := {{nil,nil,nil,nil,nil,nil,nil}}
				aFiltros := {"Código","Cliente"/* ,"Data Saida","Data Chegada" */ /* ,"CPF/CNPJ" */}
				U_PPlaca(aHeader,aCols,aCampos,_cQry,cTipo,aFiltros,"Pesquisa - Clientes")
			endif 
		endif 
	elseif cTipo == '2'

		AADD(aCampos, {"Data"    	, "sToD(_QRY1->ZPB_DATA)" 	})
		AADD(aCampos, {"Data Final" , "sToD(_QRY1->ZPB_DATAF)"	})
		AADD(aCampos, {"Placa"		, "_QRY1->ZPB_PLACA" 		})
		AADD(aCampos, {"Motorista"  , "_QRY1->ZPB_NOMMOT"		})
		AADD(aCampos, {"Fornecedor"	, "_QRY1->ZPB_CODFOR"		})
		AADD(aCampos, {"Loja"   	, "_QRY1->ZPB_LOJFOR"		})	
		AADD(aCampos, {"Nome"  		, "_QRY1->ZPB_NOMFOR"		})
		AADD(aCampos, {"Municipio"  , "_QRY1->A2_MUN"			})
		AADD(aCampos, {"Estado"  	, "_QRY1->A2_EST"			})
		AADD(aCampos, {"Cliente?"  	, "_QRY1->ZPB_CLIFOR"		})
		AADD(aCampos, {"Produto" 	, "_QRY1->ZPB_PRODUT"		})	
		AADD(aCampos, {"Descrição" 	, "_QRY1->B1_DESC"			})
		AADD(aCampos, {"Peso Final" , "_QRY1->ZPB_PESOL"		})
		AADD(aCampos, {"Recno"  	, "_QRY1->ZPBRECNO"			})

		_cQry := " SELECT ZPB_DATA " + CRLF
		_cQry += ",ZPB_DATAF " + CRLF
		_cQry += ",ZPB_PRODUT " + CRLF
		_cQry += ",B1_DESC " + CRLF
		_cQry += ",ZPB_PLACA " + CRLF
		_cQry += ",ZPB_NOTFIS " + CRLF
		_cQry += ",ZPB_CODFOR " + CRLF
		_cQry += ",ZPB_LOJFOR " + CRLF
		_cQry += ",ZPB_NOMFOR " + CRLF
		_cQry += ",ZPB_PESOL " + CRLF
		_cQry += ",A2_MUN " + CRLF
		_cQry += ",A2_EST " + CRLF
		_cQry += ",ZPB_CODMOT " + CRLF
		_cQry += ",ZPB_NOMMOT " + CRLF
		_cQry += ",ZPB_CODIGO " + CRLF
		_cQry += ",ZPB_HORA " + CRLF
		_cQry += ",ZPB_HORAF " + CRLF
		_cQry += ",ZPB_CLIFOR " + CRLF
		_cQry += ",ZPB.R_E_C_N_O_ AS ZPBRECNO " + CRLF
		_cQry += " FROM "+RetSqlName("ZPB")+" ZPB " + CRLF
		_cQry += " LEFT JOIN "+RetSqlName("SB1")+" B1 ON B1_COD = ZPB_PRODUT " + CRLF
		_cQry += " AND B1.D_E_L_E_T_ = '' " + CRLF
		_cQry += " LEFT JOIN "+RetSqlName("SA2")+" A2 ON A2_COD = ZPB_CODFOR " + CRLF
		_cQry += " AND A2_LOJA = ZPB_LOJFOR " + CRLF
		_cQry += " AND A2.D_E_L_E_T_ = '' " + CRLF
		_cQry += " WHERE ZPB_FILIAL = '"+FWxFilial("ZPB")+"'" + CRLF
		_cQry += " AND ZPB_PESOE > 0" + CRLF
		_cQry += " AND ZPB_PESOS > 0" + CRLF
		_cQry += " AND ZPB_FILIAL + ZPB_DATA + ZPB_DATAF + ZPB_CODIGO  NOT IN (SELECT ZVF_FILIAL + ZVF_ODATA + ZVF_SDATA  + ZVF_ZPBCOD FROM "+RetSqlName("ZVF")+" ZVF" + CRLF
		_cQry += " 															JOIN "+RetSqlName("ZPB")+" ZPB ON ZVF_FILIAL = ZPB_FILIAL" + CRLF
		_cQry += " 															AND ZPB_DATA  = ZVF_ODATA" + CRLF
		_cQry += " 															AND ZPB_DATAF = ZVF_SDATA" + CRLF
		_cQry += " 															AND ZPB_CODIGO = ZVF_ZPBCOD" + CRLF
		_cQry += " 															AND ZPB_PLACA = ZVF_PLACA" + CRLF
		_cQry += " 															AND ZPB.D_E_L_E_T_ = ''" + CRLF
		_cQry += " 															WHERE ZVF.D_E_L_E_T_ = '' )" + CRLF
		_cQry += " AND ZPB.D_E_L_E_T_ = ''" + CRLF

		aHeader := {{nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,NIL}}
		aCols := {{nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,NIL}}
		aFiltros := {"Placa","Fornecedor"/* ,"Data Saida","Data Chegada" */ /* ,"CPF/CNPJ" */}
		U_PPlaca(aHeader,aCols,aCampos,_cQry,cTipo,aFiltros,"Pesquisa - Pesagens")

	endif
	
	
RETURN lRet

//Validação do campo ZVF_FORN
User Function MNT03FN()
	Local oModel	:= FWModelActive()
	Local oCab 		:= oModel:GetModel("ZVFMASTER")
	Local lRet 		:= .T.
	
	if !EMPTY(oCab:GetValue("ZVF_COMBO"))
		IF oCab:GetValue("ZVF_COMBO") == 'F'
			lRet := ExistCpo("SA2",oCab:GetValue("ZVF_FORN"))
		else
			lRet := ExistCpo("SA1")
		endif
	else
		lRet := .F.
	endif
Return lRet
//Validação dos Campos T9_X_CC1 e T9_X_CC2 Na Tabela ST9
User Function MNT03CC()
	Local lRet	 := .T. 
	Local cPlaca := &(ReadVar())
	Local cCampo := SubStr(ReadVar(),4,len(ReadVar()))

	if ExistCpo("ST9", cPlaca, 19)
		if cCampo == 'T9_X_CC1'
			if cPlaca == FWFldGet("T9_PLACA") .or. cPlaca == FWFldGet("T9_X_CC2")
				lRet := .F.
			endif
		else 
			if cPlaca == FWFldGet("T9_PLACA") .or. cPlaca == FWFldGet("T9_X_CC1")
				lRet := .F.
			endif
		endif
	else
		lRet := .F.
	endif
Return lRet
//Validação do campo ZVF_COMBO
User Function MNT03CB()
	Local oModel	:= FWModelActive()
	Local oCab 		:= oModel:GetModel("ZVFMASTER")
	Local lRet 		:= .T.

	if !EMPTY(oCab:GetValue("ZVF_FORN"))
		oCab:SetValue("ZVF_FORN",Space(TamSx3("ZVF_FORN")[1]))
		oCab:SetValue("ZVF_LOJA",Space(TamSx3("ZVF_LOJA")[1]))
		oCab:SetValue("ZVF_NFOR",Space(TamSx3("ZVF_NFOR")[1]))
		oCab:SetValue("ZVF_END" ,Space(TamSx3("ZVF_END")[1]))
	endif 

Return lRet

Class MNT03EVENT From FWModelEvent
    Method New() CONSTRUCTOR
    Method BeforeTTS()
    Method InTTS()
    Method AfterTTS()
    Method After()
EndClass
/*/{Protheus.doc} New
Método para "instanciar" um observador
@author Atilio
@since 27/01/2023
@version version
@param oModel, Objeto, Objeto instanciado do Modelo de Dados
/*/
 
Method New(oModel) CLASS MNT03EVENT
Return

/*/{Protheus.doc} After
Método que é chamado pelo MVC quando ocorrer as ações do commit
depois da gravação de cada submodelo (field ou cada linha de uma grid)
@author Atilio
@since 27/01/2023
@version version
@param oModel, Objeto, Objeto instanciado do Modelo de Dados
/*/
 
Method After(oModel) Class MNT03EVENT
    Local aArea := GetArea()
    DBSELECTAREA( "ST9" )
    ST9->(DBSETORDER( 19 ))
    
	IF dTos(ZVF->ZVF_ODATA) != '' .AND. dTos(ZVF->ZVF_SDATA) != ''
		ZVF->ZVF_STATUS := "F"
	Endif

	if ZVF->ZVF_PLC1 != "" .OR. ZVF->ZVF_PLC2 != ""
		if ST9->(DbSeek(FwXFilial("ST9")+ALLTRIM( ZVF->ZVF_PLACA )))
			RECLOCK( "ST9", .F. )
				ST9->T9_X_CC1 := ZVF->ZVF_PLC1
				ST9->T9_X_CC2 := ZVF->ZVF_PLC2
			SB1->(MSUNLOCK())
		ENDIF
	ENDIF
    ST9->(DBCLOSEAREA(  ))

    RestArea(aArea)
Return

/*/{Protheus.doc} BeforeTTS
Método acionado antes de fazer as gravações da transação
@author Atilio
@since 27/01/2023
@version version
@param oModel, Objeto, Objeto instanciado do Modelo de Dados
/*/

Method BeforeTTS(oModel) Class MNT03EVENT
    //Aqui você pode fazer as operações antes de gravar
Return

/*/{Protheus.doc} InTTS
Método acionado durante as gravações da transação
@author Atilio
@since 27/01/2023
@version version
@param oModel, Objeto, Objeto instanciado do Modelo de Dados
/*/
 
Method InTTS(oModel) Class MNT03EVENT
Return
 
/*/{Protheus.doc} AfterTTS
Método acionado após as gravações da transação
@author Atilio
@since 27/01/2023
@version version
@param oModel, Objeto, Objeto instanciado do Modelo de Dados
/*/

Method AfterTTS(oModel) Class MNT03EVENT
    //Aqui você pode fazer as operações após gravar
Return

User Function PPlaca(aHead,aCol,aCampos,cQry,cTipo,aFiltros,cNome)
	Local lRet      := .T.
	local cBtnSel 	:= iif(cTipo=='1',iif("Clientes"$cNome,"Cliente","Fornecedor"),"Pesagem") 

	Private cQuery1 := ""
	Private cFiltro := ""
	Private cOrdem  := " ORDER BY 2 DESC"
	
	Private oPrinc
	Private aColsPri     := aHead
	Private aFields      := {} //Campos que aparecerão na grid principal

	Private oSecund
	Private	aColsSec := aCol
	Private aFields2 := {} //Campos que aparecerão na grid secundária
	
	Private oDlg

	Private cDiasBusca 	:= '10'
	Private cTxtBusca 	:= Space(30)
	Private cTxtAplic 	:= Space(30)
	Private cCmbInd  	:= "Nome"
  	lBusZPB := .T.

	cQuery1 := cQry
	
	aFields := aCampos
	
	DEFINE MSDIALOG oDlg TITLE cNome FROM 000, 000  TO 445, 950 COLORS 0, 16777215 PIXEL

	    @ 004, 005 MSCOMBOBOX oCmbInd VAR cCmbInd ITEMS aFiltros SIZE 050, 012 OF oDlg COLORS 0, 16777215 PIXEL
	    @ 004, 065 MSGET oTxtBusca VAR cTxtBusca 			SIZE 155, 010 OF oDlg COLORS 0,16777215 PIXEL //Valid(Filtro(3))
	    
	    @ 004, 228 BUTTON oBtnPesq PROMPT "Filtrar" 		SIZE 040, 012 OF oDlg PIXEL ACTION Processa({|| Filtro(1,cTipo,cNome) }, "Aguarde...") 
	    @ 004, 278 BUTTON oBtnLimp PROMPT "&Limpar (F4)"	SIZE 040, 012 OF oDlg PIXEL ACTION Limpar()
		SetKey( VK_F4, {|| Limpar()} )
    	@ 004, 328 BUTTON oBtnSelC PROMPT "Sel. "+cBtnSel	SIZE 040, 012 OF oDlg ACTION (SetRetor(1,cTipo,aFields), lRet := .T.) PIXEL
		if cTipo == '2'
	    	@ 004, 378 MSGET oTxtBusca VAR cDiasBusca 			SIZE 040, 010 OF oDlg COLORS 0,16777215 PIXEL //Valid(Filtro(3))
		endif 
    	//@ 004, 378 BUTTON oBtnIncl PROMPT "Inclui Novo"		SIZE 040, 012 OF oDlg ACTION Processa({|| IncluiFor() }) PIXEL
    	@ 004, 428 BUTTON oBtnSair PROMPT "Sair" 			SIZE 040, 012 OF oDlg ACTION (oDlg:End(), lRet := .F.) PIXEL    	

  		@ 020, 003 SCROLLBOX oScrollB1 HORIZONTAL VERTICAL SIZE 200, 468 OF oDlg BORDER
	    GridPrin(aFields,cTipo)                                                                     

	ACTIVATE MSDIALOG oDlg CENTERED
Return lRet

/* Montagem da grid principal */
Static Function GridPrin(aFields,cTipo)
	//Local aAux    := {}
	Local aCab    := {}
	Local nX      := 0
	Local nTam 	:= Len(aFields)
		
	for nX := 1 to nTam
		AADD(aCab, aFields[nX][GD_NOME])	
	next nX
        
    @ 002, 002 LISTBOX oPrinc Fields HEADER "INIT" SIZE 462, 194 OF oScrollB1 PIXEL ColSizes 50,50,150,100,50,20,60 ON DBLCLICK (SetRetor(NIL,cTipo,aFields), lRet := .T.)
    oPrinc:aHeaders := aCab

    oPrinc:SetArray(aColsPri)
	
	if cTipo == '1'
			oPrinc:bLine := {|| {;
			aColsPri[oPrinc:nAt,1],;
			aColsPri[oPrinc:nAt,2],;
			aColsPri[oPrinc:nAt,3],;
			aColsPri[oPrinc:nAt,4],;
			aColsPri[oPrinc:nAt,5],;
			aColsPri[oPrinc:nAt,6],;
			aColsPri[oPrinc:nAt,7];
		}}
	ELSE 
			oPrinc:bLine := {|| {;
			aColsPri[oPrinc:nAt,1],;
			aColsPri[oPrinc:nAt,2],;
			aColsPri[oPrinc:nAt,3],;
			aColsPri[oPrinc:nAt,4],;
			aColsPri[oPrinc:nAt,5],;
			aColsPri[oPrinc:nAt,6],;
			aColsPri[oPrinc:nAt,7],;
			aColsPri[oPrinc:nAt,8],;
			aColsPri[oPrinc:nAt,9],;
			aColsPri[oPrinc:nAt,10],;
			aColsPri[oPrinc:nAt,11],;
			aColsPri[oPrinc:nAt,12],;
			aColsPri[oPrinc:nAt,13],;
			aColsPri[oPrinc:nAt,14];
		}}
	ENDIF 
	oPrinc:Refresh()	    
	    
    // Evento do click
    // oPrinc:bChange := {|| SetRetor(1) }	
Return

Static Function SetRetor(cEntidade,cTipo,aFields)
	Local oView	    := FWViewActive()
	Local oModel    := FWModelActive()
	Local oCab      := oModel:GetModel('ZVFMASTER')
	Local cQry
	Local cCarreta, cItem

	IF cTipo == '2'
		If aColsPri[oPrinc:nAt][14] <> nil
			cEntidade := aColsPri[oPrinc:nAt][14]
			DbSelectArea("ZPB")
			DbSetOrder(1)

			ZPB->(DbGoto( cEntidade ))
			if ZPB->ZPB_PLACA != ''
				
				cQry := "select * from "+RetSqlName("ZVF")+" WHERE ZVF_STATUS = 'A' AND ZVF_PLC1 = '"+ALLTRIM(ZPB->ZPB_PLACA)+"' AND D_E_L_E_T_ = ''"
				MpSysOpenQuery(cQry,"TMP")

				IF !TMP->(EOF())
					_nRet := 0	
					MSGALERT("", 'Placa está com outro frete em aberto: ' + CRLF+;
									'' + CRLF +;
									'Placa: '+ALLTRIM(ZPB->ZPB_PLACA)+' ' + CRLF+;
									'Cod:   '+TMP->ZVF_COD+' ' + CRLF +;
									'' + CRLF +;
									'Termine o cadastro que está em aberto para cadastrar outro!')
					
				ELSE
					_nRet := ZPB->ZPB_PESOL
					oCab:LoadValue("ZVF_ODATA"   , ZPB->ZPB_DATA)
					oCab:LoadValue("ZVF_SDATA"   , ZPB->ZPB_DATAF)
					oCab:LoadValue("ZVF_HORAS"   , SubStr(ZPB->ZPB_HORA,1,5))
					oCab:LoadValue("ZVF_OHORA"   , SubStr(ZPB->ZPB_HORAF,1,5))
					oCab:LoadValue("ZVF_PROD"    , AllTrim(ZPB->ZPB_PRODUT))
					oCab:LoadValue("ZVF_DESC"    , Posicione("SB1",1,FWXFILIAL("SB1")+AllTrim(ZPB->ZPB_PRODUT),ALLTRIM("B1_DESC")))
					oCab:LoadValue("ZVF_ZPBCOD"  , ZPB->ZPB_CODIGO)
					oCab:LoadValue("ZVF_NF"      , AllTrim(ZPB->ZPB_NOTFIS))
					oCab:LoadValue("ZVF_COMBO"   , ZPB->ZPB_CLIFOR)
					oCab:LoadValue("ZVF_FORN"    , AllTrim(ZPB->ZPB_CODFOR))
					oCab:LoadValue("ZVF_LOJA"    , ZPB->ZPB_LOJFOR)
					oCab:LoadValue("ZVF_NFOR"    , ZPB->ZPB_NOMFOR)
					oCab:LoadValue("ZVF_CMUN"   , "41208")
					oCab:LoadValue("ZVF_EST"    , "SP")
					oCab:LoadValue("ZVF_MUN"    , "PRESIDENTE BERNARDES")
					
					cCarreta := AllTrim(Posicione("ST9",19,FWXFILIAL("ST9")+ALLTRIM(ZPB->ZPB_PLACA),'T9_X_CC1'))
					if cCarreta != ''
						cItem	 := AllTrim(Posicione("ST9",19,FWXFILIAL("ST9")+ALLTRIM(ZPB->ZPB_PLACA),'T9_ITEMCTA'))
						oCab:LoadValue("ZVF_PLC1" , cCarreta)
						oCab:LoadValue("ZVF_ITCC1", cItem)
					endif
					cCarreta := AllTrim(Posicione("ST9",19,FWXFILIAL("ST9")+ALLTRIM(ZPB->ZPB_PLACA),'T9_X_CC2'))
					if cCarreta != ''
						cItem	 := AllTrim(Posicione("ST9",19,FWXFILIAL("ST9")+cCarreta,'T9_ITEMCTA'))
						oCab:LoadValue("ZVF_PLC2"    , cCarreta)
						oCab:LoadValue("ZVF_ITCC2"   , cItem)
					endif

					IF oCab:GetValue("ZVF_COMBO") == 'F'
						oCab:LoadValue("ZVF_DMUN",Posicione("SA2" ,1,FWXfilial("SA2")+ZPB->ZPB_CODFOR+ZPB->ZPB_LOJFOR,"A2_COD_MUN"))
						oCab:LoadValue("ZVF_DEST",Posicione("SA2" ,1,FWXfilial("SA2")+ZPB->ZPB_CODFOR+ZPB->ZPB_LOJFOR,"A2_EST"))
						oCab:LoadValue("ZVF_DDMUN",ALLTRIM(Posicione("SA2",1,FWXfilial("SA2")+ZPB->ZPB_CODFOR+ZPB->ZPB_LOJFOR,"A2_MUN")))
					ELSE
						oCab:LoadValue("ZVF_DMUN" ,Posicione("SA1",1,FWXfilial("SA1")+ZPB->ZPB_CODFOR+ZPB->ZPB_LOJFOR,"A1_COD_MUN"))
						oCab:LoadValue("ZVF_DEST" ,Posicione("SA1",1,FWXfilial("SA1")+ZPB->ZPB_CODFOR+ZPB->ZPB_LOJFOR,"A1_EST"))
						oCab:LoadValue("ZVF_DDMUN",ALLTRIM(Posicione("SA1",1,FWXfilial("SA1")+ZPB->ZPB_CODFOR+ZPB->ZPB_LOJFOR,"A1_MUN")))
					ENDIF
					oCab:LoadValue("ZVF_PLACA"   , ZPB->ZPB_PLACA)
					oCab:LoadValue("ZVF_ICTA"    , AllTrim(Posicione("ST9",19,FWXFILIAL("ST9")+ALLTRIM(ZPB->ZPB_PLACA),'T9_ITEMCTA')))
					oCab:LoadValue("ZVF_MOT"     , ZPB->ZPB_CODMOT)
					oCab:LoadValue("ZVF_NMOT"    , ALLTRIM(ZPB->ZPB_NOMMOT))
				ENDIF
			ENDIF
			oDlg:End()
		Else
			cEntidade	:= ""
			Alert("Nao há registros filtrados para seleção!")
		Endif
	else
		If aColsPri[oPrinc:nAt][7] <> nil
			cEntidade := aColsPri[oPrinc:nAt][7]

			if 'A2' $ aFields[1][2]
				DbSelectArea("SA2")
				DbSetOrder(1)
				SA2->(DbGoto( cEntidade ))

				if SA2->A2_COD != ''
					_cRet := SA2->A2_COD
					oCab:LoadValue("ZVF_LOJA"    , SA2->A2_LOJA)
					oCab:LoadValue("ZVF_NFOR"    , SA2->A2_NOME)
				endif
			else
				DbSelectArea("SA1")
				DbSetOrder(1)
				SA1->(DbGoto( cEntidade ))

				if SA1->A1_COD != ''
					_cRet := SA1->A1_COD
					oCab:LoadValue("ZVF_LOJA"    , SA1->A1_LOJA)
					oCab:LoadValue("ZVF_NFOR"    , SA1->A1_NOME)
				endif
				
			endif 

			oDlg:End()
		Else
			cEntidade	:= ""
			Alert("Nao há registros filtrados para seleção!")
		Endif
	Endif
	oView:Refresh()
Return .t.

Static Function Filtro(nOPFil,cTipo,cNome)
	Local nPos 		:= 1
	Local cTxtLike 	:= Upper(AllTrim(cTxtBusca))
	Local aTxtLike	:= {}
	Local i         := 0
	Local nX        := 0
	If " "$cTxtLike              
		aTxtLike := FilWord(cTxtLike)
	Endif

	if cTipo == '1'
		If !Empty(cTxtBusca)
			if "Fornecedor" $ cNome 
				If cCmbInd == "Código"
					cFiltro := " AND UPPER(A2_COD) LIKE '%" + Upper(AllTrim(cTxtBusca)) + "%' "
				ElseIf cCmbInd == "Fornecedor"
					If len(aTxtLike)>=1
						for i:=1 to len(aTxtLike)
							if !(Upper(AllTrim(aTxtLike[i]))$cFiltro)
								cFiltro := " AND UPPER(A2_NOME) LIKE '%" + Upper(AllTrim(aTxtLike[i])) + "%'  "
							endif
						next i
					Else
						If !(Upper(AllTrim(cTxtLike))$cFiltro)
							cFiltro := " AND UPPER(A2_NOME) LIKE '%" + Upper(AllTrim(cTxtLike)) + "%'  "
						Endif	
					Endif
				Endif
			else
				If cCmbInd == "Código"
					cFiltro := " AND UPPER(A1_COD) LIKE '%" + Upper(AllTrim(cTxtBusca)) + "%' "
				ElseIf cCmbInd == "Fornecedor"
					If len(aTxtLike)>=1
						for i:=1 to len(aTxtLike)
							if !(Upper(AllTrim(aTxtLike[i]))$cFiltro)
								cFiltro := " AND UPPER(A1_NOME) LIKE '%" + Upper(AllTrim(aTxtLike[i])) + "%' "
							endif
						next i
					Else
						If !(Upper(AllTrim(cTxtLike))$cFiltro)
							cFiltro := " AND UPPER(A1_NOME) LIKE '%" + Upper(AllTrim(cTxtLike)) + "%' "
						Endif	
					Endif
				Endif
			Endif
		else 
			cFiltro += " "
		endif
	ELSE 
		If !Empty(cTxtBusca)
			If cCmbInd == "Placa"
				cFiltro := " AND UPPER(ZPB_PLACA) LIKE '%" + Upper(AllTrim(cTxtBusca)) + "%' AND ZPB_DATA >= DATEADD (DAY , -"+cDiasBusca+" , '"+dToS(dDataBase)+"') "
				cOrdem := " ORDER BY ZPB_DATAF DESC"
			ElseIf cCmbInd == "Fornecedor"
				If len(aTxtLike)>=1
					for i:=1 to len(aTxtLike)
						if !(Upper(AllTrim(aTxtLike[i]))$cFiltro)
							cFiltro := " AND UPPER(ZPB_NOMFOR) LIKE '%" + Upper(AllTrim(aTxtLike[i])) + "%' AND ZPB_DATA >= DATEADD (DAY , -"+cDiasBusca+" , '"+dToS(dDataBase)+"') "
						endif
					next i
				Else
					If !(Upper(AllTrim(cTxtLike))$cFiltro)
						cFiltro := " AND UPPER(ZPB_NOMFOR) LIKE '%" + Upper(AllTrim(cTxtLike)) + "%' AND ZPB_DATA >= DATEADD (DAY , -"+cDiasBusca+" , '"+dToS(dDataBase)+"') "
					Endif	
				Endif
				cOrdem := " ORDER BY ZPB_DATAF DESC"
			Endif
		else 
			cFiltro := "AND ZPB_DATA >= DATEADD (DAY , -"+cDiasBusca+" , '"+dToS(dDataBase)+"')"
			cOrdem  := " ORDER BY ZPB_DATAF DESC"
		endif
	ENDIF

	If select("_QRY1") > 0
		_QRY1->(DbCloseArea())
	endif
	
	if cUserName == 'ioliveira'
    	MemoWrite(StrTran(cArquivo,".xml","")+"_MNT03ZPB_.sql" , cQuery1 + cFiltro + cOrdem)
	endif

	TcQuery cQuery1 + cFiltro + cOrdem NEW Alias "_QRY1"
	//MEMOWRITE( character, character )
	Count to nCont
	_QRY1->(DbGoTop())
	ProcRegua(nCont)
	
	if cTipo == '1'
		aColsPri := {{nil,nil,nil,nil,nil,nil,nil}}
	else 
		aColsPri := {{nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,NIL}}
	endif 

	If nOPFil = 2
		cFiltro := ''
	Else
		DbSelectArea("_QRY1")
		_QRY1->(DbGoTop())
		Do While !_QRY1->(Eof())
			IncProc("Carregando registros...")
			aAux := {}
			for nX := 1 to Len(aFields)
				AADD(aAux, &(aFields[nX][GD_CONTEUDO]) )
			next nX
			Aadd(aColsPri, aAux)	
			
			if aColsPri[1][1] == nil
				ADEL(aColsPri, 1)
				ASIZE(aColsPri, len(aColsPri) - 1)		
			endif
			
			_QRY1->(DbSkip())			
		Enddo		
	Endif
	
	if len(aColsPri) == 0
	   	MsgInfo("Registro não encontrado!")

		if cTipo == '1'
			aColsSec := {{nil,nil,nil,nil,nil,nil,nil}}
		else 
			aColsSec := {{nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,NIL}}
		endif 
	    oSecund:SetArray(aColsSec)
	    	  
	   	aAux := {}
		for nX := 1 to Len(aFields2)
	    	AADD(aAux, cValToChar(nX))
		next nX
		Aadd(aColsSec,aAux)	
		
		oPrinc:SetArray(aColsPri)
		oPrinc:Refresh()
	else
		oPrinc:SetArray(aColsPri)
	    	if cTipo == '1'
					oPrinc:bLine := {|| {;
					aColsPri[oPrinc:nAt,1],;
					aColsPri[oPrinc:nAt,2],;
					aColsPri[oPrinc:nAt,3],;
					aColsPri[oPrinc:nAt,4],;
					aColsPri[oPrinc:nAt,5],;
					aColsPri[oPrinc:nAt,6],;
					aColsPri[oPrinc:nAt,7];
				}}
			ELSE 
					oPrinc:bLine := {|| {;
					aColsPri[oPrinc:nAt,1],;
					aColsPri[oPrinc:nAt,2],;
					aColsPri[oPrinc:nAt,3],;
					aColsPri[oPrinc:nAt,4],;
					aColsPri[oPrinc:nAt,5],;
					aColsPri[oPrinc:nAt,6],;
					aColsPri[oPrinc:nAt,7],;
					aColsPri[oPrinc:nAt,8],;
					aColsPri[oPrinc:nAt,9],;
					aColsPri[oPrinc:nAt,10],;
					aColsPri[oPrinc:nAt,11],;
					aColsPri[oPrinc:nAt,12],;
					aColsPri[oPrinc:nAt,13],;
					aColsPri[oPrinc:nAt,14];
				}}
			ENDIF 
		oPrinc:Refresh()
		oPrinc:GoTop()
		oPrinc:SetFocus()
	endif		
	If nOPFil = 3
 		Return .t.
	Endif
Return
	
Static Function Limpar()
		cTxtBusca := SPACE(30)
		Processa({|| Filtro(2) }, "Aguarde...") 
		oTxtBusca:SetFocus()		
Return

Static Function FilWord(cWord)
Local cTxtPesq	:= Alltrim(cWord)
Local cTxtAux 	:= ""
Local i         := 0
Local aRetTxt	:= {}
	For i:=1 to len(cTxtPesq)
		If !(Substr(cTxtPesq,i,1) == " ")
			cTxtAux := cTxtAux+Substr(cTxtPesq,i,1)
		Else  
			if !Empty(cTxtAux) 
				Aadd(aRetTxt,cTxtAux)
			Endif
			cTxtAux:= ""
		Endif  
	next i
	If !Empty(cTxtAux)
		Aadd(aRetTxt,cTxtAux)
		cTxtAux:= ""
	Endif
              
Return aRetTxt

Static Function IncluiFor() 
Local aArea	:= GetArea()
	AxInclui('SA2', 0, 3)
RestArea(aArea)
Return
