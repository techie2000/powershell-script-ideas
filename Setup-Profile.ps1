# Setup Script for PowerShell Profile
# This script helps install the PowerShell profile and scripts to your PowerShell profile location

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [switch]$Force,
    
    [Parameter(Mandatory=$false)]
    [switch]$SymbolicLink
)

Write-Host "PowerShell Profile Setup" -ForegroundColor Green
Write-Host "========================" -ForegroundColor Green
Write-Host ""

# Get the repository directory
$repoDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Get the PowerShell profile directory
$profileDir = Split-Path -Parent $PROFILE

Write-Host "Repository location: $repoDir" -ForegroundColor Cyan
Write-Host "PowerShell profile location: $PROFILE" -ForegroundColor Cyan
Write-Host "PowerShell profile directory: $profileDir" -ForegroundColor Cyan
Write-Host ""

# Check if profile directory exists
if (!(Test-Path $profileDir)) {
    Write-Host "Creating profile directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    Write-Host "✓ Profile directory created" -ForegroundColor Green
}

# Check if profile already exists
if (Test-Path $PROFILE) {
    if ($Force) {
        Write-Host "Existing profile found. Force flag is set, backing up..." -ForegroundColor Yellow
        $backup = "$PROFILE.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
        Copy-Item -Path $PROFILE -Destination $backup -Force
        Write-Host "✓ Backup created at: $backup" -ForegroundColor Green
    } else {
        Write-Host "ERROR: PowerShell profile already exists at: $PROFILE" -ForegroundColor Red
        Write-Host "Use -Force to overwrite (will create backup)" -ForegroundColor Yellow
        Write-Host "Or manually remove/rename the existing profile" -ForegroundColor Yellow
        exit 1
    }
}

if ($SymbolicLink) {
    # Create symbolic link
    Write-Host "Creating symbolic link to profile..." -ForegroundColor Yellow
    
    $profileSource = Join-Path $repoDir "Microsoft.PowerShell_profile.ps1"
    
    try {
        # Remove existing file if Force is specified
        if (Test-Path $PROFILE) {
            Remove-Item $PROFILE -Force
        }
        
        New-Item -ItemType SymbolicLink -Path $PROFILE -Target $profileSource -Force | Out-Null
        Write-Host "✓ Symbolic link created" -ForegroundColor Green
        
        # Note: Scripts and Modules will be loaded from repository location via the profile
        Write-Host "✓ Profile will load Scripts and Modules from repository" -ForegroundColor Green
    } catch {
        Write-Host "ERROR: Failed to create symbolic link: $_" -ForegroundColor Red
        Write-Host "You may need administrator privileges to create symbolic links" -ForegroundColor Yellow
        exit 1
    }
} else {
    # Copy files
    Write-Host "Copying profile to PowerShell profile location..." -ForegroundColor Yellow
    
    Copy-Item -Path (Join-Path $repoDir "Microsoft.PowerShell_profile.ps1") -Destination $PROFILE -Force
    Write-Host "✓ Profile copied" -ForegroundColor Green
    
    Write-Host "Copying Scripts folder..." -ForegroundColor Yellow
    $scriptsSource = Join-Path $repoDir "Scripts"
    $scriptsDest = Join-Path $profileDir "Scripts"
    
    if (Test-Path $scriptsDest) {
        Remove-Item -Path $scriptsDest -Recurse -Force
    }
    Copy-Item -Path $scriptsSource -Destination $scriptsDest -Recurse -Force
    Write-Host "✓ Scripts folder copied" -ForegroundColor Green
    
    Write-Host "Copying Modules folder..." -ForegroundColor Yellow
    $modulesSource = Join-Path $repoDir "Modules"
    $modulesDest = Join-Path $profileDir "Modules"
    
    if (Test-Path $modulesDest) {
        Remove-Item -Path $modulesDest -Recurse -Force
    }
    Copy-Item -Path $modulesSource -Destination $modulesDest -Recurse -Force
    Write-Host "✓ Modules folder copied" -ForegroundColor Green
}

Write-Host ""
Write-Host "Installation completed successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Restart PowerShell or run: . `$PROFILE" -ForegroundColor Cyan
Write-Host "2. Try commands like: sysinfo, dirsize, home" -ForegroundColor Cyan

if ($SymbolicLink) {
    Write-Host ""
    Write-Host "Note: Using symbolic link mode means:" -ForegroundColor Yellow
    Write-Host "- Changes to repository will automatically be reflected in your profile" -ForegroundColor Cyan
    Write-Host "- You can use git to version control your profile changes" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "To check if profile is loaded: Test-Path `$PROFILE" -ForegroundColor Cyan
Write-Host "To view your profile: Get-Content `$PROFILE" -ForegroundColor Cyan
