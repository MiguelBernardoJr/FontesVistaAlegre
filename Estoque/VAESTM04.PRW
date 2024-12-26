#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "FWADAPTEREAI.CH"
#include "tbiconn.ch"
#include "TOPCONN.CH"

// ###############################################################################################
// Projeto: 
// Fonte  : VAESTM04.prw
// ---------+------------------------------------+------------------------------------------------
// Data     | Autor                              | Descricao
// ---------+------------------------------------+------------------------------------------------
//  23/05/22|  Manoel Filho                      | Processa Movimento de Custo do Trato
// ---------+------------------------------------+------------------------------------------------
User Function VAESTM04()

Local nOpcao := Aviso("Apropriação em Insumos Diretos","Informe o tipo de movimentação desejada!", { "Movimento" , "Estorno"  } )

If nOpcao == 1 // Movimentação Interna
	oProcTTP := MsNewProcess():New({ |lEnd| FS_ProcMov() }," ","",.f.) 
	oProcTTP:Activate()
Else // Estorno
	f_TelaEstorno()
Endif


Return


Static Function FS_ProcMov()

Local dDatAnt    := GetMV("MV_ULMES")
Local dDatProc   := LastDay(dDatAnt+1)
Local cTMMov     := GetNewPar("MV_TMCUSTR","402") // tipo de movimentação para Custo do Trato
Local nCntFor    := 0
Local aCabecalho := {}
Local aItens     := {}
Local cNumDoc    := ""
Local aVetMov    := {}
Local aRetProp   := {}
Local cObserva   := ""
Local lProcessou := .f.
Local cLocal     := ""
Local nCusto     := 0
Local nCntFor2   := 0

Private aArmProporc := {}
// 1o Elemento - Armazem
// 2o Elemento - Sdo Inicial
// 3o Elemento - Entradas
// 4o Elemento - Saidas
// 5o Elemento - Valor Final
// 6o Elemento - Percentual da Proporção

If MsgYesNo("Deseja Iniciar o Processamento?", "Atenção")

	// Levanta valores para a movimentação
	DbSelectArea("Z0L")
	DbSetOrder(1)
	While Z0L->(!Eof())

		If Z0L->Z0L_ATIVO == "S" .and. Z0L->Z0L_DATUPR < (dDatAnt+1)
			//nCusto := Abs(CTSMENTMOV(Z0L->Z0L_CC,Z0L->Z0L_CC,Dtoc(dDatAnt+1),dToc(dDatProc),"01",1,"3","CTT"))
			nCusto := Abs(CTSMMOV(Dtoc(dDatAnt+1),dToc(dDatProc),"01",1,"3",Z0L->Z0L_CCTINI,Z0L->Z0L_CCTFIN,Z0L->Z0L_CC,Z0L->Z0L_CC,,,,))
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(FwXFilial("SB1")+Z0L->Z0L_COD))
			aArmProporc := {}
			If Z0L->Z0L_CUSARM == "S" // tem Armazem de Custo Prooporcional
				aArmProporc := F_CusArmProporcional() // Calcula Proporcionalidade dos Armazéns
			Endif

			If Z0L->Z0L_VARARM == "S" // produto trabalha com vários Armazéns - Sim ou Não
				aRetProp := F_RetProp(nCusto,dDatAnt+1,dDatProc) // Faz a Proporcionalidade dos itens que trabalharem com mais de um Armazém
				For nCntFor := 1 to Len(aRetProp)
					aadd(aVetMov,{Z0L->Z0L_CC,aRetProp[nCntFor,2],SB1->(Recno()),Z0L->(Recno()),aRetProp[nCntFor,1],aRetProp[nCntFor,3],aArmProporc,Z0L->Z0L_CCTCRE,Z0L->Z0L_CCTDEB})
				Next
			else
				aadd(aVetMov,{Z0L->Z0L_CC,nCusto,SB1->(Recno()),Z0L->(Recno()),SB1->B1_LOCPAD,dDatProc,aArmProporc,Z0L->Z0L_CCTCRE,Z0L->Z0L_CCTDEB})
			Endif
		Endif

		Z0L->(DbSkip())

	Enddo

	If Len(aVetMov) == 0

		MsgInfo("Não há registros a serem processados","Atenção")

	Else

		lMsErroAuto := .f.
		lMsHelpAuto := .t.

		// Faz Movimentação Interna
		Begin Transaction

		cObserva := "Apropriação em Insumos_"+Subs(dToc(dDatAnt+1),4,7)

		For nCntFor := 1 to Len(aVetMov)


			cNumDoc     := GetSXENum("SD3","D3_DOC")
			aItens      := {}

			aCabecalho := {	{"D3_DOC"	    ,  cNumDoc		        ,  NIL},;
							{"D3_TM"    	,  cTMMov    		    ,  NIL},;
							{"D3_CC"    	,  aVetMov[nCntFor,1]	,  NIL},;
							{"D3_EMISSAO"	,  aVetMov[nCntFor,6]	,  Nil}}

			nVarArm := Len(aVetMov[nCntFor,7])
			If nVarArm == 0
				nVarArm := 1
			Endif


			SB1->(DbGoTo(aVetMov[nCntFor,3]))
			IF SB1->B1_MSBLQL == "2"

				For nCntFor2 := 1 to nVarArm

					If nVarArm == 1
					    cLocal  := aVetMov[nCntFor,5]
						nCusto  := aVetMov[nCntFor,2]
					Else
					    cLocal  := aVetMov[nCntFor,7,nCntFor2,1]
						nCusto  := (aVetMov[nCntFor,7,nCntFor2,6]/100) * aVetMov[nCntFor,2]
					Endif
					If nCusto > 0							
						Aadd(aItens, {  {"D3_COD"	 , SB1->B1_COD  	   ,  NIL},;
										{"D3_LOCAL"	 , cLocal              ,  NIL},;
										{"D3_CUSTO1" , nCusto              ,  NIL},;
										{"D3_GRUPO"	 , SB1->B1_GRUPO	   ,  NIL},;
										{"D3_UM"     , SB1->B1_UM      	   ,  NIL},;
										{"D3_OBSERVA", cObserva      	   ,  NIL} })
					EndIf
				Next
/*				Aadd(aItens, {  {"D3_COD"	 , SB1->B1_COD  	   ,  NIL},;
								{"D3_LOCAL"	 , aVetMov[nCntFor,5]  ,  NIL},;
								{"D3_CUSTO1" , aVetMov[nCntFor,2]  ,  NIL},;
								{"D3_GRUPO"	 , SB1->B1_GRUPO	   ,  NIL},;
								{"D3_UM"     , SB1->B1_UM      	   ,  NIL},;
								{"D3_OBSERVA", cObserva      	   ,  NIL} }*/


				if Len(aItens) > 0
					lMsErroAuto := .F.
					MSExecAuto({|x,y| MATA241(x,y)},aCabecalho,aItens)
					If lMsErroAuto
						MostraErro()
						RollBackSX8()
						nCntFor := Len(aVetMov)
					Else
						For nCntFor2 := 1 to nVarArm

							If nVarArm == 1
								nCusto  := aVetMov[nCntFor,2]
							Else
								nCusto  := (aVetMov[nCntFor,7,nCntFor2,6]/100) * aVetMov[nCntFor,2]
							Endif
							If nCusto > 0 
								If !F_LancCtb(aVetMov[nCntFor,8],aVetMov[nCntFor,9],nCusto,aVetMov[nCntFor,6],aVetMov[nCntFor,1]) // Contabilização dos Armazens
									MostraErro()
									RollBackSX8()
									nCntFor := Len(aVetMov)
									loop
								Endif
							EndIf
						Next
						lProcessou := .t.
						Z0L->(DbGoTo(aVetMov[nCntFor,4]))
						RecLock("Z0L",.f.)
						Z0L->Z0L_DATUPR := dDatAnt+1
						MsUnlock()
						ConfirmSX8()
					EndIf
				Endif
			
			Endif

		Next

		End Transaction

		If lProcessou
			MsgInfo("Movimento(s) ocorrido(s) com sucesso!","Atenção")
		Endif

	Endif

Endif

Return

/////////////////////////////q
Static Function F_TelaEstorno()

    Local aArea    := GetArea()
    Local cFunBkp  := FunName()
	Local dDatEst  := GetMV("MV_ULMES")+1
	Local cTitulo  := "Estorno dos Movimentos"
	Local cObserva := "Apropriação em Insumos_"+Subs(dToc(dDatEst+1),4,7)
	Local cTMMov     := GetNewPar("MV_TMCUSTR","402") // tipo de movimentação para Custo do Trato

    SetFunName("VAESTM04")

    oMarkBrwSD3 := FWMarkBrowse():New()
    oMarkBrwSD3:SetAlias("SD3")
    oMarkBrwSD3:SetDescription(cTitulo)
    oMarkBrwSD3:SetFilterDefault('D3_EMISSAO >= "'+dTos(dDatEst)+'" .and. D3_EMISSAO <= "'+dTos(LastDay(dDatEst))+'" .and. D3_OBSERVA = "'+cObserva+'" .and. D3_ESTORNO <> "S" .and. D3_TM == "'+cTMMov+'"')
    oMarkBrwSD3:SetFieldMark('D3_OK')
    //Legenda de Status do Titulo
    //oMarkBrwSD3:AddLegend( "D3_EMISSAO > ", "GREEN","Aberto","1") 
    //oMarkBrwSD3:AddLegend( "D3_EMISSAO < ", "RED",  "Baixado","1")
    
    oMarkBrwSD3:Activate() 
     
    SetFunName(cFunBkp)
    RestArea(aArea)

Return Nil

static function MenuDef()
local aRotina := {}

    AAdd( aRotina, { 'Estorno'        , 'U_EstorM04()', 0, 4, 0, NIL } ) 
    
return aRotina

static function ModelDef()
local oModel := nil
local oStruSD3 := FWFormStruct(1, "SD3")

    oModel := MPFormModel():New('MD_VAESTM04')
    oModel:addFields('MODEL_SD3',,oStruSD3)
    //oModel:SetPrimaryKey({"E2_FILIAL","E2_FILIAL","E2_NUM","E2_PREFIXO","E2_PARCELA","E2_TIPO"})
    
return oModel

static function ViewDef()
local oView     := nil
local oModel    := ModelDef()
local oStrSD3   := FWFormStruct(2, 'SD3')

    oView := FWFormView():New()
    oView:SetModel(oModel) 
    oView:AddField('VIEW_SD3', oStrSD3, 'MODEL_SD3' )
    oView:CreateHorizontalBox( 'BOX_VIEW_SD3', 100)
    oView:SetOwnerView('VIEW_SD3','BOX_VIEW_SD3')
    
return oView

// estorno só mes posterior ao MV_ULMES
User function EstorM04()
    local _aCab1      := {}
    local _aItem      := {}
    local _atotitem   := {}
	local dDatEst     := GetMV("MV_ULMES")+1
	local cD3_COD     := ""
	local cD3_EMISSAO := ""
	local cQry        := ""
	local nRecZ0L     := ""
	local lProcessou  := .f.
	local cObserva    := "Apropriação em Insumos_"+Subs(dToc(dDatEst+1),4,7)
	local nSavRecD3   := 0
	local nCntFor     := 0 	
	local aVetInteg   := {}
	Local cTMMov     := GetNewPar("MV_TMCUSTR","402") // tipo de movimentação para Custo do Trato
    private lMsHelpAuto := .t. // se .t. direciona as mensagens de help
    private lMsErroAuto := .f. //necessario a criacao

    Begin Transaction

    oMarkBrwSD3:SetFilterDefault('D3_EMISSAO >= "'+dTos(dDatEst)+'" .and. D3_EMISSAO <= "'+dTos(LastDay(dDatEst))+'" .and. D3_OBSERVA = "'+cObserva+'" .and. D3_ESTORNO <> "S" .and. D3_TM == "'+cTMMov+'"')
	(oMarkBrwSD3:Alias())->( DbGoTop() )
	While (oMarkBrwSD3:Alias())->( !Eof() )

		If ( oMarkBrwSD3:IsMark() ) // Estorna apenas os títulos selecionados
			nSavRecD3 := (oMarkBrwSD3:Alias())->( Recno() )
			aadd(aVetINteg,nSavRecD3)
		Endif

		(oMarkBrwSD3:Alias())->( DbSkip() )
	
	Enddo

	For nCntFor := 1 to Len(aVetInteg)


			SD3->(DbGoTo(aVetInteg[nCntFor]))

			cD3_COD     := SD3->D3_COD
			cD3_EMISSAO := Dtos(SD3->D3_EMISSAO)
			cD3_OBSERVA := SD3->D3_OBSERVA

			_aCab1 := { {"D3_TM"        ,SD3->D3_TM     , nil},;
						{"D3_EMISSAO"   ,SD3->D3_EMISSAO, nil}}

			_aItem:={ {"D3_COD"     ,SD3->D3_COD        ,nil},;
					  {"D3_UM"      ,SD3->D3_UM         ,nil},;
					  {"D3_QUANT"   ,SD3->D3_QUANT      ,nil},;
					  {"D3_LOCAL"   ,SD3->D3_LOCAL      ,nil}}
				
			aadd(_atotitem,_aitem)
			
			MSExecAuto({|x,y,z| MATA241(x,y,z)},_aCab1,_atotitem,6)
			
			If lMsErroAuto
				mostraErro()
				DisarmTransaction()
				return
			else

				lProcessou := .t.
				cQry := " Select Z0L.R_E_C_N_O_ RECZ0L"                   
				cQry += " From " + RetSqlName( "Z0L" ) + " Z0L "   
				cQry += " Where Z0L.Z0L_FILIAL = '"+FwXFilial("Z0L")+"'"
				cQry += "       And Z0L.D_E_L_E_T_ = ' ' "
				cQry += "       And Z0L.Z0L_COD = '"+cD3_COD+"' "
				cQry += "       And Z0L.Z0L_DATUPR = '"+Dtos(dDatEst)+"' "
	
				nRecZ0L := FM_SQL(cQry)
				If nRecZ0L > 0
					Z0L->(DbGoTo(nRecZ0L))
					RecLock("Z0L",.f.)
					Z0L->Z0L_DATUPR := Ctod("")
					MsUnlock()
				Endif

			endIf

	Next

	End Transaction

	If lProcessou 
		MsgInfo("Estorno(s) ocorrido(s) com sucesso!","Atenção")
	Endif

return

// Verifica se o Produto possui mais de um armazem e retorna uma matriz com a Proporcionaidade
Static Function F_RetProp(nCust,dDatIni, dDatFin)
local cQuery  := ""
local aVetRet := {}
local nTotal  := 0
local nCntFor := 0
local nPos    := 0
Local dDatAnt := GetMV("MV_ULMES")
Local dDatProc:= LastDay(dDatAnt+1)

If Select("TMPSD3") > 0
	TMPSD3->(DbCloseArea())
EndIf

cQuery := "SELECT SD3.D3_LOCAL, SD3.D3_CUSTO1, SD3.D3_EMISSAO "
cQuery += " FROM " +RetSQLName( "SD3" )+" SD3"
cQuery += " WHERE SD3.D3_FILIAL = '"+FwXFilial( "SD3" )+"'"
cQuery += " AND SD3.D3_OP <> ' ' AND SD3.D3_CF = 'PR0'"
cQuery += " AND SD3.D3_COD = '"+Z0L->Z0L_COD+"'"
cQuery += " AND SD3.D3_EMISSAO BETWEEN '"+Dtos(dDatIni)+"' AND '"+Dtos(dDatFin)+"'"
cQuery += " AND SD3.D_E_L_E_T_ = ' '"

TCQUERY cQuery NEW ALIAS "TMPSD3"

While !TMPSd3->(Eof())

	nPos := aScan(aVetRet,{ |x| x[1]== TMPSD3->D3_LOCAL})	
	If nPos == 0
		aadd(aVetRet,{TMPSD3->D3_LOCAL,TMPSD3->D3_CUSTO1,Stod(TMPSD3->D3_EMISSAO)})
	Else
		aVetRet[nPos,2] += TMPSD3->D3_CUSTO1
	Endif

	nTotal += TMPSD3->D3_CUSTO1

	TMPSD3->(DbSkip())

Enddo
TMPSD3->(DbCloseArea())


For nCntFor := 1 to Len(aVetRet)

	aVetRet[nCntFor,2] := ( aVetRet[nCntFor,2] / nTotal ) * nCust

Next

If Len(aVetRet) == 0
	aadd(aVetRet,{SB1->B1_LOCPAD,nCust,dDatProc})
Endif

Return aVetRet

// Calcula Proporcionalidade para o custo do Armazém
Static Function F_CusArmProporcional()
Local dUltMes     := GetMV("MV_ULMES")
Local dDatProc    := LastDay(dUltMes+1)
Local cQuery      := ""
Local nCntFor     := 0
Local nPos        := 0
Local cArmazens   := "'"
Local nValTotMov  := 0


aArmProporc := {}
// 1o Elemento - Armazem
// 2o Elemento - Sdo Inicial
// 3o Elemento - Entradas
// 4o Elemento - Saidas
// 5o Elemento - Valor Final
// 6o Elemento - Percentual da Proporção

// Tipos de Entrada para Levantamento das Entradas no Armazem que terá a Proporcionaidade Calculada. 
// Devem ser separados por Ponto (.), Barra (/) ou Ponto e Virgula (;)
/*
Local cTesEnt := GetNewPar("MV_TEPRARM","402") // Tes de Entrada para 
For nCntFor := 1 to Len(cTesEnt)
	If at(".",cTesEnt) > 0
		cTesEnt := STUFF(cTesEnt,AT(".",cTesEnt),1,"','")
	Endif
	If at("/",cTesEnt) > 0
		cTesEnt := STUFF(cTesEnt,AT("/",cTesEnt),1,"','")
	Endif
	If at(";",cTesEnt) > 0
		cTesEnt := STUFF(cTesEnt,AT(";",cTesEnt),1,"','")
	Endif
Next
*/

// Levanta Entradas
If Select("TMPSD1") > 0
	TMPSD1->(DbCloseArea())
EndIf

cQuery := " SELECT SD1.D1_LOCAL, SD1.D1_CUSTO, SD1.D1_DOC FROM " + RetSqlName( "SD1" ) + " SD1 "
cQuery += "    INNER JOIN " + RetSqlName( "SF4" ) + " SF4 "
cQuery += "    ON ( SF4.F4_FILIAL = '"+FwXFilial("SF4")+"' AND SF4.F4_CODIGO = SD1.D1_TES AND SF4.F4_TRANFIL <> '1' AND SF4.F4_ESTOQUE = 'S' AND SF4.D_E_L_E_T_ = ' ' ) "
cQuery += " WHERE SD1.D1_FILIAL = '"+FwXFilial("SD1")+"' AND SD1.D1_TIPO NOT IN ( 'I', 'P' ) "
cQuery += " AND SD1.D1_EMISSAO BETWEEN '"+Dtos(dUltMes+1)+"' AND '"+Dtos(dDatProc)+"'"
cQuery += " AND SD1.D1_COD = '"+Z0L->Z0L_COD+"' AND SD1.D_E_L_E_T_=' ' "
cQuery += " UNION "
cQuery += " SELECT SD3.D3_LOCAL, SD3.D3_CUSTO1, SD3.D3_DOC FROM " + RetSqlName( "SD3" ) + " SD3 " "
cQuery += " WHERE SD3.D3_FILIAL = '"+FwXFilial("SD1")+"' and  SD3.D3_TM <= '499' AND D_E_L_E_T_ =' ' "
cQuery += " AND D3_EMISSAO BETWEEN '"+Dtos(dUltMes+1)+"' AND '"+Dtos(dDatProc)+"' "
cQuery += " AND D3_COD = '"+Z0L->Z0L_COD+"' --AND D3_LOCAL = 'S2' AND D3_OP <> ' '  "
//cQuery += " AND SD1.D1_TES IN ( '"+cTesEnt+ "' ) "

TCQUERY cQuery NEW ALIAS "TMPSD1"

While !TMPSD1->(Eof())

	nPos := aScan(aArmProporc,{ |x| x[1]== TMPSD1->D1_LOCAL})	
	If nPos == 0
		aadd(aArmProporc,{TMPSD1->D1_LOCAL,0,TMPSD1->D1_CUSTO,0,TMPSD1->D1_CUSTO,0})
		cArmazens += TMPSD1->D1_LOCAL + "','"
	Else
		aArmProporc[nPos,3] += TMPSD1->D1_CUSTO
		aArmProporc[nPos,5] += TMPSD1->D1_CUSTO
	Endif

	TMPSD1->(DbSkip())

Enddo
TMPSD1->(DbCloseArea())

// Levanta Saidas
If Select("TMPSD3") > 0
	TMPSD3->(DbCloseArea())
EndIf

cQuery := "SELECT SD3.D3_LOCAL, SD3.D3_CUSTO1 "
cQuery += " FROM " +RetSQLName( "SD3" )+" SD3"
cQuery += " WHERE SD3.D3_FILIAL = '"+FwXFilial( "SD3" )+"'"
cQuery += " AND SD3.D3_CF = 'RE4'"
cQuery += " AND SD3.D3_COD = '"+Z0L->Z0L_COD+"'"
cQuery += " AND SD3.D3_EMISSAO BETWEEN '"+Dtos(dUltMes+1)+"' AND '"+Dtos(dDatProc)+"'"
cQuery += " AND SD3.D_E_L_E_T_ = ' '"
cQuery += " UNION "
cQuery += " SELECT SD2.D2_LOCAL, SD2.D2_CUSTO1"
cQuery += " FROM " +RetSQLName( "SD2" )+" SD2"
cQuery += "    INNER JOIN " + RetSqlName( "SF4" ) + " SF4 "
cQuery += "    ON ( SF4.F4_FILIAL = '"+FwXFilial("SF4")+"' AND SF4.F4_CODIGO = SD2.D2_TES AND  SF4.F4_ESTOQUE = 'S' AND SF4.D_E_L_E_T_ = ' ' ) "
cQuery += " WHERE D2_FILIAL = '"+FwXFilial( "SD2" )+"'""
cQuery += " AND SD2.D2_COD = '"+Z0L->Z0L_COD+"'"
cQuery += " AND SD2.D2_EMISSAO BETWEEN '"+Dtos(dUltMes+1)+"' AND '"+Dtos(dDatProc)+"'"
cQuery += " AND SD2.D_E_L_E_T_ = ' '"



TCQUERY cQuery NEW ALIAS "TMPSD3"

While !TMPSD3->(Eof())

	nPos := aScan(aArmProporc,{ |x| x[1]== TMPSD3->D3_LOCAL})	
	If nPos == 0
		aadd(aArmProporc,{TMPSD3->D3_LOCAL,0,0,TMPSD3->D3_CUSTO1,-TMPSD3->D3_CUSTO1,0,Z0L->Z0L_CCTCRE,Z0L->Z0L_CCTDEB})
		cArmazens += TMPSD3->D3_LOCAL + "','"
	Else
		aArmProporc[nPos,4] += TMPSD3->D3_CUSTO1
		aArmProporc[nPos,5] -= TMPSD3->D3_CUSTO1
	Endif

	TMPSD3->(DbSkip())

Enddo
TMPSD3->(DbCloseArea())

cArmazens := subs(cArmazens,1,Len(cArmazens)-2)

// Levanta Saldos Iniciais
If Select("TMPSB9") > 0
	TMPSB9->(DbCloseArea())
EndIf

cQuery := "SELECT SB9.B9_VINI1, SB9.B9_LOCAL "
cQuery += " FROM " +RetSQLName( "SB9" )+" SB9"
cQuery += " WHERE SB9.B9_FILIAL = '"+FwXFilial( "SB9" )+"'"
cQuery += " AND SB9.B9_COD = '"+Z0L->Z0L_COD+"'"
cQuery += " AND SB9.B9_LOCAL IN ("+cArmazens+")"
cQuery += " AND SB9.B9_DATA = '"+Dtos(dUltMes)+"'"
cQuery += " AND SB9.D_E_L_E_T_ = ' '"

TCQUERY cQuery NEW ALIAS "TMPSB9"

While !TMPSB9->(Eof())

	nPos := aScan(aArmProporc,{ |x| x[1]== TMPSB9->B9_LOCAL})	
	If nPos > 0
		aArmProporc[nPos,2] += TMPSB9->B9_VINI1
		aArmProporc[nPos,5] += TMPSB9->B9_VINI1
	Endif

	TMPSB9->(DbSkip())

Enddo
TMPSB9->(DbCloseArea())

/*
// Levanta Valor total das Movimentações
For nCntFor := 1 to Len(aArmProporc)

	nValTotMov += aArmProporc[nCntFor,5]
	
Next

// Calcula Percentual de proporcionalidade de cada Armazem
For nCntFor := 1 to Len(aArmProporc)

	aArmProporc[nCntFor,6] := (aArmProporc[nCntFor,5] / nValTotMov) * 100
	
Next
*/


// Levanta Valor total das Movimentações
For nCntFor := 1 to Len(aArmProporc)

	nValTotMov += aArmProporc[nCntFor,5] + aArmProporc[nCntFor,5]
	
Next

// Calcula Percentual de proporcionalidade de cada Armazem
For nCntFor := 1 to Len(aArmProporc)

	aArmProporc[nCntFor,6] := ((aArmProporc[nCntFor,5] + aArmProporc[nCntFor,5]) / nValTotMov) * 100
	
Next

Return aArmProporc


// Lancamento Contabil dos Custos Proporcionais de Armazém
Static Function F_LancCtb(cCtaCre, cCtaDeb,nValorBase,dDatMov,cCenCus)
Local cCCCred     := GetMV("MV_CCAAPRO",,"A02Z1")
Local lOk := .T.
Local aItens := {}
Local aCab := {  {"DDATALANC"  ,dDatMov ,NIL},;
                 {"CLOTE"      ,"009999" ,NIL},;
                 {"CSUBLOTE"   ,"0001" ,NIL},;
                 {"CDOC"       ,STRZERO( seconds() ,6) ,NIL},;
                 {"CPADRAO"    ,"",NIL},;
                 {"NTOTINF"    ,0 ,NIL},;
                 {"NTOTINFLOT" ,0 ,NIL} }

PRIVATE lMsErroAuto := .f.

cHist := "APROP CUST DIR-CC "+cCenCus+" ANOMES: "+Subs(Dtos(dDatMov),1,6)
aAdd(aItens,{  {"CT2_FILIAL" ,FwXFilial("CT2"), NIL},;
				{"CT2_LINHA"  ,"001"   , NIL},;
				{"CT2_MOEDLC" ,"01"   , NIL},;
				{"CT2_DC"     ,"3"   , NIL},;
				{"CT2_DEBITO" ,cCtaDeb , NIL},;
				{"CT2_CREDIT" ,cCtaCre , NIL},;
				{"CT2_CCC"    ,cCCCred , NIL},;
				{"CT2_VALOR"  ,nValorBase , NIL},;
				{"CT2_ORIGEM" ,"VAESTM04", NIL},;
				{"CT2_HP"     ,""   , NIL},;
				{"CT2_HIST"   ,cHist, NIL} } )

MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCab ,aItens, 3)

If lMsErroAuto
	lOk := .F.
EndIf

Return lOk
