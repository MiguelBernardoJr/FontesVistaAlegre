
// #########################################################################################
// Projeto: Trato
// Fonte  : vapcpa08
// ---------+------------------------------+------------------------------------------------
// Data     | Autor                        | Descrição
// ---------+------------------------------+------------------------------------------------
// 20190815 | jrscatolon@jrscatolon.com.br | Resumo de trato
//          |                              | 
//          |                              | 
// ---------+------------------------------+------------------------------------------------

#include 'Protheus.ch'
#include 'ParmType.ch'
#include "FWMVCDef.ch"

#define _MODEL .t.
#define _VIEW  .f.

static aCposCab := { "Z0S_EQUIP", "ZV0_IDENT", "Z0U_NOME", "Z0T_ROTA", "Z05_KGMNDI" }
static aCposItens := { "Z0T_ROTA", "Z06_TRATO", "Z06_DIETA", "Z05_KGMNDI" }
static cEquip := ""
static cRota := ""
static aCab := {}
static nItem := 0

/*/{Protheus.doc} vapcpa08
Explode o Resumo de trato.
@author guima
@since 18/09/2019
@version 1.0
@return nil
@param mv_par01, date, Data de referencia do trato
@param mv_par02, characters, Versão de referencia do trato
@param cFilterPar, characters, Filtro para a query que carrega os dados do trato
@type function
/*/
user function vapcpa08(mv_par01, mv_par02, cFilterPar)
	local aParm := {mv_par01, mv_par02}
	local lInclui := nil
	local lAltera := nil
	local aArea := GetArea()
	local aEnButt := { {.f., nil},;         // 1 - Copiar
					{.f., nil},;         // 2 - Recortar
					{.f., nil},;         // 3 - Colar
					{.f., nil},;         // 4 - Calculadora
					{.f., nil},;         // 5 - Spool
					{.f., nil},;         // 6 - Imprimir
					{.f., nil},;         // 7 - Confirmar
					{.t., "Fechar"},;    // 8 - Cancelar
					{.f., nil},;         // 9 - WalkTrhough
					{.f., nil},;         // 10 - Ambiente
					{.f., nil},;         // 11 - Mashup
					{.t., nil},;         // 12 - Help
					{.f., nil},;         // 13 - Formulário HTML
					{.f., nil},;         // 14 - ECM
					{.f., nil} }         // 15 - Salvar e Criar novo
	local cPerg := "VAPCPA08"
	local cMsg := ""

	private cFilter := Iif(cFilterPar == nil, "", cFilterPar)
	Private oExecQry := nil
	Private cPerg01 := ""
	Private cPerg02 := ""

    if Type("Inclui") == 'U'
        private Inclui := .f.
    else
        lInclui := Inclui
        Inclui := .f.
    endif
    
    if Type("Altera") == 'U'
        private Altera := .f.
    else
        lAltera := Altera
        Altera := .f.
    endif

    AtuSX1(@cPerg)

    if mv_par01 == nil
        Pergunte(cPerg)
    endif

	cPerg01 := mv_par01
	cPerg02 := mv_par02

	cQry := " select Z0T_ROTA, Z06_TRATO, count(Z06_DIETA) NroDietas" + CRLF
    cQry += " from (" + CRLF
    cQry += " select distinct Z0T_ROTA, Z06_TRATO, Z06_DIETA" + CRLF
    cQry += " from " + RetSqlName("Z0T") + " Z0T" + CRLF
    cQry += " join " + RetSqlName("Z06") + " Z06" + CRLF
    cQry += " on Z06.Z06_FILIAL = '" + FWxFilial("Z06") + "'" + CRLF
    cQry += " and Z06.Z06_DATA   = Z0T.Z0T_DATA" + CRLF
    cQry += " and Z06.Z06_VERSAO = Z0T.Z0T_VERSAO" + CRLF
    cQry += " and Z06.Z06_CURRAL = Z0T.Z0T_CURRAL" + CRLF
    cQry += " and Z06.D_E_L_E_T_ = ' '" + CRLF
    cQry += " where Z0T.Z0T_FILIAL = '" + FWxFilial("Z0T") + "'" + CRLF
    cQry += " and Z0T.Z0T_DATA   = '" + DToS(cPerg01) + "'" + CRLF
    cQry += " and Z0T.Z0T_VERSAO = '" + cPerg02 + "'" + CRLF
    cQry += " and Z0T.Z0T_ROTA   <> '      '" + CRLF
    cQry += " and Z0T.D_E_L_E_T_ = ' '" + CRLF
    cQry += " ) ROTA" + CRLF
    cQry += " group by Z0T_ROTA, Z06_TRATO" + CRLF
    cQry += " having count(Z06_DIETA) > 1" + CRLF

	cAlias := MpSysOpenQuery(cQry)

    while !(cAlias)->(Eof())
        cMsg += Iif(!Empty(cMsg), CRLF, "") + "Rota: " + (cAlias)->Z0T_ROTA + " - Trato: " + (cAlias)->Z06_TRATO
        (cAlias)->(DbSkip())
    end
    (cAlias)->(DbCloseArea())

    if !Empty(cMsg)
        U_MsgInf("A(s) rota(s) abaixo possue(m) mais de uma dieta no trato. Por favor verifique." + CRLF + cMsg, "Atenção", "(cAlias) inválidas.")
    endif
	
	MontaQuery()

    FWExecView('Resumo', 'VAPCPA08', MODEL_OPERATION_VIEW,, { || .t. },,,aEnButt)

    SetKey(VK_F4, nil)

	Inclui := lInclui
	Altera := lAltera
	mv_par01 := aParm[1]
	mv_par02 := aParm[2]
return nil

/*/{Protheus.doc} ModelDef
Modelo de dados da rotina
@author jr.andre
@since 18/09/2019
@version 1.0
@return MPFormModel, Modelo de dados

@type function
/*/
static function ModelDef()
local oModel := nil
local oStrCabG := GridStruct(_MODEL, aCposCab)
local oStrIteG := GridStruct(_MODEL, aCposItens)

local bLoadFld := {|| LoadForm() }
local bLoadCab := {|oFormGrid, lCopia| LoadCabec(oFormGrid, lCopia) }
local bLoadIte := {|oFormGrid, lCopia| LoadItens(oFormGrid, lCopia) }

oModel := MPFormModel():New("MDVAPCPA08", /*bPreValid*/, /*bPostValid*/, /*bCommit*/, /*bCancel*/)
oModel:SetDescription("Resumo de Trato")

oModel:AddFields("MdField", /*cOwner*/, oStrCabG, /*bPreValid*/, /*bPosValid*/, bLoadFld)
oModel:AddGrid("MdGridCab", "MdField", oStrCabG, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/, bLoadCab)
oModel:AddGrid("MdGridIte", "MdGridCab", oStrIteG, /*bLinePre*/,/*bLinePost*/,/*bPre */,/*bPost*/, bLoadIte)

// Definição de Descrição 
oModel:GetModel("MdField"):SetDescription("nao_aparece")
oModel:GetModel("MdGridCab"):SetDescription("Equipamento")
oModel:GetModel("MdGridIte"):SetDescription("Detalhe")

oModel:GetModel("MdGridCab"):SetNoDeleteLine(.t.)
oModel:GetModel("MdGridIte"):SetNoDeleteLine(.t.)

oModel:GetModel("MdGridCab"):SetNoInsertLine(.t.)
oModel:GetModel("MdGridIte"):SetNoInsertLine(.t.)

// Cria a chave primária 
oModel:SetPrimaryKey({})

oModel:SetRelation("MdGridIte", {{"Z0T_ROTA", "Z0T_ROTA"}}, "Z0T_ROTA+Z06_TRATO")

return oModel

/*/{Protheus.doc} ViewDef
Definição da interface da rotina
@author jr.andre
@since 18/09/2019
@version 1.0
@return FwFormView, Interface da tela
@type function
/*/
static function ViewDef()
	local oView := nil
	local oModel := ModelDef()
	local oStrCabG := GridStruct(_VIEW, aCposCab)
	local oStrIteG := GridStruct(_VIEW, aCposItens)

    oView := FwFormView():New()
    oView:SetModel(oModel)

    oView:AddGrid("VwGridCab", oStrCabG, "MdGridCab")
    oView:AddGrid("VwGridIte", oStrIteG, "MdGridIte")

    oStrCabG:SetProperty("*",   MVC_VIEW_CANCHANGE, .f.)
    oStrIteG:SetProperty("*",   MVC_VIEW_CANCHANGE, .f.)

    oView:CreateVerticalBox("CABGRID", 60)
    oView:CreateVerticalBox("ITEMGRID", 40)

    oView:SetOwnerView("VwGridCab", "CABGRID")
    oView:SetOwnerView("VwGridIte", "ITEMGRID")

    oView:SetCloseOnOk({||.t.})

    oView:SetNoInsertLine("VwGridCab")
    oView:SetNoInsertLine("VwGridIte")

    oView:SetNoDeleteLine("VwGridCab")
    oView:SetNoDeleteLine("VwGridIte")

    oView:EnableTitleView('VwGridCab', "Equipamento")
    oView:EnableTitleView('VwGridIte', "Detalhe")

    oStrIteG:RemoveField("Z0T_ROTA")

    SetKey(VK_F4, {|| Exportar()})
    oView:AddUserButton( 'Gerar Arquivo', 'CLIPS', {|oView| Exportar()}, "Gera o arquivo de trato <F4>.", VK_F4,,.t.)

return oView

/*/{Protheus.doc} GridStruct
Monta estrutura das grids
@author jr.andre
@since 18/09/2019
@version 1.0
@return objeto, estrutura do model ou da view
@param lTipo, logical, _MODEL ou _VIEW
@param aCpos, array, Lista dos campos que pertencem a estrutura
@type function
/*/
static function GridStruct(lTipo, aCpos)
	local aArea := GetArea()
	local oStruct
	local i, nLen
	local aCBox

	if lTipo // Model
		oStruct := FWFormModelStruct():New()
		SX3->(DbSetOrder(2)) // X3_CAMPO
		nLen := Len(aCpos)
		for i := 1 to nLen
			SX3->(DbSeek(aCpos[i]))
			aCBox := Iif(!Empty(X3CBox()),StrToKArr(X3CBox(), ";"),nil)
			oStruct:AddField(;
				X3Titulo(),;               // [01]  C   Titulo do campo
				X3Descric(),;              // [02]  C   ToolTip do campo
				AllTrim(SX3->X3_CAMPO),;   // [03]  C   Id do Field
				TamSX3(SX3->X3_CAMPO)[3],; // [04]  C   Tipo do campo
				TamSX3(SX3->X3_CAMPO)[1],; // [05]  N   Tamanho do campo
				TamSX3(SX3->X3_CAMPO)[2],; // [06]  N   Decimal do campo
				nil,;                      // [07]  B   Code-block de validação do campo
				nil,;                      // [08]  B   Code-block de validação When do campo
				aCBox,;                    // [09]  A   Lista de valores permitido do campo
				.f.,;                      // [10]  L   Indica se o campo tem preenchimento obrigatorio
				nil,;                      // [11]  B   Code-block de inicializacao do campo
				.f.,;                      // [12]  L   Indica se trata-se de um campo chave
				.t.,;                      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
				.f.)                       // [14]  L   Indica se o campo é virtual
		next
	else // View
		oStruct := FWFormViewStruct():New()
		nLen := Len(aCpos)
		for i := 1 to nLen
			SX3->(DbSetOrder(2))
			if SX3->(DbSeek(Padr(aCpos[i], Len(SX3->X3_CAMPO))))
				oStruct:AddField(;
					AllTrim(aCpos[i]),;             // [01]  C   Nome do Campo
					StrZero(i,Len(SX3->X3_ORDEM)),; // [02]  C   Ordem
					AllTrim(X3Titulo()),;           // [03]  C   Titulo do campo
					X3Descric(),;                   // [04]  C   Descricao do campo
					{"Help"},;                      // [05]  A   Array com Help
					TamSX3(SX3->X3_CAMPO)[3],;      // [06]  C   Tipo do campo
					AllTrim(SX3->X3_PICTURE),;      // [07]  C   Picture
					nil,;                           // [08]  B   Bloco de PictTre Var
					SX3->X3_F3,;                    // [09]  C   Consulta F3
					.f.,;                           // [10]  L   Indica se o campo é alteravel
					nil,;                           // [11]  C   Pasta do campo
					nil,;                           // [12]  C   Agrupamento do campo
					nil,;                           // [13]  A   Lista de valores permitido do campo (Combo)
					nil,;                           // [14]  N   Tamanho máximo da maior opção do combo
					nil,;                           // [15]  C   Inicializador de Browse
					nil,;                           // [16]  L   Indica se o campo é virtual
					nil,;                           // [17]  C   Picture Variável
					nil;                            // [18]  L   Indica pulo de linha após o campo
				)
			endif
		next
	endif

	RestArea(aArea)
return oStruct

/*/{Protheus.doc} LoadForm
Retorna array com dados vazios para o formulario que é obrigatório. 
@author jr.andre
@since 18/09/2019
@version 1.0
@return arrya, { "", "", "", "", 0 }
@type function
/*/
static function LoadForm(); return { "", "", "", "", 0 }

/*/{Protheus.doc} LoadCabec
Carrega os dados da grid de cabeçalho
@author jr.andre
@since 18/09/2019
@version 1.0
@return array, retorna os dados do cabeçalho
@param oFormGrid, object, objeto FWFormGrid passado pelo loader
@param lCopia, logical, informa se trata-se de uma cópia
@type function
/*/
static function LoadCabec(oFormGrid, lCopia)
    local aArea  := GetArea()
    local cQry   := ""
	local cAlias := ""
	Local cTabDietas := "##TMP_DIETAS" + __cUserID
	Local cTabVersao := "##TMP_VERSAO" + __cUserID
	Local cTabComp   := "##TMP_COMP"   + __cUserID
	Local cTabQBase  := "##TMP_QBASE"  + __cUserID
	Local cTabFinal  := "##TMP_FINAL"  + __cUserID

    aCab := {}
    nItem := 0

	// Limpeza inicial
	cQry := " IF OBJECT_ID('tempdb.."+cTabDietas+"'	) IS NOT NULL DROP TABLE "+cTabDietas+"" + CRLF
	cQry += " IF OBJECT_ID('tempdb.."+cTabVersao+"'	) IS NOT NULL DROP TABLE "+cTabVersao+"" + CRLF
	cQry += " IF OBJECT_ID('tempdb.."+cTabComp+"'	) IS NOT NULL DROP TABLE "+cTabComp+""  + CRLF
	cQry += " IF OBJECT_ID('tempdb.."+cTabQBase+"'	) IS NOT NULL DROP TABLE "+cTabQBase+"" + CRLF
	cQry += " IF OBJECT_ID('tempdb.."+cTabFinal+"'	) IS NOT NULL DROP TABLE "+cTabFinal+"" + CRLF

	// 1. Identificar Dietas"++"
	cQry += " SELECT DISTINCT Z06_DIETA INTO "+cTabDietas+" " + CRLF
	cQry += " FROM " + RetSqlName("Z06") + " Z06 WITH (NOLOCK) " + CRLF
	cQry += " WHERE Z06.Z06_FILIAL = '" + FwxFilial("Z06") + "' " + CRLF
	cQry += " AND Z06.Z06_DATA = '" + DToS(cPerg01) + "' "  + CRLF
	cQry += " AND Z06.Z06_VERSAO = '" + cPerg02 + "' "    + CRLF    
	cQry += " AND Z06.D_E_L_E_T_ = ' ' " + CRLF
	cQry += " CREATE CLUSTERED INDEX IX_TMP_F ON "+cTabDietas+"(Z06_DIETA) " + CRLF

	// 2. Versão Ativa
	cQry += " SELECT ZG1.ZG1_COD, MAX(ZG1.ZG1_SEQ) AS MAX_SEQ INTO "+cTabVersao+" " + CRLF
	cQry += " FROM " + RetSqlName("ZG1") + " ZG1 WITH (NOLOCK) " + CRLF
	cQry += " INNER JOIN "+cTabDietas+" F ON F.Z06_DIETA = ZG1.ZG1_COD " + CRLF
	cQry += " WHERE ZG1.ZG1_FILIAL = '" + FwxFilial("ZG1") + "' " + CRLF
	cQry += " AND ZG1.ZG1_DTALT <= '" + DToS(cPerg01) + "' " + CRLF
	cQry += " AND ZG1.D_E_L_E_T_ = ' ' " + CRLF
	cQry += " GROUP BY ZG1.ZG1_COD " + CRLF
	cQry += " CREATE CLUSTERED INDEX IX_TMP_V ON "+cTabVersao+"(ZG1_COD, MAX_SEQ) " + CRLF

	// 3. Composição
	cQry += " SELECT ZG1.ZG1_COD, ZG1.ZG1_COMP, ZG1.ZG1_QUANT INTO "+cTabComp+" "+ CRLF
	cQry += " FROM " + RetSqlName("ZG1") + " ZG1 WITH (NOLOCK) "+ CRLF
	cQry += " INNER JOIN "+cTabVersao+" V ON ZG1.ZG1_COD = V.ZG1_COD AND ZG1.ZG1_SEQ = V.MAX_SEQ "+ CRLF
	cQry += " WHERE ZG1.ZG1_FILIAL = '" + FwxFilial("ZG1") + "' AND ZG1.D_E_L_E_T_ = ' ' " + CRLF
	cQry += " CREATE CLUSTERED INDEX IX_TMP_C ON "+cTabComp+"(ZG1_COD, ZG1_COMP) " + CRLF

	// 4. Totalizador
	cQry += " SELECT ZG1_COD, SUM(ZG1_QUANT) AS QUANT_TOTAL INTO "+cTabQBase+" "+ CRLF
	cQry += " FROM "+cTabComp+" GROUP BY ZG1_COD " + CRLF
	cQry += " CREATE CLUSTERED INDEX IX_TMP_Q ON "+cTabQBase+"(ZG1_COD) " + CRLF

	// 5. Pré-Cálculo
	cQry += " SELECT Z0S.Z0S_EQUIP, ISNULL(ZV0.ZV0_IDENT, '          ') AS ZV0_IDENT, " + CRLF
	cQry += " Z0S.Z0S_OPERAD, ISNULL(Z0U.Z0U_NOME, SPACE(40)) AS Z0U_NOME, Z0T.Z0T_ROTA, " + CRLF
	cQry += " Z06.Z06_TRATO, Z06.Z06_DIETA, ZV0.ZV0_DIVISA, "  + CRLF
	cQry += " CASE WHEN LOG10(ZV0.ZV0_DIVISA) - FLOOR(LOG10(ZV0.ZV0_DIVISA)) = 0 " + CRLF
	cQry += " THEN ROUND(SUM((100 * Z06.Z06_KGMSTR * COMP.ZG1_QUANT * Z05.Z05_CABECA) / (BASE.QUANT_TOTAL * Z0V.Z0V_INDMS)), -1 * LOG10(ZV0.ZV0_DIVISA)) " + CRLF
	cQry += " ELSE ROUND(SUM((100 * Z06.Z06_KGMSTR * COMP.ZG1_QUANT * Z05.Z05_CABECA) / (BASE.QUANT_TOTAL * Z0V.Z0V_INDMS)) * 2, -1 * ROUND(LOG10(ZV0.ZV0_DIVISA * 2), 0)) / 2 " + CRLF
	cQry += " END AS QTD_PARCIAL " + CRLF
	cQry += " INTO "+cTabFinal+" "  + CRLF
	cQry += " FROM " + RetSqlName("Z0T") + " Z0T WITH (NOLOCK) " + CRLF
	cQry += " INNER JOIN " + RetSqlName("Z05") + " Z05 WITH (NOLOCK) " + CRLF
	cQry += " ON Z05.Z05_FILIAL = '" + FwxFilial("Z05") + "' AND Z05.Z05_DATA = Z0T.Z0T_DATA AND Z05.Z05_VERSAO = Z0T.Z0T_VERSAO AND Z05.Z05_CURRAL = Z0T.Z0T_CURRAL AND Z05.D_E_L_E_T_ = ' ' " + CRLF
	cQry += " INNER JOIN " + RetSqlName("Z06") + " Z06 WITH (NOLOCK) " + CRLF
	cQry += " ON Z06.Z06_FILIAL = '" + FwxFilial("Z06") + "' AND Z06.Z06_DATA = Z05.Z05_DATA AND Z06.Z06_VERSAO = Z05.Z05_VERSAO AND Z06.Z06_LOTE = Z05.Z05_LOTE AND Z06.D_E_L_E_T_ = ' ' " + CRLF
	cQry += " INNER JOIN "+cTabComp+" COMP ON COMP.ZG1_COD = Z06.Z06_DIETA " + CRLF
	cQry += " INNER JOIN "+cTabQBase+" BASE ON BASE.ZG1_COD = Z06.Z06_DIETA " + CRLF
	cQry += " INNER JOIN " + RetSqlName("Z0V") + " Z0V WITH (NOLOCK) " + CRLF
	cQry += " ON Z0V.Z0V_FILIAL = '" + FwxFilial("Z0V") + "' AND Z0V.Z0V_COMP = COMP.ZG1_COMP AND Z0V.Z0V_DATA = Z0T.Z0T_DATA AND Z0V.Z0V_VERSAO = Z0T.Z0T_VERSAO AND Z0V.D_E_L_E_T_ = ' ' " + CRLF
	cQry += " LEFT JOIN " + RetSqlName("Z0S") + " Z0S WITH (NOLOCK) " + CRLF
	cQry += " ON Z0S.Z0S_FILIAL = '" + FwxFilial("Z0S") + "' AND Z0S.Z0S_DATA = Z0T.Z0T_DATA AND Z0S.Z0S_VERSAO = Z0T.Z0T_VERSAO AND Z0S.Z0S_ROTA = Z0T.Z0T_ROTA AND Z0S.D_E_L_E_T_ = ' ' " + CRLF
	cQry += " LEFT JOIN " + RetSqlName("ZV0") + " ZV0 WITH (NOLOCK) " + CRLF
	cQry += " ON ZV0.ZV0_FILIAL = '" + FwxFilial("ZV0") + "' AND ZV0.ZV0_CODIGO = Z0S.Z0S_EQUIP AND ZV0.D_E_L_E_T_ = ' ' " + CRLF
	cQry += " LEFT JOIN " + RetSqlName("Z0U") + " Z0U WITH (NOLOCK) " + CRLF
	cQry += " ON Z0U.Z0U_FILIAL = '" + FwxFilial("Z0U") + "' AND Z0U.Z0U_CODIGO = Z0S.Z0S_OPERAD AND Z0U.D_E_L_E_T_ = ' ' " + CRLF
	cQry += " WHERE Z0T.Z0T_FILIAL = '" + FwxFilial("Z0T") + "' " + CRLF
	cQry += " AND Z0T.Z0T_DATA = '" + DToS(cPerg01) + "' " + CRLF
	cQry += " AND Z0T.Z0T_VERSAO = '" + cPerg02 + "' " + CRLF
	cQry += " AND Z0T.Z0T_ROTA <> '      ' "  + CRLF
	cQry += " AND Z0T.D_E_L_E_T_ = ' ' "  + CRLF
	cQry += " GROUP BY Z0S.Z0S_EQUIP, ZV0.ZV0_IDENT, Z0S.Z0S_OPERAD, Z0U.Z0U_NOME, Z0T.Z0T_ROTA, Z06.Z06_TRATO, Z06.Z06_DIETA, ZV0.ZV0_DIVISA " + CRLF

	if Lower(cUserName) $ "administrador,admin,ioliveira"
		MemoWrite( "C:\totvs_relatorios\VAPCPA08-LoadCabec1.SQL", cQry)
	endif

	// Executa a preparação. Se der erro, para aqui.
	If TCSqlExec(cQry) < 0
		MsgAlert("Erro SQL na preparação: " + TCSqlError())
		RestArea(aArea)
		Return {0, {"", "", "", "", 0}}
	EndIf

	// ------------------------------------------------------------------------
	// ETAPA 2: Seleção Final
	// Agora sim usamos MPSysOpenQuery apenas para LER os dados processados
	// ------------------------------------------------------------------------
	cQry := " SELECT Z0S_EQUIP, ZV0_IDENT, Z0S_OPERAD, Z0U_NOME, Z0T_ROTA, "
	cQry += " SUM(QTD_PARCIAL) AS QTDMNCOMP "
	cQry += " FROM "+cTabFinal+" " // Lê da tabela criada no passo anterior
	cQry += " GROUP BY Z0S_EQUIP, ZV0_IDENT, Z0S_OPERAD, Z0U_NOME, Z0T_ROTA "
	cQry += " ORDER BY Z0T_ROTA "

	if Lower(cUserName) $ "administrador,admin,ioliveira"
		MemoWrite( "C:\totvs_relatorios\VAPCPA08-LoadCabec2.SQL", cQry)
	endif

	cAlias := MpSysOpenQuery(cQry)

	while !(cAlias)->(Eof())
		if !Empty(cEquip)
			cEquip := (cAlias)->ZV0_IDENT
			cRota := (cAlias)->Z0T_ROTA
		endif
		AAdd(aCab, {0, {(cAlias)->Z0S_EQUIP, (cAlias)->ZV0_IDENT, (cAlias)->Z0U_NOME, (cAlias)->Z0T_ROTA, Round((cAlias)->QTDMNCOMP, TamSX3("Z05_KGMNDI")[2])}})
		(cAlias)->(DbSkip())
	end

    (cAlias)->(DbCloseArea())

	cQry := " DROP TABLE " + cTabDietas
	cQry += " DROP TABLE " + cTabVersao
	cQry += " DROP TABLE " + cTabComp
	cQry += " DROP TABLE " + cTabQBase
	cQry += " DROP TABLE " + cTabFinal

	if Lower(cUserName) $ "administrador,admin,ioliveira"
		MemoWrite( "C:\totvs_relatorios\VAPCPA08-LoadCabec3.SQL", cQry)
	endif

	// Executa a preparação. Se der erro, para aqui.
	If TCSqlExec(cQry) < 0
		MsgAlert("Erro SQL na FINALIZAÇÃO: " + TCSqlError())
		RestArea(aArea)
		Return {0, {"", "", "", "", 0}}
	EndIf

	if !Empty(aArea)
		RestArea(aArea)
	endif
return aCab

/*/{Protheus.doc} LoadItens
Carrega os dados da grid de itens
@author jr.andre
@since 18/09/2019
@version 1.0
@return array, retorna os dados dos itens
@param oFormGrid, object, objeto FWFormGrid passado pelo loader
@param lCopia, logical, informa se trata-se de uma cópia
@type function
/*/
static function LoadItens(oFormGrid, lCopia)
	local aArea 	 := GetArea()
	local aDados 	 := {}
	local cAlias 	 := ""
	Local cQry 		 := ""
	Local cTabDietas := "##TMP_DIETAS_FILTRO_" + __cUserID
	Local cTabVersao := "##TMP_VERSAO_ATIVA_" + __cUserID
	Local cTabComp   := "##TMP_COMPOSICAO_"  + __cUserID
	Local cTabQBase  := "##TMP_QBASE_" + __cUserID

	nItem++

	if !Empty(aCab)
		
		// Limpeza de segurança
		cQry += " IF OBJECT_ID('tempdb.."+cTabDietas+"') IS NOT NULL DROP TABLE " + cTabDietas + " " + CRLF 
		cQry += " IF OBJECT_ID('tempdb.."+cTabVersao+"') IS NOT NULL DROP TABLE " + cTabVersao + " " + CRLF 
		cQry += " IF OBJECT_ID('tempdb.."+cTabComp+"') IS NOT NULL DROP TABLE " + cTabComp + " " + CRLF 
		cQry += " IF OBJECT_ID('tempdb.."+cTabQBase+"') IS NOT NULL DROP TABLE " + cTabQBase + " " + CRLF 

		// 1. Isolar as Dietas usadas no dia (Reduz o universo de busca da ZG1)

		cQry += " SELECT DISTINCT Z06_DIETA " + CRLF
		cQry += " INTO " + cTabDietas + " " + CRLF
		cQry += " FROM " + RetSqlName("Z06") + " Z06 WITH (NOLOCK) " + CRLF
		cQry += " WHERE Z06.Z06_FILIAL = '" + xFilial("Z06") + "' " + CRLF
		cQry += " AND Z06.Z06_DATA   = '" + DTOS(cPerg01) + "' " + CRLF
		cQry += " AND Z06.Z06_VERSAO = '" + cPerg02 + "' " + CRLF
		cQry += " AND Z06.D_E_L_E_T_ = ' ' " + CRLF
		cQry += "  " + CRLF
		cQry += " CREATE CLUSTERED INDEX IX_D_"+__cUserID+" ON "+cTabDietas+"(Z06_DIETA) " + CRLF

		//-- ============================================================================
		//-- 2. Identificar a VERSÃO ATIVA da Dieta (Header Version)
		//-- ============================================================================
		cQry += " SELECT  " + CRLF
		cQry += " 	ZG1.ZG1_COD, " + CRLF
		cQry += " 	MAX(ZG1.ZG1_SEQ) AS MAX_SEQ " + CRLF
		cQry += " INTO "+cTabVersao+" " + CRLF
		cQry += " FROM " + RetSqlName("ZG1") + " ZG1 WITH (NOLOCK) " + CRLF
		cQry += " INNER JOIN "+cTabDietas+" F ON F.Z06_DIETA = ZG1.ZG1_COD " + CRLF
		cQry += " WHERE ZG1.ZG1_FILIAL = '" + xFilial("ZG1") + "' " + CRLF
		cQry += " AND ZG1.ZG1_DTALT <= '" + DTOS(cPerg01) + "' " + CRLF
		cQry += " AND ZG1.D_E_L_E_T_ = ' ' " + CRLF
		cQry += " GROUP BY ZG1.ZG1_COD " + CRLF
		cQry += "  " + CRLF
		cQry += " CREATE CLUSTERED INDEX IX_V_" + __cUserID + " ON "+cTabVersao+"(ZG1_COD, MAX_SEQ) " + CRLF

		//-- ============================================================================
		//-- 3. Montar a Composição (ZG1) baseada EXATAMENTE na versão ativa
		//-- Isso elimina ingredientes antigos que não existem mais na versão atual
		//-- ============================================================================

		cQry += " 		SELECT  " + CRLF
		cQry += "     ZG1.ZG1_COD, " + CRLF
		cQry += "     ZG1.ZG1_COMP, " + CRLF
		cQry += "     ZG1.ZG1_QUANT " + CRLF
		cQry += " INTO "+cTabComp+" " + CRLF
		cQry += " FROM " + RetSqlName("ZG1") + " ZG1 WITH (NOLOCK) " + CRLF
		cQry += " INNER JOIN "+cTabVersao+" V  " + CRLF
		cQry += "     ON ZG1.ZG1_COD = V.ZG1_COD  " + CRLF
		cQry += "    AND ZG1.ZG1_SEQ = V.MAX_SEQ  " + CRLF
		cQry += " WHERE ZG1.ZG1_FILIAL = '" + xFilial("ZG1") + "' " + CRLF
		cQry += "   AND ZG1.D_E_L_E_T_ = ' ' " + CRLF 
		cQry += "  " + CRLF
		cQry += " CREATE CLUSTERED INDEX IX_C_" + __cUserID + " ON "+cTabComp+"(ZG1_COD, ZG1_COMP) " + CRLF

		//-- ============================================================================
		//-- 4. Calcular o Totalizador QBASE (Denominador da fórmula)
		//-- ============================================================================
		cQry += " 		SELECT " + CRLF
		cQry += "     ZG1_COD, " + CRLF
		cQry += "     SUM(ZG1_QUANT) AS QUANT_TOTAL" + CRLF
		cQry += " INTO "+cTabQBase+"" + CRLF
		cQry += " FROM "+cTabComp+"" + CRLF
		cQry += " GROUP BY ZG1_COD" + CRLF
		cQry += " " + CRLF
		cQry += " CREATE CLUSTERED INDEX IX_Q_" + __cUserID + " ON "+cTabQBase+"(ZG1_COD)" + CRLF
		
		if Lower(cUserName) $ "administrador,admin,ioliveira"
			MemoWrite( "C:\totvs_relatorios\VAPCPA08-LoadItens"+cValToChar(nItem)+"-Prepara1.SQL", cQry)
		endif

		If TCSqlExec(cQry) < 0
			MsgAlert("Erro SQL na preparação: " + TCSqlError())
			RestArea(aArea)
			Return {0, {"", "", "", "", 0}}
		EndIf

		//-- ============================================================================
		//-- 5. Executar o Cálculo Final com os Filtros solicitados
		//-- ============================================================================
		cQry := " 		SELECT  " + CRLF
		cQry += "     Z0S.Z0S_EQUIP, " + CRLF
		cQry += "     ISNULL(ZV0.ZV0_IDENT, '          ') AS ZV0_IDENT, " + CRLF
		cQry += "     Z0S.Z0S_OPERAD, " + CRLF
		cQry += "     ISNULL(Z0U.Z0U_NOME, SPACE(40)) AS Z0U_NOME, " + CRLF
		cQry += "     Z0T.Z0T_ROTA, " + CRLF
		cQry += "     Z06.Z06_TRATO, " + CRLF
		cQry += "     Z06.Z06_DIETA, " + CRLF
		cQry += "     -- Cálculo idêntico ao original " + CRLF
		cQry += "     CASE  " + CRLF
		cQry += "         WHEN LOG10(ZV0.ZV0_DIVISA) - FLOOR(LOG10(ZV0.ZV0_DIVISA)) = 0  " + CRLF
		cQry += "         THEN ROUND(SUM((100 * Z06.Z06_KGMSTR * COMP.ZG1_QUANT * Z05.Z05_CABECA) / (BASE.QUANT_TOTAL * Z0V.Z0V_INDMS)), -1 * LOG10(ZV0.ZV0_DIVISA)) " + CRLF
		cQry += "         ELSE ROUND(SUM((100 * Z06.Z06_KGMSTR * COMP.ZG1_QUANT * Z05.Z05_CABECA) / (BASE.QUANT_TOTAL * Z0V.Z0V_INDMS)) * 2, -1 * ROUND(LOG10(ZV0.ZV0_DIVISA * 2), 0)) / 2 " + CRLF
		cQry += "     END AS QTDMNCOMP " + CRLF
		cQry += " FROM " + RetSqlName("Z0T") + " Z0T WITH (NOLOCK) " + CRLF
		cQry += " INNER JOIN " + RetSqlName("Z05") + " Z05 WITH (NOLOCK) " + CRLF
		cQry += "     ON Z05.Z05_FILIAL = '" + xFilial("Z05") + "' " + CRLF
		cQry += "     AND Z05.Z05_DATA   = Z0T.Z0T_DATA " + CRLF
		cQry += "     AND Z05.Z05_VERSAO = Z0T.Z0T_VERSAO " + CRLF
		cQry += "     AND Z05.Z05_CURRAL = Z0T.Z0T_CURRAL " + CRLF
		cQry += "     AND Z05.D_E_L_E_T_ = ' ' " + CRLF
		cQry += " INNER JOIN " + RetSqlName("Z06") + " Z06 WITH (NOLOCK) " + CRLF
		cQry += "     ON Z06.Z06_FILIAL = '" + xFilial("Z06") + "' " + CRLF
		cQry += "     AND Z06.Z06_DATA   = Z05.Z05_DATA " + CRLF
		cQry += "     AND Z06.Z06_VERSAO = Z05.Z05_VERSAO " + CRLF
		cQry += "     AND Z06.Z06_LOTE   = Z05.Z05_LOTE " + CRLF
		cQry += "     AND Z06.D_E_L_E_T_ = ' ' " + CRLF
		cQry += " -- Joins Otimizados com as Temp Tables " + CRLF
		cQry += " INNER JOIN " + cTabComp + " COMP " + CRLF
		cQry += "     ON COMP.ZG1_COD = Z06.Z06_DIETA " + CRLF
		cQry += " INNER JOIN " + cTabQBase + " BASE " + CRLF
		cQry += "     ON BASE.ZG1_COD = Z06.Z06_DIETA " + CRLF
		cQry += " INNER JOIN " + RetSqlName("Z0V") + " Z0V WITH (NOLOCK) " + CRLF
		cQry += "     ON Z0V.Z0V_FILIAL = '" + xFilial("Z0V") + "' " + CRLF
		cQry += "     AND Z0V.Z0V_COMP   = COMP.ZG1_COMP " + CRLF
		cQry += "     AND Z0V.Z0V_DATA   = Z0T.Z0T_DATA " + CRLF
		cQry += "     AND Z0V.Z0V_VERSAO = Z0T.Z0T_VERSAO -- Filtro de versão é vital aqui " + CRLF
		cQry += "     AND Z0V.D_E_L_E_T_ = ' '  " + CRLF
		cQry += " LEFT JOIN " + RetSqlName("Z0S") + " Z0S WITH (NOLOCK) " + CRLF
		cQry += "     ON Z0S.Z0S_FILIAL = '" + xFilial("Z0S") + "' " + CRLF
		cQry += "     AND Z0S.Z0S_DATA   = Z0T.Z0T_DATA " + CRLF
		cQry += "     AND Z0S.Z0S_VERSAO = Z0T.Z0T_VERSAO " + CRLF
		cQry += "     AND Z0S.Z0S_ROTA   = Z0T.Z0T_ROTA " + CRLF
		cQry += "     AND Z0S.D_E_L_E_T_ = ' ' " + CRLF
		cQry += " LEFT JOIN " + RetSqlName("ZV0") + " ZV0 WITH (NOLOCK) " + CRLF
		cQry += "     ON ZV0.ZV0_FILIAL = '       ' -- Atenção aos espaços conforme seu ambiente " + CRLF
		cQry += "     AND ZV0.ZV0_CODIGO = Z0S.Z0S_EQUIP " + CRLF
		cQry += "     AND ZV0.D_E_L_E_T_ = ' ' " + CRLF
		cQry += " LEFT JOIN " + RetSqlName("Z0U") + " Z0U WITH (NOLOCK) " + CRLF
		cQry += "     ON Z0U.Z0U_FILIAL = '" + xFilial("Z0U") + "' " + CRLF
		cQry += "     AND Z0U.Z0U_CODIGO = Z0S.Z0S_OPERAD " + CRLF
		cQry += "     AND Z0U.D_E_L_E_T_ = ' ' " + CRLF
		cQry += " WHERE Z0T.Z0T_FILIAL = '" + xFilial("Z0T") + "' " + CRLF
		cQry += "   AND Z0T.Z0T_DATA   = '" + DTOS(cPerg01) + "' " + CRLF
		cQry += "   AND Z0T.Z0T_VERSAO = '" + cPerg02 + "' " + CRLF
		cQry += "   AND Z0T.Z0T_ROTA   <> '      ' " + CRLF
		cQry += "   AND Z0T.D_E_L_E_T_ = ' ' " + CRLF
		cQry += "   -- Filtros específicos solicitados " + CRLF
		cQry += "   AND Z0S.Z0S_EQUIP = '" + aCab[nItem][2][1] + "' " + CRLF
		cQry += "   AND Z0T.Z0T_ROTA  = '" + aCab[nItem][2][4] + "' " + CRLF
		cQry += " GROUP BY  " + CRLF
		cQry += "     Z0S.Z0S_EQUIP, " + CRLF
		cQry += "     ZV0.ZV0_IDENT, " + CRLF
		cQry += "     Z0S.Z0S_OPERAD, " + CRLF
		cQry += "     Z0U.Z0U_NOME, " + CRLF
		cQry += "     Z0T.Z0T_ROTA, " + CRLF
		cQry += "     Z06.Z06_TRATO, " + CRLF
		cQry += "     Z06.Z06_DIETA, " + CRLF
		cQry += "     ZV0.ZV0_DIVISA " + CRLF
		cQry += " ORDER BY  " + CRLF
		cQry += "     Z06.Z06_TRATO " + CRLF

		if Lower(cUserName) $ "administrador,admin,ioliveira"
			MemoWrite( "C:\totvs_relatorios\VAPCPA08-LoadItens"+cValToChar(nItem)+"-Executa.SQL", cQry)
		endif

		cAlias := MpSysOpenQuery(cQry)

		while !(cAlias)->(Eof())
			AAdd(aDados, {0, {(cAlias)->Z0T_ROTA, (cAlias)->Z06_TRATO, (cAlias)->Z06_DIETA, Round((cAlias)->QTDMNCOMP, TamSX3("Z05_KGMNDI")[2])}})
			(cAlias)->(DbSkip())
		end
		(cAlias)->(DbCloseArea())

		cQry := " DROP TABLE " + cTabDietas
		cQry += " DROP TABLE " + cTabVersao
		cQry += " DROP TABLE " + cTabComp
		cQry += " DROP TABLE " + cTabQBase

		if Lower(cUserName) $ "administrador,admin,ioliveira"
			MemoWrite( "C:\totvs_relatorios\VAPCPA08-LoadItens"+cValToChar(nItem)+"-Drop.SQL", cQry)
		endif

		If TCSqlExec(cQry) < 0
			MsgAlert("Erro SQL na exclusão: " + TCSqlError())
			RestArea(aArea)
			Return {0, {"", "", "", "", 0}}
		EndIf

	endif

	if !Empty(aArea)
		RestArea(aArea)
	endif
return aDados

/*/{Protheus.doc} AtuSX1
Cria pergunta VAPCPA08 no SX1
@author jr.andre
@since 18/09/2019
@version 1.0
@return nil
@param cPerg, characters, descricao
@type function
/*/
static function AtuSX1(cPerg)
	local aArea    := GetArea()
	local aAreaDic := SX1->( GetArea() )
	local aEstrut  := {}
	local aStruDic := SX1->( dbStruct() )
	local aDados   := {}
	local i        := 0
	local j        := 0
	local nTam1    := Len( SX1->X1_GRUPO )
	local nTam2    := Len( SX1->X1_ORDEM )

	cPerg := PadR(cPerg, Len(SX1->X1_GRUPO))

	if !SX1->( DbSeek( cPerg ) )

		aEstrut := { "X1_GRUPO"  , "X1_ORDEM"  , "X1_PERGUNT", "X1_PERSPA" , "X1_PERENG" , "X1_VARIAVL", "X1_TIPO"   , ;
					"X1_TAMANHO", "X1_DECIMAL", "X1_PRESEL" , "X1_GSC"    , "X1_VALID"  , "X1_VAR01"  , "X1_DEF01"  , ;
					"X1_DEFSPA1", "X1_DEFENG1", "X1_CNT01"  , "X1_VAR02"  , "X1_DEF02"  , "X1_DEFSPA2", "X1_DEFENG2", ;
					"X1_CNT02"  , "X1_VAR03"  , "X1_DEF03"  , "X1_DEFSPA3", "X1_DEFENG3", "X1_CNT03"  , "X1_VAR04"  , ;
					"X1_DEF04"  , "X1_DEFSPA4", "X1_DEFENG4", "X1_CNT04"  , "X1_VAR05"  , "X1_DEF05"  , "X1_DEFSPA5", ;
					"X1_DEFENG5", "X1_CNT05"  , "X1_F3"     , "X1_PYME"   , "X1_GRPSXG" , "X1_HELP"   , "X1_PICTURE", ;
					"X1_IDFIL"  }
		
		if cPerg == "VAPCPA08  "
									//123456789012345678901234567890 
			AAdd( aDados, {cPerg,'01','Data?                         ','Data?                         ','Data?                         ','mv_ch1','D', 8,0,0,'G','','mv_par01','','','','','','','','','','','','','','','','','','','','','','','','','Z0R   ','S','','','','', {"Informe a data do trato." + CRLF + "<F3 Disponível>", "Informe a data do trato." + CRLF + "<F3 Disponível>", "Informe a data do trato." + CRLF + "<F3 Disponível>"}} )
			AAdd( aDados, {cPerg,'02','Versão?                       ','Versão?                       ','Versão?                       ','mv_ch2','C', 4,0,0,'G','','mv_par02','','','','','','','','','','','','','','','','','','','','','','','','','      ','S','','','','', {"Informe a versão do trato." + CRLF + "<F3 Disponível>", "Informe a versão do trato" + CRLF + "<F3 Disponível>", "Informe a versão do trato." + CRLF + "<F3 Disponível>"}} )
		
		endif

		DbSelectArea( "SX1" )
		SX1->( DbSetOrder( 1 ) )
		
		nLenLin := Len( aDados )
		for i := 1 to nLenLin
			if !SX1->( DbSeek( PadR( aDados[i][1], nTam1 ) + PadR( aDados[i][2], nTam2 ) ) )
				RecLock( "SX1", .t. )
				nLenCol := Len( aEstrut )
				for j := 1 to nLenCol
					if aScan( aStruDic, { |aX| PadR( aX[1], 10 ) == PadR( aEstrut[j], 10 ) } ) > 0
						SX1->( FieldPut( FieldPos( aEstrut[j] ), aDados[i][j] ) )
					endif
				next
				MsUnLock()
	//            u_UpSX1Hlp( "P." + AllTrim(SX1->X1_GRUPO) + AllTrim(SX1->X1_ORDEM) + ".", aDados[i][nLenCol+1], .t.)
			endif
		next
	endif

	Pergunte(cPerg, .f.)

	RestArea( aAreaDic )
	RestArea( aArea )

return nil

/*/{Protheus.doc} Exportar
Chama a rotina de exportação dos arquivios
@author jr.andre
@since 18/09/2019
@version 1.0
@return nil
@type function
/*/
static function Exportar()
	local aParam := {mv_par01, mv_par02, mv_par03, mv_par04, mv_par05}
	local aEnButt := { {.f., nil},;         // 1 - Copiar
					{.f., nil},;         // 2 - Recortar
					{.f., nil},;         // 3 - Colar
					{.f., nil},;         // 4 - Calculadora
					{.f., nil},;         // 5 - Spool
					{.f., nil},;         // 6 - Imprimir
					{.f., nil},;         // 7 - Confirmar
					{.t., "Fechar"},;    // 8 - Cancelar
					{.f., nil},;         // 9 - WalkTrhough
					{.f., nil},;         // 10 - Ambiente
					{.f., nil},;         // 11 - Mashup
					{.t., nil},;         // 12 - Help
					{.f., nil},;         // 13 - Formulário HTML
					{.f., nil},;         // 14 - ECM
					{.f., nil} }         // 15 - Salvar e Criar novo
	local cPrgExp := "VAPCPA13X"
	local oModel := FWModelActive()
	local cVeiculo := oModel:GetModel("MdGridCab"):GetValue("Z0S_EQUIP")
	local i, nLen

	private aParRet := {}
	private cRotSel  := ""
	Private aTik    := {LoadBitmap( GetResources(), "LBTIK" ), LoadBitmap( GetResources(), "LBNO" )}


	U_PosSX1({{"VAPCPA13X", "01", DToS(cPerg01)}, {"VAPCPA13X", "02", 1}, {"VAPCPA13X", "03", cVeiculo}, {"VAPCPA13X", "04", Space(60)},  {"VAPCPA13X", "05", 2}})

	if (Pergunte(cPrgExp, .t.))
		AAdd(aParRet, mv_par01)
		AAdd(aParRet, "0001")
		AAdd(aParRet, mv_par03)
		AAdd(aParRet, mv_par02)
		AAdd(aParRet, mv_par05)
		
		//IF Type("mv_par06") == "U"
		//    mv_par06 := 1
		//else
		//  IF mv_par06 == "0"
		//    mv_par06 := "1"
		//  EndIf 
		//EndIf 
		AAdd(aParRet, mv_par04)
		//FWMsgRun(, {|| U_ExpBatTrt()}, "Processando", "Gerando arquivo...")
		U_ExpBatTrt()
	endif

	nLen := Len(aParam)
	for i := 1 to nLen
		&("mv_par"+StrZero(i, 2)) := aParam[i]
	next

return nil

Static Function MontaQuery()
	Local cQry := ""

	cQry := " with QBASE as (" + CRLF
	cQry += " select ZG1_COD, sum(ZG1_QUANT) QUANT" + CRLF
	cQry += " from " + RetSqlName("ZG1") + " ZG1" + CRLF
	cQry += " where ZG1.ZG1_FILIAL = '" + FWxFilial("ZG1") + "'" + CRLF
	cQry += " and ZG1.ZG1_DTALT  <= '" + DToS(cPerg01) + "'" + CRLF
	cQry += " and ZG1.ZG1_SEQ    = (" + CRLF
	cQry += " select max(ZG1_SEQ)" + CRLF
	cQry += " from (" + CRLF
	cQry += " select max(ZG1_SEQ) ZG1_SEQ" + CRLF
	cQry += " from " + RetSqlName("ZG1") + " MAXZG1" + CRLF
	cQry += " where MAXZG1.ZG1_FILIAL = ZG1.ZG1_FILIAL" + CRLF
	cQry += " and MAXZG1.ZG1_COD    = ZG1.ZG1_COD" + CRLF
	cQry += " and MAXZG1.ZG1_DTALT  <= '" + DToS(cPerg01) + "'" + CRLF
	cQry += " and MAXZG1.D_E_L_E_T_ = ' '" + CRLF
	cQry += " ) ZG1" + CRLF
	cQry += " )" + CRLF
	cQry += " and ZG1.D_E_L_E_T_ = ' '" + CRLF
	cQry += " group by ZG1_COD" + CRLF
	cQry += " )" + CRLF
	cQry += " , MAXSEQ as (" + CRLF
	cQry += " select ZG1.ZG1_COD, ZG1.ZG1_COMP, max(ZG1.ZG1_SEQ) ZG1_SEQ" + CRLF
	cQry += " from " + RetSqlName("ZG1") + " ZG1" + CRLF
	cQry += " where ZG1.ZG1_FILIAL = '" + FWxFilial("ZG1") + "'" + CRLF
	cQry += " and ZG1.ZG1_COD    = ZG1.ZG1_COD" + CRLF
	cQry += " and ZG1.ZG1_DTALT  <= '" + DToS(cPerg01) + "'" + CRLF
	cQry += " and ZG1.ZG1_SEQ    = (" + CRLF
	cQry += " select max(ZG1_SEQ)" + CRLF
	cQry += " from (" + CRLF
	cQry += " select max(ZG1_SEQ) ZG1_SEQ" + CRLF
	cQry += " from " + RetSqlName("ZG1") + " MAXZG1" + CRLF
	cQry += " where MAXZG1.ZG1_FILIAL = ZG1.ZG1_FILIAL" + CRLF
	cQry += " and MAXZG1.ZG1_COD    = ZG1.ZG1_COD" + CRLF
	cQry += " and MAXZG1.ZG1_DTALT  <= '" + DToS(cPerg01) + "'" + CRLF
	cQry += " and MAXZG1.D_E_L_E_T_ = ' '" + CRLF
	cQry += " ) ZG1" + CRLF
	cQry += " )" + CRLF
	cQry += " and ZG1.D_E_L_E_T_ = ' '" + CRLF
	cQry += " group by ZG1.ZG1_COD, ZG1.ZG1_COMP" + CRLF
	cQry += " )" + CRLF
	cQry += " , ZG1 as (" + CRLF
	cQry += " select ZG1.ZG1_COD, ZG1.ZG1_COMP, ZG1_QUANT" + CRLF
	cQry += " from " + RetSqlName("ZG1") + " ZG1" + CRLF
	cQry += " join MAXSEQ" + CRLF
	cQry += " on ZG1.ZG1_COD    = MAXSEQ.ZG1_COD" + CRLF
	cQry += " and ZG1.ZG1_COMP   = MAXSEQ.ZG1_COMP" + CRLF
	cQry += " and ZG1.ZG1_SEQ    = MAXSEQ.ZG1_SEQ" + CRLF
	cQry += " where ZG1.ZG1_FILIAL = '" + FWxFilial("ZG1") + "'" + CRLF
	cQry += " and ZG1.D_E_L_E_T_ = ' '" + CRLF
	cQry += " and ZG1.ZG1_DTALT  <= '" + DToS(cPerg01) + "'" + CRLF
	cQry += " and ZG1.ZG1_COD in (" + CRLF
	cQry += " select distinct Z06_DIETA" + CRLF
	cQry += " from " + RetSqlName("Z06") + " Z06" + CRLF
	cQry += " where Z06.Z06_FILIAL = '" + FWxFilial("Z06") + "'" + CRLF
	cQry += " and Z06.Z06_DATA   = '" + DToS(cPerg01) + "'" + CRLF
	cQry += " and Z06.Z06_VERSAO = '" + cPerg02 + "'" + CRLF
	cQry += " and Z06.D_E_L_E_T_ = ' '" + CRLF
	cQry += " )" + CRLF
	cQry += " )" + CRLF
	cQry += " , CARREGAMENTO as (" + CRLF
	cQry += " select Z0S.Z0S_EQUIP" + CRLF
	cQry += " , isnull(ZV0.ZV0_IDENT, '          ') ZV0_IDENT" + CRLF
	cQry += " , Z0S.Z0S_OPERAD" + CRLF
	cQry += " , isnull(Z0U.Z0U_NOME, '                                                                                                    ') Z0U_NOME" + CRLF
	cQry += " , Z0T.Z0T_ROTA" + CRLF
	cQry += " , Z06.Z06_TRATO" + CRLF
	cQry += " , Z06.Z06_DIETA" + CRLF
	cQry += " , case " + CRLF
	cQry += " when log10(ZV0.ZV0_DIVISA) - floor(log10(ZV0.ZV0_DIVISA)) = 0 " + CRLF
	cQry += " then round(sum((100*Z06.Z06_KGMSTR*ZG1.ZG1_QUANT*Z05.Z05_CABECA)/(QBASE.QUANT*Z0V.Z0V_INDMS)), -1*log10(ZV0.ZV0_DIVISA))" + CRLF
	cQry += " else round(sum((100*Z06.Z06_KGMSTR*ZG1.ZG1_QUANT*Z05.Z05_CABECA)/(QBASE.QUANT*Z0V.Z0V_INDMS))*2, -1*round(log10(ZV0.ZV0_DIVISA*2), 0))/2" + CRLF
	cQry += " end  QTDMNCOMP" + CRLF
	cQry += " from " + RetSqlName("Z0T") + " Z0T" + CRLF
	cQry += " join " + RetSqlName("Z05") + " Z05" + CRLF
	cQry += " on Z05.Z05_FILIAL = '" + FWxFilial("Z05") + "'" + CRLF
	cQry += " and Z05.Z05_DATA   = Z0T.Z0T_DATA" + CRLF
	cQry += " and Z05.Z05_VERSAO = Z0T.Z0T_VERSAO" + CRLF
	cQry += " and Z05.Z05_CURRAL = Z0T.Z0T_CURRAL" + CRLF
	cQry += " and Z05.D_E_L_E_T_ = ' '" + CRLF
	cQry += " join " + RetSqlName("Z06") + " Z06" + CRLF
	cQry += " on Z06.Z06_FILIAL = '" + FWxFilial("Z06") + "'" + CRLF
	cQry += " and Z06.Z06_DATA   = Z05.Z05_DATA" + CRLF
	cQry += " and Z06.Z06_VERSAO = Z05.Z05_VERSAO" + CRLF
	cQry += " and Z06.Z06_LOTE   = Z05.Z05_LOTE" + CRLF
	cQry += " and Z06.D_E_L_E_T_ = ' '" + CRLF
	cQry += " join ZG1" + CRLF
	cQry += " on ZG1.ZG1_COD    = Z06.Z06_DIETA" + CRLF
	cQry += " join QBASE" + CRLF
	cQry += " on QBASE.ZG1_COD = Z06.Z06_DIETA" + CRLF
	cQry += " join " + RetSqlName("Z0V") + " Z0V" + CRLF
	cQry += " on Z0V.Z0V_FILIAL = '" + FWxFilial("Z0V") + "'" + CRLF
	cQry += " and Z0V.Z0V_COMP   = ZG1.ZG1_COMP" + CRLF
	cQry += " and Z0V.Z0V_DATA   = Z0T.Z0T_DATA" + CRLF
	cQry += " and Z0V_VERSAO     = Z0T.Z0T_VERSAO" + CRLF
	cQry += " and Z0V.D_E_L_E_T_ = ' '" + CRLF
	cQry += " left join " + RetSqlName("Z0S") + " Z0S" + CRLF
	cQry += " on Z0S.Z0S_FILIAL = '" + FWxFilial("Z0S") + "'" + CRLF
	cQry += " and Z0S.Z0S_DATA   = Z0T.Z0T_DATA" + CRLF
	cQry += " and Z0S.Z0S_VERSAO = Z0T.Z0T_VERSAO" + CRLF
	cQry += " and Z0S.Z0S_ROTA   = Z0T.Z0T_ROTA" + CRLF
	cQry += " and Z0S.D_E_L_E_T_ = ' '" + CRLF
	cQry += " left join " + RetSqlName("ZV0") + " ZV0" + CRLF
	cQry += " on ZV0.ZV0_FILIAL = '" + FWxFilial("ZV0") + "'" + CRLF
	cQry += " and ZV0.ZV0_CODIGO = Z0S.Z0S_EQUIP" + CRLF
	cQry += " and ZV0.D_E_L_E_T_ = ' '" + CRLF
	cQry += " left join " + RetSqlName("Z0U") + " Z0U" + CRLF
	cQry += " on Z0U.Z0U_FILIAL = '" + FWxFilial("Z0U") + "'" + CRLF
	cQry += " and Z0U.Z0U_CODIGO = Z0S.Z0S_OPERAD" + CRLF
	cQry += " and Z0U.D_E_L_E_T_ = ' '" + CRLF
	cQry += " where Z0T.Z0T_FILIAL = '" + FWxFilial("Z0T") + "'" + CRLF
	cQry += " and Z0T.Z0T_DATA   = '" + DToS(cPerg01) + "'" + CRLF
	cQry += " and Z0T.Z0T_VERSAO = '" + cPerg02 + "'" + CRLF
	cQry += " and Z0T.Z0T_ROTA   <> '      '" + CRLF
	cQry += " and Z0T.D_E_L_E_T_ = ' '" + CRLF
	cQry += " group by Z0S.Z0S_EQUIP" + CRLF
	cQry += " , ZV0.ZV0_IDENT" + CRLF
	cQry += " , Z0S.Z0S_OPERAD" + CRLF
	cQry += " , Z0U.Z0U_NOME" + CRLF
	cQry += " , Z0T.Z0T_ROTA" + CRLF
	cQry += " , Z06.Z06_TRATO" + CRLF
	cQry += " , Z06.Z06_DIETA" + CRLF
	cQry += " , ZV0.ZV0_DIVISA" + CRLF
	cQry += ")" + CRLF
	cQry += " select Z0S_EQUIP" + CRLF
	cQry += ", ZV0_IDENT" + CRLF
	cQry += ", Z0S_OPERAD" + CRLF
	cQry += ", Z0U_NOME" + CRLF
	cQry += ", Z0T_ROTA" + CRLF
	cQry += ", Z06_TRATO" + CRLF
	cQry += ", Z06_DIETA" + CRLF
	cQry += ", sum(QTDMNCOMP) QTDMNCOMP" + CRLF
	cQry += " from CARREGAMENTO" + CRLF
	cQry += " where Z0S_EQUIP = ?" + CRLF
	cQry += " and Z0T_ROTA  = ?" + CRLF
	cQry += " group by Z0S_EQUIP" + CRLF
	cQry += " , ZV0_IDENT" + CRLF
	cQry += " , Z0S_OPERAD" + CRLF
	cQry += " , Z0U_NOME" + CRLF
	cQry += " , Z0T_ROTA" + CRLF
	cQry += " , Z06_TRATO" + CRLF
	cQry += " , Z06_DIETA" + CRLF

	oExecQry := FWExecStatement():New(cQry)
Return
