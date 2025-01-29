#Include 'Protheus.ch'
#include 'totvs.ch'
#Include "FWMVCDEF.CH"

Static cTitulo := "Limpeza de bebedouros" 

User Function VALBIG01()
	Local aArea     	:= GetArea()
	Local oBrowse
	Private aRotina		:= MenuDef()
	Private cPath 	 	:= "C:\totvs_relatorios\"
	Private cArquivo   	:= cPath+; 
							DtoS(dDataBase)+; 
							"_"+; 
							StrTran(SubS(Time(),1,5),":","")+;
							".xml"
	Private aCbLn 		:= {}
	Private _IG01FU  	:= CriaVar('ZIB_FUNC', .F.)
	private cTrbBrowse	:= CriaTrab(,.F.)
	Private aBlocos 	:= {}
	Private cCodigo 	:= ''
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("ZIB")
	oBrowse:SetDescription(cTitulo)
	oBrowse:Activate()
	
	RestArea(aArea)
RETURN NIL

Static Function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE 'Visualizar' 		ACTION 'VIEWDEF.VALBIG01' 			OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Incluir'    		ACTION 'VIEWDEF.VALBIG01' 			OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRotina TITLE 'Alterar'    		ACTION 'VIEWDEF.VALBIG01' 			OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 3
	ADD OPTION aRotina TITLE 'Excluir'    		ACTION 'VIEWDEF.VALBIG01' 			OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
Return aRotina

Static Function ModelDef()
	Local oModel 	:= Nil
	Local oStrCabec	:= FWFormStruct(1, "Cabec")
	Local oStrCur	:= FWFormStruct(1, "Curral")
	Local oStrGrid	:= FWFormStruct(1, "ZIB")
	Local bVldCom  	:= {|| u_zSZIBMD()}
	local bLoadZIB  := {|oModelGrid, nLine, cAction, cField|  LoadZIB(oModelGrid, nLine, cAction, cField) }
	Local bLoadCur 	:= {|oModelGrid, nLine, cAction, cField|  LoadCur(oModelGrid, nLine, cAction, cField) }
	Local bLoadMT	:= {|oModel, lCopia| LoadMT(oModel, lCopia) }

	aCbLn 	:= GetCbLn()
	
	oStrCabec:AddField('', '', 'CBC_LINHA', 'C', 20,0,FwBuildFeature( STRUCT_FEATURE_VALID,"U_BIG01PG()"),,aCbLn,.F.,FwBuildFeature( STRUCT_FEATURE_INIPAD, "' '" ),.F.,.F.,.T.)

	oStrCur:AddField("Velho"	, "Velho"	, "C_VELHO"	, "L", 1, 0,FwBuildFeature( STRUCT_FEATURE_VALID,"U_BIG01B()"),, Nil, .F., Nil, .F., .F., .T.)
	oStrCur:AddField("Novo" 	, "Novo" 	, "C_NOVO"	, "L", 1, 0,FwBuildFeature( STRUCT_FEATURE_VALID,"U_BIG01B()"),, Nil, .F., Nil, .F., .F., .T.)
	oStrCur:AddField("Recepção"	, "Recepção", "C_RECP"	, "L", 1, 0,FwBuildFeature( STRUCT_FEATURE_VALID,"U_BIG01B()"),, Nil, .F., Nil, .F., .F., .T.)

	oModel := MPFormModel():New("LBIG01",/*Pre-Validacao*/, /* {|| zVldModel(oModel) } */ /*Pos-Validacao*/,bVldCom,/*Cancel*/)
	
	oModel:AddFields('CUR_SEL', 			, oStrCur,,,bLoadCur)

	oModel:AddFields('ZIBMASTER','CUR_SEL'	, oStrCabec,,,bLoadMT)
	oModel:AddGrid('ZIBFILHO'	,'ZIBMASTER', oStrGrid,/* < bLinePre > */,/* < bLinePost > */,/* < bPre > */, /* < bPost > */, bLoadZIB) // PORRA DE VIRGULA DO CARALHO 

	oModel:SetPrimaryKey({})
	
	SetKEY( VK_F10, {|oModelGrid,  cAction, cField| ClearCur(oModelGrid, cAction, cField)})

	oModel:GetModel("ZIBFILHO"):SetUniqueLine({"ZIB_CURRAL","ZIB_DATA"})
	
	//Setando outras informações do Modelo de Dados
	oModel:SetDescription(cTitulo)
	oModel:GetModel('ZIBMASTER'):SetDescription(cTitulo)
	oModel:GetModel('ZIBFILHO'):SetDescription(cTitulo)
	oModel:GetModel('CUR_SEL'):SetDescription(cTitulo)

Return oModel
Static Function ViewDef()
    Local oView     := FWFormView():New()
    Local oModel    := FWLoadModel('VALBIG01')
	Local oStrCabec	:= FWFormStruct(2, "Cabec")
	Local oStrCur	:= FWFormStruct(2, "Curral")
    Local oStrGrid 	:= FWFormStruct(2,'ZIB')
	
	oStrCabec:AddField('CBC_LINHA', '01','', '',{},'C',,,,.T.,,,aCbLn,1,,.T.,,,)
	
	oStrCur:AddField('C_VELHO', '01'	 ,'Velho'	, 'Velho'	,{}, 'C',,,,.T.,,,,1,,.T.,,,)
	oStrCur:AddField('C_NOVO' , '02'	 ,'Novo'	, 'Novo'	,{}, 'C',,,,.T.,,,,1,,.T.,,,)
	oStrCur:AddField('C_RECP' , '03'	 ,'Recepção', 'Recepção',{}, 'C',,,,.T.,,,,1,,.T.,,,)

	oView:SetModel(oModel)	

    //ADICIONANDO OS CAMPOS DO CABEÇALHO
	oView:AddField("VIEW_CAB" , oStrCabec  , "ZIBMASTER")
	oView:AddGrid( "VIEW_GRID", oStrGrid   , "ZIBFILHO")
	oView:AddField("VIEW_CUR" , oStrCur    , "CUR_SEL")
    
    //Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('BOX_01', 15)
	oView:CreateHorizontalBox('BOX_02', 15)
	oView:CreateHorizontalBox('BOX_03', 70)
	
	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_CUR' ,'BOX_01')
	oView:SetOwnerView('VIEW_CAB' ,'BOX_02')
	oView:SetOwnerView('VIEW_GRID' ,'BOX_03')

	oView:EnableTitleView('VIEW_CUR' ,'Blocos')
	oView:EnableTitleView('VIEW_CAB' ,'Linha')
	oView:EnableTitleView('VIEW_GRID','Currais')
	
	oView:AddUserButton( 'Alterar Funcionários' , 'Funcionário'		, {|| LBIGAF()} )
	
	oView:SetCloseOnOk( { |oView| .T. } )

	oStrGrid:RemoveField('ZIB_FILIAL')
Return oView

User Function BIGCCOD()
	Local cRet 
	Local cQry 
	Local cAlias 	:= GetNextAlias()

	cQry := "select MAX(ZIB_COD)+1 COD FROM  "+ RetSqlName("ZIB") +" "
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQry), cAlias, .F., .T. )
	
	cRet := STRZERO((cAlias)->COD,6)
	
	(cAlias)->(DbCloseArea())
Return cRet

//Validacao blocos
User Function BIG01B()
	Local oModel	:= FWModelActive()
	Local oView 	:= FWViewActive()
	Local nOpc		:= oModel:GetOperation()
	Local oStr 		:= oModel:GetModel("CUR_SEL")
	Local xVar 		:= SubStr( ReadVar(),  At( "M->", ReadVar() ) + 3 )
	Local lRet 		:= .T. 
	
	if nOpc != 4
		if &(ReadVar()) == .T.
			if oStr:GetValue("C_VELHO") == .T. .and. xVar != "C_VELHO"
				oStr:SetValue("C_VELHO", .F.)
			endif 
			if oStr:GetValue("C_NOVO") == .T. .and. xVar != "C_NOVO"
				oStr:SetValue("C_NOVO", .F.)
			endif 
			if oStr:GetValue("C_RECP") == .T. .and. xVar != "C_RECP"
				oStr:SetValue("C_RECP", .F.)
				//oLinha:SetValue("CBC_LINHA", aRetR)
			endif 
		endif
		oView:Refresh()
	else 
		MsgAlert("Não permitido alteração do Curral nessa operação!!!", "Atenção...")
		lRet := .F.
	ENDIF

Return lRet
//Validação do campo linha
User Function BIG01PG()
	Local aArea 	:= GetArea()
	Local oModel	:= FWModelActive()
	Local nOpc		:= oModel:GetOperation()
	Local oStrLn 	:= oModel:GetModel("ZIBMASTER")
	Local oStrBl 	:= oModel:GetModel("CUR_SEL")
	Local oGrid  	:= oModel:GetModel("ZIBFILHO")
	Local cBloco  	:= ''	
	Local lRet 		:= .T.
	Local cQry 		:= ""
	Local cAlias 	:= GetNextAlias()
	Local aFunc
	Local nLine 	:= oGrid:GoLine(oGrid:GetQtdLine())
	Local nI		
	
	cCodigo := IIF(cCodigo=='',U_BIGCCOD(),cCodigo)
	
	aFunc := StrTokArr(AllTrim(GetMV("MV_BIG01FN")),";")	
	//MV_BIG01FN
	if nOpc == 3 
		if oGrid:IsEmpty()
			aBloco := {}
		endif

		if oStrBl:GetValue("C_VELHO") == .T.
			cBloco := '01'
		endif 
		if oStrBl:GetValue("C_NOVO") == .T. 
			cBloco := '02'
		endif 
		if oStrBl:GetValue("C_RECP") == .T.
			cBloco := '99'
		endif

		
		for nI := 1 to len(aBlocos)
			if cBloco == aBlocos[nI][1] .and. AllTrim(UPPER(oStrLn:GetValue("CBC_LINHA"))) == aBlocos[nI][2]
				Help(NIL, NIL, "Help", NIL, "Linha já adicionada", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Adicione outra linha"})
    			RETURN .F.
				//MsgAlert("Linha já adicionada!", "Atenção...")
			endif
		next nI
		
		if cBloco != ''

			cQry := " SELECT " + CRLF 
			cQry += " Z08_CODIGO" + CRLF 
			cQry += " FROM "+RetSqlName("Z08")+"" + CRLF 
			cQry += " WHERE Z08_FILIAL = '"+FWxFilial("Z08")+"'" + CRLF 
			cQry += " and Z08_CONFNA = '"+cBloco+"'" + CRLF
			cQry += " and Z08_MSBLQL != '1'" + CRLF
			cQry += " and LTRIM(Z08_LINHA) = '"+AllTrim(UPPER(oStrLn:GetValue("CBC_LINHA")))+"'" + CRLF 

			//If lower(cUserName) $ 'ioliveira,admin,Administrador'
				MemoWrite(StrTran(cArquivo,".xml","")+"_LancamentoDespacho_.sql" , cQry)
			//EndIf

			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQry), cAlias, .F., .T. )

			if (cAlias)->(EOF())
				Help( ,, 'HELP',, 'Linha não encontrada!!!', 1, 0)    
				lRet := .T.
			else
				aAdd(aBlocos,{cBloco,AllTrim(UPPER(oStrLn:GetValue("CBC_LINHA")))})
				
				oGrid:GoLine(nLine)
				while !(cAlias)->(EOF())
					
					oGrid:AddLine()
					oGrid:SetValue("ZIB_COD"	, cCodigo)		
					oGrid:SetValue("ZIB_CONFNA"	, cBloco)		
					oGrid:SetValue("ZIB_CURRAL"	, (cAlias)->Z08_CODIGO)		
					oGrid:SetValue("ZIB_DATA"	, dDataBase)		
					oGrid:LoadValue("ZIB_FUNC"	, AllTrim(aFunc[1]))		
					oGrid:LoadValue("ZIB_NOME"	, AllTrim(POSICIONE("SRA",1,FWxFilial("SRA")+aFunc[1],"RA_NOME")))		
					if Len(aFunc) > 1
						oGrid:LoadValue("ZIB_FUNC2"	, AllTrim(aFunc[2]))		
						oGrid:LoadValue("ZIB_NOME2"	, AllTrim(POSICIONE("SRA",1,FWxFilial("SRA")+aFunc[2],"RA_NOME")))		
					endif 
					(cAlias)->(DBSkip())
				end
				oGrid:GoLine(nLine)
			endif
		endif
	else
		MsgAlert("Não permitido alteração do Curral nessa operação!!!", "Atenção...")
		lRet := .F.
	endif 
	RestArea(aArea)
Return lRet

Static Function ClearCur(oModelGrid, cAction, cField)
	Local oModel	:= FWModelActive()
	Local oView		:= FWViewActive()
	Local oGrid  	:= oModel:GetModel("ZIBFILHO")
	Local cBloco  	:= UPPER(SubStr(AllTrim(oGrid:GetValue("ZIB_CURRAL")),1,1))
	Local nLine 	:= oGrid:GetLine()
	Local nI 		:= 1
	
	if oGrid:GetLine() > 1
		oGrid:GoLine(nLine - nI)
	endif 

	while SubStr(AllTrim(oGrid:GetValue("ZIB_CURRAL")),1,1) == cBloco .and. oGrid:GetLine() > 1 
		oGrid:GoLine(nLine - ++nI)
	end

	nLine 	:= oGrid:GetLine()
	if oGrid:GetLine() < oGrid:GetQtdLine()
		oGrid:GoLine(nLine + 1)
	endif

	while SubStr(AllTrim(oGrid:GetValue("ZIB_CURRAL")),1,1) == cBloco .and. oGrid:GetLine() < oGrid:GetQtdLine()

		/* if !oGrid:IsDeleted()
			oGrid:DeleteLine()
		else 
			oGrid:UnDeleteLine()
		endif */
		 
		oGrid:GoLine(++nLine)

		//if oGrid:GetLine() <= oGrid:GetQtdLine()
		if SubStr(AllTrim(oGrid:GetValue("ZIB_CURRAL")),1,1) == cBloco
			if !oGrid:IsDeleted()
				oGrid:DeleteLine()
			else 
				oGrid:UnDeleteLine()
			endif 
		//	exit
		endif 
	end

	oView:Refresh()
Return

Static Function GetCbLn()
	Local aArea     := GetArea()
	Local cQry 		:= ''
	Local cAlias 	:= GetNextAlias()
	Local aRet 		:= {}

	cQry := " SELECT DISTINCT Z08_LINHA, " + CRLF 
	cQry += " 	CASE Z08_CONFNA " + CRLF 
	cQry += " 		WHEN '01'  THEN 'VELHO' " + CRLF 
	cQry += " 		WHEN '02'  THEN 'NOVO' " + CRLF 
	cQry += " 		WHEN '99' THEN 'RECEPÇÃO' " + CRLF 
	cQry += " 	END TIPO" + CRLF 
	cQry += " FROM "+RetSqlName("Z08")+"  " + CRLF 
	cQry += " WHERE Z08_FILIAL = '"+FWxFilial("Z08")+"'  " + CRLF 
	cQry += " AND Z08_LINHA != ''  " + CRLF 
	cQry += " and D_E_L_E_T_ = ''  " + CRLF 
	cQry += " ORDER BY 2 asc " + CRLF

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQry), cAlias, .F., .T. )
	
	while !(cAlias)->(EOF())
		aAdd(aRet,AllTrim((cAlias)->Z08_LINHA))
		(cAlias)->(DBSkip())
	enddo

	RestArea(aArea)
Return aRet
/* Alterar Parametro Funcionario */
User Function LBIG01F()
    Local aArea		:= GetArea()
	Local oModel	:= FWModelActive()
	Local oView 	:= FWViewActive()
	Local oStr 		:= oModel:GetModel("ZIBFILHO")
    Local _cQry  	:= ""
    Local lRet 		:= .F.
	Local cCampo 	:= Substr(ReadVar(),4,10)
	Local cNome

	if RIGHT(AllTrim(cCampo),1) == '2'
		cNome := "ZIB_NOME2"
	else 
		cNome := "ZIB_NOME"
	endif 

	if Type("uRetorno") == 'U'
		public uRetorno
	endif

	uRetorno := ''

	_cQry := " SELECT RA_MAT " + CRLF
	_cQry += "			, RA_NOME " + CRLF
	_cQry += "		    , R_E_C_N_O_ SRARECNO " + CRLF
	_cQry += "	FROM " + RetSqlName("SRA")+ " " + CRLF
	_cQry += "	WHERE RA_FILIAL = '"+FWxFilial("SRA")+"'" + CRLF
	_cQry += "	AND RA_DEPTO = '000000003'  " + CRLF
	_cQry += "	AND RA_DEMISSA = ''  " + CRLF
	_cQry += "	AND D_E_L_E_T_ = '' " + CRLF
	_cQry += "	ORDER BY 1" + CRLF

    if u_F3Qry( _cQry, 'MATRICULA', 'SRARECNO', @uRetorno,, { "RA_MAT", "RA_NOME" } )
		SRA->(DbGoto( uRetorno ))
		_IG01FU := SRA->RA_MAT
		lRet := .t. 
    endif

	IF lower(cUserName) $ 'ioliveira,bernardo,mbernardo,atoshio,admin,administrador'
	    MemoWrite(StrTran(cArquivo,".xml","")+"SRA_"+cValToChar(dDataBase)+".sql" , _cQry)
    ENDIF

	if aArea[1] <> "SRA"
		RestArea( aArea )
	endif
	
	oStr:GoLine(1)

	oView:Refresh()

RETURN lRet

User Function zSZIBMD()
	Local aArea      	:= GetArea()
	Local lRet       	:= .T.
	Local oModel	  	:= FWModelActive()
	Local oGridM 		:= oModel:GetModel('ZIBFILHO')
	Local nOpc       	:= oModel:GetOperation()
	Local nI         	:= 0
	Local lRecLock   	:= .T.
	Local nLinhas	 	:= oGridM:GetQtdLine()

	DbSelectArea('ZIB')
	ZIB->(DbSetOrder(1))

	//Se for InclusÃ£o
	If nOpc == MODEL_OPERATION_INSERT .OR. nOpc == MODEL_OPERATION_UPDATE
		//Cria o registro na tabela 00 (CabeÃ§alho de tabelas)
		if !oGridM:IsEmpty()
		
            For nI := 1 To nLinhas
                oGridM:GoLine(nI)
                If !oGridM:isDeleted()
                    RecLock('ZIB', lRecLock := !DbSeek( FWxFilial("ZIB") +;
												oGridM:GetValue('ZIB_COD')+;
                                                oGridM:GetValue('ZIB_CONFNA')+;
                                                PadR(AllTrim(oGridM:GetValue('ZIB_CURRAL')),TamSx3("ZIB_CURRAL")[1]) +;
                                                dTos(oGridM:GetValue('ZIB_DATA'))))
 
                        ZIB->ZIB_FILIAL    	:= FWxFilial("ZIB")
                        ZIB->ZIB_COD    	:= oGridM:GetValue('ZIB_COD') 
                        ZIB->ZIB_CONFNA   	:= oGridM:GetValue('ZIB_CONFNA')  
                        ZIB->ZIB_DATA   	:= oGridM:GetValue('ZIB_DATA')  
                        ZIB->ZIB_CURRAL   	:= oGridM:GetValue('ZIB_CURRAL')
						if AllTrim(oGridM:GetValue('ZIB_FUNC')) != ""
                        	ZIB->ZIB_FUNC   	:= oGridM:GetValue('ZIB_FUNC')
						endif 
						if AllTrim(oGridM:GetValue('ZIB_FUNC2')) != ""
                        	ZIB->ZIB_FUNC2   	:= oGridM:GetValue('ZIB_FUNC2') 
						endif
                    ZIB->(MsUnlock())
                Else		
                    If ZIB->(DbSeek( FWxFilial("ZIB") +;
							oGridM:GetValue('ZIB_COD')+;
							oGridM:GetValue('ZIB_CONFNA')+;
							PadR(AllTrim(oGridM:GetValue('ZIB_CURRAL')),TamSx3("ZIB_CURRAL")[1])+;
							dTos(oGridM:GetValue('ZIB_DATA'))))

                        RecLock('ZIB', .F.)
                            ZIB->(DbDelete())
                        ZIB->(MsUnlock())
                    EndIf 
                EndIf
            Next nI
		else 
			lRet := .F. 
			oModel:SetErrorMessage("","","","","HELP", 'Grid Vazia', "")
		ENDIF 
	//Se for ExclusÃ£o
	ElseIf nOpc == MODEL_OPERATION_DELETE	
	ZIB->(DbSetOrder(2))
		For nI := 1 To oGridM:GetQtdLine()
			oGridM:GoLine(nI)
			If ZIB->(DbSeek( FWxFilial("ZIB") +;
					oGridM:GetValue('ZIB_COD')+;
					oGridM:GetValue('ZIB_CONFNA')+;
					PadR(AllTrim(oGridM:GetValue('ZIB_CURRAL')),TamSx3("ZIB_CURRAL")[1])+;
					dToS(oGridM:GetValue('ZIB_DATA'))))

				RecLock('ZIB', .F.)
					ZIB->(DbDelete())
				ZIB->(MsUnlock())
			EndIf
		Next nI
	EndIf
	//Se nÃ£o for inclusÃ£o, volta o INCLUI para .T. (bug ao utilizar a ExclusÃ£o, antes da InclusÃ£o)
	If nOpc != MODEL_OPERATION_INSERT
		INCLUI := .T.
	EndIf
	cCodigo := ''
	RestArea(aArea)
Return lRet

Static Function LoadZIB(oModelGrid, nLine, cAction, cField)
	local aArea    	:= GetArea()
	Local cQry		:= ''
	Local cAlias 	:= GetNextAlias()
	Private aGrid 	:= {}

	DbSelectArea("ZIB")
	DbSetOrder(1) // ZIB_FILIAL + ZIB_CURRAL + ZIB_DATA

	if Type("cTrbBrowse") <> "U" .and. Select(cTrbBrowse) > 0
    	//ZIB->(DbSeek(FWxFilial("ZIB")+(cTrbBrowse)->ZIB_CURRAL+DToS((cTrbBrowse)->ZIB_DATA)))
    	ZIB->(DbSeek(FWxFilial("ZIB")+(cTrbBrowse)->ZIB_COD))
	endif

	cQry := "select ZIB_COD, ZIB_CONFNA,ZIB_CURRAL, ZIB_DATA, ZIB_FUNC,ZIB_FUNC2, ZIB.R_E_C_N_O_ RECNO" + CRLF 
	cQry += " from "+ RetSqlName("ZIB") +" ZIB " + CRLF 
	//cQry += " JOIN "+ RetSqlName("Z08") +" Z08 on ZIB.ZIB_FILIAL = Z08.Z08_FILIAL  " + CRLF 
	//cQry += " AND ZIB.ZIB_CURRAL = Z08.Z08_CODIGO " + CRLF 
	//cQry += " AND Z08.D_E_L_E_T_ = '' " + CRLF 
	cQry += " WHERE ZIB.ZIB_FILIAL = '"+FWxFilial("ZIB")+"' " + CRLF 
	cQry += " AND ZIB.ZIB_COD = '"+ZIB->ZIB_COD+"' " + CRLF 
	//cQry += " AND RTRIM(SUBSTRING(ZIB.ZIB_CURRAL,1,1)) = '"+SubStr(ZIB->ZIB_CURRAL,1,1)+"' " + CRLF 
	//cQry += " AND ZIB.ZIB_DATA = '"+dToS(ZIB->ZIB_DATA)+"'  " + CRLF 
	cQry += " AND ZIB.D_E_L_E_T_ = ''  " + CRLF

	MemoWrite(StrTran(cArquivo,".xml","")+"LoadZIB.sql" , cQry)

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQry), cAlias, .F., .T. )

	while !(cAlias)->(EOF())

		aAdd(aGrid, { 	(cAlias)->RECNO,;
						{	FWxFilial("ZIB"),;
							AllTrim((cAlias)->ZIB_COD),;
							AllTrim((cAlias)->ZIB_CONFNA),;
							AllTrim((cAlias)->ZIB_CURRAL),;
							sToD((cAlias)->ZIB_DATA),;
							Iif( AllTrim((cAlias)->ZIB_FUNC) != "",(cAlias)->ZIB_FUNC,""  ),;
							Iif( AllTrim((cAlias)->ZIB_FUNC) != "",AllTrim(POSICIONE("SRA",1,FWxFilial("SRA")+(cAlias)->ZIB_FUNC,"RA_NOME")),""  ) ,;
							Iif( AllTrim((cAlias)->ZIB_FUNC2) != "",(cAlias)->ZIB_FUNC2,""  ),;
							Iif( AllTrim((cAlias)->ZIB_FUNC) != "",AllTrim(POSICIONE("SRA",1,FWxFilial("SRA")+(cAlias)->ZIB_FUNC2,"RA_NOME")),""  ) }})
		(cAlias)->(DbSkip())
	enddo

	if !Empty(aArea)
	    RestArea(aArea)
	endif

Return aGrid 

Static Function LoadCur(oModelGrid, nLine, cAction, cField)
	local aArea    	:= GetArea()
	local aRet     	:= {}
	Local cQry		:= ''
	Local cAlias 	:= GetNextAlias()
	Local lVelho 	:= lNovo := lRecp := .F.

	DbSelectArea("ZIB")
	DbSetOrder(1) // ZIB_FILIAL + ZIB_CURRAL + ZIB_DATA
   	
	if Type("cTrbBrowse") <> "U" .and. Select(cTrbBrowse) > 0
    	ZIB->(DbSeek(FWxFilial("ZIB")+(cTrbBrowse)->ZIB_CONFNA+(cTrbBrowse)->ZIB_CURRAL+DToS((cTrbBrowse)->ZIB_DATA)))
	endif

	cQry := "select Z08_CONFNA, ZIB_CURRAL, ZIB_DATA, ZIB_FUNC " + CRLF 
	cQry += " from "+ RetSqlName("ZIB") +" ZIB " + CRLF 
	cQry += " JOIN "+ RetSqlName("Z08") +" Z08 on ZIB.ZIB_FILIAL = Z08.Z08_FILIAL  " + CRLF 
	cQry += " AND ZIB.ZIB_CURRAL = Z08.Z08_CODIGO " + CRLF 
	cQry += " AND Z08.D_E_L_E_T_ = '' " + CRLF 
	cQry += " WHERE ZIB.ZIB_FILIAL = '"+FWxFilial("Z08")+"' " + CRLF 
	cQry += " AND ZIB.ZIB_CURRAL = '"+ZIB->ZIB_CURRAL+"' " + CRLF
	cQry += " AND ZIB.ZIB_DATA = '"+dToS(ZIB->ZIB_DATA)+"'  " + CRLF
	cQry += " AND ZIB.D_E_L_E_T_ = ''  " + CRLF

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQry), cAlias, .F., .T. )

	if !(cAlias)->(EOF())
		if (cALias) -> Z08_CONFNA == '01'
			lVelho := .T. 
		elseif (cALias) -> Z08_CONFNA == '02'
			lNovo := .T. 
		elseif (cALias) -> Z08_CONFNA == '99'
			lRecp := .T. 
		endif 
	endif 

	aAdd(aRet, {lVelho,lNovo,lRecp}) //dados
	aAdd(aRet, 1)
	RestArea(aArea)

Return aRet 

Static Function LoadMT(oGrid, lCopia) 
	Local aRet		:= {} 
	local aArea    	:= GetArea()
	Local cQry		:= ''
	Local cAlias 	:= GetNextAlias()

	DbSelectArea("ZIB")
	DbSetOrder(1) // ZIB_FILIAL + ZIB_CURRAL + ZIB_DATA
   	
	if Type("cTrbBrowse") <> "U" .and. Select(cTrbBrowse) > 0
    	ZIB->(DbSeek(FWxFilial("ZIB")+(cTrbBrowse)->ZIB_CONFNA+(cTrbBrowse)->ZIB_CURRAL+DToS((cTrbBrowse)->ZIB_DATA)))
	endif

	cQry := "select Z08_CONFNA, ZIB_CURRAL, ZIB_DATA, ZIB_FUNC " + CRLF 
	cQry += " from "+ RetSqlName("ZIB") +" ZIB " + CRLF 
	cQry += " JOIN "+ RetSqlName("Z08") +" Z08 on ZIB.ZIB_FILIAL = Z08.Z08_FILIAL  " + CRLF 


	cQry += " AND ZIB.ZIB_CURRAL = Z08.Z08_CODIGO " + CRLF 
	cQry += " AND Z08.D_E_L_E_T_ = '' " + CRLF 
	cQry += " WHERE ZIB.ZIB_FILIAL = '"+FWxFilial("Z08")+"' " + CRLF 
	cQry += " AND ZIB.ZIB_CURRAL = '"+ZIB->ZIB_CURRAL+"' " + CRLF 
	cQry += " AND ZIB.ZIB_DATA = '"+dToS(ZIB->ZIB_DATA)+"'  " + CRLF 
	cQry += " AND ZIB.D_E_L_E_T_ = ''  " + CRLF

	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQry), cAlias, .F., .T. )

	if !(cAlias)->(EOF())
		aAdd(aRet, SubStr(ZIB->ZIB_CURRAL,1,1)) 
	endif

	RestArea(aArea)
Return aRet

Static Function LBIGAF()
	Local aParamBox   	:= {}
	Local aRet			:= {}
	Local cLoad     	:= ProcName(1)	// Nome do perfil se caso for carregar
	Local lCanSave  	:= .T. 			// Salvar os dados informados nos parâmetros por perfil
	Local lUserSave 	:= .T. 			// Configuração por usuário

	aAdd(aParamBox, {1, "Funcionário 1:", Space(TamSX3('RA_MAT')[1]),"","","ZIB_FU","",0,.F. })
	aAdd(aParamBox, {1, "Funcionário 2:", Space(TamSX3('RA_MAT')[1]),"","","ZIB_FU","",0,.F. })
	
	If ParamBox(aParamBox,"Parâmetros...",@aRet, /* [ bOk ] */, /* [ aButtons ] */, /* [ lCentered ] */, /* [ nPosX ] */, /* [ nPosy ] */, /* [ oDlgWizard ] */,  cLoad, lCanSave, lUserSave )
		PUTMV("MV_BIG01FN",aRet[1]+";"+aRet[2]+"")
	EndIf
Return

User Function IG01CUR()
	Local lRet 		:= .T. 
	Local oModel	:= FWModelActive()
	Local nOpc      := oModel:GetOperation()
	
	if nOpc == 4
		//else
		MsgAlert("Não permitido alteração do Curral nessa operação!!!", "Atenção...")
		lRet := .F.
	endif 
Return lRet
