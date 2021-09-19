/// Description
Class lscalese.pki.Client
{

Parameter CLIENTID = "IRIS CA";

Parameter WOUT = 1;

Parameter DEFAULTPK = "$private_key$";

/// Minimal config for PKI.CAClient
/// server : DNS hostname used to access the PKI.CAServer Web service 
/// contactName : Name of the local technical contact for this Certificate Authority client.
/// Set sc = ##class(lscalese.pki.Client).MinimalClientConfig("iris:52773","Lorenzo Scalese",.out)
/// Write !,out
ClassMethod MinimalClientConfig(server As %String = "caserver:52773", contactName As %String = "Contact Person", ByRef out As %String) As %Status
{
    Set oldNs = $NAMESPACE
    new $NAMESPACE
    Set $namespace = "%SYS"

    If ##class(PKI.CAClient).%ExistsId(..#CLIENTID) {
        Set client = ##class(PKI.CAClient).%OpenId(..#CLIENTID)
    } Else {
        Set client = ##class(PKI.CAClient).%New()
    }
    
    Set client.Server = $Piece(server,":",1)
    Set client.Port = $Piece(server,":",2)
    Set client.ContactName = contactName

    Set out = ##class(PKI.CAClient).Configure(client, .sc)
    Return:$$$ISERR(sc) sc

    Set $NAMESPACE = oldNs
    Set sc =..GetRequestedCertificate()

    Return sc
}

/// Request a certificate with minimal information
/// Set sc = ##class(lscalese.pki.Client).RequestCertificate()
ClassMethod RequestCertificate(privateKeyPassword As %String = {..#DEFAULTPK}, country As %String = "US", sn As %String = {$Piece($system,":",1)}, filename As %String = {..GetDefaultFilename()}, ByRef out As %String = "") As %Status
{
    new $NAMESPACE
    Set $namespace = "%SYS"
    Set attr = $lb(country,,,,,sn)
    Set client = ##class(PKI.CAClient).%OpenId(..#CLIENTID)
    Set out = client.SubmitCSR(filename,attr,privateKeyPassword,.sc)
    Write:..#WOUT !,out
    Do:$$$ISOK(sc) ..SetLastRequestedFilename(filename)
    Return sc
}

ClassMethod GetRequestedCertificate(number As %Integer = 0, ByRef out As %String = "") As %Status
{
    ; Set sc = ##class(lscalese.pki.Client).GetRequestedCertificate()
    New $NAMESPACE
    Set $NAMESPACE = "%SYS"

    Set client = ##class(PKI.CAClient).%OpenId(..#CLIENTID)
    Set out = client.GetCertificate(number, .sc)
    Write:..#WOUT !,out
    Return sc
}

/// Set sc = ##class(lscalese.pki.Client).GetRequestedCertificateNumber()
ClassMethod GetRequestedCertificateNumber(filename As %String = {sn_"_client"}, ByRef sc As %Status = {$$$OK}) As %Integer
{
    New $NAMESPACE
    Set $NAMESPACE = "%SYS"
    Set sc = $$$OK
    Set instance = $Piece($system,":",2)
    Set number = ""
    Set client = ##class(PKI.CAClient).%OpenId(..#CLIENTID)
    Set dataSet = client.ListCertificates($Piece($system,":",1),instance,.sc)

    Return:$$$ISERR(sc) sc
    Set number = ""
    While dataSet.%Next() {
        Set cFilename = dataSet.Get("Filename")
        If dataSet.Get("Filename") = filename {
            Set number = dataSet.Get("Number")
        }
    }

    Return number
}

ClassMethod GetLastRequestedCertificate(ByRef out As %String) As %Status
{
    ; Set sc = ##class(lscalese.pki.Client).GetLastRequestedCertificate()
    New $NAMESPACE
    Set $NAMESPACE = "%SYS"
    Set sc = $$$OK
    
    Set instance = $Piece($system,":",2)

    Set number = ..GetRequestedCertificateNumber($Get(^lscalese.pki("LastRequested")))

    If number '= "" {
        Set sc = ..GetRequestedCertificate(number,.out)
    } Else {
        Set out = "No certificate found (or not signed yet)."
        Set sc = $$$ERROR(5001,out)
        Write:..#WOUT !,out
    }

    Return sc
}

ClassMethod WaitSigning(timeout As %Integer = 120, filename As %String = {..GetLastRequestedFilename()}, ByRef number As %Integer) As %Status
{
    Set sc = $$$OK
    Set end = $ZHOROLOG + timeout
    While $ZHOROLOG < end {
        Set number = ..GetRequestedCertificateNumber(filename,.sc)
        Quit:number'=""
        Quit:number'=""||$$$ISERR(sc)
        Hang 3
    }
    Return sc
}

ClassMethod GetLastRequestedFilename() As %String
{
    Return $Get(^["%SYS"]lscalese.pki("LastRequested"))
}

ClassMethod SetLastRequestedFilename(filename As %String) As %Status
{
    Set ^["%SYS"]lscalese.pki("LastRequested") = filename
    Return $$$OK
}

ClassMethod GenerateFilename() As %String [ CodeMode = expression ]
{
$Piece($system,":",1)_"_client_"_$tr($zdt($h,8),": ","")
}

ClassMethod GetDefaultFilename() As %String [ CodeMode = expression ]
{
$Piece($system,":",1)_"_client"
}

}
