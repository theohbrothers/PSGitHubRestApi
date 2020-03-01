function Edit-GitHubRepositoryRelease {
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
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$ReleaseId
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
        $_apiEndpoint = 'https://api.github.com'
        $_uri = "$_apiEndpoint/repos/$($Namespace)/$($Repository)/releases/$($ReleaseId)"
        $_headers = @{
            Authorization = "token $($ApiKey)"
        }
        if ($VerbosePreference -ne 'SilentlyContinue') {
            $_headersMasked = $_headers.Clone()
            $_headersMasked['Authorization'] = "token *******"
        }
        $_body = [Ordered]@{}
        if ($TagName) { $_body['tag_name'] = $TagName }
        if ($TargetCommitish) { $_body['target_commitish'] = $TargetCommitish }
        if ($Name) { $_body['name'] = $Name }
        if ($Body) { $_body['body'] = $Body }
        if ($null -ne $Draft) { $_body['draft'] = $Draft.ToString().ToLower() }
        if ($null -ne $Prerelease) { $_body['prerelease'] = $Prerelease.ToString().ToLower() }
        $_bodyJson = $_body | ConvertTo-Json -Depth 100
        "Uri: '$_uri'" | Write-Verbose
        "Headers:" | Write-Verbose
        if ($VerbosePreference -ne 'SilentlyContinue') {
            $_headersMasked | Out-String -Stream | % { $_.Trim() } | ? { $_ } | Write-Verbose
        }
        "Body:" | Write-Verbose
        $_body | Out-String -Stream | % { $_.Trim() } | ? { $_ } | Write-Verbose
        $_iwrArgs = @{
            Uri = $_uri
            Method = 'Post'
            Headers = $_headers
            Body = $_bodyJson
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
