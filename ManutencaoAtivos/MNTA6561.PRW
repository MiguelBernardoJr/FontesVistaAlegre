User Function MNTA6561()


Local aParamBox := {}
Local aRet      := {}
Local aOpc      := {("Abastecimento"),("Abastecimento+Produto"),("Produto")}

If !Inclui
	If Alltrim(TTA->TTA_SERREP) == "C00014"
		nLanca := "Produto"
	Endif
	return
Endif

nLanca := "Abastecimento"

AADD(aParamBox,{2,"Tipo de Lançamento",nLanca,aOpc,90,"",.t.}) 

While .t.

	If ParamBox(aParamBox,"",@aRet,,,,,,,,.F.)
		nLanca := aRet[1]
	Else
		Return
	EndIf

	Exit

Enddo

Return
