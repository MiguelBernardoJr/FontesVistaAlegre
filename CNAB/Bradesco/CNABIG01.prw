User Function CNABIG01()
    Private cSeq := 0
    cSeq := cSeq + 1
return cSeq

User Function CNABIG02()
RETURN Iif(Len(AllTrim(SA1->A1_CGC))==11,SA1-A1_CGC + '000',SA1->A1_CGC)


User Function CNABIG03()
    Local cRet 

    cCGC := Iif(Len(AllTrim(SA1->A1_CGC))==11,SA1->A1_CGC+'000',SA1->A1_CGC)
    cSpace := Space(2)
    cBene := Space(43)
    cRet := cCGC + cSpace + cBene

RETURN cRet

/* SA1->SA1->A1_CGC

StrZero(Sub,TamSx3[SA1->A1_CGC][3])


484 529 898 81
04 561 264 0001 75 */
/* 
NUmero Documento 
SE1->E1_NUM+AllTrim(SE1->E1_SERIE)+SE1->E1_PARCELA 

Data do Vencimento 
GRAVADATA(SE1->E1_VENCTO,.F.)                               

Valor titulo
STRZERO(INT(ROUND(SE1->E1_VALOR*100,2)),13)                 

Data Emissao 
GRAVADATA(SE1->E1_EMISSAO,.F.)               

Valor Atraso DIa 
Strzero(Int(SE1->E1_VALJUR*100),13)             


IIF(SA1->A1_TIPO ="F",01,02)                  

SUBSTR(SA1->A1_CEP,1,5)+SUBSTR(SA1->A1_CEP,6,3)             
 */
