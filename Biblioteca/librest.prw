#include 'protheus.ch'
#include 'restful.ch'
#include 'parmtype.ch'

user function librest(); return '20170301'

WSRESTFUL workflow DESCRIPTION "WebService REST para workflow"
 
WSDATA count      AS INTEGER
WSDATA startIndex AS INTEGER
 
//WSMETHOD GET    DESCRIPTION "Exemplo de retorno de entidade(s)" WSSYNTAX "/workflow || /workflow/{id}"
WSMETHOD POST   DESCRIPTION "Post para os formularios de workflow."   WSSYNTAX "/workflow/{id}"
//WSMETHOD PUT    DESCRIPTION "Exemplo de alteração de entidade"  WSSYNTAX "/workflow/{id}"
//WSMETHOD DELETE DESCRIPTION "Exemplo de exclusão de entidade"   WSSYNTAX "/workflow/{id}"
 
END WSRESTFUL
 
// O metodo GET nao precisa necessariamente receber parametros de querystring, por exemplo:
// WSMETHOD GET WSSERVICE workflow 
/*
WSMETHOD GET WSRECEIVE startIndex, count WSSERVICE workflow
Local i
 
// define o tipo de retorno do método
::SetContentType("application/json")
 
// verifica se recebeu parametro pela URL
// exemplo: http://localhost:8080/workflow/1
If Len(::aURLParms) > 0
  
   // insira aqui o código para pesquisa do parametro recebido
   
 
   // exemplo de retorno de um objeto JSON
   ::SetResponse('{"id":' + ::aURLParms[1] + ', "name":"workflow"}')
 
Else
   // as propriedades da classe receberão os valores enviados por querystring
   // exemplo: http://localhost:8080/workflow?startIndex=1&count=10
   DEFAULT ::startIndex := 1, ::count := 5
  
   // exemplo de retorno de uma lista de objetos JSON
   ::SetResponse('[')
   For i := ::startIndex To ::count + 1
      If i > ::startIndex
         ::SetResponse(',')
      EndIf
      ::SetResponse('{"id":' + Str(i) + ', "name":"workflow"}')
   Next
   ::SetResponse(']')
EndIf
Return .T.
*/
 
// O metodo POST pode receber parametros por querystring, por exemplo:
// WSMETHOD POST WSRECEIVE startIndex, count WSSERVICE workflow
WSMETHOD POST WSSERVICE workflow
local lPost := .T.
local cBody
// Exemplo de retorno de erro
if Len(::aURLParms) == 0
 SetRestFault(400, "id parameter is mandatory")
 lPost := .F.
else
    cBody := ::GetContent()
    if GetMV("VA_LOGWF",.f.,.f.) // Tipo: L, Descrição: Parametro customizado: Usado pela rotina librest.prw. Identifica se sera gerado um arquivo de log p/ cada chamada ao metodo post do servico workflow.
        aVetDir := Directory("\workflow\*.","D")
        if aScan(aVetDir,{|aMat| aMat[1] == "LOG" .and. aMat[5] == "D"}) == 0
            MakeDir("\workflow\log")
        endif 
        ConOut("Call workflow:post.")
        ConOut("cBody: " + CRLF + cBody)
        ConOut("aURLParms:" + CRLF + U_AToS(::aURLParms))
        memowrite("\workflow\log\wfret" + FWTimeStamp(1) + ".txt", "Params:" + U_AToS(::aURLParms) + CRLF + CRLF + "Body:" + CRLF + cBody)
    endif
cStatus := ProcRet(::aURLParms, ::GetContent())
 
 
 // insira aqui o código para operação inserção
 // exemplo de retorno de um objeto JSON
 ::SetResponse('{"id":' + ::aURLParms[1] + ', "name":"workflow", "status":"' + cStatus + '}')
endIf
return lPost
 
// O metodo PUT pode receber parametros por querystring, por exemplo:
// WSMETHOD PUT WSRECEIVE startIndex, count WSSERVICE workflow
/*
WSMETHOD PUT WSSERVICE workflow
Local lPut := .T.
 
// Exemplo de retorno de erro
If Len(::aURLParms) == 0
   SetRestFault(400, "id parameter is mandatory")
   lPut := .F.
Else
   // recupera o body da requisição
   cBody := ::GetContent()
   cBody := ::GetContent()
   memowrite("\http\cBody.txt", cBody)
   memowrite("\http\aURLParms.txt", U_AToS(::aURLParms[1]))

   // insira aqui o código para operação de atualização
   // exemplo de retorno de um objeto JSON
   ::SetResponse('{"id":' + ::aURLParms[1] + ', "name":"workflow"}')
EndIf
Return lPut
*/

// O metodo DELETE pode receber parametros por querystring, por exemplo:
// WSMETHOD DELETE WSRECEIVE startIndex, count WSSERVICE workflow
/*
WSMETHOD DELETE WSSERVICE workflow
Local lDelete := .T.
 
// Exemplo de retorno de erro
If Len(::aURLParms) == 0
   SetRestFault(400, "id parameter is mandatory")
   lDelete := .F.
 
Else
   // insira aqui o código para operação exclusão
   // exemplo de retorno de um objeto JSON
   :SetResponse('{"id":' + ::aURLParms[1] + ', "name":"workflow"}')
EndIf
Return lDelete
*/

user function TstProcRet()
    u_RunFunc("u_runProcRet()")
return nil

user function runProcRet()
/*/
    memowrite("\http\cBody.txt", cBody)
    memowrite("\http\aURLParms.txt", U_AToS(::aURLParms))
/*/
    ProcRet(&("{ " + '"' + "id='MATA097_01006697'" + '"' + " }"), "aprovacao=02&obs=observacao+006697") 
return nil

static function ProcRet(aParam, cBody)
local cStatus := "Processo atualizado com sucesso!"
local i,j, nLen
local aBody := {}
local cRotina := "" 
local cChave := ""
local cParam := "" 

private id := nil

if !Empty(cBody) .and. !Empty(aParam)
    
    cParam := StrTran(aParam[1], "=", ":=")
    &(cParam) 

    cRotina := SubStr(id, 1, At('_', id)-1)
    cChave := StrTran(SubStr(id, At('_', id)+1), "_", "")
    
    aBody := StrToKArr(StrTran(cBody, "+", " "), "&")
    nLen := Len(aBody)
    for i := 1 to nLen
        aBody[i] := StrToKArr(aBody[i]+" ", "=")
        nLen := Len(aBody[i])
        for j := 1 to nLen
            aBody[i][j] := Html2Ascii(aBody[i][j])
        next
    next
else
    cStatus := "Erro durante retorno. Conteúdo do formulário vazio. Por favor entre em contato conosco."
endif

if cRotina == "MATA130"
    cStatus := u_mt130wfr(aBody, cChave)
elseif cRotina == "MATA097"
   cStatus := u_mt097wfr(aBody, cChave)
else
    cStatus := "Erro durante retorno. Não foi identificada rotina para tratamento do retorno. Por favor, entre em contato conosco."
endif

return cStatus

static function Html2Ascii(cString)
local nLen
local i
local cChar
local cHex
local nCount 
local lPercent := .f.
local cNewString := ""

cString := AllTrim(cString)

nLen := Len(cString)
for i := 1 to nLen
    if (cChar := SubStr(cString, i, 1)) == "%"
        nCount := 0
        lPercent := .t.
        cHex := ""
    elseif lPercent
        cHex += cChar
        if (++nCount) == 2
            cNewString += Chr(CTON(cHex,16))
            lPercent := .f.
        endif
    else
        cNewString += cChar
    endif
next

return cNewString



    //DEC, HEX,  ASCII, ANSI, 8859, UTF-8, Descrição
    //{032, "%20", " ", " ", " ", " ", "space"},
    //{033, "%21", "!", "!", "!", "!", "exclamation mark"},
    //{034, "%22", '"', '"', '"", '"", 'quotation mark"},
    //{035, "%23", "#", "#", "#", "#", "number sign"},
    //{036, "%24", "$", "$", "$", "$", "dollar sign"},
    //{037, "%25", "%", "%", "%", "%", "percent sign"},
    //{038, "%26", "&", "&", "&", "&", "ampersand"},
    //{039, "%27", "'", "'", "'", "'", "apostrophe"},
    //{040, "%28", "(", "(", "(", "(", "left parenthesis"},
    //{041, "%29", ")", ")", ")", ")", "right parenthesis"},
    //{042, "%2A", "*", "*", "*", "*", "asterisk"},
    //{043, "%2B", "+", "+", "+", "+", "plus sign"},
    //{044, "%2C", ",", ",", ",", ",", "comma"},
    //{045, "%2D", "-", "-", "-", "-", "hyphen-minus"},
    //{046, "%2E", ".", ".", ".", ".", "full stop"},
    //{047, "%2F", "/", "/", "/", "/", "solidus"},
    //{048, "%30", "0", "0", "0", "0", "digit zero"},
    //{049, "%31", "1", "1", "1", "1", "digit one"},
    //{050, "%32", "2", "2", "2", "2", "digit two"},
    //{051, "%33", "3", "3", "3", "3", "digit three"},
    //{052, "%34", "4", "4", "4", "4", "digit four"},
    //{053, "%35", "5", "5", "5", "5", "digit five"},
    //{054, "%36", "6", "6", "6", "6", "digit six"},
    //{055, "%37", "7", "7", "7", "7", "digit seven"},
    //{056, "%38", "8", "8", "8", "8", "digit eight"},
    //{057, "%39", "9", "9", "9", "9", "digit nine"},
    //{058, "%3A", ":", ":", ":", ":", "colon"},
    //{059, "%3B", ";", ";", ";", ";", "semicolon"},
    //{060, "%3C", "<", "<", "<", "<", "less-than sign"},
    //{061, "%3D", "=", "=", "=", "=", "equals sign"},
    //{062, "%3E", ">", ">", ">", ">", "greater-than sign"},
    //{063, "%3F", "?", "?", "?", "?", "question mark"},
    //{064, "%40", "@", "@", "@", "@", "commercial at"},
    //{065, "%41", "A", "A", "A", "A", "Latin capital letter A"},
    //{066, "%42", "B", "B", "B", "B", "Latin capital letter B"},
    //{067, "%43", "C", "C", "C", "C", "Latin capital letter C"},
    //{068, "%44", "D", "D", "D", "D", "Latin capital letter D"},
    //{069, "%45", "E", "E", "E", "E", "Latin capital letter E"},
    //{070, "%46", "F", "F", "F", "F", "Latin capital letter F"},
    //{071, "%47", "G", "G", "G", "G", "Latin capital letter G"},
    //{072, "%48", "H", "H", "H", "H", "Latin capital letter H"},
    //{073, "%49", "I", "I", "I", "I", "Latin capital letter I"},
    //{074, "%4A", "J", "J", "J", "J", "Latin capital letter J"},
    //{075, "%4B", "K", "K", "K", "K", "Latin capital letter K"},
    //{076, "%4C", "L", "L", "L", "L", "Latin capital letter L"},
    //{077, "%4D", "M", "M", "M", "M", "Latin capital letter M"},
    //{078, "%4E", "N", "N", "N", "N", "Latin capital letter N"},
    //{079, "%4F", "O", "O", "O", "O", "Latin capital letter O"},
    //{080, "%50", "P", "P", "P", "P", "Latin capital letter P"},
    //{081, "%51", "Q", "Q", "Q", "Q", "Latin capital letter Q"},
    //{082, "%52", "R", "R", "R", "R", "Latin capital letter R"},
    //{083, "%53", "S", "S", "S", "S", "Latin capital letter S"},
    //{084, "%54", "T", "T", "T", "T", "Latin capital letter T"},
    //{085, "%55", "U", "U", "U", "U", "Latin capital letter U"},
    //{086, "%56", "V", "V", "V", "V", "Latin capital letter V"},
    //{087, "%57", "W", "W", "W", "W", "Latin capital letter W"},
    //{088, "%58", "X", "X", "X", "X", "Latin capital letter X"},
    //{089, "%59", "Y", "Y", "Y", "Y", "Latin capital letter Y"},
    //{090, "%5A", "Z", "Z", "Z", "Z", "Latin capital letter Z"},
    //{091, "%5B", "[", "[", "[", "[", "left square bracket"},
    //{092, "%5C", "\", "\", "\", "\", "reverse solidus"},
    //{093, "%5D", "]", "]", "]", "]", "right square bracket"},
    //{094, "%5E", "^", "^", "^", "^", "circumflex accent"},
    //{095, "%5F", "_", "_", "_", "_", "low line"},
    //{096, "%60", "`", "`", "`", "`", "grave accent"},
    //{097, "%61", "a", "a", "a", "a", "Latin small letter a"},
    //{098, "%62", "b", "b", "b", "b", "Latin small letter b"},
    //{099, "%63", "c", "c", "c", "c", "Latin small letter c"},
    //{100, "%64", "d", "d", "d", "d", "Latin small letter d"},
    //{101, "%65", "e", "e", "e", "e", "Latin small letter e"},
    //{102, "%66", "f", "f", "f", "f", "Latin small letter f"},
    //{103, "%67", "g", "g", "g", "g", "Latin small letter g"},
    //{104, "%68", "h", "h", "h", "h", "Latin small letter h"},
    //{105, "%69", "i", "i", "i", "i", "Latin small letter i"},
    //{106, "%6A", "j", "j", "j", "j", "Latin small letter j"},
    //{107, "%6B", "k", "k", "k", "k", "Latin small letter k"},
    //{108, "%6C", "l", "l", "l", "l", "Latin small letter l"},
    //{109, "%6D", "m", "m", "m", "m", "Latin small letter m"},
    //{110, "%6E", "n", "n", "n", "n", "Latin small letter n"},
    //{111, "%6F", "o", "o", "o", "o", "Latin small letter o"},
    //{112, "%70", "p", "p", "p", "p", "Latin small letter p"},
    //{113, "%71", "q", "q", "q", "q", "Latin small letter q"},
    //{114, "%72", "r", "r", "r", "r", "Latin small letter r"},
    //{115, "%73", "s", "s", "s", "s", "Latin small letter s"},
    //{116, "%74", "t", "t", "t", "t", "Latin small letter t"},
    //{117, "%75", "u", "u", "u", "u", "Latin small letter u"},
    //{118, "%76", "v", "v", "v", "v", "Latin small letter v"},
    //{119, "%77", "w", "w", "w", "w", "Latin small letter w"},
    //{120, "%78", "x", "x", "x", "x", "Latin small letter x"},
    //{121, "%79", "y", "y", "y", "y", "Latin small letter y"},
    //{122, "%7A", "z", "z", "z", "z", "Latin small letter z"},
    //{123, "%7B", "{", "{", "{", "{", "left curly bracket"},
    //{124, "%7C", "|", "|", "|", "|", "vertical line"},
    //{125, "%7D", "}", "}", "}", "}", "right curly bracket"},
    //{126, "%7E", "~", "~", "~", "~", "tilde"},
    //{127, "%7F", "",  "",  "",  "",  "Delete"},
    //{128, "%80", "",  "€", "",  "",  "euro sign"},
    //{129, "%81", "",  "",  "",  "",  "NOT USED"},
    //{130, "%82", "",  "‚", "",  "",  "single low-9 quotation mark"},
    //{131, "%83", "",  "ƒ", "",  "",  "Latin small letter f with hook"},
    //{132, "%84", "",  "„", "",  "",  "double low-9 quotation mark"},
    //{133, "%85", "",  "…", "",  "",  "horizontal ellipsis"},
    //{134, "%86", "",  "†", "",  "",  "dagger"},
    //{135, "%87", "",  "‡", "",  "",  "double dagger"},
    //{136, "%88", "",  "ˆ", "",  "",  "modifier letter circumflex accent"},
    //{137, "%89", "",  "‰", "",  "",  "per mille sign"},
    //{138, "%8A", "",  "Š", "",  "",  "Latin capital letter S with caron"},
    //{139, "%8B", "",  "‹", "",  "",  "single left-pointing angle quotation mark"},
    //{140, "%8C", "",  "Œ", "",  "",  "Latin capital ligature OE"},
    //{141, "%8D", "",  "",  "",  "",  "NOT USED"},
    //{142, "%8E", "",  "Ž", "",  "",  "Latin capital letter Z with caron"},
    //{143, "%8F", "",  "",  "",  "",  "NOT USED"},
    //{144, "%90", "",  "",  "",  "",  "NOT USED"},
    //{145, "%91", "",  "‘", "",  "",  "left single quotation mark"},
    //{146, "%92", "",  "’", "",  "",  "right single quotation mark"},
    //{147, "%93", "",  "“", "",  "",  "left double quotation mark"},
    //{148, "%94", "",  "”", "",  "",  "right double quotation mark"},
    //{149, "%95", "",  "•", "",  "",  "bullet"},
    //{150, "%96", "",  "–", "",  "",  "en dash"},
    //{151, "%97", "",  "—", "",  "",  "em dash"},
    //{152, "%98", "",  "",  "",  "",  "small tilde"},
    //{153, "%99", "",  "™", "",  "",  "trade mark sign"},
    //{154, "%9A", "",  "š", "",  "",  "Latin small letter s with caron"},
    //{155, "%9B", "",  "›", "",  "",  "single right-pointing angle quotation mark"},
    //{156, "%9C", "",  "œ", "",  "",  "Latin small ligature oe"},
    //{157, "%9D", "",  "" , "",  "",  "NOT USED"},
    //{158, "%9E", "",  "ž", "",  "",  "Latin small letter z with caron"},
    //{159, "%9F", "",  "Ÿ", "",  "",  "Latin capital letter Y with diaeresis"},
    //{160, "%A0", "",  " ", "",  "",  "no-break space"},
    //{161, "%A1", "",  "¡", "¡", "¡", "inverted exclamation mark"},
    //{162, "%A2", "",  "¢", "¢", "¢", "cent sign"},
    //{163, "%A3", "",  "£", "£", "£", "pound sign"},
    //{164, "%A4", "",  "¤", "¤", "¤", "currency sign"},
    //{165, "%A5", "",  "¥", "¥", "¥", "yen sign"},
    //{166, "%A6", "",  "¦", "¦", "¦", "broken bar"},
    //{167, "%A7", "",  "§", "§", "§", "section sign"},
    //{168, "%A8", "",  "¨", "¨", "¨", "diaeresis"},
    //{169, "%A9", "",  "©", "©", "©", "copyright sign"},
    //{170, "%AA", "",  "ª", "ª", "ª", "feminine ordinal indicator"},
    //{171, "%AB", "",  "«", "«", "«", "left-pointing double angle quotation mark"},
    //{172, "%AC", "",  "¬", "¬", "¬", "not sign"},
    //{173, "%AD", "",  "",  "",  "",  "soft hyphen"},
    //{174, "%AE", "",  "®", "®", "®", "registered sign"},
    //{175, "%AF", "",  "¯", "¯", "¯", "macron"},
    //{176, "%A0", "",  "°", "°", "°", "degree sign"},
    //{177, "%B1", "",  "±", "±", "±", "plus-minus sign"},
    //{178, "%B2", "",  "²", "²", "²", "superscript two"},
    //{179, "%B3", "",  "³", "³", "³", "superscript three"},
    //{180, "%B4", "",  "´", "´", "´", "acute accent"},
    //{181, "%B5", "",  "µ", "µ", "µ", "micro sign"},
    //{182, "%B6", "",  "¶", "¶", "¶", "pilcrow sign"},
    //{183, "%B7", "",  "·", "·", "·", "middle dot"},
    //{184, "%B8", "",  "¸", "¸", "¸", "cedilla"},
    //{185, "%B9", "",  "¹", "¹", "¹", "superscript one"},
    //{186, "%BA", "",  "º", "º", "º", "masculine ordinal indicator"},
    //{187, "%BB", "",  "»", "»", "»", "right-pointing double angle quotation mark"},
    //{188, "%BC", "",  "¼", "¼", "¼", "vulgar fraction one quarter"},
    //{189, "%BD", "",  "½", "½", "½", "vulgar fraction one half"},
    //{190, "%BE", "",  "¾", "¾", "¾", "vulgar fraction three quarters"},
    //{191, "%BF", "",  "¿", "¿", "¿", "inverted question mark"},
    //{192, "%C0", "",  "À", "À", "À", "Latin capital letter A with grave"},
    //{193, "%C1", "",  "Á", "Á", "Á", "Latin capital letter A with acute"},
    //{194, "%C2", "",  "Â", "Â", "Â", "Latin capital letter A with circumflex"},
    //{195, "%C3", "",  "Ã", "Ã", "Ã", "Latin capital letter A with tilde"},
    //{196, "%C4", "",  "Ä", "Ä", "Ä", "Latin capital letter A with diaeresis"},
    //{197, "%C5", "",  "Å", "Å", "Å", "Latin capital letter A with ring above"},
    //{198, "%C6", "",  "Æ", "Æ", "Æ", "Latin capital letter AE"},
    //{199, "%C7", "",  "Ç", "Ç", "Ç", "Latin capital letter C with cedilla"},
    //{200, "%C8", "",  "È", "È", "È", "Latin capital letter E with grave"},
    //{201, "%C9", "",  "É", "É", "É", "Latin capital letter E with acute"},
    //{202, "%CA", "",  "Ê", "Ê", "Ê", "Latin capital letter E with circumflex"},
    //{203, "%CB", "",  "Ë", "Ë", "Ë", "Latin capital letter E with diaeresis"},
    //{204, "%CC", "",  "Ì", "Ì", "Ì", "Latin capital letter I with grave"},
    //{205, "%CD", "",  "Í", "Í", "Í", "Latin capital letter I with acute"},
    //{206, "%CE", "",  "Î", "Î", "Î", "Latin capital letter I with circumflex"},
    //{207, "%CF", "",  "Ï", "Ï", "Ï", "Latin capital letter I with diaeresis"},
    //{208, "%D0", "",  "Ð", "Ð", "Ð", "Latin capital letter Eth"},
    //{209, "%D1", "",  "Ñ", "Ñ", "Ñ", "Latin capital letter N with tilde"},
    //{210, "%D2", "",  "Ò", "Ò", "Ò", "Latin capital letter O with grave"},
    //{211, "%D3", "",  "Ó", "Ó", "Ó", "Latin capital letter O with acute"},
    //{212, "%D4", "",  "Ô", "Ô", "Ô", "Latin capital letter O with circumflex"},
    //{213, "%D5", "",  "Õ", "Õ", "Õ", "Latin capital letter O with tilde"},
    //{214, "%D6", "",  "Ö", "Ö", "Ö", "Latin capital letter O with diaeresis"},
    //{215, "%D7", "",  "×", "×", "×", "multiplication sign"},
    //{216, "%D8", "",  "Ø", "Ø", "Ø", "Latin capital letter O with stroke"},
    //{217, "%D9", "",  "Ù", "Ù", "Ù", "Latin capital letter U with grave"},
    //{218, "%DA", "",  "Ú", "Ú", "Ú", "Latin capital letter U with acute"},
    //{219, "%DB", "",  "Û", "Û", "Û", "Latin capital letter U with circumflex"},
    //{220, "%DC", "",  "Ü", "Ü", "Ü", "Latin capital letter U with diaeresis"},
    //{221, "%DD", "",  "Ý", "Ý", "Ý", "Latin capital letter Y with acute"},
    //{222, "%DE", "",  "Þ", "Þ", "Þ", "Latin capital letter Thorn"},
    //{223, "%DF", "",  "ß", "ß", "ß", "Latin small letter sharp s"},
    //{224, "%E0", "",  "à", "à", "à", "Latin small letter a with grave"},
    //{225, "%E1", "",  "á", "á", "á", "Latin small letter a with acute"},
    //{226, "%E2", "",  "â", "â", "â", "Latin small letter a with circumflex"},
    //{227, "%E3", "",  "ã", "ã", "ã", "Latin small letter a with tilde"},
    //{228, "%E4", "",  "ä", "ä", "ä", "Latin small letter a with diaeresis"},
    //{229, "%E5", "",  "å", "å", "å", "Latin small letter a with ring above"},
    //{230, "%E6", "",  "æ", "æ", "æ", "Latin small letter ae"},
    //{231, "%E7", "",  "ç", "ç", "ç", "Latin small letter c with cedilla"},
    //{232, "%E8", "",  "è", "è", "è", "Latin small letter e with grave"},
    //{233, "%E9", "",  "é", "é", "é", "Latin small letter e with acute"},
    //{234, "%EA", "",  "ê", "ê", "ê", "Latin small letter e with circumflex"},
    //{235, "%EB", "",  "ë", "ë", "ë", "Latin small letter e with diaeresis"},
    //{236, "%EC", "",  "ì", "ì", "ì", "Latin small letter i with grave"},
    //{237, "%ED", "",  "í", "í", "í", "Latin small letter i with acute"},
    //{238, "%EE", "",  "î", "î", "î", "Latin small letter i with circumflex"},
    //{239, "%EF", "",  "ï", "ï", "ï", "Latin small letter i with diaeresis"},
    //{240, "%F0", "",  "ð", "ð", "ð", "Latin small letter eth"},
    //{241, "%F1", "",  "ñ", "ñ", "ñ", "Latin small letter n with tilde"},
    //{242, "%F2", "",  "ò", "ò", "ò", "Latin small letter o with grave"},
    //{243, "%F3", "",  "ó", "ó", "ó", "Latin small letter o with acute"},
    //{244, "%F4", "",  "ô", "ô", "ô", "Latin small letter o with circumflex"},
    //{245, "%F5", "",  "õ", "õ", "õ", "Latin small letter o with tilde"},
    //{246, "%F6", "",  "ö", "ö", "ö", "Latin small letter o with diaeresis"},
    //{247, "%F7", "",  "÷", "÷", "÷", "division sign"},
    //{248, "%F8", "",  "ø", "ø", "ø", "Latin small letter o with stroke"},
    //{249, "%F9", "",  "ù", "ù", "ù", "Latin small letter u with grave"},
    //{250, "%FA", "",  "ú", "ú", "ú", "Latin small letter u with acute"},
    //{251, "%FB", "",  "û", "û", "û", "Latin small letter with circumflex"},
    //{252, "%FC", "",  "ü", "ü", "ü", "Latin small letter u with diaeresis"},
    //{253, "%FD", "",  "ý", "ý", "ý", "Latin small letter y with acute"},
    //{254, "%FE", "",  "þ", "þ", "þ", "Latin small letter thorn"},
    //{255, "%FF", "",  "ÿ", "ÿ", "ÿ", "Latin small letter y with diaeresis"}
