function New-GitHubRepositoryReleaseAsset {
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$UploadUrl
        ,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({Test-Path -Path $_ -PathType Leaf})]
        [string]$Asset
        ,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$ApiKey
    )

    begin {
        $_matchInfo = $PSBoundParameters['UploadUrl'].Trim() | Select-String -Pattern '(.+\/assets)($|{\?name,label})'
        $_uploadUrlProcessed = if ($_matchInfo) { $_matchInfo.Matches.Groups[1].Value } else { $PSBoundParameters['UploadUrl'] }
        $_assetItem = Get-Item -Path $PSBoundParameters['Asset'] -ErrorAction Stop

        $_uri = "$($_uploadUrlProcessed)?name=$($_assetItem.Name)"
        $_headers = @{
            Authorization = "token $($PSBoundParameters['ApiKey'])"
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
