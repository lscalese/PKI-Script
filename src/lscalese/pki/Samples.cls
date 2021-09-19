/// 
Class lscalese.pki.Samples
{

/// Configure this instance as Authority server with minimal requirement.
ClassMethod ConfigureServer() As %Status
{
    Set sc = ##class(lscalese.pki.Server).MinimalServerConfig("$server_password$", "US", "CASrv", 365)
    Return sc
}

/// Configure a client on this instance
/// 
ClassMethod ConfigureClient() As %Status
{
    Set sc = ##class(lscalese.pki.Client).MinimalClientConfig("iris:52773","Contact Name",.out)
    Return sc
}

/// If you need to auto accept request from an hostname for a period you can use
/// Job ##class(lscalese.pki.Server).SignAllRequestWhile("$server_password$",900,"<hostname>")
/// Could be useful to avoid manual validation with configuration script.
ClassMethod AutoAcceptRequest() As %Status
{
    Write !, "Auto accept all certificate request during 900 seconds for the hostname iris (ctrl+c to abort)."
    Do ##class(lscalese.pki.Server).SignAllRequestWhile("$server_password$",900,"iris")
    Quit $$$OK
}

ClassMethod RequestCertificate() As %Status
{
    Set sc = ##class(lscalese.pki.Client).RequestCertificate("$private_key$","US",,$Piece($system,":",1)_"_client_"_$tr($zdt($h,8),": "))
    Return sc
}

ClassMethod WaitSigning()
{
    Set sc = ##class(lscalese.pki.Client).WaitSigning(,,.number)
}

ClassMethod ClientScript() As %Status
{
    ; Do ##class(lscalese.pki.Samples).ClientScript()
    Write !, " * Configure client "
    Set sc = ##class(lscalese.pki.Client).MinimalClientConfig("iris:52773","Contact Name")
    Quit:'sc sc
    Write !, " * Request certificate "
    Set sc = ##class(lscalese.pki.Client).RequestCertificate("$private_key$","US",,##class(lscalese.pki.Client).GenerateFilename())
    Quit:'sc sc
    Write !, " * Wait signing "
    Set sc = ##class(lscalese.pki.Client).WaitSigning(,,.number)
    Quit:'sc sc
    Write !, " * Get requested certificate "
    Set sc = ##class(lscalese.pki.Client).GetRequestedCertificate(number)
    Return sc
}

ClassMethod ServerScript() As %Status
{
    Set sc = ##class(lscalese.pki.Server).MinimalServerConfig("$server_password$", "US", "CASrv", 365)
    Quit:'sc sc
    Write !, "Auto accept all requested certificate during 900 seconds from the iris hostname.  Jobnumber : "
    Job ##class(lscalese.pki.Server).SignAllRequestWhile("$server_password$",900,"iris")
    Write $ZChild
    Return sc
}

}
