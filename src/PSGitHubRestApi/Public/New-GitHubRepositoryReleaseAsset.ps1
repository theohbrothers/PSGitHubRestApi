function New-GitHubRepositoryReleaseAsset {
    [CmdletBinding(DefaultParameterSetName='ReleaseId')]
    param(
        [Parameter(ParameterSetName='ReleaseId', Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Namespace
        ,
        [Parameter(ParameterSetName='ReleaseId', Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Repository
        ,
        [Parameter(ParameterSetName='ReleaseId', Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$ReleaseId
        ,
        [Parameter(ParameterSetName='UploadUrl', Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$UploadUrl
        ,
        [Parameter(Mandatory=$true)]
        [ValidateScript({Test-Path -Path $_ -PathType Leaf})]
        [string]$Asset
        ,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$ApiKey
    )

    begin {
        if ($ReleaseId) {
            $_uploadUrlProcessed = "https://uploads.github.com/repos/$Namespace/$Repository/releases/$ReleaseId/assets"
        }elseif ($UploadUrl) {
            $_matchInfo = $UploadUrl.Trim() | Select-String -Pattern '(.+\/assets)($|{\?name,label})'
            $_uploadUrlProcessed = if ($_matchInfo) { $_matchInfo.Matches.Groups[1].Value } else { $UploadUrl }
        }
        $_assetItem = Get-Item -Path $Asset -ErrorAction Stop
        $_uri = "$($_uploadUrlProcessed)?name=$($_assetItem.Name)"
        $_headers = @{
            Authorization = "token $ApiKey"
            "Content-Type" = "application/octet-stream"
        }
        "Uri: '$_uri'" | Write-Verbose
        "Headers:" | Write-Verbose
        if ($VerbosePreference -ne 'SilentlyContinue') {
            $_headersMasked = $_headers.Clone()
            $_headersMasked['Authorization'] = "token *******"
            $_headersMasked | Out-String -Stream | % { $_.Trim() } | ? { $_ } | Write-Verbose
        }
        "InFile: '$($_assetItem.FullName)'" | Write-Verbose
        $_iwrArgs = @{
            Uri = $_uri
            Method = 'Post'
            Headers = $_headers
            InFile = $_assetItem.FullName
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
