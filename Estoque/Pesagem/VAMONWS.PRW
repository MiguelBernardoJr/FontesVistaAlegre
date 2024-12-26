#INCLUDE "TOTVS.CH"
#Include "TryException.ch"
#include "FileIO.ch"

/*--------------------------------------------------------------------------------,
 | Principal: 			            U_VAMONWS()             		              |
 | Func:  VAMONWS()	            	          	            	          	      |
 | Autor: Miguel Martins Bernardo Junior	            	          	  		  |
 | Data:  21.12.2021	            	          	            	              |
 | Desc:  "Monitor de Controle de integrações"                     	              |
 '--------------------------------------------------------------------------------|
 | Obs.:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------*/
User Function VAMONWS()    // U_VAMONWS()
Local cAlias      := "ZWS"

Local oBrowse 	  := nil
Local aRotina 	  := MenuDef()

Local aCores      := { {"ZWS->ZWS_STATUS == '0'", "BR_BRANCO"  },;
                       {"ZWS->ZWS_STATUS == '1'", "BR_AMARELO" },; 
                       {"ZWS->ZWS_STATUS == '2'", "BR_VERDE"   },;
                       {"ZWS->ZWS_STATUS == '3'", "BR_VERMELHO"} }

Private cCadastro := "Logs de operação"

//Instanciando FWMBrowse - Somente com dicionário de dados
oBrowse := FWMBrowse() :New()
//Setando a tabela de cadastro de Autor/Interprete
oBrowse:SetAlias(cAlias)
//Setando a descrição da rotina
oBrowse:SetDescription( cCadastro )

//Legendas
// oBrowse:SetFilterDefault( "Z02_TPARQ == '3'" )
oBrowse:AddLegend( "ZWS->ZWS_STATUS == '0'", "BR_BRANCO"  , "Integrado"   )
oBrowse:AddLegend( "ZWS->ZWS_STATUS == '1'", "BR_AMARELO" , "Processando" )
oBrowse:AddLegend( "ZWS->ZWS_STATUS == '2'", "BR_VERDE"   , "Finalizado"  )
oBrowse:AddLegend( "ZWS->ZWS_STATUS == '3'", "BR_VERMELHO", "Erro"        )

SetKey(VK_F10, {|| U_fIntegrar('U') })
SetKey(VK_F11, {|| U_fIntegrar('L') })

//Ativa a Browse
oBrowse:Activate()

Return Nil

Static FUnction Menudef()
Local aRotina := { { "Visualizar"            , "axVisual"        , 0, 2 },;
                   { "Excluir"               , "axDeleta"        , 0, 5 },;
                   { "Integrar (F10)"        , "U_fIntegrar('U')", 0, 4 },;
                   { "Integrar em Lote (F11)", "U_fIntegrar('L')", 0, 4 } }
Return aRotina


/*--------------------------------------------------------------------------------,
 | Principal: 			            U_SchAppPt()             		              |
 | Func:  	  SchAppPt()          	          	            	          	      |
 | Autor:     Miguel Martins Bernardo Junior	            	          	  	  |
 | Data:      04.01.2022	            	          	            	          |
 | Desc:      Schedule de processamento da integracao do APP da portaria.         |
 '--------------------------------------------------------------------------------|
 | Obs.:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------*/
User Function SchAppPt() // U_SchAppPt()
    If Type("oMainWnd") == "U"
        ConOut("")
        ConOut("")
        ConOut("")
        ConOut("")
        ConOut("[SchAppPt] Chamada por Schedule: " + Time())
		U_RunFunc("U_fIntegrar('L')",'01','01',3)
	Else
		U_fIntegrar("L")
	EndIf
Return nil

/*--------------------------------------------------------------------------------,
 | Principal: 			            U_VAMONWS()             		              |
 | Func:  VAMONWS()	            	          	            	          	      |
 | Autor: Miguel Martins Bernardo Junior	            	          	  		  |
 | Data:  21.12.2021	            	          	            	              |
 | Desc:  "Monitor de Controle de integrações"                     	              |
 '--------------------------------------------------------------------------------|
 | Obs.:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------*/
User Function fIntegrar( cOpc )
Local aArea        := GetArea()
Local lErro        := .F.
Local nQtdCiclos   := 1000

Private lLOOP      := .T. // deixa job em Loop, sem finalizar
Private nCoProcPVI := 0 // Contagem de processo/Ciclos, reiniciar de tempo em tempo para forcar que o servico nao fique parado

If Type("cSemaforo") == "U"
    Public  cSemaforo := ""
EndIf

Default cOpc       := "L"
   
    If cOpc == "L"

        While lLOOP

            nCoProcPVI += 1
            ConOut('Contador de Processos/Ciclos: ' + StrZero(nCoProcPVI, 4) )
            
            dbUseArea(.T.,'TOPCONN',TCGENQRY(,,;
                    _cQry := " SELECT   ISNULL(MIN(R_E_C_N_O_),0) RECNO " + CRLF +;
                            " FROM      ZWS010 " + CRLF +;
                            " WHERE " + CRLF +;
                            "           ZWS_STATUS = '0' " + CRLF +;
                            "       AND D_E_L_E_T_ = ' '";
                ),"TEMPSQL",.F.,.F.)

            If !TEMPSQL->(Eof()) .AND. TEMPSQL->RECNO > 0
                ZWS->(DbGoTo( TEMPSQL->RECNO ) )
                cSemaforo := "Recno ZWS " + cValToChar( ZWS->(Recno()) )
                If ( lErro := IntEmLote() )
                    ConOut( "Erro no processamento do Schedule: " + cValToChar(ZWS->(Recno())) )
                    // exit
                EndIf
                Sleep( 1000*1 )
            Else
                ConOut( "1-Time: " + Time() )
                Sleep( 1000*10 )
                ConOut( "2-Time: " + Time() )
                // lLOOP := .F.
                // Exit
            EndIf
            TEMPSQL->(DbCloseArea())

            If nCoProcPVI >= nQtdCiclos
                // Sleep(Randomize(1000,10000))
                ConOut( "3-Time: " + Time() )
                Sleep( 1000*30 )
                ConOut( "4-Time: " + Time() )
                lLOOP := .F.
            EndIf
        EndDo

    Else
        cSemaforo := "Recno ZWS " + cValToChar( ZWS->(Recno()) )
        lErro := IntEmLote()
    EndIf   
    If lErro
        DisarmTransaction()
    EndIf

    If !lLOOP
        Final("O proceso de integracao chegou a " + cValToChar(nQtdCiclos) +;
              " ciclos e por isso sera reiniciado. Por favor aguarde um momento.")
    EndIf

RestArea(aArea)
Return lErro


/*--------------------------------------------------------------------------------,
 | Principal : 			                        		                          |
 | Func:     : Integração em Lote  	          	            	          	      |
 | Autor: Miguel Martins Bernardo Junior	            	          	  		  |
 | Data:  28.12.2021	            	          	            	              |
 | Desc:  Rotina para realizar a integração                                       |
 '--------------------------------------------------------------------------------|
 | Obs.:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------*/
Static Function IntEmLote()
Local aArea                  := GetArea()
Local lErro                  := .T.
Local nInicio                := Time()
Local oObjResul              := nil
Local __cTxt    := ""

ConOut(" ")
ConOut("Inicio - " + FunName() + ": " + nInicio )

// nAux := At("-", ZWS->ZWS_METODO)
TryException
    BeginTran()
        ConOut( cSemaforo )
        While !LockByName(cSemaforo,.F., .F., .T.)
            Sleep(500)
        EndDo
            
            RecLock( "ZWS", .F. )
                ZWS->ZWS_SCHDTA := MsDate()
                ZWS->ZWS_SCHHRA := Time()
                If Empty(ZWS->ZWS_RECEIV)
                    ZWS->ZWS_RECEIV := oObjResul:agendamento_id
                EndIf
                ZWS->ZWS_STATUS := "2" // I=Importado para ZFL

                If Left(ZWS->ZWS_METODO, 6) == "DELETE"
                    if U_GetPodeManipular( AllTrim(ZWS->ZWS_RECEIV) /* oObjResul:agendamento_id */) // SIM = PODE MANIPULAR
                        SCH_DELETE( oObjResul )
                        U_LogWs( __cTxt := "AgendamentoId: " + AllTrim(ZWS->ZWS_RECEIV) + " excluido com sucesso.", "E")
                    Else // NAO == ERRO
                        ZWS->ZWS_STATUS := "3" // 3=Erro;I=Importado para ZFL
                        U_LogWs( __cTxt := "Não foi liberado para manipular o registro: " + AllTrim(ZWS->ZWS_RECEIV), "E")
                    EndIf
                Else
                    If FWJsonDeserialize( ZWS->ZWS_JSON, @oObjResul)
                        If Left(ZWS->ZWS_METODO, 4) == "POST"
                            SCH_POST( oObjResul )
                            ConOut(__cTxt := ZWS->ZWS_JSON )
                        ElseIf Left(ZWS->ZWS_METODO, 3) == "PUT"
                            if U_GetPodeManipular( AllTrim(ZWS->ZWS_RECEIV) /* oObjResul:agendamento_id */) // SIM = PODE MANIPULAR
                                // o LOG esta sendo na funcao abaixo
                                SCH_PUT( oObjResul )
                            Else // NAO == ERRO
                                ConOut(__cTxt := "Não foi liberado manipular o registro: " + AllTrim(ZWS->ZWS_RECEIV)/* oObjResul:agendamento_id */)
                                U_LogWs( __cTxt, "E")
                                ZWS->ZWS_STATUS := "3" // 3=Erro;I=Importado para ZFL
                            EndIf
                        EndIf
                    EndIf
                EndIf
            ZWS->(MsUnlock())
        UnLockByName(cSemaforo,.F., .F., .T.)
        lErro := .F.
    EndTran()
CatchException Using oException
    DisarmTransaction() // cancelar operacao, nao grava szg, szh
    ConOut('Erro ao integrar ZWS: ' + oException:Description )
EndException

ConOut("Fim - " + FunName() + ": " + Time() + " Tempo de Processamento: " + ElapTime( nInicio, Time()) )
RestArea(aArea) 
Return lErro

/* MB : 14.03.2022 */
Static Function SCH_DELETE( oObjResul )

RecLock("ZPB", .F.)
    ZPB->( DbDelete() )
MsUnlock()

RecLock("ZFL", .F.)
    ZFL->( DbDelete() )
MsUnlock()

Return

/* MB : 14.03.2022 */
Static Function SCH_PUT( oObjResul )

Local _cdepartamento_destino := ""
Local _cAUX                  := ""

ZFL->(DbSetOrder(1))
If ZFL->(DbSeek( xFilial('ZFL') + ZWS->ZWS_RECEIV/* oObjResul:agendamento_id */ ))

    RecLock( "ZFL", .F. )


        If At("agendamento_id", Lower(ZWS->ZWS_JSON)) > 0
            ZFL->ZFL_FILIAL := xFilial("ZFL")
            
            If At("agendamento_data", Lower(ZWS->ZWS_JSON)) > 0
                ZFL->ZFL_DATA   := cToD(Left(oObjResul:agendamento_data, 10)) // sToD( StrTran(Left(oObjResul:agendamento_data, 10), "/", "") ) // dDataBase
            EndIf
            If At("agendamento_data", Lower(ZWS->ZWS_JSON)) > 0
                ZFL->ZFL_HORA   := Right(oObjResul:agendamento_data, 08) // Time()
            EndIf
            If At("placa", Lower(ZWS->ZWS_JSON)) > 0
                ZFL->ZFL_PLACA  := oObjResul:placa        // "placa": "ABC-1234",
            EndIf

            // FORNECEDOR
            If At("fornecedor_id", Lower(ZWS->ZWS_JSON)) > 0
                ZFL->ZFL_CLIFOR := oObjResul:fornecedor_id
            EndIf
            If At("fornecedor_nome", Lower(ZWS->ZWS_JSON)) > 0
                ZFL->ZFL_NOMFOR := Upper(oObjResul:fornecedor_nome)
            EndIf
            If At("fornecedor_cnpj_cpf", Lower(ZWS->ZWS_JSON)) > 0
                ZFL->ZFL_FORCPF := U_UpdFormatCpo(oObjResul:fornecedor_cnpj_cpf, "C")
            EndIf
            
            //INCLUIR COD MOTORISTA DA4
            DbSelectArea("DA4")
            _cZPB_CODMOT := ""
            DA4->(DbSetOrder(1))
            If At("motorista_id", Lower(ZWS->ZWS_JSON)) > 0 .and.;
                !Empty(oObjResul:motorista_id) .and.;
                DA4->(DbSeek( xFilial('DA4')+oObjResul:motorista_id ) )
                _cZPB_CODMOT := DA4->DA4_COD
            ElseIf At("motorista_cpf", Lower(ZWS->ZWS_JSON)) > 0
                _cAUX := cValToChar(U_UpdFormatCpo(oObjResul:motorista_cpf, "C") )
                DA4->(DbSetOrder(3))
                If !Empty(_cAUX) .and. DA4->(DbSeek( xFilial('DA4')+_cAUX ))
                    _cZPB_CODMOT := DA4->DA4_COD
                EndIf                    
            EndIf
            If Empty( _cZPB_CODMOT )
                RecLock( "DA4", .T. )
                    DA4->DA4_FILIAL := xFilial('DA4')
                    DA4->DA4_COD    := GetSX8Num('DA4','DA4_COD')
                    DA4->DA4_NOME   := oObjResul:motorista_nome
                    DA4->DA4_NREDUZ := oObjResul:motorista_nome
                    DA4->DA4_FORNEC := SubStr(oObjResul:fornecedor_id,1,6)
                    DA4->DA4_LOJA   := SubStr(oObjResul:fornecedor_id,7,2) 
                    DA4->DA4_CGC    := U_UpdFormatCpo(oObjResul:motorista_cpf, "C")
                DA4->(MsUnlock())
                ConfirmSX8()
            Else
                RecLock( "DA4", .F. )
                    DA4->DA4_NOME   := Upper(oObjResul:motorista_nome)
                    DA4->DA4_NREDUZ := Upper(oObjResul:motorista_nome)
                    DA4->DA4_FORNEC := SubStr(oObjResul:fornecedor_id,1,6)
                    DA4->DA4_LOJA   := SubStr(oObjResul:fornecedor_id,7,2) 
                    DA4->DA4_CGC    := U_UpdFormatCpo(oObjResul:motorista_cpf, "C")
                DA4->(MsUnlock())
            EndIf
            ZFL->ZFL_CODMOT := _cZPB_CODMOT // oObjResul:motorista_id  // "motorista_nome": "João da Silva",
            If At("motorista_cpf", Lower(ZWS->ZWS_JSON)) > 0
                ZFL->ZFL_CPFMOT := U_UpdFormatCpo(oObjResul:motorista_cpf, "C")   // "motorista_cpf": "123.123.123-12",
            EndIf
            If At("motorista_nome", Lower(ZWS->ZWS_JSON)) > 0
                ZFL->ZFL_NOMMOT := Upper(oObjResul:motorista_nome)  // "motorista_nome": "João da Silva",
            EndIf
            If At("motorista_phone", Lower(ZWS->ZWS_JSON)) > 0
                ZFL->ZFL_CELMOT := U_UpdFormatCpo(oObjResul:motorista_phone, "T") // "motorista_phone": "(18) 99877-1233",
            EndIf        
            
            If At("produto_id", Lower(ZWS->ZWS_JSON)) > 0
                ZFL->ZFL_PRODID := oObjResul:produto_id      // "produto_id": "12ab",
            EndIf
            If At("produto_descricao", Lower(ZWS->ZWS_JSON)) > 0
                ZFL->ZFL_PRODUT := Upper(oObjResul:produto_descricao)      // "produto_id": "12ab",
            EndIf
             If At("porteiro_id", Lower(ZWS->ZWS_JSON)) > 0
                ZFL->ZFL_PORCOD := oObjResul:porteiro_id
            EndIf
            If At("operacao_tipo", Lower(ZWS->ZWS_JSON)) > 0
                ZFL->ZFL_OPERAC := oObjResul:operacao_tipo
            EndIf
            If At("agendamento_data", Lower(ZWS->ZWS_JSON)) > 0
                ZFL->ZFL_STATUS := "1"
            EndIf
            /* 
            1 - Estacionamento
            2 - Aguardando pesagem (liberado pelo departamento)
            3 - Em pesagem         ( liberado pelo balancao no processo de chamar pelo whatsapp)
            4 - Descarga            ( 1a. pessagem )
            5 - Finalizado          ( 2a. pesagem  )
            6 - Excluído
            */
        EndIf
        If At("departamento_id", Lower(ZWS->ZWS_JSON)) > 0
            ZFL->ZFL_DPTOID := oObjResul:departamento_id

            Do Case
                CASE Lower(oObjResul:departamento_id) == "0a"
                    _cdepartamento_destino := "ESCAVADO"
                CASE Lower(oObjResul:departamento_id) == "0b" 
                    _cdepartamento_destino := "FÁBRICA"
                CASE Lower(oObjResul:departamento_id) == "0c"
                    _cdepartamento_destino := "OFICINA"
                CASE Lower(oObjResul:departamento_id) == "0d"
                    _cdepartamento_destino := "ALMOXARIFADO"
                CASE Lower(oObjResul:departamento_id) == "0e"
                    _cdepartamento_destino := "OBRA"
                CASE Lower(oObjResul:departamento_id) == "0f"
                    _cdepartamento_destino := "CURRAL"
                CASE Lower(oObjResul:departamento_id) == "0g"
                    _cdepartamento_destino := "SILO"
                CASE Lower(oObjResul:departamento_id) == "0h"
                    _cdepartamento_destino := "PORTARIA"
                CASE Lower(oObjResul:departamento_id) == "0i"
                    _cdepartamento_destino := "TI"
                OTHERWISE
                    _cdepartamento_destino := "DEPARTAMENTO NAO LOCALIZADO"
            EndCase
        
            ZFL->ZFL_DPDEST := _cdepartamento_destino
        EndIf
    ZFL->(MsUnlock())

    If At("agendamento_id", Lower(ZWS->ZWS_JSON)) > 0    
        // PESAGENS
        RecLock( "ZPB", .F. )
            ZPB->ZPB_DATA	:= ZFL->ZFL_DATA
            ZPB->ZPB_PLACA  := oObjResul:placa
            
            // MOTORISTA
            ZPB->ZPB_CODMOT := DA4->DA4_COD  // oObjResul:motorista_id
            ZPB->ZPB_NOMMOT := DA4->DA4_NOME // oObjResul:motorista_nome
            ZPB->ZPB_CPFMOT := DA4->DA4_CGC  // oObjResul:motorista_cpf
            
            // FORNECEDOR
            ZPB->ZPB_CODFOR := SubStr(oObjResul:fornecedor_id,1,6)
            ZPB->ZPB_LOJFOR := SubStr(oObjResul:fornecedor_id,7,2) 
            ZPB->ZPB_NOMFOR := Upper(oObjResul:fornecedor_nome)
            
            // PRODUTO
            ZPB->ZPB_PRODUT := oObjResul:produto_id
            ZPB->ZPB_DESC   := Upper(oObjResul:produto_descricao)
        ZPB->(MsUnlock())
    EndIf

    U_LogWs( "Alteração realizada com sucesso para o Agendamento: " + AllTrim(ZWS->ZWS_RECEIV) + CRLF +;
             ZWS->ZWS_JSON, "E")
Else
    U_LogWs( "Integracao nao realizada, registro nao localizado: " + AllTrim(ZWS->ZWS_RECEIV) + CRLF +;
             ZWS->ZWS_JSON, "E")
EndIf
Return nil
// FIM: SCH_PUT


/* MB : 14.03.2022 */
Static Function SCH_POST( oObjResul )

Local _cdepartamento_destino := ""
Local _cAUX                  := ""

Do Case
    CASE Lower(oObjResul:departamento_id) == "0a"
        _cdepartamento_destino := "Escavado"
    CASE Lower(oObjResul:departamento_id) == "0b" 
        _cdepartamento_destino := "Fábrica"
    CASE Lower(oObjResul:departamento_id) == "0c"
        _cdepartamento_destino := "Oficina"
    CASE Lower(oObjResul:departamento_id) == "0d"
        _cdepartamento_destino := "Almoxarifado"
    CASE Lower(oObjResul:departamento_id) == "0e"
        _cdepartamento_destino := "Obra"
    CASE Lower(oObjResul:departamento_id) == "0f"
        _cdepartamento_destino := "Curral"
    CASE Lower(oObjResul:departamento_id) == "0g"
        _cdepartamento_destino := "Silo"
    CASE Lower(oObjResul:departamento_id) == "0h"
        _cdepartamento_destino := "Portaria"
    CASE Lower(oObjResul:departamento_id) == "0i"
        _cdepartamento_destino := "TI"
    OTHERWISE
        _cdepartamento_destino := "Departamento nao localizado"
EndCase

//INCLUIR COD MOTORISTA DA4
DbSelectArea("DA4")

_cZPB_CODMOT := ""
DA4->(DbSetOrder(1))
If !Empty(oObjResul:motorista_id) .and. DA4->(DbSeek( xFilial('DA4')+oObjResul:motorista_id ) )
    _cZPB_CODMOT := DA4->DA4_COD
Else
    _cAUX := cValToChar(U_UpdFormatCpo(oObjResul:motorista_cpf, "C") )
    DA4->(DbSetOrder(3))
    If !Empty(_cAUX) .and. DA4->(DbSeek( xFilial('DA4')+_cAUX ))
        _cZPB_CODMOT := DA4->DA4_COD
    EndIf                    
EndIf
If Empty( _cZPB_CODMOT )
    RecLock( "DA4", .T. )
        DA4->DA4_FILIAL := xFilial('DA4')
        DA4->DA4_COD    := GetSX8Num('DA4','DA4_COD')
        DA4->DA4_NOME   := oObjResul:motorista_nome
        DA4->DA4_NREDUZ := oObjResul:motorista_nome
        DA4->DA4_FORNEC := oObjResul:fornecedor_id
        /* DA4->DA4_LOJA   := oObjResul:fornecedor_id */
        /* DA4->DA4_FORNEC := SubStr(oObjResul:fornecedor_id,1,6)
        DA4->DA4_LOJA   := SubStr(oObjResul:fornecedor_id,7,2) */
        DA4->DA4_CGC    := U_UpdFormatCpo(oObjResul:motorista_cpf, "C")
    DA4->(MsUnlock())
    ConfirmSX8()
EndIf

RecLock( "ZFL", .T. )
    ZFL->ZFL_FILIAL := xFilial("ZFL")
    ZFL->ZFL_AGENID := iIf(Empty(oObjResul:agendamento_id), 0, oObjResul:agendamento_id )
    ZFL->ZFL_DATA   := cToD(Left(oObjResul:agendamento_data, 10)) // sToD( StrTran(Left(oObjResul:agendamento_data, 10), "/", "") ) // dDataBase
    ZFL->ZFL_HORA   := Right(oObjResul:agendamento_data, 08) // Time()
    ZFL->ZFL_PLACA  := oObjResul:placa        // "placa": "ABC-1234",
    
    ZFL->ZFL_CLIFOR := oObjResul:fornecedor_id
    ZFL->ZFL_NOMFOR := oObjResul:fornecedor_nome
    ZFL->ZFL_FORCPF := U_UpdFormatCpo(oObjResul:fornecedor_cnpj_cpf, "C")
    
    ZFL->ZFL_CODMOT := _cZPB_CODMOT // oObjResul:motorista_id  // "motorista_nome": "João da Silva",
    ZFL->ZFL_CPFMOT := U_UpdFormatCpo(oObjResul:motorista_cpf, "C")   // "motorista_cpf": "123.123.123-12",
    ZFL->ZFL_NOMMOT := oObjResul:motorista_nome  // "motorista_nome": "João da Silva",
    ZFL->ZFL_CELMOT := U_UpdFormatCpo(oObjResul:motorista_phone, "T") // "motorista_phone": "(18) 99877-1233",
    
    ZFL->ZFL_PRODID := oObjResul:produto_id      // "produto_id": "12ab",
    ZFL->ZFL_PRODUT := oObjResul:produto_descricao      // "produto_id": "12ab",

    ZFL->ZFL_DPTOID := oObjResul:departamento_id
    ZFL->ZFL_DPDEST := _cdepartamento_destino
    
    ZFL->ZFL_PORCOD := oObjResul:porteiro_id
    // ZFL->ZFL_PORNOM := oObjResul:porteiro_nome
    
    ZFL->ZFL_OPERAC := oObjResul:OPERACAO_TIPO
    ZFL->ZFL_STATUS := "1"
    /* 
    1 - Estacionamento
    2 - Aguardando pesagem (liberado pelo departamento)
    3 - Em pesagem         ( liberado pelo balancao no processo de chamar pelo whatsapp)
    4 - Descarga            ( 1a. pessagem )
    5 - Finalizado          ( 2a. pesagem  )
    6 - Excluído
    */
ZFL->(MsUnlock())
  
// PESAGENS
RecLock( "ZPB", .T. )
    ZPB->ZPB_FILIAL	:= xFilial('ZPB')
    ZPB->ZPB_DATA	:= dDataBase
    ZPB->ZPB_CODIGO	:= U_fChvITEM("ZPB", "ZPB_DATA", "ZPB_CODIGO", "ZPB_DATA", DtoS(dDataBase))
    ZPB->ZPB_PLACA  := oObjResul:placa
    
    // MOTORISTA
    ZPB->ZPB_CODMOT := DA4->DA4_COD  // oObjResul:motorista_id
    ZPB->ZPB_NOMMOT := DA4->DA4_NOME // oObjResul:motorista_nome
    ZPB->ZPB_CPFMOT := DA4->DA4_CGC  // oObjResul:motorista_cpf
    
    // FORNECEDOR
    ZPB->ZPB_CODFOR := SubStr(oObjResul:fornecedor_id,1,6)
    ZPB->ZPB_LOJFOR := SubStr(oObjResul:fornecedor_id,7,2) 
    ZPB->ZPB_NOMFOR := oObjResul:fornecedor_nome
    
    // PRODUTO
    ZPB->ZPB_PRODUT := oObjResul:produto_id
    ZPB->ZPB_DESC   := oObjResul:produto_descricao
    
    ZPB->ZPB_PESOE  := 0
    ZPB->ZPB_PESOS  := 0
    ZPB->ZPB_STATUS := "P" //
    ZPB->ZPB_RCOZFL := ZFL->(Recno())
ZPB->(MsUnlock())
Return

/* MB : 14.03.2022 */
User Function GetPodeManipular( cAgendamentoId )
Local lRet := .T.

DbSelectArea("ZFL")
ZFL->(DbSetOrder(1))
If ZFL->(DbSeek( xFilial('ZFL')+cAgendamentoId ))
	BeginSQL alias "qTMP"
        %noParser%
        SELECT *
        FROM   %table:ZPB%
        WHERE  ZPB_RCOZFL=%exp:ZFL->(Recno())%
           AND %notDel%
    EndSQL
    If !qTMP->(Eof()) 
        ZPB->(DbGoTo( qTMP->R_E_C_N_O_ ) )
        if ( qTMP->ZPB_STATUS == 'F')        
            lRet := .F.
        EndIf
    EndIf
    qTMP->(DbCloseArea()) 
EndIf
Return lRet



#define __TRACO__ Replicate("-", 100 )

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³ LogWs     ºAutor  ³Miguel Bernardo    º Data ³ 04/06/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Função para gerar log. Cria 1 arquivo por dia e grava     º±±
±±º          ³ a mensagem sempre no final.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Parametro³ cVal: Mensagem a ser incluida(gravada) na mensagem de Log  º±±
±±º entrada  ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º Retorno  ³      													  º±±
±±ºda função ³                                                        	  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Central Ar - MP11                                          º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ºModificado³                                                            º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function LogWs(cVal,nOpc)

Local nHandle   := 0
Local cFileName := ""
Local __cTxt    := ""

Default nOpc := 'E' // E=Entrada/Recebimento; S=Saida/Envio

// cFileName := "\ws\log\ws_"+ nOpc + "_" +DToS(Date())+".log"
cFileName := "C:\totvs_relatorios\"+ nOpc + "_" +DToS(Date())+".log"

If !File(cFileName)
   nHandle := fCreate(cFileName)
Else
   nHandle := fOpen(cFileName, FO_READWRITE)
   nPos := FSeek(nHandle, 0, FS_END)
EndIf

While !LockByName("LogWs",.F., .F., .T.)
	Inkey(0.01)
End

FWrite(nHandle, __cTxt := "[" + AllTrim(Str(ThreadID())) + " " + DToS(Date()) + " " + Time() +"]" + CRLF +;
                        cVal + CRLF + CRLF +;
                        __TRACO__ + CRLF )
// FWrite(nHandle, "[" + AllTrim(Str(ThreadID())) + " " + DToS(Date()) + " " + Time() +"]" )
// FWrite(nHandle, "" )
// FWrite(nHandle, cVal )
// FWrite(nHandle, "" )
// FWrite(nHandle, "" )
// FWrite(nHandle, __TRACO__ )
// FWrite(nHandle, "" )
UnLockByName("LogWs",.F., .F., .T.)
 
FClose(nHandle)

RecLock("ZWS",.F.) 
    // Programar gravacao no campo ZWS_LOG
	ZWS->ZWS_LOG	:= ZWS->ZWS_LOG + CRLF + __cTxt
ZWS->(MsUnlock())	
ConOut("LogWS: " + __cTxt)
Return Nil
