# PowerShell Profile
# This profile automatically loads personal scripts and modules

# Get the directory where this profile is located
$ProfileDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Define paths for scripts and modules
$ScriptsPath = Join-Path $ProfileDir "Scripts"
$ModulesPath = Join-Path $ProfileDir "Modules"

# Load all personal scripts from the Scripts folder
if (Test-Path $ScriptsPath) {
    Write-Host "Loading personal scripts from: $ScriptsPath" -ForegroundColor Green
    
    Get-ChildItem -Path $ScriptsPath -Filter "*.ps1" -Recurse | ForEach-Object {
        Write-Host "  Loading: $($_.Name)" -ForegroundColor Cyan
        . $_.FullName
    }
}

# Add Modules path to PSModulePath if it exists
if (Test-Path $ModulesPath) {
    if ($env:PSModulePath -notlike "*$ModulesPath*") {
        $env:PSModulePath = "$ModulesPath;$env:PSModulePath"
        Write-Host "Added modules path: $ModulesPath" -ForegroundColor Green
    }
    
    # Auto-import any modules in the Modules folder
    Get-ChildItem -Path $ModulesPath -Directory | ForEach-Object {
        $moduleName = $_.Name
        Write-Host "  Importing module: $moduleName" -ForegroundColor Cyan
        Import-Module $moduleName -ErrorAction SilentlyContinue
    }
}

Write-Host "PowerShell profile loaded successfully!" -ForegroundColor Green
