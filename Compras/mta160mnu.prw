#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} u_mta160mnu()
    Ponto de Entrada localizado na Análise de Cotações na função MenuDef(). 
    Permite adicionar botões ao menu.Os botões adcionais, devem ser carregados na variável 
    aRotina, que conterá as opções atuais e as novas opções adicionadas.
    Adiciona a função u_vacomr05 para o menu da rotna mata160.
/*/
user function mta160mnu()
    AAdd(aRotina, { "Exporta Excel", "u_vacomr05", 0 , 6, 0, .f.})
return nil