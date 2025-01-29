#include "protheus.ch"
#include "topconn.ch"    


//----------------------------------------------------------------------------------------------------------
//Proximo Numero Cad de Fornecedores
//----------------------------------------------------------------------------------------------------------
User Function ProxSA2()
	Local aArea	:= GetArea()
	Local cQuery
	Local cProx
	cQuery := "SELECT MAX(A2_COD) PROX FROM " + RetSqlName("SA2") + " WHERE	LEN(A2_COD)=6 AND SUBSTRING(A2_COD,1,1) <> '9' AND D_E_L_E_T_= ' ' "
	TcQuery cQuery New Alias "QSA2"
	dbSelectArea("QSA2")
	dbGotop()
	cProx := StrZero(Val(QSA2->PROX)+1,6)
	QSA2->(dbCloseArea())
	cProx := u_NumLivre("SA2",cProx)
	RestArea(aArea)
Return(cProx)

//----------------------------------------------------------------------------------------------------------
//Proximo Numero Cad de Clientes
//----------------------------------------------------------------------------------------------------------
User Function ProxSA1()
	Local aArea	:= GetArea()
	Local cQuery
	Local cProx
	cQuery := "SELECT MAX(A1_COD) PROX FROM " + RetSqlName("SA1") + " WHERE	LEN(A1_COD)=6 AND SUBSTRING(A1_COD,1,1) <> '9' AND D_E_L_E_T_= ' ' "
	TcQuery cQuery New Alias "QSA1"
	dbSelectArea("QSA1")
	dbGotop()
	cProx := StrZero(Val(QSA1->PROX)+1,6)
	QSA1->(dbCloseArea())
	cProx := u_NumLivre("SA1",cProx)
	RestArea(aArea)
Return(cProx)

//----------------------------------------------------------------------------------------------------------
//Proximo Numero Cad de Transportadoras
//----------------------------------------------------------------------------------------------------------
User Function ProxSA4()
	Local aArea	:= GetArea()
	Local cQuery
	Local cProx
	cQuery := "SELECT MAX(A4_COD) PROX FROM " + RetSqlName("SA4") + " WHERE A4_COD < '900000' AND D_E_L_E_T_<>'*' "
	TcQuery cQuery New Alias "QSA4"
	dbSelectArea("QSA4")
	dbGotop()
	cProx := StrZero(Val(QSA4->PROX)+1,6)
	QSA4->(dbCloseArea())
	cProx := u_NumLivre("SA4",cProx)
	RestArea(aArea)
Return(cProx)


User Function NumLivre(cIdentif,cProximo)
Local cMay:="", cProx:=""
	FreeUsedCode() 
	cMay  := Alltrim(cIdentif)+"_"
	cProx := Alltrim(cProximo)
	While !MayIUseCode(cMay+cProx)
		cProx := Soma1(cProx)
	EndDo
Return(cProx)



//---------------------------------------------------------------------------------------------------------
//Retorna a codigo do documento de entrada com 9 digitos
//usado no campo cnfiscal
//---------------------------------------------------------------------------------------------------------
User Function RETSF1DOC(cNum)
Local aArea			:= GetArea()
	CNFISCAL :=	PADL(alltrim(cNum),9,"0")
	Restarea(aArea)
Return .T.
             


//-----------------------------------------------------------------------------------------------
// Codigo Estruturado no cadastro de Produtos
//-----------------------------------------------------------------------------------------------
User Function ProxSB1(cGrupo)
Local aArea		:= GetArea()
Local cRetCod	:= ""
cSequencial		:= ""

If !Empty(cGrupo)	

	cQuery := " SELECT MAX(B1_COD) PROX FROM " + RetSqlName("SB1") 
	cQuery += " WHERE B1_FILIAL='"+FWxFilial('SB1')+"' "
	cQuery += "   AND B1_GRUPO = '"+cGrupo+"' "
	If cGrupo == 'BOV'
		cQuery += "   AND LEN(B1_COD) = 15 "
	EndIf
	cQuery += "   AND SUBSTRING(B1_COD,1," + AllTrim(Str(Len(AllTrim(cGrupo)))) + ")='"+cGrupo+"' "
	cQuery += "   AND D_E_L_E_T_<>'*' "
	
	//cQuery := "SELECT MAX(B1_COD) PROX FROM " + RetSqlName("SB1") + " WHERE B1_COD < '999999999999999' AND B1_GRUPO = '"+cGrupo+"' AND D_E_L_E_T_<>'*' "
	TcQuery cQuery New Alias "QSB1"
	dbSelectArea("QSB1")
	dbGotop()
	
		// Se não houver cadastro para o grupo
		If Empty(QSB1->PROX)	
			// Quando for diferente de LOTE e BOV cria sequencial 
			If cGrupo != 'LOTE' .And. cGrupo != 'BOV'
				cRetCod := cGrupo+"0001"
			// 	Quando nao houver cadastro para o grupo BOV, cria inicial com 15 digitos
			ElseIf (Empty(QSB1->PROX) .And. cGrupo == 'BOV')
				cRetCod := AllTrim(cGrupo) + StrZero(1, 15-Len(AllTrim(cGrupo)))
			EndIf
		ElseIf cGrupo == 'BOV'
			cRetCod := cGrupo + Soma1(AllTrim(SubS(QSB1->PROX,4)))
		ElseIf cGrupo != 'LOTE'
			cRetCod := Soma1(Alltrim(QSB1->PROX))
		Endif			
	dbSelectArea("SB1")
	
	QSB12->(dbCloseArea())
	QSB1->(dbCloseArea())
Endif
//Set Key VK_F4 to M->B1_COD := u_CodSb1()
RestArea(aArea)
Return(cRetCod)

/*
// INCLUIR ROTINA NO PEDIDO DE VENDA
User Function MA410MNU //MA410 foi exemplo, nao sei qual PE utilizar para incluir o botão na tela de pedido de venda)

   // 9 //Aadd(aRotina,{"Documento Saída"   ,"MATA460"             ,0,2,0,Nil})  
	//   { OemToAnsi(STR0095),"Ma410PvNfs"	,0,2,0 ,NIL},;		//"Prep.Doc.Saída"
//   	aRotina[9,2] := "MATA460"   
	Aadd(aRotina,{"Doc.Saída(NF)"   ,"MATA460"             ,0,2,0,Nil})  
	Aadd(aRotina,{"NF-e SEFAZ"      ,"SPEDNFE"             ,0,2,0,Nil})  

Return
*/


User function F373CONS()
return FI9->FI9_IDDARF                 



// Funcao para selecionar arquivos via Consulta Especifica 
User Function SelF3()
Local cFile,cTipo
Local cDirIni:=&(ReadVar())
Public __cGetArquivo         
If substr( cDirIni,1,1) = '\' 
                cDirIni:= '\\SERVIDOR'+cDirIni
Endif
                cTipo :="Todos Arquivos        | *.* | "
                cFile :=cGetFile(cTipo,"Selecionando arquivo",0,cDirIni,.T.,nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_NETWORKDRIVE),,.T.)          
                __cGetArquivo := cFile   
Return !Empty(AllTrim(cFile))        


User Function SelF3Dir()
Local cFile,cTipo
Local cDirIni:=&(ReadVar())
Public __cGetArquivo         
If substr( cDirIni,1,1) = '\' 
                cDirIni:= '\\SERVIDOR'+cDirIni
Endif
                cTipo :="Todos Arquivos        | *.* | "
                cFile :=cGetFile(cTipo,"Selecionando arquivo",0,cDirIni,.T.,nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_NETWORKDRIVE,GETF_RETDIRECTORY),,.T.)          
                __cGetArquivo := cFile   
Return !Empty(AllTrim(cFile))        
      
//apos impressao de cheque
User Function F460BXT()
	FINR490()
Return           


User Function FR150FLT()
Local cFil150 := ''  

//If SE2->(FieldPos("E2_XXDTDIG"))>0
//	cFil150 := ' !(SE2->E2_XXDTDIG >= mv_par37 .AND. SE2->E2_XXDTDIG <= mv_par38) '   
//EndIf

Return cFil150



// Funcao para tratar nome de cliente e fornecedor no pedido de vendas em campos virtuais e de enderecos
// usado para verificar nome de fornecedores no ambiente de entradas
User Function CpoES(cCampo1,cCampo2,cCodCliFor,cTipo,cAmbiente)
// cCampo1		- campo a ser retornando quando cliente
// cCampo2		- campo a ser retornado quando fornecedor
// cCodCliFor   - Codigo+Loja do Cliente/Fornecedor                                                    
// cTipo        - D(evolucao) / B(eneficiamento) / N(ormal) etc
// cAmbiente 	- E-ntrada ou S-aida  
// Exemplo chamando funcao de um inicializador padrao  -> U_CpoES("A1_NOME","A2_NOME",(SF2->F2_CLIENTE+SF2->F2_LOJA),SF2->F2_TIPO,"S")                                                      
// U_CpoES("A2_NOME","A1_NOME",(SF1->F1_FORNECE+SF1->F1_LOJA),SF1->F1_TIPO,"E")                                                     
Local cResult      := "" 
Local aArea        := GetArea()

	If cAmbiente<>"E"                
		If alltrim(cTipo)$"DB"  
        	cResult := Posicione("SA2",1,FWxfilial("SA2")+cCodCliFor, if(!empty(cCampo2),cCampo2,"A2_"+substr(cCampo1,4,len(cCampo1)-3) ) )
  		Else
			cResult := Posicione("SA1",1,FWxfilial("SA1")+cCodCliFor,cCampo1)
		Endif 
	Else
		If alltrim(cTipo)$"DB"  
        	cResult := Posicione("SA1",1,FWxfilial("SA1")+cCodCliFor,Iif(!empty(cCampo2),cCampo2,"A1_"+substr(cCampo1,4,len(cCampo1)-3) ) )
  		Else
			cResult := Posicione("SA2",1,FWxfilial("SA2")+cCodCliFor,cCampo1)
		Endif 
	Endif

RestArea(aArea)       
Return (cResult)     





//-----------------------------------------------------------------------------------------------
// Codigo para OP com base no Lote
//-----------------------------------------------------------------------------------------------
User Function ProxSC2(xLoteG)
Local aArea		:= GetArea()
Local cRetCod	:= ""
lOCAL cLoteG 	:= SUBSTR(Alltrim(xLoteG),1,3)

	If !Empty(cLoteG)
		cQuery := "SELECT MAX(C2_NUM) PROX FROM " + RetSqlName("SC2") + " WHERE SUBSTRING(C2_NUM,1,3) = '"+cLoteG+"' AND D_E_L_E_T_<>'*' AND C2_FILIAL  = '"+cFilAnt+ "'  "
	Else
		cQuery := "SELECT MAX(C2_NUM) PROX FROM " + RetSqlName("SC2") + " WHERE C2_NUM BETWEEN '000000' AND '999999' AND D_E_L_E_T_<>'*' AND C2_FILIAL  = '"+cFilAnt+ "'  "
	Endif
	TcQuery cQuery New Alias "QSC2"
	dbSelectArea("QSC2")
	dbGotop()
	
	If Empty(QSC2->PROX)
			If !Empty(cLoteG)
				cRetCod := cLoteG+"001"
			Else 
				cRetCod := "000001"
			Endif	
	Else
		cRetCod := Soma1(Alltrim(QSC2->PROX))
	Endif
	QSC2->(dbCloseArea())
//Endif
//Set Key VK_F4 to M->B1_COD := u_CodSb1()
RestArea(aArea)
Return(cRetCod)
                                        


///**************************************************************************
///FUNÇÃO DE IMPRESSÃO
///**************************************************************************
User Function BuscaSM0(strFilial)
Local strNome:="NÃO LOCALIZADO"
Local aAreaSM0:= SM0->(GetArea())

	DbSelectArea("SM0")
	DbGoTop()
	
	While !SM0->(EOF()) 
		If AllTrim(SM0->M0_CODFIL) == AllTrim(strFilial)
			strNome:=strFilial + " - " + AllTrim(SM0->M0_FILIAL) + " - " + AllTrim(SM0->M0_CIDENT)
			Exit
		EndIf
		SM0->(DbSkip())
	EndDo
	
	RestArea(aAreaSM0)

Return(strNome)


///**************************************************************************
///Posicione
///**************************************************************************
user function Posic(cAlias, nIndice, cChave, cCampo)
local aArea := GetArea()
local xRet := CriaTrab(cCampo, .f.)

DbSelectArea(cAlias)
DbSetOrder(nIndice)
if DbSeek(FWxFilial(cAlias)+cChave)
    xRet := &(cCampo)
endif

if !Empty(aArea)
    RestArea(aArea)
endif
return xRet
