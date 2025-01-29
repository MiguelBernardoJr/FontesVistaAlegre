#Include 'Protheus.ch'

User Function MT131COR()

Local aCores := PARAMIXB[1]

aAdd(aCores,{'C1_PRODUTO=="220091"',"BR_PINK"})
//Alert ('Ponto de Entrada MT131COR') //Validações do usuário

Return aCores
