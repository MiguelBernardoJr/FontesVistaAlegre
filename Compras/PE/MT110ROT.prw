User Function MT110ROT()
//Local aRotina := {}
//Define Array contendo as Rotinas a executar do programa     
// ----------- Elementos contidos por dimensao ------------    
// 1. Nome a aparecer no cabecalho                             
// 2. Nome da Rotina associada                                 
// 3. Usado pela rotina                                        
// 4. Tipo de Transa‡„o a ser efetuada                         
//    1 - Pesquisa e Posiciona em um Banco de Dados            
//    2 - Simplesmente Mostra os Campos                        
//    3 - Inclui registros no Bancos de Dados                  
//    4 - Altera o registro corrente                           
//    5 - Remove o registro corrente do Banco de Dados         
//    6 - Altera determinados campos sem incluir novos Regs     
    AAdd( aRotina, { 'Bloqueio de solicitações', 'U_IG110BL()', 0, 2 } )
Return aRotina 

User Function IG110BL()
    Local aPergs    := {}
    Local nTipo     := iif(GetMv("MV_BLQSOL"),"S","N")
    Local cUsers    := GetMv("MV_BLQSLUS", ,"")

    if !(__cUserID $ cUsers)
        MsgStop("Usuário sem permissão para utilizar essa rotina!")
        return 
    endif

    aAdd(aPergs, {2, "Bloqueia?", nTipo, {"S=Sim","N=Não"},     122, ".T.", .F.})
    
    If ParamBox(aPergs, "Informe os parâmetros")
        if MV_PAR01 != nTipo
            PutMV("MV_BLQSOL",iif(MV_PAR01=="S",.T.,.F.))
            MsgAlert("A Partir de agora " + iif(MV_PAR01=="S","não será","será") + " permitido alterar solicitações já aprovadas.","Atenção!")
        endif
    EndIf
Return
