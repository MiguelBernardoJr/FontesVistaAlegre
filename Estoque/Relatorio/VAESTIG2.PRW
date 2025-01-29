#include "protheus.ch"
#include "rwmake.ch"
#include "topconn.ch"
#include "parmtype.ch"
#include "fwmvcdef.ch"
#INCLUDE "TOTVS.CH"

Static cTitulo := "Fechamento de Frete"

/*---------------------------------------------------------------------------------,
 | Analista : Igor Gomes Oliveira                                                  |
 | Data		: 11.10.2021                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Relatório Fechamento de frete                                        |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     : U_VAESTIG2()                                                         |
 '---------------------------------------------------------------------------------*/

 USER FUNCTION VAESTIG2()
    Local cTimeINi  := Time()
    Local cStyle    := ""
    Local cXML      := ""
    Private cTitulo     := "Relatório - Compra de Gado"
    Private cPath       := "C:\TOTVS_RELATORIOS\"
    Private cArquivo    := cPath + cPerg +;
                                    DToS(dDataBase)+;//converte a data para aaaammdd
                                    "_"+;
                                    StrTran(Subs(Time(),1,5),":","")+;
                                    ".xml"
    Private oExcelApp   := nil
    Private _cAliasG    := GetNextAlias()

    Private nHandle     := 0
    Private nHandAux    := 0

    GeraX1(cPerg)

    IF Pergunte(cPerg, .T.)
        U_PrintSX1(cPerg)

        IF Len(Directory(cPath + "*.*","D")) == 0
            IF Makedir(cPath) == 0 
                ConOut('Diretório criado com sucesso.')
                MsgAlert('Diretorio criado com sucesso: ', + cPath, 'Aviso')
            ELSE
                ConOut("Não foi possivel criar o diretório. Erro: " + CValToChar(FError()))
                MsgAlert('Não foi possível criar o diretório. Erro', CValToChar(FError()),'Aviso')
            ENDIF
        ENDIF
    ENDIF

    nHandle := FCREATE(cArquivo)
    IF nHandle = -1
        ConOut("Erro ao criar arquivo - ferror" + Str(FError()))
    ELSE
        cStyle  := U_defStyle()
        // Processar SQL
 		FWMsgRun(, {|| lTemDados := fLoadSql("Geral", @_cAliasG ) },;
					    'Por Favor Aguarde...',; 
						'Processando Banco de Dados - Recebimento')
        IF lTemDados
            cXML    := U_CabXMLExcel(cStyle)

            IF !Empty(cXML)
                FWrite(nHandle, EncodeUTF8(cXML))
                cXML := ""
            ENDIF

            // Gerar primeira planilha
            FWMsgRun(, {|| fQuadro1() }, 'Gerando excel, Por favor, aguarde...')

            // Final - encerramento do arquivo
            FWrite(nHandle, EncodeUTF8('</Workbook>'))

            FClose(nHandle)

            IF ApoLeClient("MSExcel") // Verifica se o excel está instado
                oExcelApp   := MsExcel():New()
                oExcelApp:WorkBooks:Open(cArquivo)
                oExcelApp:SetVisible(.T.)
                oExcelApp:Destroy()
            ELSE
                MsgAlert("O Excel não foi encontrado. Arquivo" + cArquivo + " gerado em " + cPath + ".", "MsExcel não encontrado")
            ENDIF
        ELSE
            MsgAlert("Os parametros informados não retornaram nenhuma informação do banco de dados." + CRLF + ;
			"Por isso o excel não será aberto automaticamente.", "Dados não localizados")
        ENDIF

        (_cAliasG)->(DbCloseArea())

        IF Lower(cUserName) $ 'ioliveira'
            Alert('Tempo de processamento: ' + ElapTime(cTimeINi, Time()))
        ENDIF

        ConOut('Activate: ' + Time())
    ENDIF
RETURN NIL

STATIC FUNCTION GeraX1(cPerg)
    Local _aArea	:= GetArea()
    Local aRegs     := {}
    Local nX		:= 0
    Local nPergs	:= 0
    Local i
    Local j

    //Conta quantas perguntas existem atualmente.
    DbSelectArea('SX1')
    DbSetOrder(1)
    SX1->(DbGoTop())
    IF SX1->(DbSeek(cPerg))
        WHILE !SX1->(Eof()) .And. X1_GRUPO = cPerg
            nPergs++
            SX1->(DbSkip())
        ENDDO
    ENDIF
	
    AADD(aRegs,{cPerg,"01","Filial de            ?",Space(20),Space(20),"mv_ch1", TamSX3("ZFF_FILIAL")[3], TamSX3("ZFF_FILIAL")[1], TamSX3("ZFF_FILIAL")[2],0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"02","FIlial ate           ?",Space(20),Space(20),"mv_ch2", TamSX3("ZFF_FILIAL")[3], TamSX3("ZFF_FILIAL")[1], TamSX3("ZFF_FILIAL")[2],0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"03","Rementende de        ?",Space(20),Space(20),"mv_ch3", TamSX3("ZFF_ORIGEM")[3], TamSX3("ZFF_ORIGEM")[1], TamSX3("ZFF_ORIGEM")[2],0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	AADD(aRegs,{cPerg,"04","Remetente ate        ?",Space(20),Space(20),"mv_ch4", TamSX3("ZFF_ORIGEM")[3], TamSX3("ZFF_ORIGEM")[1], TamSX3("ZFF_ORIGEM")[2],0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
    AADD(aRegs,{cPerg,"05","Destinatario de      ?",Space(20),Space(20),"mv_ch5", TamSX3("ZFF_DESTIN")[3], TamSX3("ZFF_DESTIN")[1], TamSX3("ZFF_DESTIN")[2],0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
    AADD(aRegs,{cPerg,"06","Destinatario ate     ?",Space(20),Space(20),"mv_ch6", TamSX3("ZFF_DESTIN")[3], TamSX3("ZFF_DESTIN")[1], TamSX3("ZFF_DESTIN")[2],0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})

//Se quantidade de perguntas for diferente, apago todas
    SX1 -> (DbGoTop())
    IF nPergs <> Len(aRegs)
        FOR nX := 1 to nPergs
            IF  SX1 -> (DbSeek(cPerg))
                IF  RecLock('SX1', .F.)
                    SX1 -> (DbDelete())
                    SX1 -> (MsUnlock())
                ENDIF               
            ENDIF
        NEXT nX
    ENDIF

// gravação das perguntas na tabela SX1
    IF nPergs <> Len(aRegs)
        DbSelectArea("SX1")
        DbSetOrder(1)
        FOR i := 1 to Len(aRegs)
            IF !DbSeek(cPerg+aRegs[i,2])
                RecLock("SX1", .T.)
                    FOR j := 1 to FCOUNT()
                        IF j <= Len(aRegs[i])
                            FieldPut(j,aRegs[i,j])
                        ENDIF
                    NEXT j
                MsUnlock()
            ENDIF
        NEXT i 
    ENDIF

    RestArea(_aArea)
RETURN NIL

STATIC FUNCTION fLoadSQL(cTipo, _cAlias)
    Local _cQry     := ""

    IF lower(cUserName) $ 'ioliveira,bernardo,mbernardo,atoshio,admin,administrador'
	    MemoWrite(StrTran(cArquivo,".xml","")+"_Quadro_" + cTipo + ".sql" , _cQry)
    ENDIF

    dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.) 

RETURN !(_cAlias)->(Eof())
