#INCLUDE "RWMAKE.CH" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"

/*---------------------------------------------------------------------------------,
 | Func:  			                                                               |
 | Autor:  Miguel Martins Bernardo Junior                                          |
 | Data:   14.06.2021                                                              |
 | Desc:   Relatorio de Lotação de Baias e Pastos.                                 |
 |                                                                                 |
 | Obs.:  -                                                                        |
 '--------------------------------------------------------------------------------*/
User Function VAEST015() // U_VAEST015()
Private cTitulo     := "Movimentação - Plantel do Gado em Geral"
Private cPerg       := "VAEST015"
Private lAtual      := .T.
Private cPath       := "C:\TOTVS_RELATORIOS\"
Private cArquivo    := cPath + cPerg +; // __cUserID+"_"+;
								DtoS(dDataBase)+;
								"_"+;
								StrTran(SubS(Time(),1,5),":","")+;
								".xml"
Private nRegistros  := 0
Private cAliaQTD    := GetNextAlias() // CriaTrab(,.F.)
Private aAuxQtd     := {}
Private cAliaBRAN   := GetNextAlias() // CriaTrab(,.F.)   

Private cXMLTitulo  := ""
Private cXML2Titulo := ""

	  cXML2Titulo := U_prtCellXML( 'Row',,'33' )
/*01*/cXML2Titulo += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s96', 'String', /*cFormula*/, 'Filial'		    ,,.T. )
/*02*/cXML2Titulo += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s96', 'String', /*cFormula*/, 'Bezerro Mamando',,.T. )
/*03*/cXML2Titulo += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s96', 'String', /*cFormula*/, 'Bezerro Desmama',,.T. )
/*04*/cXML2Titulo += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s96', 'String', /*cFormula*/, 'Garrote' 		,,.T. )
/*05*/cXML2Titulo += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s96', 'String', /*cFormula*/, 'Boi'			,,.T. )
/*06*/cXML2Titulo += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s96', 'String', /*cFormula*/, 'Touro'			,,.T. )
/*07*/cXML2Titulo += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s96', 'String', /*cFormula*/, 'Bezerra Mamando',,.T. )
/*08*/cXML2Titulo += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s96', 'String', /*cFormula*/, 'Bezerra Desmama',,.T. )
/*09*/cXML2Titulo += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s96', 'String', /*cFormula*/, 'Novilha'  		,,.T. )
/*10*/cXML2Titulo += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s96', 'String', /*cFormula*/, 'Vaca'			,,.T. )
/*11*/cXML2Titulo += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s96', 'String', /*cFormula*/, 'TOTAL'          ,,.T. )
/*12*/cXML2Titulo += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s96', 'String', /*cFormula*/, 'Macho'			,,.T. )
/*13*/cXML2Titulo += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s96', 'String', /*cFormula*/, 'Capão'			,,.T. )
/*14*/cXML2Titulo += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s96', 'String', /*cFormula*/, 'Femea'			,,.T. )
	  cXML2Titulo += U_prtCellXML( '</Row>' )

	GeraX1(cPerg)
	U_PosSX1({{cPerg, "01", DTOS(dDataBase-1)}})

	If !Pergunte(cPerg, .T.)
		Return Nil
	EndIf
	U_PrintSX1(cPerg)

	cTitulo += " - Dt. Referência: " + DtoC(MV_PAR01) + " às " + SubS(Time(),1,5)
	cXMLTitulo  := U_prtCellXML( 'Titulo' /* cTag */, /* cName */, '38' /* cHeight */, /* cIndex */, '16' /* cMergeAcross */, 's62' /* cStyleID */, 'String' /* cType */, /* cFormula */, cTitulo/* cInfo */, /* cPanes */)
	lAtual  := MV_PAR01 == dDataBase
 
	If MsgYesNo( 'Deseja abrir a versão nova (com formulas) ????', 'Atenção!' )
		U_bEST015()
	Else
		U_aEST015()
	EndIf
	(cAliaQTD)->(DbCloseArea())
	(cAliaBRAN)->(DbCloseArea())

Return nil


/*---------------------------------------------------------------------------------,
 | Func:  			                                                               |
 | Autor:  Miguel Martins Bernardo Junior                                          |
 | Data:   14.06.2021                                                              |
 | Desc:   Relatorio de Lotação de Baias e Pastos.                                 |
 |                                                                                 |
 | Obs.:  -                                                                        |
 '--------------------------------------------------------------------------------*/
User Function bEST015() // U_VAEST015()

Local cTimeIni    := Time()
Local cStyle      := ""
Local cXML        := ""
Local lTemDados   := .T.

Private oExcelApp := nil
Private nTTLin    := 0

Private nHandle   := 0
Private nHandAux  := 0

If Len( Directory(cPath + "*.*","D") ) == 0
	If Makedir(cPath) == 0
		ConOut('Diretorio Criado com Sucesso.')
		MsgAlert('Diretorio Criado com Sucesso: ' + cPath, 'Aviso')
	Else	
		ConOut( "Não foi possivel criar o diretório. Erro: " + cValToChar( FError() ) )
		MsgAlert( "Não foi possivel criar o diretório. Erro: " + cValToChar( FError() ), 'Aviso' )
	EndIf
EndIf

nHandle := FCreate(cArquivo)
if nHandle = -1
	conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
else
	
	cStyle := U_defStyle()
	cStyle += ' <Style ss:ID="s73">'+CRLF+;
              ' <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>'+CRLF+;
              ' <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF+;
              ' ss:Color="#FFFFFF"/>'+CRLF+;
              ' <NumberFormat'+CRLF+;
              ' ss:Format="_-&quot;R$&quot;\ * #,##0.00_-;\-&quot;R$&quot;\ * #,##0.00_-;_-&quot;R$&quot;\ * &quot;-&quot;??_-;_-@_-"/>'+CRLF+;
              ' </Style>'+CRLF+;
              ' <Style ss:ID="s200">'+CRLF+;
              ' <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>'+CRLF+;
              ' <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF+;
              ' ss:Color="#000000"/>'+CRLF+;
              ' <NumberFormat'+CRLF+;
              ' ss:Format="_-&quot;R$&quot;\ * #,##0.00_-;\-&quot;R$&quot;\ * #,##0.00_-;_-&quot;R$&quot;\ * &quot;-&quot;??_-;_-@_-"/>'+CRLF+;
              ' </Style>'+CRLF+;
              ' <Style ss:ID="s202" ss:Name="Moeda 2">'+CRLF+;
              ' <NumberFormat'+CRLF+;
              ' ss:Format="_-&quot;R$&quot;\ * #,##0.00_-;\-&quot;R$&quot;\ * #,##0.00_-;_-&quot;R$&quot;\ * &quot;-&quot;??_-;_-@_-"/>'+CRLF+;
              ' </Style>'+CRLF+;
              ' <Style ss:ID="s201" ss:Parent="s202">'+CRLF+;
              ' <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>'+CRLF+;
              ' <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Bold="1"/>'+CRLF+;
              ' <Interior ss:Color="#A6A6A6" ss:Pattern="Solid"/>'+CRLF+;
              ' </Style>'+CRLF+;
              ' <Style ss:ID="s83" ss:Parent="s202">'+CRLF+;
              ' <Alignment ss:Horizontal="Center" ss:Vertical="Bottom" ss:WrapText="1"/>'+CRLF+;
              ' <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF+;
              ' ss:Color="#000000"/>'+CRLF+;
              ' <Interior ss:Color="#FFFF00" ss:Pattern="Solid"/>'+CRLF+;
              ' </Style>'+CRLF+;
              ' <Style ss:ID="s203" ss:Parent="s16">'+CRLF+;
              ' <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF+;
              ' ss:Color="#000000"/>'+CRLF+;
              ' <Interior ss:Color="#FFFF00" ss:Pattern="Solid"/>'+CRLF+;
              ' <NumberFormat ss:Format="_-* #,##0_-;\-* #,##0_-;_-* &quot;-&quot;??_-;_-@_-"/>'+CRLF+;
              ' </Style>'+CRLF+;
              ' <Style ss:ID="s204">'+CRLF+;
              ' <Alignment ss:Horizontal="Left" ss:Vertical="Bottom" ss:WrapText="1"/>'+CRLF+;
              ' <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF+;
              ' ss:Color="#000000"/>'+CRLF+;
              ' <Interior ss:Color="#FFFF00" ss:Pattern="Solid"/>'+CRLF+;
              ' </Style>'+CRLF+;
              ' <Style ss:ID="s89">'+CRLF+;
              ' <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>'+CRLF+;
              ' <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF+;
              ' ss:Color="#000000"/>'+CRLF+;
              ' <Interior ss:Color="#FFFF00" ss:Pattern="Solid"/>'+CRLF+;
              ' <NumberFormat'+CRLF+;
              ' ss:Format="_-&quot;R$&quot;\ * #,##0.00_-;\-&quot;R$&quot;\ * #,##0.00_-;_-&quot;R$&quot;\ * &quot;-&quot;??_-;_-@_-"/>'+CRLF+;
              ' </Style>'+CRLF+;
              ' <Style ss:ID="s205">'+CRLF+;
              ' <Alignment ss:Horizontal="Left" ss:Vertical="Bottom" ss:WrapText="1"/>'+CRLF+;
              ' <Borders>'+CRLF+;
              ' <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>'+CRLF+;
              ' <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF+;
              ' </Borders>'+CRLF+;
              ' <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF+;
              ' ss:Color="#000000" ss:Bold="1"/>'+CRLF+;
              ' </Style>'+CRLF+;
              ' <Style ss:ID="s103">'+CRLF+;
              ' <Borders>'+CRLF+;
              ' <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>'+CRLF+;
              ' <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF+;
              ' </Borders>'+CRLF+;
              ' <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF+;
              ' ss:Color="#000000" ss:Bold="1"/>'+CRLF+;
              ' <NumberFormat ss:Format="_-* #,##0_-;\-* #,##0_-;_-* &quot;-&quot;??_-;_-@_-"/>'+CRLF+;
              ' </Style>'+CRLF+;
              ' <Style ss:ID="s96">'+CRLF+;
              ' <Alignment ss:Horizontal="Center" ss:Vertical="Bottom" ss:WrapText="1"/>'+CRLF+;
              ' <Borders>'+CRLF+;
              ' <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>'+CRLF+;
              ' <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"'+CRLF+;
              ' ss:Color="#37752F"/>'+CRLF+;
              ' <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"'+CRLF+;
              ' ss:Color="#37752F"/>'+CRLF+;
              ' </Borders>'+CRLF+;
              ' <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="11"'+CRLF+;
              ' ss:Color="#FFFFFF" ss:Bold="1"/>'+CRLF+;
              ' <Interior ss:Color="#37752F" ss:Pattern="Solid"/>'+CRLF+;
              ' </Style>'+CRLF+;
              ' <Style ss:ID="s102">'+CRLF+;
              ' <Borders>'+CRLF+;
              ' <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="2"/>'+CRLF+;
              ' <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>'+CRLF+;
              ' </Borders>'+CRLF+;
              ' <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Size="14"'+CRLF+;
              ' ss:Color="#000000" ss:Bold="1"/>'+CRLF+;
              ' <NumberFormat ss:Format="_-* #,##0_-;\-* #,##0_-;_-* &quot;-&quot;??_-;_-@_-"/>'+CRLF+;
              ' </Style>'+CRLF+;
              ' <Style ss:ID="s95" ss:Parent="s202">'+CRLF+;
              ' <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>'+CRLF+;
              ' <Font ss:FontName="Arial Narrow" x:Family="Swiss" ss:Bold="1"/>'+CRLF+;
              ' <Interior/>'+CRLF+;
              ' </Style>'+CRLF

	// Processar SQL
	FWMsgRun(, {|| lTemDados := fQuadro1()/* fLoadSql("Geral", @_cAliasG ) */ },;
					'Por Favor Aguarde...',; 
					'Processando Banco de Dados - Recebimento')
	If lTemDados
	
		cXML := U_CabXMLExcel(cStyle)
		If !Empty(cXML)
			FWrite(nHandle, EncodeUTF8( cXML ) )
			cXML := ""
		EndIf
		
		// Gerar primeira planilha
		FWMsgRun(, {|| xmlfQdr1() },'Gerando excel, Por Favor Aguarde...', 'Geração do quadro todas as Filiais')
		
		FWMsgRun(, {|| lTemDados := fQuadro5()/* fLoadSql("Geral", @_cAliasG ) */ },;
					'Por Favor Aguarde...',; 
					'Processando Banco de Dados - Recebimento')
		FWMsgRun(, {|| xmlfQdr5() },'Gerando excel, Por Favor Aguarde...', 'Geração da Filial Sr. Branco')
		
		FWMsgRun(, {|| xmlfQdrR() },'Gerando excel, Por Favor Aguarde...', 'Geração dos resumos')

		// Final - encerramento do arquivo
		FWrite(nHandle, EncodeUTF8( '</Workbook>' ) )
		
		FClose(nHandle)

		If ApOleClient("MSExcel")
			oExcelApp := MsExcel():New()
			oExcelApp:WorkBooks:Open( cArquivo )
			oExcelApp:SetVisible(.T.) 	
			oExcelApp:Destroy()	
			// ou >  ShellExecute( "Open", cNameFile , '', '', 1 ) //Abre o arquivo na tela após salvar 
		Else
			MsgAlert("O Excel não foi encontrado. Arquivo " + cArquivo + " gerado em " + cPath + ".", "MsExcel não encontrado" )
		EndIf
	Else
		MsgAlert("Os parametros informados não retornou nenhuma informação do banco de dados." + CRLF + ;
					"Por isso o excel não sera aberto automaticamente.", "Dados não localizados")
	EndIf
	
	If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin, administrador'
		Alert('Tempo de processamento: ' + ElapTime( cTimeINI, Time() ) )
	EndIf
	ConOut('Activate: ' + Time())
EndIf

Return nil
// FIM : bEST015()


/*---------------------------------------------------------------------------------,
 | Func:  			                                                               |
 | Autor:  Miguel Martins Bernardo Junior                                          |
 | Data:   14.06.2021                                                              |
 | Desc:   Relatorio de Lotação de Baias e Pastos.                                 |
 |                                                                                 |
 | Obs.:  -                                                                        |
 '--------------------------------------------------------------------------------*/
Static Function xmlfQdr1()

Local cXML       := ""
Local cWorkSheet := ""
Local nI         := 0
Local cFilOK	   := cFilAnt

If !(cAliaQTD)->(Eof())

	cWorkSheet := "Movimentacao"
	
	cXML += U_prtCellXML( 'Worksheet', cWorkSheet )

	cXML += ' <Names>'+CRLF
	cXML += ' <NamedRange ss:Name="_FilterDatabase" '+CRLF
	cXML += ' 	ss:RefersTo="='+cWorkSheet+'!R2C1:R'+cValToChar(nRegistros+1)+'C14"'+CRLF
	cXML += ' 	ss:Hidden="1"/>'+CRLF
	cXML += ' </Names>'+CRLF

	cXML += U_prtCellXML( 'Table' )

    cXML += '<Column ss:Width="173"/>'+CRLF+;
			'<Column ss:AutoFitWidth="0" ss:Width="85" ss:Span="12"/>'
	cXML += cXMLTitulo // U_prtCellXML( 'Titulo'/* cTag */, /* cName */, '38'/* cHeight */, /* cIndex */, '16'/* cMergeAcross */, 's62'/* cStyleID */, 'String'/* cType */, /* cFormula */, cTitulo/* cInfo */, /* cPanes */)

	// Titulo
	cXML += cXML2Titulo
	  
	If lAtual // fQuadro1
		While !(cAliaQTD)->(Eof())
			if  (cAliaQTD)->BEZERROMAMANDO > 0 .or. ;
				(cAliaQTD)->BEZERRODESMAMA > 0 .or. ;
				(cAliaQTD)->GARROTE > 0 .or. ;
				(cAliaQTD)->BOI > 0 .or. ;
				(cAliaQTD)->TOURO > 0 .or. ;
				(cAliaQTD)->BEZERRAMAMANDO > 0 .or. ;
				(cAliaQTD)->BEZERRADESMAMA > 0 .or. ;
				(cAliaQTD)->NOVILHA > 0 .or. ;
				(cAliaQTD)->VACA > 0

				nTTLin+=1
				  cXML += U_prtCellXML( 'Row' )
			/*01*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto'  , 'String',  /*cFormula*/, U_FrmtVlrExcel( (cAliaQTD)->FILIAL         ),,.T. )
			/*02*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( (cAliaQTD)->BEZERROMAMANDO ),,.T. )
			/*03*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( (cAliaQTD)->BEZERRODESMAMA ),,.T. )
			/*04*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( (cAliaQTD)->GARROTE        ),,.T. )
			/*05*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( (cAliaQTD)->BOI            ),,.T. )
			/*06*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( (cAliaQTD)->TOURO          ),,.T. )
			/*07*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( (cAliaQTD)->BEZERRAMAMANDO ),,.T. )
			/*08*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( (cAliaQTD)->BEZERRADESMAMA ),,.T. )
			/*09*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( (cAliaQTD)->NOVILHA        ),,.T. )
			/*10*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( (cAliaQTD)->VACA           ),,.T. )
			/*11*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDigN', 'String', "=SUM(RC[-9]:RC[-1])" /*cFormula*/,,,.T. )
			/*12*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( (cAliaQTD)->MACHO          ),,.T. )
			/*13*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( (cAliaQTD)->CAPAO          ),,.T. )
			/*14*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( (cAliaQTD)->FEMEA          ),,.T. )
				  cXML += U_prtCellXML( '</Row>' )
			EndIf
			(cAliaQTD)->(DbSkip())
			
			If !Empty(cXML)
				FWrite(nHandle, EncodeUTF8( cXML ) )
			EndIf
			cXML := ""
		EndDo
	Else

		aAdd( aAuxQtd , {"FILIAL", "BEZERRO MAMANDO","BEZERRO DESMAMA","GARROTE","BOI","TOURO","BEZERRA MAMANDO","BEZERRA DESMAMA","NOVILHA","VACA","TOTAL","MACHO","CAPAO","FEMEA"} )

		DbSelectArea('SB2')
		SB2->(DbSetOrder(1))
		While !(cAliaQTD)->(Eof())  
			
			If xFilial('SB2') <> (cAliaQTD)->B2_FILIAL			
				SB2->(DbSetOrder(1))
				SB2->(DbSeek( (cAliaQTD)->B2_FILIAL + (cAliaQTD)->B1_COD + (cAliaQTD)->B2_LOCAL ))
				cFilAnt := (cAliaQTD)->B2_FILIAL
			EndIf
			
			If GetNewPar("MV_RASTRO", "N", (cAliaQTD)->B2_FILIAL ) == "S" .AND. (cAliaQTD)->B1_RASTRO == 'L' 
				nQuant := (aAuxPrd := CalcEstL( (cAliaQTD)->B1_COD, (cAliaQTD)->B2_LOCAL, MV_PAR01+1, (cAliaQTD)->B8_LOTECTL))[1]
			Else
				nQuant := (aAuxPrd := CalcEst( (cAliaQTD)->B1_COD, (cAliaQTD)->B2_LOCAL, MV_PAR01+1 ))[1]
			EndIf
			If nQuant <> 0 

				If (nPosCol := aScan( aAuxQtd[1] , { |x| Upper(x) == AllTrim(Upper((cAliaQTD)->B1_X_ERA)) } )) > 0
					
					cFilFind := (cAliaQTD)->B2_FILIAL + ": " + (cAliaQTD)->NNR_DESCRI					
					If (nPosLin := aScan( aAuxQtd , { |x| x[1] == cFilFind } )) == 0
						aAdd( aAuxQtd, aClone(Array(14)) )
						nPosLin := Len(aAuxQtd)
						aAuxQtd[ nPosLin, 01 ] := cFilFind
						aAuxQtd[ nPosLin, 02 ] := 0
						aAuxQtd[ nPosLin, 03 ] := 0
						aAuxQtd[ nPosLin, 04 ] := 0
						aAuxQtd[ nPosLin, 05 ] := 0
						aAuxQtd[ nPosLin, 06 ] := 0
						aAuxQtd[ nPosLin, 07 ] := 0
						aAuxQtd[ nPosLin, 08 ] := 0
						aAuxQtd[ nPosLin, 09 ] := 0
						aAuxQtd[ nPosLin, 10 ] := 0
						aAuxQtd[ nPosLin, 11 ] := 0
						aAuxQtd[ nPosLin, 12 ] := 0
						aAuxQtd[ nPosLin, 13 ] := 0
						aAuxQtd[ nPosLin, 14 ] := 0
					EndIf     
					
					aAuxQtd[ nPosLin, nPosCol ] += aAuxPrd[1]
					// aAuxCst[       1, nPosCol ] += aAuxPrd[2]
				EndIf     
				
				If (nPosCol := aScan( aAuxQtd[1] , { |x| Upper(x) == AllTrim(Upper((cAliaQTD)->B1_X_SEXO)) } )) > 0
					aAuxQtd[ nPosLin, nPosCol ] += aAuxPrd[1]
					// aAuxCst[       1, nPosCol ] += aAuxPrd[2]
				EndIf
				
			EndIf
		
			(cAliaQTD)->(DbSkip())	
		EndDo
		cFilAnt := cFilOk
		
		For nI := 2 to Len(aAuxQtd)
			nTTLin+=1
			cXML += U_prtCellXML( 'Row' )
	  /*01*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto'  , 'String',  /*cFormula*/, U_FrmtVlrExcel( aAuxQtd[ nI, 01 ] ),,.T. )
	  /*02*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( aAuxQtd[ nI, 02 ] ),,.T. )
	  /*03*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( aAuxQtd[ nI, 03 ] ),,.T. )
	  /*04*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( aAuxQtd[ nI, 04 ] ),,.T. )
	  /*05*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( aAuxQtd[ nI, 05 ] ),,.T. )
	  /*06*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( aAuxQtd[ nI, 06 ] ),,.T. )
	  /*07*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( aAuxQtd[ nI, 07 ] ),,.T. )
	  /*08*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( aAuxQtd[ nI, 08 ] ),,.T. )
	  /*09*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( aAuxQtd[ nI, 09 ] ),,.T. )
	  /*10*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( aAuxQtd[ nI, 10 ] ),,.T. )
	  /*11*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDigN', 'String', "=SUM(RC[-9]:RC[-1])" /*cFormula*/,,,.T. )
	  /*12*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( aAuxQtd[ nI, 12 ] ),,.T. )
	  /*13*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( aAuxQtd[ nI, 13 ] ),,.T. )
	  /*14*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( aAuxQtd[ nI, 14 ] ),,.T. )
			cXML += U_prtCellXML( '</Row>' )
		Next nI
	EndIf

	cXML += U_prtCellXML( 'Row',,'26' )
	/*01*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s205', 'String',  /*cFormula*/, U_FrmtVlrExcel( "Total Rebanho" ),,.T. )
	/*02*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s103', 'Number', "=SUM(R[-"+cValToChar(nTTLin)+"]C:R[-1]C)" /*cFormula*/,,,.T. )
	/*03*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s103', 'Number', "=SUM(R[-"+cValToChar(nTTLin)+"]C:R[-1]C)" /*cFormula*/,,,.T. )
	/*04*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s103', 'Number', "=SUM(R[-"+cValToChar(nTTLin)+"]C:R[-1]C)" /*cFormula*/,,,.T. )
	/*05*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s103', 'Number', "=SUM(R[-"+cValToChar(nTTLin)+"]C:R[-1]C)" /*cFormula*/,,,.T. )
	/*06*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s103', 'Number', "=SUM(R[-"+cValToChar(nTTLin)+"]C:R[-1]C)" /*cFormula*/,,,.T. )
	/*07*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s103', 'Number', "=SUM(R[-"+cValToChar(nTTLin)+"]C:R[-1]C)" /*cFormula*/,,,.T. )
	/*08*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s103', 'Number', "=SUM(R[-"+cValToChar(nTTLin)+"]C:R[-1]C)" /*cFormula*/,,,.T. )
	/*09*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s103', 'Number', "=SUM(R[-"+cValToChar(nTTLin)+"]C:R[-1]C)" /*cFormula*/,,,.T. )
	/*10*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s103', 'Number', "=SUM(R[-"+cValToChar(nTTLin)+"]C:R[-1]C)" /*cFormula*/,,,.T. )
	/*11*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s102', 'Number', "=SUM(R[-"+cValToChar(nTTLin)+"]C:R[-1]C)" /*cFormula*/,,,.T. )
	/*12*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s103', 'Number', "=SUM(R[-"+cValToChar(nTTLin)+"]C:R[-1]C)" /*cFormula*/,,,.T. )
	/*13*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s103', 'Number', "=SUM(R[-"+cValToChar(nTTLin)+"]C:R[-1]C)" /*cFormula*/,,,.T. )
	/*14*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s103', 'Number', "=SUM(R[-"+cValToChar(nTTLin)+"]C:R[-1]C)" /*cFormula*/,,,.T. )
	cXML += U_prtCellXML( '</Row>' )

	cXML += U_prtCellXML( 'pulalinha','1' )

	If !Empty(cXML)
		FWrite(nHandle, EncodeUTF8( cXML ) )
	EndIf
	cXML := ""
EndIf

Return nil
// FIM : xmlfQdr1()

/*---------------------------------------------------------------------------------,
 | Func:  			                                                               |
 | Autor:  Miguel Martins Bernardo Junior                                          |
 | Data:   15.06.2021                                                              |
 | Desc:   Relatorio de Lotação de Baias e Pastos.                                 |
 |                                                                                 |
 | Obs.:  -                                                                        |
 '--------------------------------------------------------------------------------*/
Static Function xmlfQdr5()

Local cXML     := ""
Local nTTLin   := 0
Local aAuxQBra := {}
Local cFilOK   := cFilAnt

	aAdd( aAuxQBra, {"05: SR BRANCO", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0} )

	// fQuadro5
	If lAtual
		If !(cAliaBRAN)->(Eof())
				nTTLin+=1
				cXML += U_prtCellXML( 'Row' )
			/*01*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto'  , 'String',  /*cFormula*/, U_FrmtVlrExcel( (cAliaBRAN)->FILIAL         ),,.T. )
			/*02*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( (cAliaBRAN)->BEZERROMAMANDO ),,.T. )
			/*03*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( (cAliaBRAN)->BEZERRODESMAMA ),,.T. )
			/*04*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( (cAliaBRAN)->GARROTE        ),,.T. )
			/*05*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( (cAliaBRAN)->BOI            ),,.T. )
			/*06*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( (cAliaBRAN)->TOURO          ),,.T. )
			/*07*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( (cAliaBRAN)->BEZERRAMAMANDO ),,.T. )
			/*08*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( (cAliaBRAN)->BEZERRADESMAMA ),,.T. )
			/*09*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( (cAliaBRAN)->NOVILHA        ),,.T. )
			/*10*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( (cAliaBRAN)->VACA           ),,.T. )
			/*11*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDigN', 'String', "=SUM(RC[-9]:RC[-1])" /*cFormula*/,,,.T. )
			/*12*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( (cAliaBRAN)->MACHO          ),,.T. )
			/*13*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( (cAliaBRAN)->CAPAO          ),,.T. )
			/*14*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( (cAliaBRAN)->FEMEA          ),,.T. )
				cXML += U_prtCellXML( '</Row>' )
		EndIf

	Else  // fQuadro5
	
		DbSelectArea('SB2')
		SB2->(DbSetOrder(1))
		While !(cAliaBRAN)->(Eof())

			If xFilial('SB2') <> (cAliaBRAN)->B2_FILIAL
				SB2->(DbSetOrder(1))
				SB2->(DbSeek( (cAliaBRAN)->B2_FILIAL + (cAliaBRAN)->B1_COD + (cAliaBRAN)->B2_LOCAL ))
				cFilAnt := (cAliaBRAN)->B2_FILIAL
			EndIf
			
			If GetNewPar("MV_RASTRO", "N", (cAliaBRAN)->B2_FILIAL ) == "S" .AND. (cAliaBRAN)->B1_RASTRO == 'L' 
				nQuant := (aAuxPrd := CalcEstL( (cAliaBRAN)->B1_COD, (cAliaBRAN)->B2_LOCAL, MV_PAR01+1, (cAliaBRAN)->B8_LOTECTL))[1]
			Else
				nQuant := (aAuxPrd := CalcEst( (cAliaBRAN)->B1_COD, (cAliaBRAN)->B2_LOCAL, MV_PAR01+1, (cAliaBRAN)->B2_FILIAL))[1]
			EndIf
			If nQuant <> 0 
				If (nPosCol := aScan( aAuxQtd[1] , { |x| Upper(x) == AllTrim(Upper((cAliaBRAN)->B1_X_ERA)) } )) > 0
					aAuxQBra[ 1, nPosCol ] += aAuxPrd[1]
				EndIf     
				
				If (nPosCol := aScan( aAuxQtd[1] , { |x| Upper(x) == AllTrim(Upper((cAliaBRAN)->B1_X_SEXO)) } )) > 0
					aAuxQBra[ 1, nPosCol ] += aAuxPrd[1]
				EndIf     
			EndIf
			(cAliaBRAN)->(DbSkip())	
		EndDo
		cFilAnt := cFilOk
		
		nTTLin+=1
			cXML += U_prtCellXML( 'Row' )
	  /*01*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto'  , 'String',  /*cFormula*/, U_FrmtVlrExcel( aAuxQBra[ 01, 01 ] ),,.T. )
	  /*02*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( aAuxQBra[ 01, 02 ] ),,.T. )
	  /*03*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( aAuxQBra[ 01, 03 ] ),,.T. )
	  /*04*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( aAuxQBra[ 01, 04 ] ),,.T. )
	  /*05*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( aAuxQBra[ 01, 05 ] ),,.T. )
	  /*06*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( aAuxQBra[ 01, 06 ] ),,.T. )
	  /*07*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( aAuxQBra[ 01, 07 ] ),,.T. )
	  /*08*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( aAuxQBra[ 01, 08 ] ),,.T. )
	  /*09*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( aAuxQBra[ 01, 09 ] ),,.T. )
	  /*10*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( aAuxQBra[ 01, 10 ] ),,.T. )
	  /*11*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDigN', 'String', "=SUM(RC[-9]:RC[-1])" /*cFormula*/,,,.T. )
	  /*12*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( aAuxQBra[ 01, 12 ] ),,.T. )
	  /*13*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( aAuxQBra[ 01, 13 ] ),,.T. )
	  /*14*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sSemDig' , 'Number', /*cFormula*/, U_FrmtVlrExcel( aAuxQBra[ 01, 14 ] ),,.T. )
			cXML += U_prtCellXML( '</Row>' )
	EndIf	  

		  cXML += U_prtCellXML( 'Row' ) // em branco
	/*02*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/'2',/*cMergeAcross*/,'s73'   , 'Number', "=R[-1]C*R[1]C" /*cFormula*/,,,.T. )
	/*03*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/   ,/*cMergeAcross*/,'s73'   , 'Number', "=R[-1]C*R[1]C" /*cFormula*/,,,.T. )
	/*04*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/   ,/*cMergeAcross*/,'s73'   , 'Number', "=R[-1]C*R[1]C" /*cFormula*/,,,.T. )
	/*05*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/   ,/*cMergeAcross*/,'s73'   , 'Number', "=R[-1]C*R[1]C" /*cFormula*/,,,.T. )
	/*06*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/   ,/*cMergeAcross*/,'s73'   , 'Number', "=R[-1]C*R[1]C" /*cFormula*/,,,.T. )
	/*07*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/   ,/*cMergeAcross*/,'s73'   , 'Number', "=R[-1]C*R[1]C" /*cFormula*/,,,.T. )
	/*08*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/   ,/*cMergeAcross*/,'s73'   , 'Number', "=R[-1]C*R[1]C" /*cFormula*/,,,.T. )
	/*09*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/   ,/*cMergeAcross*/,'s73'   , 'Number', "=R[-1]C*R[1]C" /*cFormula*/,,,.T. )
	/*10*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/   ,/*cMergeAcross*/,'s73'   , 'Number', "=R[-1]C*R[1]C" /*cFormula*/,,,.T. )
	/*11*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/   ,/*cMergeAcross*/,'s73'   , 'Number', "=SUM(RC[-9]:RC[-1])" /*cFormula*/,,,.T. )
		  cXML += U_prtCellXML( '</Row>' )

	If !Empty(cXML)
		FWrite(nHandle, EncodeUTF8( cXML ) )
		cXML := ""
	EndIf
Return nil
// FIM : xmlfQdr5()


/*---------------------------------------------------------------------------------,
 | Func:  			                                                               |
 | Autor:  Miguel Martins Bernardo Junior                                          |
 | Data:   15.06.2021                                                              |
 | Desc:   Relatorio de Lotação de Baias e Pastos.                                 |
 |                                                                                 |
 | Obs.:  -                                                                        |
 '--------------------------------------------------------------------------------*/
Static Function xmlfQdrR()

Local cXML     := ""
Local cAliaCTS := CriaTrab(,.F.)
Local _cQry    := ""

	_cQry := " WITH "+CRLF+;
			   " ERAS AS ( "+CRLF+;
			   " 		SELECT	DISTINCT RTRIM(Z09_DESCRI) B1_X_ERA, Z09_CUSTO CUSTO --DISTINCT B1_X_ERA, B1_CUSTD CUSTO  "+CRLF+;
			   " 		   FROM " + RetSqlName('SB1') + " B1   "+CRLF+;
			   " 		   JOIN " + RetSqlName('SB2') + " B2    "+CRLF+;
			   "  		     ON B1_FILIAL='"+FWxFilial('SB1')+"' AND NOT ( B2_FILIAL = '0101005' AND B2_LOCAL='89')  AND B1_COD=B2_COD "+CRLF+;
			   "  		    AND B1_GRUPO IN ('01','BOV')    "+CRLF+;
			   "  		    AND B2_QATU>0 "+CRLF+;
			   "  		    AND B2.D_E_L_E_T_=' '    "+CRLF+;
			   "  		   JOIN " + RetSqlName('Z09') + " Z09 ON "+CRLF+;
			   "                Z09_CODIGO=B1_XANIMAL "+CRLF+;
			   "            AND Z09_ITEM=B1_XANIITE "+CRLF+;
			   "            AND Z09.D_E_L_E_T_ = ' '    "+CRLF+;
			   "  		  WHERE B1.D_E_L_E_T_=' '    "+CRLF+;
			   " ) "+CRLF+;
			   CRLF+;
			   " SELECT [BEZERRO MAMANDO] AS 'BEZERROMAMANDO', [BEZERRO DESMAMA] AS 'BEZERRODESMAMA', [GARROTE], [BOI], [TOURO],  "+CRLF+;
			   "  		          [BEZERRA MAMANDO] AS 'BEZERRAMAMANDO', [BEZERRA DESMAMA] AS 'BEZERRADESMAMA', [NOVILHA], [VACA],  "+CRLF+;
			   "  			      [MACHO], [CAPAO], [FEMEA]  "+CRLF+;
			   " FROM ERAS "+CRLF+;
			   " PIVOT (  "+CRLF+;
			   " 	SUM(CUSTO)  "+CRLF+;
			   " 	FOR B1_X_ERA IN ([BEZERRO MAMANDO], [BEZERRO DESMAMA], [GARROTE], [BOI], [TOURO],  "+CRLF+;
			   "  				[BEZERRA MAMANDO], [BEZERRA DESMAMA], [NOVILHA], [VACA],   "+CRLF+;
			   "  				[MACHO], [CAPAO], [FEMEA])  "+CRLF+;
			   " 	) AS PLANTELPIVO  "+CRLF+;
			   " ORDER BY 1 "
	If Select(cAliaCTS) > 0
		(cAliaCTS)->(DbCloseArea())
	EndIf
	If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
		MemoWrite("C:\totvs_relatorios\"+cPerg+"Qtdade"+StrTran(SubS(Time(),1,5),":","")+".sql" , _cQry)
	EndIf
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAliaCTS),.F.,.F.) 

	if !(cAliaCTS)->(Eof())
		  cXML += U_prtCellXML( 'Row' )
	/*01*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'sTexto', 'String', /*cFormula*/, U_FrmtVlrExcel( "FAZENDAS" ),,.T. )
	/*02*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s83'   , 'Number', /*cFormula*/, U_FrmtVlrExcel( (cAliaCTS)->BEZERROMAMANDO ),,.T. )
	/*03*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s83'   , 'Number', /*cFormula*/, U_FrmtVlrExcel( (cAliaCTS)->BEZERRODESMAMA ),,.T. )
	/*04*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s83'   , 'Number', /*cFormula*/, U_FrmtVlrExcel( (cAliaCTS)->GARROTE        ),,.T. )
	/*05*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s83'   , 'Number', /*cFormula*/, U_FrmtVlrExcel( (cAliaCTS)->BOI            ),,.T. )
	/*06*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s83'   , 'Number', /*cFormula*/, U_FrmtVlrExcel( (cAliaCTS)->TOURO          ),,.T. )
	/*07*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s83'   , 'Number', /*cFormula*/, U_FrmtVlrExcel( (cAliaCTS)->BEZERRAMAMANDO ),,.T. )
	/*08*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s83'   , 'Number', /*cFormula*/, U_FrmtVlrExcel( (cAliaCTS)->BEZERRADESMAMA ),,.T. )
	/*09*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s83'   , 'Number', /*cFormula*/, U_FrmtVlrExcel( (cAliaCTS)->NOVILHA        ),,.T. )
	/*10*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/,'s83'   , 'Number', /*cFormula*/, U_FrmtVlrExcel( (cAliaCTS)->VACA           ),,.T. )
		  cXML += U_prtCellXML( '</Row>' )
	EndIf
	(cAliaCTS)->(DbCloseArea())

		  cXML += U_prtCellXML( 'Row' )
	/*01*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/   ,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( "QUANTIDADE" ),,.T. )
	/*02*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/   ,'sSemDig', 'Number', "=SUM(R[-"+cValToChar(nTTLin+4)+"]C:R[-6]C)" /*cFormula*/,,,.T. )
	/*03*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/   ,'sSemDig', 'Number', "=SUM(R[-"+cValToChar(nTTLin+4)+"]C:R[-6]C)" /*cFormula*/,,,.T. )
	/*04*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/   ,'sSemDig', 'Number', "=SUM(R[-"+cValToChar(nTTLin+4)+"]C:R[-6]C)" /*cFormula*/,,,.T. )
	/*05*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/   ,'sSemDig', 'Number', "=SUM(R[-"+cValToChar(nTTLin+4)+"]C:R[-6]C)" /*cFormula*/,,,.T. )
	/*06*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/   ,'sSemDig', 'Number', "=SUM(R[-"+cValToChar(nTTLin+4)+"]C:R[-6]C)" /*cFormula*/,,,.T. )
	/*07*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/   ,'sSemDig', 'Number', "=SUM(R[-"+cValToChar(nTTLin+4)+"]C:R[-6]C)" /*cFormula*/,,,.T. )
	/*08*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/   ,'sSemDig', 'Number', "=SUM(R[-"+cValToChar(nTTLin+4)+"]C:R[-6]C)" /*cFormula*/,,,.T. )
	/*09*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/   ,'sSemDig', 'Number', "=SUM(R[-"+cValToChar(nTTLin+4)+"]C:R[-6]C)" /*cFormula*/,,,.T. )
	/*10*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/   ,'sSemDig', 'Number', "=SUM(R[-"+cValToChar(nTTLin+4)+"]C:R[-6]C)" /*cFormula*/,,,.T. )
	/*11*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/"1",'sSemDig', 'Number', "=SUM(RC[-9]:RC[-1])" /*cFormula*/,,,.T. )
		  cXML += U_prtCellXML( '</Row>' )

		  cXML += U_prtCellXML( 'Row' )
	/*01*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/   ,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( "TOTAL" ),,.T. )
	/*02*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/   ,'s201'   , 'Number', "=R[-2]C*R[-1]C" /*cFormula*/,,,.T. )
	/*03*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/   ,'s201'   , 'Number', "=R[-2]C*R[-1]C" /*cFormula*/,,,.T. )
	/*04*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/   ,'s201'   , 'Number', "=R[-2]C*R[-1]C" /*cFormula*/,,,.T. )
	/*05*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/   ,'s201'   , 'Number', "=R[-2]C*R[-1]C" /*cFormula*/,,,.T. )
	/*06*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/   ,'s201'   , 'Number', "=R[-2]C*R[-1]C" /*cFormula*/,,,.T. )
	/*07*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/   ,'s201'   , 'Number', "=R[-2]C*R[-1]C" /*cFormula*/,,,.T. )
	/*08*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/   ,'s201'   , 'Number', "=R[-2]C*R[-1]C" /*cFormula*/,,,.T. )
	/*09*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/   ,'s201'   , 'Number', "=R[-2]C*R[-1]C" /*cFormula*/,,,.T. )
	/*10*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/   ,'s201'   , 'Number', "=R[-2]C*R[-1]C" /*cFormula*/,,,.T. )
	/*11*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/,/*cMergeAcross*/"1",'s95'   , 'Number', "=SUM(RC[-9]:RC[-1])" /*cFormula*/,,,.T. )
		  cXML += U_prtCellXML( '</Row>' )
		  
		  cXML += U_prtCellXML( 'pulalinha','1' )

		  cXML += U_prtCellXML( 'Row' )
	/*11*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/"11",/*cMergeAcross*/   ,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( "CONFINAMENTO" ),,.T. )
	/*12*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/    ,/*cMergeAcross*/   ,'sSemDig', 'Number', "=R[-"+cValToChar(nTTLin+8)+"]C[-1]" /*cFormula*/,,,.T. )
	/*13*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/    ,/*cMergeAcross*/"1",'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( "informar manualmente" ),,.T. )
		  cXML += U_prtCellXML( '</Row>' )

		  cXML += U_prtCellXML( 'Row' )
	/*11*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/"11",/*cMergeAcross*/   ,'sTexto' , 'String', /*cFormula*/, U_FrmtVlrExcel( "FAZENDAS" ),,.T. )
	/*12*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/    ,/*cMergeAcross*/   ,'sSemDig', 'Number', "=R[-4]C[-1]" /*cFormula*/,,,.T. )
	/*13*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/    ,/*cMergeAcross*/"1",'s200'    , 'Number', "=R[-3]C[-2]" /*cFormula*/,,,.T. )
		  cXML += U_prtCellXML( '</Row>' )

		  cXML += U_prtCellXML( 'Row',,"34" )
	/*11*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/"11",/*cMergeAcross*/   ,'sTexto', 'String',  /*cFormula*/, U_FrmtVlrExcel( "TOTAL GERAL SEM SR BRANCO" ),,.T. )
	/*12*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/    ,/*cMergeAcross*/   ,'sSemDig', 'Number', "=SUM(R[-2]C:R[-1]C)" /*cFormula*/,,,.T. )
	/*13*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/    ,/*cMergeAcross*/"1",'s200'    , 'Number', "=SUM(R[-2]C:R[-1]C[1])" /*cFormula*/,,,.T. )
		  cXML += U_prtCellXML( '</Row>' )

		  cXML += U_prtCellXML( 'Row' )
	/*11*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/"11",/*cMergeAcross*/   ,'s204', 'String',  /*cFormula*/, U_FrmtVlrExcel( "SR BRANCO" ),,.T. )
	/*12*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/    ,/*cMergeAcross*/   ,'s203', 'Number', "=R[-9]C[-1]" /*cFormula*/,,,.T. )
	/*13*/cXML += U_prtCellXML( 'Cell'/*cTag*/,/*cName*/,/*cHeight*/,/*cIndex*/    ,/*cMergeAcross*/"1",'s89', 'Number', "=R[-8]C[-2]" /*cFormula*/,,,.T. )
		  cXML += U_prtCellXML( '</Row>' )

	// Final da Planilha
	cXML += '</Table>'+CRLF+;
			' <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">'+CRLF+;
			'  <PageSetup>'+CRLF+;
			'   <Header x:Margin="0.31496062000000002"/>'+CRLF+;
			'   <Footer x:Margin="0.31496062000000002"/>'+CRLF+;
			'   <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"'+CRLF+;
			'    x:Right="0.511811024" x:Top="0.78740157499999996"/>'+CRLF+;
			'  </PageSetup>'+CRLF+;
			'  <Unsynced/>'+CRLF+;
			'  <Print>'+CRLF+;
			'   <ValidPrinterInfo/>'+CRLF+;
			'   <PaperSizeIndex>9</PaperSizeIndex>'+CRLF+;
			'   <HorizontalResolution>600</HorizontalResolution>'+CRLF+;
			'   <VerticalResolution>600</VerticalResolution>'+CRLF+;
			'  </Print>'+CRLF+;
			'  <Selected/>'+CRLF+;
			'  <FreezePanes/>'+CRLF+;
			'  <FrozenNoSplit/>'+CRLF+;
			'  <SplitHorizontal>2</SplitHorizontal>'+CRLF+;
			'  <TopRowBottomPane>2</TopRowBottomPane>'+CRLF+;
			'  <ActivePane>2</ActivePane>'+CRLF+;
			'  <Panes>'+CRLF+;
			'   <Pane>'+CRLF+;
			'    <Number>3</Number>'+CRLF+;
			'   </Pane>'+CRLF+;
			'   <Pane>'+CRLF+;
			'    <Number>2</Number>'+CRLF+;
			'    <ActiveRow>5</ActiveRow>'+CRLF+;
			'    <ActiveCol>14</ActiveCol>'+CRLF+;
			'   </Pane>'+CRLF+;
			'  </Panes>'+CRLF+;
			'  <ProtectObjects>False</ProtectObjects>'+CRLF+;
			'  <ProtectScenarios>False</ProtectScenarios>'+CRLF+;
			' </WorksheetOptions>'+CRLF+;
			'</Worksheet>'

	If !Empty(cXML)
		FWrite(nHandle, EncodeUTF8( cXML ) )
	EndIf
	cXML := ""
Return nil
// FIM : xmlfQdrR()


/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  31.01.2017                                                              |
 | Desc:  Relatorio de Lotação de Baias e Pastos.                                 |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
User Function aEST015() // U_VAEST015()

Local   aArea		:= GetArea()
Local oReport                 

Private cAliaVATU   := CriaTrab(,.F.)   
Private cAliaCSTA   := CriaTrab(,.F.)   
Private cAliaINSU   := CriaTrab(,.F.)   
Private cAliaCUBR   := CriaTrab(,.F.)   // CUSTO SR BRANCO

	oReport := ReportDef()
	oReport:PrintDialog()
	
	Iif(lAtual, (cAliaVATU)->(DbCloseArea()), nil)
	(cAliaCSTA)->(DbCloseArea())
	(cAliaINSU)->(DbCloseArea())
	Iif(lAtual, (cAliaCUBR)->(DbCloseArea()), nil)
	
	RestArea(aArea)
	
Return nil

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  26.01.2017                                                              |
 | Desc:  Relatorio de Lotação de Baias e Pastos.                                 |
 |        Este relatorio faz exportacao direta para execel.                       |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function ReportDef(cCodigo)
	
	Local oReport	:= nil
	Local oSection1	:= nil, oBreak1 := nil
	Local oSection2	:= nil
	Local oSection3	:= nil
	Local oSection4	:= nil
	Local oSection5	:= nil
	Local oSection6	:= nil
	
	fQuadro1() // Quantidade
	Iif(lAtual, fQuadro2(),nil) // Custo Total
	fQuadro3() // Custo Standart
	fQuadro4() // Insumos
	fQuadro5() // Sr. Branco
	Iif(lAtual, fQuadro6(),nil) // Custo Sr. Branco

	oReport := TReport():New(cPerg+DtoS(dDataBase)+SubS(StrTran(Time(),":",""),1,4), cTitulo, cPerg, {|oReport| PrintReport(oReport) },"Este relatorio ira listar os produtos em suas Baias e Pastos" , .T./* lLandscape */,/* uTotalText */, /* .T.  lTotalInLine */, /* cPageTText */,/* lPageTInLine */,.F. /* lTPageBreak */,/* nColSpace */)
	oReport:nFontBody := 8
	oReport:cFontBody := 'Arial Narrow'
	oReport:lParamPage := .F. // nao imprimir pagina de parametros
	
	oSection1 := TRSection():New(oReport, OemToAnsi(cTitulo) )//, /* uTable */,/* aOrder */,/* lLoadCells */,/* lLoadOrder */,/* uTotalText */,/* lTotalInLine */, .F. /* lHeaderPage */, .F. /* lHeaderBreak */, .F. /* lPageBreak */, .F. /* lLineBreak */, /* nLeftMargin */, /* lLineStyle */, /* nColSpace */, .T. /* lAutoSize */,/* cCharSeparator */, /* nLinesBefore */, /* nCols */, /* nClrBack */, /* nClrFore */, /* nPercentage */)
	TRCell():New(oSection1, "_PAR01" , , "Filial"			, , TamSX3("NNR_DESCRI")[1] )
	TRCell():New(oSection1, "_PAR02" , , "Bezerro Mamando"  , "@E 999,999", TamSX3("B2_QATU")[1] )
	TRCell():New(oSection1, "_PAR03" , , "Bezerro Desmama"  , "@E 999,999", TamSX3("B2_QATU")[1] )
	TRCell():New(oSection1, "_PAR04" , , "Garrote"          , "@E 999,999", TamSX3("B2_QATU")[1] )
	TRCell():New(oSection1, "_PAR05" , , "Boi"              , "@E 999,999", TamSX3("B2_QATU")[1] )
	TRCell():New(oSection1, "_PAR06" , , "Touro"            , "@E 999,999", TamSX3("B2_QATU")[1] )
	TRCell():New(oSection1, "_PAR07" , , "Bezerra Mamando"  , "@E 999,999", TamSX3("B2_QATU")[1] )
	TRCell():New(oSection1, "_PAR08" , , "Bezerra Desmama"  , "@E 999,999", TamSX3("B2_QATU")[1] )
	TRCell():New(oSection1, "_PAR09" , , "Novilha"          , "@E 999,999", TamSX3("B2_QATU")[1] )
	TRCell():New(oSection1, "_PAR10" , , "Vaca"             , "@E 999,999", TamSX3("B2_QATU")[1] )
	TRCell():New(oSection1, "_PAR11" , , "TOTAL"            , "@E 999,999", TamSX3("B2_QATU")[1] )
	TRCell():New(oSection1, "_PAR12" , , "Macho"            , "@E 999,999", TamSX3("B2_QATU")[1] )
	TRCell():New(oSection1, "_PAR13" , , "Capão"            , "@E 999,999", TamSX3("B2_QATU")[1] )
	TRCell():New(oSection1, "_PAR14" , , "Femea"            , "@E 999,999", TamSX3("B2_QATU")[1] )

	oBreak1 := TRBreak():New(oSection1, "", "Total Rebanho", .F. )
	TRFunction():New(oSection1:Cell( "_PAR02" ) , ""  , "SUM"   , oBreak1 , "" , "@R 999,999", , .F. , .F. , .F. , oSection1 )
	TRFunction():New(oSection1:Cell( "_PAR03" ) , ""  , "SUM"   , oBreak1 , "" , "@R 999,999", , .F. , .F. , .F. , oSection1 )
	TRFunction():New(oSection1:Cell( "_PAR04" ) , ""  , "SUM"   , oBreak1 , "" , "@R 999,999", , .F. , .F. , .F. , oSection1 )
	TRFunction():New(oSection1:Cell( "_PAR05" ) , ""  , "SUM"   , oBreak1 , "" , "@R 999,999", , .F. , .F. , .F. , oSection1 )
	TRFunction():New(oSection1:Cell( "_PAR06" ) , ""  , "SUM"   , oBreak1 , "" , "@R 999,999", , .F. , .F. , .F. , oSection1 )
	TRFunction():New(oSection1:Cell( "_PAR07" ) , ""  , "SUM"   , oBreak1 , "" , "@R 999,999", , .F. , .F. , .F. , oSection1 )
	TRFunction():New(oSection1:Cell( "_PAR08" ) , ""  , "SUM"   , oBreak1 , "" , "@R 999,999", , .F. , .F. , .F. , oSection1 )
	TRFunction():New(oSection1:Cell( "_PAR09" ) , ""  , "SUM"   , oBreak1 , "" , "@R 999,999", , .F. , .F. , .F. , oSection1 )
	TRFunction():New(oSection1:Cell( "_PAR10" ) , ""  , "SUM"   , oBreak1 , "" , "@R 999,999", , .F. , .F. , .F. , oSection1 )
	TRFunction():New(oSection1:Cell( "_PAR11" ) , ""  , "SUM"   , oBreak1 , "" , "@R 999,999", , .F. , .F. , .F. , oSection1 )
	TRFunction():New(oSection1:Cell( "_PAR12" ) , ""  , "SUM"   , oBreak1 , "" , "@R 999,999", , .F. , .F. , .F. , oSection1 )
	TRFunction():New(oSection1:Cell( "_PAR13" ) , ""  , "SUM"   , oBreak1 , "" , "@R 999,999", , .F. , .F. , .F. , oSection1 )
	TRFunction():New(oSection1:Cell( "_PAR14" ) , ""  , "SUM"   , oBreak1 , "" , "@R 999,999", , .F. , .F. , .F. , oSection1 )
	
	oSection2 := TRSection():New(oSection1, "Custo Medio" ) // , /* uTable */,/* aOrder */,/* lLoadCells */,/* lLoadOrder */,/* uTotalText */, /* lTotalInLine */, .F. /* lHeaderPage */, .F. /* lHeaderBreak */, .F. /* lPageBreak */, .F. /* lLineBreak */, /* nLeftMargin */, /* lLineStyle */, /* nColSpace */, .T. /* lAutoSize */,/* cCharSeparator */, /* nLinesBefore */, /* nCols */, /* nClrBack */, /* nClrFore */, /* nPercentage */)
	TRCell():New(oSection2, "_PAR01" , , ""  , "", )
	TRCell():New(oSection2, "_PAR02" , , "Bezerro Mamando"  , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection2, "_PAR03" , , "Bezerro Desmama"  , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection2, "_PAR04" , , "Garrote"          , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection2, "_PAR05" , , "Boi"              , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection2, "_PAR06" , , "Touro"            , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection2, "_PAR07" , , "Bezerra Mamando" , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection2, "_PAR08" , , "Bezerra Desmama" , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection2, "_PAR09" , , "Novilha"          , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection2, "_PAR10" , , "Vaca"             , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection2, "_PAR11" , , "TOTAL"            , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection2, "_PAR12" , , "Macho"            , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection2, "_PAR13" , , "Capão"            , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection2, "_PAR14" , , "Femea"            , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	
	oSection3 := TRSection():New(oSection1, "Custo Standart" ) // , /* uTable */,/* aOrder */,/* lLoadCells */,/* lLoadOrder */,/* uTotalText */, /* lTotalInLine */, .F. /* lHeaderPage */, .F. /* lHeaderBreak */, .F. /* lPageBreak */, .F. /* lLineBreak */, /* nLeftMargin */, /* lLineStyle */, /* nColSpace */, .T. /* lAutoSize */,/* cCharSeparator */, /* nLinesBefore */, /* nCols */, /* nClrBack */, /* nClrFore */, /* nPercentage */)
	TRCell():New(oSection3, "_PAR01" , , ""  , "", )
	TRCell():New(oSection3, "_PAR02" , , "Bezerro Mamando"  , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection3, "_PAR03" , , "Bezerro Desmama"  , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection3, "_PAR04" , , "Garrote"          , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection3, "_PAR05" , , "Boi"              , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection3, "_PAR06" , , "Touro"            , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection3, "_PAR07" , , "Bezerra Mamando" , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection3, "_PAR08" , , "Bezerra Desmama" , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection3, "_PAR09" , , "Novilha"          , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection3, "_PAR10" , , "Vaca"             , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection3, "_PAR11" , , "TOTAL"            , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection3, "_PAR12" , , "Macho"            , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection3, "_PAR13" , , "Capão"            , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection3, "_PAR14" , , "Femea"            , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	
	oSection4 := TRSection():New(oSection1, "Custo INSUMOS" ) // , /* uTable */,/* aOrder */,/* lLoadCells */,/* lLoadOrder */,/* uTotalText */, /* lTotalInLine */, .F. /* lHeaderPage */, .F. /* lHeaderBreak */, .F. /* lPageBreak */, .F. /* lLineBreak */, /* nLeftMargin */, /* lLineStyle */, /* nColSpace */, .T. /* lAutoSize */,/* cCharSeparator */, /* nLinesBefore */, /* nCols */, /* nClrBack */, /* nClrFore */, /* nPercentage */)
	TRCell():New(oSection4, "_PAR01" , , ""  , "", )
	TRCell():New(oSection4, "_PAR02" , , "Bezerro Mamando"  , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection4, "_PAR03" , , "Bezerro Desmama"  , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection4, "_PAR04" , , "Garrote"          , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection4, "_PAR05" , , "Boi"              , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection4, "_PAR06" , , "Touro"            , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection4, "_PAR07" , , "Bezerra Mamando" , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection4, "_PAR08" , , "Bezerra Desmama" , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection4, "_PAR09" , , "Novilha"          , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection4, "_PAR10" , , "Vaca"             , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection4, "_PAR11" , , "TOTAL"            , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection4, "_PAR12" , , "Macho"            , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection4, "_PAR13" , , "Capão"            , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection4, "_PAR14" , , "Femea"            , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	
	oSection5 := TRSection():New(oSection1, OemToAnsi("Sr. Branco") )//, /* uTable */,/* aOrder */,/* lLoadCells */,/* lLoadOrder */,/* uTotalText */,/* lTotalInLine */, .F. /* lHeaderPage */, .F. /* lHeaderBreak */, .F. /* lPageBreak */, .F. /* lLineBreak */, /* nLeftMargin */, /* lLineStyle */, /* nColSpace */, .T. /* lAutoSize */,/* cCharSeparator */, /* nLinesBefore */, /* nCols */, /* nClrBack */, /* nClrFore */, /* nPercentage */)
	TRCell():New(oSection5, "_PAR01" , , "Filial"			, , TamSX3("NNR_DESCRI")[1] )
	TRCell():New(oSection5, "_PAR02" , , "Bezerro Mamando"  , "@E 999,999", TamSX3("B2_QATU")[1] )
	TRCell():New(oSection5, "_PAR03" , , "Bezerro Desmama"  , "@E 999,999", TamSX3("B2_QATU")[1] )
	TRCell():New(oSection5, "_PAR04" , , "Garrote"          , "@E 999,999", TamSX3("B2_QATU")[1] )
	TRCell():New(oSection5, "_PAR05" , , "Boi"              , "@E 999,999", TamSX3("B2_QATU")[1] )
	TRCell():New(oSection5, "_PAR06" , , "Touro"            , "@E 999,999", TamSX3("B2_QATU")[1] )
	TRCell():New(oSection5, "_PAR07" , , "Bezerra Mamando" , "@E 999,999", TamSX3("B2_QATU")[1] )
	TRCell():New(oSection5, "_PAR08" , , "Bezerra Desmama" , "@E 999,999", TamSX3("B2_QATU")[1] )
	TRCell():New(oSection5, "_PAR09" , , "Novilha"          , "@E 999,999", TamSX3("B2_QATU")[1] )
	TRCell():New(oSection5, "_PAR10" , , "Vaca"             , "@E 999,999", TamSX3("B2_QATU")[1] )
	TRCell():New(oSection5, "_PAR11" , , "TOTAL"            , "@E 999,999", TamSX3("B2_QATU")[1] )
	TRCell():New(oSection5, "_PAR12" , , "Macho"            , "@E 999,999", TamSX3("B2_QATU")[1] )
	TRCell():New(oSection5, "_PAR13" , , "Capão"            , "@E 999,999", TamSX3("B2_QATU")[1] )
	TRCell():New(oSection5, "_PAR14" , , "Femea"            , "@E 999,999", TamSX3("B2_QATU")[1] )
	
	oSection6 := TRSection():New(oSection1, "Custo Medio-Sr. Branco" ) // , /* uTable */,/* aOrder */,/* lLoadCells */,/* lLoadOrder */,/* uTotalText */, /* lTotalInLine */, .F. /* lHeaderPage */, .F. /* lHeaderBreak */, .F. /* lPageBreak */, .F. /* lLineBreak */, /* nLeftMargin */, /* lLineStyle */, /* nColSpace */, .T. /* lAutoSize */,/* cCharSeparator */, /* nLinesBefore */, /* nCols */, /* nClrBack */, /* nClrFore */, /* nPercentage */)
	TRCell():New(oSection6, "_PAR01" , , ""  , "", )
	TRCell():New(oSection6, "_PAR02" , , "Bezerro Mamando"  , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection6, "_PAR03" , , "Bezerro Desmama"  , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection6, "_PAR04" , , "Garrote"          , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection6, "_PAR05" , , "Boi"              , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection6, "_PAR06" , , "Touro"            , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection6, "_PAR07" , , "Bezerra Mamando" , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection6, "_PAR08" , , "Bezerra Desmama" , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection6, "_PAR09" , , "Novilha"          , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection6, "_PAR10" , , "Vaca"             , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection6, "_PAR11" , , "TOTAL"            , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection6, "_PAR12" , , "Macho"            , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection6, "_PAR13" , , "Capão"            , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	TRCell():New(oSection6, "_PAR14" , , "Femea"            , "@E 999,999,999.99", TamSX3("B2_VATU1")[1] )
	
Return oReport

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  26.01.2017                                                              |
 | Desc:  Relatorio de Lota??o de Baias e Pastos.                                 |
 |        Este relatorio faz exportacao direta para execel.                       |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function PrintReport(oReport)

	Local oSection1    := oReport:Section(1)
	Local oSection2    := oReport:Section(1):Section(1)
	Local oSection3    := oReport:Section(1):Section(2)
	Local oSection4    := oReport:Section(1):Section(3)
	Local oSection5    := oReport:Section(1):Section(4)
	Local oSection6    := oReport:Section(1):Section(5)

	Local aDadoQTD 	   := Array(14)
	Local aDadoVATU    := Array(14)
	Local aDadoCSTA    := Array(14)
	Local aDadoINSU    := Array(14)
	Local aDadoBRAN    := Array(14)
	Local aDadoCUBR	   := Array(14)
	Local cFilOK	   := cFilAnt
	Local aAuxCst      := {}
	Local aAuxIns      := {}
	Local aAuxQBra     := {}
	Local aAuxCBra     := {}
	
	Local nI           := 0
	Local nQuant	   := 0
	Local aAuxQtd	   := {}
	
	aAdd( aAuxQtd , {"FILIAL", "BEZERRO MAMANDO","BEZERRO DESMAMA","GARROTE","BOI","TOURO","BEZERRA MAMANDO","BEZERRA DESMAMA","NOVILHA","VACA","TOTAL","MACHO","CAPAO","FEMEA"} )
	aAdd( aAuxCst , {"", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0} )
	aAdd( aAuxIns , {"", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0} )
	aAdd( aAuxQBra, {"05: SR BRANCO", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0} )
	aAdd( aAuxCBra, {"", 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0} )
	
	oReport:SetMeter(nRegistros)

	oSection1:Cell( "_PAR01" ):SetBlock( { || aDadoQTD[01] } )
    oSection1:Cell( "_PAR02" ):SetBlock( { || aDadoQTD[02] } )
    oSection1:Cell( "_PAR03" ):SetBlock( { || aDadoQTD[03] } )
    oSection1:Cell( "_PAR04" ):SetBlock( { || aDadoQTD[04] } )
    oSection1:Cell( "_PAR05" ):SetBlock( { || aDadoQTD[05] } )
    oSection1:Cell( "_PAR06" ):SetBlock( { || aDadoQTD[06] } )
    oSection1:Cell( "_PAR07" ):SetBlock( { || aDadoQTD[07] } )
    oSection1:Cell( "_PAR08" ):SetBlock( { || aDadoQTD[08] } )
    oSection1:Cell( "_PAR09" ):SetBlock( { || aDadoQTD[09] } )
    oSection1:Cell( "_PAR10" ):SetBlock( { || aDadoQTD[10] } )
    oSection1:Cell( "_PAR11" ):SetBlock( { || aDadoQTD[11] } )
    oSection1:Cell( "_PAR12" ):SetBlock( { || aDadoQTD[12] } )
    oSection1:Cell( "_PAR13" ):SetBlock( { || aDadoQTD[13] } )
    oSection1:Cell( "_PAR14" ):SetBlock( { || aDadoQTD[14] } )
	
	oSection1:Init()  
	oReport:PrintText(cTitulo)	
	If lAtual // fQuadro1
		While !oReport:Cancel() .And. !(cAliaQTD)->(Eof())
			
			oReport:IncMeter()
			
			if  (cAliaQTD)->BEZERROMAMANDO > 0 .or. ;
				(cAliaQTD)->BEZERRODESMAMA > 0 .or. ;
				(cAliaQTD)->GARROTE > 0 .or. ;
				(cAliaQTD)->BOI > 0 .or. ;
				(cAliaQTD)->TOURO > 0 .or. ;
				(cAliaQTD)->BEZERRAMAMANDO > 0 .or. ;
				(cAliaQTD)->BEZERRADESMAMA > 0 .or. ;
				(cAliaQTD)->NOVILHA > 0 .or. ;
				(cAliaQTD)->VACA > 0
		
				aDadoQTD[01] := (cAliaQTD)->FILIAL
				aDadoQTD[02] := (cAliaQTD)->BEZERROMAMANDO
				aDadoQTD[03] := (cAliaQTD)->BEZERRODESMAMA
				aDadoQTD[04] := (cAliaQTD)->GARROTE
				aDadoQTD[05] := (cAliaQTD)->BOI
				aDadoQTD[06] := (cAliaQTD)->TOURO
				aDadoQTD[07] := (cAliaQTD)->BEZERRAMAMANDO
				aDadoQTD[08] := (cAliaQTD)->BEZERRADESMAMA
				aDadoQTD[09] := (cAliaQTD)->NOVILHA
				aDadoQTD[10] := (cAliaQTD)->VACA
				aDadoQTD[11] :=  aDadoQTD[02]+;
								 aDadoQTD[03]+;
								 aDadoQTD[04]+;
								 aDadoQTD[05]+;
								 aDadoQTD[06]+;
								 aDadoQTD[07]+;
								 aDadoQTD[08]+;
								 aDadoQTD[09]+;
								 aDadoQTD[10]
				aDadoQTD[12] := (cAliaQTD)->MACHO
				aDadoQTD[13] := (cAliaQTD)->CAPAO
				aDadoQTD[14] := (cAliaQTD)->FEMEA
				
				oSection1:PrintLine()		
			EndIf
			(cAliaQTD)->(DbSkip())	
		EndDo
		
	Else // fQuadro1
		
		DbSelectArea('SB2')
		SB2->(DbSetOrder(1))
		While !oReport:Cancel() .And. !(cAliaQTD)->(Eof())  
			oReport:IncMeter()
			
			If xFilial('SB2') <> (cAliaQTD)->B2_FILIAL			
				SB2->(DbSetOrder(1))
				SB2->(DbSeek( (cAliaQTD)->B2_FILIAL + (cAliaQTD)->B1_COD + (cAliaQTD)->B2_LOCAL ))
				cFilAnt := (cAliaQTD)->B2_FILIAL
			EndIf
			
			If GetNewPar("MV_RASTRO", "N", (cAliaQTD)->B2_FILIAL ) == "S" .AND. (cAliaQTD)->B1_RASTRO == 'L' 
				nQuant := (aAuxPrd := CalcEstL( (cAliaQTD)->B1_COD, (cAliaQTD)->B2_LOCAL, MV_PAR01+1, (cAliaQTD)->B8_LOTECTL))[1]
			Else
				nQuant := (aAuxPrd := CalcEst( (cAliaQTD)->B1_COD, (cAliaQTD)->B2_LOCAL, MV_PAR01+1 ))[1]
			EndIf
			If nQuant <> 0 

				If (nPosCol := aScan( aAuxQtd[1] , { |x| Upper(x) == AllTrim(Upper((cAliaQTD)->B1_X_ERA)) } )) > 0
					
					cFilFind := (cAliaQTD)->B2_FILIAL + ": " + (cAliaQTD)->NNR_DESCRI					
					If (nPosLin := aScan( aAuxQtd , { |x| x[1] == cFilFind } )) == 0
						aAdd( aAuxQtd, aClone(Array(14)) )
						nPosLin := Len(aAuxQtd)
						aAuxQtd[ nPosLin, 01 ] := cFilFind
						aAuxQtd[ nPosLin, 02 ] := 0
						aAuxQtd[ nPosLin, 03 ] := 0
						aAuxQtd[ nPosLin, 04 ] := 0
						aAuxQtd[ nPosLin, 05 ] := 0
						aAuxQtd[ nPosLin, 06 ] := 0
						aAuxQtd[ nPosLin, 07 ] := 0
						aAuxQtd[ nPosLin, 08 ] := 0
						aAuxQtd[ nPosLin, 09 ] := 0
						aAuxQtd[ nPosLin, 10 ] := 0
						aAuxQtd[ nPosLin, 11 ] := 0
						aAuxQtd[ nPosLin, 12 ] := 0
						aAuxQtd[ nPosLin, 13 ] := 0
						aAuxQtd[ nPosLin, 14 ] := 0
					EndIf     
					
					aAuxQtd[ nPosLin, nPosCol ] += aAuxPrd[1]
					aAuxCst[       1, nPosCol ] += aAuxPrd[2]
				EndIf     
				
				If (nPosCol := aScan( aAuxQtd[1] , { |x| Upper(x) == AllTrim(Upper((cAliaQTD)->B1_X_SEXO)) } )) > 0
					aAuxQtd[ nPosLin, nPosCol ] += aAuxPrd[1]
					aAuxCst[       1, nPosCol ] += aAuxPrd[2]
				EndIf
				
			EndIf
		
			(cAliaQTD)->(DbSkip())	
		EndDo
		cFilAnt := cFilOk
		
		For nI := 2 to Len(aAuxQtd)
			aDadoQTD[01] := aAuxQtd[ nI, 01 ]
			aDadoQTD[02] := aAuxQtd[ nI, 02 ]
			aDadoQTD[03] := aAuxQtd[ nI, 03 ]
			aDadoQTD[04] := aAuxQtd[ nI, 04 ]
			aDadoQTD[05] := aAuxQtd[ nI, 05 ]
			aDadoQTD[06] := aAuxQtd[ nI, 06 ]
			aDadoQTD[07] := aAuxQtd[ nI, 07 ]
			aDadoQTD[08] := aAuxQtd[ nI, 08 ]
			aDadoQTD[09] := aAuxQtd[ nI, 09 ]
			aDadoQTD[10] := aAuxQtd[ nI, 10 ]
			aDadoQTD[11] := aDadoQTD[02]+;
							aDadoQTD[03]+;
							aDadoQTD[04]+;
							aDadoQTD[05]+;
							aDadoQTD[06]+;
							aDadoQTD[07]+;
							aDadoQTD[08]+;
							aDadoQTD[09]+;
							aDadoQTD[10]
			If nI == 1
				aDadoQTD[11] := aAuxQtd[ nI, 11 ]
			EndIf			
			aDadoQTD[12] := aAuxQtd[ nI, 12 ]
			aDadoQTD[13] := aAuxQtd[ nI, 13 ]
			aDadoQTD[14] := aAuxQtd[ nI, 14 ]
			
			oSection1:PrintLine()		
		Next nI
		
	EndIf
	oSection1:Finish()
	oReport:SkipLine() // oReport:SetStartPage(.T.)
	
	/* -------------------------------------------------------------------------------- */
	oSection2:Cell( "_PAR01" ):SetBlock( { || aDadoVATU[01] } )
    oSection2:Cell( "_PAR02" ):SetBlock( { || aDadoVATU[02] } )
    oSection2:Cell( "_PAR03" ):SetBlock( { || aDadoVATU[03] } )
    oSection2:Cell( "_PAR04" ):SetBlock( { || aDadoVATU[04] } )
    oSection2:Cell( "_PAR05" ):SetBlock( { || aDadoVATU[05] } )
    oSection2:Cell( "_PAR06" ):SetBlock( { || aDadoVATU[06] } )
    oSection2:Cell( "_PAR07" ):SetBlock( { || aDadoVATU[07] } )
    oSection2:Cell( "_PAR08" ):SetBlock( { || aDadoVATU[08] } )
    oSection2:Cell( "_PAR09" ):SetBlock( { || aDadoVATU[09] } )
    oSection2:Cell( "_PAR10" ):SetBlock( { || aDadoVATU[10] } )
    oSection2:Cell( "_PAR11" ):SetBlock( { || aDadoVATU[11] } )
    oSection2:Cell( "_PAR12" ):SetBlock( { || aDadoVATU[12] } )
    oSection2:Cell( "_PAR13" ):SetBlock( { || aDadoVATU[13] } )
    oSection2:Cell( "_PAR14" ):SetBlock( { || aDadoVATU[14] } )
	
	oSection2:Init()  // oReport:SkipLine(2)		

	If lAtual // fQuadro2	                                
		If !(cAliaVATU)->(Eof())
			
			aDadoVATU[01] := "Valor por Cabeça"
			aDadoVATU[02] := (cAliaVATU)->BEZERROMAMANDO / oSection1:ABREAK[1]:AFUNCTION[1]:UPRINT 
			aDadoVATU[03] := (cAliaVATU)->BEZERRODESMAMA / oSection1:ABREAK[1]:AFUNCTION[2]:UPRINT 
			aDadoVATU[04] := (cAliaVATU)->GARROTE / oSection1:ABREAK[1]:AFUNCTION[3]:UPRINT 
			aDadoVATU[05] := (cAliaVATU)->BOI / oSection1:ABREAK[1]:AFUNCTION[4]:UPRINT 
			aDadoVATU[06] := (cAliaVATU)->TOURO / oSection1:ABREAK[1]:AFUNCTION[5]:UPRINT 
			aDadoVATU[07] := (cAliaVATU)->BEZERRAMAMANDO / oSection1:ABREAK[1]:AFUNCTION[6]:UPRINT 
			aDadoVATU[08] := (cAliaVATU)->BEZERRADESMAMA / oSection1:ABREAK[1]:AFUNCTION[7]:UPRINT 
			aDadoVATU[09] := (cAliaVATU)->NOVILHA / oSection1:ABREAK[1]:AFUNCTION[8]:UPRINT 
			aDadoVATU[10] := (cAliaVATU)->VACA / oSection1:ABREAK[1]:AFUNCTION[9]:UPRINT 
			aDadoVATU[11] := ((cAliaVATU)->BEZERROMAMANDO +;
							  (cAliaVATU)->BEZERRODESMAMA +;
							  (cAliaVATU)->GARROTE +;
							  (cAliaVATU)->BOI +;
							  (cAliaVATU)->TOURO +;
							  (cAliaVATU)->BEZERRAMAMANDO +;
							  (cAliaVATU)->BEZERRADESMAMA +;
							  (cAliaVATU)->NOVILHA +;
							  (cAliaVATU)->VACA) / oSection1:ABREAK[1]:AFUNCTION[10]:UPRINT
			aDadoVATU[12] := (cAliaVATU)->MACHO / oSection1:ABREAK[1]:AFUNCTION[11]:UPRINT 
			aDadoVATU[13] := (cAliaVATU)->CAPAO / oSection1:ABREAK[1]:AFUNCTION[12]:UPRINT 
			aDadoVATU[14] := (cAliaVATU)->FEMEA / oSection1:ABREAK[1]:AFUNCTION[13]:UPRINT 
			
			oSection2:PrintLine()		

			aDadoVATU    := Array(14)
			aDadoVATU[01] := "CUSTO MEDIO Total"
			aDadoVATU[02] := (cAliaVATU)->BEZERROMAMANDO
			aDadoVATU[03] := (cAliaVATU)->BEZERRODESMAMA
			aDadoVATU[04] := (cAliaVATU)->GARROTE
			aDadoVATU[05] := (cAliaVATU)->BOI
			aDadoVATU[06] := (cAliaVATU)->TOURO
			aDadoVATU[07] := (cAliaVATU)->BEZERRAMAMANDO
			aDadoVATU[08] := (cAliaVATU)->BEZERRADESMAMA
			aDadoVATU[09] := (cAliaVATU)->NOVILHA
			aDadoVATU[10] := (cAliaVATU)->VACA
			aDadoVATU[11] :=  aDadoVATU[02]+;
							  aDadoVATU[03]+;
							  aDadoVATU[04]+;
							  aDadoVATU[05]+;
							  aDadoVATU[06]+;
							  aDadoVATU[07]+;
							  aDadoVATU[08]+;
							  aDadoVATU[09]+;
							  aDadoVATU[10]
			aDadoVATU[12] := (cAliaVATU)->MACHO
			aDadoVATU[13] := (cAliaVATU)->CAPAO
			aDadoVATU[14] := (cAliaVATU)->FEMEA
			
			oSection2:PrintLine()		
		EndIf
		
	Else // fQuadro2
		
		aDadoVATU[01] := "Valor por Cabeça"
		aDadoVATU[02] := aAuxCst[01, 02] / oSection1:ABREAK[1]:AFUNCTION[1]:UPRINT 
		aDadoVATU[03] := aAuxCst[01, 03] / oSection1:ABREAK[1]:AFUNCTION[2]:UPRINT 
		aDadoVATU[04] := aAuxCst[01, 04] / oSection1:ABREAK[1]:AFUNCTION[3]:UPRINT 
		aDadoVATU[05] := aAuxCst[01, 05] / oSection1:ABREAK[1]:AFUNCTION[4]:UPRINT 
		aDadoVATU[06] := aAuxCst[01, 06] / oSection1:ABREAK[1]:AFUNCTION[5]:UPRINT 
		aDadoVATU[07] := aAuxCst[01, 07] / oSection1:ABREAK[1]:AFUNCTION[6]:UPRINT 
		aDadoVATU[08] := aAuxCst[01, 08] / oSection1:ABREAK[1]:AFUNCTION[7]:UPRINT 
		aDadoVATU[09] := aAuxCst[01, 09] / oSection1:ABREAK[1]:AFUNCTION[8]:UPRINT 
		aDadoVATU[10] := aAuxCst[01, 10] / oSection1:ABREAK[1]:AFUNCTION[9]:UPRINT 
		aDadoVATU[11] :=(aAuxCst[01, 02] +;
						 aAuxCst[01, 03] +;
						 aAuxCst[01, 04] +;
						 aAuxCst[01, 05] +;
						 aAuxCst[01, 06] +;
						 aAuxCst[01, 07] +;
						 aAuxCst[01, 08] +;
						 aAuxCst[01, 09] +;
						 aAuxCst[01, 10])/ oSection1:ABREAK[1]:AFUNCTION[10]:UPRINT
		aDadoVATU[12] := aAuxCst[01, 12] / oSection1:ABREAK[1]:AFUNCTION[11]:UPRINT 
		aDadoVATU[13] := aAuxCst[01, 13] / oSection1:ABREAK[1]:AFUNCTION[12]:UPRINT 
		aDadoVATU[14] := aAuxCst[01, 14] / oSection1:ABREAK[1]:AFUNCTION[13]:UPRINT 
		
		oSection2:PrintLine()		

		aDadoVATU    := Array(14)
		aDadoVATU[01] := "CUSTO MEDIO Total"
		aDadoVATU[02] := aAuxCst[01, 02] 
		aDadoVATU[03] := aAuxCst[01, 03] 
		aDadoVATU[04] := aAuxCst[01, 04] 
		aDadoVATU[05] := aAuxCst[01, 05] 
		aDadoVATU[06] := aAuxCst[01, 06] 
		aDadoVATU[07] := aAuxCst[01, 07] 
		aDadoVATU[08] := aAuxCst[01, 08] 
		aDadoVATU[09] := aAuxCst[01, 09] 
		aDadoVATU[10] := aAuxCst[01, 10]	 
		aDadoVATU[11] := aAuxCst[01, 02] +;
						 aAuxCst[01, 03] +; 
						 aAuxCst[01, 04] +; 
						 aAuxCst[01, 05] +; 
						 aAuxCst[01, 06] +; 
						 aAuxCst[01, 07] +; 
						 aAuxCst[01, 08] +; 
						 aAuxCst[01, 09] +; 
						 aAuxCst[01, 10]
		aDadoVATU[12] := aAuxCst[01, 12] 
		aDadoVATU[13] := aAuxCst[01, 13] 
		aDadoVATU[14] := aAuxCst[01, 14] 
		
		oSection2:PrintLine()		
	EndIf

	oSection2:Finish()
	oReport:SkipLine() // oReport:SetStartPage(.T.)
	
	/* -------------------------------------------------------------------------------- */
	oSection3:Cell( "_PAR01" ):SetBlock( { || aDadoCSTA[01] } )
    oSection3:Cell( "_PAR02" ):SetBlock( { || aDadoCSTA[02] } )
    oSection3:Cell( "_PAR03" ):SetBlock( { || aDadoCSTA[03] } )
    oSection3:Cell( "_PAR04" ):SetBlock( { || aDadoCSTA[04] } )
    oSection3:Cell( "_PAR05" ):SetBlock( { || aDadoCSTA[05] } )
    oSection3:Cell( "_PAR06" ):SetBlock( { || aDadoCSTA[06] } )
    oSection3:Cell( "_PAR07" ):SetBlock( { || aDadoCSTA[07] } )
    oSection3:Cell( "_PAR08" ):SetBlock( { || aDadoCSTA[08] } )
    oSection3:Cell( "_PAR09" ):SetBlock( { || aDadoCSTA[09] } )
    oSection3:Cell( "_PAR10" ):SetBlock( { || aDadoCSTA[10] } )
    oSection3:Cell( "_PAR11" ):SetBlock( { || aDadoCSTA[11] } )
    oSection3:Cell( "_PAR12" ):SetBlock( { || aDadoCSTA[12] } )
    oSection3:Cell( "_PAR13" ):SetBlock( { || aDadoCSTA[13] } )
    oSection3:Cell( "_PAR14" ):SetBlock( { || aDadoCSTA[14] } )
	
	// fQuadro3
	oSection3:Init()  
	If !(cAliaCSTA)->(Eof())
		aDadoCSTA[01] := "Valor por Cabeça"
		aDadoCSTA[02] := (cAliaCSTA)->BEZERROMAMANDO
		aDadoCSTA[03] := (cAliaCSTA)->BEZERRODESMAMA
		aDadoCSTA[04] := (cAliaCSTA)->GARROTE
		aDadoCSTA[05] := (cAliaCSTA)->BOI
		aDadoCSTA[06] := (cAliaCSTA)->TOURO
		aDadoCSTA[07] := (cAliaCSTA)->BEZERRAMAMANDO
		aDadoCSTA[08] := (cAliaCSTA)->BEZERRADESMAMA
		aDadoCSTA[09] := (cAliaCSTA)->NOVILHA
		aDadoCSTA[10] := (cAliaCSTA)->VACA
		aDadoCSTA[11] := ((aDadoCSTA[02] * oSection1:ABREAK[1]:AFUNCTION[1]:UPRINT)+;
						  (aDadoCSTA[03] * oSection1:ABREAK[1]:AFUNCTION[2]:UPRINT)+;
						  (aDadoCSTA[04] * oSection1:ABREAK[1]:AFUNCTION[3]:UPRINT)+;
						  (aDadoCSTA[05] * oSection1:ABREAK[1]:AFUNCTION[4]:UPRINT)+;
						  (aDadoCSTA[06] * oSection1:ABREAK[1]:AFUNCTION[5]:UPRINT)+;
						  (aDadoCSTA[07] * oSection1:ABREAK[1]:AFUNCTION[6]:UPRINT)+;
						  (aDadoCSTA[08] * oSection1:ABREAK[1]:AFUNCTION[7]:UPRINT)+;
						  (aDadoCSTA[09] * oSection1:ABREAK[1]:AFUNCTION[8]:UPRINT)+;
						  (aDadoCSTA[10] * oSection1:ABREAK[1]:AFUNCTION[9]:UPRINT)) ;
						   / oSection1:ABREAK[1]:AFUNCTION[10]:UPRINT
		aDadoCSTA[12] := (cAliaCSTA)->MACHO
		aDadoCSTA[13] := (cAliaCSTA)->CAPAO 
		aDadoCSTA[14] := (cAliaCSTA)->FEMEA 
		oSection3:PrintLine()			
		
		aDadoCSTA    := Array(14)
		aDadoCSTA[01] := "CUSTO STANDART Total"
		aDadoCSTA[02] := (cAliaCSTA)->BEZERROMAMANDO * oSection1:ABREAK[1]:AFUNCTION[1]:UPRINT 
		aDadoCSTA[03] := (cAliaCSTA)->BEZERRODESMAMA * oSection1:ABREAK[1]:AFUNCTION[2]:UPRINT 
		aDadoCSTA[04] := (cAliaCSTA)->GARROTE * oSection1:ABREAK[1]:AFUNCTION[3]:UPRINT 
		aDadoCSTA[05] := (cAliaCSTA)->BOI * oSection1:ABREAK[1]:AFUNCTION[4]:UPRINT 
		aDadoCSTA[06] := (cAliaCSTA)->TOURO * oSection1:ABREAK[1]:AFUNCTION[5]:UPRINT 
		aDadoCSTA[07] := (cAliaCSTA)->BEZERRAMAMANDO * oSection1:ABREAK[1]:AFUNCTION[6]:UPRINT 
		aDadoCSTA[08] := (cAliaCSTA)->BEZERRADESMAMA * oSection1:ABREAK[1]:AFUNCTION[7]:UPRINT 
		aDadoCSTA[09] := (cAliaCSTA)->NOVILHA * oSection1:ABREAK[1]:AFUNCTION[8]:UPRINT 
		aDadoCSTA[10] := (cAliaCSTA)->VACA * oSection1:ABREAK[1]:AFUNCTION[9]:UPRINT 
		aDadoCSTA[11] :=  aDadoCSTA[02]+;
						  aDadoCSTA[03]+;
						  aDadoCSTA[04]+;
						  aDadoCSTA[05]+;
						  aDadoCSTA[06]+;
						  aDadoCSTA[07]+;
						  aDadoCSTA[08]+;
						  aDadoCSTA[09]+;
						  aDadoCSTA[10]
		aDadoCSTA[12] := (cAliaCSTA)->MACHO * oSection1:ABREAK[1]:AFUNCTION[11]:UPRINT 
		aDadoCSTA[13] := (cAliaCSTA)->CAPAO * oSection1:ABREAK[1]:AFUNCTION[12]:UPRINT 
		aDadoCSTA[14] := (cAliaCSTA)->FEMEA * oSection1:ABREAK[1]:AFUNCTION[13]:UPRINT 
		
		oSection3:PrintLine()		
		
	EndIf
	oSection3:Finish()
	oReport:SkipLine()
	
	/* -------------------------------------------------------------------------------- */
	oSection4:Cell( "_PAR01" ):SetBlock( { || aDadoINSU[01] } )
    oSection4:Cell( "_PAR02" ):SetBlock( { || aDadoINSU[02] } )
    oSection4:Cell( "_PAR03" ):SetBlock( { || aDadoINSU[03] } )
    oSection4:Cell( "_PAR04" ):SetBlock( { || aDadoINSU[04] } )
    oSection4:Cell( "_PAR05" ):SetBlock( { || aDadoINSU[05] } )
    oSection4:Cell( "_PAR06" ):SetBlock( { || aDadoINSU[06] } )
    oSection4:Cell( "_PAR07" ):SetBlock( { || aDadoINSU[07] } )
    oSection4:Cell( "_PAR08" ):SetBlock( { || aDadoINSU[08] } )
    oSection4:Cell( "_PAR09" ):SetBlock( { || aDadoINSU[09] } )
    oSection4:Cell( "_PAR10" ):SetBlock( { || aDadoINSU[10] } )
    oSection4:Cell( "_PAR11" ):SetBlock( { || aDadoINSU[11] } )
    oSection4:Cell( "_PAR12" ):SetBlock( { || aDadoINSU[12] } )
    oSection4:Cell( "_PAR13" ):SetBlock( { || aDadoINSU[13] } )
    oSection4:Cell( "_PAR14" ):SetBlock( { || aDadoINSU[14] } )
	
	oSection4:Init()  
	
	If lAtual	// fQuadro4
		
		If !(cAliaINSU)->(Eof())
			
			aDadoINSU[01] := "Valor por Cabeça"
			aDadoINSU[02] := (cAliaINSU)->BEZERROMAMANDO / oSection1:ABREAK[1]:AFUNCTION[1]:UPRINT 
			aDadoINSU[03] := (cAliaINSU)->BEZERRODESMAMA / oSection1:ABREAK[1]:AFUNCTION[2]:UPRINT 
			aDadoINSU[04] := (cAliaINSU)->GARROTE / oSection1:ABREAK[1]:AFUNCTION[3]:UPRINT 
			aDadoINSU[05] := (cAliaINSU)->BOI / oSection1:ABREAK[1]:AFUNCTION[4]:UPRINT 
			aDadoINSU[06] := (cAliaINSU)->TOURO / oSection1:ABREAK[1]:AFUNCTION[5]:UPRINT 
			aDadoINSU[07] := (cAliaINSU)->BEZERRAMAMANDO / oSection1:ABREAK[1]:AFUNCTION[6]:UPRINT 
			aDadoINSU[08] := (cAliaINSU)->BEZERRADESMAMA / oSection1:ABREAK[1]:AFUNCTION[7]:UPRINT 
			aDadoINSU[09] := (cAliaINSU)->NOVILHA / oSection1:ABREAK[1]:AFUNCTION[8]:UPRINT 
			aDadoINSU[10] := (cAliaINSU)->VACA / oSection1:ABREAK[1]:AFUNCTION[9]:UPRINT 
			aDadoINSU[11] := ((cAliaINSU)->BEZERROMAMANDO +;
							  (cAliaINSU)->BEZERRODESMAMA +;
							  (cAliaINSU)->GARROTE +;
							  (cAliaINSU)->BOI +;
							  (cAliaINSU)->TOURO +;
							  (cAliaINSU)->BEZERRAMAMANDO +;
							  (cAliaINSU)->BEZERRADESMAMA +;
							  (cAliaINSU)->NOVILHA +;
							  (cAliaINSU)->VACA) / oSection1:ABREAK[1]:AFUNCTION[10]:UPRINT
			aDadoINSU[12] := (cAliaINSU)->MACHO / oSection1:ABREAK[1]:AFUNCTION[11]:UPRINT 
			aDadoINSU[13] := (cAliaINSU)->CAPAO / oSection1:ABREAK[1]:AFUNCTION[12]:UPRINT 
			aDadoINSU[14] := (cAliaINSU)->FEMEA / oSection1:ABREAK[1]:AFUNCTION[13]:UPRINT 
			
			oSection4:PrintLine()		
			
			aDadoINSU    := Array(14)
			aDadoINSU[01] := "CUSTO INSUMO Total"
			aDadoINSU[02] := (cAliaINSU)->BEZERROMAMANDO
			aDadoINSU[03] := (cAliaINSU)->BEZERRODESMAMA
			aDadoINSU[04] := (cAliaINSU)->GARROTE
			aDadoINSU[05] := (cAliaINSU)->BOI
			aDadoINSU[06] := (cAliaINSU)->TOURO
			aDadoINSU[07] := (cAliaINSU)->BEZERRAMAMANDO
			aDadoINSU[08] := (cAliaINSU)->BEZERRADESMAMA
			aDadoINSU[09] := (cAliaINSU)->NOVILHA
			aDadoINSU[10] := (cAliaINSU)->VACA
			aDadoINSU[11] :=  aDadoINSU[02]+;
							  aDadoINSU[03]+;
							  aDadoINSU[04]+;
							  aDadoINSU[05]+;
							  aDadoINSU[06]+;
							  aDadoINSU[07]+;
							  aDadoINSU[08]+;
							  aDadoINSU[09]+;
							  aDadoINSU[10]
			aDadoINSU[12] := (cAliaINSU)->MACHO
			aDadoINSU[13] := (cAliaINSU)->CAPAO
			aDadoINSU[14] := (cAliaINSU)->FEMEA
			
			oSection4:PrintLine()		
		EndIf
		
	Else // fQuadro4
	
		DbSelectArea('SB2')
		SB2->(DbSetOrder(1))
		While !oReport:Cancel() .And. !(cAliaINSU)->(Eof())
			oReport:IncMeter()

			If xFilial('SB2') <> (cAliaINSU)->B2_FILIAL
				SB2->(DbSetOrder(1))
				SB2->(DbSeek( (cAliaINSU)->B2_FILIAL + (cAliaINSU)->B1_XLOTE + (cAliaINSU)->B2_LOCAL ))
				cFilAnt := (cAliaINSU)->B2_FILIAL
			EndIf
			
			nQuant := (aAuxPrd := CalcEst( (cAliaINSU)->B1_XLOTE, (cAliaINSU)->B2_LOCAL, MV_PAR01+1, (cAliaINSU)->B2_FILIAL))[1]
			If nQuant <> 0 

				If (nPosCol := aScan( aAuxQtd[1] , { |x| Upper(x) == AllTrim(Upper((cAliaINSU)->B1_X_ERA)) } )) > 0
					aAuxIns[ 1, nPosCol ] += aAuxPrd[2]
				EndIf     
				
				If (nPosCol := aScan( aAuxQtd[1] , { |x| Upper(x) == AllTrim(Upper((cAliaINSU)->B1_X_SEXO)) } )) > 0				
					aAuxIns[       1, nPosCol ] += aAuxPrd[2]
				EndIf
				
			EndIf
			(cAliaINSU)->(DbSkip())	
		EndDo
		cFilAnt := cFilOk
		
		aDadoINSU[01] := "Valor por Cabeça"
		aDadoINSU[02] := aAuxIns[ 01, 02] / oSection1:ABREAK[1]:AFUNCTION[1]:UPRINT 
		aDadoINSU[03] := aAuxIns[ 01, 03] / oSection1:ABREAK[1]:AFUNCTION[2]:UPRINT 
		aDadoINSU[04] := aAuxIns[ 01, 04] / oSection1:ABREAK[1]:AFUNCTION[3]:UPRINT 
		aDadoINSU[05] := aAuxIns[ 01, 05] / oSection1:ABREAK[1]:AFUNCTION[4]:UPRINT 
		aDadoINSU[06] := aAuxIns[ 01, 06] / oSection1:ABREAK[1]:AFUNCTION[5]:UPRINT 
		aDadoINSU[07] := aAuxIns[ 01, 07] / oSection1:ABREAK[1]:AFUNCTION[6]:UPRINT 
		aDadoINSU[08] := aAuxIns[ 01, 08] / oSection1:ABREAK[1]:AFUNCTION[7]:UPRINT 
		aDadoINSU[09] := aAuxIns[ 01, 09] / oSection1:ABREAK[1]:AFUNCTION[8]:UPRINT 
		aDadoINSU[10] := aAuxIns[ 01, 10] / oSection1:ABREAK[1]:AFUNCTION[9]:UPRINT 
		aDadoINSU[11] :=(aAuxIns[ 01, 02] +;
						 aAuxIns[ 01, 03] +;
						 aAuxIns[ 01, 04] +;
						 aAuxIns[ 01, 05] +;
						 aAuxIns[ 01, 06] +;
						 aAuxIns[ 01, 07] +;
						 aAuxIns[ 01, 08] +;
						 aAuxIns[ 01, 09] +;
						 aAuxIns[ 01, 10] ) / oSection1:ABREAK[1]:AFUNCTION[10]:UPRINT
		aDadoINSU[12] := aAuxIns[ 01, 12] / oSection1:ABREAK[1]:AFUNCTION[11]:UPRINT 
		aDadoINSU[13] := aAuxIns[ 01, 13] / oSection1:ABREAK[1]:AFUNCTION[12]:UPRINT 
		aDadoINSU[14] := aAuxIns[ 01, 14] / oSection1:ABREAK[1]:AFUNCTION[13]:UPRINT 
		
		oSection4:PrintLine()		
		
		aDadoINSU    := Array(14)
		aDadoINSU[01] := "CUSTO INSUMO Total"
		aDadoINSU[02] := aAuxIns[ 01, 02]
		aDadoINSU[03] := aAuxIns[ 01, 03]
		aDadoINSU[04] := aAuxIns[ 01, 04]
		aDadoINSU[05] := aAuxIns[ 01, 05]
		aDadoINSU[06] := aAuxIns[ 01, 06]
		aDadoINSU[07] := aAuxIns[ 01, 07]
		aDadoINSU[08] := aAuxIns[ 01, 08]
		aDadoINSU[09] := aAuxIns[ 01, 09]
		aDadoINSU[10] := aAuxIns[ 01, 10]
		aDadoINSU[11] := aAuxIns[ 01, 02] +;
						 aAuxIns[ 01, 03] +;
						 aAuxIns[ 01, 04] +;
						 aAuxIns[ 01, 05] +;
						 aAuxIns[ 01, 06] +;
						 aAuxIns[ 01, 07] +;
						 aAuxIns[ 01, 08] +;
						 aAuxIns[ 01, 09] +;
						 aAuxIns[ 01, 10]
		aDadoINSU[12] := aAuxIns[ 01, 12]
		aDadoINSU[13] := aAuxIns[ 01, 13]
		aDadoINSU[14] := aAuxIns[ 01, 14]
		
		oSection4:PrintLine()		

	EndIf

	oSection4:Finish()
	oReport:SkipLine()
	
	/* -------------------------------------------------------------------------------- */	
	oSection5:Cell( "_PAR01" ):SetBlock( { || aDadoBRAN[01] } )
    oSection5:Cell( "_PAR02" ):SetBlock( { || aDadoBRAN[02] } )
    oSection5:Cell( "_PAR03" ):SetBlock( { || aDadoBRAN[03] } )
    oSection5:Cell( "_PAR04" ):SetBlock( { || aDadoBRAN[04] } )
    oSection5:Cell( "_PAR05" ):SetBlock( { || aDadoBRAN[05] } )
    oSection5:Cell( "_PAR06" ):SetBlock( { || aDadoBRAN[06] } )
    oSection5:Cell( "_PAR07" ):SetBlock( { || aDadoBRAN[07] } )
    oSection5:Cell( "_PAR08" ):SetBlock( { || aDadoBRAN[08] } )
    oSection5:Cell( "_PAR09" ):SetBlock( { || aDadoBRAN[09] } )
    oSection5:Cell( "_PAR10" ):SetBlock( { || aDadoBRAN[10] } )
    oSection5:Cell( "_PAR11" ):SetBlock( { || aDadoBRAN[11] } )
    oSection5:Cell( "_PAR12" ):SetBlock( { || aDadoBRAN[12] } )
    oSection5:Cell( "_PAR13" ):SetBlock( { || aDadoBRAN[13] } )
    oSection5:Cell( "_PAR14" ):SetBlock( { || aDadoBRAN[14] } )
	
	oSection5:Init()  
	If lAtual // fQuadro5
		
		If !(cAliaBRAN)->(Eof())
			
			oReport:IncMeter()
		
			aDadoBRAN[01] := (cAliaBRAN)->FILIAL
			aDadoBRAN[02] := (cAliaBRAN)->BEZERROMAMANDO
			aDadoBRAN[03] := (cAliaBRAN)->BEZERRODESMAMA
			aDadoBRAN[04] := (cAliaBRAN)->GARROTE
			aDadoBRAN[05] := (cAliaBRAN)->BOI
			aDadoBRAN[06] := (cAliaBRAN)->TOURO
			aDadoBRAN[07] := (cAliaBRAN)->BEZERRAMAMANDO
			aDadoBRAN[08] := (cAliaBRAN)->BEZERRADESMAMA
			aDadoBRAN[09] := (cAliaBRAN)->NOVILHA
			aDadoBRAN[10] := (cAliaBRAN)->VACA
			aDadoBRAN[11] :=  aDadoBRAN[02]+;
							  aDadoBRAN[03]+;
							  aDadoBRAN[04]+;
							  aDadoBRAN[05]+;
							  aDadoBRAN[06]+;
							  aDadoBRAN[07]+;
							  aDadoBRAN[08]+;
							  aDadoBRAN[09]+;
							  aDadoBRAN[10]
			aDadoBRAN[12] := (cAliaBRAN)->MACHO
			aDadoBRAN[13] := (cAliaBRAN)->CAPAO
			aDadoBRAN[14] := (cAliaBRAN)->FEMEA
			
			oSection5:PrintLine()
			
		EndIf
		
	Else  // fQuadro5
		
		DbSelectArea('SB2')
		SB2->(DbSetOrder(1))
		While !oReport:Cancel() .And. !(cAliaBRAN)->(Eof())
			oReport:IncMeter()

			If xFilial('SB2') <> (cAliaBRAN)->B2_FILIAL
				SB2->(DbSetOrder(1))
				SB2->(DbSeek( (cAliaBRAN)->B2_FILIAL + (cAliaBRAN)->B1_COD + (cAliaBRAN)->B2_LOCAL ))
				cFilAnt := (cAliaBRAN)->B2_FILIAL
			EndIf
			
			If GetNewPar("MV_RASTRO", "N", (cAliaBRAN)->B2_FILIAL ) == "S" .AND. (cAliaBRAN)->B1_RASTRO == 'L' 
				nQuant := (aAuxPrd := CalcEstL( (cAliaBRAN)->B1_COD, (cAliaBRAN)->B2_LOCAL, MV_PAR01+1, (cAliaBRAN)->B8_LOTECTL))[1]
			Else
				nQuant := (aAuxPrd := CalcEst( (cAliaBRAN)->B1_COD, (cAliaBRAN)->B2_LOCAL, MV_PAR01+1, (cAliaBRAN)->B2_FILIAL))[1]
			EndIf
			If nQuant <> 0 

				If (nPosCol := aScan( aAuxQtd[1] , { |x| Upper(x) == AllTrim(Upper((cAliaBRAN)->B1_X_ERA)) } )) > 0
					aAuxQBra[ 1, nPosCol ] += aAuxPrd[1]
					aAuxCBra[ 1, nPosCol ] += aAuxPrd[2]
				EndIf     
				
				If (nPosCol := aScan( aAuxQtd[1] , { |x| Upper(x) == AllTrim(Upper((cAliaBRAN)->B1_X_SEXO)) } )) > 0
					aAuxQBra[ 1, nPosCol ] += aAuxPrd[1]
					aAuxCBra[ 1, nPosCol ] += aAuxPrd[2]
				EndIf     
				
			EndIf
			(cAliaBRAN)->(DbSkip())	
		EndDo
		cFilAnt := cFilOk
		
		oReport:IncMeter()
		
		aDadoBRAN[01] := aAuxQBra[ 01, 01]
		aDadoBRAN[02] := aAuxQBra[ 01, 02]
		aDadoBRAN[03] := aAuxQBra[ 01, 03]
		aDadoBRAN[04] := aAuxQBra[ 01, 04]
		aDadoBRAN[05] := aAuxQBra[ 01, 05]
		aDadoBRAN[06] := aAuxQBra[ 01, 06]
		aDadoBRAN[07] := aAuxQBra[ 01, 07]
		aDadoBRAN[08] := aAuxQBra[ 01, 08]
		aDadoBRAN[09] := aAuxQBra[ 01, 09]
		aDadoBRAN[10] := aAuxQBra[ 01, 10]
		aDadoBRAN[11] := aDadoBRAN[02] +;
						 aDadoBRAN[03] +;
						 aDadoBRAN[04] +;
						 aDadoBRAN[05] +;
						 aDadoBRAN[06] +;
						 aDadoBRAN[07] +;
						 aDadoBRAN[08] +;
						 aDadoBRAN[09] +;
						 aDadoBRAN[10]
		aDadoBRAN[12] := aAuxQBra[ 01, 12]
		aDadoBRAN[13] := aAuxQBra[ 01, 13]
		aDadoBRAN[14] := aAuxQBra[ 01, 14]
		
		oSection5:PrintLine()		
	EndIf

	oSection5:Finish()
	// oReport:SkipLine(2) // oReport:SetStartPage(.T.)
	
	
	/* -------------------------------------------------------------------------------- */
	oSection6:Cell( "_PAR01" ):SetBlock( { || aDadoCUBR[01] } )
    oSection6:Cell( "_PAR02" ):SetBlock( { || aDadoCUBR[02] } )
    oSection6:Cell( "_PAR03" ):SetBlock( { || aDadoCUBR[03] } )
    oSection6:Cell( "_PAR04" ):SetBlock( { || aDadoCUBR[04] } )
    oSection6:Cell( "_PAR05" ):SetBlock( { || aDadoCUBR[05] } )
    oSection6:Cell( "_PAR06" ):SetBlock( { || aDadoCUBR[06] } )
    oSection6:Cell( "_PAR07" ):SetBlock( { || aDadoCUBR[07] } )
    oSection6:Cell( "_PAR08" ):SetBlock( { || aDadoCUBR[08] } )
    oSection6:Cell( "_PAR09" ):SetBlock( { || aDadoCUBR[09] } )
    oSection6:Cell( "_PAR10" ):SetBlock( { || aDadoCUBR[10] } )
    oSection6:Cell( "_PAR11" ):SetBlock( { || aDadoCUBR[11] } )
    oSection6:Cell( "_PAR12" ):SetBlock( { || aDadoCUBR[12] } )
    oSection6:Cell( "_PAR13" ):SetBlock( { || aDadoCUBR[13] } )
    oSection6:Cell( "_PAR14" ):SetBlock( { || aDadoCUBR[14] } )
	
	oSection6:Init()  // oReport:SkipLine(2)	
	If lAtual // fQuadro6
		
		If !(cAliaCUBR)->(Eof())
			
			aDadoCUBR[01] := "Valor por Cabeça: Sr. Branco"
			aDadoCUBR[02] := (cAliaCUBR)->BEZERROMAMANDO / aDadoBRAN[02]
			aDadoCUBR[03] := (cAliaCUBR)->BEZERRODESMAMA / aDadoBRAN[03]
			aDadoCUBR[04] := (cAliaCUBR)->GARROTE 		 / aDadoBRAN[04]
			aDadoCUBR[05] := (cAliaCUBR)->BOI 			 / aDadoBRAN[05]
			aDadoCUBR[06] := (cAliaCUBR)->TOURO 		 / aDadoBRAN[06]
			aDadoCUBR[07] := (cAliaCUBR)->BEZERRAMAMANDO / aDadoBRAN[07]
			aDadoCUBR[08] := (cAliaCUBR)->BEZERRADESMAMA / aDadoBRAN[08]
			aDadoCUBR[09] := (cAliaCUBR)->NOVILHA 		 / aDadoBRAN[09]
			aDadoCUBR[10] := (cAliaCUBR)->VACA 			 / aDadoBRAN[10]
			aDadoCUBR[11] := ((cAliaCUBR)->BEZERROMAMANDO +;
							  (cAliaCUBR)->BEZERRODESMAMA +;
							  (cAliaCUBR)->GARROTE +;
							  (cAliaCUBR)->BOI +;
							  (cAliaCUBR)->TOURO +;
							  (cAliaCUBR)->BEZERRAMAMANDO +;
							  (cAliaCUBR)->BEZERRADESMAMA +;
							  (cAliaCUBR)->NOVILHA +;
							  (cAliaCUBR)->VACA) / aDadoBRAN[11]
			aDadoCUBR[12] := (cAliaCUBR)->MACHO 		/ aDadoBRAN[12]
			aDadoCUBR[13] := (cAliaCUBR)->CAPAO 		/ aDadoBRAN[13]
			aDadoCUBR[14] := (cAliaCUBR)->FEMEA 		/ aDadoBRAN[14]
			
			oSection6:PrintLine()		
			
			aDadoCUBR	   := Array(14)
			aDadoCUBR[01] := "CUSTO MEDIO Total: Sr. Branco"
			aDadoCUBR[02] := (cAliaCUBR)->BEZERROMAMANDO
			aDadoCUBR[03] := (cAliaCUBR)->BEZERRODESMAMA
			aDadoCUBR[04] := (cAliaCUBR)->GARROTE
			aDadoCUBR[05] := (cAliaCUBR)->BOI
			aDadoCUBR[06] := (cAliaCUBR)->TOURO
			aDadoCUBR[07] := (cAliaCUBR)->BEZERRAMAMANDO
			aDadoCUBR[08] := (cAliaCUBR)->BEZERRADESMAMA
			aDadoCUBR[09] := (cAliaCUBR)->NOVILHA
			aDadoCUBR[10] := (cAliaCUBR)->VACA
			aDadoCUBR[11] :=  aDadoCUBR[02]+;
							  aDadoCUBR[03]+;
							  aDadoCUBR[04]+;
							  aDadoCUBR[05]+;
							  aDadoCUBR[06]+;
							  aDadoCUBR[07]+;
							  aDadoCUBR[08]+;
							  aDadoCUBR[09]+;
							  aDadoCUBR[10]
			aDadoCUBR[12] := (cAliaCUBR)->MACHO
			aDadoCUBR[13] := (cAliaCUBR)->CAPAO
			aDadoCUBR[14] := (cAliaCUBR)->FEMEA
			
			oSection6:PrintLine()		
		EndIf
		
	Else // fQuadro6

		aDadoCUBR[01] := "Valor por Cabeça: Sr. Branco"
		aDadoCUBR[02] := aAuxCBra[ 01, 02] / aDadoBRAN[02]
		aDadoCUBR[03] := aAuxCBra[ 01, 03] / aDadoBRAN[03]
		aDadoCUBR[04] := aAuxCBra[ 01, 04] / aDadoBRAN[04]
		aDadoCUBR[05] := aAuxCBra[ 01, 05] / aDadoBRAN[05]
		aDadoCUBR[06] := aAuxCBra[ 01, 06] / aDadoBRAN[06]
		aDadoCUBR[07] := aAuxCBra[ 01, 07] / aDadoBRAN[07]
		aDadoCUBR[08] := aAuxCBra[ 01, 08] / aDadoBRAN[08]
		aDadoCUBR[09] := aAuxCBra[ 01, 09] / aDadoBRAN[09]
		aDadoCUBR[10] := aAuxCBra[ 01, 10] / aDadoBRAN[10]
		aDadoCUBR[11] :=(aAuxCBra[ 01, 02] +;
						 aAuxCBra[ 01, 03] +;
						 aAuxCBra[ 01, 04] +;
						 aAuxCBra[ 01, 05] +;
						 aAuxCBra[ 01, 06] +;
						 aAuxCBra[ 01, 07] +;
						 aAuxCBra[ 01, 08] +;
						 aAuxCBra[ 01, 09] +;
						 aAuxCBra[ 01, 10]) / aDadoBRAN[11]
		aDadoCUBR[12] := aAuxCBra[ 01, 12] / aDadoBRAN[12]
		aDadoCUBR[13] := aAuxCBra[ 01, 13] / aDadoBRAN[13]
		aDadoCUBR[14] := aAuxCBra[ 01, 14] / aDadoBRAN[14]
		
		oSection6:PrintLine()		
		
		aDadoCUBR	   := Array(14)
		aDadoCUBR[01] := "CUSTO MEDIO Total: Sr. Branco"
		aDadoCUBR[02] := aAuxCBra[ 01, 02] 
		aDadoCUBR[03] := aAuxCBra[ 01, 03] 
		aDadoCUBR[04] := aAuxCBra[ 01, 04] 
		aDadoCUBR[05] := aAuxCBra[ 01, 05] 
		aDadoCUBR[06] := aAuxCBra[ 01, 06] 
		aDadoCUBR[07] := aAuxCBra[ 01, 07] 
		aDadoCUBR[08] := aAuxCBra[ 01, 08] 
		aDadoCUBR[09] := aAuxCBra[ 01, 09] 
		aDadoCUBR[10] := aAuxCBra[ 01, 10] 
		aDadoCUBR[11] := aAuxCBra[ 01, 02] +;
						 aAuxCBra[ 01, 03] +;
						 aAuxCBra[ 01, 04] +;
						 aAuxCBra[ 01, 05] +;
						 aAuxCBra[ 01, 06] +;
						 aAuxCBra[ 01, 07] +;
						 aAuxCBra[ 01, 08] +;
						 aAuxCBra[ 01, 09] +;
						 aAuxCBra[ 01, 10] 
		aDadoCUBR[12] := aAuxCBra[ 01, 12]
		aDadoCUBR[13] := aAuxCBra[ 01, 13]
		aDadoCUBR[14] := aAuxCBra[ 01, 14]
		
		oSection6:PrintLine()		
	EndIf

	oSection6:Finish()
	oReport:SkipLine() // oReport:SetStartPage(.T.)
	
Return nil

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  02.02.2017                                                              |
 | Desc:  Processa informaçao de quantidade dos bois por ERA;                     |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro1()
Local aArea := GetArea()
Local _cQry := ""


	If lAtual
		_cQry := " WITH PLANTEL1 AS " +  CRLF
		_cQry += " ( " +  CRLF
		_cQry += " 	SELECT B2_FILIAL, B1_X_ERA,  " +  CRLF
		_cQry += " 	B2_LOCAL, NNR_DESCRI, B2_COD, " + CRLF
		// alt. 28.12.2017
		_cQry += " B2_QATU SOMA_SB2, ISNULL(SUM(B8_SALDO),0) SOMA_SB8 " + CRLF
		_cQry += " FROM "+RetSqlName("SB1")+" B1  " + CRLF
		_cQry += "  JOIN "+RetSqlName("SB2")+" B2   " + CRLF
		_cQry += " 		ON B1_FILIAL='"+FWxFilial('SB1')+"' AND NOT ( B2_FILIAL = '0101005' AND B2_LOCAL='89')  AND B1_COD=B2_COD   " + CRLF
		_cQry += " 			AND B1_GRUPO IN ('01','BOV')   " + CRLF
		_cQry += " 			-- AND B1_RASTRO <> 'L' " + CRLF
		_cQry += " 			AND B1.D_E_L_E_T_=' ' AND B2.D_E_L_E_T_=' '   " + CRLF
		_cQry += "  LEFT JOIN "+RetSqlName("SB8")+" B8   " + CRLF
		_cQry += " 		ON B1_FILIAL='"+FWxFilial('SB1')+"' AND B2_FILIAL=B8_FILIAL AND B2_COD=B8_PRODUTO " + CRLF
		_cQry += " 			AND NOT ( B8_FILIAL = '0101005' AND B2_LOCAL='89')  AND B1_COD=B8_PRODUTO   " + CRLF
		_cQry += " 			AND B1_GRUPO IN ('01','BOV')   " + CRLF
		_cQry += "          AND B2_LOCAL = B8_LOCAL " +CRLF
		_cQry += " 			AND B1_X_ERA <> ' '  " + CRLF
		_cQry += " 			AND B1.D_E_L_E_T_=' '  " + CRLF
		_cQry += " 			AND B8.D_E_L_E_T_=' '   " + CRLF
		_cQry += "  " + CRLF
		_cQry += "  LEFT JOIN "+RetSqlName("Z09")+" Z9 ON Z09_FILIAL='  ' AND Z09_CODIGO=B1_XANIMAL AND Z09_ITEM=B1_XANIITE AND Z9.D_E_L_E_T_=' '   " + CRLF
		_cQry += " JOIN "+RetSqlName("NNR")+" NR ON NNR_FILIAL=B2_FILIAL AND NNR_CODIGO=B2_LOCAL AND NR.D_E_L_E_T_=' ' " + CRLF
		_cQry += " 	GROUP BY B2_FILIAL, B1_X_ERA, B2_LOCAL, NNR_DESCRI, B2_COD, B2_QATU " +  CRLF
		_cQry += "  " +  CRLF
		_cQry += " 	UNION ALL " +  CRLF
		_cQry += "  " +  CRLF
		_cQry += " 	SELECT B2_FILIAL, UPPER(RTRIM(B1_X_SEXO)) B1_X_ERA,  " +  CRLF
		_cQry += " 	B2_LOCAL, NNR_DESCRI, B2_COD, " + CRLF
		_cQry += " B2_QATU SOMA_SB2, ISNULL(SUM(B8_SALDO),0) SOMA_SB8 " + CRLF
		_cQry += " FROM "+RetSqlName("SB1")+" B1  " + CRLF
		_cQry += "  JOIN "+RetSqlName("SB2")+" B2   " + CRLF
		_cQry += " 		ON B1_FILIAL='"+FWxFilial('SB1')+"' AND NOT ( B2_FILIAL = '0101005' AND B2_LOCAL='89')  AND B1_COD=B2_COD   " + CRLF
		_cQry += " 			AND B1_GRUPO IN ('01','BOV')   " + CRLF
		_cQry += " 			AND B1_X_ERA <> ' '  " + CRLF
		_cQry += " 			AND B1.D_E_L_E_T_=' ' AND B2.D_E_L_E_T_=' '   " + CRLF
		_cQry += "  LEFT JOIN "+RetSqlName("SB8")+" B8   " + CRLF
		_cQry += " 		ON B1_FILIAL='"+FWxFilial('SB1')+"' AND B2_FILIAL=B8_FILIAL AND B2_COD=B8_PRODUTO " + CRLF
		_cQry += " 			AND NOT ( B8_FILIAL = '0101005' AND B2_LOCAL='89')  AND B1_COD=B8_PRODUTO   " + CRLF
		_cQry += "          AND B2_LOCAL = B8_LOCAL " +CRLF
		_cQry += " 			AND B1_GRUPO IN ('01','BOV')   " + CRLF
		_cQry += " 			-- AND B1_RASTRO = 'L' " + CRLF
		_cQry += " 			AND B1.D_E_L_E_T_=' '  " + CRLF
		_cQry += " 			AND B8.D_E_L_E_T_=' '   " + CRLF
		_cQry += "  " + CRLF
		_cQry += "  LEFT JOIN "+RetSqlName("Z09")+" Z9 ON Z09_FILIAL='  ' AND Z09_CODIGO=B1_XANIMAL AND Z09_ITEM=B1_XANIITE AND Z9.D_E_L_E_T_=' '   " + CRLF
		_cQry += " JOIN "+RetSqlName("NNR")+" NR ON NNR_FILIAL=B2_FILIAL AND NNR_CODIGO=B2_LOCAL  AND NR.D_E_L_E_T_=' ' " + CRLF
		_cQry += " 	GROUP BY B2_FILIAL, B1_X_SEXO,   " +  CRLF
		_cQry += " 	B2_LOCAL, NNR_DESCRI, B2_COD, B2_QATU " +  CRLF
		_cQry += " 			 " +  CRLF
		_cQry += " ), " +  CRLF
		_cQry += "  " +  CRLF
		_cQry += " PLANTEL2 AS " +  CRLF
		_cQry += " ( " +  CRLF
		_cQry += " 	SELECT B2_FILIAL+': ' + NNR_DESCRI FILIAL, UPPER(RTRIM(B1_X_ERA)) ERA, " + CRLF // SOMA " +  CRLF
		_cQry += "  CASE SOMA_SB8 " + CRLF
		_cQry += "  	WHEN 0 " + CRLF
		_cQry += "  		THEN SOMA_SB2 " + CRLF
		_cQry += "  		ELSE SOMA_SB8 " + CRLF
		_cQry += "  END SOMA " + CRLF
		_cQry += " 	FROM PLANTEL1 " +  CRLF
		_cQry += " ) " +  CRLF
		_cQry += "  " +  CRLF
		_cQry += " SELECT FILIAL, [BEZERRO MAMANDO] AS 'BEZERROMAMANDO', [BEZERRO DESMAMA] AS 'BEZERRODESMAMA', [GARROTE], [BOI], [TOURO], " + CRLF
		_cQry += " 		          [BEZERRA MAMANDO] AS 'BEZERRAMAMANDO', [BEZERRA DESMAMA] AS 'BEZERRADESMAMA', [NOVILHA], [VACA], " + CRLF
		_cQry += " 			      [MACHO], [CAPAO], [FEMEA] " +  CRLF
		_cQry += " FROM PLANTEL2  " +  CRLF
		_cQry += " PIVOT " +  CRLF
		_cQry += " ( " +  CRLF
		_cQry += " 	SUM(SOMA) " +  CRLF
		_cQry += " 	FOR ERA IN ([BEZERRO MAMANDO], [BEZERRO DESMAMA], [GARROTE], [BOI], [TOURO], " +  CRLF
		_cQry += " 			   [BEZERRA MAMANDO], [BEZERRA DESMAMA], [NOVILHA], [VACA],  " +  CRLF
		_cQry += " 			   [MACHO], [CAPAO], [FEMEA]) " +  CRLF
		_cQry += " ) AS PLANTELPIVO " +  CRLF
		_cQry += " ORDER BY 1 "
		
	Else // fQuadro1()
	
		_cQry := " WITH GERAL AS ( " +  CRLF
		_cQry += " 	SELECT DISTINCT " +  CRLF
		_cQry += " 		B2_FILIAL, B1_COD, B2_LOCAL, NNR_DESCRI, UPPER(RTRIM(B1_X_SEXO)) B1_X_SEXO,  " +  CRLF
		_cQry += " 		B1_XANIMAL,  B1_XANIITE, " +  CRLF
		_cQry += " 		CASE B1_XDATACO  " +  CRLF
		_cQry += "   			WHEN ' ' THEN 0  " +  CRLF
		_cQry += "   			ELSE DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), CONVERT(DATETIME, '"+dToS(MV_PAR01)+"', 103))   " +  CRLF
		_cQry += "   		END AS Dias, " +  CRLF
		_cQry += " 		DATEDIFF(MONTH, CONVERT(DATETIME, B1_DTNASC, 103), CONVERT(DATETIME, '"+dToS(MV_PAR01)+"', 103)) IDADE_ATUAL, " +  CRLF
		_cQry += " 		B1_RASTRO, ISNULL(B8_LOTECTL ,'') B8_LOTECTL " + CRLF
		_cQry += " FROM "+RetSqlName("SB1")+" B1  " + CRLF
		_cQry += "  JOIN "+RetSqlName("SB2")+" B2   " + CRLF
		_cQry += " 		ON B1_FILIAL='"+FWxFilial('SB1')+"' AND NOT ( B2_FILIAL = '0101005' AND B2_LOCAL='89')  AND B1_COD=B2_COD   " + CRLF
		_cQry += " 			AND B1_GRUPO IN ('01','BOV')   " + CRLF
		_cQry += " 			-- AND B1_RASTRO <> 'L' " + CRLF
		_cQry += " 			AND B1.D_E_L_E_T_=' ' AND B2.D_E_L_E_T_=' '   " + CRLF
		_cQry += "  LEFT JOIN "+RetSqlName("SB8")+" B8   " + CRLF
		_cQry += " 		ON B1_FILIAL='"+FWxFilial('SB1')+"' AND B2_FILIAL=B8_FILIAL AND B2_COD=B8_PRODUTO " + CRLF
		_cQry += " 			AND NOT ( B8_FILIAL = '0101005' AND B2_LOCAL='89')  AND B1_COD=B8_PRODUTO   " + CRLF
		_cQry += " 			AND B1_GRUPO IN ('01','BOV')   " + CRLF
		_cQry += " 			-- AND B1_RASTRO = 'L' " + CRLF
		_cQry += " 			AND B1.D_E_L_E_T_=' '  " + CRLF
		_cQry += " 			AND B8.D_E_L_E_T_=' '   " + CRLF
		_cQry += "  " + CRLF
		_cQry += "  LEFT JOIN "+RetSqlName("Z09")+" Z9 ON Z09_FILIAL='  ' AND Z09_CODIGO=B1_XANIMAL AND Z09_ITEM=B1_XANIITE AND Z9.D_E_L_E_T_=' '   " + CRLF
		_cQry += " JOIN NNR010 NR ON NNR_FILIAL=B2_FILIAL AND NNR_CODIGO=B2_LOCAL AND NR.D_E_L_E_T_=' ' " + CRLF
		_cQry += " ), " +  CRLF
		_cQry += "  " +  CRLF
	    _cQry += " PRODUTOS AS (" +CRLF
	    _cQry += "     SELECT DISTINCT D1_FILIAL, D1_COD " +CRLF
	    _cQry += "	  FROM "+RetSqlName("SD1")+" SD1" +CRLF
	    _cQry += "	 WHERE D1_DTDIGIT >= (SELECT X6_CONTEUD FROM "+RetSqlName("SX6")+" WHERE X6_VAR = 'MV_ULMES' AND X6_FIL = '"+FWxFilial('SD1')+"' AND D_E_L_E_T_ =' ' )" +CRLF
	    _cQry += "	   AND D1_GRUPO IN ('01','05','BOV','BMS')" +CRLF
	    _cQry += "	   AND SD1.D_E_L_E_T_ =' ' " +CRLF
        _cQry += "UNION ALL " + CRLF
        _cQry += "     SELECT DISTINCT B2_FILIAL, B2_COD " + CRLF
        _cQry += "	   FROM "+RetSqlName("SB2")+" SB2  " + CRLF
        _cQry += "	   JOIN "+RetSqlName("SB1")+" SB1 ON B1_COD = B2_COD AND SB1.D_E_L_E_T_ =' ' AND B1_GRUPO IN ('01','05','BOV','BMS') " + CRLF
        _cQry += "	  WHERE B2_QATU > 0  " + CRLF
        _cQry += "	    AND SB2.D_E_L_E_T_ =' '  " + CRLF
	    _cQry += "UNION ALL" +CRLF
	    _cQry += "    SELECT DISTINCT D2_FILIAL, D2_COD " +CRLF
	    _cQry += "	  FROM "+RetSqlName("SD2")+" SD2" +CRLF
	    _cQry += "	 WHERE D2_EMISSAO>= (SELECT X6_CONTEUD FROM "+RetSqlName("SX6")+" WHERE X6_VAR = 'MV_ULMES' AND X6_FIL = '"+FWxFilial('SD2')+"' AND D_E_L_E_T_ =' ' )" +CRLF
	    _cQry += "	   AND D2_GRUPO IN ('01','05','BOV','BMS')" +CRLF
	    _cQry += "	   AND SD2.D_E_L_E_T_ =' ' " +CRLF
	    _cQry += "UNION ALL " +CRLF
	    _cQry += "    SELECT DISTINCT B9_FILIAL, B9_COD " +CRLF
	    _cQry += "   	  FROM "+RetSqlName("SB9")+" SB9 " +CRLF
		_cQry += "		JOIN "+RetSqlName("SB1")+" SB1 ON " +CRLF
		_cQry += "	       B9_COD = B1_COD " +CRLF
		_cQry += "	   AND SB1.D_E_L_E_T_ =' ' " +CRLF
		_cQry += "	   AND B1_GRUPO IN ('01','05','BOV','BMS')" +CRLF
	    _cQry += "	 WHERE SB9.D_E_L_E_T_ = ' ' " +CRLF
	    _cQry += "	   AND B9_QINI > 0" +CRLF
	    _cQry += "	   --AND SUBSTRING(B9_COD,1,3) = 'BOV' " +CRLF
	    _cQry += "	   AND (" +CRLF
	    _cQry += "	     B9_DATA = ' ' OR" +CRLF
	    _cQry += "	     B9_DATA = (SELECT X6_CONTEUD FROM "+RetSqlName("SX6")+" WHERE X6_VAR = 'MV_ULMES' AND X6_FIL = '"+FWxFilial('SB9')+"' AND D_E_L_E_T_ =' ' )" +CRLF
	    _cQry += "		)" +CRLF
	    _cQry += "	UNION ALL" +CRLF
	    _cQry += "    SELECT DISTINCT D3_FILIAL, D3_COD " +CRLF
	    _cQry += "	  FROM "+RetSqlName("SD3")+" SD3" +CRLF
	    _cQry += "	 WHERE D3_GRUPO IN ('01','05','BOV','BMS')" +CRLF
	    _cQry += "	   AND D3_ESTORNO = ' ' " +CRLF
	    _cQry += "	   AND D3_EMISSAO >= (SELECT X6_CONTEUD FROM "+RetSqlName("SX6")+" WHERE X6_VAR = 'MV_ULMES' AND X6_FIL = '"+FWxFilial('SD3')+"' AND D_E_L_E_T_ =' ' )" +CRLF
	    _cQry += "	   AND SD3.D_E_L_E_T_ = ' ' " +CRLF
	    _cQry += " ), 		" +CRLF
		_cQry += " ERA_ATUALIZADA AS (  " +  CRLF
		_cQry += " 	SELECT G.*, UPPER(RTRIM(Z09_DESCRI)) B1_X_ERA " +  CRLF
		_cQry += " 	FROM GERAL G  " +  CRLF
		_cQry += " 	JOIN "+RetSqlName("Z09")+" Z9 ON Z09_FILIAL=' ' AND B1_XANIMAL=Z09_CODIGO AND Z9.D_E_L_E_T_=' '    " +  CRLF
		_cQry += " 	WHERE Z09_ITEM=B1_XANIITE --IDADE_ATUAL BETWEEN Z09_IDAINI AND Z09_IDAFIM   " +  CRLF
		_cQry += " )  " +  CRLF
		_cQry += "  " +  CRLF
		_cQry += " SELECT DISTINCT B2_FILIAL, B2_LOCAL, NNR_DESCRI, B1_X_SEXO, B1_X_ERA, B1_COD, Dias, IDADE_ATUAL, B1_RASTRO, B8_LOTECTL " +  CRLF
		_cQry += " FROM  ERA_ATUALIZADA " +  CRLF
		_cQry += " JOIN PRODUTOS ON B2_FILIAL = D1_FILIAL AND B1_COD = D1_COD  " +  CRLF /*20240503*/
		_cQry += " WHERE Dias >= 0 " +  CRLF
		_cQry += " ORDER BY B2_FILIAL, B2_LOCAL, B1_X_SEXO, B1_X_ERA, B1_COD " +  CRLF
	EndIf

	If Select(cAliaQTD) > 0
		(cAliaQTD)->(DbCloseArea())
	EndIf
	If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
		MemoWrite(StrTran(cArquivo,'.xml','')+"_Qtdade"+".sql" , _cQry)
	EndIf
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAliaQTD),.F.,.F.) 
	
	// TcSetField(cAliaQTD, "B1_XDATACO"  , "D")
	(cAliaQTD)->(DbEval({|| nRegistros++ }))
	(cAliaQTD)->( DbGoTop() )
	
RestArea(aArea)	
Return nRegistros>0 // nil


/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  02.02.2017                                                              |
 | Desc:  Precessa o custo total por ERA unificando as filiais;                   |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro2()
Local aArea := GetArea()
Local _cQry := ""

	_cQry := " WITH CustoTotal AS " + CRLF
	_cQry += " ( " + CRLF
	_cQry += " 	SELECT B1_X_ERA ERA, B2_VATU1  " + CRLF
	_cQry += " 	FROM ( " + CRLF
	_cQry += " 		SELECT B1_X_ERA, B2_VATU1 " + CRLF
	_cQry += " 		from ( " + CRLF
	_cQry += " 				SELECT UPPER(RTRIM(B1_X_ERA)) B1_X_ERA, SUM(B2_VATU1) B2_VATU1 " + CRLF
	_cQry += " 				FROM SB1010 B1  " + CRLF
	_cQry += " 					JOIN SB2010 B2  " + CRLF
	_cQry += " 						ON B1_FILIAL='"+FWxFilial('SB1')+"' AND B2_FILIAL<>' ' AND B1_COD=B2_COD  " + CRLF
	_cQry += " 							AND B1_GRUPO IN ('01','BOV')  " + CRLF
	//_cQry += " 							AND B2_QATU > 0  " + CRLF
	_cQry += " 							AND B1.D_E_L_E_T_=' ' AND B2.D_E_L_E_T_=' '  " + CRLF
	_cQry += " 					LEFT JOIN Z09010 Z9 ON Z09_FILIAL='  ' AND Z09_CODIGO=B1_XANIMAL AND Z09_ITEM=B1_XANIITE AND Z9.D_E_L_E_T_=' '  " + CRLF
	_cQry += " 				JOIN NNR010 NR ON NNR_FILIAL=B2_FILIAL AND NNR_CODIGO=B2_LOCAL AND NR.D_E_L_E_T_=' ' " + CRLF
	_cQry += " 				WHERE  " + CRLF
	_cQry += " 						B2_FILIAL <> ' ' " + CRLF
	//_cQry += " 					AND B2_QATU > 0 " + CRLF
	_cQry += " 					AND NOT ( B2_FILIAL = '0101005' AND B2_LOCAL='89') " + CRLF
	_cQry += " 					AND B2.D_E_L_E_T_=' ' " + CRLF
	_cQry += " 				GROUP BY B1_X_ERA " + CRLF
	_cQry += " 			 ) AS SOURCEPLANTEL " + CRLF
	_cQry += "  " + CRLF
	_cQry += "  			 UNION ALL " + CRLF
	_cQry += "  " + CRLF
	_cQry += " 			 SELECT B1_X_ERA, B2_VATU1 " + CRLF
	_cQry += " 			 from ( " + CRLF
	_cQry += " 			 		SELECT UPPER(RTRIM(B1_X_SEXO)) B1_X_ERA, SUM(B2_VATU1) B2_VATU1 " + CRLF
	_cQry += " 			 		FROM SB1010 B1  " + CRLF
	_cQry += " 			 			JOIN SB2010 B2  " + CRLF
	_cQry += " 			 				ON B1_FILIAL='"+FWxFilial('SB1')+"' AND B2_FILIAL<>' ' AND B1_COD=B2_COD  " + CRLF
	_cQry += " 			 					AND B1_GRUPO IN ('01','BOV')  " + CRLF
	//_cQry += " 			 					AND B2_QATU > 0  " + CRLF
	_cQry += " 			 					AND B1.D_E_L_E_T_=' ' AND B2.D_E_L_E_T_=' '  " + CRLF
	_cQry += " 			 			LEFT JOIN Z09010 Z9 ON Z09_FILIAL='  ' AND Z09_CODIGO=B1_XANIMAL AND Z09_ITEM=B1_XANIITE AND Z9.D_E_L_E_T_=' '  " + CRLF
	_cQry += " 			 		JOIN NNR010 NR ON NNR_FILIAL=B2_FILIAL AND NNR_CODIGO=B2_LOCAL AND NR.D_E_L_E_T_=' ' " + CRLF
	_cQry += " 			 		WHERE  " + CRLF
	_cQry += " 			 				B2_FILIAL <> ' ' " + CRLF
	//_cQry += " 			 			AND B2_QATU > 0 " + CRLF
	_cQry += " 						AND NOT ( B2_FILIAL = '0101005' AND B2_LOCAL='89') " + CRLF
	_cQry += " 			 			AND B2.D_E_L_E_T_=' ' " + CRLF
	_cQry += " 			 		GROUP BY B2_FILIAL, B1_X_SEXO " + CRLF
	_cQry += " 			 	) AS SOURCEPLANTEL " + CRLF
	_cQry += " 		) AS PLANTEL " + CRLF
	_cQry += " ) " + CRLF
	_cQry += "  " + CRLF
	_cQry += " SELECT [BEZERRO MAMANDO] AS 'BEZERROMAMANDO', [BEZERRO DESMAMA] AS 'BEZERRODESMAMA', [GARROTE], [BOI], [TOURO], " + CRLF
	_cQry += " 	   [BEZERRA MAMANDO] AS 'BEZERRAMAMANDO', [BEZERRA DESMAMA] AS 'BEZERRADESMAMA', [NOVILHA], [VACA],  " + CRLF
	_cQry += " 	   [MACHO], [CAPAO], [FEMEA] " + CRLF
	_cQry += " FROM CustoTotal " + CRLF
	_cQry += " PIVOT " + CRLF
	_cQry += " ( " + CRLF
	_cQry += " 	SUM(B2_VATU1) " + CRLF
	_cQry += " 	FOR ERA IN ([BEZERRO MAMANDO], [BEZERRO DESMAMA], [GARROTE], [BOI], [TOURO], " + CRLF
	_cQry += " 			   [BEZERRA MAMANDO], [BEZERRA DESMAMA], [NOVILHA], [VACA],  " + CRLF
	_cQry += " 			   [MACHO], [CAPAO], [FEMEA]) " + CRLF
	_cQry += " ) AS PLANTELPIVO " + CRLF
	//_cQry += " ORDER BY 1 "

	If Select(cAliaVATU) > 0
		(cAliaVATU)->(DbCloseArea())
	EndIf
	If cUserName == 'mbernardo'
		MemoWrite("C:\totvs_relatorios\"+cPerg+"CustoMedio"+StrTran(SubS(Time(),1,5),":","")+".sql" , _cQry)
	EndIf
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAliaVATU),.F.,.F.) 

RestArea(aArea)
Return nil


/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  03.02.2017                                                              |
 | Desc:  Precessa o custo total Standart por ERA unificando as filiais;          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro3()
Local aArea := GetArea()
Local _cQry := ""

	_cQry := " WITH CustoTotal AS " +  CRLF
	_cQry += " ( " +  CRLF
	_cQry += " 	SELECT B1_X_ERA ERA, Z09_CUSTO " +  CRLF
	_cQry += " 	FROM ( " +  CRLF
	_cQry += " 		SELECT B1_X_ERA, Z09_CUSTO " +  CRLF
	_cQry += " 		from ( " +  CRLF
	_cQry += " 				SELECT UPPER(RTRIM(B1_X_ERA)) B1_X_ERA, MIN(Z09_CUSTO) Z09_CUSTO " +  CRLF
	_cQry += " 				FROM SB1010 B1  " +  CRLF
	_cQry += " 					JOIN SB2010 B2  " +  CRLF
	_cQry += " 						ON B1_FILIAL='"+FWxFilial('SB1')+"' AND B2_FILIAL<>' ' AND B1_COD=B2_COD  " +  CRLF
	_cQry += " 							AND B1_GRUPO IN ('01','BOV')  " +  CRLF
	//_cQry += " 							AND B2_QATU > 0  " +  CRLF
	_cQry += " 							AND B1.D_E_L_E_T_=' ' AND B2.D_E_L_E_T_=' '  " +  CRLF
	_cQry += " 					LEFT JOIN Z09010 Z9 ON Z09_FILIAL='  ' AND Z09_CODIGO=B1_XANIMAL AND Z09_ITEM=B1_XANIITE AND Z9.D_E_L_E_T_=' '  " +  CRLF
	_cQry += " 				JOIN NNR010 NR ON NNR_FILIAL=B2_FILIAL AND NNR_CODIGO=B2_LOCAL AND NR.D_E_L_E_T_=' ' " +  CRLF
	_cQry += " 				WHERE  " +  CRLF
	_cQry += " 						B2_FILIAL <> ' ' " +  CRLF
	//_cQry += " 					AND B2_QATU > 0 " +  CRLF
	_cQry += " 					AND NOT ( B2_FILIAL = '0101005' AND B2_LOCAL='89') " + CRLF
	_cQry += " 					AND B2.D_E_L_E_T_=' ' " +  CRLF
	_cQry += " 				GROUP BY B1_X_ERA " +  CRLF
	_cQry += " 			 ) AS SOURCEPLANTEL " +  CRLF
	_cQry += "  " +  CRLF
	_cQry += "  			 UNION ALL " +  CRLF
	_cQry += "  " +  CRLF
	_cQry += " 			 SELECT B1_X_ERA, AVG(Z09_CUSTO) Z09_CUSTO " +  CRLF
	_cQry += " 			 from ( " +  CRLF
	_cQry += " 			 		SELECT UPPER(RTRIM(B1_X_SEXO)) B1_X_ERA, AVG(Z09_CUSTO) Z09_CUSTO " +  CRLF
	_cQry += " 			 		FROM SB1010 B1  " +  CRLF
	_cQry += " 			 			JOIN SB2010 B2  " +  CRLF
	_cQry += " 			 				ON B1_FILIAL='"+FWxFilial('SB1')+"' AND B2_FILIAL<>' ' AND B1_COD=B2_COD  " +  CRLF
	_cQry += " 			 					AND B1_GRUPO IN ('01','BOV')  " +  CRLF
	//_cQry += " 			 					AND B2_QATU > 0  " +  CRLF
	_cQry += " 			 					AND B1.D_E_L_E_T_=' ' AND B2.D_E_L_E_T_=' '  " +  CRLF
	_cQry += " 			 			LEFT JOIN Z09010 Z9 ON Z09_FILIAL='  ' AND Z09_CODIGO=B1_XANIMAL AND Z09_ITEM=B1_XANIITE AND Z9.D_E_L_E_T_=' '  " +  CRLF
	_cQry += " 			 		JOIN NNR010 NR ON NNR_FILIAL=B2_FILIAL AND NNR_CODIGO=B2_LOCAL AND NR.D_E_L_E_T_=' ' " +  CRLF
	_cQry += " 			 		WHERE  " +  CRLF
	_cQry += " 			 				B2_FILIAL <> ' ' " +  CRLF
	//_cQry += " 			 			AND B2_QATU > 0 " +  CRLF
	_cQry += " 						AND NOT ( B2_FILIAL = '0101005' AND B2_LOCAL='89') " + CRLF
	_cQry += " 			 			AND B2.D_E_L_E_T_=' ' " +  CRLF
	_cQry += " 			 		GROUP BY B2_FILIAL, B1_X_SEXO " +  CRLF
	_cQry += " 			 	) AS SOURCEPLANTEL " +  CRLF
	_cQry += " 			 	GROUP BY B1_X_ERA  " +  CRLF
	_cQry += " 		) AS PLANTEL " +  CRLF
	_cQry += " ) " +  CRLF
	_cQry += "  " +  CRLF
	_cQry += " SELECT [BEZERRO MAMANDO] AS 'BEZERROMAMANDO', [BEZERRO DESMAMA] AS 'BEZERRODESMAMA', [GARROTE], [BOI], [TOURO], " +  CRLF
	_cQry += " 	   [BEZERRA MAMANDO] AS 'BEZERRAMAMANDO', [BEZERRA DESMAMA] AS 'BEZERRADESMAMA', [NOVILHA], [VACA],  " +  CRLF
	_cQry += " 	   [MACHO], [CAPAO], [FEMEA] " +  CRLF
	_cQry += " FROM CustoTotal " +  CRLF
	_cQry += " PIVOT " +  CRLF
	_cQry += " ( " +  CRLF
	_cQry += " 	SUM(Z09_CUSTO) " +  CRLF
	_cQry += " 	FOR ERA IN ([BEZERRO MAMANDO], [BEZERRO DESMAMA], [GARROTE], [BOI], [TOURO], " +  CRLF
	_cQry += " 			   [BEZERRA MAMANDO], [BEZERRA DESMAMA], [NOVILHA], [VACA],  " +  CRLF
	_cQry += " 			   [MACHO], [CAPAO], [FEMEA]) " +  CRLF
	_cQry += " ) AS PLANTELPIVO " +  CRLF

	If Select(cAliaCSTA) > 0
		(cAliaCSTA)->(DbCloseArea())
	EndIf
	If cUserName == 'mbernardo'
		MemoWrite("C:\totvs_relatorios\"+cPerg+"CustoStandart"+StrTran(SubS(Time(),1,5),":","")+".sql" , _cQry)
	EndIf
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAliaCSTA),.F.,.F.) 

RestArea(aArea)
Return nil


/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  03.02.2017                                                              |
 | Desc:  Precessa o custo total de INSUMOS, amarrado pelos Lotes;                |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro4()
Local aArea := GetArea()
Local _cQry := ""

	If lAtual
		_cQry := "  WITH Insumos AS  " + CRLF
		_cQry += "  (  " + CRLF
		_cQry += "  	SELECT B1_X_ERA, B1_XLOTE  " + CRLF
		_cQry += "  	FROM (  " + CRLF
		_cQry += "  			SELECT B1_X_ERA, B1_XLOTE  " + CRLF
		_cQry += "  			from (  " + CRLF
		_cQry += "  					SELECT UPPER(RTRIM(B1_X_ERA)) B1_X_ERA, B1_XLOTE  " + CRLF
		_cQry += "  					FROM " + RetSqlName('SB1') + " B1   " + CRLF
		_cQry += "  						JOIN " + RetSqlName('SB2') + " B2   " + CRLF
		_cQry += "  							ON B1_FILIAL='"+FWxFilial('SB1')+"' AND B2_FILIAL<>' ' AND B1_COD=B2_COD   " + CRLF
		_cQry += "  								AND B1_GRUPO IN ('01','BOV')   " + CRLF
		_cQry += " 								AND B1_XLOTE <> ' ' " + CRLF
		// _cQry += "  								AND B2_QATU > 0   " + CRLF
		_cQry += "  								AND B1.D_E_L_E_T_=' ' AND B2.D_E_L_E_T_=' '   " + CRLF
		_cQry += "  						LEFT JOIN " + RetSqlName('Z09') + " Z9 ON Z09_FILIAL='  ' AND Z09_CODIGO=B1_XANIMAL AND Z09_ITEM=B1_XANIITE AND Z9.D_E_L_E_T_=' '   " + CRLF
		_cQry += "  					JOIN " + RetSqlName('NNR') + " NR ON NNR_FILIAL=B2_FILIAL AND NNR_CODIGO=B2_LOCAL AND NR.D_E_L_E_T_=' '  " + CRLF
		_cQry += "  					WHERE   " + CRLF
		_cQry += "  							B2_FILIAL <> ' '  " + CRLF
		// _cQry += "  						AND B2_QATU > 0  " + CRLF
		_cQry += " 							AND NOT ( B2_FILIAL = '0101005' AND B2_LOCAL='89') " + CRLF
		_cQry += "  						AND B2.D_E_L_E_T_=' '  " + CRLF
		_cQry += " 					 " + CRLF
		_cQry += "  				 ) AS SOURCEPLANTEL  " + CRLF
		_cQry += " 				 " + CRLF
		_cQry += "  " + CRLF
		_cQry += "   				 UNION ALL  " + CRLF
		_cQry += "    " + CRLF
		_cQry += "  				 SELECT B1_X_ERA, B1_XLOTE  " + CRLF
		_cQry += "  				 from (  " + CRLF
		_cQry += "  			 			SELECT UPPER(RTRIM(B1_X_SEXO)) B1_X_ERA, B1_XLOTE  " + CRLF
		_cQry += "  			 			FROM " + RetSqlName('SB1') + " B1   " + CRLF
		_cQry += "  			 				JOIN " + RetSqlName('SB2') + " B2   " + CRLF
		_cQry += "  			 					ON B1_FILIAL='"+FWxFilial('SB1')+"' AND B2_FILIAL<>' ' AND B1_COD=B2_COD   " + CRLF
		_cQry += "  			 						AND B1_GRUPO IN ('01','BOV')   " + CRLF
		_cQry += " 									AND B1_XLOTE <> ' ' " + CRLF
		// _cQry += "  			 						AND B2_QATU > 0   " + CRLF
		_cQry += "  			 						AND B1.D_E_L_E_T_=' ' AND B2.D_E_L_E_T_=' '   " + CRLF
		_cQry += "  			 				LEFT JOIN " + RetSqlName('Z09') + " Z9 ON Z09_FILIAL='  ' AND Z09_CODIGO=B1_XANIMAL AND Z09_ITEM=B1_XANIITE AND Z9.D_E_L_E_T_=' '   " + CRLF
		_cQry += "  			 			JOIN NNR010 NR ON NNR_FILIAL=B2_FILIAL AND NNR_CODIGO=B2_LOCAL AND NR.D_E_L_E_T_=' '  " + CRLF
		_cQry += "  			 			WHERE   " + CRLF
		_cQry += "  			 					B2_FILIAL <> ' '  " + CRLF
		// _cQry += "  			 				AND B2_QATU > 0  " + CRLF
		_cQry += " 								AND NOT ( B2_FILIAL = '0101005' AND B2_LOCAL='89') " + CRLF
		_cQry += "  			 				AND B2.D_E_L_E_T_=' '  " + CRLF
		_cQry += " 						 " + CRLF
		_cQry += "  			 		) AS SOURCEPLANTEL  " + CRLF
		_cQry += " 					 " + CRLF
		_cQry += "  		) AS PLANTEL  " + CRLF
		_cQry += " 		 " + CRLF
		_cQry += "  ), " + CRLF
		_cQry += "  " + CRLF
		_cQry += "  Custo AS ( " + CRLF
		_cQry += " 	SELECT  " + CRLF
		_cQry += " 		CT.B1_X_ERA, SUM(B2_VATU1) B2_VATU1 " + CRLF
		_cQry += " 	FROM Insumos CT " + CRLF
		_cQry += " 	JOIN " + RetSqlName('SB1') + " B1 ON B1_FILIAL=' ' AND B1.B1_XLOTE=CT.B1_XLOTE AND B1_GRUPO IN ('LOTE') AND B1.D_E_L_E_T_=' ' " + CRLF
		_cQry += " 	JOIN " + RetSqlName('SB2') + " B2 ON B2_FILIAL<>' ' AND B1_COD=B2_COD  AND B2_VATU1 > 0  AND B2.D_E_L_E_T_=' '   " + CRLF
		_cQry += " 	GROUP BY CT.B1_X_ERA " + CRLF
		_cQry += "  )  " + CRLF
		_cQry += "    " + CRLF
		_cQry += "  SELECT [BEZERRO MAMANDO] AS 'BEZERROMAMANDO', [BEZERRO DESMAMA] AS 'BEZERRODESMAMA', [GARROTE], [BOI], [TOURO],  " + CRLF
		_cQry += "  	   [BEZERRA MAMANDO] AS 'BEZERRAMAMANDO', [BEZERRA DESMAMA] AS 'BEZERRADESMAMA', [NOVILHA], [VACA],   " + CRLF
		_cQry += "  	   [MACHO], [CAPAO], [FEMEA]  " + CRLF
		_cQry += "  FROM Custo " + CRLF
		_cQry += "  PIVOT  " + CRLF
		_cQry += "  (  " + CRLF
		_cQry += "  	SUM(B2_VATU1)  " + CRLF
		_cQry += "  	FOR B1_X_ERA IN ([BEZERRO MAMANDO], [BEZERRO DESMAMA], [GARROTE], [BOI], [TOURO],  " + CRLF
		_cQry += "  			   [BEZERRA MAMANDO], [BEZERRA DESMAMA], [NOVILHA], [VACA],   " + CRLF
		_cQry += "  			   [MACHO], [CAPAO], [FEMEA])  " + CRLF
		_cQry += "  ) AS PLANTELPIVO  "
		
	Else // fQuadro4()
		
		_cQry := " WITH GERAL AS ( " +  CRLF
		_cQry += " 	SELECT DISTINCT " +  CRLF
		_cQry += " 		B2_FILIAL, B1_COD, B2_LOCAL, NNR_DESCRI, UPPER(RTRIM(B1_X_SEXO)) B1_X_SEXO,  " +  CRLF
		_cQry += " 		B1_XANIMAL, " +  CRLF
		_cQry += " 		CASE B1_XDATACO  " +  CRLF
		_cQry += "   			WHEN ' ' THEN 0  " +  CRLF
		_cQry += "   			ELSE DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), CONVERT(DATETIME, '"+dToS(MV_PAR01)+"', 103))   " +  CRLF
		_cQry += "   		END AS Dias, " +  CRLF
		_cQry += " 		DATEDIFF(MONTH, CONVERT(DATETIME, B1_DTNASC, 103), CONVERT(DATETIME, '"+dToS(MV_PAR01)+"', 103)) IDADE_ATUAL, " +  CRLF
		_cQry += " 		B1_XLOTE " + CRLF
		_cQry += " 	FROM SB1010 B1  " +  CRLF
		_cQry += "  	JOIN SB2010 B2 ON B1_FILIAL=' ' AND B2_FILIAL<>' ' AND B1_COD=B2_COD   " +  CRLF
		_cQry += "  				  AND B1_GRUPO IN ('01','BOV')   " +  CRLF
		_cQry += "  				  AND B1.D_E_L_E_T_=' ' AND B2.D_E_L_E_T_=' '   " +  CRLF
		_cQry += "  	LEFT JOIN Z09010 Z9 ON Z09_FILIAL='  ' AND Z09_CODIGO=B1_XANIMAL AND Z09_ITEM=B1_XANIITE AND Z9.D_E_L_E_T_=' '   " +  CRLF
		_cQry += " 	JOIN NNR010 NR ON NNR_FILIAL=B2_FILIAL AND NNR_CODIGO=B2_LOCAL AND NR.D_E_L_E_T_=' '  " +  CRLF
		_cQry += " 	WHERE B2_FILIAL <> ' ' AND NOT (B2_FILIAL = '0101005' AND B2_LOCAL='89') " +  CRLF
		_cQry += " ), " +  CRLF
		_cQry += "  " +  CRLF
		_cQry += " ERA_ATUALIZADA AS (  " +  CRLF
		_cQry += " 	SELECT G.*, UPPER(RTRIM(Z09_DESCRI)) B1_X_ERA " +  CRLF
		_cQry += " 	FROM GERAL G  " +  CRLF
		_cQry += " 	JOIN Z09010 Z9 ON Z09_FILIAL=' ' AND B1_XANIMAL=Z09_CODIGO AND Z9.D_E_L_E_T_=' '    " +  CRLF
		_cQry += " 	WHERE IDADE_ATUAL BETWEEN Z09_IDAINI AND Z09_IDAFIM   " +  CRLF
		_cQry += " )  " +  CRLF
		_cQry += "  " +  CRLF
		_cQry += " SELECT B2_FILIAL, B2_LOCAL, NNR_DESCRI, B1_X_SEXO, B1_X_ERA, B1_COD, Dias, IDADE_ATUAL, B1_XLOTE " +  CRLF
		_cQry += " FROM  ERA_ATUALIZADA " +  CRLF
		_cQry += " WHERE Dias >= 0 " +  CRLF
		_cQry += " ORDER BY B2_FILIAL, B2_LOCAL, B1_X_SEXO, B1_X_ERA, B1_COD " +  CRLF
		
	EndIf

	If Select(cAliaINSU) > 0
		(cAliaINSU)->(DbCloseArea())
	EndIf
	If cUserName == 'mbernardo'
		MemoWrite("C:\totvs_relatorios\"+cPerg+"CustoInsumos"+StrTran(SubS(Time(),1,5),":","")+".sql" , _cQry)
	EndIf
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAliaINSU),.F.,.F.) 

RestArea(aArea)
Return nil


/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  02.02.2017                                                              |
 | Desc:  Processa informaçao de quantidade dos bois por ERA, para a filial do 	  |
 |        Sr. Branco;                                                             |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro5()
Local aArea := GetArea()
Local _cQry := ""

	If lAtual
		_cQry := " WITH PLANTEL1 AS " +  CRLF
		_cQry += " ( " +  CRLF
		_cQry += " 	SELECT B2_FILIAL, B1_X_ERA,  " +  CRLF
		_cQry += " 	B2_LOCAL, NNR_DESCRI, " + CRLF
		// alt. 28.12.2017
		_cQry += " B2_QATU SOMA_SB2, ISNULL(SUM(B8_SALDO),0) SOMA_SB8 " + CRLF
		_cQry += " FROM SB1010 B1  " + CRLF
		_cQry += "  JOIN SB2010 B2   " + CRLF
		_cQry += " 		ON B1_FILIAL='"+FWxFilial('SB1')+"' AND ( B2_FILIAL = '0101005' AND B2_LOCAL='89')  AND B1_COD=B2_COD   " + CRLF
		_cQry += " 			AND B1_GRUPO IN ('01','BOV')   " + CRLF
		_cQry += " 			-- AND B1_RASTRO <> 'L' " + CRLF
		_cQry += " 			AND B1.D_E_L_E_T_=' ' AND B2.D_E_L_E_T_=' '   " + CRLF
		_cQry += "  LEFT JOIN SB8010 B8   " + CRLF
		_cQry += " 		ON B1_FILIAL='"+FWxFilial('SB1')+"' AND B2_FILIAL=B8_FILIAL AND B2_COD=B8_PRODUTO " + CRLF
		_cQry += "          AND B2_LOCAL = B8_LOCAL " +CRLF
		_cQry += " 			AND ( B8_FILIAL = '0101005' AND B2_LOCAL='89')  AND B1_COD=B8_PRODUTO   " + CRLF
		_cQry += " 			AND B1_GRUPO IN ('01','BOV')   " + CRLF
		_cQry += " 			-- AND B1_RASTRO = 'L' " + CRLF
		_cQry += " 			AND B1.D_E_L_E_T_=' '  " + CRLF
		_cQry += " 			AND B8.D_E_L_E_T_=' '   " + CRLF
		_cQry += "  " + CRLF
		_cQry += "  LEFT JOIN Z09010 Z9 ON Z09_FILIAL='  ' AND Z09_CODIGO=B1_XANIMAL AND Z09_ITEM=B1_XANIITE AND Z9.D_E_L_E_T_=' '   " + CRLF
		_cQry += " JOIN NNR010 NR ON NNR_FILIAL=B2_FILIAL AND NNR_CODIGO=B2_LOCAL AND NR.D_E_L_E_T_=' ' " + CRLF
		_cQry += " 	GROUP BY B2_FILIAL, B1_X_ERA, B2_LOCAL, NNR_DESCRI, B2_QATU " +  CRLF
		_cQry += "  " +  CRLF
		_cQry += " 	UNION ALL " +  CRLF
		_cQry += "  " +  CRLF
		_cQry += " 	SELECT B2_FILIAL, UPPER(RTRIM(B1_X_SEXO)) B1_X_ERA,  " +  CRLF
		_cQry += " 	B2_LOCAL, NNR_DESCRI, " + CRLF
		_cQry += " B2_QATU SOMA_SB2, ISNULL(SUM(B8_SALDO),0) SOMA_SB8 " + CRLF
		_cQry += " FROM SB1010 B1  " + CRLF
		_cQry += "  JOIN SB2010 B2   " + CRLF
		_cQry += " 		ON B1_FILIAL='"+FWxFilial('SB1')+"' AND ( B2_FILIAL = '0101005' AND B2_LOCAL='89')  AND B1_COD=B2_COD   " + CRLF
		_cQry += " 			AND B1_GRUPO IN ('01','BOV')   " + CRLF
		_cQry += " 			-- AND B1_RASTRO <> 'L' " + CRLF
		_cQry += " 			AND B1.D_E_L_E_T_=' ' AND B2.D_E_L_E_T_=' '   " + CRLF
		_cQry += "  LEFT JOIN SB8010 B8   " + CRLF
		_cQry += " 		ON B1_FILIAL='"+FWxFilial('SB1')+"' AND B2_FILIAL=B8_FILIAL AND B2_COD=B8_PRODUTO " + CRLF
		_cQry += " 			AND ( B8_FILIAL = '0101005' AND B2_LOCAL='89')  AND B1_COD=B8_PRODUTO   " + CRLF
		_cQry += "          AND B2_LOCAL = B8_LOCAL " +CRLF
		_cQry += " 			AND B1_GRUPO IN ('01','BOV')   " + CRLF
		_cQry += " 			-- AND B1_RASTRO = 'L' " + CRLF
		_cQry += " 			AND B1.D_E_L_E_T_=' '  " + CRLF
		_cQry += " 			AND B8.D_E_L_E_T_=' '   " + CRLF
		_cQry += "  " + CRLF
		_cQry += "  LEFT JOIN Z09010 Z9 ON Z09_FILIAL='  ' AND Z09_CODIGO=B1_XANIMAL AND Z09_ITEM=B1_XANIITE AND Z9.D_E_L_E_T_=' '   " + CRLF
		_cQry += " JOIN NNR010 NR ON NNR_FILIAL=B2_FILIAL AND NNR_CODIGO=B2_LOCAL AND NR.D_E_L_E_T_=' ' " + CRLF
		_cQry += " 	GROUP BY B2_FILIAL, B1_X_SEXO,  " +  CRLF
		_cQry += " 	B2_LOCAL, NNR_DESCRI, B2_QATU " +  CRLF
		_cQry += " 			 " +  CRLF
		_cQry += " ), " +  CRLF
		_cQry += "  " +  CRLF
		_cQry += " PLANTEL2 AS " +  CRLF
		_cQry += " ( " +  CRLF
		_cQry += " 	SELECT B2_FILIAL+': ' + NNR_DESCRI FILIAL, UPPER(RTRIM(B1_X_ERA)) ERA, " + CRLF // SOMA " +  CRLF
		_cQry += "  CASE SOMA_SB8 " + CRLF
		_cQry += "  	WHEN 0 " + CRLF
		_cQry += "  		THEN SOMA_SB2 " + CRLF
		_cQry += "  		ELSE SOMA_SB8 " + CRLF
		_cQry += "  END SOMA " + CRLF
		_cQry += " 	FROM PLANTEL1 " +  CRLF
		_cQry += " ) " +  CRLF
		_cQry += "  " +  CRLF
		_cQry += " SELECT FILIAL, [BEZERRO MAMANDO] AS 'BEZERROMAMANDO', [BEZERRO DESMAMA] AS 'BEZERRODESMAMA', [GARROTE], [BOI], [TOURO], " + CRLF
		_cQry += " 		          [BEZERRA MAMANDO] AS 'BEZERRAMAMANDO', [BEZERRA DESMAMA] AS 'BEZERRADESMAMA', [NOVILHA], [VACA], " + CRLF
		_cQry += " 			      [MACHO], [CAPAO], [FEMEA] " +  CRLF
		_cQry += " FROM PLANTEL2  " +  CRLF
		_cQry += " PIVOT " +  CRLF
		_cQry += " ( " +  CRLF
		_cQry += " 	SUM(SOMA) " +  CRLF
		_cQry += " 	FOR ERA IN ([BEZERRO MAMANDO], [BEZERRO DESMAMA], [GARROTE], [BOI], [TOURO], " +  CRLF
		_cQry += " 			   [BEZERRA MAMANDO], [BEZERRA DESMAMA], [NOVILHA], [VACA],  " +  CRLF
		_cQry += " 			   [MACHO], [CAPAO], [FEMEA]) " +  CRLF
		_cQry += " ) AS PLANTELPIVO " +  CRLF
		_cQry += " ORDER BY 1 "

	Else // fQuadro5()

		_cQry := " WITH GERAL AS ( " +  CRLF
		_cQry += " 	SELECT DISTINCT " +  CRLF
		_cQry += " 		B2_FILIAL, B1_COD, B2_LOCAL, NNR_DESCRI, UPPER(RTRIM(B1_X_SEXO)) B1_X_SEXO,  " +  CRLF
		_cQry += " 		B1_XANIMAL, " +  CRLF
		_cQry += " 		CASE B1_XDATACO  " +  CRLF
		_cQry += "   			WHEN ' ' THEN 0  " +  CRLF
		_cQry += "   			ELSE DATEDIFF(DAY, CONVERT(DATETIME, B1_XDATACO, 103), CONVERT(DATETIME, '"+dToS(MV_PAR01)+"', 103))   " +  CRLF
		_cQry += "   		END AS Dias, " +  CRLF
		_cQry += " 		DATEDIFF(MONTH, CONVERT(DATETIME, B1_DTNASC, 103), CONVERT(DATETIME, '"+dToS(MV_PAR01)+"', 103)) IDADE_ATUAL, " +  CRLF
		_cQry += " 		B1_RASTRO, ISNULL(B8_LOTECTL ,'') B8_LOTECTL " + CRLF
		_cQry += " FROM SB1010 B1  " + CRLF
		_cQry += "  JOIN SB2010 B2   " + CRLF
		_cQry += " 		ON B1_FILIAL='"+FWxFilial('SB1')+"' AND ( B2_FILIAL = '0101005' AND B2_LOCAL='89')  AND B1_COD=B2_COD   " + CRLF
		_cQry += " 			AND B1_GRUPO IN ('01','BOV')   " + CRLF
		_cQry += " 			-- AND B1_RASTRO <> 'L' " + CRLF
		_cQry += " 			AND B1.D_E_L_E_T_=' ' AND B2.D_E_L_E_T_=' '   " + CRLF
		_cQry += "  LEFT JOIN SB8010 B8   " + CRLF
		_cQry += " 		ON B1_FILIAL='"+FWxFilial('SB1')+"' AND B2_FILIAL=B8_FILIAL AND B2_COD=B8_PRODUTO " + CRLF
		_cQry += " 			AND  ( B8_FILIAL = '0101005' AND B2_LOCAL='89')  AND B1_COD=B8_PRODUTO   " + CRLF
		_cQry += " 			AND B1_GRUPO IN ('01','BOV')   " + CRLF
		_cQry += " 			-- AND B1_RASTRO = 'L' " + CRLF
		_cQry += " 			AND B1.D_E_L_E_T_=' '  " + CRLF
		_cQry += " 			AND B8.D_E_L_E_T_=' '   " + CRLF
		_cQry += "  " + CRLF
		_cQry += "  LEFT JOIN Z09010 Z9 ON Z09_FILIAL='  ' AND Z09_CODIGO=B1_XANIMAL AND Z09_ITEM=B1_XANIITE AND Z9.D_E_L_E_T_=' '   " + CRLF
		_cQry += " JOIN NNR010 NR ON NNR_FILIAL=B2_FILIAL AND NNR_CODIGO=B2_LOCAL AND NR.D_E_L_E_T_=' ' " + CRLF
		_cQry += " ), " +  CRLF
		_cQry += "  " +  CRLF
		_cQry += " ERA_ATUALIZADA AS (  " +  CRLF
		_cQry += " 	SELECT G.*, UPPER(RTRIM(Z09_DESCRI)) B1_X_ERA " +  CRLF
		_cQry += " 	FROM GERAL G  " +  CRLF
		_cQry += " 	JOIN Z09010 Z9 ON Z09_FILIAL=' ' AND B1_XANIMAL=Z09_CODIGO AND Z9.D_E_L_E_T_=' '    " +  CRLF
		_cQry += " 	WHERE IDADE_ATUAL BETWEEN Z09_IDAINI AND Z09_IDAFIM   " +  CRLF
		_cQry += " )  " +  CRLF
		_cQry += "  " +  CRLF
		_cQry += " SELECT B2_FILIAL, B2_LOCAL, NNR_DESCRI, B1_X_SEXO, B1_X_ERA, B1_COD, Dias, IDADE_ATUAL, B1_RASTRO, B8_LOTECTL " +  CRLF
		_cQry += " FROM  ERA_ATUALIZADA " +  CRLF
		_cQry += " WHERE Dias >= 0 " +  CRLF
		_cQry += " ORDER BY B2_FILIAL, B2_LOCAL, B1_X_SEXO, B1_X_ERA, B1_COD " +  CRLF
	EndIf

	If Select(cAliaBRAN) > 0
		(cAliaBRAN)->(DbCloseArea())
	EndIf
	If lower(cUserName) $ 'bernardo,mbernardo,atoshio,admin,administrador'
		MemoWrite(StrTran(cArquivo,'.xml','')+"_SrBranco"+".sql" , _cQry)
	EndIf
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAliaBRAN),.F.,.F.) 
	
	// TcSetField(cAliaBRAN, "B1_XDATACO"  , "D")
	(cAliaBRAN)->(DbEval({|| nRegistros++ }))
	(cAliaBRAN)->( DbGoTop() )

RestArea(aArea)
Return nRegistros>0 // nil


/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  02.02.2017                                                              |
 | Desc:  Precessa o custo total por ERA unificando somente da Filial Sr. Branco; |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function fQuadro6()
Local aArea := GetArea()
Local _cQry := ""

	_cQry := " WITH CustoTotal AS " + CRLF
	_cQry += " ( " + CRLF
	_cQry += " 	SELECT B1_X_ERA ERA, B2_VATU1  " + CRLF
	_cQry += " 	FROM ( " + CRLF
	_cQry += " 		SELECT B1_X_ERA, B2_VATU1 " + CRLF
	_cQry += " 		from ( " + CRLF
	_cQry += " 				SELECT UPPER(RTRIM(B1_X_ERA)) B1_X_ERA, SUM(B2_VATU1) B2_VATU1 " + CRLF
	_cQry += " 				FROM SB1010 B1  " + CRLF
	_cQry += " 					JOIN SB2010 B2  " + CRLF
	_cQry += " 						ON B1_FILIAL='"+FWxFilial('SB1')+"' AND B2_FILIAL<>' ' AND B1_COD=B2_COD  " + CRLF
	_cQry += " 							AND B1_GRUPO IN ('01','BOV')  " + CRLF
	// _cQry += " 							AND B2_QATU > 0  " + CRLF
	_cQry += " 							AND B1.D_E_L_E_T_=' ' AND B2.D_E_L_E_T_=' '  " + CRLF
	_cQry += " 					LEFT JOIN Z09010 Z9 ON Z09_FILIAL='  ' AND Z09_CODIGO=B1_XANIMAL AND Z09_ITEM=B1_XANIITE AND Z9.D_E_L_E_T_=' '  " + CRLF
	_cQry += " 				JOIN NNR010 NR ON NNR_FILIAL=B2_FILIAL AND NNR_CODIGO=B2_LOCAL AND NR.D_E_L_E_T_=' ' " + CRLF
	_cQry += " 				WHERE  " + CRLF
	_cQry += " 						B2_FILIAL <> ' ' " + CRLF
	// _cQry += " 					AND B2_QATU > 0 " + CRLF
	_cQry += " 					AND ( B2_FILIAL = '0101005' AND B2_LOCAL='89') " + CRLF
	_cQry += " 					AND B2.D_E_L_E_T_=' ' " + CRLF
	_cQry += " 				GROUP BY B1_X_ERA " + CRLF
	_cQry += " 			 ) AS SOURCEPLANTEL " + CRLF
	_cQry += "  " + CRLF
	_cQry += "  			 UNION ALL " + CRLF
	_cQry += "  " + CRLF
	_cQry += " 			 SELECT B1_X_ERA, B2_VATU1 " + CRLF
	_cQry += " 			 from ( " + CRLF
	_cQry += " 			 		SELECT UPPER(RTRIM(B1_X_SEXO)) B1_X_ERA, SUM(B2_VATU1) B2_VATU1 " + CRLF
	_cQry += " 			 		FROM SB1010 B1  " + CRLF
	_cQry += " 			 			JOIN SB2010 B2  " + CRLF
	_cQry += " 			 				ON B1_FILIAL='"+FWxFilial('SB1')+"' AND B2_FILIAL<>' ' AND B1_COD=B2_COD  " + CRLF
	_cQry += " 			 					AND B1_GRUPO IN ('01','BOV')  " + CRLF
	// _cQry += " 			 					AND B2_QATU > 0  " + CRLF
	_cQry += " 			 					AND B1.D_E_L_E_T_=' ' AND B2.D_E_L_E_T_=' '  " + CRLF
	_cQry += " 			 			LEFT JOIN Z09010 Z9 ON Z09_FILIAL='  ' AND Z09_CODIGO=B1_XANIMAL AND Z09_ITEM=B1_XANIITE AND Z9.D_E_L_E_T_=' '  " + CRLF
	_cQry += " 			 		JOIN NNR010 NR ON NNR_FILIAL=B2_FILIAL AND NNR_CODIGO=B2_LOCAL AND NR.D_E_L_E_T_=' ' " + CRLF
	_cQry += " 			 		WHERE  " + CRLF
	_cQry += " 			 				B2_FILIAL <> ' ' " + CRLF
	// _cQry += " 			 			AND B2_QATU > 0 " + CRLF
	_cQry += " 						AND ( B2_FILIAL = '0101005' AND B2_LOCAL='89') " + CRLF
	_cQry += " 			 			AND B2.D_E_L_E_T_=' ' " + CRLF
	_cQry += " 			 		GROUP BY B2_FILIAL, B1_X_SEXO " + CRLF
	_cQry += " 			 	) AS SOURCEPLANTEL " + CRLF
	_cQry += " 		) AS PLANTEL " + CRLF
	_cQry += " ) " + CRLF
	_cQry += "  " + CRLF
	_cQry += " SELECT [BEZERRO MAMANDO] AS 'BEZERROMAMANDO', [BEZERRO DESMAMA] AS 'BEZERRODESMAMA', [GARROTE], [BOI], [TOURO], " + CRLF
	_cQry += " 	   [BEZERRA MAMANDO] AS 'BEZERRAMAMANDO', [BEZERRA DESMAMA] AS 'BEZERRADESMAMA', [NOVILHA], [VACA],  " + CRLF
	_cQry += " 	   [MACHO], [CAPAO], [FEMEA] " + CRLF
	_cQry += " FROM CustoTotal " + CRLF
	_cQry += " PIVOT " + CRLF
	_cQry += " ( " + CRLF
	_cQry += " 	SUM(B2_VATU1) " + CRLF
	_cQry += " 	FOR ERA IN ([BEZERRO MAMANDO], [BEZERRO DESMAMA], [GARROTE], [BOI], [TOURO], " + CRLF
	_cQry += " 			   [BEZERRA MAMANDO], [BEZERRA DESMAMA], [NOVILHA], [VACA],  " + CRLF
	_cQry += " 			   [MACHO], [CAPAO], [FEMEA]) " + CRLF
	_cQry += " ) AS PLANTELPIVO " + CRLF
	//_cQry += " ORDER BY 1 "

	If Select(cAliaCUBR) > 0
		(cAliaCUBR)->(DbCloseArea())
	EndIf
	If cUserName == 'mbernardo'
		MemoWrite("C:\totvs_relatorios\"+cPerg+"CustoMedioSrBranco"+StrTran(SubS(Time(),1,5),":","")+".sql" , _cQry)
	EndIf
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(cAliaCUBR),.F.,.F.) 

RestArea(aArea)
Return nil

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  21.02.2017                                                              |
 | Desc:                                                                          |
 |                                                                                |
 | Obs.:  -                                                                       |
 '--------------------------------------------------------------------------------*/
Static Function GeraX1(cPerg)

Local _aArea	:= GetArea()
Local aRegs     := {}
Local nX		:= 0
Local i         := 0
Local j         := 0
Local nPergs	:= 0
Local aRegs		:= {}

//Conta quantas perguntas existem ualmente.
DbSelectArea('SX1')
DbSetOrder(1)
SX1->(DbGoTop())
If SX1->(DbSeek(cPerg))
	While !SX1->(Eof()) .And. X1_GRUPO = cPerg
		nPergs++
		SX1->(DbSkip())
	EndDo
EndIf

aAdd(aRegs,{cPerg,"01","Dt. Referencia:            ","","","MV_CH1","D",TamSX3("B1_DTNASC")[1],0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","@!"})
//AADD(aRegs,{cPerg,"05","Considera Devolução?","","","mv_ch5","C",03,0,2,"C","","mv_par05","Sim","","","","","Não","","","","","","","","","","","","","","","","","","","","U","","","",""})

//Se quantidade de perguntas for diferente, apago todas
SX1->(DbGoTop())  
If nPergs <> Len(aRegs)
	For nX:=1 To nPergs
		If SX1->(DbSeek(cPerg))		
			If RecLock('SX1',.F.)
				SX1->(DbDelete())
				SX1->(MsUnlock())
			EndIf
		EndIf
	Next nX
EndIf

// gravação das perguntas na tabela SX1
If nPergs <> Len(aRegs)
	dbSelectArea("SX1")
	dbSetOrder(1)
	For i := 1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
				For j := 1 to FCount()
					If j <= Len(aRegs[i])
						FieldPut(j,aRegs[i,j])
					Endif
				Next j
			MsUnlock()
		EndIf
	Next i
EndIf

RestArea(_aArea)

Return nil
