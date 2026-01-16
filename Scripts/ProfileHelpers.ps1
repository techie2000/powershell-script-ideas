# Profile Helper Functions
# Utilities for managing and discovering available profile functions

function Get-ProfileFunctions {
    <#
    .SYNOPSIS
        Lists all custom functions loaded by the PowerShell profile
    .DESCRIPTION
        Displays custom functions from the Scripts folder with optional details
        including synopsis and aliases
    .PARAMETER ShowSynopsis
        Include the synopsis (short description) for each function
    .PARAMETER ShowAliases
        Include aliases for each function
    .PARAMETER Detailed
        Show both synopsis and aliases
    .EXAMPLE
        Get-ProfileFunctions
        # Lists function names only
    .EXAMPLE
        Get-ProfileFunctions -ShowSynopsis
        # Lists functions with their synopsis
    .EXAMPLE
        Get-ProfileFunctions -ShowAliases
        # Lists functions with their aliases
    .EXAMPLE
        Get-ProfileFunctions -Detailed
        # Lists functions with synopsis and aliases
    #>
    [CmdletBinding()]
    param(
        [Alias('s')]
        [switch]$ShowSynopsis,
        
        [Alias('a')]
        [switch]$ShowAliases,
        
        [Alias('d')]
        [switch]$Detailed
    )
    
    # If Detailed is specified, show both synopsis and aliases
    if ($Detailed) {
        $ShowSynopsis = $true
        $ShowAliases = $true
    }
    
    # Get all functions from our custom scripts
    # Exclude built-in and module functions by filtering on Source
    $customFunctions = Get-Command -CommandType Function | Where-Object { 
        $_.Source -eq '' -and 
        $_.Name -like 'Get-*' -or $_.Name -like 'Set-*' -or 
        $_.Name -like 'New-*' -or $_.Name -like 'Remove-*' -or
        $_.Name -like 'Invoke-*' -or $_.Name -like 'Test-*'
    } | Where-Object {
        # Further filter to only include our custom functions
        $helpContent = Get-Help $_.Name -ErrorAction SilentlyContinue
        $helpContent -and $helpContent.Synopsis -notlike '*Get-Help*'
    }
    
    if ($customFunctions) {
        $results = foreach ($func in $customFunctions) {
            $obj = [PSCustomObject]@{
                Name = $func.Name
            }
            
            if ($ShowSynopsis) {
                $help = Get-Help $func.Name -ErrorAction SilentlyContinue
                $synopsis = if ($help.Synopsis) { 
                    $help.Synopsis.Trim()
                } else { 
                    "No synopsis available" 
                }
                $obj | Add-Member -NotePropertyName Synopsis -NotePropertyValue $synopsis
            }
            
            if ($ShowAliases) {
                $aliases = Get-Alias | Where-Object { $_.Definition -eq $func.Name } | 
                           Select-Object -ExpandProperty Name
                $aliasString = if ($aliases) { 
                    ($aliases -join ', ') 
                } else { 
                    "None" 
                }
                $obj | Add-Member -NotePropertyName Aliases -NotePropertyValue $aliasString
            }
            
            $obj
        }
        
        Write-Host "`nCustom Profile Functions:" -ForegroundColor Green
        Write-Host ("=" * 80) -ForegroundColor Green
        
        if ($ShowSynopsis -or $ShowAliases) {
            $results | Format-List
        } else {
            $results | Format-Table -AutoSize
        }
        
        Write-Host "`nTotal functions: $($results.Count)" -ForegroundColor Cyan
    } else {
        Write-Host "No custom functions found." -ForegroundColor Yellow
    }
}

function Show-ProfileHelp {
    <#
    .SYNOPSIS
        Displays help information for using the PowerShell profile
    .DESCRIPTION
        Shows a quick reference guide for all custom functions and aliases
    .EXAMPLE
        Show-ProfileHelp
    #>
    [CmdletBinding()]
    param()
    
    Write-Host "`n=== PowerShell Profile Quick Reference ===" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "File Helpers:" -ForegroundColor Cyan
    Write-Host "  Get-DirectorySize      Calculate directory sizes" -ForegroundColor White
    Write-Host "    Aliases: dirsize, getdirsize, gds" -ForegroundColor Gray
    Write-Host "  Get-LargeFiles         Find large files with filtering" -ForegroundColor White
    Write-Host "    Aliases: largefiles, getlargefiles, glf" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "System Info:" -ForegroundColor Cyan
    Write-Host "  Get-SystemInfo         Display system information" -ForegroundColor White
    Write-Host "    Alias: sysinfo" -ForegroundColor Gray
    Write-Host "  Get-DiskSpace          Show disk space usage" -ForegroundColor White
    Write-Host "    Alias: diskspace" -ForegroundColor Gray
    Write-Host "  Get-NetworkAdapters    Display network configuration" -ForegroundColor White
    Write-Host "    Alias: netadapters" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "Navigation:" -ForegroundColor Cyan
    Write-Host "  Set-LocationHome       Navigate to home directory" -ForegroundColor White
    Write-Host "    Alias: home" -ForegroundColor Gray
    Write-Host "  Set-LocationDocuments  Navigate to Documents" -ForegroundColor White
    Write-Host "    Alias: docs" -ForegroundColor Gray
    Write-Host "  Set-LocationDownloads  Navigate to Downloads" -ForegroundColor White
    Write-Host "    Alias: downloads" -ForegroundColor Gray
    Write-Host "  Set-LocationDesktop    Navigate to Desktop" -ForegroundColor White
    Write-Host "    Alias: desktop" -ForegroundColor Gray
    Write-Host "  Get-QuickPath          List navigation aliases" -ForegroundColor White
    Write-Host ""
    
    Write-Host "Profile Utilities:" -ForegroundColor Cyan
    Write-Host "  Get-ProfileFunctions   List all custom functions" -ForegroundColor White
    Write-Host "    Aliases: funcs, listfuncs" -ForegroundColor Gray
    Write-Host "    Options: -ShowSynopsis, -ShowAliases, -Detailed" -ForegroundColor Gray
    Write-Host "  Show-ProfileHelp       Show this help message" -ForegroundColor White
    Write-Host "    Alias: profilehelp" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "For detailed help on any function, use: Get-Help <FunctionName> -Detailed" -ForegroundColor Yellow
    Write-Host ""
}

# Aliases for profile helper functions
Set-Alias -Name funcs -Value Get-ProfileFunctions
Set-Alias -Name listfuncs -Value Get-ProfileFunctions
Set-Alias -Name profilehelp -Value Show-ProfileHelp
