# Windows PowerShell System Administration Toolkit
# Portfolio edition - read-only administration and reporting functions

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Write-Section {
    param([Parameter(Mandatory)][string]$Title)
    Write-Host ""
    Write-Host ("=" * 68) -ForegroundColor DarkCyan
    Write-Host $Title -ForegroundColor Cyan
    Write-Host ("=" * 68) -ForegroundColor DarkCyan
}

function Show-SystemIdentity {
    Write-Section "System Identity"

    $os = Get-CimInstance Win32_OperatingSystem
    $computer = Get-CimInstance Win32_ComputerSystem

    [PSCustomObject]@{
        ComputerName = $env:COMPUTERNAME
        CurrentUser  = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
        Manufacturer = $computer.Manufacturer
        Model        = $computer.Model
        OperatingSystem = $os.Caption
        Version      = $os.Version
        LastBootTime = $os.LastBootUpTime
        UptimeHours  = [math]::Round(((Get-Date) - $os.LastBootUpTime).TotalHours, 2)
    } | Format-List
}

function Show-ProcessMonitor {
    param([int]$Top = 10)

    Write-Section "Top Processes by CPU"

    Get-Process |
        Sort-Object CPU -Descending |
        Select-Object -First $Top Name, Id,
            @{Name = "CPUSeconds"; Expression = { [math]::Round($_.CPU, 2) }},
            @{Name = "MemoryMB"; Expression = { [math]::Round($_.WorkingSet64 / 1MB, 2) }} |
        Format-Table -AutoSize
}

function Show-ServiceSummary {
    Write-Section "Service Summary"

    $services = Get-Service
    $summary = $services | Group-Object Status | Select-Object Name, Count
    $summary | Format-Table -AutoSize

    Write-Host "Stopped automatic services:" -ForegroundColor Yellow
    Get-CimInstance Win32_Service |
        Where-Object { $_.StartMode -eq "Auto" -and $_.State -ne "Running" } |
        Select-Object Name, DisplayName, State, StartMode |
        Format-Table -AutoSize
}

function Show-NetworkConfiguration {
    Write-Section "Network Configuration"

    Get-NetIPConfiguration |
        Select-Object InterfaceAlias,
            @{Name = "IPv4"; Expression = { ($_.IPv4Address.IPAddress -join ", ") }},
            @{Name = "Gateway"; Expression = { ($_.IPv4DefaultGateway.NextHop -join ", ") }},
            @{Name = "DnsServer"; Expression = { ($_.DNSServer.ServerAddresses -join ", ") }} |
        Format-Table -Wrap
}

function Show-DiskUsage {
    Write-Section "Disk Usage"

    Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" |
        Select-Object DeviceID, VolumeName,
            @{Name = "SizeGB"; Expression = { [math]::Round($_.Size / 1GB, 2) }},
            @{Name = "FreeGB"; Expression = { [math]::Round($_.FreeSpace / 1GB, 2) }},
            @{Name = "FreePercent"; Expression = {
                if ($_.Size -gt 0) { [math]::Round(($_.FreeSpace / $_.Size) * 100, 1) }
            }} |
        Format-Table -AutoSize
}

function Show-LocalAccounts {
    Write-Section "Local User Accounts"

    if (Get-Command Get-LocalUser -ErrorAction SilentlyContinue) {
        Get-LocalUser |
            Select-Object Name, Enabled, LastLogon, PasswordRequired |
            Format-Table -AutoSize
    }
    else {
        Write-Warning "Get-LocalUser is not available on this system."
    }
}

function Search-FilesByExtension {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Extension
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        throw "The folder '$Path' does not exist."
    }

    $cleanExtension = $Extension.TrimStart(".")
    Write-Section "Files with .$cleanExtension extension"

    Get-ChildItem -LiteralPath $Path -File -Recurse -Filter "*.$cleanExtension" -ErrorAction SilentlyContinue |
        Select-Object FullName,
            @{Name = "SizeKB"; Expression = { [math]::Round($_.Length / 1KB, 2) }},
            LastWriteTime |
        Format-Table -Wrap
}

function Show-RecentSystemEvents {
    param([int]$Hours = 24)

    Write-Section "Recent System Warnings and Errors"

    $startTime = (Get-Date).AddHours(-$Hours)
    Get-WinEvent -FilterHashtable @{
        LogName   = "System"
        StartTime = $startTime
        Level     = 2, 3
    } -ErrorAction SilentlyContinue |
        Select-Object -First 25 TimeCreated, Id, LevelDisplayName, ProviderName, Message |
        Format-Table -Wrap
}

function Export-SystemReport {
    param([string]$OutputPath = ".\system-report.json")

    Write-Section "Export System Report"

    $os = Get-CimInstance Win32_OperatingSystem
    $computer = Get-CimInstance Win32_ComputerSystem

    $report = [PSCustomObject]@{
        GeneratedAt = Get-Date
        ComputerName = $env:COMPUTERNAME
        CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
        OperatingSystem = $os.Caption
        Version = $os.Version
        Manufacturer = $computer.Manufacturer
        Model = $computer.Model
        MemoryGB = [math]::Round($computer.TotalPhysicalMemory / 1GB, 2)
        Disks = @(
            Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" |
                Select-Object DeviceID,
                    @{Name = "SizeGB"; Expression = { [math]::Round($_.Size / 1GB, 2) }},
                    @{Name = "FreeGB"; Expression = { [math]::Round($_.FreeSpace / 1GB, 2) }}
        )
        Network = @(
            Get-NetIPConfiguration |
                Select-Object InterfaceAlias,
                    @{Name = "IPv4"; Expression = { $_.IPv4Address.IPAddress }},
                    @{Name = "Gateway"; Expression = { $_.IPv4DefaultGateway.NextHop }}
        )
    }

    $report | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $OutputPath -Encoding UTF8
    Write-Host "Report saved to: $((Resolve-Path $OutputPath).Path)" -ForegroundColor Green
}

function Show-CommandHelp {
    Write-Section "Toolkit Commands"

    Get-Command -CommandType Function |
        Where-Object Name -Match "^(Show|Search|Export)-" |
        Sort-Object Name |
        Select-Object Name |
        Format-Table -AutoSize

    Write-Host "Use Get-Help <FunctionName> -Full for parameter details."
}

function Show-ToolkitMenu {
    do {
        Clear-Host
        Write-Host "Windows PowerShell Administration Toolkit" -ForegroundColor Cyan
        Write-Host "Read-only portfolio edition" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "1. System identity"
        Write-Host "2. Process monitor"
        Write-Host "3. Service summary"
        Write-Host "4. Network configuration"
        Write-Host "5. Disk usage"
        Write-Host "6. Local accounts"
        Write-Host "7. Search files by extension"
        Write-Host "8. Recent system events"
        Write-Host "9. Export system report"
        Write-Host "10. Command help"
        Write-Host "0. Exit"
        Write-Host ""

        $choice = Read-Host "Select an option"

        try {
            switch ($choice) {
                "1" { Show-SystemIdentity }
                "2" { Show-ProcessMonitor }
                "3" { Show-ServiceSummary }
                "4" { Show-NetworkConfiguration }
                "5" { Show-DiskUsage }
                "6" { Show-LocalAccounts }
                "7" {
                    $path = Read-Host "Folder to search"
                    $extension = Read-Host "File extension, for example log or txt"
                    Search-FilesByExtension -Path $path -Extension $extension
                }
                "8" { Show-RecentSystemEvents }
                "9" {
                    $path = Read-Host "Output path or press Enter for system-report.json"
                    if ([string]::IsNullOrWhiteSpace($path)) {
                        Export-SystemReport
                    }
                    else {
                        Export-SystemReport -OutputPath $path
                    }
                }
                "10" { Show-CommandHelp }
                "0" { Write-Host "Goodbye." -ForegroundColor Cyan }
                default { Write-Warning "Choose a number from 0 to 10." }
            }
        }
        catch {
            Write-Error $_
        }

        if ($choice -ne "0") {
            Write-Host ""
            Read-Host "Press Enter to return to the menu"
        }
    } while ($choice -ne "0")
}

Show-ToolkitMenu
