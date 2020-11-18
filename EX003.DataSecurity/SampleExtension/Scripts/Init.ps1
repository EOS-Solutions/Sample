$ErrorActionPreference = "Stop"

. $PSScriptRoot\InitializeProject.ps1

try {
    Initialize-Project (Resolve-Path "$PSScriptRoot\..")    
}
catch {
    Write-Host $_ -ForegroundColor Red
}
Read-Host -Prompt "Press <ENTER> to continue"