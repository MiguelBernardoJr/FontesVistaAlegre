#Include "Protheus.ch" 

User Function TSCFA00D()
	U_RunFunc("U_RunA00D()")
Return Nil

User Function RunA00D()

	DbSelectArea("SC9")
	DbSetOrder(1)
	DbSeek(xFilial("SC9")+"000053")
	
	U_CFATA00D()
	
Return Nil 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³CFATA00D  ºAutor  ³Microsiga           º Data ³  07/19/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Liberação do pedido de vendas                              º±±
±±º          ³ Liberação FINANCEIRA                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function CFATA00D(cPedido) 
Local aArea      := GetArea()
Local aAreaSC9   := {}
Local aAreaSC5   := {}
Local aAreaSC6   := {}
Local aRegSC6    := {}
Local cAlias     := ""
Local lProcessa  := .T.
Local nOpcA      := 4

//-- Variaveis utilizadas pela funcao wmsexedcf
Private aLibSDB	:= {}
Private aWmsAviso:= {}

Default cPedido    := SC9->C9_PEDIDO

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Liberacao para todos os itens do SC9                                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	DbSelectArea("SC5")
	DbSetOrder(1)
	
	DbSelectArea("SC6")
	DbSetOrder(1)

	DbSelectArea("SC9")
	DbSetOrder(1)

	aAreaSC9 := SC9->(GetArea())
	aAreaSC5 := SC5->(GetArea())
	aAreaSC6 := SC6->(GetArea())

	SC9->(DbSeek(xFilial("SC9")+cPedido))

	cAlias := CriaTrab(,.F.)
	
	cSql := "    select SC9.C9_FILIAL, SC9.C9_PEDIDO, SC9.C9_BLCRED, SC9.C9_ITEM, SC9.R_E_C_N_O_ C9_RECNO, "
	cSql += "           SC5.C5_TIPLIB, SC5.R_E_C_N_O_ C5_RECNO, "
	cSql += "           SC6.R_E_C_N_O_ C6_RECNO "
	cSql += "      from " + RetSqlName("SC9") + " SC9 "
	cSql += "      join " + RetSqlName("SC5") + " SC5 "
	cSql += "        on SC5.C5_FILIAL  = '" + xFilial("SC5") + "' "
	cSql += "       and SC5.C5_NUM     = SC9.C9_PEDIDO "
	cSql += "       and SC5.D_E_L_E_T_ = ' ' "
	cSql += "      join " + RetSqlName("SC6") + " SC6 "			
	cSql += "        on SC6.C6_FILIAL  = '" + xFilial("SC6") + "' "
	cSql += "       and SC6.C6_NUM     = SC5.C5_NUM "
	cSql += "       and SC6.C6_ITEM    = SC9.C9_ITEM "
	cSql += "       and SC6.C6_PRODUTO = SC9.C9_PRODUTO "
	cSql += "       and SC6.D_E_L_E_T_ = ' ' "
	cSql += "     where SC9.C9_FILIAL  = '" + xFilial("SC9") + "' "
	cSql += "       and SC9.C9_PEDIDO  = '" + cPedido + "' "
	cSql += "       and SC9.C9_BLCRED  not in ('" + Space(Len(SC9->C9_BLCRED)) + "', '09', '10', 'ZZ') "
	cSql += "       and SC9.D_E_L_E_T_ = ' ' "

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cSql)),cAlias,.T.,.T.)

	While ( !Eof() .And. (cAlias)->C9_FILIAL == xFilial("SC9") .And.;
			(cAlias)->C9_PEDIDO == cPedido )
			
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Ponto de Entrada para validacao do usuario                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (Existblock("MTA450LIB"))
			lProcessa:=ExecBlock("MTA450LIB",.f.,.f.,{(cAlias)->C9_PEDIDO,(cAlias)->C9_ITEM,4})
		EndIf

		If lProcessa
			SC5->(MsGoto((cAlias)->C5_RECNO))
			If (cAlias)->C5_TIPLIB == "2"
				AAdd(aRegSC6,(cAlias)->C6_RECNO)
			Else
				SC9->(MsGoto((cAlias)->C9_RECNO))
				a450Grava(1,.T.,.F.)
			EndIf				
		EndIf

		If (Existblock("MTA450I"))
			ExecBlock("MTA450I",.f.,.f.,{4,dDataBase})										
		EndIf
		
		(cAlias)->(DbSkip())
	EndDo

	(cAlias)->(DbCloseArea())

	If Len(aRegSC6) > 0
	
		dbSelectArea("SC9")
		DbClearFilter()
		dbSetOrder(1)

		Begin Transaction
			MaAvalSC5("SC5",3,.F.,.F.,,,,,,cPedido,aRegSC6,.T.,.F.)
			aRegSC6 := {}
		End Transaction
	EndIf

	If (Existblock("MT450FIM"))
		Execblock("MT450FIM",.F.,.F.,{cPedido})
	Endif

	//-- Integrado ao wms devera avaliar as regras para convocacao do servico e disponibilizar os 
	//-- registros do SDB para convocacao
	If	IntDL() .And. !Empty(aLibSDB)
		WmsExeDCF('2')
	EndIf

SC6->(RestArea(aAreaSC6))
SC5->(RestArea(aAreaSC5))
SC9->(RestArea(aAreaSC9))
If !Empty(aArea)
	RestArea(aArea)
EndIf
Return Nil