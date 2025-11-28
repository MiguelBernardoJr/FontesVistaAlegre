#include 'PROTHEUS.ch'
 
User Function NGNOGERASC()
 
    Local aSC      := ParamIXB[1]
    Local cProgram := FunName()
    Local lRet     := .T.
 
    Do Case
 
        Case cProgram == 'MNTA410'
 
            // Não gera S.C. qaundo acionado pelo rotina O.S. Preventiva.
            lRet := .t.//MsgYesNo( 'Deseja cancelar a geração da S.C. para a O.S. Preventiva?', 'Atenção' )
 
        Case cProgram == 'MNTA420'
 
            // Não gera S.C. qaundo acionado pelo rotina O.S. Corretiva.
            if Len(ParamIXB) > 3 // quando é TERCEIRO o array vem com apenas 3 posições
                lRet := .F.//MsgYesNo( 'Deseja cancelar a geração da S.C. para a O.S. Corretiva?', 'Atenção' )
            endif

        OtherWise
 
            // Gera S.C. qaundo acionado pelas demais rotinas.
            lRet := .F.
 
    End Case

Return lRet
