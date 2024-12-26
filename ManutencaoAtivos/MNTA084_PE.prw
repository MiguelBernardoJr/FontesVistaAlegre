#Include "Protheus.ch"
#Include "Fwmvcdef.CH"

User Function MNTA084() //Função responsável pela chamda dos pontos de entrada da rotina MNTA084 - Veículos.
 
Local aParam   := PARAMIXB // Parâmetros passados pelo ponto de entrada.
Local lRet     := .T.// Retorno da função.
Local oObj     := '' // Objeto que receberá o modelo.
Local cIdPonto := '' // Identificador da chamada do ponto de entrada.
Local cIdModel := '' // Identificador do modelo utilizado.
Local cModel   := '' // Identifica o modelo utilizado e receberá o seu identificador.
Local cItemcta := ""
Local cCodBem  := ""
Local cPropri  := ""
 
    If aParam <> NIL // Identifica que foram enviado os parâmetros.
    
        oObj     := aParam[1] // Modelo ativado.
        cIdPonto := aParam[2] // Determina o ponto de chamada.
        cIdModel := aParam[3] // Identificador do modelo.
 
        If cIdPonto == 'MODELPOS' //Novo modelo para chamada do ponto de entrada MNTA0841
 
            oModel := oObj:GetModel('MNTA084_ST9') // Posiciona no Model
            If oModel:GetOperation() != MODEL_OPERATION_DELETE // Valida apenas se não for deleção
 
                cCodBem := oModel:GetValue('T9_CODBEM')
                cPropri := oModel:GetValue('T9_PROPRIE')
                If "TERCEIRO" $ Upper(cCodBem) .and. cProPri == "1"
                    Help(NIL, NIL, "Atenção", NIL, "Este veículo está cadastrado com nome TERCEIRO, porém o Proprietário T9_PROPRIE está com conteúdo 1-Próprio!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Favor corrigir o cadastro do veículo!"})
					lRet := .f.
                EndIf

                cItemcta := oModel:GetValue('T9_ITEMCTA')
                iF Empty(cItemcta)
                    Help(NIL, NIL, "Atenção", NIL, "Deve-se vincular um item contábil para um veículo", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Favor corrigir o cadastro do veículo!"})
                    lRet := .f.
                EndIf
 
            EndIf
 
        EndIf

    EndIf
 
Return lRet //Retorno do ponto de entrada.



/*

If aParam <> NIL // Identifica que foram enviado os parâmetros.
    oObj     := aParam[1] // Modelo ativado.
    cIdPonto := aParam[2] // Determina o ponto de chamada.
    cIdModel := aParam[3] // Identificador do modelo.
 
    If cIdPonto == 'MODELPOS' //Novo modelo para chamada do ponto de entrada MNTA0841
 
        oST9 := MntPneu():New // Inicializa classe
        oST9:ModelToClass( oObj ) // Carrega a classe com modelo de dados
        xRet := oST9:Valid() // Executa validação final
        oST9:ShowHelp() // Se houver, apresenta erro
 
    ElseIf cIdPonto == 'MODELCOMMITTTS' //Novo modelo para chamada do ponto de entrada MNTA0842.
 
        If !Empty(oObj:GetValue('T9_CODBEM'))
            MsgInfo("Ponto de entrada 'MNTA084' executado com sucesso! Codigo do bem: " + oObj:GetValue('T9_CODBEM'))
            xRet := .T.
        EndIf
 
    EndIf
EndIf
 
Return xRet //Retorno do ponto de entrada.

*/
