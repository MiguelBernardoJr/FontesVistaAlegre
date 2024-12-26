#include "RWMake.ch"
#include "Protheus.ch"
#include "TopConn.ch"


// User Function M200REVI()
//     
//     ConOut("M200REVI")
// Return nil

user function P200GRAV()

    Local nIndex  := 0
    Local aRecnos := PARAMIXB[2]

    // LOCAL oView := FwViewActive()
    // Local oModel   := FwModelActive()
    // Local oModelAux := FWLoadModel("PCPA200")
	// Local oModelCab := oModelAux:GetModel("SG1_MASTER")
    // Local cProduto := oModel:GetModel("SG1_MASTER"):GetValue("G1_COD")
    // Local __nEnerg := oModel:GetModel():GetModel("SG1_MASTER"):GetValue("NENERGIA")

    // se NAO for inclusão ou alteração e houve alguma operação com registro da SG1,
    // SAI do PE
    if !(ParamIXB[1] == 3 .or. ParamIXB[1] == 4) // .and. !Empty(ParamIXB[4])
        Return
    EndIf
    


    For nIndex := 1 to Len(aRecnos)
        // If aRecnos[nIndex][1] == 3
        //     ConOut("Operação de inclusão realizada no recno " + CValToChar(aRecnos[nIndex][2]))
        // ElseIf aRecnos[nIndex][1] == 4
        //     ConOut("Operação de alteração realizada no recno " + CValToChar(aRecnos[nIndex][2]))
        // ElseIf aRecnos[nIndex][1] == 5
        //     ConOut("Operação de exclusão realizada no recno " + CValToChar(aRecnos[nIndex][2]))
        // EndIf

        If aRecnos[nIndex][1] == 5
            loop
        EndIf

        PEA200GRVE( aRecnos[nIndex][2] )
    Next

return nil


Static Function PEA200GRVE( nRecnoSG1 )

    Local aAreaSG1 := SG1->(GetArea())
    local cTime := ""
    local cSeq  := ""
    Local oMdlDad := nil

    Local oModel    := FwModelActive()
    Local oModelAux := FWLoadModel("PCPA200")
	Local oModelCab := oModelAux:GetModel("SG1_MASTER")
    //Local cProduto  := oModel:GetModel("SG1_MASTER"):GetValue("G1_COD")
    //Local __nEnerg  := oModel:GetModel():GetModel("SG1_MASTER"):GetValue("NENERGIA")

    SG1->(DbGoTo(  nRecnoSG1 ))        

    begin transaction
        
        // Calcula nova sequência
        cSeq := u_NextSeq("G1_SEQ")

        // Atualiza campo sequência da estrutura
        TCSqlExec("UPDATE " + RetSqlName("SG1") +;
                    " SET " +; // G1_ENERG = " + AllTrim(Str(G1_ENERG)) + ", " +;
                        "G1_SEQ = '" + cSeq + "'" +;
                    " WHERE G1_FILIAL = '" + FWxFilial("SG1") + "'" +;
                    " AND G1_COD = '" + SG1->G1_COD + "'" +;
                    " AND D_E_L_E_T_ = ' '" ;
                    )
        
        // Cria historico da estrutura
        DbUseArea(.t., "TOPCONN", TCGenQry(,,;
                                " SELECT G1_FILIAL, G1_COD, G1_COMP, G1_TRT, G1_QUANT, G1_PERDA, G1_INI, G1_FIM, G1_OBSERV, G1_FIXVAR, G1_GROPC"+;
                                        ", G1_OPC, G1_REVINI, G1_REVFIM, G1_NIV, G1_NIVINV, G1_POTENCI, G1_VECTOR, G1_OK, G1_TIPVEC, G1_VLCOMPE"+;
                                        ", G1_ENERG, G1_SEQ, G1_ORIGEM " +;
                                    " FROM " + RetSqlName("SG1") + " SG1" +;
                                " WHERE SG1.G1_FILIAL = '" + FWxFilial("SG1") + "'" +;
                                    " AND SG1.G1_COD = '" + SG1->G1_COD + "'" +;
                                    " AND SG1.G1_SEQ = '" + cSeq + "'" +;
                                    " AND SG1.D_E_L_E_T_ = ''" ;
                                            ), "TMPSG1", .f., .t.) 

            cTime := Time()
            while !TMPSG1->(Eof())
                RecLock("ZG1", .t.)
                    ZG1->ZG1_FILIAL := TMPSG1->G1_FILIAL
                    ZG1->ZG1_COD    := TMPSG1->G1_COD
                    ZG1->ZG1_COMP   := TMPSG1->G1_COMP
                    ZG1->ZG1_TRT    := TMPSG1->G1_TRT
                    ZG1->ZG1_QUANT  := TMPSG1->G1_QUANT
                    ZG1->ZG1_PERDA  := TMPSG1->G1_PERDA
                    ZG1->ZG1_INI    := SToD(TMPSG1->G1_INI)
                    ZG1->ZG1_FIM    := SToD(TMPSG1->G1_FIM)
                    ZG1->ZG1_OBSERV := TMPSG1->G1_OBSERV
                    ZG1->ZG1_FIXVAR := TMPSG1->G1_FIXVAR
                    ZG1->ZG1_GROPC  := TMPSG1->G1_GROPC
                    ZG1->ZG1_OPC    := TMPSG1->G1_OPC
                    ZG1->ZG1_REVINI := TMPSG1->G1_REVINI
                    ZG1->ZG1_REVFIM := TMPSG1->G1_REVFIM
                    ZG1->ZG1_NIV    := TMPSG1->G1_NIV
                    ZG1->ZG1_NIVINV := TMPSG1->G1_NIVINV
                    ZG1->ZG1_POTENC := TMPSG1->G1_POTENCI
                    ZG1->ZG1_VECTOR := TMPSG1->G1_VECTOR
                    ZG1->ZG1_OK     := TMPSG1->G1_OK
                    ZG1->ZG1_TIPVEC := TMPSG1->G1_TIPVEC
                    ZG1->ZG1_VLCOMP := TMPSG1->G1_VLCOMPE
                    ZG1->ZG1_ENERGI := TMPSG1->G1_ENERG
                    ZG1->ZG1_SEQ    := TMPSG1->G1_SEQ
                    ZG1->ZG1_ORIGEM := TMPSG1->G1_ORIGEM
                    /*ARTHURTOSHIO*/
                    ZG1->ZG1_DTALT  := Date()
                    ZG1->ZG1_HRALT  := cTime
                    ZG1->ZG1_CODUSU :=  __cUserId
                MsUnlock()
                TMPSG1->(DbSkip())
            end
        TMPSG1->(DbCloseArea())
    end transaction

    RestArea(aAreaSG1)
Return

User Function PCPA200()
    Local aParam 		:= PARAMIXB
	Local xRet 			:= .T.
	Local cIdPonto 		:= ''
	Local cIdModel 		:= ''
	Local cIdIXB5		:= ''
	Local cIdIXB4		:= ''
	Local oModel 	 	:= nil
	Local oMdlDad		:= nil
	Local oMdlGrid 		:= nil
    Local nI, nLines, nEnerg
	Local aSaveLines 	:= FWSaveRows()

    If aParam <> NIL
		oObj := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]

		if len(aParam) >= 4
			cIdIXB4  := aParam[4]
		endif 

		if len(aParam) >= 5
			cIdIXB5  := aParam[5]
		endif 

		if Alltrim(cIdPonto) == "FORMPOS" .and. cIdModel == 'SG1_MASTER' //.AND. cIdIXB5 == 'CANSETVALUE' .AND. AllTrim(cIdIXB4) == 'ZMS_QTDE'
			oModel 	 	:= FwModelActivate()
			oMdlDad     := oModel:GetModel("SG1_MASTER")
			oMdlGrid    := oModel:GetModel("SG1_DETAIL")

            nEnerg := oMdlDad:GetValue("G1_ENERG")

            nLines := oMdlGrid:GetQtdLine()    

            For nI := 1 to nLines
                oMdlGrid:GoLine(nI)
                oMdlGrid:LoadValue("G1_ENERG",nEnerg)
            Next nI 

		endif
	endif 
	FWRestRows( aSaveLines )

Return xRet
