user function EXP0001()
	Local oBtn :=	Array(4)
	Static oDlg

	DEFINE MSDIALOG oDlg TITLE "Exemplo de uso de teclas de atalho" From 0,0 To 300,400 PIXEL

	@001,001 BTNBMP oBtn[1]  RESOURCE "PREV" 		SIZE 25,25 ACTION MsgInfo("Você pressionou a tecla CTRL+Q","Tecla") OF oDlg
	@001,030 BTNBMP oBtn[2]  RESOURCE "NEXT" 		SIZE 25,25 ACTION MsgInfo("Você pressionou a tecla CTRL+W","Tecla") OF oDlg
	@001,070 BTNBMP oBtn[3]  RESOURCE "BMPINCLUIR"	SIZE 25,25 ACTION MsgInfo("Você pressionou a tecla CTRL+M","Tecla")	OF oDlg 
	@001,105 BTNBMP oBtn[4]  RESOURCE "PESQUISA"	SIZE 25,25 ACTION MsgInfo("Você pressionou a tecla CTRL+L","Tecla") OF oDlg

	oBtn[1]:cToolTip := "Voltar   (Ctrl+Q)"
	oBtn[2]:cToolTip := "Avancar   (Ctrl+W)"
	oBtn[3]:cToolTip := "Inverte Selecao (Ctrl+M)"
	oBtn[4]:cToolTip := "Buscar (Ctrl+L)"

	@020,011 SAY "Exemplo do uso de teclas de atalho" Size 200,015 Pixel Of oDlg

	SetKEY(17,oBtn[1]:bAction)
	SetKEY(23,oBtn[2]:bAction)
	SetKEY(13,oBtn[3]:bAction)
	SetKEY(12,oBtn[4]:bAction)

	ACTIVATE MSDIALOG oDlg CENTERED

	SetKEY(12, Nil)
	SetKEY(13, Nil)
	SetKEY(17, Nil)
	SetKEY(23, Nil)
return
