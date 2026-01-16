# Modules Folder

This folder contains custom PowerShell modules. The PowerShell profile automatically adds this folder to the module path and imports modules on startup.

## Current Modules

### ExampleModule
A template module demonstrating proper module structure. Use this as a reference when creating new modules.

**Functions:**
- `Get-ExampleData` - Returns sample data
- `Invoke-ExampleTask` - Performs example tasks

## Creating a New Module

A PowerShell module consists of:

1. **Module folder** - Named after the module
2. **Module script file (.psm1)** - Contains the functions
3. **Module manifest (.psd1)** - Metadata and configuration (optional but recommended)

### Basic Module Structure

```
Modules/
└── YourModuleName/
    ├── YourModuleName.psm1     # Required: Module script
    └── YourModuleName.psd1     # Recommended: Module manifest
```

### Creating a Module Script (.psm1)

```powershell
# YourModuleName.psm1

function Get-Something {
    <#
    .SYNOPSIS
        Description of what this function does
    .PARAMETER Name
        Parameter description
    .EXAMPLE
        Get-Something -Name "Example"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Name
    )
    
    # Function implementation
}

function Set-Something {
    # Another function
}

# Export only the functions you want to be publicly available
Export-ModuleMember -Function Get-Something, Set-Something
```

### Creating a Module Manifest (.psd1)

Use PowerShell to generate a manifest:

```powershell
New-ModuleManifest -Path .\Modules\YourModuleName\YourModuleName.psd1 `
    -RootModule 'YourModuleName.psm1' `
    -ModuleVersion '1.0.0' `
    -Author 'Your Name' `
    -Description 'Module description' `
    -FunctionsToExport @('Get-Something', 'Set-Something')
```

## Module vs Script

**Use a Module when:**
- You have a cohesive set of related functions
- You want to version and distribute functionality
- You need more control over what gets exported
- You want to include module-level initialization

**Use a Script when:**
- You have simple, standalone functions
- You want all functions automatically available
- You prefer a simpler structure

## Testing Your Module

After creating a module, test it:

```powershell
# Import the module
Import-Module .\Modules\YourModuleName -Force

# Test functions
Get-Command -Module YourModuleName

# Use the functions
Get-Something -Name "Test"

# Remove module if needed
Remove-Module YourModuleName
```

## Best Practices

1. **Follow naming conventions** - Use approved verbs (Get, Set, New, etc.)
2. **Include help documentation** - Use comment-based help for all exported functions
3. **Export explicitly** - Use `Export-ModuleMember` to control what's exported
4. **Version your modules** - Update version numbers in the manifest
5. **Test thoroughly** - Test module import and all functions before deploying
6. **Keep modules focused** - Each module should have a clear, single purpose

## Advanced Features

### Module Initialization

Add code that runs when the module is imported:

```powershell
# Module initialization code (runs on import)
Write-Verbose "Loading YourModuleName"
$script:ModuleConfig = @{
    Setting1 = "Value1"
}

# Your functions here...

# Cleanup code (runs on removal)
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    Write-Verbose "Unloading YourModuleName"
}
```

### Private Functions

Functions not exported remain private to the module:

```powershell
# Private helper function
function Get-PrivateHelper {
    # Only available within the module
}

# Public function
function Get-PublicFunction {
    Get-PrivateHelper  # Can call private functions
}

Export-ModuleMember -Function Get-PublicFunction
```

## Resources

- [PowerShell Module Documentation](https://docs.microsoft.com/en-us/powershell/scripting/developer/module/writing-a-windows-powershell-module)
- [About Modules](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_modules)
