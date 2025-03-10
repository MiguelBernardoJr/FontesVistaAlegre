/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TOICurFun �Autor  �Joeudo Santana      � Data �  09/04/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Retorna se o curso foi Realizado pelo Funcionario          ���
�������������������������������������������������������������������������͹��
���Uso       � Consulta Office TRM                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function TOICurFun (cCodCurs,cCodFunc) 
Local cQueryAlias	:=	GetNextAlias()
Local aArea			:=	GetArea()                   
Local cRetorno		:=	""                  

BeginSql Alias cQueryAlias				
	SELECT COUNT(RA4_CURSO)QUANT 
	FROM %table:RA4% RA4
	WHERE RA4_CURSO = %exp:cCodCurs%
	AND RA4_MAT = %exp:cCodFunc%
	AND RA4_FILIAL = %xFilial:RA4%
	AND RA4.%notDel%
EndSql	

Dbselectarea(cQueryAlias)

cRetorno:= If ((cQueryAlias)->QUANT > 0,"X","")
(cQueryAlias)->(DbCloseArea())

RestArea(aArea)  
Return cRetorno      

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TOIAvalia �Autor  �Joeudo Santana	     � Data �  09/04/07   ���
�������������������������������������������������������������������������͹��
���Desc.     � Retorna se a avaliacao foi realizada pelo funcionario      ���
�������������������������������������������������������������������������͹��
���Uso       � Consulta Office APD                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function TOIAvalia(cCodava,cCodAvado,cTipAval) 
Local cQueryAlias	:=	GetNextAlias()
Local aArea			:=	GetArea()                   
Local cRetorno		:=	""    
Local dData			:= cTod('//')

BeginSql Alias cQueryAlias	  
	SELECT COUNT(*) QUANT 
	FROM %table:RDC% RDC
	WHERE  RDC_CODAVA	= %exp:cCodava%
	AND RDC_CODADO = %exp:cCodAvado%
	AND RDC_TIPOAV = %exp:cTipAval%
	AND RDC_FILIAL = %xFilial:RDC%
	AND RDC.%notDel%    
	AND RDC_DATRET <> %exp:dData%
EndSql	

Dbselectarea(cQueryAlias)
cRetorno:= If ((cQueryAlias)->QUANT > 0,"X","")

(cQueryAlias)->(DbCloseArea()) 	

RestArea(aArea)                   
Return cRetorno                                                                  

