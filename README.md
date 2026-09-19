# Windows PowerShell Administration Toolkit

A runnable, menu-driven PowerShell toolkit for common Windows administration, monitoring and reporting tasks.

**Status:** Working portfolio project  
**Module origin:** OPS262 - Operating Systems  
**Safety:** The public toolkit is read-only. It inspects and reports system information without changing users, services or security settings.

## What is included

The script provides ten menu options:

1. System identity and operating-system information
2. Top processes by CPU usage
3. Service status and stopped automatic services
4. IP, gateway and DNS configuration
5. Disk capacity and free space
6. Local user-account summary
7. Recursive file-extension search
8. Recent System log warnings and errors
9. JSON system-report export
10. Command discovery and help

## Run the project

1. Download or clone this repository.
2. Open **Windows PowerShell 5.1 or PowerShell 7**.
3. Change to the repository folder.
4. Run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\src\Windows-Admin-Toolkit.ps1
```

Some functions such as local account and event-log inspection may provide more information when PowerShell is opened as Administrator.

## Source code

[Open the complete PowerShell toolkit](src/Windows-Admin-Toolkit.ps1)

## Evidence

[View screenshots and test evidence](evidence/)

The evidence includes the menu running live, the process-monitor function, system-summary output and file-extension search results.

## Architecture

```text
Menu
  |
  +-- System and operating-system checks
  +-- Process and service monitoring
  +-- Network and disk reporting
  +-- Local account and event-log inspection
  +-- File search and JSON export
```

## Skills demonstrated

- Reusable PowerShell functions
- Windows system administration
- CIM and built-in cmdlets
- Validation and error handling
- Structured objects and JSON output
- Monitoring and technical documentation

## Development roadmap

- Add Pester unit tests
- Add optional CSV and HTML reports
- Add remote-computer support
- Add GitHub Actions syntax validation

## Academic context

This is a cleaned public portfolio edition based on practical work completed at Belgium Campus iTversity in 2026. Private academic records and unredacted assessment material are not published.
