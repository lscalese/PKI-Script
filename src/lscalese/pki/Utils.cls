/// 
Class lscalese.pki.Utils
{

/// Helper to config mirror
/// Master is PKI server
/// Configure this local instance as PKI Server.
/// Configure this local instance as PKI Client.
/// Request a certificate for this local IRIS instance.
/// Accept all certificate request from a list of hosts while 1 hour
/// Set sc = ##class(lscalese.pki.Utils).MirrorMaster()
/// ServerPassword : Password of the PKI Server ...
/// PrivateKey : private key for the local certificate.
/// Contact : Name of the contact person.
/// Attributes : Listbuild with certificate attribute
/// day : certificate validity in day
/// AcceptAllRequest : PKI Server accept all requested certificate while 1 hour the comma separated list of hostname (or "*" to accept all).
ClassMethod MirrorMaster(ServerPassword As %String = "$server_password$", PrivateKey As %String = "$private_key$", Contact As %String = "Contact Person", Attributes As %List = {$lb("US",,,,,$Piece($system,":",1))}, day As %Integer = 365, AcceptAllRequest As %String = "*") As %Status
{
    Set sc = $$$OK, ptr = 0
    
    While $LISTNEXT(Attributes, ptr, v) {
        Set:$Data(v) arr($i(arr)) = v
    }
    Set arr("Day") = day
    
    $$$QuitOnError(##class(lscalese.pki.Server).ConfigureServer(ServerPassword, .arr, .out))
    
    Set:AcceptAllRequest'="*" AcceptAllRequest = $Piece($system,":",1) _ "," _AcceptAllRequest
    
    Job ##class(lscalese.pki.Server).SignAllRequestWhile(ServerPassword, 3600, AcceptAllRequest)

    Set Server  = $SYSTEM.INetInfo.LocalHostName()_":"_$Get(^%SYS("WebServer", "Port")) ; server is this local instance
    $$$QuitOnError(##class(lscalese.pki.Client).MinimalClientConfig(Server, Contact, .out))
    $$$QuitOnError(##class(lscalese.pki.Client).RequestCertificateByAttr(PrivateKey, Attributes))
    $$$QuitOnError(##class(lscalese.pki.Client).WaitSigning(,,.number))
    $$$QuitOnError(##class(lscalese.pki.Client).GetRequestedCertificate(number))
    
    Return sc
}

/// Helper to config mirror
/// Configure the PKI client on this instance.
/// Resquest a certificate to the PKI server.
/// Wait 120 seconds a certificate validation from the server.
/// Install the validate requested certificate.
/// Set sc = ##class(lscalese.pki.Utils).MirrorBackup("master:52773")
ClassMethod MirrorBackup(Server As %String, PrivateKey As %String = "$private_key$", Contact As %String = "Contact Person",Attributes As %List = {$lb("US",,,,,$Piece($system,":",1))}) As %Status
{
    Set sc = $$$OK

    $$$QuitOnError(##class(lscalese.pki.Client).MinimalClientConfig(Server,Contact))
    $$$QuitOnError(##class(lscalese.pki.Client).RequestCertificateByAttr(PrivateKey, Attributes))
    $$$QuitOnError(##class(lscalese.pki.Client).WaitSigning(,,.number))
    $$$QuitOnError(##class(lscalese.pki.Client).GetRequestedCertificate(number))

    Return sc
}

}
