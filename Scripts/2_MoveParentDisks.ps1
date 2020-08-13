
# Move Parent Disks created in 2_CreateParentDisks.ps1 to shared location
# Move from $PSScriptRoot\ParentDisks to $LabConfig.ServerParentPath

# Verify Running as Admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
If (-not $isAdmin) {
    Write-Host "-- Restarting as Administrator" -ForegroundColor Cyan ; Start-Sleep -Seconds 1

    if($PSVersionTable.PSEdition -eq "Core") {
        Start-Process pwsh.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs 
    } else {
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs 
    }

    exit
}

# Load LabConfig....
. "$PSScriptRoot\LabConfig.ps1"


# Check if exists ParentPath directory
if (Test-Path -Path "$PSScriptRoot\ParentDisks" -PathType Container) {
    # Check if exists Win2016_G2.vhdx
    if (Test-Path -Path "$PSScriptRoot\ParentDisks\Win2016_G2.vhdx" -PathType Leaf) {
        # Check if exists Win2016Core_G2.vhdx
        if (Test-Path -Path "$PSScriptRoot\ParentDisks\Win2016Core_G2.vhdx" -PathType Leaf) {
            # Check if exists ServerParentPath
            if (!(Test-Path -Path "$($LabConfig.ServerParentPath)" -PathType Container)) {
                # Move ParentDisks to destination
                New-Item -Path $labconfig.ServerParentPath -ItemType Directory -ErrorAction SilentlyContinue
                Get-ChildItem -Path "$PSScriptRoot\ParentDisks" | Move-Item -Destination $LabConfig.ServerParentPath
                Remove-Item -Path "$PSScriptRoot\ParentDisks" -Force
            }
            else { Write-Warning "Ya existe $($LabConfig.ServerParentPath). No se hace nada" }
        }
        else { Write-Warning "No existe $PSScriptRoot\ParentDisks\Win2016Core_G2.vhdx. No se hace nada" }
    }
    else { Write-Warning "No existe $PSScriptRoot\ParentDisks\Win2016_G2.vhdx. No se hace nada" }
}
else { Write-Warning "No existe $PSScriptRoot\ParentDisks. No se hace nada" }

Pause