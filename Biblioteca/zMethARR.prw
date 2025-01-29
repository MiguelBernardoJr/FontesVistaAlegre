#Include 'Protheus.ch'
#include 'totvs.ch'
#Include "FWMBROWSE.CH"
#Include "FWMVCDEF.CH"
#Include "FWADAPTEREAI.CH"
#INCLUDE "TOPCONN.CH"  

/* GRAVA ARQUIVO COM OS ATRIBUTOS DOS OBJETOS RECEBIDOS */
User Function zMethARR(oModel, oModelGrid)
Local nI 
Private cPath 	 	:= "C:\totvs_relatorios\"
Private cArquivo   	:= cPath + "Metodos" +; // __cUserID+"_"+;
								DtoS(dDataBase)+; 
								"_"+; 
								StrTran(SubS(Time(),1,5),":","")+;
								".txt"

//Exemplo de objeto
/* oMsDialog := MSDialog():New(180,180,550,700,'Exemplo MSDialog',,,,,CLR_BLACK,CLR_WHITE,,,.T.) */
 
//Parametro 1 - Objeto
//Parametro 2 - Se verdadeiro (.T.) retorna todos os parametros, inclusive os parâmetros herdados de outras classes, adiciona o nome da classe na 3ª coluna do array
aMetMod  := ClassMethArr(oModel     , .T.)
aMetGrid := ClassMethArr(oModelGrid , .T.)

cMethods := PadR("METHOD", 30) + "|OWNER" + CRLF
 
//Concateno todas as informações
For nI := 01 To Len(aMetMod)
    cMethods += PadR(AllTrim(aMetMod[nI, 01]), 30) + "|" + AllTrim(aMetMod[nI, 03]) + CRLF
Next nI
MemoWrite(StrTran(cArquivo,".txt","")+"_MODEL_.sql" , cMethods)
For nI := 01 To Len(aMetGrid)
    cMethods += PadR(AllTrim(aMetGrid[nI, 01]), 30) + "|" + AllTrim(aMetGrid[nI, 03]) + CRLF
Next nI
MemoWrite(StrTran(cArquivo,".txt","")+"_GRID_.sql" , cMethods)
 
Return .t.
