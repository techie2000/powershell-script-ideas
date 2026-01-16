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
    .PARAMETER Help
        Display detailed usage help
    .EXAMPLE
        Get-DirectorySize -Path "C:\Users"
    .EXAMPLE
        dirsize "C:\Windows"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false, Position=0)]
        [string]$Path,
        
        [Alias('h')]
        [switch]$Help
    )
    
    if ($Help) {
        Write-Host "Get-DirectorySize usage:" -ForegroundColor Green
        Write-Host "  dirsize C:\Path             # Get size of directory"
        Write-Host "  gds C:\Users                # Using short alias"
        Write-Host "  getdirsize .                # Current directory"
        Write-Host ""
        Write-Host "Parameters:" -ForegroundColor Cyan
        Write-Host "  -Path          Directory path (required)"
        Write-Host "  -Help, -h      Show this help message"
        Write-Host ""
        Write-Host "Aliases:" -ForegroundColor Cyan
        Write-Host "  dirsize, getdirsize, gds"
        return
    }
    
    if (-not $Path) {
        Write-Error "Path parameter is required. Use -Help for usage information."
        return
    }
    
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

function Get-LargeFiles {
    <#
    .SYNOPSIS
        Finds large files in a directory with advanced filtering options
    .DESCRIPTION
        Searches for files larger than the specified size threshold with support for
        recursion depth control, creation/modification date filtering, and flexible size units
    .PARAMETER MinSize
        Minimum file size (e.g. 10MB, 500KB, 1GB, 2TB, 100). Default is 10MB
    .PARAMETER Recurse
        Recurse through all subdirectories
    .PARAMETER Depth
        Maximum recursion depth (implies -Recurse)
    .PARAMETER CreatedAfter
        Filter files created on or after this date (e.g. 2025-01-01)
    .PARAMETER ModifiedAfter
        Filter files modified on or after this date (e.g. 2025-01-01)
    .PARAMETER Help
        Display detailed usage help
    .EXAMPLE
        Get-LargeFiles
        # Current directory, >=10MB (default), no recursion
    .EXAMPLE
        Get-LargeFiles -MinSize 500KB
        # Current directory, >=500KB
    .EXAMPLE
        Get-LargeFiles -MinSize 1GB -Recurse
        # Recurse all levels, >=1GB
    .EXAMPLE
        Get-LargeFiles -MinSize 2GB -Depth 3
        # Recurse 3 levels, >=2GB
    .EXAMPLE
        Get-LargeFiles -MinSize 1GB -Depth 3 -CreatedAfter 2025-01-01
        # Recurse 3 levels, >=1GB, created after 2025-01-01
    #>
    [CmdletBinding()]
    param(
        [Alias('m')]
        [string]$MinSize = "10MB",   # e.g. 10MB, 500KB, 1GB, 2TB, 100

        [Alias('r')]
        [switch]$Recurse,

        [Alias('d')]
        [int]$Depth,

        [Alias('ca')]
        [string]$CreatedAfter,       # creation time >= this

        [Alias('ma')]
        [string]$ModifiedAfter,      # last write >= this

        [Alias('h')]
        [switch]$Help
    )

    if ($Help) {
        Write-Host "Get-LargeFiles usage:" -ForegroundColor Green
        Write-Host "  glf                            # current dir, >=10MB (default), no recursion"
        Write-Host "  glf -m 500KB                   # current dir, >=500KB"
        Write-Host "  glf -m 1GB                     # current dir, >=1GB"
        Write-Host "  glf -r                         # recurse all levels, >=10MB"
        Write-Host "  glf -d 2                       # recurse 2 levels, >=10MB (Depth implies -r)"
        Write-Host "  glf -m 50MB -r                 # recurse all levels, >=50MB"
        Write-Host "  glf -m 2GB -d 3                # recurse 3 levels, >=2GB (Depth implies -r)"
        Write-Host "  glf -ca 2025-01-01             # created on/after 2025-01-01"
        Write-Host "  glf -ma 2025-01-01             # modified on/after 2025-01-01"
        Write-Host "  glf -m 1GB -d 3 -ca 2025-01-01"
        Write-Host ""
        Write-Host "Parameters:" -ForegroundColor Cyan
        Write-Host "  -MinSize, -m       Minimum file size (10MB, 500KB, 1GB, 2TB, etc.)"
        Write-Host "  -Recurse, -r       Recurse all subdirectories"
        Write-Host "  -Depth, -d         Maximum recursion depth (implies -Recurse)"
        Write-Host "  -CreatedAfter, -ca Filter by creation date (YYYY-MM-DD)"
        Write-Host "  -ModifiedAfter, -ma Filter by modification date (YYYY-MM-DD)"
        Write-Host "  -Help, -h          Show this help message"
        return
    }

    # Check which parameters were explicitly specified by user
    $minSizeSpecified = $PSBoundParameters.ContainsKey('MinSize')
    $recurseSpecified = $PSBoundParameters.ContainsKey('Recurse')
    $depthSpecified = $PSBoundParameters.ContainsKey('Depth')
    $createdAfterSpecified = $PSBoundParameters.ContainsKey('CreatedAfter')
    $modifiedAfterSpecified = $PSBoundParameters.ContainsKey('ModifiedAfter')
    
    # Track original values before any modifications
    $originalRecurse = $Recurse.IsPresent
    $originalDepth = $Depth

    # Parse the MinSize string to bytes
    $minSizeBytes = 0
    if ($MinSize -match '^(\d+(?:\.\d+)?)\s*(TB|GB|MB|KB|B)?$') {
        $number = [double]$Matches[1]
        $unit = $Matches[2]
        
        # Handle unit conversion - if no unit specified, assume bytes
        if ([string]::IsNullOrEmpty($unit)) {
            $minSizeBytes = $number  # No unit means bytes
        } else {
            switch ($unit) {
                'TB' { $minSizeBytes = $number * 1TB }
                'GB' { $minSizeBytes = $number * 1GB }
                'MB' { $minSizeBytes = $number * 1MB }
                'KB' { $minSizeBytes = $number * 1KB }
                'B'  { $minSizeBytes = $number }
            }
        }
    } else {
        Write-Error "Invalid MinSize format: $MinSize. Use format like '10MB', '500KB', '1GB', etc."
        return
    }

    # Build Get-ChildItem parameters
    $gciParams = @{
        Path = "."
        File = $true
        ErrorAction = 'SilentlyContinue'
    }

    # Handle recursion logic and track changes
    $actualRecurse = $false
    $actualDepth = $null
    $recursionNote = ""
    
    if ($Depth -gt 0) {
        $gciParams['Recurse'] = $true
        $gciParams['Depth'] = $Depth
        $actualRecurse = $true
        $actualDepth = $Depth
        
        if ($depthSpecified) {
            $recursionNote = "specified"
            if ($recurseSpecified -and $originalRecurse) {
                $recursionNote = "specified (Depth implies Recurse)"
            }
        }
    } elseif ($Depth -eq 0 -and $depthSpecified) {
        # Depth=0 was explicitly specified, which means no recursion
        $actualRecurse = $false
        $actualDepth = 0  # Set actualDepth so we can track it was specified
        
        if ($recurseSpecified -and $originalRecurse) {
            # User specified both -Recurse and -Depth 0, Depth wins
            $recursionNote = "overwritten (Depth=0 overrides -Recurse)"
        } else {
            # Depth=0 specified, but -Recurse was not specified
            $recursionNote = "inferred (from Depth=0)"
        }
    } elseif ($Recurse) {
        $gciParams['Recurse'] = $true
        $actualRecurse = $true
        $recursionNote = "specified"
    } else {
        $recursionNote = "defaulted"
    }
    
    # Determine depth display value
    $depthDisplay = if ($actualDepth -ne $null) {
        if ($depthSpecified) {
            "$actualDepth (specified)"
        } else {
            "$actualDepth"
        }
    } elseif ($actualRecurse) {
        "unlimited (implied by -Recurse)"
    } else {
        "0 (defaulted - no recursion)"
    }

    # Parse date filters if provided
    $createdAfterDate = $null
    $modifiedAfterDate = $null
    $createdDisplay = "none (defaulted)"
    $modifiedDisplay = "none (defaulted)"
    
    if ($CreatedAfter) {
        try {
            $createdAfterDate = [DateTime]::Parse($CreatedAfter)
            # If we're in this block, CreatedAfter was specified
            $createdDisplay = "$($createdAfterDate.ToString('yyyy-MM-dd')) (specified)"
        } catch {
            Write-Error "Invalid CreatedAfter date format: $CreatedAfter. Use format like '2025-01-01'"
            return
        }
    }
    
    if ($ModifiedAfter) {
        try {
            $modifiedAfterDate = [DateTime]::Parse($ModifiedAfter)
            # If we're in this block, ModifiedAfter was specified
            $modifiedDisplay = "$($modifiedAfterDate.ToString('yyyy-MM-dd')) (specified)"
        } catch {
            Write-Error "Invalid ModifiedAfter date format: $ModifiedAfter. Use format like '2025-01-01'"
            return
        }
    }

    # Display parameters being used
    Write-Host "`nRunning Get-LargeFiles with parameters:" -ForegroundColor Cyan
    
    # Path is currently always defaulted (no Path parameter in function signature)
    Write-Host ("  Path       : {0} (defaulted)" -f $gciParams.Path)
    Write-Host ("  Recurse    : {0} ({1})" -f $actualRecurse, $recursionNote)
    Write-Host ("  Depth      : {0}" -f $depthDisplay)
    
    $minSizeSource = if ($minSizeSpecified) { "specified" } else { "defaulted" }
    Write-Host ("  MinSize    : {0} ({1} bytes) ({2})" -f $MinSize, $minSizeBytes, $minSizeSource)
    Write-Host ("  Created>=  : {0}" -f $createdDisplay)
    Write-Host ("  Modified>= : {0}" -f $modifiedDisplay)
    Write-Host ""


    # Get files and apply filters
    $files = Get-ChildItem @gciParams | Where-Object {
        $matchesSize = $_.Length -ge $minSizeBytes
        $matchesCreated = (-not $createdAfterDate) -or ($_.CreationTime -ge $createdAfterDate)
        $matchesModified = (-not $modifiedAfterDate) -or ($_.LastWriteTime -ge $modifiedAfterDate)
        
        $matchesSize -and $matchesCreated -and $matchesModified
    }

    # Format and display results
    if ($files) {
        $files | Select-Object FullName,
                              @{Name="Size";Expression={
                                  $size = $_.Length
                                  if ($size -ge 1GB) {
                                      "{0:N2} GB" -f ($size / 1GB)
                                  } elseif ($size -ge 1MB) {
                                      "{0:N2} MB" -f ($size / 1MB)
                                  } elseif ($size -ge 1KB) {
                                      "{0:N2} KB" -f ($size / 1KB)
                                  } else {
                                      "$size bytes"
                                  }
                              }},
                              @{Name="SizeBytes";Expression={$_.Length}},
                              CreationTime,
                              LastWriteTime |
                 Sort-Object SizeBytes -Descending
    } else {
        Write-Host "No files found matching the criteria." -ForegroundColor Yellow
    }
}

# Aliases for common functions
Set-Alias -Name dirsize -Value Get-DirectorySize
Set-Alias -Name getdirsize -Value Get-DirectorySize
Set-Alias -Name gds -Value Get-DirectorySize
Set-Alias -Name largefiles -Value Get-LargeFiles
Set-Alias -Name getlargefiles -Value Get-LargeFiles
Set-Alias -Name glf -Value Get-LargeFiles
