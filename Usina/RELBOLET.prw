#INCLUDE "Protheus.ch"

/*�������������������������������������������������������������������������������
���Programa  �  RELBOLET  � Autor �  Rodrigo Franco   � Data �   18/02/2025   ���
�����������������������������������������������������������������������������͹��
���Descricao � Gera Excel do Boletim                                          ��� 
�������������������������������������������������������������������������������*/
User Function RELBOLET()

	Local oDlg
	Private _cData1 :=  CtoD("  /  /  ")
	Private oData1

	DEFINE MSDIALOG oDlg TITLE "Gera Boletim em Excel" FROM C(178),C(181) TO C(292),C(361) PIXEL
	@ C(002),C(003) TO C(043),C(090) LABEL "" PIXEL OF oDlg
	@ C(010),C(040) Say "Data:" Size C(149),C(008) COLOR CLR_BLACK PIXEL OF oDlg
	@ C(020),C(028) MsGet oData1 Var _cData1 Size C(040),C(009) COLOR CLR_BLACK PIXEL OF oDlg
	@ C(046),C(008) BUTTON "OK"  SIZE 45 ,10 ACTION (OkLeTxt(oDlg)) OF oDlg PIXEL
	@ C(046),C(048) BUTTON "Sair"  SIZE 45 ,10 ACTION (oDlg:End()) OF oDlg PIXEL
	ACTIVATE MSDIALOG oDlg CENTERED

Return


/*�������������������������������������������������������������������������������
���Fun��o    �  OkLeTxt    � Autor �  Rodrigo Franco   � Data �  18/02/2025   ���
�����������������������������������������������������������������������������͹��
���Descri��o � Funcao chamada pelo botao OK na tela inicial de processamen    ���
���          � to. Executa a leitura do arquivo texto.                        ���
�������������������������������������������������������������������������������*/
Static Function OkLeTxt(oDlg)

	oDlg:End()
	Processa({|| COMPSALD() },"Gerando Boletim...")
	dbSelectArea("TRA")
	DBCLOSEAREA()

	MsgAlert("Processo Finalizado salvo em C:\EXCTOT\" ,"Aviso")

Return


/*�����������������������������������������������������������������������������
���Fun��o    �  COMPSALD  � Autor �  Rodrigo Franco   � Data �  18/02/2025  ���
���������������������������������������������������������������������������͹��
���Descri��o � Rotina Boletim                                               ���
�����������������������������������������������������������������������������*/
Static Function COMPSALD()
	//Local cArq	 	:= ""

	cQuery1 := "SELECT * FROM ZH1010 WHERE ZH1_DATA = '" + DTOS(_cData1) + "' AND D_E_L_E_T_ <> '*' "
	cQuery1 += "ORDER BY ZH1_ORDEM"
	cQuery1 := ChangeQuery(cQuery1)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery1),"TRA",.T.,.T.)

	aLog1 := {}
	aAdd(aLog1,{"Processo","Unidade","Dia","Semana","Mes","Acumulado"})

	_cPros	:= ""
	_cUnid	:= ""
	_nDia	:= 0
	_nSema  := 0
	_nMes   := 0
	_nAcum  := 0

	dbSelectArea("TRA")
	dbGoTop()
	While !EOF()
		_cPros	:= TRA->ZH1_PROCES
		_cUnid	:= TRA->ZH1_UNIDAD
		_nDia	:= TRA->ZH1_DIA
		_nSema  := TRA->ZH1_SEMANA
		_nMes   := TRA->ZH1_MES
		_nAcum  := TRA->ZH1_ACUMUL
		aAdd(aLog1, {_cPros,_cUnid,_nDia,_nSema,_nMes,_nAcum } )
		dbSelectArea("TRA")
		DBSKIP()
	END

	_cHORA := substr(TIME(),1,2) + substr(TIME(),4,2)
	If Len(aLog1) >=2 // Desconto o Cabec da Array
		MontaExcel(aLog1,"C:\EXCTOT\","BOLETIM_"+SUBSTR(DtoS(DDataBase),7,2)+SUBSTR(DtoS(DDataBase),5,2)+SUBSTR(DtoS(DDataBase),1,4)+"_"+_cHORA)
		//MontaExcel(aLog1,"C:\EXCTOT\","CSGrupo01")
	Endif

Return

/*����������������������������������������������������������������������������������
���Funcao     �  MontaExcel   � Autor �  Rodrigo Franco   � Data �  18/02/2025   ���
��������������������������������������������������������������������������������Ĵ��
���Descri��o  � Monta e Abre uma planilha do Excel baseada em uma Array          ���
���           � A Planilha eh montada sobre um arquivo CSV que eh um TXT         ���
���           � formatado separado pelo carater ";"                              ���
��������������������������������������������������������������������������������Ĵ��
���Parametros � aDados := Array que sera exportada para o Excel                  ���
���           � cPath  := Diretorio onde sera salvo o arquivo Temporario         ���
���           � cNome  := Nome Arquivo LOG a ser Gerado                          ���
����������������������������������������������������������������������������������*/
Static Function MontaExcel(aDados,cPath,cNome)
	Local cArquivo  	:= AllTrim(cNome)+".csv"
	Local nHandle   	:= fCreate(AllTrim(cPath)+cArquivo) // Cria Arquivo
	Local nX			:= 0
	Local nY			:= 0
	Local nLenaDados	:= Len(aDados)
	Local nLenaDadIt	:= Len(aDados[1])
	Local cType			:= ""

	// Varre Array
	For nX := 1 to nLenaDados
		// Verifica Tamanho de cada Linha
		nLenaDadIt := Len(aDados[nX])
		For nY := 1 to nLenaDadIt
			// Verifica se Celula da Array nao esta NIL
			If aDados[nX,nY] <> Nil
				// Define Tipo da Celula
				cType := ValType(aDados[nX,nY])
				If cType == "N"
					fWrite(nHandle, Transform(aDados[nX,nY],"@E 999,999,999,999.99") + ";" )
				ElseIf cType == "C"
					fWrite(nHandle, Transform(aDados[nX,nY],"") + ";" )
				ElseIf cType == "L"
					fWrite(nHandle	, Iif(aDados[nX,nY],".T.",".F.") + ";" )
				ElseIf cType == "D"
					fWrite(nHandle, DtoC(aDados[nX,nY]) + ";" )
				Endif
			Else
				// Se for NIL alimenta apenas o pulo de Celula
				fWrite(nHandle, ";" ) // Pula linha
			Endif
		Next nY
		// Alimenta Pulo de Linha
		fWrite(nHandle, CRLF ) // Pula linha
	Next nX
	// Salva Arquivo
	fClose(nHandle)
	// Abre Planilha
	oExcelApp := MsExcel():New()
	oExcelApp:WorkBooks:Open(AllTrim(cPath)+cArquivo)
	oExcelApp:SetVisible(.T.)
Return Nil


/*���������������������������������������������������������������������������
���Programa   �  C()   � Autor �  Rodrigo Franco   � Data �  18/02/2025   ���
�������������������������������������������������������������������������Ĵ��
���Descricao  � Funcao responsavel por manter o Layout independente da    ���
���           � resolucao horizontal do Monitor do Usuario.               ���
���������������������������������������������������������������������������*/
Static Function C(nTam)
	Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
		nTam *= 0.8
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
		nTam *= 1
	Else	// Resolucao 1024x768 e acima
		nTam *= 1.28
	EndIf

	//�Tratamento para tema "Flat"�
	If "MP8" $ oApp:cVersion
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
			nTam *= 0.90
		EndIf
	EndIf
Return Int(nTam)
