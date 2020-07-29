#requires -Modules Hyper-V


# Script para parar un laboratorio después de realizar pruebas. No es lo mismo que eliminar el lab, que se haría con Cleanup.ps1

# 1. Apagar las VMs
# 2. Eliminar el switch virtual (Las VM's se quedan sin switch configurado, pero se vuelven a conectar con '5_Start Lab.ps1'


# Ejecutar en el Host Hyper-V (ANIMP10)


# Importar modulo Hyper-V con prefijo, para distinguir comandos con el mismo nombre de VMware
# Verify Running as Admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
If (!( $isAdmin )) {
    Write-Host "-- Restarting as Administrator" -ForegroundColor Cyan ; Start-Sleep -Seconds 1
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs 
    exit
}


Import-Module -Prefix HV -Name Hyper-V


# Load LabConfig....
. "$PSScriptRoot\LabConfig.ps1"


# Establecer valores
$VMSwitchName  = $LabConfig.Prefix + $LabConfig.SwitchName
$VMNames       = foreach ($VMName in $LabConfig.VMs.VMName) { $LabConfig.Prefix + $VMName }


# 1. Apagar las VMs
Stop-HVVM -Name $VMNames


# 3. Esperar a que se apaguen las VMs
while ((Get-VM -Name $VMNames).State -ne 'Off') {
    Start-Sleep -Seconds 5
}


# 2. Apagar el DC (después de las VMs)
Stop-HVVM -Name $($LabConfig.Prefix + 'DC')


# 3. Esperar a que se apague el DC
while ((Get-VM -Name $($LabConfig.Prefix + 'DC')).State -ne 'Off') {
    Start-Sleep -Seconds 5
}


# 4. Eliminar el switch (si existe)
if (Get-VMSwitch -Name $VMSwitchName -ErrorAction SilentlyContinue) {
    Remove-VMSwitch -Name $VMSwitchName -Force -Confirm:$false
}
