#INCLUDE 'PROTHEUS.CH'

User Function zValDesc() //u_zValDesc()
    Local lRet      := .T. 
    Local cBov      := GETMV("MV_BOVPADR")
    Local cCampo    := SubStr(ReadVar(),at('>',ReadVar())+1,Len(ReadVar()))
    Local cTitulo   := FWX3Titulo( cCampo )

    /*  
        BOVS QUE A DESCRIÇÃO NÃO PODE SER ALTERADA - CONTEUDO NO PARAMETRO MV_BOVPADR

        'B1_DESC|B1_XIDADE|B1_XANIMAL|B1_XANIITE|B1_X_ERA'

        'BOV000000022324',
        'BOV000000022325',
        'BOV000000022326',
        'BOV000000022327',
        'BOV000000022333',
        'BOV000000022322',
        'BOV000000022323',
        'BOV000000022328',
        'BOV000000022329',
        'BOV000000049358'
    */

    //"BOV000000022324,BOV000000022325,BOV000000022326,BOV000000022327,BOV000000022333,BOV000000022322,BOV000000022323,BOV000000022328,BOV000000022329,BOV000000049358"
    
    IF !IsInCallStack("U_VAMVCA01")
        if AllTrim(SB1->B1_COD) $ cBov
            MsgStop("Campo ["+cCampo+" - "+Alltrim(cTitulo)+"] do produto ["+AllTrim(SB1->B1_COD)+"] não pode ser alterada por se tratar de BOV PADRÃO!" + CRLF +;
                    "Faça a transferência para outro BOV com a idade correta!")
            lRet := .F.
        endif
    endif

Return lRet
