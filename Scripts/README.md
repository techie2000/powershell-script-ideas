# Scripts Folder

This folder contains personal PowerShell scripts that define custom functions and aliases. All scripts in this folder are automatically loaded when the PowerShell profile starts.

## Current Scripts

### FileHelpers.ps1
Utilities for working with files and directories:
- `Get-DirectorySize` / `dirsize` - Calculate directory sizes
- `Get-LargeFiles` / `glf` - Find large files with advanced filtering (size, date, recursion depth)

### SystemInfo.ps1
System information and monitoring functions:
- `Get-SystemInfo` / `sysinfo` - Display system information
- `Get-DiskSpace` / `diskspace` - Show disk space usage
- `Get-NetworkAdapters` / `netadapters` - Display network configuration

### NavigationHelpers.ps1
Quick navigation shortcuts:
- `home` - Go to user home directory
- `docs` - Go to Documents folder
- `downloads` - Go to Downloads folder
- `desktop` - Go to Desktop folder

## Adding New Scripts

To add a new script:

1. Create a `.ps1` file in this folder
2. Define functions with proper documentation
3. Add aliases for frequently used functions
4. Restart PowerShell or reload profile with `. $PROFILE`

## Script Template

```powershell
# ScriptName.ps1 - Brief description

function Verb-Noun {
    <#
    .SYNOPSIS
        Short description
    .DESCRIPTION
        Detailed description
    .PARAMETER ParameterName
        Parameter description
    .EXAMPLE
        Verb-Noun -ParameterName "value"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ParameterName
    )
    
    # Implementation
}

# Aliases
Set-Alias -Name alias -Value Verb-Noun
```

## Best Practices

- Use approved PowerShell verbs (Get, Set, New, Remove, etc.)
- Follow Verb-Noun naming convention
- Include comprehensive help documentation
- Test scripts before adding them
- Group related functions in the same file
- Use meaningful aliases that are easy to remember
