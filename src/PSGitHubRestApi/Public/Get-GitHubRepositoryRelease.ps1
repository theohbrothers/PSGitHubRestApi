function Get-GitHubRepositoryRelease {
    [CmdletBinding(DefaultParameterSetName='Single')]
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
        [Parameter(ParameterSetName='Single', Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$ReleaseId
        ,
        [Parameter(ParameterSetName='All', Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [switch]$All
    )

    begin {
        $_apiEndpoint = 'https://api.github.com'
        if ($PSBoundParameters['ReleaseId']) {
            $_uri = "$_apiEndpoint/repos/$($PSBoundParameters['Namespace'])/$($PSBoundParameters['Repository'])/releases/$($PSBoundParameters['ReleaseId'])"
        }elseif ($PSBoundParameters['All']) {
            $_uri = "$_apiEndpoint/repos/$($PSBoundParameters['Namespace'])/$($PSBoundParameters['Repository'])/releases"
        }
        $_headers = @{
            Authorization = "token $($PSBoundParameters['ApiKey'])"
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
