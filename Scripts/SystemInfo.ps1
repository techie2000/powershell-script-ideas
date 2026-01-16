# System Information Helper Functions
# Utilities for retrieving system information

function Get-SystemInfo {
    <#
    .SYNOPSIS
        Gets basic system information
    .DESCRIPTION
        Retrieves and displays key system information including OS, CPU, and memory
    .EXAMPLE
        Get-SystemInfo
    #>
    [CmdletBinding()]
    param()
    
    $os = Get-CimInstance -ClassName Win32_OperatingSystem
    $cpu = Get-CimInstance -ClassName Win32_Processor
    $memory = Get-CimInstance -ClassName Win32_ComputerSystem
    
    [PSCustomObject]@{
        ComputerName = $env:COMPUTERNAME
        OSVersion = $os.Caption
        OSArchitecture = $os.OSArchitecture
        BuildNumber = $os.BuildNumber
        Processor = $cpu.Name
        TotalMemoryGB = [math]::Round($memory.TotalPhysicalMemory / 1GB, 2)
        FreeMemoryGB = [math]::Round($os.FreePhysicalMemory / 1MB / 1024, 2)
        LastBootTime = $os.LastBootUpTime
    }
}

function Get-DiskSpace {
    <#
    .SYNOPSIS
        Gets disk space information for all drives
    .DESCRIPTION
        Displays free and used space for all local drives
    .EXAMPLE
        Get-DiskSpace
    #>
    [CmdletBinding()]
    param()
    
    Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3" |
        Select-Object DeviceID,
                      @{Name="TotalGB";Expression={[math]::Round($_.Size / 1GB, 2)}},
                      @{Name="FreeGB";Expression={[math]::Round($_.FreeSpace / 1GB, 2)}},
                      @{Name="UsedGB";Expression={[math]::Round(($_.Size - $_.FreeSpace) / 1GB, 2)}},
                      @{Name="PercentFree";Expression={[math]::Round(($_.FreeSpace / $_.Size) * 100, 2)}} |
        Sort-Object DeviceID
}

function Get-NetworkAdapters {
    <#
    .SYNOPSIS
        Gets network adapter information
    .DESCRIPTION
        Displays information about active network adapters
    .EXAMPLE
        Get-NetworkAdapters
    #>
    [CmdletBinding()]
    param()
    
    Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -Filter "IPEnabled=True" |
        Select-Object Description,
                      IPAddress,
                      IPSubnet,
                      DefaultIPGateway,
                      DNSServerSearchOrder,
                      MACAddress
}

# Aliases for common functions
Set-Alias -Name sysinfo -Value Get-SystemInfo
Set-Alias -Name diskspace -Value Get-DiskSpace
Set-Alias -Name netadapters -Value Get-NetworkAdapters
