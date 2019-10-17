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
        $apiEndpoint = 'https://api.github.com'
        if ($ReleaseId) {
            $_uri = "$apiEndpoint/repos/$($PSBoundParameters['Namespace'])/$($PSBoundParameters['Repository'])/releases/$($PSBoundParameters['ReleaseId'])"
        }elseif ($All) {
            $_uri = "$apiEndpoint/repos/$($PSBoundParameters['Namespace'])/$($PSBoundParameters['Repository'])/releases"
        }
        $_headers = @{
            Authorization = "token $($PSBoundParameters['ApiKey'])"
        }
        if ($VerbosePreference -ne 'SilentlyContinue') {
            $_headersMasked = $_headers.Clone()
            $_headersMasked['Authorization'] = "token *******"
        }
        "Uri: '$_uri'"| Write-Verbose
        "Headers:" | Write-Verbose
        ($_headersMasked | Out-String).Trim() | Write-Verbose
    }process{
        try {
            "Invoking Web Request" | Write-Verbose
            $_response = Invoke-WebRequest -Uri $_uri -Method Get -Headers $_headers -UseBasicParsing
        }catch {
            throw
        }
        $_response
    }
}
