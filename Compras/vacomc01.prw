#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

User Function VACOMC01()

Private cPerg := "VACOMC01"
Private aRotina 
Private cCadastro 
Private cMarca    := Getmark()       

ValidPerg()

If !Pergunte(cPerg,.T.)
	return
Endif	

aCampos 	:= {}
nXML 		:= 0
//cCaminho 	:= "\XMLNFE\*.*"
//cDiretor  := "\XMLNFE\"

cCaminho 	:= alltrim(MV_PAR01) + "*.*"
cDiretor    := alltrim(MV_PAR01)
nAcao       := MV_PAR02
//nPC         := MV_PAR03


AADD(aCampos,{"OK",         "C",002						,0,})
AADD(aCampos,{"TIPO",       "C",010						,0,})
AADD(aCampos,{"FILIAL",     "C",TAMSX3('A2_NOME')[1]	,0,})  // NOME DA FILIAL
AADD(aCampos,{"CODIGO",     "C",TAMSX3('A2_COD')[1]		,0,})
AADD(aCampos,{"LOJA",       "C",TAMSX3('A2_LOJA')[1]	,0,})
AADD(aCampos,{"RAZAO",      "C",TAMSX3('A2_NOME')[1]	,0,})
AADD(aCampos,{"TIPOOP",		"C",010						,0,})
AADD(aCampos,{"DOCUMENTO",  "C",TAMSX3('F1_DOC')[1]		,0,})
AADD(aCampos,{"SERIE",      "C",TAMSX3('F1_SERIE')[1]	,0,})
AADD(aCampos,{"EMISSAO",    "C",TAMSX3('F1_EMISSAO')[1]+4 ,0,})
AADD(aCampos,{"CHAVE",      "C",044						,0,})
AADD(aCampos,{"XML",        "C",100						,0,})

cArq := CriaTrab(aCampos)

If Select("TMP") > 0
	TMP->(dbCloseArea())
Endif

DbUseArea( .T.,, cArq, "TMP", .T., .F. )

IndRegua("TMP",cArq,"CODIGO+LOJA",,,"Criando Controles") 

fCarrega()

cCadastro :="Selecionar XML"
aCpos   := {}
 
AADD(aCpos,{"OK"        ,," "                   })
AADD(aCpos,{"TIPO"      ,,"Tipo"                })
AADD(aCpos,{"FILIAL"    ,,"Filial"              })
AADD(aCpos,{"CODIGO"    ,,"Codigo"              })
AADD(aCpos,{"LOJA"      ,,"Loja"                })
AADD(aCpos,{"RAZAO"     ,,"Razão Social"        })
AADD(aCpos,{"TIPOOP" 	,,"Tipo NF"         	})
AADD(aCpos,{"DOCUMENTO" ,,"Documento"           })
AADD(aCpos,{"SERIE"     ,,"Serie"               })
AADD(aCpos,{"EMISSAO"   ,,"Emissao"             })
AADD(aCpos,{"CHAVE"     ,,"Chave"               })
AADD(aCpos,{"XML"       ,,"XML"                 })

cMarca    := Getmark()       

aRotina := {{"Marca"   ,"fMarcaT(1)",   0 , 4},;
            {"Desmarca","fMarcaT(2)",   0 , 4}}
                                  
If nXML > 0

	dbSelectArea("TMP")
	dbGoTop()
	
//	MarkBrow("TMP", "OK", , aCpos, , cMarca,)       
//	MarkBrow( 'TRB', 'A1_OK',,_afields,, cMark,'u_MarkAll()',,,,'u_Mark()',{|| u_MarkAll()},,,,,,,.F.) 

	MarkBrow( 'TMP', 'OK',, aCpos,, cMarca,,,,,,,,,,,,,.F.) 

	
Else

	MsgAlert("Nenhum XML encontrado para Importação.","Atencao!")

Endif	
	
TMP->(dbCloseArea())

ferase(cArq)
	
Return


Static Function fCarrega
Local cMsg01	:= "" // arquivo nao pode ser aberto
Local cMsg02	:= "" // erro no layout
Local cMsg03	:= "" // cnpj nao cadastrado
Local lGeraXml	:= .F.

//		MsgAlert("O(s) arquivo(s) abaixo nao pode(m) ser aberto(s)! Verifique os parametros ou Layout do Arquivo!!!. <br>"+cMsg01,"Atenção")

aFiles := {} // [ADIR(cCaminho)]
ADIR(cCaminho, aFiles)      

dbSelectArea("SF1")
dbSetOrder(1)

For nI:=1 to len(aFiles)

	cFile := cDiretor + aFiles[nI] 	
	nHdl  := fOpen(cFile,0)
		
	If nHdl == -1
		If !Empty(cFile) 
			//MsgAlert("O arquivo de nome "+cFile+" nao pode ser aberto! Verifique os parametros ou layout do arquivo!.","Atencao!")
			cMsg01 += 	"O arquivo de nome "+cFile+" nao pode ser aberto;<br>"
		Endif
	Else
		
		nTamFile := fSeek(nHdl,0,2)
		fSeek(nHdl,0,0)
		cBuffer  := Space(nTamFile)                
		nBtLidos := fRead(nHdl,@cBuffer,nTamFile)  
		fClose(nHdl)
		
		cAviso := ""
		cErro  := ""
		oNfe := XmlParser(cBuffer,"_",@cAviso,@cErro)
		
		Private oNF
		Private lObjNfe := .F.		                         
		
		If Type("oNFe:_NfeProc") <> "U"
			oNF := oNFe:_NFeProc:_NFe
			lObjNfe := .T.
		Else
			If Type("oNFe:_NFe") <> "U"
				oNF := oNFe:_NFe
				lObjNfe := .T.
			Else
//				MsgAlert("O arquivo de nome "+cFile+" nao pode ser aberto! Verifique o Layout.","Atencao!")
				cMsg02 += 	"O arquivo de nome "+cFile+" nao pode ser aberto(Verifique Layout);<br>"
		    Endif
		Endif
		
		If 	lObjNfe // testo se realmente leu o objeto xml

			Private oEmitente  := oNF:_InfNfe:_Emit
			Private oIdent     := oNF:_InfNfe:_IDE
			Private oDestino   := oNF:_InfNfe:_Dest
			Private oDestin2   := oNF:_InfNfe:_Dest:_enderDest
			Private oTotal     := oNF:_InfNfe:_Total
			Private oTransp    := oNF:_InfNfe:_Transp
			Private oDet       := oNF:_InfNfe:_Det 
			Private cCgcDest   := Space(14)      
			Private cNomeEmit  := Space(40)      
			Private cIDECHV	   := substr(oNF:_InfNfe:_id:TEXT,4,44)
			//Private cTpNF	   := oNF:_InfNfe:_IDE:_tpNF	
			Private cTpNF      := OIdent:_tpNf:TEXT
			Private cStatus    := "2"
			oDet  := IIf(ValType(oDet)=="O",{oDet},oDet)
			cTipo := "N"
	
			cCgcEmit := AllTrim(IIf(Type("oEmitente:_CPF")=="U",oEmitente:_CNPJ:TEXT,oEmitente:_CPF:TEXT))
	
		    cCgcDest := AllTrim(IIf(Type("oDestino:_CPF")=="U",oDestino:_CNPJ:Text,oDestino:_CPF:Text))
		    cMunDest := AllTrim(IIf(Type("oDestin2:_xMun")<>"U",oDestin2:_xMun:Text,""))
		    cEstDest := AllTrim(IIf(Type("oDestin2:_UF")<>"U",oDestin2:_UF:Text,""))
			cFildest := PesqFlCNPJ(Alltrim(cCgcDest))
		  	
		  	If Empty(cFildest) // caso nao seja da mesma empresa ou a filial nao exista
		  		Loop
		  	Endif
		  	
		  	cNomeEmit := AllTrim(IIf(Type("oEmitente:_xNome")<>"U",oEmitente:_xNome:TEXT,""))
		    cDoc     := Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)
		    cSerie   := Padr(OIdent:_serie:TEXT,3)
			cTipo    := ''
			cCodigo  := ''
			cLoja    := ''
			cRazao   := ''
			cDtEmis	 := AllTrim(IIf(Type("OIdent:_dhEmi")<>"U",substr(OIdent:_dhEmi:TEXT,9,2)+"/"+substr(OIdent:_dhEmi:TEXT,6,2)+"/"+substr(OIdent:_dhEmi:TEXT,1,4),"")) ////<dhEmi>2015-08-12						
			if Empty(cDtEmis) 
				cDtEmis	 := AllTrim(IIf(Type("OIdent:_dEmi")<>"U",substr(OIdent:_dEmi:TEXT,9,2)+"/"+substr(OIdent:_dEmi:TEXT,6,2)+"/"+substr(OIdent:_dEmi:TEXT,1,4),"")) ////<dhEmi>2015-08-12						
			Endif

			cTipo   := 'NAO CADASTRADO'
			cCodigo := '******'
			cLoja   := '**'
			cRazao  := cNomeEmit

			If !SA2->(dbSetOrder(3), dbSeek(xFilial("SA2") + cCgcEmit))
			
				If !SA1->(dbSetOrder(3), dbSeek(xFilial("SA1") + cCgcEmit))
				
					//MsgAlert("CNPJ Origem Não Localizado - Verifique " + cCgcEmit)
					cMsg03 += 	"CNPJ Origem Não Localizado - Verifique " + cCgcEmit+" - "+cNomeEmit+ " ;<br>"
					
				Else              
				
					cTipo   := 'CLIENTE'
					cCodigo := SA1->A1_COD
					cLoja   := SA1->A1_LOJA
					cRazao  := SA1->A1_NOME
					cStatus := SA1->A1_MSBLQL
				Endif            
				
			Else
	
				cTipo   := 'FORNECEDOR'
				cCodigo := SA2->A2_COD
				cLoja   := SA2->A2_LOJA
				cRazao  := SA2->A2_NOME
				cStatus := SA2->A2_MSBLQL	
			Endif
			
			lGeraXml	:= .F.
			
			If !empty(cTipo) //.and. alltrim(cCgcDest) == alltrim(SM0->M0_CGC) 	    
//			 	If !(SF1->(dbSeek(xFilial("SF1")+cDoc+cSerie+cCodigo+cLoja)))
				
			 	If !(SF1->(dbSeek(cFilDest+cDoc+cSerie+cCodigo+cLoja)))
			 		lGeraXml := .T.
			 	Endif	
			 	// testar casos em que se digita zeros a esquerda da serie	
				If(SF1->(dbSeek(cFilDest+cDoc+'00'+AllTrim(cSerie)+cCodigo+cLoja))) 
				 	lGeraXml := .F.
				Endif	
				If(SF1->(dbSeek(cFilDest+cDoc+'0'+AllTrim(cSerie)+'0'+cCodigo+cLoja))) 
				 	lGeraXml := .F.
				Endif	
				// testar se é NF de entrada ou saída (série 0 ou 1) 0 = ENTRADA 1 SAÍDA
				if (cTpNF == '0')
					lGeraXml := .F.
					
				Endif
				if(cStatus=="1")
					lGeraXml = .F.
				Endif

				
				If lGeraXml	
					reclock('TMP',.T.)
					replace OK        with ''
					replace TIPO      with cTipo     
					replace FILIAL    with cFilDest +" - "+ cCgcDest + " - " + cEstDest + "-" + cMunDest
					replace CODIGO    with cCodigo     
					replace LOJA      with cLoja     
					replace RAZAO     with cRazao
					replace TIPOOP	  with 'NF ENTRADA'
		        	replace DOCUMENTO with cDoc
		        	replace SERIE     with cSerie
		        	replace EMISSAO	  WITH cDtEmis
					replace CHAVE     with cIDECHV	 
					replace XML       with aFiles[nI] 	 
					msunlock()
					nXML++ 
				Endif

			Endif
			
		Endif // lObjNfe 
		 				
    Endif
Next

If !Empty(cMsg01) .or. !Empty(cMsg02)
	MsgAlert("O(s) arquivo(s) abaixo nao pode(m) ser aberto(s)! Verifique os parametros ou Layout do Arquivo!!!. <br>"+cMsg01+"<br><br>"+cMsg02+"<br>" ,"Atenção")
Endif

If !Empty(cMsg03) 
	MsgAlert("O(s) CNPJ/CPF Origem Não foi(ram) localizado(s) ! Verifique !!!. <br>"+cMsg03+"<br>","Atenção")
Endif

Return

Static Function fMarcaT(opcao)

local cArea:=alias()
local nRec :=recno()

dbSelectArea('TMP')
dbGotop()
do while !eof()
	reclock('TMP',.f.)
	if opcao == 1
		replace TMP->OK with cMarca
	else
		replace TMP->OK with ' '
	endif		
	msunlock()
	dbSkip()
enddo

dbSelectArea(cArea)
dbGoto(nRec)

return





Static Function ValidPerg()

Local cAlias := Alias()
Local nI, nJ

dbSelectArea("SX1")
dbSetOrder(1)

cPerg   := PADR(cPerg,10)
aRegs   :={}

aAdd(aRegs,{cPerg,"01","Diretorio     ?","","","mv_ch1","C",80,0,0,"G","u_fDiretorio","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","_XDIR","","",""})
aAdd(aRegs,{cPerg,"02","Ação          ?","","","mv_ch2","N",01,0,0,"C","","mv_par02","Tela","","","","","Impressao","","","","","","","","","","","","","","","","","","","","","",""})
//aAdd(aRegs,{cPerg,"03","Pedido Compra ?","","","mv_ch3","N",01,0,0,"C","","mv_par03","Automatico","","","","","Não Gera","","","","","","","","","","","","","","","","","","","","","",""})


For nI := 1 to Len(aRegs)
	If !dbSeek(cPerg+aRegs[nI,2])
		RecLock("SX1",.T.)
		For nJ:=1 to FCount()
			If nJ <= Len(aRegs[nI])
				FieldPut(nJ,aRegs[nI,nJ])
			Endif
		Next
		MsUnlock()
	Endif
Next

dbSelectArea(cAlias)

Return

                                                                


Static Function PesqFlCNPJ(cxCGC)
	Local aArea 	:= GetArea()
	Local aAreaM0 	:= SM0->(GetArea())
	Local cFilRet 	:= ""
	
	//Percorrendo o grupo de empresas
	SM0->(DbGoTop())
	While !SM0->(EoF())
		//Se o CNPJ for encontrado, atualiza a filial e finaliza, testando tambem a empresa
		If cxCGC == SM0->M0_CGC .and. SM0->M0_CODIGO==cEmpAnt
			cFilRet := SM0->M0_CODFIL
			Exit
		EndIf
		
		SM0->(DbSkip())
	EndDo
	
	RestArea(aAreaM0)
	RestArea(aArea)
Return cFilRet