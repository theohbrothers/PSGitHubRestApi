function Get-GitHubRepositoryRelease {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Namespace
        ,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Repository
        ,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$ApiKey
        ,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$ReleaseId
    )

    begin {
        $_apiEndpoint = 'https://api.github.com'
        if ($ReleaseId) {
            $_uri = "$_apiEndpoint/repos/$Namespace/$Repository/releases/$ReleaseId"
        }else {
            $_uri = "$_apiEndpoint/repos/$Namespace/$Repository/releases"
        }
        $_headers = @{
            Authorization = "token $ApiKey"
        }
        if ($VerbosePreference -ne 'SilentlyContinue') {
            $_headersMasked = $_headers.Clone()
            $_headersMasked['Authorization'] = "token *******"
        }
        "Uri: '$_uri'" | Write-Verbose
        "Headers:" | Write-Verbose
        if ($VerbosePreference -ne 'SilentlyContinue') {
            $_headersMasked | Out-String -Stream | % { $_.Trim() } | ? { $_ } | Write-Verbose
        }
        $_iwrArgs = @{
            Uri = $_uri
            Method = 'Get'
            Headers = $_headers
            UseBasicParsing = $true
        }
    }process {
        try {
            "Invoking Web Request" | Write-Verbose
            $_response = Invoke-WebRequest @_iwrArgs
        }catch {
            throw
        }
        $_response
    }
}
