#include "protheus.ch"
#Include "Fileio.ch"

/*--------------------------------------------------------------------------------,
 | Func:  			                                                              |
 | Autor: Miguel Martins Bernardo Junior                                          |
 | Data:  21.07.2020                                                              |
 | Desc:  Processamento de Notas fiscais nao escrituradas;                        |
 |                                                                                |
 | Obs.:  Leitura de arquvio CSV; Localizar em nosso banco de dados nota fiscal   |
 |	      Não lançada em nosso ambiente                                           |
 |--------------------------------------------------------------------------------|
 | Exec:  U_EscritEFD()                                                           |
 |--------------------------------------------------------------------------------*/
User Function EscritEFD() // U_EscritEFD()
Local cNomeFile     := "" // "c:\temp\notasfiscaisefd.csv"
local aDados        := {}
//Local aResult     := {}
Local lTemResul     := .T.
Local nI            := 0// , nJ := 0

Private cPerg       := "EscritEFD"
Private cWorkSheet  := "NF Nao Escrituradas"
Private cTitulo     := "Relatório Notas fiscais Não Escrituradas conforme arquivo fornecido pela SEFAZ"

Private cArquivo    := "" // "c:\temp\notasfiscaisEFDresultado.xml"
Private oExcelApp   := nil
Private oExcel      := FWMSExcel():New()

Private nPChvNFE    := 0
Private nPDtEmissao := 0
Private nPUF        := 0
Private nCNPJ       := 0
Private nDocum      := 0
Private nSerie      := 0
Private nPVlrNF     := 0
Private nPBaseICMS  := 0
Private nPVlrICMS   := 0
Private nCpf        := 0
pRIVATE nNomeFor    := 0

    GeraSX1( )
    If !Pergunte( cPerg, .T.)
        Return 
    EndIf

    If MV_PAR04 == 1
        nPChvNFE    := 1
        nCNPJ       := 2
        nDocum      := 3
        nSerie      := 4
        nPDtEmissao := 5
        nPUF        := 6
        nPVlrNF     := 7
        nPBaseICMS  := 8
        nPVlrICMS   := 9
    
    Else // If MV_PAR04 == 2
        nPChvNFE    := 7//nPChvNFE    := 7
        nCNPJ       := 20//nCNPJ       := 21
        nCpf        := 21//nCpf        := 22
        nDocum      := 13//nDocum      := 13
        nSerie      := 19//nSerie      := 19
        //nPDtEmissao := 20//nPDtEmissao := 20
        nNomeFor    := 22//nNomeFor    := 23
        //nModelo     := 14//nModelo     := 14
        // nPUF//// nPUF
        nPVlrNF     := 23//nPVlrNF     := 24
    EndIf

    if !Empty(MV_PAR01)
        cNomeFile := AllTrim(MV_PAR01)
    EndIf
    if !Empty(MV_PAR02) .and. !Empty(MV_PAR03)
        cArquivo := AllTrim(MV_PAR02)+Alltrim(MV_PAR03) + iIf( At(".XNL",Upper(MV_PAR03))>0, "", ".XML" )
    EndIf

    MsgRun("Executando a leitura do arquivo, por favor aguarde ...", "Processando",;
                    {|| aDados := U_ImpFile(@cNomeFile) } )

    oExcel:SetFont('Arial Narrow')
    oExcel:SetBgColorHeader("#37752F") // cor de fundo linha cabeçalho
    oExcel:SetLineBgColor("#FFFFFF")   // cor da linha 1
    oExcel:Set2LineBgColor("#FFFFFF")  // cor da linha 2
        
    oExcel:AddworkSheet(cWorkSheet) 
    oExcel:AddTable( cWorkSheet, cTitulo)

    // FWMsExcelEx():AddColumn(< cWorkSheet >, < cTable >, < cColumn >, < nAlign >, < nFormat >, < lTotal >)-> NIL
    // nAlign	Numérico	Alinhamento da coluna ( 1-Left,2-Center,3-Right )	
	// nFormat	Numérico	Codigo de formatação ( 1-General,2-Number,3-Monetário,4-DateTime )
    /*01*/ oExcel:AddColumn( cWorkSheet, cTitulo, "Item"		    , 1, 1 ) 
    /*02*/ oExcel:AddColumn( cWorkSheet, cTitulo, "Sub-item"		, 1, 1 ) 
    /*03*/ oExcel:AddColumn( cWorkSheet, cTitulo, "Chave Arq."		, 1, 1 ) 
    /*04*/ oExcel:AddColumn( cWorkSheet, cTitulo, "CNPJ Arq."		, 1, 1 ) 
    /*05*/ oExcel:AddColumn( cWorkSheet, cTitulo, "Nome FOrnecedor"	, 1, 1 ) 
    /*06*/ oExcel:AddColumn( cWorkSheet, cTitulo, "NF. Arq."		, 1, 1 ) 
    /*07*/ oExcel:AddColumn( cWorkSheet, cTitulo, "Serie Arq."		, 1, 1 ) 
    /*08*/ oExcel:AddColumn( cWorkSheet, cTitulo, "Data Arq."		, 1, 4 )     
    /*09*/ oExcel:AddColumn( cWorkSheet, cTitulo, "UF"		     	, 1, 1 )     
    /*10*/ oExcel:AddColumn( cWorkSheet, cTitulo, "Valor Arq."		, 3, 3 )     
    /*11*/ oExcel:AddColumn( cWorkSheet, cTitulo, "Base ICMS"       , 3, 3 )     
    /*12*/ oExcel:AddColumn( cWorkSheet, cTitulo, "Valor ICMS"      , 3, 3 )     
    /*13*/ oExcel:AddColumn( cWorkSheet, cTitulo, "Chave NF V@"		, 1, 1 ) 
    /*14*/ oExcel:AddColumn( cWorkSheet, cTitulo, "Num NF V@"		, 1, 1 )
    /*15*/ oExcel:AddColumn( cWorkSheet, cTitulo, "Série NF V@"		, 1, 1 )
    /*16*/ oExcel:AddColumn( cWorkSheet, cTitulo, "Emissao NF V@"   , 1, 4 )
    /*17*/ oExcel:AddColumn( cWorkSheet, cTitulo, "Valor NF V@"     , 3, 3 )
    /*18*/ oExcel:AddColumn( cWorkSheet, cTitulo, "Fornecedor V@"   , 1, 1 )
    /*19*/ oExcel:AddColumn( cWorkSheet, cTitulo, "CNPJ V@"         , 1, 1 )
    /*20*/ oExcel:AddColumn( cWorkSheet, cTitulo, "Mensagem NF V@"  , 1, 1 )
    /*21*/ oExcel:AddColumn( cWorkSheet, cTitulo, "Status"          , 1, 1 )

    For nI := 2 to Len(aDados)

        ConOut( cValtoChar(nI) + ": " + U_AtoS(aDados[nI]) )
        // durante desenvolvimento
        //If nI > 4
        //    Exit
        //EndIf
    
        if !Empty(aDados[nI, nCNPJ]) 
            lTemResul := ConsultaSQL(aDados[nI], 'CGC', nI-1) // aResult := ConsultaSQL(aDados[nI], 'CGC')
        Else
            lTemResul := .F.
        EndIf
        If !lTemResul   // If Empty(aResult)
            lTemResul := ConsultaSQL(aDados[nI], 'DOC_E_DATA', nI-1) // aResult := ConsultaSQL(aDados[nI], 'DOC_E_DATA')
        EndIf
        If !lTemResul .and. len(AllTrim(aDados[nI, nDocum]))>3
            lTemResul := ConsultaSQL(aDados[nI], 'MENNOTA', nI-1) // aResult := ConsultaSQL(aDados[nI], 'DOC_E_DATA')
        EndIf
                If !lTemResul .and. len(AllTrim(aDados[nI, nDocum]))>3
            lTemResul := ConsultaSQL(aDados[nI], 'DEVOLUCAO', nI-1) // aResult := ConsultaSQL(aDados[nI], 'DOC_E_DATA')
        EndIf

        // impressa da linha do arquivo CSV qdo nao encontrado no BANCO DE DADOS;
        If !lTemResul
            oExcel:AddRow( cWorkSheet, cTitulo,;
            /* 01 */                 { StrZero(nI, 4)            ,; // Item
            /* 02 */                   "0001"                    ,; // Sub-item
            /* 03 */                   AllTrim( aDados[nI, nPChvNFE] )       ,; // Chave Arq.
            /* 04 */                   Iif(Empty(AllTrim( aDados[nI, nCNPJ] )), AllTrim( aDados[nI, nCpf]), AllTrim( aDados[nI, nCNPJ] ))          ,; // CNPJ Arq.
            /* 05 */                   AllTrim( aDados[nI, nNomefor] )         ,;
            /* 06 */                   AllTrim( aDados[nI, nDocum] )         ,; // NF. Arq.
            /* 07 */                   AllTrim( aDados[nI, nSerie] )         ,; // Serie Arq.
            /* 08 */                   Iif(MV_PAR04==1, aDados[nI, nPDtEmissao],"")  ,; // Data Arq.
            /* 09 */                   Iif(MV_PAR04==1, AllTrim(aDados[nI, nPUF]), ""),; // UF
            /* 10 */                   Val(Replace(Replace(aDados[nI, nPVlrNF],".",""),",",".")),; // Valor Arq.
            /* 11 */                   Iif(MV_PAR04==1, Val(Replace(Replace(aDados[nI, nPBaseICMS],".",""),",",".")), 0),; // Base ICMS
            /* 12 */                   Iif(MV_PAR04==1, Val(Replace(Replace(aDados[nI, nPVlrICMS],".",""),",",".")), 0),; // Valor ICMS
            /* 13 */                   ""                     ,; // Chave NF V@
            /* 14 */                   ""                     ,; // Num NF V@
            /* 15 */                   ""                     ,; // Série NF V@
            /* 16 */                   sToD("")               ,; // Emissao NF V@
            /* 17 */                   0                      ,; // Valor NF V@
            /* 18 */                   ""                     ,; // Fornecedor V@
            /* 19 */                   ""                     ,; // CNPJ V@
            /* 20 */                   ""                     ,; // Mensagem NF V@
                               "Não Localizado" } )      // Status
        EndIf
       
    Next nI

    //Abrindo o excel e abrindo o arquivo xml
    oExcel:Activate()                                                
    oExcel:GetXMLFile( cArquivo )

    If ApOleClient("MSExcel")
        oExcelApp := MsExcel():New()
        oExcelApp:WorkBooks:Open( cArquivo )
        oExcelApp:SetVisible(.T.) 	
        oExcelApp:Destroy()	
        // ou >  ShellExecute( "Open", cNameFile , '', '', 1 ) //Abre o arquivo na tela após salvar 
    Else
        MsgAlert("O Excel não foi encontrado. Arquivo " + cArquivo + /* " gerado em " + cPath + */ ".", "MsExcel não encontrado" )
    EndIf

Return

/* ############################################################################################ */
Static Function ConsultaSQL(aDados, cModo, nItem)
local cAlias     := CriaTrab(,.f.)
Local cSql       := ""
Local lTemResul  := .T.
Local nSubItem   := 0
Local nRegistros := 0
       
        cSql := " SELECT "+CRLF
        cSql += "		F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA CHAVE_PROTHEUS, "+CRLF
        cSql += "		F1_FILIAL, "+CRLF
        cSql += "		F1_FORNECE+F1_LOJA COD_FOR, "+CRLF
        cSql += "		A2_CGC,"+CRLF
        cSql += "		A2_NOME, "+CRLF
        cSql += "		A2_MUN, "+CRLF
        cSql += "		A2_EST, "+CRLF
        cSql += "		F1_EMISSAO , "+CRLF
        cSql += "		F1_VALBRUT, "+CRLF
        cSql += "		F1_VALMERC, "+CRLF
        cSql += "		F1_BASEICM, "+CRLF
        cSql += "		F1_VALICM, "+CRLF
        cSql += "		F1_MENNOTA"+CRLF
        cSql += "		, F1_CHVNFE "+CRLF
        cSql += "		, F1_DOC "+CRLF
        cSql += "		, F1_SERIE "+CRLF
        cSql += "      FROM " + RetSqlName("SF1") + " F1"+CRLF
        cSql += "	LEFT JOIN " + RetSqlName("SA2") + " A2 ON A2_FILIAL=' ' "+CRLF
        cSql += "	        AND F1_FORNECE+F1_LOJA = A2_COD+A2_LOJA "+CRLF
        cSql += "           AND A2.D_E_L_E_T_ = ' ' "+CRLF
        cSql += "    WHERE F1.D_E_L_E_T_ = ' ' " +CRLF
     if MV_PAR04 == 1
        cSql += "      AND F1_TIPO = 'N' " +CRLF
     EndIf
        //cSql += "    AND   F1_EMISSAO BETWEEN '"+DTOS(CTOD(aDados[nPDtEmissao])) +"' AND  DATEADD(DAY,20, '"+ DtoS(CToD(aDados[nPDtEmissao]))+"') "+CRLF
    
     If cModo == "CGC"
        If MV_PAR04 == 1
            cSql += "	AND A2_CGC LIKE '%" + aDados[nCNPJ] + "%' " + iIF(MV_PAR04 == 1, "AND A2_EST = '" + aDados[nPUF] + "'", "") + CRLF
        Else
            cSql += " 	AND A2_CGC LIKE '%" +Iif(Empty(aDados[nCNPJ]), aDados[nCpf], aDados[nCNPJ])+ "%' " + CRLF
            //cSql += "   " + iIF(MV_PAR04 == 1, "AND A2_EST = '" + aDados[nPUF] + "'", "") + CRLF
        EndIf
        cSql += "	AND ("+CRLF
        cSql += "	     (F1_MENNOTA LIKE '%" + Replace(Replace(Replace(AllTrim(Transform(Val(Replace(aDados[nDocum],".","")),'@E 999%999%999%999%999')),"%   ",""),"%  ","%"),"%%","%") + "%' " +CRLF
        If MV_PAR04 == 1
        cSql += " AND (F1_MENNOTA LIKE '%"  + aDados[nPDtEmissao] + "%' OR F1_MENNOTA LIKE '%" + Substr(aDados[nPDtEmissao],1,2) +'/'+Substr(aDados[nPDtEmissao],4,2) +'/' + Substr(aDados[nPDtEmissao],7,4) + "%')"+CRLF
        EndIf
        cSql += " )" +CRLF
        cSql += "        OR F1_MENNOTA LIKE '%" + aDados[nDocum] + "%' " +CRLF
        cSql += "	     OR F1_DOC LIKE '%" + aDados[nDocum] + "' "+CRLF
        cSql += "	    )"+CRLF
    
    ElseIf cModo == "DOC_E_DATA"
        //cSql += "			(F1_MENNOTA LIKE '%" + aDados[nDocum] +admin     "%' AND F1_MENNOTA LIKE '%"  + aDados[nPDtEmissao] + "%' "+CRLF
        If MV_PAR04 == 1
            cSql += "       AND A2_CGC LIKE '%" + aDados[nCNPJ] + "%'"+CRLF
        Else 
            cSql += " 	AND A2_CGC LIKE '%" +Iif(Empty(aDados[nCNPJ]), aDados[nCpf], aDados[nCNPJ])+ "%' " + CRLF
            //cSql += " 	AND A2_CGC LIKE '%" + aDados[+iF(nCNPJ=' ' ,nCpf,nCNPJ)] + "%' " 
            //cSql += "   " + iIF(MV_PAR04 == 1, "AND A2_EST = '" + aDados[nPUF] + "'", "") + CRLF
        EndIf
        cSql += "	AND ("+CRLF
        cSql += "	     (F1_MENNOTA LIKE '%" + Replace(Replace(Replace(AllTrim(Transform(Val(Replace(aDados[nDocum],".","")),'@E 999%999%999%999%999')),"%   ",""),"%  ","%"),"%%","%") + "%' " +CRLF
        //cSql += "	     F1_MENNOTA LIKE '%" + Replace(Replace(Replace(AllTrim(Transform(Val(Replace(aDados[nDocum],".","")),'@E 999%999%999%999%999')),"%",""),"%","%"),"%%","%") + "%' )" +CRLF

        cSql += " ) " +CRLF
        cSql += "	  OR F1_DOC LIKE '%" + aDados[nDocum] + "' " + iIF(MV_PAR04 == 1, "AND A2_EST = '" + aDados[nPUF] + "'", "") + CRLF
        cSql += "	    )"+CRLF
    
    ElseIf cModo == "DEVOLUCAO"
        
            cSql += "   AND F1_FORNECE IN (SELECT A1_COD FROM " + RetSqlName("SA1") + " SA1  WHERE A1_CGC LIKE '%" + aDados[nCNPJ] + "%' AND D_E_L_E_T_ = ' ' ) "+CRLF"
            If MV_PAR04 == 1
                cSql += "   AND F1_EMISSAO  = '"+DTOS(CTOD(aDados[nPDtEmissao])) +"' " +CRLF
            EndIf
            cSql += "   AND F1_TIPO = 'D'  AND (F1_DOC LIKE '%" + aDados[nDocum] + "' OR F1_DOC LIKE '%" + Replace(Replace(Replace(AllTrim(Transform(Val(Replace(aDados[nDocum],".","")),'@E 999%999%999%999%999')),"%   ",""),"%  ","%"),"%%","%") + "%') " +CRLF
        
    

    ElseIf cModo == "MENNOTA"
        If !Empty(aDados[nCNPJ])
            cSql += "       AND A2_CGC LIKE '%" + aDados[nCNPJ] + "%'"+CRLF"
        Else
            cSql += "   AND F1_FORMUL = 'S' " + iIF(MV_PAR04 == 1, "AND A2_EST = '" + aDados[nPUF] + "'", "") + CRLF
        EndIf
        cSql += "	AND ("+CRLF
        cSql += "	      F1_MENNOTA LIKE '%" + Replace(Replace(Replace(AllTrim(Transform(Val(Replace(aDados[nDocum],".","")),'@E 999%999%999%999%999')),"%",""),"%  ","%"),"%%","%") + "%'"+CRLF
        cSql += "	    )"+CRLF 
    EndIf
        cSql += "ORDER BY 1" + CRLF
        cSql += " -- MODO: " + cModo

    //Val(Replace(aDados[nDocum],".",""))
    MemoWrite( StrTran(Upper(cArquivo),".XML",".SQL"), cSql)

    DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),(cAlias),.T.,.T.)
    (cAlias)->(DbEval({|| nRegistros++ }))
	(cAlias)->( DbGoTop() )

    lTemResul := !(cAlias)->(Eof())
    while !(cAlias)->(Eof())

        // // desenvolver teste analisando se adiciona ou NAO mais de um linha encontrada;
        // // pensei em um teste por faixa de valor, data definido um padrao para cada variavel.
        // if lTeste
        //     exit
        // EndIf    
        nSubItem += 1
        oExcel:AddRow( cWorkSheet, cTitulo,;
/* 01 */                         { StrZero(nItem, 4)                 ,; // Item
/* 02 */                           StrZero(nSubItem, 4)              ,; // Sub-item
/* 03 */                           AllTrim( aDados[nPChvNFE] )       ,; // Chave Arq.
/* 04 */                           AllTrim( aDados[nCNPJ] )          ,; // CNPJ Arq.
/* 05 */                           AllTrim( aDados[nNomefor] )       ,; // Nome do Fornecedor
/* 06 */                           AllTrim( aDados[nDocum] )         ,; // NF. Arq.
/* 07 */                           AllTrim( aDados[nSerie] )         ,; // Serie Arq.
/* 08 */                           Iif(MV_PAR04==1, aDados[nPDtEmissao],"" ),; // Data Arq.
/* 09 */                           Iif(MV_PAR04==1, AllTrim(aDados[nPUF]), ""),; // UF
/* 10 */                           Val(Replace(Replace(aDados[nPVlrNF],".",""),",",".")),; // Valor Arq.
/* 11 */                           Iif(MV_PAR04==1, Val(Replace(Replace(aDados[8],".",""),",",".")), 0),; // Base ICMS
/* 12 */                           Iif(MV_PAR04==1, Val(Replace(Replace(aDados[9],".",""),",",".")), 0),; // Valor ICMS
/* 13 */                           AllTrim( (cAlias)->F1_CHVNFE)      ,; // Chave NF V@
/* 14 */                           AllTrim( (cAlias)->F1_DOC )        ,; // Num NF V@
/* 15 */                           AllTrim( (cAlias)->F1_SERIE)       ,; // Série NF V@
/* 16 */                           sToD((cAlias)->F1_EMISSAO)         ,; // Emissao NF V@
/* 17 */                           (cAlias)->F1_VALBRUT               ,; // Valor NF V@
/* 18 */                           AllTrim( (cAlias)->A2_NOME)        ,; // Fornecedor V@
/* 19 */                           AllTrim( (cAlias)->A2_CGC)         ,; // CNPJ V@
/* 20 */                           AllTrim( (cAlias)->F1_MENNOTA)     ,; // Mensagem NF V@
/* 21 */                           "Localizado" } )                      // Status

        ConOut( StrZero(nItem, 4) +": Qtd Registros: " + StrZero(nRegistros,2) )

        (cAlias)->(DbSkip())
    EndDo
    (cAlias)->(DbCloseArea())

Return lTemResul


Static Function GeraSX1( )
	Local aArea 	:= GetArea()
	Local i	  		:= 0
	Local j     	:= 0
	Local lInclui	:= .F.
	Local aHelpPor	:= {}
	Local aHelpSpa	:= {}
	Local aHelpEng	:= {}
	Local cTexto	:= ''
	
	aRegs := {}

	AADD(aRegs, {cPerg, "01","Arquivo de Origem?"         ,"","","mv_ch1","C",60,0,0,"G","NAOVAZIO","mv_par01",""           ,"","","","",""           ,"","","","","","","","","","","","","","","","","","","DIR"  ,"N","","",""})
	AADD(aRegs, {cPerg, "02","Diretório do Destino?"      ,"","","mv_ch2","C",60,0,0,"G","NAOVAZIO","mv_par02",""           ,"","","","",""           ,"","","","","","","","","","","","","","","","","","","_XDIR","N","","",""})
	AADD(aRegs, {cPerg, "03","Nome de Arquivo do Destino?","","","mv_ch3","C",60,0,0,"G","NAOVAZIO","mv_par03",""           ,"","","","",""           ,"","","","","","","","","","","","","","","","","","","     ","N","","",""})
	AADD(aRegs, {cPerg, "04","Tipo de movto:"             ,"","","mv_ch4","N",01,0,0,"C","        ","mv_par04","1=1ª Versão","","","","","E=E-Auditor","","","","","","","","","","","","","","","","","","","     ","N","","",""})

	dbSelectArea("SX1")
	dbSetOrder(1)
    For i := 1 To Len(aRegs)

        If lInclui := !SX1->(dbSeek( PadR(cPerg, 10, " ") + aRegs[i,2]))
            RecLock("SX1", lInclui)
            For j := 1 to FCount()
                If j <= Len(aRegs[i])
                    FieldPut(j,aRegs[i,j])
                Endif
            Next
            MsUnlock()

            aHelpPor := {}; aHelpSpa := {}; aHelpEng := {}
            
            IF i==1
                AADD(aHelpPor,"Informe o nome do arquivo")
                AADD(aHelpPor,"a ser lido")
                AADD(aHelpPor,"")
            ElseIf i==2
                AADD(aHelpPor,"Informe o nome do arquivo")
                AADD(aHelpPor,"a ser gerado")
                AADD(aHelpPor,"")
            ENDIF
            PutSX1Help("P."+AllTrim(cPerg)+strzero(i,2)+".",aHelpPor,aHelpEng,aHelpSpa)
        EndIf

    Next
	
	RestArea(aArea)
Return('SX1: ' + cTexto  + CHR(13) + CHR(10))
