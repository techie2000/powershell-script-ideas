# File and Directory Helper Functions
# Common utilities for working with files and directories

function Get-DirectorySize {
    <#
    .SYNOPSIS
        Gets the total size of a directory
    .DESCRIPTION
        Recursively calculates the total size of all files in a directory
    .PARAMETER Path
        The path to the directory
    .EXAMPLE
        Get-DirectorySize -Path "C:\Users"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [string]$Path
    )
    
    if (Test-Path $Path) {
        $size = (Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue | 
                 Measure-Object -Property Length -Sum).Sum
        
        # Convert to readable format
        if ($size -gt 1GB) {
            "{0:N2} GB" -f ($size / 1GB)
        } elseif ($size -gt 1MB) {
            "{0:N2} MB" -f ($size / 1MB)
        } elseif ($size -gt 1KB) {
            "{0:N2} KB" -f ($size / 1KB)
        } else {
            "$size bytes"
        }
    } else {
        Write-Error "Path not found: $Path"
    }
}

function Find-LargeFiles {
    <#
    .SYNOPSIS
        Finds large files in a directory
    .DESCRIPTION
        Searches for files larger than the specified size threshold
    .PARAMETER Path
        The path to search
    .PARAMETER MinimumSizeMB
        Minimum file size in megabytes (default: 100)
    .EXAMPLE
        Find-LargeFiles -Path "C:\Users" -MinimumSizeMB 50
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, Position=0)]
        [string]$Path = ".",
        
        [Parameter(Mandatory=$false)]
        [int]$MinimumSizeMB = 100
    )
    
    $minimumBytes = $MinimumSizeMB * 1MB
    
    Get-ChildItem -Path $Path -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object { $_.Length -gt $minimumBytes } |
        Select-Object FullName, 
                      @{Name="SizeMB";Expression={[math]::Round($_.Length / 1MB, 2)}},
                      LastWriteTime |
        Sort-Object SizeMB -Descending
}

# Aliases for common functions
Set-Alias -Name dirsize -Value Get-DirectorySize
Set-Alias -Name findlarge -Value Find-LargeFiles
