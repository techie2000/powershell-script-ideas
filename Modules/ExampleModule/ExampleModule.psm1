# Example PowerShell Module
# This is a template for creating custom PowerShell modules

function Get-ExampleData {
    <#
    .SYNOPSIS
        Example function that returns sample data
    .DESCRIPTION
        This is a template function to demonstrate module structure
    .PARAMETER Name
        Optional name parameter
    .EXAMPLE
        Get-ExampleData -Name "Test"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$Name = "Default"
    )
    
    [PSCustomObject]@{
        Name = $Name
        Timestamp = Get-Date
        ComputerName = $env:COMPUTERNAME
        Message = "This is example data from the ExampleModule"
    }
}

function Invoke-ExampleTask {
    <#
    .SYNOPSIS
        Example function that performs a task
    .DESCRIPTION
        This is a template function to demonstrate module functionality
    .PARAMETER Task
        The task to perform
    .EXAMPLE
        Invoke-ExampleTask -Task "ProcessData"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateSet("ProcessData", "GenerateReport", "CleanUp")]
        [string]$Task
    )
    
    Write-Host "Executing task: $Task" -ForegroundColor Green
    
    switch ($Task) {
        "ProcessData" {
            Write-Host "Processing data..." -ForegroundColor Cyan
            # Add processing logic here
        }
        "GenerateReport" {
            Write-Host "Generating report..." -ForegroundColor Cyan
            # Add report generation logic here
        }
        "CleanUp" {
            Write-Host "Cleaning up..." -ForegroundColor Cyan
            # Add cleanup logic here
        }
    }
    
    Write-Host "Task completed successfully!" -ForegroundColor Green
}

# Export module members
Export-ModuleMember -Function Get-ExampleData, Invoke-ExampleTask
