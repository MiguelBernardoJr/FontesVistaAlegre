#INCLUDE "TOPCONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

User Function XMLNFe

Private cPerg := "IMPX3L"
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
nPC         := MV_PAR03


AADD(aCampos,{"OK",         "C",002						,0,})
AADD(aCampos,{"TIPO",       "C",010						,0,})
AADD(aCampos,{"CODIGO",     "C",TAMSX3('A2_COD')[1]		,0,})
AADD(aCampos,{"LOJA",       "C",TAMSX3('A2_LOJA')[1]	,0,})
AADD(aCampos,{"RAZAO",      "C",TAMSX3('A2_NOME')[1]	,0,})
AADD(aCampos,{"DOCUMENTO",  "C",TAMSX3('F1_DOC')[1]		,0,})
AADD(aCampos,{"SERIE",      "C",TAMSX3('F1_SERIE')[1]	,0,})
AADD(aCampos,{"EMISSAO",    "C",TAMSX3('F1_EMISSAO')[1]+4 ,0,})
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
AADD(aCpos,{"CODIGO"    ,,"Codigo"              })
AADD(aCpos,{"LOJA"      ,,"Loja"                })
AADD(aCpos,{"RAZAO"     ,,"Razão Social"        })
AADD(aCpos,{"DOCUMENTO" ,,"Documento"           })
AADD(aCpos,{"SERIE"     ,,"Serie"               })
AADD(aCpos,{"EMISSAO"   ,,"Emissao"             })
AADD(aCpos,{"XML"       ,,"XML"                 })

cMarca    := Getmark()       

aRotina := {{"Gerar"   ,"u_GeraNFE()",    0 , 4},;
            {"Marca"   ,"u_fMarcaT(1)",   0 , 4},;
            {"Desmarca","u_fMarcaT(2)",   0 , 4}}
                                  
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
Local nI        := 0 
Local cMsg01	:= "" // arquivo nao pode ser aberto
Local cMsg02	:= "" // erro no layout
Local cMsg03	:= "" // cnpj nao cadastrado

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
			Private oTotal     := oNF:_InfNfe:_Total
			Private oTransp    := oNF:_InfNfe:_Transp
			Private oDet       := oNF:_InfNfe:_Det 
			Private cCgcDest   := Space(14)      
			Private cNomeEmit  := Space(40)      
				
			oDet  := IIf(ValType(oDet)=="O",{oDet},oDet)
			cTipo := "N"
	
			cCgcEmit := AllTrim(IIf(Type("oEmitente:_CPF")=="U",oEmitente:_CNPJ:TEXT,oEmitente:_CPF:TEXT))
	
		    cCgcDest := AllTrim(IIf(Type("oDestino:_CPF")=="U",oDestino:_CNPJ:Text,oDestino:_CPF:Text))
			
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
			If !SA2->(dbSetOrder(3), dbSeek(xFilial("SA2") + cCgcEmit))
			
				If !SA1->(dbSetOrder(3), dbSeek(xFilial("SA1") + cCgcEmit))
				
					//MsgAlert("CNPJ Origem Não Localizado - Verifique " + cCgcEmit)
					cMsg03 += 	"CNPJ Origem Não Localizado - Verifique " + cCgcEmit+" - "+cNomeEmit+ " ;<br>"
					
				Else              
				
					cTipo   := 'CLIENTE'
					cCodigo := SA1->A1_COD
					cLoja   := SA1->A1_LOJA
					cRazao  := SA1->A1_NOME
		
				Endif            
				
			Else
	
				cTipo   := 'FORNECEDOR'
				cCodigo := SA2->A2_COD
				cLoja   := SA2->A2_LOJA
				cRazao  := SA2->A2_NOME
					
			Endif
	
			If !empty(cTipo) .and. alltrim(cCgcDest) == alltrim(SM0->M0_CGC) 	    
			 	If !(SF1->(dbSeek(xFilial("SF1")+cDoc+cSerie+cCodigo+cLoja)))
					reclock('TMP',.T.)
					replace OK        with ''
					replace TIPO      with cTipo     
					replace CODIGO    with cCodigo     
					replace LOJA      with cLoja     
					replace RAZAO     with cRazao     
		        	replace DOCUMENTO with cDoc
		        	replace SERIE     with cSerie
		        	replace EMISSAO	  WITH cDtEmis
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

User Function fMarcaT(opcao)

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

User Function GeraNFE

Local nItem 	:= 0
Local lPCSld	:= .F.
Local nCont     := 0
Local nContLote := 0
dbSelectArea('TMP')
dbGotop()
do while !eof()

	IF TMP->OK == cMarca    

		nItem  := 0
		lGera  := .T.
		aCabec := {}
		aItens := {}

		cFile := cDiretor + alltrim(TMP->XML) 	
		nHdl  := fOpen(cFile,0)
					
		nTamFile := fSeek(nHdl,0,2)
		fSeek(nHdl,0,0)
		cBuffer  := Space(nTamFile)                
		nBtLidos := fRead(nHdl,@cBuffer,nTamFile)  
		fClose(nHdl)
		
		cAviso := ""
		cErro  := ""
		oNfe := XmlParser(cBuffer,"_",@cAviso,@cErro)
		
		If Type("oNFe:_NfeProc") <> "U"
			oNF := oNFe:_NFeProc:_NFe
		Else
			oNF := oNFe:_NFe
		Endif
		
		oEmitente  := oNF:_InfNfe:_Emit
		oIdent     := oNF:_InfNfe:_IDE
		oDestino   := oNF:_InfNfe:_Dest
		oTotal     := oNF:_InfNfe:_Total
		oTransp    := oNF:_InfNfe:_Transp
		oDet       := oNF:_InfNfe:_Det 
		cCgcDest   := Space(14)
		cIDECHV	   := substr(oNF:_InfNfe:_id:TEXT,4,44)
			
		oDet  := IIf(ValType(oDet)=="O",{oDet},oDet)
		
		cTipo := "N"
	
		cCgcEmit := AllTrim(IIf(Type("oEmitente:_CPF")=="U",oEmitente:_CNPJ:TEXT,oEmitente:_CPF:TEXT))
	    cCgcDest := AllTrim(IIf(Type("oDestino:_CPF")=="U",oDestino:_CNPJ:Text,oDestino:_CPF:Text))
		cNomeEmit := AllTrim(IIf(Type("oEmitente:_xNome")<>"U",oEmitente:_xNome:TEXT,""))

	    cDoc     := Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)
	    cSerie   := Padr(OIdent:_serie:TEXT,3)
		cTipo    := ''
		cCodigo  := ''
		cLoja    := ''
		cRazao   := ''
	   		
		If !SA2->(dbSetOrder(3), dbSeek(xFilial("SA2") + cCgcEmit))
		
			If !SA1->(dbSetOrder(3), dbSeek(xFilial("SA1") + cCgcEmit))
			
				//MsgAlert("CNPJ Origem Não Localizado - Verifique " + cCgcEmit)
				cMsg03 += 	"CNPJ Origem Não Localizado - Verifique " + cCgcEmit+" - "+cNomeEmit+ " ;<br>"
				lGera := .F.		
				
			Else              
			
				cTipo   := 'ClIENTE'
				cCodigo := SA1->A1_COD
				cLoja   := SA1->A1_LOJA
				cRazao  := SA1->A1_NOME
	
			Endif            
			
		Else
	
			cTipo   := 'FORNECEDOR'
			cCodigo := SA2->A2_COD
			cLoja   := SA2->A2_LOJA
			cRazao  := SA2->A2_NOME
				
		Endif
	
		If SF1->(DbSeek(XFilial("SF1")+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+Padr(OIdent:_serie:TEXT,3)+cCodigo+cLoja))
			MsgAlert("Nota No.: "+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+"/"+OIdent:_serie:TEXT + if(cTipo=='FORNECEDOR',' do Fornec. ',' do Cliente ') + cCodigo+"/"+cLoja+" Ja foi importada.")
			lGera := .F.			
			dbSelectArea('TMP')
			dbSkip()
			Loop
		EndIf
						
		cLogVer := ''
		cProds  := ''
		aPedIte := {}                                 
		        
		nItens  := len(oDet)
		
		For nCont := 1 To nItens
	 		
	 		 cCodPro	   := space(TamSx3("B1_COD")[1])	
	 	     cCodBarra     := oDet[nCont]:_Prod:_CEAN:Text
	 	     cCodForn      := AllTrim(oDet[nCont]:_Prod:_CPROD:Text)
	         cProdFDsc	   := Alltrim(oDet[nCont]:_Prod:_xProd:Text)
	  	     nQuant        := Val(oDet[nCont]:_Prod:_QCOM:Text)
	         nPrcUnBrt     := Val(oDet[nCont]:_Prod:_VUNCOM:Text)
	         nPrcTtBrt     := nQuant * nPrcUnBrt 
	
		     If XmlChildEx(oDet[nCont]:_PROD, "_VDESC")!= Nil
		          nValDesc     := Val(oDet[nCont]:_Prod:_VDESC:Text)
		     Else
		          nValDesc     := 0
		     EndIf    
		     
		     // Busca o Codigo interno do produto.
		     dbSelectArea("SA5")
		     dbSetOrder(5)
		     cUnidad := ""
		     bOkItem := .F.
		     
		     If bOkItem == .F. .and. alltrim(str(val(cCodForn))) <> cCodForn .and. val(cCodForn) > 0 // busca sem os zeros no inicio. se existirem zeros.
	
		          cCodForn     := Alltrim(cCodForn) //Alltrim(Str(val(cCodForn)))
		          
		          If SA5->(dbSeek(xFilial("SA5")+   cCodForn ))
		               While alltrim(SA5->A5_CODPRF) = cCodForn
		                    If SA5->(A5_FORNECE+A5_LOJA) == cCodigo+cLoja
		                         bOkItem := .T.
		                         cCodPro := SA5->A5_PRODUTO
		                         cUnidad := SA5->A5_UNID
		                         Exit
		                    Endif
		                    dbSkip()
		               EndDo
		          EndIf
		     Endif
			     
		     If bOkItem == .F.
		     
		          If SA5->(dbSeek(xFilial("SA5")+cCodForn)) // Busca pelo codigo do Fornecedor
		               While alltrim(SA5->A5_CODPRF) = cCodForn
		                    If SA5->(A5_FORNECE+A5_LOJA) == cCodigo+cLoja
		                         bOkItem := .T.
		                         cCodPro := SA5->A5_PRODUTO
		                         cUnidad := SA5->A5_UNID
		                         Exit
		                    EndIf
		                    DBSkip()
		               EndDo
		          Endif
		     Endif
		     
		     If bOkItem = .F. .and. !Empty(cCodBarra)
		
		        // Busca pelo Codigo de Barras no cadastro do produto
		          dbSelectArea("SB1")
		          dbSetOrder(5)
		          If SB1->(dbSeek(xFilial("SB1")+cCodBarra))
		               cCodPro := SB1->B1_COD               
		               
		               // Verifica se existe uma amarracao para o produto encontrado
		               dbSelectArea("SA5")
		               dbSetOrder(2)
		               If ! DBSeek(xFilial("SA5")+cCodPro+cCodigo+cLoja)
		                    // Inclui a amarracao do produto X Fornecedor
		                    bOkItem := .T.
		                    RecLock("SA5",.T.)
		                    A5_FILIAL     := xFilial("SA5")
		                    A5_FORNECE    := cCodigo
		                    A5_LOJA       := cLoja
		                    A5_NOMEFOR    := SA2->A2_NOME
		                    A5_PRODUTO    := cCodPro
		                    A5_NOMPROD    := SB1->B1_DESC
		                    A5_CODPRF     := cCodForn
		                    MSUnLock()
		               Else
		                    If Empty(SA5->A5_CODPRF) .or. SA5->A5_CODPRF = "0" // Atualiza a amarracao se nao tiver o codigo do fornecedor cadastrado.
		                         bOkItem := .T.
		                         RecLock("SA5",.F.)
		                         A5_CODPRF     := cCodForn
		                         MSUnLock()
		                    Endif
		               EndIf
		          Endif
	
		          If !bOkItem
		               dbSelectArea("SLK")
		               DBSetOrder(1)
		               If SLK->(dbSeek(xFilial("SLK")+cCodBarra))
		                    bOkItem := .T.
		                    cUnidad := "3"
		                    cCodigo := SLK->LK_CODIGO
		               Endif
		          Endif
		          
		     Endif
			
		     If !bOkItem 
		     	u_GeraSA5()
				lGera := .F.
			 Endif

		     If !bOkItem 
//				MsgAlert("Produto Sem Amarração: " + cCodForn + " (" + oDet[nCont]:_Prod:_xProd:Text + ") Codigo de barras: " + cCodBarra)
				cLogVer+= Chr(13)+Chr(10)+"Produto Sem Amarração: " + cCodForn + " (" + cProdFDsc + ") Codigo de barras: " + cCodBarra+" "+Chr(13)+Chr(10)
				lGera := .F.
				dbSelectArea('TMP')
				TMP->(dbSkip())
				Loop
		     Else
		        // Posiciona no produto encontrado
		        dbSelectArea("SB1")
		        dbSetOrder(1)
		        dbSeek(xFilial("SB1")+cCodPro)
		        
		        If SB1->B1_MSBLQL = '1'
		        	If Aviso("Produto Bloqueado","Este Produto esta bloqueado, deseja desbloquea-lo agora? ",{"Sim","Não"}) == 1
		         		RecLock("SB1",.F.)
		           			B1_MSBLQL:= '2'
		              	MSUnLock()  
		            Else
						cLogVer+= Chr(13)+Chr(10)+"Produto Bloqueado: " + cCodForn + " (" + oDet[nCont]:_Prod:_xProd:Text + ") Codigo de barras: " + cCodBarra+"   Codigo no Sistema: "+SB1->B1_COD+" "+Chr(13)+Chr(10)
						lGera := .F.					
						dbSelectArea('TMP')
						TMP->(dbSkip())
						Loop				              	
					Endif
		        Endif
			 Endif
			 						
	         nFator := 1
	         Do Case
	               Case cUnidad = "2"
	                    nFator := SB1->B1_CONV
	               Case cUnidad = "3" .and. SLK->LK_QUANT > 1
	                    nFator := SLK->LK_QUANT
	         End Case
	
	          //Verifica se possui Node _Med
	         bMed := XmlChildEx(oDet[nCont]:_Prod , "_MED" ) != Nil
	     
	         If bMed
	               // Converte o Node Med em array para os casos que existe informacao de mais de um lote do mesmo produto.          
	               If ValType(oDet[nCont]:_PROD:_MED) = "O"
	                    XmlNode2Arr(oDet[nCont]:_PROD:_MED, "_MED")
	               EndIf
	
	               nTotalMed := len(oDet[nCont]:_PROD:_MED)
	         Else
	               nTotalMed := 1
	               nQtdeLote := nQuant
	               cLote     := ""
	               cValidade := ""
	         Endif
	                 
	          // Acumuladores
	         nDescTT  := 0
	         nValorTT := 0
	         
	         For nContLote := 1 to nTotalMed
	         	               	                           
	            if bMed
	                    cLote     := oDet[nCont]:_Prod:_MED[nContLote]:_NLote:Text
	                    cValidade := oDet[nCont]:_Prod:_MED[nContLote]:_DVal:Text
	                    cValidade := Substr(cValidade,9,2)+"/"+Substr(cValidade,6,2)+"/"+Substr(cValidade,1,4)
	                    nQtdeLote := val(oDet[nCont]:_Prod:_MED[nContLote]:_QLote:Text)
	            Endif
	            If nContLote != nTotalMed
	                    nDescLote := Round(nValDesc/nQuant*nQtdeLote,2) // Desconto do Lote Atual
	                    nValLote  := Round(nPrcTtBrt/nQuant*nQtdeLote,2) // Valor do Lote Atual
	
	                    nDescTT   += nDescLote
	                    nValorTT  += nValLote                    
	            Else
	                    nDescLote := nValDesc  - nDescTT // Desconto do Lote Atual - Diferenca
	                    nValLote  := nPrcTtBrt - nValorTT // Valor do Lote Atual - Diferenca
	            Endif

	            If nFator > 1               
	                  nQtdeLote := nQtdeLote*SB1->B1_CONV
	            Endif

				 //Pedido de compra automático
				cPedAut   	:= ''			 
				cItPedAut 	:= ''
				cPcCC	    := ''
				cPcCICta	:= ''
				cPcCLVL	    := ''
				
				If nPC == 1
				
				 	dbSelectArea('SC7')
				 	dbSetOrder(2)
				 	dbSeek(xFilial('SC7') + padr(cCodPro,tamsx3('C7_PRODUTO')[1]) + padr(cCodigo,tamsx3('C7_FORNECE')[1]) + padr(cLoja,tamsx3('C7_LOJA')[1]), .T. )
	     			
	     			//validar de pedido esta apto para uso  - com saldo
	     			While 	C7_FILIAL  == xFilial('SC7') .AND. C7_PRODUTO == padr(cCodPro,tamsx3('C7_PRODUTO')[1]) .AND. C7_FORNECE == padr(cCodigo,tamsx3('C7_FORNECE')[1]) .AND. C7_LOJA    == padr(cLoja,tamsx3('C7_LOJA')[1])
						
	     				If C7_QUANT - C7_QUJE >= nQtdeLote 
	     					Exit
	     				Endif
	     			    SC7->(dbSkip())
	     			Enddo           
	     
					If  C7_FILIAL  == xFilial('SC7') .AND. ;
						C7_PRODUTO == padr(cCodPro,tamsx3('C7_PRODUTO')[1]) .AND. ;
						C7_FORNECE == padr(cCodigo,tamsx3('C7_FORNECE')[1]) .AND. ;
						C7_LOJA    == padr(cLoja,tamsx3('C7_LOJA')[1]) .AND. ;
						C7_QUANT - C7_QUJE >= nQtdeLote
						
						cPedAut   	:= C7_NUM			 
						cItPedAut 	:= C7_ITEM  
						cPcCC	    := C7_CC  
						cPcCICta	:= C7_ITEMCTA  
						cPcCLVL	    := C7_CLVL  
																
					Endif	
				 
				Endif	 
	
                nItem++
	            aLinha := {}
	            
	            aadd(aLinha,{"D1_ITEM"  ,STRZERO(nItem,3)   ,Nil})
	            aadd(aLinha,{"D1_FILIAL",xFilial('SD1')     ,Nil})
	            aadd(aLinha,{"D1_COD"   ,cCodPro            ,Nil})
	            aadd(aLinha,{"D1_QUANT" ,nQtdeLote          ,Nil})               
	            aadd(aLinha,{"D1_VUNIT" ,nValLote/nQtdeLote ,Nil})
	            aadd(aLinha,{"D1_TOTAL" ,nValLote           ,Nil})
	            aadd(aLinha,{"D1_TES"   ,""                 ,Nil})
	            aadd(aLinha,{"D1_OPER"  ,""                 ,Nil})
	            aadd(aLinha,{"D1_CONTA" ,""                 ,Nil})               
	            aadd(aLinha,{"D1_VALDESC", nDescLote        ,Nil})                
	            aadd(aLinha,{"D1_LOTEFOR",cLote             ,Nil})
	            If !empty(cPedAut)
		            aadd(aLinha,{"D1_PEDIDO"	,cPedAut    ,Nil})
		            aadd(aLinha,{"D1_ITEMPC"	,cItPedAut  ,Nil})
		            aadd(aLinha,{"D1_CC"		,cPcCC      ,Nil})
		            aadd(aLinha,{"D1_ITEMCTA"	,cPcCICta   ,Nil})
		            aadd(aLinha,{"D1_CLVL"		,cPcCLVL    ,Nil})
		        Endif    
	            aadd(aLinha,{"AUTDELETA","N"                ,Nil}) 
	               
	            aadd(aItens,aLinha)
	            
	         Next
	         
		Next
	    
		If !empty(cLogVer)
			Aviso('Verificar Produtos',cLogVer,{'Ok'})  
	    Endif
	
	
		If len(aItens) > 0 .and. lGera

			nFrete        := 0
			nSeguro       := Val(oNfe:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VSeg:Text)			
			nIcmsSubs     := Val(oNfe:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VST:Text)
			nTotalMerc    := Val(oNfe:_NFEPROC:_NFE:_INFNFE:_TOTAL:_ICMSTOT:_VPROD:Text) // Valor Mercadorias
			cData         := SUBSTR(Alltrim(OIdent:_dhEmi:TEXT),1,10)
			dData         := CTOD(Right(cData,2)+'/'+Substr(cData,6,2)+'/'+Left(cData,4))
						
			aadd(aCabec,{"F1_TIPO"   ,if(cTipo=='FORNECEDOR','N','D'),Nil,Nil})
			aadd(aCabec,{"F1_FORMUL" ,"N",Nil,Nil})
			aadd(aCabec,{"F1_DOC"    ,cDoc,Nil,Nil})
			aadd(aCabec,{"F1_SERIE"  ,cSerie,Nil,Nil})
			aadd(aCabec,{"F1_EMISSAO",dData,Nil,Nil})
			aadd(aCabec,{"F1_FORNECE",cCodigo,Nil,Nil})
			aadd(aCabec,{"F1_LOJA"   ,cLoja,Nil,Nil})
			aadd(aCabec,{"F1_ESPECIE","SPED",Nil,Nil})
		    aadd(aCabec,{"F1_SEGURO" ,nSeguro,NIL})
		    aadd(aCabec,{"F1_FRETE"  ,nFrete,NIL})    
		    aadd(aCabec,{"F1_VALMERC",nTotalMerc,NIL})
		    aadd(aCabec,{"F1_VALBRUT",nTotalMerc+nSeguro+nFrete+nIcmsSubs,NIL})
		    aadd(aCabec,{"F1_CHVNFE"  ,cIDECHV,NIL})    
		
		    dbSelectArea("SB1")
		    dbSetOrder(1)

			lMsErroAuto := .f.
															     
		    MATA140(aCabec,aItens,3)
		    		     
		    If !lMsErroAuto

				SF1->(DbSeek(XFilial("SF1")+Right("000000000"+Alltrim(OIdent:_nNF:TEXT),9)+Padr(OIdent:_serie:TEXT,3)+cCodigo+cLoja))		          
				
				If nAcao == 1 //PRE NOTA

					antArotina := aRotina
							
					aRotina	:= {{ "Pesquisar"	            ,"AxPesqui"		, 0 , 1, 0, .F.},; 
								{ "Visualizar"	            ,"A140NFiscal"	, 0 , 2, 0, .F.},; 
								{ "Incluir"	                ,"A140NFiscal"	, 0 , 3, 0, nil},; 
								{ "Alterar"	                ,"A140NFiscal"	, 0 , 4, 0, nil},; 
								{ "Excluir"	                ,"A140NFiscal"	, 0 , 5, 0, nil},; 
								{ "Imprimir"	            ,"A140Impri"  	, 0 , 4, 0, nil},; 
								{ "Estorna Classificacao"	,"A140EstCla" 	, 0 , 5, 0, nil},; 
								{ "Legenda"	                ,"A103Legenda"	, 0 , 2, 0, .F.}} 
	
					PRIVATE aHeadSD1    := {}
											
					A140NFiscal('SF1',SF1->(recno()),4)          
					
				    aRotina := antArotina
				
				ElseIf nAcao == 2 //Classifica
				
					antArotina := aRotina

					PRIVATE aRotina := {{"Pesquisar"  , "AxPesqui"   , 0, 1},; 
										{"Visualizar" , "A103NFiscal", 0, 2},; 
										{"Incluir"    , "A103NFiscal", 0, 3},; 
										{"Classificar", "A103NFiscal", 0, 4},; 
										{"Retornar"   , "A103Devol"  , 0, 3},; 
										{"Excluir"    , "A103NFiscal", 3, 5},; 
										{"Imprimir"   , "A103Impri"  , 0, 4},; 
										{"Legenda"    , "A103Legenda", 0, 2} } 
										
					A103NFiscal('SF1',SF1->(recno()),4)          
					
				    aRotina := antArotina
													
				Endif   
	
				cFileImp := cDiretor + 'Importados\' + alltrim(TMP->XML) 	
				
		        FRename(cFile, cFileImp)

				reclock('TMP',.F.)				
				dbDelete()        
				msunlock()
		
		    Else                       
		    
		        mostraerro()          
		        
		    EndIf
		    
		Endif     
		
	Endif    

	dbSelectArea('TMP')
	dbSkip()
	
enddo		

Return

Static Function ValidPerg()

Local cAlias := Alias()
Local nI, nJ

dbSelectArea("SX1")
dbSetOrder(1)

cPerg   := PADR(cPerg,10)
aRegs   :={}

aAdd(aRegs,{cPerg,"01","Diretorio     ?","","","mv_ch1","C",80,0,0,"G","u_fDiretorio","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","_XDIR","","",""})
aAdd(aRegs,{cPerg,"02","Ação          ?","","","mv_ch2","N",01,0,0,"C","","mv_par02","Pre-Nota","","","","","Classifica","","","","","Nenhuma","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Pedido Compra ?","","","mv_ch3","N",01,0,0,"C","","mv_par03","Automatico","","","","","Não Gera","","","","","","","","","","","","","","","","","","","","","",""})


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


User Function fDiretorio

Local cFile 

If empty(MV_PAR01)

	cFile := cGetFile( "Arquivo NFe (*.xml) | *.xml", "Selecione o Arquivo de Nota Fiscal XML",,'',.F., GETF_RETDIRECTORY)
	
	If !empty(cFile)    
		MV_PAR01 := cFile
	Endif	

Endif
	
Return .T.


//-------------------------------------------------------------------------
// Função para Selecionar o Produto  e Amarrar com a Tabela SA5
//-------------------------------------------------------------------------
User Function GeraSA5()
Local oDlgSA5
Local aArea 	:= GetArea()
Local cPFCod	:= Iif(!empty(cCodForn),cCodForn,space(15)) 
Local cPFDesc	:= oDet[nCont]:_Prod:_xProd:Text
Local cPFUCom	:= oDet[nCont]:_Prod:_uCom:Text
Local cPFUTrib	:= oDet[nCont]:_Prod:_uTrib:Text
Local cPFCBar 	:= Iif(!empty(cCodBarra),cCodBarra,space(25)) 
Local cForCod	:= Iif(!empty(cCodigo),cCodigo,space(6)) 
Local cForLoj	:= Iif(!empty(cLoja),cLoja,space(2))  
Local cForRaz	:= Iif(!empty(cRazao),cRazao,space(60))   
Local cFornece  := cForCod+"-"+cForLoj+"  "+cForRaz
Local cProduto	:= space(TamSx3("B1_COD")[1])
//Public cPRDPesq	:= Substr(oDet[nCont]:_Prod:_xProd:Text+space(30),1,30)

DEFINE MSDIALOG oDlgSA5 FROM 05,10 TO 20,105 TITLE "Produto x Fornecedor" //TO 35,105 
@ 002,002 TO 110,370 TITLE "Relacionamento de Produto x Fornecedor" ////TO 220,370 

@ 001,001 SAY "Fornecedor: "  SIZE 70,1 OF oDlgSA5
@ 001,007 MSGET oFornece VAR cFornece PICTURE "@!" When .f. OF oDlgSA5

@ 002,001 SAY "Cod.Produto: " SIZE 70,1 OF oDlgSA5
@ 002,007 MSGET oPFCod VAR cPFCod PICTURE "@!" When .f. OF oDlgSA5

@ 003,001 SAY "Cod.Barra: " SIZE 70,1 OF oDlgSA5
@ 003,007 MSGET oPFCBar VAR cPFCBar PICTURE "@!"  When .f. OF oDlgSA5

@ 004,001 SAY "Descr. Produto: " SIZE 70,1 OF oDlgSA5
@ 004,007 MSGET oPFDesc VAR cPFDesc PICTURE "@!"  When .f. OF oDlgSA5
//@ 003,021 SAY "UF Desemb. " SIZE 70,1 OF oDlgMens
//@ 003,027 MSGET oUFDES VAR cXUFDES F3 '12' PICTURE "@!"  When IIF(Inclui,.t.,.f.) OF oDlgMens

@ 005,001 SAY "UM Comercial: " SIZE 70,1 OF oDlgSA5
@ 005,007 MSGET oPFUCom VAR cPFUCom PICTURE "@!"  When .f. OF oDlgSA5
@ 005,018 SAY "UM Tributada: " SIZE 70,1 OF oDlgSA5
@ 005,025 MSGET oPFUCom VAR cPFUCom PICTURE "@!"  When .f. OF oDlgSA5

@ 006,001 SAY "Produto Protheus:" SIZE 70,1 OF oDlgSA5
@ 006,007 MSGET oProduto VAR cProduto F3 'SB1_X' PICTURE "@!"  When .T. OF oDlgSA5



@ 090,275 BUTTON "&OK" Size 40,14 action (IIF(GrvSa5(cProduto,cPFCBar),oDlgSA5:End(),)) Object btnOK 
@ 090,320 BUTTON "&Cancela" Size 40,14 action oDlgSA5:End() Object btnCancela

//oProduto:Setfocus()
//oPRDPesq:Setfocus()

ACTIVATE MSDIALOG oDlgSA5 CENTERED

RestArea(aArea)

Return .T.                                   

Static Function GrvSa5(cProdCod,cBarras)
Local lRet := .T.
	dbSelectArea("SB1")
	dbSetOrder(1)
	
	If(dbSeek(xFilial("SB1")+cProdCod)) .and. !Empty(Alltrim(cProdCod))
        // Verifica se existe uma amarracao para o produto encontrado
		dbSelectArea("SA5")
		dbSetOrder(2)                                    
		If !DBSeek(xFilial("SA5")+cProdCod+cCodigo+cLoja)
			RecLock("SA5",.T.)
				A5_FILIAL     := xFilial("SA5")
				A5_FORNECE    := cCodigo
				A5_LOJA       := cLoja
				A5_NOMEFOR    := SA2->A2_NOME
				A5_PRODUTO    := cProdCod
				A5_NOMPROD    := SB1->B1_DESC
				A5_CODPRF     := cCodForn
			MSUnLock()        			
			cCodPro := cProdCod			
			bOkItem := .T.    			
		Else
		    If !Empty(alltrim(SA5->A5_CODPRF))
				Alert("Já Existe Produto amarrado para este Fornecedor! Verifique!")	
				lRet := .f.
			Else
				RecLock("SA5",.F.)
					A5_CODPRF     := cCodForn
				MSUnLock()	
				lRet := .T.
				cCodPro := cProdCod			
		    Endif     
		Endif	
 	Else	
 		Alert("Produto Invalido! Verifique!")
 		lRet := .f.                                                                                                                      
 		
 	Endif

	If lRet .and. !Empty(SB1->B1_CODBAR) .and. !empty(cBarras)
		If MsgBox("O Produto "+alltrim(SB1->B1_COD)+" possui o codigo de Barras "+alltrim(SB1->B1_CODBAR)+". Deseja substituir pelo numero " +alltrim(cBarras)+" conforme arquivo XML atual?","Codigo de Barras","YESNO")
			RecLock("SB1",.F.)
				B1_CODBAR     := alltrim(cBarras)
			MSUnLock()	
        Endif
	Endif
 	 	
Return lRet
