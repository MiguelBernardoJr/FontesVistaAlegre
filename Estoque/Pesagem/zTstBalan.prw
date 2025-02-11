//Bibliotecas
#Include "Protheus.ch"
#include "Fileio.ch"

//Constantes
#Define MAX_BUFFER     22     //Máximo de caracter por linha (buffer)
#Define MSECONDS_WAIT  5000   //Tempo de espera
 
/*/{Protheus.doc} zTstBalan
Função para testar a integração com balanças
@author Atilio
@since 07/04/2018
@version 1.0
@type function
/*/
 
User Function zTstBalan()
    Local nPesoRet := 0
     
    nPesoRet := u_zLeBalanca("TOLEDO")
     
    Alert("Peso Lido: "+cValToChar(nPesoRet))
Return nPesoRet
 
/*/{Protheus.doc} zLeBalanca
Função para fazer uma integração com balança via AdvPL
@author Atilio
@since 07/04/2018
@version 1.0
@param cMarca, characters, Marca da balança que será lida
@type function
@obs O fonte original foi criado em 2013, depois foi adaptado por Wallace Freitas em 2015, e agora está sendo reescrito em 2018
    As marcas testadas foram:
    - Toledo
    - Líder
    - Jundiaí
    - Confiança
     
    Foi usado como base, o artigo disponível em http://advpl-protheus.blogspot.com.br/2013/09/integracao-protheus-x-balanca-via.html
@example u_zLeBalanca("TOLEDO")
/*/
 
User Function zLeBalanca()
    Local nPesoRet
    Local cPorta    := ""
    Local cVelocid  := ""
    Local cParidade := ""
    Local cBits     := ""
    Local cStopBits := ""
    Local cFluxo    := ""
    Local nTempo    := ""
    Local cConfig   := ""
    Local lRet      := .T.
    Local nH        := 0
    Local cBuffer   := ""
    Local nPosFim   := 0
    Local nPosIni   := 0
    Local nAux      := 0
    Local nX        := 0
    Local cPesoLido := ""
    Local cLido     := ""
    Default cMarca  := ""
     
    //Se houver marca
    //Pegando a porta padrão da balança
    cPorta    := "COM3" //SuperGetMV("MV_X_PORTA",.F.,"COM3")
    cVelocid  := "9600" //SuperGetMV("MV_X_VELOC", .F.,"9600")    //Velocidade
    cParidade := "N"    //SuperGetMV("MV_X_PARID", .F.,"N")       //Paridade
    cBits     := "8"    //SuperGetMV("MV_X_BITS",  .F.,"8")       //Bits
    cStopBits := "1"    //SuperGetMV("MV_X_SBITS", .F.,"1")       //Stop Bit
    cFluxo    := ""     //SuperGetMV("MV_X_FLUXO", .F.,"")        //Controle de Fluxo
    nTempo    := 5      //SuperGetMV("MV_X_TEMPO", .F.,5)         //Tempo
    
    //Montando a configuração (Porta:Velocidade,Paridade,Bits,Stop)
    cConfig := cPorta+":"+cVelocid+","+cParidade+","+cBits+","+cStopBits
    
    //Guarda resultado se houve abert   ura da porta
    lRet := msOpenPort(nH,cConfig)
    //Se não conseguir abrir a porta, mostra mensagem e finaliza
    If(!lRet)
        //Se for barra, tentar na confiança, depois na jundiai
        MsgStop("<b>Falha</b> ao conectar com a porta serial. Detalhes:"+;
                "<br><b>Porta:</b> "        +cPorta+;
                "<br><b>Velocidade:</b> "   +cVelocid+;
                "<br><b>Paridade:</b> "     +cParidade+;
                "<br><b>Bits:</b> "         +cBits+;
                "<br><b>Stop Bits:</b> "    +cStopBits,"Atenção")
        cLido := 0
    EndIf
    
    //Se estiver OK
    If lRet
        //Mandando mensagem para a porta COM
        msWrite(nH,Chr(5))
        Sleep(nTempo)

        //Pegando o tempo final
        cSegNor:=Time()
        cSegAcr:=SubStr(Time(),1,5)+":"+cValToChar(Val(SubStr(Time(),7,2)) + nTempo)

        //Enquanto os tempos forem diferentes
        While(cSegNor != cSegAcr)
            //Lendo os dados
            msRead(nH,@cBuffer)

            //Se não estiver em branco
            if(!Empty(cBuffer)) 
                cLido := Alltrim(cBuffer)
            EndIf

            //Atualizando o tempo
            cSegNor:=SubStr(cSegNor,1,5)+":"+cValToChar(Val(SubStr(cSegNor,7,2)) + 1)
        EndDo

        cLido   := Upper(cLido)
        nPosFim := (At('K',cLido) - 1)

        //Pegando a Posição Inicial
        For nAux:=1 To Len(cLido)
            //Se o caracter atual estiver contido no intervalo de 0 a 9 e ponto
            If(SubStr(cLido,nAux,1) $ '0123456789.')
                nPosIni:=nAux
                Exit
            EndIf
        Next
            
        nPesoRet := Val(cLido)
    EndIf
        
    msClosePort(nH,cConfig)

Return nPesoRet
 
/*
Abaixo o Fonte Original, escrito em 2013:
 
/*---------------------------------------------------------------------------------------------*
 | Autor: Daniel Atilio                                                                        |
 | Data:  01/10/2013                                                                           |
 | Desc:  Função que lê a porta serial e retorna a string obtida                               |
 | Ref.:  http://advpl-protheus.blogspot.com.br/2013/09/integracao-protheus-x-balanca-via.html |
 *---------------------------------------------------------------------------------------------* /
 
//Bibliotecas
#Include "Protheus.ch"
#Include "RwMake.ch"
 
//Funçãos que lê a porta serial e retorna a string lida
//lTipo    == .F.              -> Irá retornar a string completa
//lTipo    == .T.              -> Irá retornar somente o valor numérico
//cBalanca == 'NOME_BALANCA'
//cTipoVar == 'N'              -> retorna apenas número (Val)
//cCom     == 'PORTA_CONEXAO'
User Function LeSerial(lTipo,cBalanca,cTipoVar,cCom)
    Local cLido:=""
    Local cCfg :=""//"COM1:4800,n,8,1"
    Local nH:=0
    Local lRet:=.F.
    Local cSegAcr:=""
    Local cSegNor:=""
    Local cBuffer:=""
    Local lTipo := .F.
    Local nPeso
 
    Private cBPorta := cCom    //Porta
    Private cBVeloc            //Velocidade
    Private cBParid            //Paridade
    Private cBBits            //Bits
    Private cBStop            //Stop Bit
    Private cBContr            //Controle de Fluxo
    Private cBTempo            //Tempo
    Private cPeso := ""
 
    //Parâmetros, utilizados na Confiança (modelo 312-E)
    If (cBalanca=="CONFIANCA")
        If Empty(cBPorta)
            cBPorta := SuperGetMV("MV_X_CPOR",.F.,"COM1")    //Porta
        EndIf
        cBVeloc := SuperGetMV("MV_X_CVEL",.F.,"9600")    //Velocidade
        cBParid := SuperGetMV("MV_X_CPAR",.F.,"n")        //Paridade
        cBBits  := SuperGetMV("MV_X_CBIT",.F.,"8")        //Bits
        cBStop  := SuperGetMV("MV_X_CSTO",.F.,"1")        //Stop Bit
        cBContr := SuperGetMV("MV_X_CCON",.F.,"")        //Controle de Fluxo
        cBTempo := SuperGetMV("MV_X_CTEM",.F.,"5")        //Tempo
    ElseIf (cBalanca == "JUNDIAI")
        If Empty(cBPorta)
            cBPorta := SuperGetMV("MV_X_JPOR",.F.,"COM4")    //Porta
        EndIf
        cBVeloc := SuperGetMV("MV_X_JVEL",.F.,"9600")    //Velocidade
        cBParid := SuperGetMV("MV_X_JPAR",.F.,"n")        //Paridade
        cBBits  := SuperGetMV("MV_X_JBIT",.F.,"8")        //Bits
        cBStop  := SuperGetMV("MV_X_JSTO",.F.,"0")        //Stop Bit
        cBContr := SuperGetMV("MV_X_JCON",.F.,"")        //Controle de Fluxo
        cBTempo := SuperGetMV("MV_X_JTEM",.F.,"5")        //Tempo
    ElseIf (cBalanca == "TOLEDO")
        If Empty(cBPorta)
            cBPorta := SuperGetMV("MV_X_TPOR",.F.,"COM3")    //Porta
        EndIf
        cBVeloc := SuperGetMV("MV_X_TVEL",.F.,"4800")    //Velocidade
        cBParid := SuperGetMV("MV_X_TPAR",.F.,"S")        //Paridade
        cBBits  := SuperGetMV("MV_X_TBIT",.F.,"7")        //Bits
        cBStop  := SuperGetMV("MV_X_TSTO",.F.,"1")        //Stop Bit
        cBContr := SuperGetMV("MV_X_TCON",.F.,"")        //Controle de Fluxo
        cBTempo := SuperGetMV("MV_X_TTEM",.F.,"5")        //Tempo
    //Qualquer balança que utilize porta serial
    Else
        If Empty(cBPorta)
            cBPorta := SuperGetMV("MV_X_BPOR",.F.,"COM1")    //Porta
        EndIf
        cBVeloc := SuperGetMV("MV_X_BVEL",.F.,"9600")    //Velocidade
        cBParid := SuperGetMV("MV_X_BPAR",.F.,"n")        //Paridade
        cBBits  := SuperGetMV("MV_X_BBIT",.F.,"8")        //Bits
        cBStop  := SuperGetMV("MV_X_BSTO",.F.,"1")        //Stop Bit
        cBContr := SuperGetMV("MV_X_BCON",.F.,"")        //Controle de Fluxo
        cBTempo := SuperGetMV("MV_X_BTEM",.F.,"5")        //Tempo
 
        cLido := 0
        lTipo := .T.                                     //Não passa pela leitura
    EndIf
 
    //Montando a configuração (Porta:Velocidade,Paridade,Bits,Stop)
    cCfg:=cBPorta+":"+cBVeloc+","+cBParid+","+cBBits+","+cBStop
 
    //Guarda resultado se houve abertura da porta
    lRet := msOpenPort(@nH,cCfg)
 
    //Se não conseguir abrir a porta, mostra mensagem e finaliza
    If(!lRet)
        //Se for barra, tentar na confiança, depois na jundiai
        MsgStop("<b>Falha</b> ao conectar com a porta serial. Detalhes:"+;
                "<br><b>Porta:</b> "        +cBPorta+;
                "<br><b>Velocidade:</b> "    +cBVeloc+;
                "<br><b>Paridade:</b> "        +cBParid+;
                "<br><b>Bits:</b> "            +cBBits+;
                "<br><b>Stop Bits:</b> "    +cBStop,"Atenção")
        cLido := 0
    EndIf
 
    //Se estiver em branco o conteúdo
    If !lTipo .And. lRet
        If (cBalanca == "JUNDIAI" .Or. cBalanca == "CONFIANCA")
            //Mandando mensagem para a porta COM
            msWrite(nH,Chr(5))
            If(cBalanca == "JUNDIAI") //Jundiai, 200 milissegundos. Confiança, 500
                Sleep(200)
            ElseIf(cBalanca == "CONFIANCA")
                Sleep(500)
            EndIf
 
            //Pegando o tempo final
            cSegNor:=Time()
            cSegAcr:=SubStr(Time(),1,5)+":"+cValToChar(Val(SubStr(Time(),7,2)) + Val(cBTempo))
 
            If (cBalanca == "JUNDIAI")
                //Enquanto os tempos forem diferentes
                While(cSegNor!=cSegAcr)
                    //Lendo os dados
                    msRead(nH,@cBuffer)
 
                    //Se não estiver em branco
                    if(!Empty(cBuffer))
                        cLido:=Alltrim(cBuffer)
                        //Exit
                    EndIf
 
                    //Atualizando o tempo
                    cSegNor:=SubStr(cSegNor,1,5)+":"+cValToChar(Val(SubStr(cSegNor,7,2)) + 1)
                EndDo
            //Senão, se for confiança, enquanto o tamanho for menor, ler o conteúdo
            ElseIf (cBalanca == "CONFIANCA")
                cLido := ''
                nCont := 1
                //Enquanto os tempos forem diferentes
                While(Len(cLido) < 16)
                    //Lendo os dados
                    msRead(nH,@cBuffer)
                    sleep(200)
 
                    //Somando o valor lido com o buffer
                    cLido+=cBuffer
 
                    //Aumentando o contador
                    nCont++
                    If nCont >= 30
                        If MsgYesNo('Houve <b>30 tentativas</b> de ler o peso, deseja parar?','Atenção')
                            cLido:=Space(17)
                            Exit
                        Else
                            nCont := 1
                        EndIf
                    EndIf
 
                EndDo
            EndIf
 
            //Se for a Jundiai
            If (cBalanca == "JUNDIAI")
                SoPeso2(@cLido)
            ElseIf (cBalanca == "CONFIANCA")
                SoPeso(@cLido)
                //Alert(cLido)
            EndIf
 
            //Se estiver em branco, retorna erro
            If Empty(cLido)
                cLido="ERRO NA LEITURA"
            EndIf
 
            cLido:=StrTran(cLido,',','.')
 
            //Se o retorno for numérico
            If cTipoVar == 'N'
                cLido  := Val(cLido)
            Else
                __nVal := Val(cLido)
                cLido  := cValToChar(__nVal)
            EndIf
            cLido := Int(cLido)
        ElseIf (cBalanca == "TOLEDO")
            For nX := 1 To 50
                Sleep(100)
                MSRead(nH,@cBuffer)
                //If(!Empty(cBuffer))
                If(Len(cBuffer) == 16)
                    cPeso += cValToChar(cBuffer)
                    Exit
                EndIf
            Next nX
            nPosIni := At("`",cPeso)
            nPosIni := nPosIni+2
            cPeso   := SubStr(cPeso,nPosIni,6)
 
            MSClosePort(nH,cCfg)
            If !Empty(cPeso)
                nPeso := Val(cPeso)/100
                nPeso := Round(nPeso,0)
                cLido := nPeso
            Else
                nPeso:=0
                cLido := nPeso
            EndIf
        EndIf
    EndIf
 
    msClosePort(nH,cCfg)
 
Return cLido
 
//Função que retorna somente o peso lido da String
Static Function SoPeso(cVar)
    Local nPosIni := 0
    Local nPosFim := 0
    Local nAux      := 0
 
    //Pegando a Posição Final, se tiver k minúsculo, será a posição, dele, senão o maiúsculo
    nPosFim:=Iif(('k' $ cVar),(At('k',cVar) - 1),(At('K',cVar) - 1))
 
    //Pegando a Posição Inicial
    For nAux:=1 To Len(cVar)
        //Se o caracter atual estiver contido no intervalo de 0 a 9 e ponto
        If(SubStr(cVar,nAux,1) $ '0123456789.')
            nPosIni:=nAux
            Exit
        EndIf
    Next
    //Pegando somente o valor
    cVar:=SubStr(cVar,nPosIni,nPosFim-nPosIni)
Return
 
//Função que retorna somente o peso lido da String
Static Function SoPeso2(cVar)
    Local nPosIni := 0
    Local nPosFim := 0
    Local nAux      := 0
 
    //Alert("'"+cVar+"'")
 
    //Pegando a Posição Final, se tiver k minúsculo, será a posição, dele, senão o maiúsculo
    nPosFim:=Iif(('k' $ cVar),(At('k',cVar) - 1),(At('K',cVar) - 1))
 
    //Pegando a Posição Inicial
    For nAux:=1 To Len(cVar)
        //Se o caracter atual estiver contido no intervalo de 0 a 9 e ponto
        If(SubStr(cVar,nAux,1) $ '0123456789.')
            nPosIni:=nAux
            Exit
        EndIf
    Next
 
    //Pegando somente o valor
    cVar:=SubStr(cVar,nPosIni,nPosFim-nPosIni+1)
    //Alert("'"+cVar+"'")
Return
*/
