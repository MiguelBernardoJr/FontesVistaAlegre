/*/{Protheus.doc} User Function MNTA656H
	Insere novos campos no aHeader 
	@type  Function
	@author Manoel Filho
	@since 20/02/2022
	@version version
	@return 
/*/
User Function MNTA656H()

If nLanca == "Produto"

	If !Empty(Posicione("SX3",2,"TL_NRABAS","X3_CAMPO"))

		aValores := fValidHead("TL_NRABAS")
		aAdd(aHeader,{aValores[1],aValores[2] ,aValores[3] ,aValores[4] ,aValores[5],aValores[6],aValores[7],aValores[8],;
						aValores[9],aValores[10],aValores[11],aValores[12],aValores[13]})

	EndIf

	If !Empty(Posicione("SX3",2,"TL_VUNABA","X3_CAMPO"))

		aValores := fValidHead("TL_VUNABA")
		aAdd(aHeader,{aValores[1],aValores[2] ,aValores[3] ,aValores[4] ,aValores[5],aValores[6],aValores[7],aValores[8],;
						aValores[9],aValores[10],aValores[11],aValores[12],aValores[13]})

	EndIf

	If !Empty(Posicione("SX3",2,"TL_VTTABA","X3_CAMPO"))

		aValores := fValidHead("TL_VTTABA")
		aAdd(aHeader,{aValores[1],aValores[2] ,aValores[3] ,aValores[4] ,aValores[5],aValores[6],aValores[7],aValores[8],;
						aValores[9],aValores[10],aValores[11],aValores[12],aValores[13]})

	EndIf

	If !Empty(Posicione("SX3",2,"TL_TITABA","X3_CAMPO"))

		aValores := fValidHead("TL_TITABA")
		aAdd(aHeader,{aValores[1],aValores[2] ,aValores[3] ,aValores[4] ,aValores[5],aValores[6],aValores[7],aValores[8],;
						aValores[9],aValores[10],aValores[11],aValores[12],aValores[13]})

	EndIf

	If !Empty(Posicione("SX3",2,"TL_FORST9","X3_CAMPO"))

		aValores := fValidHead("TL_FORST9")
		aAdd(aHeader,{aValores[1],aValores[2] ,aValores[3] ,aValores[4] ,aValores[5],aValores[6],aValores[7],aValores[8],;
						aValores[9],aValores[10],aValores[11],aValores[12],aValores[13]})

	EndIf

	If !Empty(Posicione("SX3",2,"TL_LOJST9","X3_CAMPO"))

		aValores := fValidHead("TL_LOJST9")
		aAdd(aHeader,{aValores[1],aValores[2] ,aValores[3] ,aValores[4] ,aValores[5],aValores[6],aValores[7],aValores[8],;
						aValores[9],aValores[10],aValores[11],aValores[12],aValores[13]})

	EndIf

	If !Empty(Posicione("SX3",2,"TL_COBABA","X3_CAMPO"))

		aValores := fValidHead("TL_COBABA")
		aAdd(aHeader,{aValores[1],aValores[2] ,aValores[3] ,aValores[4] ,aValores[5],aValores[6],aValores[7],aValores[8],;
						aValores[9],aValores[10],aValores[11],aValores[12],aValores[13]})

	EndIf

Else // nLanca == "Abastecimento"


	If !Empty(Posicione("SX3",2,"TQN_NRABAS","X3_CAMPO"))

		aValores := fValidHead("TQN_NRABAS")
		aAdd(aHeader,{aValores[1],aValores[2] ,aValores[3] ,aValores[4] ,aValores[5],aValores[6],aValores[7],aValores[8],;
						aValores[9],aValores[10],aValores[11],aValores[12],aValores[13]})

	EndIf

	If !Empty(Posicione("SX3",2,"TQN_VUNABA","X3_CAMPO"))

		aValores := fValidHead("TQN_VUNABA")
		aAdd(aHeader,{aValores[1],aValores[2] ,aValores[3] ,aValores[4] ,aValores[5],aValores[6],aValores[7],aValores[8],;
						aValores[9],aValores[10],aValores[11],aValores[12],aValores[13]})

	EndIf

	If !Empty(Posicione("SX3",2,"TQN_VTTABA","X3_CAMPO"))

		aValores := fValidHead("TQN_VTTABA")
		aAdd(aHeader,{aValores[1],aValores[2] ,aValores[3] ,aValores[4] ,aValores[5],aValores[6],aValores[7],aValores[8],;
						aValores[9],aValores[10],aValores[11],aValores[12],aValores[13]})

	EndIf

	If !Empty(Posicione("SX3",2,"TQN_TITABA","X3_CAMPO"))

		aValores := fValidHead("TQN_TITABA")
		aAdd(aHeader,{aValores[1],aValores[2] ,aValores[3] ,aValores[4] ,aValores[5],aValores[6],aValores[7],aValores[8],;
						aValores[9],aValores[10],aValores[11],aValores[12],aValores[13]})

	EndIf

	If !Empty(Posicione("SX3",2,"TQN_FORST9","X3_CAMPO"))

		aValores := fValidHead("TQN_FORST9")
		aAdd(aHeader,{aValores[1],aValores[2] ,aValores[3] ,aValores[4] ,aValores[5],aValores[6],aValores[7],aValores[8],;
						aValores[9],aValores[10],aValores[11],aValores[12],aValores[13]})

	EndIf

	If !Empty(Posicione("SX3",2,"TQN_LOJST9","X3_CAMPO"))

		aValores := fValidHead("TQN_LOJST9")
		aAdd(aHeader,{aValores[1],aValores[2] ,aValores[3] ,aValores[4] ,aValores[5],aValores[6],aValores[7],aValores[8],;
						aValores[9],aValores[10],aValores[11],aValores[12],aValores[13]})

	EndIf

	If !Empty(Posicione("SX3",2,"TQN_COBABA","X3_CAMPO"))

		aValores := fValidHead("TQN_COBABA")
		aAdd(aHeader,{aValores[1],aValores[2] ,aValores[3] ,aValores[4] ,aValores[5],aValores[6],aValores[7],aValores[8],;
						aValores[9],aValores[10],aValores[11],aValores[12],aValores[13]})

	EndIf

Endif

return


Static function fValidHead(cCampo)

	Local cTitulo   := Posicione("SX3",2,cCampo,"X3Titulo()")
	Local cPicture  := X3Picture(cCampo)
	Local nTam      := TAMSX3(cCampo)[1]
	Local nDec      := TAMSX3(cCampo)[2]
	Local cValid    := Posicione("SX3",2,cCampo,"X3_VALID")
	Local cUsado    := Posicione("SX3",2,cCampo,"X3_USADO")
	Local cTipo     := Posicione("SX3",2,cCampo,"X3_TIPO")
	Local cF3       := Posicione("SX3",2,cCampo,"X3_F3")
	Local cContexto := Posicione("SX3",2,cCampo,"X3_CONTEXT")
	Local cCBox     := X3CBOX(cCampo)
	Local cRelac    := Posicione("SX3",2,cCampo,"X3_RELACAO")
	Local cWhen     := Alltrim(Posicione("SX3",2,cCampo,"X3_WHEN"))


Return {cTitulo,cCampo,cPicture,nTam,nDec,cValid,cUsado,cTipo,cF3,cContexto,cCBox,cRelac,cWhen}


