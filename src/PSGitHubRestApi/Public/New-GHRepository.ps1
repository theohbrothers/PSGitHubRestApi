function New-GHRepository {
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
        $apiEndpoint = 'https://api.github.com'
        $_uri = if ($PSBoundParameters['AccountType'] -eq 'User') {
                "$apiEndpoint/user/repos"
            }elseif ($PSBoundParameters['AccountType'] -eq 'Organization') {
                "$apiEndpoint/orgs/$($PSBoundParameters['Namespace'])/repos"
            }
        $_headers = @{
            Authorization = "token $($PSBoundParameters['ApiKey'])"
        }
        if ($VerbosePreference -ne 'SilentlyContinue') {
            $_headersMasked = $_headers.Clone()
            $_headersMasked['Authorization'] = "token *******"
        }
        $_body = [Ordered]@{
            name = $PSBoundParameters['Repository']
        }
        if ($PSBoundParameters['Description']) { $_body['description'] = $PSBoundParameters['Description'] }
        if ($PSBoundParameters['Homepage']) { $_body['homepage'] = $PSBoundParameters['Homepage'] }
        if ($PSBoundParameters['Private']) { $_body['private'] = $PSBoundParameters['Private'] }
        if ($PSBoundParameters['HasIssues']) { $_body['has_issues'] = $PSBoundParameters['HasIssues'] }
        if ($PSBoundParameters['HasProjects']) { $_body['has_projects'] = $PSBoundParameters['HasProjects'] }
        if ($PSBoundParameters['HasWiki']) { $_body['has_wiki'] = $PSBoundParameters['HasWiki'] }
        if ($PSBoundParameters['IsTemplate']) { $_body['is_template'] = $PSBoundParameters['IsTemplate'] }
        if ($PSBoundParameters['TeamId']) { $_body['team_id'] = $PSBoundParameters['TeamId'] }
        if ($PSBoundParameters['AutoInit']) { $_body['auto_init'] = $PSBoundParameters['AutoInit'] }
        if ($PSBoundParameters['GitignoreTemplate']) { $_body['gitignore_template'] = $PSBoundParameters['GitignoreTemplate'] }
        if ($PSBoundParameters['LicenseTemplate']) { $_body['license_template'] = $PSBoundParameters['LicenseTemplate'] }
        if ($PSBoundParameters['AllowSquashMerge']) { $_body['allow_squash_merge'] = $PSBoundParameters['AllowSquashMerge'] }
        if ($PSBoundParameters['AllowMergeCommit']) { $_body['allow_merge_commit'] = $PSBoundParameters['AllowMergeCommit'] }
        if ($PSBoundParameters['AllowRebaseMerge']) { $_body['allow_rebase_merge'] = $PSBoundParameters['AllowRebaseMerge'] }
        $_bodyJson = $_body | ConvertTo-Json -Depth 100
        "Uri: '$_uri'"| Write-Verbose
        "Headers:" | Write-Verbose
        ($_headersMasked | Out-String).Trim() | Write-Verbose
        "Body:" | Write-Verbose
        ($_body | Out-String).Trim() | Write-Verbose
    }process{
        try {
            "Invoking Web Request" | Write-Verbose
            $_response = Invoke-WebRequest -Uri $_uri -Method Post -Headers $_headers -Body $_bodyJson
        }catch {
            throw
        }
        $_response
    }
}
