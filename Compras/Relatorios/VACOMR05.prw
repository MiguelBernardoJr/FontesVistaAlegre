#include 'protheus.ch'
#include 'parmtype.ch'

user function runVCR05()
    u_RunFunc("u_rvacr05()")
return nil

user function rvacr05()
    DbSelectArea("SC8")
    DbSetOrder(1) 
    DbSeek(xFilial("SC8")+"000014")
    u_vacomr05(SC8->C8_NUM)
return nil

user function vacomr05(cAlias, nReg, nOpc)
    GeraPlan(SC8->C8_NUM)
return nil

user function SC8Plan(cNumCot)
return GeraPlan(cNumCot, .f.)

static function GeraPlan(cNumCot, lAbreCliente)
local aAreaSC8 := {}
local aCotacao := {}
local aFornece := {}
local cSql := ""
local nPosFornec := 0 
local nPosProd := 0
local lContinua := .t.

private dEmissao := SToD("")
private cNumCotacao := ""

default lAbreCliente := .t.

    DbSelectArea("SC8")
    DbSetOrder(1) //
    if SC8->C8_NUM <> cNumCot
        aAreaSC8 := SC8->(GetArea())
        if !SC8->(DbSeek(xFilial("SC8")+cNumCot))
            ShowHelpDlg("VACOMR05", {"Não foi identificada a cotação nro " + cNumCot + ". Não é possível imprimir."}, 1, {""}, 1)
            lContinua := .f.
        endif
    endif

    if lContinua
    
        cNumCotacao := Iif(cNumCot == nil, SC8->C8_NUM, cNumCot)
        if Empty(dEmissao)
            dEmissao := SC8->C8_EMISSAO
        endif
        
        DbSelectArea("SB2")
        DbSetOrder(1) // B2_FILIAL + B2_COD + B2_LOCAL
        
        cSql := " select SC8.C8_NUM "
        cSql += " , SC8.C8_FORNECE "
        cSql += " , SC8.C8_LOJA "
        cSql += " , SA2.A2_NREDUZ "
        cSql += " , SC8.C8_ITEM "
        cSql += " , SC8.C8_PRODUTO "
        cSql += " , SB1.B1_DESC "
        cSql += " , SC8.C8_UM "
        cSql += " , SC8.C8_NUMPRO "
        cSql += " , SC8.C8_QUANT "
        cSql += " , SC8.C8_PRECO "
        cSql += " , SC8.C8_TOTAL "
        cSql += " , SC8.C8_EMISSAO "
        cSql += " , SC8.C8_COND "
        cSql += " , SE4.E4_DESCRI "
        cSql += " , SC8.C8_XMARCA "
        cSql += " , SC8.C8_EMISSAO "
        cSql += " from " + RetSqlName("SC8") + " SC8 "
        cSql += " join " + RetSqlName("SA2") + " SA2 "
        cSql += " on SA2.A2_FILIAL  = '" + xFilial("SA2") + "'"
        cSql += " and SA2.A2_COD     = SC8.C8_FORNECE "
        cSql += " and SA2.A2_LOJA    = SC8.C8_LOJA "
        cSql += " and SA2.D_E_L_E_T_ = ' ' "
        cSql += " join " + RetSqlName("SB1") + " SB1 "
        cSql += " on SB1.B1_FILIAL  = '" + xFilial("SB1") + "'"
        cSql += " and SB1.B1_COD     = SC8.C8_PRODUTO "
        cSql += " and SB1.D_E_L_E_T_ = ' ' "
        cSql += " left join " + RetSqlName("SE4") + " SE4 "
        cSql += " on SE4.E4_FILIAL  = '" + xFilial("SE4") + "'  "
        cSql += " and SE4.E4_CODIGO  = SC8.C8_COND "
        cSql += " and SE4.D_E_L_E_T_ = ' ' "
        cSql += " where SC8.C8_FILIAL  = '" + xFilial("SC8") + "'"
        cSql += " and SC8.C8_NUM     = '" + cNumCot + "'"
        cSql += " and SC8.D_E_L_E_T_ = ' ' "
        cSql += " order by SC8.C8_NUMPRO, SC8.C8_FORNECE, SC8.C8_LOJA, SC8.C8_ITEM"
        
        DbUseArea(.t., "TOPCONN", TCGenQry(,, cSql), "TMPSC8", .f., .f.)
        
        while !TMPSC8->(Eof())
        
            if (nPosProd := AScan(aCotacao, {|aMat| aMat[1] == TMPSC8->C8_PRODUTO})) == 0
                AAdd(aCotacao, {TMPSC8->C8_PRODUTO, TMPSC8->C8_UM, TMPSC8->C8_QUANT, SaldoTot(TMPSC8->C8_PRODUTO), aClone(aFornece) })
                nPosProd := Len(aCotacao)
            endif
        
            if (nPosFornec := aScan(aCotacao[nPosProd][5], {|aMat| aMat[1] == TMPSC8->C8_FORNECE + TMPSC8->C8_LOJA})) == 0 
                nPosFornec := AdFornec(TMPSC8->C8_FORNECE + TMPSC8->C8_LOJA, @aFornece, @aCotacao)
            endif
        
            // '{' Fornecedor, Num Proposta, CondPgto, Marca, PrcUnit, Total '}' 
            aCotacao[nPosProd][5][nPosFornec][2] := TMPSC8->C8_NUMPRO
            aCotacao[nPosProd][5][nPosFornec][3] := TMPSC8->C8_COND + "-" + TMPSC8->E4_DESCRI
            aCotacao[nPosProd][5][nPosFornec][4] := TMPSC8->C8_XMARCA
            aCotacao[nPosProd][5][nPosFornec][5] := TMPSC8->C8_PRECO//iF(TMPSC8->C8_PRECO > 0,TMPSC8->C8_PRECO,"")
            aCotacao[nPosProd][5][nPosFornec][6] := TMPSC8->C8_TOTAL
        
            TMPSC8->(DbSkip())
        end
        TMPSC8->(DbCloseArea())
        
        //MemoWrite("acotacao.txt", u_AToS(aCotacao))
        
        if !Empty(aCotacao)
            cFileName := CriaArqExcel( aCotacao )
            if lAbreCliente 
                if (CpyS2T(cFileName, Alltrim(GetTempPath())))
                    fErase(cFileName)
                    cFileName := SubStr(cFileName, RAt("\", cFileName)+1)
                    
                    // Abre excell
                    if !ApOleClient( 'MsExcel' )
                        MsgAlert("O excel não foi encontrado. Arquivo " + cFileName + " gerado em " + GetTempPath() + ".", "MsExcel não encontrado" )
                    else
                        oExcelApp := MsExcel():New()
                        oExcelApp:WorkBooks:Open(GetTempPath()+cFileName)
                        oExcelApp:SetVisible(.T.)
                    endif
                else
                    MsgAlert("Não foi possivel criar o arquivo " + cFileName + " no cliente no diretório " + GetTempPath() + ". Por favor, contacte o suporte.", "Não foi possivel criar Planilha." )
                endif
                cFileName := nil
            endif
        endif
    endif 

if !Empty(aAreaSC8)
    RestArea(aAreaSC8)
endif
return cFileName

static function CriaArqExcel( aCotacao )
local nHandle := 0
local aVetDir := {}
local cFileName := ""
Local i       := 0
Local J       := 0

    aVetDir := Directory("\workflow\*.","D")
    if aScan(aVetDir,{|aMat| aMat[1] == "TEMP" .and. aMat[5] == "D"}) == 0
        MakeDir("\workflow\temp")
    endif 

    nHandle := FCreate(cFileName := "\workflow\temp\cotac_" + cNumCotacao + ".xml")

    FWrite(nHandle, '<?xml version="1.0"?>' + CRLF)
    FWrite(nHandle, '<?mso-application progid="Excel.Sheet"?>' + CRLF)
    FWrite(nHandle, '<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"' + CRLF +;
                    '          xmlns:o="urn:schemas-microsoft-com:office:office"' + CRLF +;
                    '          xmlns:x="urn:schemas-microsoft-com:office:excel"' + CRLF +;
                    '          xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"' + CRLF +;
                    '          xmlns:html="http://www.w3.org/TR/REC-html40">' + CRLF)
    FWrite(nHandle, '    <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">' + CRLF)
    FWrite(nHandle, '        <Keywords>Cotação Nro ' + cNumCotacao + '</Keywords>' + CRLF)
    FWrite(nHandle, '        <Created>' + TimeStamp() + 'Z</Created>' + CRLF)
    FWrite(nHandle, '        <Version>16.00</Version>' + CRLF)
    FWrite(nHandle, '    </DocumentProperties>' + CRLF)
    FWrite(nHandle, '    <OfficeDocumentSettings xmlns="urn:schemas-microsoft-com:office:office">' + CRLF +;
                    '        <AllowPNG/>' + CRLF +;
                    '        <RemovePersonalInformation/>' + CRLF +;
                    '    </OfficeDocumentSettings>' + CRLF)
    FWrite(nHandle, '    <ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF +;
                    '        <WindowHeight>7530</WindowHeight>' + CRLF +;
                    '        <WindowWidth>20490</WindowWidth>' + CRLF +;
                    '        <WindowTopX>0</WindowTopX>' + CRLF +;
                    '        <WindowTopY>0</WindowTopY>' + CRLF +;
                    '        <ProtectStructure>False</ProtectStructure>' + CRLF +;
                    '        <ProtectWindows>False</ProtectWindows>' + CRLF +;
                    '    </ExcelWorkbook>' + CRLF)
    FWrite(nHandle, '    <Styles>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="Default" ss:Name="Normal">' + CRLF +;
                    '            <Alignment ss:Vertical="Bottom"/>' + CRLF +;
                    '             <Borders/>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>' + CRLF +;
                    '            <Interior/>' + CRLF +;
                    '            <NumberFormat/>' + CRLF +;
                    '            <Protection/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="s16" ss:Name="Moeda">' + CRLF +;
                    '            <NumberFormat ss:Format="_-&quot;R$&quot;\ * #,##0.00_-;\-&quot;R$&quot;\ * #,##0.00_-;_-&quot;R$&quot;\ * &quot;-&quot;??_-;_-@_-"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="s17" ss:Name="Vírgula">' + CRLF +;
                    '            <NumberFormat ss:Format="_-* #,##0.00_-;\-* #,##0.00_-;_-* &quot;-&quot;??_-;_-@_-"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="m320402680">' + CRLF +;
                    '            <Alignment ss:Horizontal="Right" ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Bold="1"/>' + CRLF +;
                    '            <NumberFormat ss:Format="Standard"/>' + CRLF +;
                    '            <Protection ss:Protected="0"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="m320402700">' + CRLF +;
                    '            <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Bold="1"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="m320402720">' + CRLF +;
                    '            <Alignment ss:Horizontal="Right" ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Bold="1"/>' + CRLF +;
                    '            <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>' + CRLF +;
                    '            <NumberFormat ss:Format="Standard"/>' + CRLF +;
                    '            <Protection ss:Protected="0"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="m320402740">' + CRLF +;
                    '            <Alignment ss:Horizontal="Right" ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Bold="1"/>' + CRLF +;
                    '            <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>' + CRLF +;
                    '            <NumberFormat ss:Format="Standard"/>' + CRLF +;
                    '            <Protection ss:Protected="0"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="m2126159379956"> '+ CRLF +;
                    '            <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>' + CRLF +;
                    '             <Borders>' + CRLF +;
                    '              <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF +;
                    '               ss:Color="#808080"/>' + CRLF +;
                    '              <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF +;
                    '               ss:Color="#808080"/>' + CRLF +;
                    '              <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF +;
                    '               ss:Color="#808080"/>' + CRLF +;
                    '              <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"' + CRLF +;
                    '               ss:Color="#808080"/>' + CRLF +;
                    '             </Borders>' + CRLF +;
                    '             <Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000" ss:Bold="1"/>' + CRLF +;
                    '             <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>' + CRLF +;
                    '             <NumberFormat ss:Format="#,##0.00_ ;\-#,##0.00\ "/>' + CRLF +;
                    '        </Style> '+ CRLF )
    
    FWrite(nHandle, '        <Style ss:ID="m320402760">' + CRLF +;
                    '            <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Bold="1"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="m320402780">' + CRLF +;
                    '            <Alignment ss:Horizontal="Right" ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Bold="1"/>' + CRLF +;
                    '            <NumberFormat/>' + CRLF +;
                    '            <Protection ss:Protected="0"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="m320402800">' + CRLF +;
                    '            <Alignment ss:Horizontal="Right" ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Bold="1"/>' + CRLF +;
                    '            <NumberFormat/>' + CRLF +;
                    '            <Protection ss:Protected="0"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="m320402820">' + CRLF +;
                    '            <Alignment ss:Horizontal="Right" ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Bold="1"/>' + CRLF +;
                    '            <NumberFormat ss:Format="Standard"/>' + CRLF +;
                    '            <Protection ss:Protected="0"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="m320402840">' + CRLF +;
                    '            <Alignment ss:Horizontal="Right" ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Bold="1"/>' + CRLF +;
                    '            <NumberFormat ss:Format="Standard"/>' + CRLF +;
                    '            <Protection ss:Protected="0"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="m320402432">' + CRLF +;
                    '            <Alignment ss:Horizontal="Right" ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Bold="1"/>' + CRLF +;
                    '            <NumberFormat ss:Format="Standard"/>' + CRLF +;
                    '            <Protection ss:Protected="0"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="m320402452">' + CRLF +;
                    '            <Alignment ss:Horizontal="Right" ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Bold="1"/>' + CRLF +;
                    '            <NumberFormat ss:Format="Standard"/>' + CRLF +;
                    '            <Protection ss:Protected="0"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="m320402472">' + CRLF +;
                    '            <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Bold="1"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="m320402492">' + CRLF +;
                    '            <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Bold="1"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="m320408336">' + CRLF +;
                    '            <Alignment ss:Horizontal="Right" ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Bold="1"/>' + CRLF +;
                    '            <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>' + CRLF +;
                    '            <NumberFormat ss:Format="Standard"/>' + CRLF +;
                    '            <Protection ss:Protected="0"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="m320408376">' + CRLF +;
                    '            <Alignment ss:Horizontal="Right" ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Bold="1"/>' + CRLF +;
                    '            <NumberFormat/>' + CRLF +;
                    '            <Protection ss:Protected="0"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="m320408396">' + CRLF +;
                    '            <Alignment ss:Horizontal="Right" ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Bold="1"/>' + CRLF +;
                    '            <NumberFormat ss:Format="Standard"/>' + CRLF +;
                    '            <Protection ss:Protected="0"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="m320408436">' + CRLF +;
                    '            <Alignment ss:Horizontal="Right" ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Bold="1"/>' + CRLF +;
                    '            <NumberFormat/>' + CRLF +;
                    '            <Protection ss:Protected="0"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="m320408456">' + CRLF +;
                    '            <Alignment ss:Horizontal="Right" ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Bold="1"/>' + CRLF +;
                    '            <NumberFormat ss:Format="Standard"/>' + CRLF +;
                    '            <Protection ss:Protected="0"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="m320408476">' + CRLF +;
                    '            <Alignment ss:Horizontal="Right" ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Bold="1"/>' + CRLF +;
                    '            <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>' + CRLF +;
                    '            <NumberFormat ss:Format="Standard"/>' + CRLF +;
                    '            <Protection ss:Protected="0"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="m320408556">' + CRLF +;
                    '            <Alignment ss:Horizontal="Right" ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Bold="1"/>' + CRLF +;
                    '            <NumberFormat ss:Format="Standard"/>' + CRLF +;
                    '            <Protection ss:Protected="0"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="m320408624">' + CRLF +;
                    '            <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF" ss:Bold="1"/>' + CRLF +;
                    '            <Interior ss:Color="#808080" ss:Pattern="Solid"/>' + CRLF +;
                    '            <NumberFormat ss:Format="Short Date"/>' + CRLF +;
                    '            <Protection/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="m320408664" ss:Parent="s16">' + CRLF +;
                    '            <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>' + CRLF +;
                    '            <Protection ss:Protected="0"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="m320408684">' + CRLF +;
                    '            <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <NumberFormat ss:Format="Short Date"/>' + CRLF +;
                    '            <Protection ss:Protected="0"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="s18">' + CRLF +;
                    '            <Alignment ss:Vertical="Center"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="s19">' + CRLF +;
                    '            <Alignment ss:Vertical="Center"/>' + CRLF +;
                    '            <NumberFormat ss:Format="Standard"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="s20" ss:Parent="s16">' + CRLF +;
                    '            <Alignment ss:Vertical="Center"/>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="s21">' + CRLF +;
                    '            <Alignment ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="s22">' + CRLF +;
                    '            <Alignment ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="2"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="s23">' + CRLF +;
                    '            <Alignment ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders/>' + CRLF +;
                    '            <NumberFormat ss:Format="Short Date"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="s24">' + CRLF +;
                    '            <Alignment ss:Vertical="Center"/>' + CRLF +;
                    '            <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="s25" ss:Parent="s16">' + CRLF +;
                    '            <Alignment ss:Vertical="Center"/>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>' + CRLF +;
                    '            <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="s26">' + CRLF +;
                    '            <Alignment ss:Vertical="Center"/>' + CRLF +;
                    '            <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>' + CRLF +;
                    '            <NumberFormat ss:Format="Standard"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="s27">' + CRLF +;
                    '            <Alignment ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders/>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>' + CRLF +;
                    '            <NumberFormat ss:Format="Standard"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="s28">' + CRLF +;
                    '            <Alignment ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders/>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="s29">' + CRLF +;
                    '            <Alignment ss:Horizontal="Right" ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders/>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Bold="1"/>' + CRLF +;
                    '            <NumberFormat ss:Format="Standard"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="s30" ss:Parent="s16">' + CRLF +;
                    '            <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders/>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>' + CRLF +;
                    '            <Protection ss:Protected="0"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="s31">' + CRLF +;
                    '            <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders/>' + CRLF +;
                    '            <NumberFormat ss:Format="Short Date"/>' + CRLF +;
                    '            <Protection ss:Protected="0"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="s32" ss:Parent="s16">' + CRLF +;
                    '            <Alignment ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders/>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="s33">' + CRLF +;
                    '            <Alignment ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Interior ss:Color="#F2F2F2" ss:Pattern="Solid"/>' + CRLF +;
                    '            <Protection ss:Protected="0"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="s34">' + CRLF +;
                    '            <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Interior ss:Color="#F2F2F2" ss:Pattern="Solid"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="s35" ss:Parent="s16">' + CRLF +;
                    '            <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>' + CRLF +;
                    '            <Interior ss:Color="#F2F2F2" ss:Pattern="Solid"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="s36">' + CRLF +;
                    '            <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Interior ss:Color="#F2F2F2" ss:Pattern="Solid"/>' + CRLF +;
                    '            <NumberFormat ss:Format="Standard"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="s37">' + CRLF +;
                    '            <Alignment ss:Vertical="Center" ss:WrapText="1"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000"/>' + CRLF +;
                    '            <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>' + CRLF +;
                    '            <Protection ss:Protected="0"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="s38">' + CRLF +;
                    '            <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000"/>' + CRLF +;
                    '            <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>' + CRLF +;
                    '            <Protection ss:Protected="0"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="s39" ss:Parent="s17">' + CRLF +;
                    '            <Alignment ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000"/>' + CRLF +;
                    '            <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>' + CRLF +;
                    '            <Protection ss:Protected="0"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="s40" ss:Parent="s17">' + CRLF +;
                    '            <Alignment ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000"/>' + CRLF +;
                    '            <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="s41" ss:Parent="s17">' + CRLF +;
                    '            <Alignment ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000"/>' + CRLF +;
                    '            <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>' + CRLF +;
                    '            <NumberFormat/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="s71">' + CRLF +;
                    '            <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders/>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="s72">' + CRLF +;
                    '            <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders/>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>' + CRLF +;
                    '            <NumberFormat ss:Format="Short Date"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="s75">' + CRLF +;
                    '            <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders/>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="22" ss:Color="#C00000" ss:Bold="1"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="s82">' + CRLF +;
                    '            <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>' + CRLF +;
                    '            <Interior ss:Color="#F2F2F2" ss:Pattern="Solid"/>' + CRLF +;
                    '            <NumberFormat ss:Format="Standard"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="s87">' + CRLF +;
                    '            <Alignment ss:Horizontal="Center" ss:Vertical="Center" ss:WrapText="1"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>' + CRLF +;
                    '            <Interior ss:Color="#F2F2F2" ss:Pattern="Solid"/>' + CRLF +;
                    '            <NumberFormat ss:Format="Standard"/>' + CRLF +;
                    '            <Protection ss:Protected="0"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="s94" ss:Parent="s17">' + CRLF +;
                    '            <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>' + CRLF +;
                    '            <Interior ss:Color="#FFFF66" ss:Pattern="Solid"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="s95">' + CRLF +;
                    '            <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Bold="1"/>' + CRLF +;
                    '            <Interior ss:Color="#F2F2F2" ss:Pattern="Solid"/>' + CRLF +;
                    '        </Style>' + CRLF)
    FWrite(nHandle, '        <Style ss:ID="s96">' + CRLF +;
                    '            <Alignment ss:Horizontal="Center" ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000" ss:Bold="1"/>' + CRLF +;
                    '            <Interior ss:Color="#FFFF66" ss:Pattern="Solid"/>' + CRLF +;
                    '        </Style>' + CRLF)

    FWrite(nHandle, '        <Style ss:ID="s110" ss:Parent="s16">' + CRLF +;
                    '            <Alignment ss:Vertical="Center"/>' + CRLF +;
                    '            <Borders>' + CRLF +;
                    '                <Border ss:Position="Bottom" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '                <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1" ss:Color="#808080"/>' + CRLF +;
                    '            </Borders>' + CRLF +;
                    '            <Font ss:FontName="Calibri" x:Family="Swiss" ss:Color="#000000"/>' + CRLF +;
                    '            <Interior ss:Color="#FFFFFF" ss:Pattern="Solid"/>' + CRLF +;
                    '        </Style>' + CRLF)


    FWrite(nHandle, '    </Styles>' + CRLF)
    FWrite(nHandle, '    <Worksheet ss:Name="Cotação ' + FrmtValorExcel(cNumCotacao) + '">' + CRLF)
    FWrite(nHandle, '        <Table x:FullColumns="1" x:FullRows="1" ss:StyleID="s18" ss:DefaultRowHeight="20.0625">' + CRLF)
    FWrite(nHandle, '            <Column ss:StyleID="s18" ss:AutoFitWidth="0" ss:Width="177"/>' + CRLF )
    FWrite(nHandle, '            <Column ss:StyleID="s18" ss:AutoFitWidth="0" ss:Width="63"/>' + CRLF)
    FWrite(nHandle, '            <Column ss:StyleID="s18" ss:AutoFitWidth="0" ss:Width="66"/>' + CRLF)
    FWrite(nHandle, '            <Column ss:StyleID="s18" ss:AutoFitWidth="0" ss:Width="34"/>' + CRLF)

    aFornece := aCotacao[1][5]
    nLenFornec := Len(aFornece)
    for i := 1 to nLenFornec
        FWrite(nHandle, '            <Column ss:StyleID="s18" ss:AutoFitWidth="0" ss:Width="60"/>' + CRLF +;
                        '            <Column ss:StyleID="s18" ss:AutoFitWidth="0" ss:Width="60"/>' + CRLF +;
                        '            <Column ss:StyleID="s18" ss:AutoFitWidth="0" ss:Width="60"/>' + CRLF)
    next

    FWrite(nHandle, '            <Column ss:StyleID="s18" ss:AutoFitWidth="0" ss:Width="63"/>' + CRLF)
    FWrite(nHandle, '            <Column ss:StyleID="s18" ss:AutoFitWidth="0" ss:Width="63"/>' + CRLF)
    FWrite(nHandle, '            <Row ss:AutoFitHeight="0" ss:Height="33">' + CRLF +;
                    '                <Cell ss:MergeAcross="16" ss:StyleID="s75"><Data ss:Type="String">C O T A C A O    D E    P R E C O S</Data><NamedCell ss:Name="Print_Area"/></Cell>' + CRLF +;
                    '            </Row>' + CRLF)
    FWrite(nHandle, '            <Row ss:AutoFitHeight="0">' + CRLF +;
                    '                <Cell ss:StyleID="s22"><NamedCell ss:Name="Print_Area"/></Cell>' + CRLF +;
                    '                <Cell ss:MergeAcross="1" ss:StyleID="s71"><Data ss:Type="String">FAZENDA:</Data><NamedCell ss:Name="Print_Area"/></Cell>' + CRLF +;
                    '                <Cell ss:MergeAcross="9" ss:StyleID="m320408664"><Data ss:Type="String">' + FrmtValorExcel(AllTrim(SM0->M0_ENDENT)) + '</Data><NamedCell ss:Name="Print_Area"/></Cell>' + CRLF +;
                    '                <Cell ss:StyleID="s30"><NamedCell ss:Name="Print_Area"/></Cell>' + CRLF +;
                    '                <Cell ss:StyleID="s21"><NamedCell ss:Name="Print_Area"/></Cell>' + CRLF +;
                    '                <Cell ss:MergeAcross="1" ss:StyleID="m320408624"><Data ss:Type="DateTime">' + FrmtValorExcel(dEmissao) + '</Data><NamedCell ss:Name="Print_Area"/></Cell>' + CRLF +;
                    '            </Row>' + CRLF)
    FWrite(nHandle, '            <Row ss:AutoFitHeight="0"></Row>' + CRLF)
    FWrite(nHandle, '            <Row ss:AutoFitHeight="0" ss:Height="33">' + CRLF +;
                    '                <Cell ss:MergeAcross="3" ss:StyleID="s87"><Data ss:Type="String">DESCRICAO</Data><NamedCell ss:Name="Print_Area"/></Cell>' + CRLF)
    aFornece := aCotacao[1][5]
    nLenFornec := Len(aFornece)
    for i := 1 to nLenFornec
        FWrite(nHandle, '                <Cell ss:MergeAcross="2" ss:StyleID="s87"><Data ss:Type="String">' + FrmtValorExcel( AllTrim(Posicione("SA2", 1, xFilial("SA2")+aFornece[i][1], "A2_NREDUZ"))) + '</Data><NamedCell ss:Name="Print_Area"/></Cell>')
    next
    FWrite(nHandle, '                <Cell ss:MergeAcross="1" ss:StyleID="s87"><Data ss:Type="String">VALOR MINIMO</Data><NamedCell ss:Name="Print_Area"/></Cell>' + CRLF +;
                    '            </Row>' + CRLF)
    FWrite(nHandle, '            <Row ss:AutoFitHeight="0">' + CRLF +;
                    '                <Cell ss:StyleID="s33"><Data ss:Type="String">REQ.: ' + FrmtValorExcel(cNumCotacao) + '</Data><NamedCell ss:Name="Print_Area"/></Cell>' + CRLF +;
                    '                <Cell ss:StyleID="s34"><Data ss:Type="String">Qtde</Data><NamedCell ss:Name="Print_Area"/></Cell>' + CRLF +;
                    '                <Cell ss:StyleID="s34"><Data ss:Type="String">Saldo</Data></Cell>' + CRLF +;
                    '                <Cell ss:StyleID="s34"><Data ss:Type="String">UDM</Data><NamedCell ss:Name="Print_Area"/></Cell>' + CRLF)

    for i := 1 to nLenFornec
        FWrite(nHandle, '                <Cell ss:StyleID="s35"><Data ss:Type="String">R$ Unit</Data><NamedCell ss:Name="Print_Area"/></Cell>' + CRLF +;
                        '                <Cell ss:StyleID="s36"><Data ss:Type="String">R$ Total</Data><NamedCell ss:Name="Print_Area"/></Cell>' + CRLF +;
                        '                <Cell ss:StyleID="s36"><Data ss:Type="String">Marca</Data><NamedCell ss:Name="Print_Area"/></Cell>' + CRLF) 
    next

    FWrite(nHandle, '                <Cell ss:StyleID="s35"><Data ss:Type="String">R$ Unit</Data><NamedCell ss:Name="Print_Area"/></Cell>' + CRLF +;
                    '                <Cell ss:StyleID="s36"><Data ss:Type="String">R$ Total</Data><NamedCell ss:Name="Print_Area"/></Cell>' + CRLF +;
                    '            </Row>' + CRLF)


//    <aCotacao> ::= <aCotacao> {, <aCotacao>}
//    <aCotacao> ::= '{' Produto, Unid Medida, Quantidade Solicitada, Saldo em Estoque,  '{' <aFornece> '}'  '}'
//    <aFornece> ::= <aFornece> {, <aFornece>}
//    <aFornece> ::= '{' Fornecedor, Num Proposta, CondPgto, Marca, PrcUnit, Total '}'

    nLenProdutos := Len(aCotacao)
    
    for i := 1 to nLenProdutos
        FWrite(nHandle, '            <Row ss:AutoFitHeight="0" ss:Height="33.75">' + CRLF +;
                        '                <Cell ss:StyleID="s37"><Data ss:Type="String">' + FrmtValorExcel(AllTrim(aCotacao[i][1]) + " - " + AllTrim(Posicione("SB1", 1, xFilial("SB1")+aCotacao[i][1], "B1_DESC"))) + '</Data><NamedCell ss:Name="Print_Area"/></Cell>' + CRLF +;
                        '                <Cell ss:StyleID="s38"><Data ss:Type="Number">' + FrmtValorExcel(aCotacao[i][3]) + '</Data><NamedCell ss:Name="Print_Area"/></Cell>' + CRLF +;
                        '                <Cell ss:StyleID="s38"><Data ss:Type="Number">' + FrmtValorExcel(aCotacao[i][4]) + '</Data><NamedCell ss:Name="Print_Area"/></Cell>' + CRLF +;
                        '                <Cell ss:StyleID="s38"><Data ss:Type="String">' + FrmtValorExcel(aCotacao[i][2]) + '</Data><NamedCell ss:Name="Print_Area"/></Cell>' + CRLF )

        cFormula := ""
        
        for j := 1 to nLenFornec
            If(aCotacao[i][5][j][5] == 0)
                FWrite(nHandle, '            <Cell ss:StyleID="s39"/>' + CRLF +;
                            '                <Cell ss:StyleID="s40" ss:Formula="=IF(RC[-1]=&quot;&quot;,&quot;&quot;,RC[-1]*RC2)"><Data ss:Type="Number"></Data><NamedCell ss:Name="Print_Area"/></Cell>' + CRLF +;
                            '                <Cell ss:StyleID="s40"><Data ss:Type="String">' + FrmtValorExcel(aCotacao[i][5][j][4]) + '</Data><NamedCell ss:Name="Print_Area"/></Cell>' + CRLF ) 
            Else
                
                FWrite(nHandle, '            <Cell ss:StyleID="s39"><Data ss:Type="Number">' + FrmtValorExcel(aCotacao[i][5][j][5])  + '</Data><NamedCell ss:Name="Print_Area"/></Cell>' + CRLF +;
                            '                <Cell ss:StyleID="s40" ss:Formula="=IF(RC[-1]=&quot;&quot;,&quot;&quot;,RC[-1]*RC2)"><Data ss:Type="Number"></Data><NamedCell ss:Name="Print_Area"/></Cell>' + CRLF +;
                            '                <Cell ss:StyleID="s40"><Data ss:Type="String">' + FrmtValorExcel(aCotacao[i][5][j][4]) + '</Data><NamedCell ss:Name="Print_Area"/></Cell>' + CRLF ) 
            //cFormula += Iif(Empty(cFormula), "", ",") + "IF(RC[-" + AllTrim(Str(j*3)) + "]=0,999999999,RC[-" + AllTrim(Str(j*3)) + "])"
            EndIf
        next
        /*
        FWrite(nHandle, '                <Cell ss:StyleID="s40" ss:Formula="=MIN(' + cFormula + ')"><Data ss:Type="Number"></Data><NamedCell ss:Name="Print_Area"/></Cell>' + CRLF +;
                        '                <Cell ss:StyleID="s40" ss:Formula="=MIN(' + cFormula + ')"><Data ss:Type="Number"></Data><NamedCell ss:Name="Print_Area"/></Cell>' + CRLF +;
                        '            </Row>' + CRLF ) 
        */                        
        //FWrite(nHandle, '                <Cell ss:StyleID="s40" ss:Formula="=MINIFS(RC[-'+CVALTOCHAR( nLenFornec * 3 )+']:R5C[-1],R5C[-'+CVALTOCHAR( nLenFornec * 3 )+']:R[-1]C[-1],&quot;R$ Unit&quot;,RC[-'+CVALTOCHAR( nLenFornec * 3 )+']:RC[-1],&quot;&gt;0&quot;)"><Data ss:Type="Number"></Data><NamedCell ss:Name="Print_Area"/></Cell>' + CRLF +;
        /*
        FWrite(nHandle, '                <Cell ss:StyleID="s40" ss:Formula="=MINIFS(RC[-'+CVALTOCHAR( nLenFornec * 3 )+']:RC[-1],R5C5:R5C[-1],&quot;R$ Unit&quot;,RC[-'+CVALTOCHAR( nLenFornec * 3 )+']:RC[-1],&quot;&gt;0&quot;)"><Data ss:Type="Number"></Data><NamedCell ss:Name="Print_Area"/></Cell>' + CRLF +;
                        '                <Cell ss:StyleID="s40" ss:Formula="=MINIFS(RC[-'+CVALTOCHAR( (nLenFornec * 3)+1 )+']:RC[-2],R5C5:R5C[-2],&quot;R$ Total&quot;,RC[-'+CVALTOCHAR( (nLenFornec * 3)+1 )+']:RC[-2],&quot;&gt;0&quot;)"><Data ss:Type="Number"></Data><NamedCell ss:Name="Print_Area"/></Cell>' + CRLF +;
                        '            </Row>' + CRLF ) 
                        */
        FWrite(nHandle, '                <Cell ss:StyleID="s40" ss:Formula="=MIN(RC[-'+CVALTOCHAR( nLenFornec * 3 )+']:RC[-1])"><Data ss:Type="Number"></Data><NamedCell ss:Name="Print_Area"/></Cell>' + CRLF +;
                        '                <Cell ss:StyleID="s40" ss:Formula="=MIN(RC[-'+CVALTOCHAR( (nLenFornec * 3)+4 )+'] * RC[-1])"><Data ss:Type="Number"></Data><NamedCell ss:Name="Print_Area"/></Cell>' + CRLF +;
                        '            </Row>' + CRLF ) 
    next


    FWrite(nHandle, '            <Row ss:AutoFitHeight="0">' + CRLF +;
                    '                <Cell ss:MergeAcross="3" ss:StyleID="m320402740"><Data ss:Type="String">TOTAL</Data></Cell>' + CRLF)
    for i := 1 to nLenFornec
        FWrite(nHandle, '                <Cell ss:MergeAcross="2" ss:StyleID="m2126159379956" ss:Formula="=SUM(R[-' + AllTrim(Str(nLenProdutos+1)) + ']C[1]:R[-1]C[1])"><Data ss:Type="Number"></Data></Cell>' + CRLF)
    next
    FWrite(nHandle, '                <Cell ss:MergeAcross="1" ss:StyleID="m2126159379956" ss:Formula="=SUM(R[-' + AllTrim(Str(nLenProdutos+1)) + ']C[1]:R[-1]C[1])"><Data ss:Type="Number"></Data></Cell>' + CRLF)
    FWrite(nHandle, '            </Row>' + CRLF)
    
    FWrite(nHandle, '            <Row ss:AutoFitHeight="0">' + CRLF +;
                    '                <Cell ss:MergeAcross="3" ss:StyleID="m320402740"><Data ss:Type="String">Condicao Pagamento</Data></Cell>' + CRLF)
    for i := 1 to nLenFornec
        FWrite(nHandle, '                <Cell ss:MergeAcross="2" ss:StyleID="m320402760"><Data ss:Type="String">' + FrmtValorExcel( aFornece[i][3] ) + '</Data></Cell>' + CRLF)
    next
    FWrite(nHandle, '            </Row>' + CRLF)
    FWrite(nHandle, '            <Row ss:AutoFitHeight="0">' + CRLF +;
                    '                <Cell ss:MergeAcross="3" ss:StyleID="m320402740"><Data ss:Type="String">Contato</Data></Cell>' + CRLF)
    for i := 1 to nLenFornec
        FWrite(nHandle, '                <Cell ss:MergeAcross="2" ss:StyleID="m320402760"><Data ss:Type="String">' + FrmtValorExcel(Posicione("SA2",1,xFilial("SA2")+aFornece[i][1],"A2_CONTATO") + "-" + Iif(!Empty(SA2->A2_DDD),"(" + AllTrim(SA2->A2_DDD) + ")", "") + AllTrim(SA2->A2_TEL)) + '</Data></Cell>' + CRLF)
    next
    FWrite(nHandle, '            </Row>' + CRLF)
    
    FWrite(nHandle, '        </Table>' + CRLF)
    FWrite(nHandle, '        <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF)
    FWrite(nHandle, '            <PageSetup>' + CRLF +;
                    '                <Layout x:Orientation="Landscape" x:CenterHorizontal="1"/>' + CRLF +;
                    '                <Header x:Margin="0.31496062992125984"/>' + CRLF +;
                    '                <Footer x:Margin="0.31496062992125984"/>' + CRLF +;
                    '                <PageMargins x:Bottom="0" x:Left="0" x:Right="0" x:Top="0.59055118110236227"/>' + CRLF +;
                    '            </PageSetup>' + CRLF)
    FWrite(nHandle, '            <Unsynced/>' + CRLF)
    FWrite(nHandle, '            <FitToPage/>' + CRLF)
    FWrite(nHandle, '            <Print>' + CRLF +;
                    '                <FitHeight>0</FitHeight>' + CRLF +;
                    '                <ValidPrinterInfo/>' + CRLF +;
                    '                <PaperSizeIndex>9</PaperSizeIndex>' + CRLF +;
                    '                <Scale>66</Scale>' + CRLF +;
                    '                <HorizontalResolution>600</HorizontalResolution>' + CRLF +;
                    '                <VerticalResolution>600</VerticalResolution>' + CRLF +;
                    '            </Print>' + CRLF)
    FWrite(nHandle, '            <Selected/>' + CRLF)
    FWrite(nHandle, '            <DoNotDisplayGridlines/>' + CRLF)
    FWrite(nHandle, '            <FreezePanes/>' + CRLF)
    FWrite(nHandle, '            <FrozenNoSplit/>' + CRLF)
    FWrite(nHandle, '            <SplitHorizontal>5</SplitHorizontal>' + CRLF)
    FWrite(nHandle, '            <TopRowBottomPane>5</TopRowBottomPane>' + CRLF)
    FWrite(nHandle, '            <SplitVertical>4</SplitVertical>' + CRLF)
    FWrite(nHandle, '            <LeftColumnRightPane>4</LeftColumnRightPane>' + CRLF)
    FWrite(nHandle, '            <ActivePane>0</ActivePane>' + CRLF)
    FWrite(nHandle, '            <Panes>' + CRLF +;
                    '                <Pane>' + CRLF +;
                    '                    <Number>3</Number>' + CRLF +;
                    '                </Pane>' + CRLF +;
                    '                <Pane>' + CRLF +;
                    '                    <Number>1</Number>' + CRLF +;
                    '                </Pane>' + CRLF +;
                    '                <Pane>' + CRLF +;
                    '                    <Number>2</Number>' + CRLF +;
                    '                    <ActiveRow>0</ActiveRow>' + CRLF +;
                    '                </Pane>' + CRLF +;
                    '                <Pane>' + CRLF +;
                    '                    <Number>0</Number>' + CRLF +;
                    '                    <ActiveCol>4</ActiveCol>' + CRLF +;
                    '                </Pane>' + CRLF +;
                    '            </Panes>' + CRLF)
    FWrite(nHandle, '            <ProtectObjects>False</ProtectObjects>' + CRLF)
    FWrite(nHandle, '            <ProtectScenarios>False</ProtectScenarios>' + CRLF)
    FWrite(nHandle, '        </WorksheetOptions>' + CRLF)

    // R6C5:R31C5,R6C8:R31C8,R6C11:R31C11,R6C14:R31C14
    nCol := 5
    cRange := ""
    for i := 1 to nLenFornec
        cRange += Iif(Empty(cRange), "", ",") + "R6C" + AllTrim(Str(nCol)) + ":R" + AllTrim(Str(5+nLenProdutos)) + "C" + AllTrim(Str(nCol))
        nCol += 3
    next
    // RC17
    cValue := "RC" + AllTrim(Str(nCol))

    FWrite(nHandle, '        <ConditionalFormatting xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF +;
                    '            <Range>' + cRange + '</Range>' + CRLF +;
                    '            <Condition>' + CRLF +;
                    '                <Qualifier>Equal</Qualifier>' + CRLF +;
                    '                <Value1>' + cValue + '</Value1>' + CRLF +;
                    "                <Format Style='color:white;font-weight:700;background:#00B050'/>" + CRLF +;
                    '            </Condition>' + CRLF)
    FWrite(nHandle, '        </ConditionalFormatting>' + CRLF)

    // R6C6:R31C6,R6C9:R31C9,R6C12:R31C12,R6C15:R31C15
    nCol := 6
    cRange := ""
    for i := 1 to nLenFornec
        cRange += Iif(Empty(cRange), "", ",") + "R6C" + AllTrim(Str(nCol)) + ":R" + AllTrim(Str(5+nLenProdutos)) + "C" + AllTrim(Str(nCol))
        nCol += 3
    next
    // RC18
    cValue := "RC" + AllTrim(Str(nCol))

    FWrite(nHandle, '        <ConditionalFormatting xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF +;
                    '            <Range>' + cRange + '</Range>' + CRLF +;
                    '            <Condition>' + CRLF +;
                    '                <Qualifier>Equal</Qualifier>' + CRLF +;
                    '                <Value1>' + cValue + '</Value1>' + CRLF +;
                    "                <Format Style='color:white;font-weight:700;background:#00B050'/>" + CRLF +;
                    '            </Condition>' + CRLF +;
                    '        </ConditionalFormatting>' + CRLF)
    FWrite(nHandle, '    </Worksheet>' + CRLF)

    FWrite(nHandle, '    <Worksheet ss:Name="Plan2">' + CRLF +;
                    '        <Table ss:ExpandedColumnCount="1" ss:ExpandedRowCount="1" x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="15">' + CRLF +;
                    '        </Table>' + CRLF +;
                    '        <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF +;
                    '            <PageSetup>' + CRLF +;
                    '                <Header x:Margin="0.3"/>' + CRLF +;
                    '                <Footer x:Margin="0.3"/>' + CRLF +;
                    '                <PageMargins x:Bottom="0.75" x:Left="0.7" x:Right="0.7" x:Top="0.75"/>' + CRLF +;
                    '            </PageSetup>' + CRLF +;
                    '            <Print>' + CRLF +;
                    '                <ValidPrinterInfo/>' + CRLF +;
                    '                <PaperSizeIndex>9</PaperSizeIndex>' + CRLF +;
                    '                <HorizontalResolution>600</HorizontalResolution>' + CRLF +;
                    '                <VerticalResolution>600</VerticalResolution>' + CRLF +;
                    '            </Print>' + CRLF +;
                    '            <ProtectObjects>False</ProtectObjects>' + CRLF +;
                    '            <ProtectScenarios>False</ProtectScenarios>' + CRLF +;
                    '        </WorksheetOptions>' + CRLF +;
                    '    </Worksheet>' + CRLF)

    FWrite(nHandle, '    <Worksheet ss:Name="Plan3">' + CRLF +;
                    '        <Table ss:ExpandedColumnCount="1" ss:ExpandedRowCount="1" x:FullColumns="1" x:FullRows="1" ss:DefaultRowHeight="15">' + CRLF +;
                    '        </Table>' + CRLF +;
                    '        <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">' + CRLF +;
                    '            <PageSetup>' + CRLF +;
                    '                <Header x:Margin="0.3"/>' + CRLF +;
                    '                <Footer x:Margin="0.3"/>' + CRLF +;
                    '                <PageMargins x:Bottom="0.75" x:Left="0.7" x:Right="0.7" x:Top="0.75"/>' + CRLF +;
                    '            </PageSetup>' + CRLF +;
                    '            <Print>' + CRLF +;
                    '                <ValidPrinterInfo/>' + CRLF +;
                    '                <PaperSizeIndex>9</PaperSizeIndex>' + CRLF +;
                    '                <HorizontalResolution>600</HorizontalResolution>' + CRLF +;
                    '                <VerticalResolution>600</VerticalResolution>' + CRLF +;
                    '            </Print>' + CRLF +;
                    '            <ProtectObjects>False</ProtectObjects>' + CRLF +;
                    '            <ProtectScenarios>False</ProtectScenarios>' + CRLF +;
                    '        </WorksheetOptions>' + CRLF +;
                    '    </Worksheet>' + CRLF)

    FWrite(nHandle, '</Workbook>' + CRLF)

    FClose(nHandle)
    
return cFileName

static function AdFornec(cFornece, aFornece, aCotacao)
local nPosForn := 0
local aModForn := {cFornece, "", "", "", 0, 0}
local i, nLen

AAdd(aFornece, aModForn)
nPosForn := Len(aFornece)

nLen := Len(aCotacao)
for i := 1 to nLen
    AAdd(aCotacao[i][5], aClone(aModForn))
next

return nPosForn

/*/{Protheus.doc} SaldoTot
/*/
static function SaldoTot(cProduto)
local aArea := GetArea()
local nSaldo := 0

    DbSelectArea("SB2")
    DbSetOrder(1) // B2_FILIAL + B2_COD + B2_LOCAL
    SB2->(DbSeek(xFilial("SB2")+cProduto))
    while !SB2->(Eof()) .and. SB2->B2_FILIAL == xFilial("SB2") .and. SB2->B2_COD == cProduto
		nSaldo += SaldoSB2()
		SB2->(DbSkip())
	end

if !Empty(aArea)
    RestArea(aArea)
endif
return nSaldo


/*/{Protheus.doc} FrmtValorExcel
/*/
static function FrmtValorExcel( xVar )
local cRet  := ""
local cType := ValType(xVar)

    if cType == "U"
        cRet := ""
    elseif cType == "C"
        cRet := Formata( xVar ) 
    elseif cType == "N"
        if xVar == 0
            cRet := ""
        else
            cRet := AllTrim( Str( xVar ) )
        endif
    elseif cType == "D"
        xVar := DToS( xVar )
        cRet := SubStr(xVar, 1, 4) + "-" + SubStr(xVar, 5, 2) + "-" + SubStr(xVar, 7, 2) + "T00:00:00.000"
    else
        cRet := Iif(xVar , "=VERDADEIRO" ,  "=FALSO") 
    endif

return cRet

/*/{Protheus.doc} TimeStamp
/*/
static function TimeStamp(dData, cTime)
return FWTimeStamp(3, Iif(Empty(dData), Date(), dData), Iif(Empty(cTime), Time(), cTime))

/*/{Protheus.doc} Formata
/*/
static function Formata( cVar )
local nLen := 0
local i    := 0
local aPad := { { 'ã', 'a' }, { 'á' , 'a' }, { 'â', 'a' }, { 'ä', 'a' }, ;
                { 'Ã', 'A' }, { 'Á' , 'A' }, { 'Â', 'A' }, { 'Ä', 'A' }, ;
                { 'é', 'e' }, { 'ê' , 'e' }, { 'ë', 'e' }, ;
                { 'É', 'E' }, { 'Ê' , 'E' }, { 'Ë', 'E' }, ;
                { 'í', 'i' }, { 'î' , 'i' }, { 'ï', 'i' }, ; 
                { 'õ', 'o' }, { 'ó' , 'o' }, { 'ô', 'o' }, { 'ö', 'o' },;
                { 'Õ', 'O' }, { 'Ó' , 'O' }, { 'Ô', 'O' }, { 'Ö', 'O' },;
                { 'ú', 'u' }, { 'û' , 'u' }, { 'ü', 'u' }, ;
                { 'Ú', 'U' }, { 'Û' , 'U' }, { 'Ü', 'U' }, ;
                { 'ç', 'c' }, ;
                { 'Ç', 'C' }, ;
                { '&', '' } }
                
    nLen := Len(aPad)
    for i := 1 to nLen
       cVar := StrTran(cVar, aPad[i][1], aPad[i][2])
    next
return AllTrim(cVar)
