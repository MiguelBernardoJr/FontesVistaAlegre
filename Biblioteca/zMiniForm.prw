//Bibliotecas
#Include "Protheus.ch"
 
/*/{Protheus.doc} zMiniForm
Funóóo Mini Fórmulas, para executar fórmulas
@author Atilio
@since 17/12/2017
@version 1.0
@type function
@obs Assim como o fórmulas foi bloqueado no Protheus 12, cuidado ao deixar exposto no menu o Mini Fórmulas
/*/
 
User Function zMiniForm()
    Local aArea      := GetArea()
    //Varióveis da tela
    Private oDlgForm
    Private oGrpForm
    Private oGetForm
    Private cGetForm := "U_JOB20VA()               "//PadR(GetMV("MV_ZMINFOR",,""), 250) //Space(250)
    Private oGrpAco
    Private oBtnExec
    //Tamanho da Janela
    Private nJanLarg := 500
    Private nJanAltu := 120
    Private nJanMeio := ((nJanLarg)/2)/2
    Private nTamBtn  := 048

    // cGetForm := 'U_WSEnviaPlaca( "AAA"+"-"+StrTran(SubS(Time(),1,5),":",""), "MILHO VERDE", "Miguel " + DtoS(dDataBase) + " " + StrTran(SubS(Time(),1,5),":",""))'
    // cGetForm := 'U_SocketSiemens()'
    
    //Criando a janela
    DEFINE MSDIALOG oDlgForm TITLE "zMiniForm - Execução de Fórmulas" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
        
		//Grupo Fórmula com o Get
        @ 003, 003  GROUP oGrpForm TO 30, (nJanLarg/2)-1        PROMPT "Fórmula: " OF oDlgForm COLOR 0, 16777215 PIXEL
        @ 010, 006  MSGET oGetForm VAR cGetForm SIZE (nJanLarg/2)-9, 013 OF oDlgForm COLORS 0, 16777215 PIXEL
         
        //Grupo Aóóes com o Botóo
        @ (nJanAltu/2)-30, 003 GROUP oGrpAco TO (nJanAltu/2)-3, (nJanLarg/2)-1 PROMPT "Ações: " OF oDlgForm COLOR 0, 16777215 PIXEL
        @ (nJanAltu/2)-24, nJanMeio - (nTamBtn/2) BUTTON oBtnExec PROMPT "Executar" SIZE nTamBtn, 018 OF oDlgForm ACTION(fExecuta()) PIXEL
         
    //Ativando a janela
    ACTIVATE MSDIALOG oDlgForm CENTERED
    PutMV("MV_ZMINFOR",Alltrim(cGetForm))
    RestArea(aArea)
Return
 
/*---------------------------------------*
 | Func.: fExecuta                       |
 | Desc.: Executa a fórmula digitada     |
 *---------------------------------------*/
 
Static Function fExecuta()
    Local aArea    := GetArea()
    Local cFormula := Alltrim(cGetForm)
    Local cError   := ""
    Local bError   := ErrorBlock({ |oError| cError := oError:Description})
     
    //Se tiver conteódo digitado
    If ! Empty(cFormula)
        //Inicio a utilizaóóo da tentativa
        Begin Sequence
            &(cFormula)
        End Sequence
         
        //Restaurando bloco de erro do sistema
        ErrorBlock(bError)
         
        //Se houve erro, seró mostrado ao usuório
        If ! Empty(cError)
            MsgStop("Houve um erro na fórmula digitada: "+CRLF+CRLF+cError, "Atenóóo")
        EndIf
    EndIf
     
    RestArea(aArea)
Return
