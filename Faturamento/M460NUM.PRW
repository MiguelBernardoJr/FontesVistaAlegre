ser Function M460NUM()

    If Type("_cProcNF") <> "U"
        cNumero := PadL(_cProcNF, Len(SF2->F2_DOC), "0")
    EndIf

Return()
