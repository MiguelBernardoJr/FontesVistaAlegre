#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

/*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBMATERIAIS()          		              |
 | Func:  MBMATERIAIS	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  15.09.2020	            	          	            	              |
 | Desc:  Rotina para colocar informacoes de OBSERVAÇÃO, no processo de trans -   |
 |       ferencia;                                                                |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
 '--------------------------------------------------------------------------------*/
User Function MBMATERIAIS()
Return "MBMATERIAIS: " + MsDate()

/*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBMATERIAIS()          		              |
 | Func:  M310CABEC 	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  15.09.2020	            	          	            	              |
 | Desc:  Criar botão na rotina de transferencia;                                 |
 |                                                                                |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
 '--------------------------------------------------------------------------------*/
User Function M310CABEC

Local cProg  := PARAMIXB[1]
Local aCabec := PARAMIXB[2]
// Local aPar   := PARAMIXB[3]

    If cProg == 'MATA410'
        // If (__aMATA311[1] == NNS->NNS_COD)
            /*            
            RecLock("NSS", .F.)
                NNS->NNS_TRANSP  := __aMATA311[02]
                NNS->NNS_MENPAD  := __aMATA311[04]
                NNS->NNS_MENNOT  := __aMATA311[06]
            NSS->(MsUnLock())
            */

            aAdd(aCabec, {'C5_TRANSP' , NNS->NNS_TRANSP /*__aMATA311[02]*/, Nil})
            aAdd(aCabec, {'C5_MENPAD' , NNS->NNS_MENPAD  /*__aMATA311[04]*/, Nil})
            aAdd(aCabec, {'C5_MENNOTA', NNS->NNS_MENNOT /*__aMATA311[06]*/, Nil})
        // EndIf
    EndIf

Return(aCabec)


/*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBMATERIAIS()          		              |
 | Func:  MT311ROT  	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  15.09.2020	            	          	            	              |
 | Desc:  Criar botão na rotina de transferencia;                                 |
 |                                                                                |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
 '--------------------------------------------------------------------------------*/
// User Function MT311ROT()
// 
// Local aRet := PARAMIXB // Array contendo os botoes padroes da rotina.
// 
//     // Tratamento no array aRet para adicionar novos botoes e retorno do novo array.
//     ADD OPTION aRet TITLE  OemToAnsi("Copiar Transferência");
//                     ACTION "VIEWDEF.MATA311" OPERATION 9 ACCESS 0 // "Copiar"
// Return aRet


// User Function MATA311()
// Local aParam   := PARAMIXB
// Local oObj     := nil
// Local cIdPonto := '', cIdModel := ''
// Local xRet     := .T.
// 
// If aParam <> NIL      
// 	oObj       := aParam[1]
// 	cIdPonto   := aParam[2]
// 	cIdModel   := aParam[3]
// 	
//     //Valida a abertura da tela
// 	If cIdPonto == "MODELVLDACTIVE"
//         public __aMATA311 := iIf(ValType(__aMATA311)=="A", __aMATA311, {})
//         // _SetNamedPrvt('__aMATA311', {}, 'MATA311') 
//     
//     ElseIf cIdPonto == 'BUTTONBAR'
//         xRet := {}
// 		aAdd(xRet, {"Observação NF", "",;
//                      {|| U_FSTelaObs('TransfAuto', 'Observação para Transferência', 'Transferencia') },;
//                       ""/* "Tooltip 1" */})
//         /* BIBLIOTECA
//             https://github.com/dan-atilio/AdvPL/blob/master/Exemplos/V%C3%ADdeo%20Aulas/023%20-%20Pontos%20de%20Entrada%20em%20MVC/MATA070_pe.prw
//         */
//     EndIf
// EndIf
// 
// Return xRet
