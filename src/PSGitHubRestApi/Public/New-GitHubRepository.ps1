function New-GitHubRepository {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet('User','Organization')]
        [string]$AccountType
        ,
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
        [string]$Description
        ,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$Homepage
        ,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$Private
        ,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$HasIssues
        ,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$HasProjects
        ,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$HasWiki
        ,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$IsTemplate
        ,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$TeamId
        ,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$AutoInit
        ,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$GitignoreTemplate
        ,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$LicenseTemplate
        ,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$AllowSquashMerge
        ,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$AllowMergeCommit
        ,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$AllowRebaseMerge
    )

    begin {
        $_apiEndpoint = 'https://api.github.com'
        $_uri = if ($AccountType -eq 'User') {
                "$_apiEndpoint/user/repos"
            }elseif ($AccountType -eq 'Organization') {
                "$_apiEndpoint/orgs/$($Namespace)/repos"
            }
        $_headers = @{
            Authorization = "token $($ApiKey)"
        }
        if ($VerbosePreference -ne 'SilentlyContinue') {
            $_headersMasked = $_headers.Clone()
            $_headersMasked['Authorization'] = "token *******"
        }
        $_body = [Ordered]@{
            name = $Repository
        }
        if ($Description) { $_body['description'] = $Description }
        if ($Homepage) { $_body['homepage'] = $Homepage }
        if ($Private) { $_body['private'] = $Private }
        if ($HasIssues) { $_body['has_issues'] = $HasIssues }
        if ($HasProjects) { $_body['has_projects'] = $HasProjects }
        if ($HasWiki) { $_body['has_wiki'] = $HasWiki }
        if ($IsTemplate) { $_body['is_template'] = $IsTemplate }
        if ($TeamId) { $_body['team_id'] = $TeamId }
        if ($AutoInit) { $_body['auto_init'] = $AutoInit }
        if ($GitignoreTemplate) { $_body['gitignore_template'] = $GitignoreTemplate }
        if ($LicenseTemplate) { $_body['license_template'] = $LicenseTemplate }
        if ($AllowSquashMerge) { $_body['allow_squash_merge'] = $AllowSquashMerge }
        if ($AllowMergeCommit) { $_body['allow_merge_commit'] = $AllowMergeCommit }
        if ($AllowRebaseMerge) { $_body['allow_rebase_merge'] = $AllowRebaseMerge }
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
