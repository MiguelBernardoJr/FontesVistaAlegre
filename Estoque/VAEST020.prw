//##########################################################################################
// Projeto: AVA1000002 - AVA- APONTAMENTOS CUSTO RACAO E ANIMAIS
// Modulo : Estoque/Custos
// Fonte  : vaest020
//----------+------------------------------+------------------------------------------------
// Data     | Autor                        | Descricao
//----------+------------------------------+------------------------------------------------
// 20170310 | jrscatolon informatica       | Criação da rotina de Importação do Trato
//          |                              |
//          |                              |
//----------+-------------------------------------------------------------------------------

#include "Protheus.ch"
#include "FWMVCDef.ch"
#include "Fileio.ch"
#include "FWMBrowse.CH"
#include "TryException.ch"

#IFNDEF _ENTER_
	#DEFINE _ENTER_ (Chr(13)+Chr(10))
	// Alert("miguel")
#ENDIF 

static cTitulo := "Importação do Trato"

/*/
Criar Parâmetro
---------------
Parametro:    VA_GRPINDV
Tipo:         C
Descrição:    Parametro customizado usado pela rotina vaest020. Grupos de produtos que apropriarao os custos de alimentacao separados por '|'.
Conteudo:     BOV
/*/


/*/{Protheus.doc} VAEST020
Browse para rotina de importação de trato.
@return nil
/*/
user function VAEST020()
local oBrowse
private lPTO     := .T.
private cLogFile := ""

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("Z02")
oBrowse:SetDescription(cTitulo)
oBrowse:SetFilterDefault( "Z02_TPARQ == '4'" )
oBrowse:AddLegend( "Z02_TPARQ == '4'", "BLUE"   , "Trato" )
oBrowse:Activate()

return nil

/*/{Protheus.doc} MenuDef
Habilita facilidades de acesso durante o processo de atualização da interface do sistema.
@return aRotina -> Matriz N x 5 contendo detalhes para acesso as rotinas do sistema.
/*/
static function MenuDef()
local aRotina := {}
    ADD OPTION aRotina TITLE "Pesquisar"      ACTION "PesqBrw"          OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE 'Visualizar'     ACTION 'VIEWDEF.VAEST020' OPERATION 2 ACCESS 0
    ADD OPTION aRotina TITLE 'Incluir'        ACTION 'VIEWDEF.VAEST020' OPERATION 3 ACCESS 0
    ADD OPTION aRotina TITLE 'Excluir'        ACTION 'VIEWDEF.VAEST020' OPERATION 5 ACCESS 0
    ADD OPTION aRotina TITLE 'Imprimir'       ACTION 'VIEWDEF.VAEST020' OPERATION 8 ACCESS 0
    ADD OPTION aRotina TITLE 'Importar Trato' ACTION 'u_Est20Trato()'   OPERATION 3 ACCESS 0
return aRotina

/*/{Protheus.doc} ModelDef
Definição da regra de negócios (modelo de dados).
@return oModel -> Objeto do tipo MPformModel.
/*/
static function ModelDef()
local oModel := nil
local oStPai := FWformStruct(1, 'Z02')
local oStFilho := FWformStruct(1, 'Z04')
local aZ04Rel := {}

    oModel := MPformModel():New('EST020')

    oModel:AddFields('Z02MASTER',/*cOwner*/,oStPai)
    oModel:AddGrid('Z04DETAIL','Z02MASTER',oStFilho,/*bLinePre*/, /*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)  //cOwner Ã© para quem pertence

    aAdd(aZ04Rel, {'Z04_FILIAL', 'Z02_FILIAL' })
    aAdd(aZ04Rel, {'Z04_SEQUEN', 'Z02_SEQUEN' })

    oModel:SetRelation('Z04DETAIL', aZ04Rel, Z04->(IndexKey(1)))

    oModel:SetPrimaryKey( {"Z02_FILIAL","Z02_SEQUEN"} )

    oModel:SetDescription("Rotina de Integração de Trato")
    oModel:GetModel('Z02MASTER'):SetDescription('Cabecalho de Importacao')
    oModel:GetModel('Z04DETAIL'):SetDescription('Integração dos Tratos')

    oModel:AddCalc('TOT_SALDO1', 'Z02MASTER', 'Z04DETAIL', 'Z04_CURRAL', 'XX_TOTAL' , 'COUNT', , , "Total Imp. Trato:")

return oModel

/*/{Protheus.doc} ViewDef
Definição da interface e interação com o modelo de dados.
@return oView -> Objeto do tipo FWformView.
/*/
static function ViewDef()
local oView := nil
local oModel := FWLoadModel('VAEST020')

local oStPai := FWformStruct(2, 'Z02')
local oStFilho := FWformStruct(2, 'Z04')
local oStTot1 := FWCalcStruct(oModel:GetModel('TOT_SALDO1'))

// local aStruZ02 := Z02->(DbStruct())
// local aStruZ04 := Z04->(DbStruct())

    oView := FWformView():New()
    oView:SetModel(oModel)

    oView:AddField('VIEW_Z02', oStPai, 'Z02MASTER')
    oView:AddGrid ('VIEW_Z04', oStFilho, 'Z04DETAIL')
    oView:AddField('VIEW_TOT1', oStTot1, 'TOT_SALDO1')

    oView:CreateHorizontalBox('BVIEW_Z02', 15)
    oView:CreateHorizontalBox('BVIEW_Z04', 75)
    oView:CreateHorizontalBox('EMBAIXO', 10)
    oView:CreateVerticalBox('EMBESQ',50 , 'EMBAIXO')

    oView:SetOwnerView('VIEW_Z02', 'BVIEW_Z02')
    oView:SetOwnerView('VIEW_Z04', 'BVIEW_Z04')
    oView:SetOwnerView('VIEW_TOT1', 'EMBESQ')

    oView:EnableTitleView('VIEW_Z02', 'Cabecalho de Importacao')
    oView:EnableTitleView('VIEW_Z04', 'Cadastro de Trato')

    oStPai:RemoveField("Z02_TPARQ")

return oView

/*/{Protheus.doc} u_Est020
Pontos de entrada para tratamento de dados.
@return lRet -> Sempre .T.
/*/
user function Est020()
local aArea := GetArea()
local lRet := .T.
local aParam := ParamIXB
local oObj := aParam[1]
local cIdPonto := aParam[2]
// local cIdModel := oObj:GetId()
local cClasse := oObj:ClassName()

local nLinha := 0
local nQtdLinhas := 0
// local cMsg := ''
local aDados := {}
// local aAux := {}
local cUpd := ""
local cAlias := ""
local _cQry := ""
local xVar := {}
local nI := 0, nJ := 0

if cClasse == 'FWforMGRID'
    nQtdLinhas := oObj:GetQtdLine()
    nLinha     := oObj:nLine
endif

if lPTO
    if cIdPonto ==  'MODELCOMMITTTS'

        if  oObj:NOPERATION == 3

            aDados:=ProcADados(oObj:aDependency[1][2][1][3]:aCols)

            RecLock('Z02',.f.)
                Z02->Z02_CONTEU := U_AToS(aDados)
                Z02->Z02_TPARQ  := '4'
            Z02->(MsUnLock())

            cUpd := "update " + retSQLName("Z04") +" "+_ENTER_
            cUpd += "   set Z04_FILIAL='"+xFilial('Z04')+ "'"+_ENTER_
            cUpd += " where Z04_FILIAL=' ' " + _ENTER_
            cUpd += "   and Z04_SEQUEN='"+Z02->Z02_SEQUEN+ "'"+_ENTER_
            cUpd += "   and D_E_L_E_T_=' ' "+_ENTER_

            if (TCSqlExec(cUpd) < 0)
                if u_IsInException()
                    MsgStop("TCSQLError() " + TCSQLError())
                else
                    Help( ,, 'Help',, 'Erro durante processamento da tabela Z04. ' + TCSQLError(), 1, 0 )
                    final("O sistema será finalizado para mater a integridade dos dados.")
                endif
            endif

            if lRet
				BeginTran()
					TryException
						ProcZ02(aDados, Z02->Z02_SEQUEN )
					CatchException Using oException
						u_ShowException(oException)
						ConOut(oException:ErrorStack)
						DisarmTransaction()
						Final("O sistema será finalizado para garantir a integridade dos dados")
					EndException
				EndTran()
            EndIf
			
        elseif oObj:NOPERATION == 5

            cUpd := "update " + retSQLName("Z04") +" "+_ENTER_
            cUpd += "   set D_E_L_E_T_='*'"+_ENTER_
            cUpd += " where Z04_FILIAL='"+xFilial('Z04')+ "'" + _ENTER_
            cUpd += "   and Z04_SEQUEN='"+Z02->Z02_SEQUEN+ "'"+_ENTER_
            cUpd += "   and D_E_L_E_T_=' ' "+_ENTER_
			
			BeginTran() // Begin Transaction  
				if (TCSqlExec(cUpd) < 0)        
					lRet := .F.
					MsgStop("TCSQLError() " + TCSQLError())
					u_ShowException(oException)
					DisarmTransaction()
				endif
			EndTran() // End Transaction
        endif

    elseif cIdPonto ==  'MODELPOS'

        if oObj:NOPERATION == 5

            cAlias        := GetnextAlias()
            _cQry := " select R_E_C_N_O_ RECNO " + _ENTER_
            _cQry += " from " + RetSQLName('Z04') + _ENTER_
            _cQry += " where " + _ENTER_
            _cQry += "        Z04_filial='"+xFilial('Z04')+ "'" + _ENTER_
            _cQry += " and Z04_sequen='"+Z02->Z02_SEQUEN+ "'" + _ENTER_
            _cQry += " and d_e_l_e_t_ = ' ' "

            DbUseArea(.T.,'TOPCONN',TCGENQRY(,,ChangeQuery(_cQry)),(cAlias),.T.,.T.)
			BeginTran()
				TryException
					while !(cAlias)->(Eof())

						Z04->(DbGoTo((cAlias)->RECNO))

						if !Empty(Z04->Z04_NUMOP)
							xVar := &(Z04->Z04_NUMOP)

							for nI:=1 to Len(xVar)
								for nJ := 1 to Len(xVar[nI])
									u_vaest002( xVar[nI][nJ] )
								next nJ
							next nI
						endif
						(cAlias)->(DbSkip())
					EndDo
				CatchException Using oException
 					lRet := .F.
					u_ShowException(oException)
					ConOut(oException:ErrorStack)
					DisarmTransaction()
				EndException
			EndTran()
            (cAlias)->(DbCloseArea())
        endif
    endif
endif
RestArea(aArea)
return lRet

/*/{Protheus.doc} ProcADADOS
Cria uma matriz Nx9 contendo em cada linha Data Importação, Hora, Curral, Lote, Nro de Cabeças, Dieta, Tot. Aprop, Nro OP, Armazem
@param aDados, Array, Matriz contendo os dados da tabela Z04.
@return aDadAux, Matriz Nx9
/*/
static function ProcADados(aDados)
local aDadAux := {}
local i       := 0

for i:=1 to Len(aDados)
    aDados[i][2] := M->Z02_SEQUEN
    if !aDados[i, Len(aDados[1])]
        aAdd(aDadAux , { DtoC(aDados[i][04]),;  // Z04_DTIMP
                         aDados[i][05],;        // Z04_HRIMP
                         aDados[i][03],;        // Z04_CURRAL
                         aDados[i][06],;        // Z04_LOTE
                         AllTrim(Str(aDados[i][07])),;
                         aDados[i][08],;
                         AllTrim(Str(aDados[i][09])),;
                         AllTrim(Str(aDados[i][10])),;
                         AllTrim(aDados[i][12]),;
                         AllTrim(aDados[i][13])} )
    endif
next i

return aDadAux

/*/{Protheus.doc} Est20Trato
Identifica o arquivo e efetua a importação do trato
@return nil
/*/
user function Est20Trato()
local aSay       := {}
local aButton    := {}
local nOpc       := 0
local Titulo     := 'Importação do Trato/Alimentação'
local cDesc      := 'Esta rotina fará a ' + lower(Titulo)
local cDesc      += ', confome estrutura definida '
local cDesc2     := 'na tabela Z04.'
local lOk        := .T.

    aAdd(aSay, cDesc)
    aAdd(aSay, cDesc2)

    aAdd( aButton, { 1, .T., { || nOpc := 1, FechaBatch() } } )
    aAdd( aButton, { 2, .T., { || FechaBatch() } } )

    formBatch( Titulo, aSay, aButton )
    if nOpc == 1
        lPTO    := .F.
        Processa( { || lOk := procAux()  },'Aguarde','Processando...',.T.)
        lPTO    := .T.
    endif

return nil

/*/{Protheus.doc} procAux
Função Auxilar para tratamento da importação dos dados
@return lOk,
/*/
static function procAux()
local lOk       := .T.
local cNomeFile := ""
local aDados    := U_ImpFile(@cNomeFile)

private cSequencia := ""
private cNumOp := ""
private _aGeral := {}

    FWMsgRun(, {|| lOk := ValidaDados(aDados) },;
							"Validando arquivo")

    if lOk
        BeginTran()
            TryException
                if (Z04RunProc( aDados, cNomeFile ))
                    ApMsgInfo( 'Processamento terminado com sucesso.', 'ATENÇÃO' )
                endif
            CatchException Using oException
                u_ShowException(oException)
                ConOut(oException:ErrorStack)
                DisarmTransaction()
                lOK := .f.
            EndException
        EndTran()
    endif
return lOk

/*/{Protheus.doc} Z04RunProc
Função Tratamento da importação dos dados para as tabelas Z02 e Z04
@return lOk,
/*/
static function Z04RunProc( aDados, cNomeFile )
local aArea          := GetArea()
local lRet           := .T.
local aCposCab      := {}
local aCposDet      := {}
local aAux          := {}
//local cInsumo     := ""
local cReceita      := ""
Local cArmazem      := ""
Local i             := 0

Private cSequencia := ""

if !Empty(aDados)
    if Len(aDados[1]) == 10 //8 .and. aDados[1,6] == 3 // qtd de campos do arquivo de trato
        lRet := .T.

        cSequencia  := u_fChaveSX8('Z02','Z02_SEQUEN')

        aAdd( aCposCab, { 'Z02_FILIAL' , xFilial('Z02') } )
        aAdd( aCposCab, { 'Z02_SEQUEN' , cSequencia      } )
        aAdd( aCposCab, { 'Z02_ARQUIV' , cNomeFile          } )
        aAdd( aCposCab, { 'Z02_DTIMP'  , dDataBase       } )
        aAdd( aCposCab, { 'Z02_TPARQ'  , '4'             } ) // 4 = Z04 - Trato
        aAdd( aCposCab, { 'Z02_CONTEU' , U_ATOS(aDados)     } )

        ProcRegua(Len(aDados))

        for i := 1 to Len(aDados)

            if cToD(aDados[i,01]) <>  dDataBase
                MsgStop("Erro na linha [" + AllTrim(Str(i)) + "]. A data do Trato definida no arquivo [" + aDados[i,01] + "] é diferente da data base [" + DToC(dDataBase) + "].")
            endif
            if GetNewPar("VA_CODPROD","PROTHEUS") != "PROTHEUS"
                if Empty(cReceita := AllTrim(u_GetExata(aDados[i][06])))
                    MsgStop("Erro na linha [" + AllTrim(Str(i)) + "]. O código do produto tipo receita [" + AllTrim(aDados[i][06]) + "] não possui contrapartida para código de produto do Protheus.")
                endif
                aDados[i][06] := cReceita
            endif
            aAux := {}

            aAdd( aAux, { 'Z04_FILIAL', xFilial('Z04') } )
            aAdd( aAux, { 'Z04_SEQUEN', cSequencia } )
            aAdd( aAux, { 'Z04_DTIMP',  cToD(aDados[i,01]) } )
            aAdd( aAux, { 'Z04_HRIMP',  aDados[i,02] } )
            aAdd( aAux, { 'Z04_CURRAL', aDados[i,03] } )
            aAdd( aAux, { 'Z04_LOTE',   aDados[i,04] } )
            aAdd( aAux, { 'Z04_NROCAB', Val(aDados[i,05]) } )
            aAdd( aAux, { 'Z04_DIETA',  aDados[i][06] } )
            aAdd( aAux, { 'Z04_TOTREA', Val(aDados[i,07]) } )
            aAdd( aAux, { 'Z04_TOTAPR', Val(aDados[i,08]) } )
            aAdd( aAux, { 'Z04_ARMAZE', cArmazem:=aDados[i,09] } )
            aAdd( aAux, { 'Z04_ARMDIE', aDados[i,10] } )
            aAdd( aCposDet, aAux )
        next i

        lRet := va020imp( 'Z02', 'Z04', aCposCab, aCposDet, 'VAEST020' )
		If lRet
			ProcZ02(aDados, cSequencia, cArmazem)
		EndIf
    else
        MsgStop("O arquivo processado possui a quantidade de campos diferente de 9. Nao se trata de um arquivo de Trato.")
    endif
endif
RestArea(aArea)
return lRet

/*/{Protheus.doc} ProcZ02
Realiza o processamento das tabelas Z02 e Z04 e cria as ordens de produção
para custeio dos lotes.
@param aDados, Array, Matriz contendo os detalhes de alimentação dos lotes
@return nil
/*/
static function ProcZ02(aDados, cSequencia, cArmazem)
// local aAux := {}
// local cArmz := "01"
// local cCodPro := ""
// local nQuant := 0
local i := 0
local x := 0
// local cUpd := ""
local aNumOp    := {}
//Local aAuxNumOp := {}
Local aEmpenho  := {}
Local cBov,cLote, cArmz
Local nQuant
Local cAuxNumOp := ""

Default cArmazem  := "01"

If Type("__DATA") == "U"
	Private __DATA		:= iIf(IsInCallStack("U_JOBPrcLote"), MsDate(), dDataBase)
EndIf
If Type("cFile") == "U"
	Private cFile 		:= "C:\TOTVS_RELATORIOS\JOBPrcLote_" + DtoS(__DATA) + ".TXT"
EndIf

ProcRegua(Len(aDados))

If Len(aDados) > 0
	If !Empty( _cMSG := Z04xSB2Sld020( cSequencia ) )
		MemoWrite( GetTempPath() + "TRATO_"+AllTrim(cSequencia)+"SB2.TXT", _cMSG)
		MsgStop(_cMSG)
	EndIf
	
	If !Empty( _cMSG := Z04xSB8Sld020( cSequencia, cArmazem ) )
		MemoWrite( GetTempPath() + "TRATO_"+AllTrim(cSequencia)+"SB8.TXT", _cMSG)
		MsgStop(_cMSG)
	EndIf
	
	If !Empty( _cMSG := LoteZ04xSB8( cSequencia ) )
		MemoWrite( GetTempPath() + "TRATO_"+AllTrim(cSequencia)+"Z04xSB8.TXT", _cMSG)
		MsgStop(_cMSG)
	EndIf
EndIf

aNumOp    := {}

for i := 1 to Len(_aGeral)
    // indice: B1LOTE
    // campo: B1_XLOTE
    // procLote( cLote , cRacao, nQuant, cArmz )
    // procLote( aDados[i,04], Upper(aDados[i,06]), Val(aDados[i,08]), aDados[i,09] )

    cBov        := _aGeral[i,01]
    nQuant      := _aGeral[i,02]
    cArmz       := _aGeral[i,03]
    aEmpenho    := aClone(_aGeral[i,04])
    cLote       := _aGeral[i,05]

    IncProc("Atualizaando lote " + AllTrim(_aGeral[i,05]) + "...")

    U_GravaArq( iIf(IsInCallStack("U_JOBPrcLote"), cFile, ""),;
                    "Processando [VAEST020: ProcZ02]" + _ENTER_ + "Processando dados ["+ StrZero(i,5) + " de " + StrZero(Len(_aGeral[i,04]),5) + ": " + AllTrim(_aGeral[i,03]) +"]",;
                    .T./* lConOut */,;
                    /* lAlert */ )
    //Toshio                                                    /*  */               /**/                 /**/
                //static function ProcLote(   cLote        , cRacao, nQuant, cArmzRac  ,  cArmz       )

    FWMsgRun(, {|| cAuxNumOp := u_vaest021( cBov, nQuant, cArmz, aEmpenho, cLote ) },;
                        "Processando [VAEST020: ProcLote]",;
                        "Processando dados ["+ StrZero(i,5) + ' de ' + StrZero(Len(_aGeral),5) + ": " + AllTrim(_aGeral[i,01]) +"]")

    IF Len(aNumOp) == 0
        AAdd( aNumOp ,{ cLote , { cAuxNumOp } })
    else
        if (nPosLote := aScan(aNumOp , {|y| AllTrim(y[1])==cLote})) == 0
            AAdd( aNumOp ,{ cLote , { cAuxNumOp } })
        else
            if ( nPos := aScan(aNumOp[nPosLote][2] , {|x| AllTrim(x)==cAuxNumOp } )) == 0
                AAdd( aNumOp[nPosLote,2], cAuxNumOp )
            endif
        endif 
    endif
next i

//_vVendas[n][1] = Código do gerente
//_vVendas[n][2] = Valor das vendas do gerente
//_vVendas[n][3] = Quantidade vendida do gerente
//_vVendas[n][4][z][1] = Código do vendedor
//_vVendas[n][4][z][2] = Valor do vendedor
//_vVendas[n][4][z][3] = Quantidade do vendedor
//
//Nesse caso, uma forma bem simples de fazer a busca seria:
//
//_cVendedor:=‘000050‘ // Este é o vendedor a quem quero localizar
//
//for _nPosicGer:=1 to len(_vVendas)
//    _nPosicVen:=ascan(_vVendas[_nPosicGer][4],{|_vAux| _vAux[1]==_cVendedor})
//    if _nPosicVen>0
//       // Se chegou aqui, esta é a 1a ocorrência desse vendedor
//       exit
//    endif
//next

Z04->(DbSetOrder(1))
For i := 1 to Len(aNumOp)
    if Z04->(DbSeek(xFilial('Z04')+cSequencia+aNumOp[i,01]))
        while rTrim(xFilial('Z04')+cSequencia+aNumOp[i,01]) == rTrim(Z04->(Z04_FILIAL+Z04_SEQUEN+Z04_LOTE))
            RecLock('Z04', .f.)
                Z04->Z04_NUMOP := u_AToS(aNumOp[i,02])
            Z04->(MsUnLock())

            Z04->(DbSkip())
        enddo 
    endif
Next i

return nil

/*/{Protheus.doc} ProcLote
Função responsável pela valorização do custeio do Lote, vinculando o Insumo ao Lote
@param cLote, Character, Numero do lote processado
@param cRacao, Character, Código do produto insumo usado para alimentar o Lote
@param nQuant, Character, Quantidade de insumo usado na alimentação do Lote
@param cArmz, Character, local onde está o insumo usado para alimentar o Lote
@return nil
/*/
//static function ProcLote(cLote, cRacao, nQuant, cArmz, cArmzRac)
static function ProcLote(cLote, aRacao, cArmz)
    local nRegistros := 0
    local cAlias 	 := CriaTrab(,.f.)
    local i 		 := 0
    local x 		 := 0
    local nQtdApro 	 := 0
    local aNumOp 	 := {}
    Local cAuxNumOp  := ""
    local cInGrpInd  := "'" + StrTran(GetMV("VA_GRPINDV"), "|", "', '") + "'"
    local cSql 		 := ""
    Local aCpyRacao  := {}

    If Type("__DATA") == "U"
        Private __DATA		:= iIf(IsInCallStack("U_JOBPrcLote"), MsDate(), dDataBase)
    EndIf
    If Type("cFile") == "U"
        Private cFile 		:= "C:\TOTVS_RELATORIOS\JOBPrcLote_" + DtoS(__DATA) + ".TXT"
    EndIf

    cSql := " with estoque as ( " +_ENTER_+;
                "  select B8_LOTECTL " +_ENTER_+;
                "       , B1_GRUPO " +_ENTER_+;
                "       , B1_COD " +_ENTER_+;
                "       , B8_FILIAL " +_ENTER_+;
                "       , B8_LOCAL " +_ENTER_+;
                "       , B8_SALDO, B8_NUMLOTE " +_ENTER_+;
                "  from " + RetSqlName('SB8') + " SB8 " +_ENTER_+;
                "  join " + RetSqlName('SB1') + " SB1 " +_ENTER_+;
                "      on SB1.B1_FILIAL  = '" + xFilial("SB1") + "' " +_ENTER_+;
                "      and SB1.B1_COD     = SB8.B8_PRODUTO " +_ENTER_+;
                "      and SB1.B1_GRUPO  in (" + cInGrpInd + ")" +_ENTER_+;
                " 	 and SB8.B8_LOTECTL = '" + cLote + "'" +_ENTER_+;
                " 	 and SB8.B8_LOCAL   = '" + cArmz + "'" +_ENTER_+;
                "      and SB1.D_E_L_E_T_ = ' ' " +_ENTER_+;
                "  where SB8.B8_FILIAL  = '" + xFilial("SB8") + "' " +_ENTER_+;
                " 	 and SB8.B8_DATA <= '" + dToS(dDataBase) + "'" +_ENTER_+;
                " 	 and SB8.B8_SALDO > 0 " +_ENTER_+;
                "      and SB8.D_E_L_E_T_ = ' ' " +_ENTER_+;
                "  ), " +_ENTER_+;
                "  quant as ( " +_ENTER_+;
                "  select B8_LOTECTL, count(*) QTDREG " +_ENTER_+;
                "  from estoque " +_ENTER_+;
                "  WHERE B8_FILIAL  = '" + xFilial("SB8") + "' " +_ENTER_+;
                "    AND B8_LOCAL   = '" + cArmz + "'" +_ENTER_+;
                "    AND B8_SALDO > 0 " +_ENTER_+;
                "  group by B8_LOTECTL " +_ENTER_+;
                "  ) " +_ENTER_+;
                "  select estoque.B8_LOTECTL " +_ENTER_+;
                "       , estoque.B1_GRUPO " +_ENTER_+;
                "       , estoque.B1_COD " +_ENTER_+;
                "       , estoque.B8_FILIAL " +_ENTER_+;
                "       , estoque.B8_LOCAL " +_ENTER_+;
                "       , estoque.B8_SALDO, estoque.B8_NUMLOTE " +_ENTER_+;
                "       , total.TOTAL " +_ENTER_+;
                "       , quant.QTDREG " +_ENTER_+;
                "  from estoque " +_ENTER_+;
                "  join quant " +_ENTER_+;
                "  on quant.B8_LOTECTL = estoque.B8_LOTECTL " +_ENTER_+;
                "  join ( " +_ENTER_+;
                "         select B8_LOTECTL " +_ENTER_+;
                "            , sum(B8_SALDO) TOTAL " +_ENTER_+;
                "         from estoque " +_ENTER_+;
                "         group by B8_LOTECTL " +_ENTER_+;
                "     ) total " +_ENTER_+;
                "  on total.B8_LOTECTL = estoque.B8_LOTECTL " +_ENTER_+;
                "  order by estoque.B8_LOTECTL " +_ENTER_+;
                "         , estoque.B1_COD "

    MemoWrite( "C:\TOTVS_RELATORIOS\VAEST020-ProcLote.SQL", cSql)
    
    DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSql),(cAlias),.T.,.T.)

    //(cAlias)->(DbEval({|| nRegistros++ }))
    if (cAlias)->QTDREG == 0 //nRegistros == 0
        MsgStop("Não foi encontrado nenhum animal para o Lote: [" + AllTrim(cLote) + "]. Por favor Verifique." )
    endif

    i := 0
    nQtdApro := 0
    aNumOp := {}
	
    (cAlias)->(DbEval({|| nRegistros++ }))
	(cAlias)->(DbGoTop())

    while !(cAlias)->(Eof())
        i++

            aCpyRacao := aClone(aRacao)
            
            For x := 1 to Len(aCpyRacao)
                aCpyRacao[x,3] := aCpyRacao[x,3] * (cAlias)->(B8_SALDO/TOTAL)
            next x

			U_GravaArq( iIf(IsInCallStack("U_JOBPrcLote"), cFile, ""),;
						 "Processando [VAEST020: ProcLote]"+_ENTER_+"Processando dados ["+ StrZero(i,5) + ' de ' + StrZero(nRegistros,5) + ": " + AllTrim((cAlias)->B1_COD) +"]",;
						  .T./* lConOut */,;
						  /* lAlert */ )
			FWMsgRun(, {|| cAuxNumOp := u_vaest021( (cAlias)->B1_COD, (cAlias)->B8_SALDO, cArmz, aCpyRacao, (cAlias)->B8_LOTECTL ) },;
							"Processando [VAEST020: ProcLote]",;
							"Processando dados ["+ StrZero(i,5) + ' de ' + StrZero(nRegistros,5) + ": " + AllTrim((cAlias)->B1_COD) +"]")
			AAdd( aNumOp , cAuxNumOp )
      
        (cAlias)->(DbSkip())
    end
    (cAlias)->(DbCloseArea())

return  aNumOp

//-------------------------------------------------------------------
// Importacao dos dados
//-------------------------------------------------------------------
static function va020imp( cMaster, cDetail, aCpoMaster, aCpoDetail, cModel )
local oModel, oAux, oStruct	
local nI         := 0
local nJ         := 0
local nPos         := 0
local lRet        := .T.
local aAux
// local aC
// local aH
local nItErro
local lAux

dbSelectArea( cDetail )
dbSetOrder( 1 )

dbSelectArea( cMaster )
dbSetOrder( 1 )

// Aqui ocorre o instânciamento do modelo de dados (Model)
// Neste exemplo instanciamos o modelo de dados do fonte COMP022_MVC
// que é a rotina de manutenção de musicas
oModel := FWLoadModel( cModel )

// Temos que definir qual a operação deseja: 3 - Inclusão / 4 - Alteração / 5 - Exclusão
oModel:SetOperation( 3 )

// Antes de atribuirmos os valores dos campos temos que ativar o modelo
oModel:Activate()

// Instanciamos apenas a parte do modelo referente aos dados de cabeçalho
oAux := oModel:GetModel( cMaster + 'MASTER' )

// Obtemos a estrutura de dados do cabeçalho
oStruct := oAux:GetStruct()
aAux := oStruct:GetFields()

if lRet
    for nI := 1 To Len( aCpoMaster )
        // Verifica se os campos passados existem na estrutura do cabeçalho
        if ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aCpoMaster[nI][1] ) } ) ) > 0

            // É feita a atribuição do dado ao campo do Model do cabeçalho
            if !( lAux := oModel:SetValue( cMaster + 'MASTER', aCpoMaster[nI][1], aCpoMaster[nI][2] ) )

                // Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
                // o método SetValue retorna .F.
                lRet := .F.
                Exit
            endif
        endif
    next
endif

if lRet
    // Instanciamos apenas a parte do modelo referente aos dados do item
    oAux := oModel:GetModel( cDetail + 'DETAIL' )

    // Obtemos a estrutura de dados do item
    oStruct := oAux:GetStruct()
    aAux     := oStruct:GetFields()
    nItErro    := 0

    for nI := 1 to Len(aCpoDetail)
        // Incluímos uma linha nova
        // ATENÇÃO: Os itens são criados em uma estrutura de grid (forMGRID) portanto já é criada uma primeira linha
        //branco automaticamente, desta forma começamos a inserir novas linhas a partir da 2a vez
        if nI > 1
            // Incluímos uma nova linha de item
            if ( nItErro := oAux:AddLine() ) <> nI
                // Se por algum motivo o método AddLine() não consegue incluir a linha,
                // ele retorna a quantidade de linhas já
                // existem no grid. Se conseguir retorna a quantidade mais 1
                lRet := .F.
                Exit
            endif
        endif

        for nJ := 1 To Len( aCpoDetail[nI] )
            // Verifica se os campos passados existem na estrutura de item
            if ( nPos := aScan( aAux, { |x| AllTrim( x[3] ) == AllTrim( aCpoDetail[nI][nJ][1] ) } ) ) > 0
                if !( lAux := oModel:SetValue( cDetail + 'DETAIL', aCpoDetail[nI][nJ][1], aCpoDetail[nI][nJ][2] ) )
                    // Caso a atribuição não possa ser feita, por algum motivo (validação, por exemplo)
                    // o método SetValue retorna .F.
                    lRet := .F.
                    nItErro := nI
                    Exit
                endif
            endif
        next
        if !lRet
            exit
        endif
    next
endif

if lRet
    // Faz-se a validação dos dados, note que diferentemente das tradicionais "rotinas automáticas"
    // neste momento os dados não são gravados, são somente validados.
    if ( lRet := oModel:VldData() )
        // Se os dados foram validados faz-se a gravação efetiva dos dados (commit)
        oModel:CommitData()
    endif
endif

if !lRet
    // Se os dados não foram validados obtemos a descrição do erro para gerar
    // LOG ou mensagem de aviso
    aErro := oModel:GetErrorMessage()

    if !Empty(aErro[1])
        AutoGrLog( "Id do formulário de origem: " + ' [' + AllToChar( aErro[1] ) + ']' )
    endif
    if !Empty(aErro[2])
        AutoGrLog( "Id do campo de origem: "      + ' [' + AllToChar( aErro[2] ) + ']' )
    endif
    if !Empty(aErro[3])
        AutoGrLog( "Id do formulário de erro: "   + ' [' + AllToChar( aErro[3] ) + ']' )
    endif
    if !Empty(aErro[4])
        AutoGrLog( "Id do campo de erro: "        + ' [' + AllToChar( aErro[4] ) + ']' )
    endif
    if !Empty(aErro[5])
        AutoGrLog( "Id do erro: "                 + ' [' + AllToChar( aErro[5] ) + ']' )
    endif
    if !Empty(aErro[6])
        AutoGrLog( "Mensagem do erro: "           + ' [' + AllToChar( aErro[6] ) + ']' )
    endif
    if !Empty(aErro[7])
        AutoGrLog( "Mensagem da solução: "        + ' [' + AllToChar( aErro[7] ) + ']' )
    endif
    if !Empty(aErro[8])
        AutoGrLog( "Valor atribuído: "            + ' [' + AllToChar( aErro[8] ) + ']' )
    endif
    if !Empty(aErro[9])
        AutoGrLog( "Valor anterior: "             + ' [' + AllToChar( aErro[9] ) + ']' )
    endif

    MsgStop(MemoRead(NomeAutoLog()))

endif

// Desativamos o Model
oModel:DeActivate()

return lRet

/*/{Protheus.doc} IsInException()
Verifica se foi habilitado o tratamento de excessão
@return .T. se existir uma exeção habilitada, .f. caso contrario
/*/
user function IsInException()
return Type("aTryException") == "A" .and. Type("nTryException") == "N" .and. !Empty(aTryException) .and. nTryException > 0

/* MJ : 24.07.2018
	Validar SQL; */
Static Function Z04xSB2Sld020( cSequencia )

Local _cQry 	:= ""
Local _cAlias   := CriaTrab(,.F.)   
Local _cMSG		:= ""

_cQry := " WITH TRATO AS ( " + _ENTER_
_cQry += " 		SELECT	 Z04_FILIAL FILIAL, rTrim(Z04_DIETA) PRODUTO, SUM(Z04_TOTAPR) QUANT " + _ENTER_
_cQry += " 		FROM	 "+ RetSqlName('Z04') +" " + _ENTER_
_cQry += " 		WHERE	 Z04_FILIAL = '"+ xFilial('Z04') + "'" + _ENTER_
_cQry += "			 AND Z04_SEQUEN ='" + cSequencia + "'" + _ENTER_
_cQry += " 		     AND D_E_L_E_T_=' ' " + _ENTER_
_cQry += " 		GROUP BY Z04_FILIAL, Z04_DIETA " + _ENTER_
_cQry += " ), " + _ENTER_
_cQry += " " + _ENTER_
_cQry += " SALDO_B2 AS ( " + _ENTER_
_cQry += " 		SELECT	B2_FILIAL FILIAL, rTrim(B2_COD) PRODUTO, SUM(B2_QATU) QUANT " + _ENTER_
_cQry += " 		FROM	"+ RetSqlName('SB2') + _ENTER_
_cQry += " 		WHERE	B2_FILIAL = '"+xFilial('SB2')+ "'" + _ENTER_
_cQry += " 			AND D_E_L_E_T_=' ' " + _ENTER_
_cQry += " 		GROUP BY B2_FILIAL, B2_COD " + _ENTER_
_cQry += " 		HAVING SUM(B2_QATU) > 0 " + _ENTER_
_cQry += " ) " + _ENTER_
_cQry += " " + _ENTER_
_cQry += " SELECT B.FILIAL, B.PRODUTO, rTrim(B1_DESC) DESCRICAO, B.QUANT QTD_APONT, S.QUANT QTD_SB2, B.QUANT-S.QUANT DIFERENCA " + _ENTER_
_cQry += " FROM TRATO B " + _ENTER_ 
_cQry += " JOIN SALDO_B2 S ON B.FILIAL=S.FILIAL AND B.PRODUTO=S.PRODUTO " + _ENTER_
_cQry += " 					AND B.QUANT > S.QUANT " + _ENTER_
_cQry += " JOIN SB1010  B1 ON B1_FILIAL=' ' AND B1_COD=B.PRODUTO AND B1.D_E_L_E_T_=' ' " + _ENTER_
_cQry += " ORDER BY B.FILIAL, B.PRODUTO " + _ENTER_

MemoWrite( "C:\TOTVS_RELATORIOS\VAEST020-B2.SQL", _cQry)

dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.)

While !(_cAlias)->(Eof())

	If (_cAlias)->DIFERENCA > GetMV("VA_DIFTRAT",,1)
		_cMSG 	+= Iif( Empty(_cMSG), _ENTER_ + "Saldo não é suficiente para o(s) produto(s): " + _ENTER_, "" )
		_cMSG	+= AllTrim( (_cAlias)->PRODUTO ) + "-" + AllTrim( (_cAlias)->DESCRICAO )
		_cMSG	+= ", demanda: "    + AllTrim(Transform( (_cAlias)->QTD_APONT, '@E 999,999,999.99')) 
		_cMSG	+= ", disponivel: " + AllTrim(Transform( (_cAlias)->QTD_SB2  , '@E 999,999,999.99'))
		_cMSG	+= ", diferença: "  + AllTrim(Transform( (_cAlias)->DIFERENCA, '@E 999,999,999.9999')) + _ENTER_
	EndIf
	
	(_cAlias)->(DbSkip())
EndDo

(_cAlias)->(DbCloseArea())
Return _cMSG

/* MJ : 25/07/18
	=> Processar Lotes indisponiveis; */
Static Function Z04xSB8Sld020( cSequencia, cArmazem )

Local _cQry 	:= ""
Local _cAlias   := CriaTrab(,.F.)   
Local _cMSG		:= ""
Default cArmazem  := "01"

_cQry := " WITH TRATO AS ( " + _ENTER_
_cQry += " 		SELECT	 DISTINCT Z04_FILIAL FILIAL, rTrim(Z04_LOTE) LOTE " + _ENTER_
_cQry += " 		FROM	 "+ RetSqlName('Z04') +" " + _ENTER_
_cQry += " 		WHERE	 Z04_FILIAL = '"+ xFilial('Z04') + "'" + _ENTER_
_cQry += "			 AND Z04_SEQUEN ='" + cSequencia + "'" + _ENTER_
_cQry += " 		     AND D_E_L_E_T_=' ' " + _ENTER_
_cQry += " ), " + _ENTER_
_cQry += " " + _ENTER_
_cQry += " SALDO_B8 AS ( " + _ENTER_
_cQry += " 		SELECT	B8_FILIAL FILIAL, rTrim(B8_LOTECTL) PRODUTO, SUM(B8_SALDO) SALDO " + _ENTER_
_cQry += " 		FROM	"+ RetSqlName('SB8') +" " + _ENTER_
_cQry += " 		WHERE	B8_FILIAL='"+xFilial('SB8')+ "'" + _ENTER_
_cQry += "          AND B8_LOCAL='" + cArmazem + "' " + _ENTER_
_cQry += "          AND D_E_L_E_T_=' ' " + _ENTER_
_cQry += " 		GROUP BY B8_FILIAL, B8_LOTECTL " + _ENTER_
_cQry += " 		HAVING SUM(B8_SALDO) > 0 " + _ENTER_
_cQry += " ) " + _ENTER_
_cQry += " " + _ENTER_ 
_cQry += " SELECT T.FILIAL, T.LOTE, S.SALDO " + _ENTER_
_cQry += " FROM TRATO T " + _ENTER_
_cQry += " JOIN SALDO_B8 S ON T.FILIAL=S.FILIAL AND T.LOTE=S.PRODUTO " + _ENTER_
_cQry += " 					AND S.SALDO <= 0 " + _ENTER_
_cQry += " ORDER BY T.FILIAL, T.LOTE " + _ENTER_

MemoWrite( "C:\TOTVS_RELATORIOS\VAEST020-B8.SQL", _cQry)

dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.)

While !(_cAlias)->(Eof())

    _cMSG 	+= Iif( Empty(_cMSG), _ENTER_ + "Lotes não possuem animais disponiveis: " + _ENTER_, "" )
    _cMSG	+= AllTrim( (_cAlias)->LOTE ) + _ENTER_
    // _cMSG	+= ", saldo: "  + AllTrim(Transform( (_cAlias)->SALDO, '@E 999,999,999.99')) + _ENTER_

    (_cAlias)->(DbSkip())
EndDo

(_cAlias)->(DbCloseArea())
Return _cMSG



/* MJ : 26/07/18
	=> Processar Lotes inexistentes; */
Static Function LoteZ04xSB8( cSequencia )

Local _cQry 	:= ""
Local _cAlias   := CriaTrab(,.F.)
Local _cMSG		:= ""

_cQry := " SELECT	DISTINCT Z04_LOTE" + _ENTER_
_cQry += "	FROM	"+ RetSqlName('Z04') +" " + _ENTER_
_cQry += "	WHERE	Z04_FILIAL ='" + xFilial('Z04') + "'" + _ENTER_
_cQry += "	    AND Z04_SEQUEN ='" + cSequencia + "'" + _ENTER_
_cQry += "		AND NOT EXISTS (" + _ENTER_
_cQry += "			SELECT	1" + _ENTER_
_cQry += "			FROM	"+ RetSqlName('SB8') +" B8" + _ENTER_
_cQry += "			WHERE	Z04_FILIAL=B8_FILIAL" + _ENTER_
_cQry += "				AND Z04_LOTE=B8_LOTECTL" + _ENTER_
_cQry += "				AND B8.D_E_L_E_T_=' '" + _ENTER_
_cQry += "		)" + _ENTER_
_cQry += "		AND D_E_L_E_T_=' ' " + _ENTER_

MemoWrite( "C:\TOTVS_RELATORIOS\VAEST020-Z04xB8.SQL", _cQry)

dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),(_cAlias),.F.,.F.)

While !(_cAlias)->(Eof())

	_cMSG 	+= Iif( Empty(_cMSG), _ENTER_ + "Lote(s) informado(s) no trato não foram localizados na tabela de lotes (SB8): " + _ENTER_, "" )
	_cMSG	+= AllTrim( (_cAlias)->Z04_LOTE ) + _ENTER_
	
	(_cAlias)->(DbSkip())
EndDo

(_cAlias)->(DbCloseArea())
Return _cMSG

Static Function ValidaDados(aDados)
    Local aArea     := FwGetArea()
    Local lRet      := .T.
    Local i         := 0
    Local x         := 0
    Local aCopia    := {}
    Local aLinha    := {}
    Local oSaldoB2  := FWTemporaryTable():New(GetNextAlias())
    Local cAlias    := ""
    Local aFields   := {}
    Local nPosLote  := 0
    Local cLote
    DbSelectArea("SC2")
    DbSetorder(1) // C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD

    DbSelectArea("SB1")
    DbSetOrder(1) // B1_FILIAL+B1_COD

    DbSelectArea("SB8")
    DbSetOrder(1) // B8_FILIAL+B8_COD+B8_LOCAL

    for i := 1 to Len(aDados)
        if Val(aDados[i,08]) > 0
            cLote := aDados[i][4]
            if i == 1
                aAdd(aCopia,{aDados[i][1],;              //DATA
                                aDados[i][2],;              //HORA
                                aDados[i][3],;              //CURRAL
                                aDados[i][4],;              //LOTE
                                aDados[i][5],;              //Z04_NROCAB
                                {{UPPER(aDados[i][06]),;    //PRODUTO
                                    aDados[i][10],;          //ARMAZEM RACAO
                                    Val(aDados[i][08])}},;   //QUANTIDADE RACAO
                                aDados[i][07],;             //
                                aDados[i][09]})             //
            else
                if (nPosLote := aScan(aCopia , {|y| AllTrim(y[4])==cLote})) == 0
                    aAdd(aCopia,{aDados[i][01],;
                                aDados[i][02],;
                                aDados[i][03],;
                                aDados[i][04],;
                                aDados[i][05],;
                                {{UPPER(aDados[i][06]),;
                                    aDados[i][10],;
                                    Val(aDados[i][08])}},;
                                aDados[i][07],;
                                aDados[i][09]})
                else
                    if aCopia[nPosLote,08] != aDados[i,09]
                        aAdd(aCopia,{aDados[i][01],;
                                    aDados[i][02],;
                                    aDados[i][03],;
                                    aDados[i][04],;
                                    aDados[i][05],;
                                    {{UPPER(aDados[i][06]),;
                                        aDados[i][10],;
                                        Val(aDados[i][08])}},;
                                    aDados[i][07],;
                                    aDados[i][09]})
                    else
                        aAdd(aCopia[nPosLote][6],{   UPPER(aDados[i][06]),;
                                                        aDados[i][10],;
                                                        Val(aDados[i][08])})
                    endif
                endif 
            endif
        else
            MsgStop("Linha ["+StrZero(i,4)+"] com quantidade zerada. Processamento será iterrempido")
            lRet :=  .F.
            exit
        endif
    next i

    if lRet 
        For i := 1 to Len(aCopia)
            aLinha := {}                            //LOTE        ARRAY         ARMAZEM
            FWMsgRun(, {|| aLinha := ValidaLotes(  aCopia[i,04] , aCopia[i,06], aCopia[i,08]  ) },;
                                "Processando [VAEST020: ValidaLotes]",;
                                "Processando dados ["+ StrZero(i,5) + ' de ' + StrZero(Len(aDados),5) + ": " + aCopia[i,04]  +"]")

            if Empty(aLinha)
                MsgStop("Não foi encontrado nenhum animal para o Lote: [" + AllTrim(aCopia[i,04]) + "] no armazem: [" + AllTrim(aCopia[i,08]) + "] . Por favor Verifique." )
                lRet := .F.
                exit
            else
                For x := 1 to Len(aLinha)
                    aAdd(_aGeral,aLinha[x])
                next x
            endif
        next i
    endif

    aAdd(aFields, {"CODIGO"  ,TamSx3("B2_COD")[3]    , TamSx3("B2_COD")[1]   , TamSx3("B2_COD")[2]})
    aAdd(aFields, {"ARMAZEM" ,TamSx3("B2_LOCAL")[3] , TamSx3("B2_LOCAL")[1], TamSx3("B2_LOCAL")[2]})
    aAdd(aFields, {"QUANT"   ,TamSx3("B2_QATU")[3]   , TamSx3("B2_QATU")[1]  , TamSx3("B2_QATU")[2]})

    oSaldoB2:SetFields( aFields )
    oSaldoB2:AddIndex("1", {"CODIGO","ARMAZEM"} )
    oSaldoB2:Create()
    cAlias := oSaldoB2:GetAlias()

    if lRet
        For i := 1 to Len(_aGeral)
            For x := 1 to Len(_aGeral[i,4])
                if SB1->(DbSeek(xFilial("SB1")+_aGeral[i,4,x,1]))

                    if Empty(_aGeral[i,4,x,2]) //ARMAZEM VAZIO
                        _aGeral[i,4,x,2] := SB1->B1_LOCPAD
                    endif

                    IF (cAlias)->(DBSeek(Padr(_aGeral[i,4,x,1],TamSx3("B2_COD")[1])+_aGeral[i,4,x,2]))
                        if (cAlias)->QUANT > 0 .and. ( _aGeral[i,4,x,3] <= (cAlias)->QUANT .or. (_aGeral[i,4,x,3]-(cAlias)->QUANT)<=GetMV("VA_DIFTRAT",,1))
                            If _aGeral[i,4,x,3] > (cAlias)->QUANT .or. ABS(_aGeral[i,4,x,3]-(cAlias)->QUANT)<=GetMV("VA_DIFTRAT",,1)
                                _aGeral[i,4,x,3] := (cAlias)->QUANT
                            EndIf

                            RecLock((cAlias),.F.)
                                (cAlias)->QUANT := (cAlias)->QUANT - _aGeral[i,4,x,3]
                            (cAlias)->(MSUNLOCK())
                        else
                            MsgStop("Não existe saldo suficiente para apontar a alimentação [" + AllTrim(_aGeral[i,4,x,1]) + "] Armazem ["+ AllTrim(_aGeral[i,4,x,2]) +"] do animal [" + AllTrim(_aGeral[i,1]) + "]." )
                            lRet := .F.
                            exit
                        endif
                    else
                        IF SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+_aGeral[i,4,x,2]))
                            RecLock((cAlias),.t.)
                                (cAlias)->CODIGO    :=  SB2->B2_COD
                                (cAlias)->ARMAZEM   :=  SB2->B2_LOCAL
                                (cAlias)->QUANT     :=  SB2->B2_QATU
                            (cAlias)->(MSUNLOCK())

                            if _aGeral[i,4,x,3] <= (cAlias)->QUANT .or. (_aGeral[i,4,x,3]-(cAlias)->QUANT)<=GetMV("VA_DIFTRAT",,1)
                                If _aGeral[i,4,x,3] > (cAlias)->QUANT .or. ABS(_aGeral[i,4,x,3]-(cAlias)->QUANT)<=GetMV("VA_DIFTRAT",,1)
                                    _aGeral[i,4,x,3] := (cAlias)->QUANT
                                EndIf
                            
                                RecLock((cAlias),.F.)
                                    (cAlias)->QUANT := (cAlias)->QUANT - _aGeral[i,4,x,3]
                                (cAlias)->(MSUNLOCK())
                            else
                                MsgStop("Não existe saldo suficiente para apontar a alimentação [" + AllTrim(_aGeral[i,4,x,1]) + "] do animal [" + AllTrim(_aGeral[i,1]) + "]." )
                                lRet := .F.
                                exit
                            endif
                        ELSE
                            MsgStop("Racao [" + AllTrim(_aGeral[i,4,x,1]) + "] não foi encontrada no cadastro de produtos." )
                            lRet := .F.
                            exit
                        endif
                    ENDIF
                else
                    MsgStop("Racao [" + AllTrim(_aGeral[i,4,x,1]) + "] não foi encontrada no cadastro de produtos." )
                    lRet := .F.
                    exit
                endif
            next x
            if !lRet
                exit
            endif
        next i
    endif
    
    (cALias)->(DBGoTop())
    cLine := PADR("CODIGO",TAMSX3("B2_COD")[1])+PADR("ARMAZEM",TAMSX3("B2_COD")[1])+PADR("QUANT",TAMSX3("B2_QATU")[1]) + CRLF
    WHile !(cALias)->(EOF())
        cLine += (cALias)->(CODIGO+ARMAZEM)+TRANSFORM( (cALias)->QUANT, "@E 999,999,999.999999" ) + CRLF
        (cALias)->(DBSkip())
    enddo 
    oSaldoB2:DELETE()

    if !Empty(aArea)
        FwRestArea(aArea)
    endif
Return lRet

Static Function ValidaLotes(cLote, aRacao, cArmz)
    local cAlias 	    := GetNextAlias()
    local cInGrpInd     := "'" + StrTran(GetMV("VA_GRPINDV"), "|", "', '") + "'"
    local cSql 		    := ""
    Local aLinha        := {}
    Local x

    If Type("__DATA") == "U"
        Private __DATA		:= iIf(IsInCallStack("U_JOBPrcLote"), MsDate(), dDataBase)
    EndIf
    If Type("cFile") == "U"
        Private cFile 		:= "C:\TOTVS_RELATORIOS\JOBPrcLote_" + DtoS(__DATA) + ".TXT"
    EndIf
    
    cSql := " with estoque as ( " +_ENTER_+;
                "  select B8_LOTECTL " +_ENTER_+;
                "       , B1_GRUPO " +_ENTER_+;
                "       , B1_COD " +_ENTER_+;
                "       , B8_FILIAL " +_ENTER_+;
                "       , B8_LOCAL " +_ENTER_+;
                "       , B8_SALDO, B8_NUMLOTE " +_ENTER_+;
                "  from " + RetSqlName('SB8') + " SB8 " +_ENTER_+;
                "  join " + RetSqlName('SB1') + " SB1 " +_ENTER_+;
                "      on SB1.B1_FILIAL  = '" + xFilial("SB1") + "' " +_ENTER_+;
                "      and SB1.B1_COD     = SB8.B8_PRODUTO " +_ENTER_+;
                "      and SB1.B1_GRUPO  in (" + cInGrpInd + ")" +_ENTER_+;
                " 	 and SB8.B8_LOTECTL = '" + cLote + "'" +_ENTER_+;
                " 	 and SB8.B8_LOCAL   = '" + cArmz + "'" +_ENTER_+;
                "      and SB1.D_E_L_E_T_ = ' ' " +_ENTER_+;
                "  where SB8.B8_FILIAL  = '" + xFilial("SB8") + "' " +_ENTER_+;
                " 	 and SB8.B8_DATA <= '" + dToS(dDataBase) + "'" +_ENTER_+;
                " 	 and SB8.B8_SALDO > 0 " +_ENTER_+;
                "      and SB8.D_E_L_E_T_ = ' ' " +_ENTER_+;
                "  ), " +_ENTER_+;
                "  quant as ( " +_ENTER_+;
                "  select B8_LOTECTL, count(*) QTDREG " +_ENTER_+;
                "  from estoque " +_ENTER_+;
                "  WHERE B8_FILIAL  = '" + xFilial("SB8") + "' " +_ENTER_+;
                "    AND B8_LOCAL   = '" + cArmz + "'" +_ENTER_+;
                "    AND B8_SALDO > 0 " +_ENTER_+;
                "  group by B8_LOTECTL " +_ENTER_+;
                "  ) " +_ENTER_+;
                "  select estoque.B8_LOTECTL " +_ENTER_+;
                "       , estoque.B1_GRUPO " +_ENTER_+;
                "       , estoque.B1_COD " +_ENTER_+;
                "       , estoque.B8_FILIAL " +_ENTER_+;
                "       , estoque.B8_LOCAL " +_ENTER_+;
                "       , estoque.B8_SALDO, estoque.B8_NUMLOTE " +_ENTER_+;
                "       , total.TOTAL " +_ENTER_+;
                "       , quant.QTDREG " +_ENTER_+;
                "  from estoque " +_ENTER_+;
                "  join quant " +_ENTER_+;
                "  on quant.B8_LOTECTL = estoque.B8_LOTECTL " +_ENTER_+;
                "  join ( " +_ENTER_+;
                "         select B8_LOTECTL " +_ENTER_+;
                "            , sum(B8_SALDO) TOTAL " +_ENTER_+;
                "         from estoque " +_ENTER_+;
                "         group by B8_LOTECTL " +_ENTER_+;
                "     ) total " +_ENTER_+;
                "  on total.B8_LOTECTL = estoque.B8_LOTECTL " +_ENTER_+;
                "  order by estoque.B8_LOTECTL " +_ENTER_+;
                "         , estoque.B1_COD "

    MemoWrite( "C:\TOTVS_RELATORIOS\VAEST020-ValidaLotes.SQL", cSql)

    MpSysOpenQry(cSql,cAlias)

    if (cAlias)->QTDREG > 0 //nRegistros == 0
        while !(cAlias)->(Eof())
                if (cAlias)->B8_SALDO > 0
                    aCpyRacao := aClone(aRacao)
                        
                    For x := 1 to Len(aCpyRacao)
                        aCpyRacao[x,3] := Round(aCpyRacao[x,3] * (cAlias)->(B8_SALDO/TOTAL),TamSx3("D3_QUANT")[2])
                    next x

                    AAdd( aLinha , {(cAlias)->B1_COD, (cAlias)->B8_SALDO,cArmz,aCpyRacao,AllTrim((cAlias)->B8_LOTECTL)} )
                endif
            (cAlias)->(DbSkip())
        end
    endif
    (cAlias)->(DbCloseArea())

Return aLinha
