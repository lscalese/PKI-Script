/// Description
Class lscalese.pki.Server
{

Parameter SERVERID = "IRIS CA";

Parameter DFLTPASSWORD = "$server_password$";

Parameter WOUT = 1;

/// Set sc = ##class(lscalese.pki.Server).MinimalServerConfig()
ClassMethod MinimalServerConfig(serverPwd As %String = {..GetDefaultPassWord()}, countryCode As %String = "US", CN As %String = "CASrv", day As %Integer = 365) As %Status
{
    Set sc = $$$OK
    Set attribute(1)=countryCode
    Set attribute(6)=CN
    Set attribute("Day")= day
    Return ..ConfigureServer(serverPwd,.attribute)
}

/// configure the PKI Server
/// serverPwd : serveur certificate password, default : "server_password" (first invocation only)
/// attribute : array
///     1 : country, default: "US"
///     6 : CN, default: "CASrv"
///     CAFilename : Server certificate filename, default "CA_Server"
///     CAPath : Server certificate path, default $zu(12,"CAServer")
ClassMethod ConfigureServer(serverPwd As %String = {..GetDefaultPassWord()}, ByRef attribute As %Binary, ByRef out As %String) As %Status
{
    new $NAMESPACE
    Set $NAMESPACE = "%SYS"

    Set $List(attr,1)=$Get(attribute(1),"US")
    Set:$Data(attribute(2)) $List(attr,2)=$Get(attribute(2))
    Set:$Data(attribute(3)) $List(attr,3)=$Get(attribute(3))
    Set:$Data(attribute(4)) $List(attr,4)=$Get(attribute(4))
    Set:$Data(attribute(5)) $List(attr,5)=$Get(attribute(5))
    Set $List(attr,6)=$Get(attribute(6),"CASrv")
    
    If ##class(PKI.CAServer).%ExistsId(..#SERVERID) {
        Set serv = ##class(PKI.CAServer).%OpenId(..#SERVERID)
    } Else {
        Set serv = ##class(PKI.CAServer).%New()
    }

    Set serv.CAFilename = $Get(attribute("CAFilename"),"CA_Server")
    set serv.CAPath = $Get(attribute("CAPath"),$zu(12,"CAServer"))

    Set:$Data(attribute("SMTPPassword")) serv.SMTPPassword = attribute("SMTPPassword")
    Set:$Data(attribute("SMTPServer")) serv.SMTPServer = attribute("SMTPServer")
    Set:$Data(attribute("SMTPUsername")) serv.SMTPUsername = attribute("SMTPUsername")
    Set:$Data(attribute("AdminEmail")) serv.AdminEmail = attribute("AdminEmail")

    Set out = ##class(PKI.CAServer).Configure(serv, attr, serverPwd, $Get(attribute("Day"),365), .sc)
    Write:..#WOUT !,out
    Return sc
}

ClassMethod SignRequest(serverPwd As %String = {..GetDefaultPassWord()}, requestId As %String, ByRef out As %String) As %Status
{
    new $NAMESPACE
    Set $NAMESPACE = "%SYS"
    Set serv = ##class(PKI.CAServer).%OpenId(..#SERVERID)
    Set out = serv.Sign(requestId, serverPwd, 1, .sc)
    Write:..#WOUT !,out
    Return sc
}

ClassMethod SignAllRequest(serverPwd As %String = {..GetDefaultPassWord()}, ByRef out As %String, host As %String = "*") As %Status
{
    new $NAMESPACE
    Set $namespace = "%SYS"
    Set key = "", sc = $$$OK, out = "", lowerHost = $$$LOWER(host), lbHosts = $ListFromString(lowerHost,",")

    For  {
        Set key = $Order(^PKI.CSRD(key)), scR = $$$OK, currentHost = $$$LOWER($Piece(key,":",1))
        Quit:key=""
        If (host="*") || (''$ListFind(lbHosts,currentHost)) {
            Set scR = ..SignRequest(serverPwd,key,.cOut)
            Set out = out _ cOut
            Set:$$$ISERR(scR) sc = $$$ADDSC(sc,scR)
        }
    }
    Write:..#WOUT !,out
    Return sc
}

ClassMethod SignAllRequestWhile(serverPwd As %String = {..GetDefaultPassWord()}, timeInSecond As %Integer = 900, host As %String = "*") As %Status
{
    ;Job ##class(lscalese.pki.Server).SignAllRequestWhile("server_password",900,"*")
    Set end = $zh+timeInSecond
    While $zh < end {
        Set out = ""
        Do ..SignAllRequest(serverPwd,.out,host)
        Write !,out
        Hang 3
    }
    Return $$$OK
}

ClassMethod GetDefaultPassWord() As %String
{
    Return ..#DFLTPASSWORD
}

}
