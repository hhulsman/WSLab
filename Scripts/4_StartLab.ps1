#requires -Modules Hyper-V


# Script para arrancar un laboratorio

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


# Importar modulo Hyper-V con prefijo, para distinguir comandos con el mismo nombre de VMware
Import-Module -Prefix HV -Name Hyper-V


# Load LabConfig....
. "$PSScriptRoot\LabConfig.ps1"


# Establecer valores
$VMSwitchName  = $LabConfig.Prefix + $LabConfig.SwitchName
$DC            = $LabConfig.Prefix + 'DC'
$VMNames       = foreach ($VMName in $LabConfig.VMs.VMName) { $LabConfig.Prefix + $VMName }
$AdapterPrefix = 'Management*'



# 1. Crear el switch, si no existe
if (!(Get-VMSwitch -Name $VMSwitchName -ErrorAction SilentlyContinue)) {
    New-VMSwitch -SwitchType Private -Name $VMSwitchName
}
else {
    Write-Warning "El switch virtual $VMSwitchName ya existe"
}


# 2. Conectar las NICs de DC con nombre 'Management*' al switch

# Obtener todas las NICs de la VM cuyo nombre empiece por 'Management'
$NetAdapters = Get-VMNetworkAdapter -Name $AdapterPrefix -VMName $DC

# Conectar las NICs de la VM al switch
Connect-VMNetworkAdapter -Name $NetAdapters.Name -VMName $DC -SwitchName $VMSwitchName


# 3. Conectar las NICs del resto de VMs con nombre 'Management*' al switch
foreach ($VMName in $VMnames) {

    # Obtener todas las NICs de la VM cuyo nombre empiece por 'Management'
    $NetAdapters = Get-VMNetworkAdapter -Name $AdapterPrefix -VMName $VMName

    # Conectar las NICs de la VM al switch
    Connect-VMNetworkAdapter -Name $NetAdapters.Name -VMName $VMName -SwitchName $VMSwitchName

}


# 4. Arrancar las VMs
Start-HVVM -Name $DC
Start-HVVM -Name $VMNames