#include "MNTR675.CH"
#INCLUDE "PROTHEUS.CH"

User Function MNTR675G()

local nOpc := PARAMIXB[1] //Indica se está executando relatório MNTR675 ou MNTR676
local cWhileTL
local nLinha    := 1820 
local nColuna   := 2190
local _cQry     := ''
local nPCodigo   := aScan( aHoBrw6, { | x | Trim( Upper( x[ 2 ] ) ) == "TL_CODIGO" } )
local nPTarefa   := aScan( aHoBrw6, { | x | Trim( Upper( x[ 2 ] ) ) == "TL_TAREFA" } )
local nPTiporeg  := aScan( aHoBrw6, { | x | Trim( Upper( x[ 2 ] ) ) == "TL_TIPOREG" } )
local nPQuantid  := aScan( aHoBrw6, { | x | Trim( Upper( x[ 2 ] ) ) == "TL_QUANTID" } )
local nNSA       := GDFieldPos( 'TL_NUMSA' , aHoBrw6 )
local nISA       := GDFieldPos( 'TL_ITEMSA', aHoBrw6 )
local nNSC       := GDFieldPos( 'TL_NUMSC' , aHoBrw6 )
local nISC       := GDFieldPos( 'TL_ITEMSC' , aHoBrw6 )
local nLine      := 0
local nQuantid   := 0 //quantidade do insumo realizado
local cCodigo    := "" //código do insumo realizado
local cTiporeg   := "" //tipo do insumo realizado
local nSizeField := TamSx3( "T2_CODFUNC" )[ 1 ]
local cStatus    := ""
local aStatus    := {}
local nIndex 

if nOpc == 1 //Se for o modelo gráfico do MNTR675

   _cQry := "select * from STL010 WHERE TL_ORDEM = '"+STL->TL_ORDEM+"' AND D_E_L_E_T_ = ''" 

   MPSysOpenQuery(_cQry,"TMP")

   WHILE !TMP->(EOF())
       IF TMP->TL_TIPOREG == 'P' .And. ( nNSA > 0 .And. !Empty( TMP->TL_NUMSA ) ) .And.;
			( nISA .And. !Empty( TMP->TL_ITEMSA ) )

           nLine := 0

			// Considera a quantidade somente de insumos aplicados vinculados a mesma S.A.
			If nNSA > 0 .And. nISA > 0 .And. ( ( nLine := aScan( aCoBrw6, { |x| x[nNSA] == TMP->TL_NUMSA .And.;
				x[nISA] == TMP->TL_ITEMSA } ) ) > 0 )

				nQuantid := aCoBrw6[nLine,nPQuantid]
       ElseIf lIntRM .And. TMP->TL_TIPOREG $ 'P\T' .And. ( nNSC > 0 .And. !Empty( TMP->TL_NUMSC ) ) .And.;
			( nISC .And. !Empty( TMP->TL_ITEMSC ) )

			// Considera a quantidade somente de insumos aplicados vinculados a mesma S.C.
			If nNSC > 0 .And. nISC > 0 .And. ( ( nLine := aScan( aCoBrw6, { |x| x[nNSC] == TMP->TL_NUMSC .And.;
				x[nISC] == TMP->TL_ITEMSC } ) ) > 0 )

				nQuantid := aCoBrw6[nLine,nPQuantid]

			EndIf

		Else

			For nIndex := 1 To Len( aCoBrw6 )

				cTiporeg := aCoBrw6[ nIndex, nPTiporeg ]
				cCodigo  := aCoBrw6[ nIndex, nPCodigo ]

				//----------------------------------------------------
				//Comparação de insumos previstos x insumos realizados
				//----------------------------------------------------
				If AllTrim( TMP->TL_TAREFA ) == AllTrim( aCoBrw6[ nIndex, nPTarefa ] ) ;
					.And. ( ( Alltrim( TMP->TL_TIPOREG ) == "E" .And. AllTrim( cTiporeg ) == "M" ;
					.And. NGIFDBSEEK( "ST2", Padr( cCodigo, nSizeField )  + Alltrim( TMP->TL_CODIGO ), 1 ) ) ;
					.Or. ( AllTrim( TMP->TL_TIPOREG ) == AllTrim( cTiporeg ) ;
					.And. AllTrim( TMP->TL_CODIGO ) == AllTrim( cCodigo ) ) )

					//Soma a quantidade de insumos que já foram aplicados
					nQuantid += aCoBrw6[ nIndex, nPQuantid ]
				EndIf
			Next nIndex
			EndIf

       endif 

       If nQuantid == 0
			cStatus := "0" //'0' - Não aplicado
		ElseIf nQuantid < TMP->TL_QUANTID
			cStatus := "1" //'1' - Parcialmente Aplicado
		ElseIf nQuantid >= TMP->TL_QUANTID
			cStatus := "2" //'2' - Totalmente aplicado
		EndIf

       aAdd(aStatus,cStatus)

       TMP->(DBSKIP())
   END

    //oPrint:Say(2190,1820,"Status",oFonTPN)//
    oPrint:Say(2140,1920,"Status",oFonTPN)//
    //For nIndex := 1 to Len(aStatus)

//    Next nIndex
    // oPrint:Say(li,nHorz+1320,STR0110,oFonTPN)

   // li += 100 //Incrementa linhas
    //oPrint:Say(li,15 ,"SEU TEXTO AQUI MNTR675",oFonTPN)

//    TMP->(DBCLOSEAREA())
//ElseIf nOpc == 2 //Se for o modelo gráfico do MNTR676

//Lin += 100 //Incrementa linhas
//oPrint:Say(Lin,100,"SEU TEXTO AQUI! MODELO GRÁFICO MNTR676",oFontMN)

EndIf

Return .T.

Static Function MNTW675Somal(oPrint)
	Private cNomFil  := Trim( SM0->M0_FILIAL )

	li += 50
	If li > 3100
		lQuebra := .T.
		li := 100
		nPaG ++
		oPrint:EndPage()
		oPrint:StartPage()
		oPrint:Box(li,nHorz+10,3200,nHorz+2280)
		li += 20
		//
		If File(cLogo)
			oPrint:SayBitMap(li,nHorz+40,cLogo,250,73)
		EndIf

		oPrint:Say(li,nHorz+380,STR0006+"  "+STJ->TJ_ORDEM,oFonTMN)
		oPrint:Say( Li-10, nHorz+2040, STR0076 + ' ' + Str( nPag, 2 ), oFonTPN )

		If !Empty(stj->tj_solici)
			Li += 90
			oPrint:Say(li,nHorz+15,STR0056+"  "+STJ->TJ_SOLICI+Space(5)+STR0095+; //"Solicitante: "
			SubStr(UsrRetName(NGSEEK('TQB',STJ->TJ_SOLICI,1,'TQB->TQB_CDSOLI')),1,15))
			Li += 60
			oPrint:Say(li,nHorz+15,STR0096+; //"Dt.Solic.: "
			DtoC(NGSEEK('TQB',STJ->TJ_SOLICI,1,'TQB->TQB_DTABER'))+;
			Space(4)+STR0097+; //"Hr.Solic.: "
			NGSEEK('TQB',STJ->TJ_SOLICI,1,'TQB->TQB_HOABER'),oFonTPN)
		EndIf

		Li += 100

		oPrint:Say( Li, nHorz+15, STR0204 + cNomFil, oFonTPN ) // Filial:

		Li += 60

		oPrint:Say(li,nHorz+15 ,STR0044+" "+Dtoc(STJ->TJ_DTMPINI+(cTRB675)->DIFFDT)+" "+STJ->TJ_HOMPINI,oFonTPN)
		oPrint:Say(li,nHorz+750,STR0045+" "+Dtoc(STJ->TJ_DTMPFIM+(cTRB675)->DIFFDT)+" "+STJ->TJ_HOMPFIM,oFonTPN)
		oPrint:Say(li,nHorz+1400,STR0046+" "+Dtoc(Date())+" "+SubStr(Time(),1,5),oFonTPN)

		Li += 60
		oPrint:Say(li,nHorz+15,SubStr(STR0047,2,Len(STR0047))+" "+STJ->TJ_PLANO,oFonTPN)

		If STJ->TJ_TIPOOS == "B"
			oPrint:Say(li,nHorz+1650,STR0048+" "+STJ->TJ_PRIORID,oFonTPN)
		EndIf

		Li += 50
		oPrint:Say(li,nHorz+15,SubStr(STR0049,2,Len(STR0049))+" "+;
		NGSEEK('STI',STJ->TJ_PLANO,1,'SubStr(STI->TI_DESCRIC,1,39)'),oFonTPN)

		If NGSEEK('ST9',STJ->TJ_CODBEM,1,'ST9->T9_TEMCONT') <> "N"
			Li += 50
			oPrint:Say(li,nHorz+15,"1º "+STR0021+AllTrim(Str(STJ->TJ_POSCONT)),oFonTPN)  //"Contador:"
			If NGIFDBSEEK("TPE",STJ->TJ_CODBEM,1)
				Li += 50
				oPrint:Say(li,nHorz+15,"2º "+STR0021+AllTrim(Str(STJ->TJ_POSCON2)),oFonTPN) //"Contador:"
			EndIf
		EndIf

		Li += 100
	EndIf
Return
