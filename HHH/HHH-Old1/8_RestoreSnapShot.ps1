#requires -Modules Hyper-V

# Script para volver al último punto de control para el laboratorio

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


# Importar modulo Hyper-V con prefijo, para distinguir comandos con el mismo nombre de VMware
    Import-Module -Prefix HV -Name Hyper-V


# Load LabConfig....
    . "$PSScriptRoot\LabConfig.ps1"
   

# Establecer valores
    $DC            = $LabConfig.Prefix + 'DC'
    $VMNames       = foreach ($VMName in $LabConfig.VMs.VMName) { $LabConfig.Prefix + $VMName }


# 1. Revertir al snapshot
    Restore-VMsnapshot -VMName $DC -Name $SnapshotName -Confirm:$False 
    foreach ($VMName in $VMnames) { Restore-VMsnapshot -VMName $VMName -Name $SnapshotName -Confirm:$False }


# 2. Arrancar el laboratorio
    . "$PSScriptRoot\4_StartLab.ps1"

