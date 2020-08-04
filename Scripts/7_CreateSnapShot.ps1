#requires -Modules Hyper-V

# Script para crear un punto de control para el  laboratorio, es decir, consolidar la situación actual

# 1. Crear el switch virtual
# 2. Conectar las NICs con nombre 'Management*' al switch
# 3. Arrancar las VMs

# Ejecutar en el Host Hyper-V (ANIMP10)


# Verify Running as Admin
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    If (!( $isAdmin )) {
        Write-Host "-- Restarting as Administrator" -ForegroundColor Cyan ; Start-Sleep -Seconds 1
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs 
        exit
    }


# 0. Definir nombre snapshot
    $SnapshotName = 'Con PostDeploy aplicado'
    $SnapshotName = 'Antes de Team Aruba'
    $SnapshotName = 'Después de Team Aruba'
    $SnapshotName = 'Después de Team Aruba'
    $SnapshotName = 'Red configurada (Paso 2)'
    $SnapshotName = 'Red configurada (Paso 2, sin vlan)'
    $SnapshotName = 'Cluster creado, antes de S2D'
    $SnapshotName = 'S2D creado, antes de crear volumenes'


# Importar modulo Hyper-V con prefijo, para distinguir comandos con el mismo nombre de VMware
    Import-Module -Prefix HV -Name Hyper-V


# Load LabConfig....
    . "$PSScriptRoot\LabConfig.ps1"


# Establecer valores
    $DC            = $LabConfig.Prefix + 'DC'
    $VMNames       = foreach ($VMName in $LabConfig.VMs.VMName) { $LabConfig.Prefix + $VMName }


# 1. Parar el laboratorio
    . "$PSScriptRoot\6_StopLab.ps1"


# 2. Hacer snapshot de todo
    $DC | Checkpoint-VM -SnapshotName $SnapshotName
    foreach ($VMName in $VMnames) { $VMName | Checkpoint-VM -SnapshotName $SnapshotName }


# 3. Arrancar el laboratorio
    . "$PSScriptRoot\4_StartLab.ps1"
