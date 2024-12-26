#Include "Rwmake.ch"
#Include "Protheus.ch"
#Include "TopConn.ch"

/* 05.03.2018 */ 
user function VACOMM09( cCods )	// Alert( U_VACOMA09('101,102,103,104,105') )
// Local cCods  := GetMv("MV_MSGFUN",,"008,009,010,011")
Local aCods  := strtokarr( cCods, ",")	
Local cTexto := ""
Local cMsg 	 := "" 

	// utilizado somente durante teste - debug direto com alert pelo formulas
	//CHKFILE('SF1')
	//SF1->(DBGOTO(56495))

	For nI := 1 to len(aCods)
		cTexto := AllTrim( POSICIONE("SM4",1,xFilial("SM4")+aCods[nI],"M4_FORMULA") )
		If !Empty(cTexto)
			cTexto 	:= TrataTexto(cTexto)
			cMsg 	+= iIf(Empty(cMsg),"", CRLF) + cTexto
		EndIf
	Next nI

return(cMsg)

/* MJ : 05.03.2018 */
User Function LimpaAcentos( cVar )
Local nLen := 0
Local i    := 0
Local aPad := { { 'ã', 'a' }, { 'á' , 'a' }, { 'â', 'a' }, { 'ä', 'a' }, ;
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
                { '"', ''  }, ;
                { '&', '' } }
                
nLen := Len(aPad)
For i := 1 To nLen
   cVar := StrTran(cVar, aPad[i][1], aPad[i][2])
Next
Return AllTrim(cVar)


/* MJ : 06.03.2018 */
Static Function A05MVRUR(/* cTexto */)   // Alert( U_VACOMA09('101,102,103,104,105') )
Local cParam	:= GetMV('MV_CONTSOC',,'1.5/1.5/1.5')
Local aParam  	:= strtokarr( cParam, "/")	
Local cRet 		:= 0
/* Default cTexto   := "" */

//CHKFILE('SA2')
//SA2->(DBGOTO(5135))

// MV_CONTSOC => Pessoa Fisica:=2.2,Seg.Especial 2.3,Juridica:= 2.7
If SA2->A2_TIPORUR == 'L'
	cRet := aParam[2]
ElseIf SA2->A2_TIPORUR == 'J'
	cRet := aParam[3]
Else // SA2->A2_TIPORUR == 'F'
	cRet := aParam[1]
EndIf

Return cRet


/* MJ : 06.03.2018 */
Static Function A05SM4( cCodigo ) // 000005610
Local aArea		:= GetArea()
Local nRet 		:= 0
Local cTexto 	:= AllTrim( Posicione("SM4",1,xFilial("SM4")+cCodigo ,"M4_FORMULA") )
Local cRur		:= ""

	While AT( "A05MVRUR", UPPER( cTexto ) ) > 0
		cRur := A05MVRUR()
		cTexto := StrTran( cTexto, "A05MVRUR()" , cRur )
		cTexto := StrTran( cTexto, "#"+cRur+"#" , cRur )
	EndDo
	
	cTexto 		:= StrTran( cTexto, '"' , '' )
	cTexto 		:= StrTran( cTexto, "'" , '' )
	nRet		:= &( cTexto )

RestArea(aArea)
Return nRet

/* 05.03.2018 */
Static Function TrataTexto(cTexto) // fCpoAutoMail
Local cAux 	  := U_LimpaAcentos(cTexto)
Local nIni	  := At('#', cTexto )+1
Local nFim	  := At('#', SubS( cTexto,  nIni ) )-1
Local cCampo  := ""
Local cPrefix := ""
Local xInfo   := ""
Local nCalc	  := 0

	While nIni > 1 .and. nFim > 0	
		cCampo  := SubS( cTexto, nIni, nFim )
		cPrefix := Iif(SubS(cCampo,3,1) == "_", "S"+SubS(cCampo,1,2),SubS(cCampo,1,3))
		if !Empty(cCampo)
	
			If 'A05SM4' $ cCampo // 'M04010A' // A05SM4("201") // Alert( U_VACOMA09('101,102,103,104,105') )
			
				nCalc := &(cCampo)
				xInfo := AllTrim(Transform( nCalc, X3Picture("F1_BASEFUN") ))
			
			ElseIf 'A05MVRUR' $ cCampo
			
				xInfo := &(cCampo)
			
			Else
	
				xInfo   := (cPrefix)->&(cCampo)
				
				if xInfo == Nil
					xInfo := cCampo
				Else
					If ValType(xInfo) == "N"
						xInfo := AllTrim(Transform( xInfo, X3Picture("F1_BASEFUN") ))
					ElseIf ValType(xInfo) == "D"
						xInfo := AllTrim(dToC( xInfo ))
					EndIf
				EndIf
			EndIf
			
			cTexto := StrTran( cTexto, '#' + cCampo + '#' , xInfo )
			
			// ElseIf cCampo == 'M04010B'
			// 
			// 	nCalc := Round( SF1->F1_VALICM*1.5/100, 2)
			// 	xInfo := AllTrim(Str( nCalc ))
			// 
			// ElseIf cCampo == 'M04010C'
			// 
			// 	nCalc := Round( (SF1->F1_BASEFUN-SF1->F1_VALICM)*(1.5/100), 2)
			// 	xInfo := AllTrim(Str( nCalc ))
			// 
			// ElseIf cCampo == 'M04017A'
			// 
			// 	nCalc := Round( SF1->F1_BASEFUN*1.5/100, 2)
			// 	xInfo := AllTrim(Str( nCalc ))
			// 
		EndIf
		nIni    := At('#', cTexto )+1
		nFim    := At('#', SubS( cTexto,  nIni ) )-1	
	EndDo
	
Return(cTexto) // Alert( U_VACOMA09('008,009,010,011') )