#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
/*  Igor Oliveira 
    03/2023
    ExecAuto - MATA150.PRW
    INCLUSÃO DE UM NOVO PARTICIPANTE
*/
User Function IncMata150(aSolicitac)
Local aCabec := {}
Local aItens := {}
PRIVATE lMsErroAuto := .F.

PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "COM"
//| Posiciona a cotação em que o novo participante será incluído. |//
dbSelectArea("SC8")
dbSetOrder(1)
dbSeek(xFilial("SC8")+"000035")

aadd(aCabec,{"C8_FORNECE" ,"000010"})
aadd(aCabec,{"C8_LOJA" ,"01"})
aadd(aCabec,{"C8_COND" ,"001"})
aadd(aCabec,{"C8_CONTATO" ,"AUTO"})
aadd(aCabec,{"C8_FILENT" ,"01"})
aadd(aCabec,{"C8_MOEDA" ,1})
aadd(aCabec,{"C8_EMISSAO" ,dDataBase})
aadd(aCabec,{"C8_TOTFRE" ,0})
aadd(aCabec,{"C8_VALDESC" ,0})
aadd(aCabec,{"C8_DESPESA" ,0})
aadd(aCabec,{"C8_SEGURO" ,0})
aadd(aCabec,{"C8_DESC1" ,0})
aadd(aCabec,{"C8_DESC2" ,0})
aadd(aCabec,{"C8_DESC3" ,0})

aadd(aItens,{{"C8_NUMPRO" ,"01" ,Nil},;
                    {"C8_PRODUTO" ," COM00000000000000000000000011" ,Nil},;
                    {"C8_ITEM" ,"0001",Nil},;
                    {"C8_UM" ,"UN",Nil},;
                    {"C8_QUANT" ,10 ,Nil},;
                    {"C8_PRECO" ,0 ,NIL},;
                    {"C8_TOTAL" ,0 ,NIL}})

MSExecAuto({|v,x,y| MATA150(v,x,y)},aCabec,aItens,2)

If !lMsErroAuto
        ConOut(" Novo participante incluído" )
Else
        MostraErro()
        ConOut("Erro na inclusão!")
EndIf

ConOut("Fim: " + Time())

RESET ENVIRONMENT

Return
