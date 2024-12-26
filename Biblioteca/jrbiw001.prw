#include 'Protheus.ch'
#include 'APWebSrv.ch'

user function jrbiw001(); return nil

wsservice signa;
    description "<b>Serviço de administração de indicadores.</b><br/><br/>Esse serviço permite o cadastro e a comunicação dos dispositivos ao servidor de indicadores SIGNA.";
    // namespace "http://189.50.133.194:9092/signa.apw" // "https://wf.novauroramaquinas.com.br:9092/signa.apw"// "https://jrscatolon.dyndns-server.com/signa.apw"

    wsdata UserID   as String
    wsdata Password as String
    wsdata DeviceID as String
    wsdata Descript as String
    wsdata Version  as String
    wsdata WSreturn as String
    wsdata IDGCM    as String

    wsmethod GetKPIVersion  description "<b>Retorna a versão da última atualização dos indicadores.</b><br><br>Essa é uma rotina sincrona. Devem ser passados como parametro o ID do usuário e senha. O retorno é uma string contendo a versão da ultima atualizações para o dispositivo."
    wsmethod Login			description "<b>Realizar o Login do usuario no  sistema</b><br><br>Esta é uma rotina sincrona. Devem ser passados o ID do Usuario e senha. O retorno é uma 1 caso o usuario e senha seja localizado no banco de dados e 0 caso contrario."
    wsmethod AddDevice		description "<b>Adicionar um dispositivo no sistema caso nao exista, onde o mesmo é validado pelo codigo GCM.</b><br><br>Esta é uma rotina sincrona. Devem ser passados o ID do Usuario e senha e tambem o codigo GCM do dispositivo. O retorno é uma 1 caso o dispositivo tenha sido gravado com sucesso no banco de dados e 0 caso contrario."
    wsmethod DashBoard		description "<b>Busca o campo DashBoard no cadastro do usuario. [ZFU].</b><br><br>Esta é uma rotina sincrona. Devem ser passados o ID do Usuario e senha. O retorno é uma string com o caminho do DashBoard caso o usuario e senha seja localizado no banco de dados e 0 caso contrario. Se retornado vazio na string e' porque o caminho nao foi cadastrado."
    wsmethod Retaguarda		description "<b>Busca o campo Retaguarda no cadastro do usuario. [ZFU].</b><br><br>Esta é uma rotina sincrona. Devem ser passados o ID do Usuario e senha. O retorno é uma string com o caminho do Retaguarda caso o usuario e senha seja localizado no banco de dados e 0 caso contrario. Se retornado vazio na string e' porque o caminho nao foi cadastrado."
	
endwsservice

wsmethod GetKPIVersion wsreceive UserID, Password wssend WSreturn wsservice signa
    ::WSreturn := u_jrbiws01(UserID, Password)
return .t.

wsmethod AddDevice wsreceive UserID, Password, IDGCM, Descript wssend  WSreturn wsservice signa
    ::WSreturn := u_jrbiws02(UserID, Password, IDGCM, Descript) 
return .t.

wsmethod Login wsreceive UserID, Password wssend  WSreturn wsservice signa
    ::WSreturn := u_VlFtpUsr(UserID, Password)  // 0 = false; 1= true
return .t.

wsmethod DashBoard wsreceive UserID, Password wssend  WSreturn wsservice signa
    ::WSreturn := u_jrbiws03(UserID, Password)
return .t.

wsmethod Retaguarda wsreceive UserID, Password wssend  WSreturn wsservice signa
    ::WSreturn := u_jrbiws04(UserID, Password)
return .t.

