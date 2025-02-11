#INCLUDE 'PROTHEUS.CH'

User Function FA750BRW()
    Local aBotoes:={}
    
    aAdd(aBotoes,{ "Excl. Provis. Contrato" , "Processa( { || U_VAFINI02() })", 0, 0} )

Return aBotoes
