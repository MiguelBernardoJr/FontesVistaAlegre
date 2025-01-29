#include 'protheus.ch'


User Function zTesFWE()
    Local cQuery as character
    Local cAlias as character
    local oExec as object
    
    cQuery := "SELECT ? FROM SE1010 WHERE E1_NUM = ? AND D_E_L_E_T_ = ?"
    cQuery := ChangeQuery(cQuery)
    oExec := FwExecStatement():New(cQuery)
    
    oExec:SetUnsafe(1,'E1_NUM')
    oExec:SetNumeric(2,0)
    oExec:SetString(3,' ')
    
    cAlias := oExec:OpenAlias()
    
    //Também existe o método ExecScalar para esta classe, que se comporta bem parecido com a
    //função FwExecScalar
    //cQuery := "SELECT COUNT(*) CNT FROM SE1T10 WHERE E1_FABOV = ? AND D_E_L_E_T_ = ?"
    //...........................
    //oExec:ExecScalar('CNT')
    
    (cAlias)->(DbCloseArea())
    oExec:Destroy()
    oExec := nil 
Return 
