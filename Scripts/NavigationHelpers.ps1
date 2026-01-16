# Quick Navigation Functions
# Shortcuts for common directory navigation

function Set-LocationHome {
    <#
    .SYNOPSIS
        Changes to the user's home directory
    .EXAMPLE
        Set-LocationHome
    #>
    Set-Location $env:USERPROFILE
}

function Set-LocationDocuments {
    <#
    .SYNOPSIS
        Changes to the user's Documents directory
    .EXAMPLE
        Set-LocationDocuments
    #>
    Set-Location ([Environment]::GetFolderPath("MyDocuments"))
}

function Set-LocationDownloads {
    <#
    .SYNOPSIS
        Changes to the user's Downloads directory
    .EXAMPLE
        Set-LocationDownloads
    #>
    $downloadsPath = Join-Path $env:USERPROFILE "Downloads"
    Set-Location $downloadsPath
}

function Set-LocationDesktop {
    <#
    .SYNOPSIS
        Changes to the user's Desktop directory
    .EXAMPLE
        Set-LocationDesktop
    #>
    Set-Location ([Environment]::GetFolderPath("Desktop"))
}

function Get-QuickPath {
    <#
    .SYNOPSIS
        Lists all quick navigation aliases
    .EXAMPLE
        Get-QuickPath
    #>
    Write-Host "Quick Navigation Aliases:" -ForegroundColor Green
    Write-Host "  home      - Navigate to user home directory" -ForegroundColor Cyan
    Write-Host "  docs      - Navigate to Documents folder" -ForegroundColor Cyan
    Write-Host "  downloads - Navigate to Downloads folder" -ForegroundColor Cyan
    Write-Host "  desktop   - Navigate to Desktop folder" -ForegroundColor Cyan
}

# Aliases for quick navigation
Set-Alias -Name home -Value Set-LocationHome
Set-Alias -Name docs -Value Set-LocationDocuments
Set-Alias -Name downloads -Value Set-LocationDownloads
Set-Alias -Name desktop -Value Set-LocationDesktop
