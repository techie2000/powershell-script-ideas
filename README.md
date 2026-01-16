# PowerShell Script Ideas

Recording my trialling experience of PowerShell scripting.

## Overview

This repository contains a structured approach to managing PowerShell profiles, personal scripts, and modules. It provides an organized way to maintain and version control your PowerShell environment.

## Repository Structure

```
powershell-script-ideas/
├── Microsoft.PowerShell_profile.ps1    # PowerShell profile that auto-loads scripts
├── Scripts/                             # Personal scripts with functions and aliases
│   ├── FileHelpers.ps1                 # File and directory utilities
│   ├── SystemInfo.ps1                  # System information functions
│   └── NavigationHelpers.ps1           # Quick navigation shortcuts
└── Modules/                             # Custom PowerShell modules
    └── ExampleModule/                  # Example module template
        ├── ExampleModule.psm1          # Module script file
        └── ExampleModule.psd1          # Module manifest
```

## Installation

### Option 1: Copy Profile to PowerShell Profile Location

To use this profile as your main PowerShell profile:

1. Clone this repository:
   ```powershell
   git clone https://github.com/techie2000/powershell-script-ideas.git
   cd powershell-script-ideas
   ```

2. Copy the profile to your PowerShell profile location:
   ```powershell
   # Check your profile location
   $PROFILE
   
   # Create profile directory if it doesn't exist
   $profileDir = Split-Path -Parent $PROFILE
   if (!(Test-Path $profileDir)) {
       New-Item -ItemType Directory -Path $profileDir -Force
   }
   
   # Copy the profile file
   Copy-Item -Path .\Microsoft.PowerShell_profile.ps1 -Destination $PROFILE -Force
   
   # Copy Scripts and Modules folders to the same location
   Copy-Item -Path .\Scripts -Destination $profileDir -Recurse -Force
   Copy-Item -Path .\Modules -Destination $profileDir -Recurse -Force
   ```

3. Restart PowerShell or reload the profile:
   ```powershell
   . $PROFILE
   ```

### Option 2: Use Repository as Profile Location

Alternatively, you can use this repository directly as your profile location by creating a symbolic link:

```powershell
# Remove existing profile if present
Remove-Item $PROFILE -Force -ErrorAction SilentlyContinue

# Create symbolic link to the repository profile
New-Item -ItemType SymbolicLink -Path $PROFILE -Target "C:\path\to\powershell-script-ideas\Microsoft.PowerShell_profile.ps1"
```

## Available Scripts

### File Helpers (Scripts/FileHelpers.ps1)

- **Get-DirectorySize** (aliases: `dirsize`, `getdirsize`, `gds`) - Calculate total size of a directory
  ```powershell
  Get-DirectorySize -Path "C:\Users"
  dirsize "C:\Windows"
  gds "C:\Projects"
  ```

- **Get-LargeFiles** (aliases: `glf`, `getlargefiles`) - Find files larger than specified size with advanced filtering
  ```powershell
  Get-LargeFiles                              # Default: >=10MB in current directory
  glf -m 500KB                                # Files >=500KB (short form)
  getlargefiles -m 1GB -r                     # Files >=1GB, recurse all levels
  glf -m 2GB -d 3                             # Files >=2GB, recurse 3 levels
  glf -m 1GB -d 3 -ca 2025-01-01              # Files >=1GB, created after date
  glf -ma 2025-01-01                          # Modified after date
  glf -h                                      # Show detailed help
  ```

### System Info (Scripts/SystemInfo.ps1)

- **Get-SystemInfo** (alias: `sysinfo`) - Display system information
  ```powershell
  Get-SystemInfo
  sysinfo
  ```

- **Get-DiskSpace** (alias: `diskspace`) - Show disk space for all drives
  ```powershell
  Get-DiskSpace
  diskspace
  ```

- **Get-NetworkAdapters** (alias: `netadapters`) - Display network adapter info
  ```powershell
  Get-NetworkAdapters
  netadapters
  ```

### Navigation Helpers (Scripts/NavigationHelpers.ps1)

Quick navigation aliases:
- `home` - Navigate to user home directory
- `docs` - Navigate to Documents folder
- `downloads` - Navigate to Downloads folder
- `desktop` - Navigate to Desktop folder

```powershell
# Examples
home
docs
downloads
```

## Available Modules

### ExampleModule

A template module demonstrating the structure for creating custom PowerShell modules.

Functions:
- **Get-ExampleData** - Returns sample data
- **Invoke-ExampleTask** - Performs example tasks

```powershell
Get-ExampleData -Name "Test"
Invoke-ExampleTask -Task "ProcessData"
```

## Creating Your Own Scripts

To add your own scripts:

1. Create a new `.ps1` file in the `Scripts/` folder
2. Define your functions with proper documentation
3. Add aliases at the end of the script using `Set-Alias`
4. The profile will automatically load it on next PowerShell start

Example script structure:

```powershell
# MyCustomScript.ps1

function Get-MyCustomFunction {
    <#
    .SYNOPSIS
        Brief description
    .DESCRIPTION
        Detailed description
    .PARAMETER ParamName
        Parameter description
    .EXAMPLE
        Get-MyCustomFunction -ParamName "value"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ParamName
    )
    
    # Function logic here
}

# Create alias
Set-Alias -Name myalias -Value Get-MyCustomFunction
```

## Creating Your Own Modules

To create a custom module:

1. Create a new folder in `Modules/` with your module name
2. Create a `.psm1` file with the same name containing your functions
3. Create a `.psd1` manifest file (optional but recommended)
4. Export functions using `Export-ModuleMember`

See the `ExampleModule` for a template.

## How It Works

When PowerShell starts:

1. The `Microsoft.PowerShell_profile.ps1` file is automatically executed
2. The profile scans the `Scripts/` folder and dot-sources all `.ps1` files
3. The profile adds the `Modules/` folder to `$env:PSModulePath`
4. All functions and aliases from scripts become available in your session
5. Modules in the `Modules/` folder are automatically imported

## Customization

You can customize the profile behavior by editing `Microsoft.PowerShell_profile.ps1`:

- Change the loading messages
- Add custom initialization logic
- Set environment variables
- Configure PowerShell settings

## Best Practices

1. **Use descriptive function names** - Follow PowerShell's Verb-Noun naming convention
2. **Include proper documentation** - Use comment-based help for all functions
3. **Test your scripts** - Test functions before adding them to the profile
4. **Version control** - Keep this repository updated with your changes
5. **Keep it organized** - Group related functions in the same script file

## Troubleshooting

### Profile not loading

Check if execution policy allows scripts:
```powershell
Get-ExecutionPolicy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Functions not available

Reload the profile manually:
```powershell
. $PROFILE
```

### Check if profile is loaded

```powershell
Test-Path $PROFILE
Get-Content $PROFILE
```

## Contributing

Feel free to add your own scripts and modules to this repository. Commit changes regularly to keep your PowerShell environment backed up and version controlled.

## License

See LICENSE file for details.
