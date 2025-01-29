#INCLUDE "PROTHEUS.CH"
#Include "TOPCONN.CH"
#Include "RWMAKE.CH"
#include "Fileio.ch"
#include "tbiconn.ch"
#INCLUDE "DBINFO.CH"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "mntutil_os.CH"
//---------------------------------------------------------------------
/*/{Protheus.doc} NGIMP675
Impressao de ordem de servico

@return .T.

@Param cVORDEM
@Param cVPLANO
@Param lPARI
@Param cFilTroc
@Param nRecOs

@sample
NGIMP675()

@author Inacio Luiz Kolling
@since 24/06/04
/*/
//---------------------------------------------------------------------
User Function IMP675(cVORDEM,cVPLANO,lPARI,cFilTroc,nRecOs)

	Local aItems
	Local lNovo676  := .F.
    Local lRet      := .T.
	Local nTamDial  := 250
    Local nTamGrp   := 82
	Local nOptPE	:= 0

	Private oDlgC
    Private nOpRe   := 1
    Private nOpca   := 0
	Private cNomFil := SM0->M0_FILIAL
	Private nHorz   := 100

	Default nRecOs := 0

	DbSelectArea("STJ")
	cAliasimp := Alias()
	nIndeximp := IndexOrd()
	nIMP675RE := Recno()
	If cVORDEM <> NIL .And. cVPLANO <> NIL
		DbSetOrder(1)
		Dbseek(NGTROCAFILI("STJ",cFilTroc)+cVORDEM+cVPLANO)
	Endif

    If !ExistBlock("MNTIMPOS")

        aItems := { STR0233, STR0234, STR0235+" "+STR0236,;  // "Basica" "Simplificada" "Padrao"##"Normal"
                    STR0235+" "+STR0237,STR0238+" "+STR0236,;// "Padrao"##"Gráfica" "Completa"##"Normal"
                    STR0238+" "+STR0237 , STR0241 }          // "Completa"##"Gráfica"##"OS Interna"

        If ExistBlock("IMP675OS")
            aOptionsPE := {}
            aOptionsPE := ExecBlock("IMP675OS", .F., .F.)
            // Adiciona as opções informadas pelo PE no menu de impressões padrão
            // Ajusta tamanho da Dialog e do Grupo de opções conforme quantidade de opções inseridas
            For nOptPE := 1 To Len(aOptionsPE)
                aAdd(aItems, aOptionsPE[nOptPE, 1])
                nTamDial += 18
                nTamGrp  += 10
            Next nOptPE
        EndIf

		DEFINE MSDIALOG oDlgC FROM 00,00 TO nTamDial,600 TITLE STR0232 PIXEL //"Modelo de Impressao da ordem"

        oPnlPai := TPanel():New(00,00,,oDlgC,,,,,,320,200,.F.,.F.)
		oPnlPai:Align := CONTROL_ALIGN_ALLCLIENT

		@ 0005,030 To nTamGrp,155 LABEL STR0239 of oPnlPai Pixel  // "Opcoes"

		TRadMenu():New( 015, 035, aItems,{|u|Iif (PCount()==0,nOpRe,nOpRe:=u)},oPnlPai,,,,,,,,60,10,,,,.T.)

		Activate MsDialog oDlgC On Init EnchoiceBar(oDlgC,{|| nOPCA := 1,oDlgC:End()},{||oDlgC:End()}) Centered
		If nOpca != 0
		    If nOpRe == 1 .OR. nOpRe == 2
			    lNovo676 := .T.
		    Endif
        Else
            lRet := .F.
        EndIf
	EndIf

	If lRet
        If STJ->TJ_SITUACA <> 'L'
            MsgInfo(STR0240,STR0005) //"NÃO CONFORMIDADE" ### "Ordem de serviço não foi liberada."
        Else
            If !lNovo676 //Se for alguma opcao do MNTR675
                aMATSX1 := {{'01', Space(Len(stj->tj_plano))},{'02',Replicate('Z',Len(stj->tj_plano))},;
                            {'07', Space(Len(stj->tj_ccusto))},{'08',Replicate('Z',Len(stj->tj_ccusto))},;
                            {'09', Space(Len(stj->tj_centrab))},{'10',Replicate('Z',Len(stj->tj_centrab))},;
                            {'11', Space(Len(stj->tj_codarea))},{'12',Replicate('Z',Len(stj->tj_codarea))},;
                            {'13', STJ->TJ_ORDEM},{'14',STJ->TJ_ORDEM},{'15',STJ->TJ_DTMPINI},;
                            {'16', STJ->TJ_DTMPINI}}

            Else //Se for alguma opcao do MNTR676
                aMATSX1 := {{'01', STJ->TJ_PLANO},;
                            {'02', STJ->TJ_PLANO},;
                            {'03', STJ->TJ_CODBEM},;
                            {'04', STJ->TJ_CODBEM},;
                            {'05', STJ->TJ_ORDEM},;
                            {'06', STJ->TJ_ORDEM},;
                            {'07', STJ->TJ_DTMPINI},;
                            {'08', STJ->TJ_DTMPINI}}

            Endif

            If ExistBlock("MNTIMPOS")
                ExecBlock("MNTIMPOS",.F.,.F.,{stj->tj_plano,stj->tj_ordem,stj->tj_dtmpini})
            Else
                If nOpRe == 1
                    MNTBA676(lPARI,nRecOs,,aMATSX1)
                ElseIf nOpRe == 2
                    MNTSI676(lPARI,nRecOs,,aMATSX1)
                ElseIf nOpRe == 3
                    U_xMNTR675(lPARI,,,,1,aMATSX1,nRecOs)
                ElseIf nOpRe == 4
                    U_xMNTR675(lPARI,,,,2,aMATSX1,nRecOs)
                ElseIf nOpRe == 5
                    U_xMNTR675(lPARI,,,,3,aMATSX1,nRecOs)
                ElseIf nOpRe == 6
                    U_xMNTR675(lPARI,,,,4,aMATSX1,nRecOs)
                ElseIf nOpRe == 7
                    MNTR422(STJ->TJ_ORDEM)
                Else
                    If ExistBlock("IMP675OS")
						//Calculo para validar a opção do cliente ( 7 = Quantidade de opções de impressão padrão do sistema)
                        nPosPe := nOpRe - 7
                        If nPosPe > 0
                            If Len( aOptionsPE[ nPosPe ] ) < 3
                                &( aOptionsPE[nPosPe, 2] + '()' )
                            Else
								aOpcParam := aOptionsPE[nPosPe, 3]
                                &( aOptionsPE[nPosPe, 2] + '( aOpcParam )' )
                            EndIf
                        EndIf
                    EndIf
                Endif
            Endif
        EndIf

        DbSelectArea(cAliasimp)
        DbSetOrder(nIndeximp)
        Dbgoto(nIMP675RE)
    EndIf

Return lRet
