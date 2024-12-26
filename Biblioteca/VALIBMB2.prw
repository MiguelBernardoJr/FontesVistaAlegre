#include "TOTVS.CH"
#include "protheus.ch" 

/*---------------------------------------------------------------------------------,
 | Analista : Miguel Martins Bernardo Junior                                       |
 | Data		: 13.08.2019                                                           |
 | Cliente  : V@                                                                   |
 | Desc		: Carregar paginas WEB;                                                |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Regras   :                                                                      |
 |                                                                                 |
 |---------------------------------------------------------------------------------|
 | Obs.     :                                                                      |
 '---------------------------------------------------------------------------------*/
User Function PortalWEB(cURL)
Default cURL := "http://localhost:62955/Estoque/Relatorios/RelAlimentacaoDiaria"
shellExecute("Open", cURL, "", "", 1 )
Return nil

/* ###################################################### */

User Function BPortalVA(cURL)
Local oWebEngine
Private aSize 		:= MsAdvSize() 
Default cURL := "http://localhost:62955/Estoque/Relatorios/RelAlimentacaoDiaria"

  DEFINE DIALOG oDlg TITLE "Navegador" From aSize[7],0 to aSize[6], aSize[5] of oMainWnd PIXEL
  oDlg:lMaximized := .T. //Maximiza a janela
  
    /*
    // Prepara o conector WebSocket
    PRIVATE oWebChannel := TWebChannel():New()
    nPort := oWebChannel::connect()
    */
    // Cria componente
    oWebEngine := TWebEngine():New(oDlg, 0, 0, 100, 100) // ,, nPort)
    oWebEngine:bLoadFinished := {|self,url| conout("Termino da carga do pagina: " + url) }
    oWebEngine:navigate( cURL )
    oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT
  
  ACTIVATE DIALOG oDlg CENTERED
Return


User Function LoadPage(cURL, cExpOk, cExpCanc, aButtons, lShowPrint )	//	u_cTmkA001("http://www.uol.com.br")
Local nOpcA        := 0

Private aSize      := MsAdvSize()
Private oDlgVA, oTIBrw

Default cURL       := "http://localhost:62955/Estoque/Relatorios/RelAlimentacaoDiaria"
Default cExpOk     := "'.T.'"
Default cExpCanc   := "'.T.'"
Default aButtons   := nil
Default lShowPrint := .T.

	If lShowPrint
		If aButtons == nil
			aButtons	:= {}
		EndIf
		aAdd( aButtons, {"PRINT", { || oTIBrw:Print() }, "Imprimir Documento" , "Imprimir"})
	End

	DEFINE MSDIALOG oDlgVA TITLE "Navegador" From aSize[7],0 to aSize[6], aSize[5] of oMainWnd PIXEL 
	oDlgVA:lMaximized := .T. //Maximiza a janela

	oTIBrw:= TIBrowser():New( 1,1,400, 380, cURL, oDlgVA ) 
	oTIBrw:Align := CONTROL_ALIGN_ALLCLIENT 
	oTIBrw:Refresh()

	Activate MsDialog oDlgVA ON INIT ;
					(EnchoiceBar(oDlgVA,;
							{||nOpcA := 1,;
									Iif(U_RunEXP(cExpOk),oDlgVA:End(), nOpcA := 0) },;
									{|| Iif(U_RunEXP(cExpCanc),oDlgVA:End(),Nil) },,;
							aButtons))

Return nOpcA==1

User Function RunEXP(cExpOk)
	cExpOk := &(cExpOk)
Return &(cExpOK)


// 	// #include "TOTVS.CH"
//  	 
//  	/*/ -----------------------------------------------------------------/
//  	Exemplo para montagem de um componente hibrido AdvPL/HTML
//  	/-------------------------------------------------------------------*/
//  	User function React()
//  	Local i, oDlg, globalLink
//  	Private oWebChannel, oCompHTML
//  	Private nItem := 0
//  	 
//  	oDlg := TWindow():New(10, 10, 800, 600, "TOTVS - Demonstração React + Advpl")
//  	oDlg:setCss("QPushButton{borderDummy: 1px solid black;}")
//  	 
//  	// [Android] retorna mesmo tipo do Linux
//  	If GetRemoteType() == 2
//  	oMobile := TMobile():New()
//  	oMobile:SetScreenOrientation(-1)
//  	EndIf
//  	 
//  	// Painel de botoes
//  	@ 000, 000 MSPANEL pLeft SIZE 092, 400 OF oDlg COLORS 0, 16777215 RAISED
//  	@ 000, 000 BUTTON oButton2 PROMPT "Abre Janela" SIZE 091, 012 OF pLeft PIXEL;
//  	ACTION ( OpenWindow() )
//  	@ 000, 000 BUTTON oButton3 PROMPT "Fecha Janela" SIZE 091, 012 OF pLeft PIXEL;
//  	ACTION ( CloseWindow() )
//  	@ 013, 000 BUTTON oButton4 PROMPT "Adiciona item" SIZE 091, 012 OF pLeft PIXEL;
//  	ACTION ( AddItem() )
//  	 
//  	// TWebChannel eh responsavel pelo trafego SmartClient/HTML
//  	oWebChannel := TWebChannel():New(9999)
//  	oWebChannel:nPort := 9999
//  	oWebChannel:connect(9999)
//  	if !oWebChannel:lConnected
//  	msgStop("Erro na conexao com o WebSocket")
//  	return
//  	endif
//  	oWebChannel:nPort := 9999
//  	conout(oWebChannel:nPort)
//  	 
//  	// IMPORTANTE: Aqui definimos a porta WebSocket que sera utilizada
//  	globalLink := "localhost:3000/?port=" + cValToChar(oWebChannel:nPort)
//  	 
//  	// Toda acao JavaScript enviada atraves do comando dialog.jsToAdvpl()
//  	// serah recebida/tratada por esta bloco de codigo
//  	oWebChannel:bJsToAdvpl := {|self,codeType,codeContent|;
//  	jsToAdvpl(self,codeType,codeContent) }
//  	 
//  	// Componente que sera utilizado como Navegador embutido
//  	oCompHTML := TWebEngine():New(oDlg, 0, 0, 100, 100)
//  	oCompHTML:navigate(globalLink)
//  	 
//  	pLeft:Align := CONTROL_ALIGN_LEFT
//  	oButton2:Align := CONTROL_ALIGN_TOP
//  	oButton3:Align := CONTROL_ALIGN_TOP
//  	oButton4:Align := CONTROL_ALIGN_TOP
//  	oCompHTML:Align := CONTROL_ALIGN_ALLCLIENT
//  	 
//  	 
//  	oDlg:Activate("MAXIMIZED")
//  	Return
//  	 
//  	/*/ -----------------------------------------------------------------/
//  	Bloco de codigo que recebera as chamadas JavaScript
//  	/-------------------------------------------------------------------*/
//  	static function jsToAdvpl(self,codeType,codeContent)
//  	// Exibe mensagens trocadas
//  	conout("jsToAdvpl->codeType: " + codeType +chr(10)+;
//  	"jsToAdvpl->codeContent: " + codeContent)
//  	 
//  	// Termino da carga da pagina HTML
//  	if codeType == "pageStarted"
//  	conout("Terminou de carregar página HTML")
//  	//oWebChannel:advplToJs("js", cFunction)
//  	endif
//  	 
//  	return
//  	 
//  	Static Function OpenWindow()
//  	Return oWebChannel:advplToJs("OpenWindow", "")
//  	 
//  	Static Function CloseWindow()
//  	Return oWebChannel:advplToJs("CloseWindow", "")
//  	 
//  	Static Function AddItem()
//  	Local cItem := cValToChar(nItem)
//  	Local cJson := '{"item": "'+cItem+'", "name": "Item '+cItem+'" }'
//  	nItem++
//  	Return oWebChannel:advplToJs("AddItem", cJson)
// /*
// 
// 
// SM4
// 'Port CAT-81de 21-07-2015 - ISENTO CFE ART 102 DO ANEXO I DO RICMS/00 -SUSP. DE PIS/COFINS CFE LEI 12.058 DE 13/10/09 CFE ART32'
// https://app.powerbi.com/view?r=eyJrIjoiOThkNDQ5ZmYtNGZlZi00OTNjLWFmNTEtN2QyZjI1NGExY2RiIiwidCI6ImRjZDQxYzQyLTA1NjAtNDc5ZC1hY2I4LWE2YzYxN2M3MzdmNyJ9
// https://app.powerbi.com/view?r=eyJrIjoiMzVlZmU2NWYtY2VhMy00NmI2LTk2OGUtM2JjNjgzZjcwYTg2IiwidCI6ImRjZDQxYzQyLTA1NjAtNDc5ZC1hY2I4LWE2YzYxN2M3MzdmNyJ9
// https://app.powerbi.com/view?r=eyJrIjoiNzg4YTk5YmItNTYzMy00NmZmLWIyY2UtN2Y0ODBkYTg3MjhhIiwidCI6ImRjZDQxYzQyLTA1NjAtNDc5ZC1hY2I4LWE2YzYxN2M3MzdmNyJ9
// 212-10                                                 
// 256   
// 
// X5_DESCRI
// 55	REG ESPECIAL - DEV COMUNICADO DO CORREIO - DESCONHECIDO
// */
