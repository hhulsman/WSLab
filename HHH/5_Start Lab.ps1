#requires -Modules Hyper-V


# Script para arrancar un laboratorio

# 1. Crear el switch virtual
# 2. Conectar las NICs con nombre 'Management*' al switch
# 3. Arrancar las VMs

# Ejecutar en el Host Hyper-V ó en cliente W10


# Importar modulo Hyper-V con prefijo, para distinguir comandos con el mismo nombre de VMware
Import-Module -Prefix HV -Name Hyper-V


# Valores
$VMHost = 'Animp10'
$AdapterPrefix = 'Management*'
$VMSwitchName = 'WSLab3-Switch'
$VMNames = 'WSLab3-DC', 'WSLab3-S2D1', 'WSLab3-S2D2', 'WSLab3-S2D3', 'WSLab3-S2D4', 'WSLab3-Win10-1', 'WSLab3-Win10-2', 'WSLab3-Win10-3', 'WSLab3-Win10-4'


# 1. Crear el switch, si no existe
if (!(Get-VMSwitch -Name $VMSwitchName -CimSession $VMHost -ErrorAction SilentlyContinue)) {
    New-VMSwitch -SwitchType Private -Name $VMSwitchName -CimSession $VMHost
}


# 2. Conectar las NICs con nombre 'Management*' al switch
foreach ($VMName in $VMnames) {

    # Obtener todas las NICs de la VM cuyo nombre empiece por 'Management'
    $NetAdapters = Get-VMNetworkAdapter -Name $AdapterPrefix -VMName $VMName -CimSession $VMHost

    # Conectar las NICs de la VM al switch
    Connect-VMNetworkAdapter -Name $NetAdapters.Name -VMName $VMName -SwitchName $VMSwitch.Name -CimSession $VMHost

}

# 3. Arrancar las VMs
Start-HVVM -Name $VMNames -CimSession $VMHost

break

    # Eliminar el switch, al final del ejercicio
    Remove-VMSwitch -Name $VMSwitchName -CimSession $VMHost -Force -Confirm:$false
