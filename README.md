<div align="center">

# ⚡ Windows PowerShell Administration Toolkit

**A runnable, menu-driven toolkit for Windows administration and reporting**

[![Source](https://img.shields.io/badge/OPEN_COMPLETE_SCRIPT-B6FF00?style=for-the-badge&logo=powershell&logoColor=07110D)](src/Windows-Admin-Toolkit.ps1)
[![Evidence](https://img.shields.io/badge/VIEW_TEST_EVIDENCE-101820?style=for-the-badge&logo=windows&logoColor=B6FF00)](evidence/)
[![Download](https://img.shields.io/badge/DOWNLOAD_COMPLETE_PROJECT-B6FF00?style=for-the-badge&logo=github&logoColor=07110D)](https://github.com/Naledi-Reed/powershell-admin-toolkit/archive/refs/heads/main.zip)

</div>

## What is included

The complete PowerShell script provides:

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

## Actual project files

| File | Purpose |
|---|---|
| [Windows-Admin-Toolkit.ps1](src/Windows-Admin-Toolkit.ps1) | Complete runnable toolkit |
| [architecture.svg](docs/architecture.svg) | System architecture |
| [implementation-notes.md](docs/implementation-notes.md) | Technical implementation notes |
| [evidence/](evidence/) | Execution and source evidence |
| [evidence/README.md](evidence/README.md) | Evidence index |

## Run the toolkit

1. Download the repository ZIP or clone it.
2. Open Windows PowerShell 5.1 or PowerShell 7.
3. Change to the downloaded repository directory.
4. Run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\src\Windows-Admin-Toolkit.ps1
```

Some functions may provide more detail when PowerShell is opened as Administrator.

## Safety

The public toolkit is read-only. It inspects and reports information without creating users, changing services or modifying security settings.

## Skills demonstrated

Reusable functions • Windows administration • CIM cmdlets • validation • error handling • structured objects • JSON output • monitoring • documentation

**Module origin:** OPS262 — Operating Systems  
**Status:** Working portfolio project with complete source, documentation and evidence
