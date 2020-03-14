#requires -Modules Hyper-V


# Script para parar un laboratorio después de realizar pruebas. No es lo mismo que eliminar el lab, que se haría con Cleanup.ps1

# 1. Apagar las VMs
# 2. Eliminar el switch virtual (Las VM's se quedan sin switch configurado, pero se vuelven a conectar con '5_Start Lab.ps1'


# Ejecutar en el Host Hyper-V ó en cliente W10


# Importar modulo Hyper-V con prefijo, para distinguir comandos con el mismo nombre de VMware
Import-Module -Prefix HV -Name Hyper-V


# Valores
$VMHost = 'Animp10'
$AdapterPrefix = 'Management*'
$VMSwitchName = 'WSLab3-Switch'
$VMNames = 'WSLab3-DC', 'WSLab3-S2D1', 'WSLab3-S2D2', 'WSLab3-S2D3', 'WSLab3-S2D4', 'WSLab3-Win10-1', 'WSLab3-Win10-2', 'WSLab3-Win10-3', 'WSLab3-Win10-4'


# 1. Apagar las VMs
Stop-HVVM -Name $VMNames -CimSession $VMHost


# 2. Eliminar el switch (si existe)
if (Get-VMSwitch -Name $VMSwitchName -CimSession $VMHost -ErrorAction SilentlyContinue) {
    Remove-VMSwitch -Name $VMSwitchName -CimSession $VMHost -Force -Confirm:$false
}

