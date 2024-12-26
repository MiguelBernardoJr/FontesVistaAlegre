#Include "Protheus.ch"

USER FUNCTION ConvLD()
	SETPRVT("cStr")

	cStr := LTRIM(RTRIM(M->E2_LINDIG))

	IF VALTYPE(M->E2_LINDIG) == NIL .OR. EMPTY(M->E2_LINDIG)
		// Se o Campo está em Branco não Converte nada.
		cStr := ""
	ELSE
		// Se o Tamanho do String for menor que 44, completa com zeros até 47 dígitos. Isso é
		// necessário para Bloquetos que NÂO têm o vencimento e/ou o valor informados na LD.
		cStr := IF(LEN(cStr)<44,cStr+REPL("0",47-LEN(cStr)),cStr)
	ENDIF

	DO CASE
	CASE LEN(cStr) == 47
		cStr := SUBSTR(cStr,1,4)+SUBSTR(cStr,33,15)+SUBSTR(cStr,5,5)+SUBSTR(cStr,11,10)+SUBSTR(cStr,22,10)
	CASE LEN(cStr) == 48
	cStr := SUBSTR(cStr,1,11)+SUBSTR(cStr,13,11)+SUBSTR(cStr,25,11)+SUBSTR(cStr,37,11)
	OTHERWISE
		cStr := cStr+SPACE(48-LEN(cStr))
	ENDCASE

RETURN(cStr)
