function New-GitHubRepositoryRelease {
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
        [string]$TagName
        ,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$TargetCommitish
        ,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
        ,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$Body
        ,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [bool]$Draft
        ,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [bool]$Prerelease
    )

    begin {
        $apiEndpoint = 'https://api.github.com'
        $_uri = "$apiEndpoint/repos/$($PSBoundParameters['Namespace'])/$($PSBoundParameters['Repository'])/releases"
        $_headers = @{
            Authorization = "token $($PSBoundParameters['ApiKey'])"
        }
        if ($VerbosePreference -ne 'SilentlyContinue') {
            $_headersMasked = $_headers.Clone()
            $_headersMasked['Authorization'] = "token *******"
        }
        $_body = [Ordered]@{}
        if ($PSBoundParameters['TagName']) { $_body['tag_name'] = $PSBoundParameters['TagName'] }
        if ($PSBoundParameters['TargetCommitish']) { $_body['target_commitish'] = $PSBoundParameters['TargetCommitish'] }
        if ($PSBoundParameters['Name']) { $_body['name'] = $PSBoundParameters['Name'] }
        if ($PSBoundParameters['Body']) { $_body['body'] = $PSBoundParameters['Body'] }
        if ($PSBoundParameters['Draft']) { $_body['draft'] = $PSBoundParameters['Draft'] }
        if ($PSBoundParameters['Prerelease']) { $_body['prerelease'] = $PSBoundParameters['Prerelease'] }
        $_bodyJson = $_body | ConvertTo-Json -Depth 100
        "Uri: '$_uri'" | Write-Verbose
        "Headers:" | Write-Verbose
        $_headersMasked | Out-String -Stream | % { $_.Trim() } | ? { $_ } | Write-Verbose
        "Body:" | Write-Verbose
        $_body | Out-String -Stream | % { $_.Trim() } | ? { $_ } | Write-Verbose
    }process{
        try {
            "Invoking Web Request" | Write-Verbose
            $_response = Invoke-WebRequest -Uri $_uri -Method Post -Headers $_headers -Body $_bodyJson -UseBasicParsing
        }catch {
            throw
        }
        $_response
    }
}
