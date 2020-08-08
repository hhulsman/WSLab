

Para crear entorno S2D, usar 'Scenarios\S2D Hyperconverged\Scenario.ps1'

Antes: desde DC conectar a disco ClusterStorage para poder seleccionar parentdisks:
    net use k: \\animp11\c$\clusterstorage /user:animsauine\jefe

Una vez creado el espacio
- repasar network y pruebas en http://aka.ms/ConvergedRDMA
- también https://docs.microsoft.com/en-us/windows-server/virtualization/hyper-v-virtual-switch/rdma-and-switch-embedded-teaming
- ejecutar Test-ClusterHealth de VMFleet
- también mirar Test-RDMA script de Diskspd
- también Test-Rdma.ps1 from https://docs.microsoft.com/en-us/windows-server/networking/technologies/conv-nic/cnic-app-troubleshoot
- también hay comandos útiles en https://www.dell.com/support/article/es-es/how16693/c%C3%B3mo-configurar-rdma-hu%C3%A9sped-en-windows-server-2019?lang=es
- reflejar en Scenario definitivo
- Crear script con tests para comprobar todo (ya hay algo en 'verify networking')

Estructura Network:
- Tarjetas físicas:
    Get-NetAdapter | Where-Object HardwareInterface -EQ $true
    Get-NetAdapter Ethernet | fl *  # (detalle)
- Switch virtual:
    Get-VMSwitch SETSwitch | fl *
    Get-VMSwitch SETSwitch | select Name, NetAdapterInterfaceDescriptions # (conectado a 2 tarjetas físicas)
- Team:
    Get-NetLbfoTeam
    Get-VMNetworkAdapterTeamMapping -ManagementOS # (muestra tarjetas físicas mapeados y su tarjeta virtual correspondiente (parentadapter))
    Get-VMSwitchTeam # (muestra switch y tarjetas físicas)
- Tarjetas virtuales:
    Get-NetAdapter | Where-Object HardwareInterface -EQ $false
    Get-VMNetworkAdapter -ManagementOS
    Get-VMNetworkAdapter -ManagementOS - Name Mgmt | fl *
- Load Balancing Mode:
    Para Set Teams y Packet Direct (RDMA?) tiene que ser 'HyperVPort'

SRIOV y RDMA: Ambos 'pasan' del vswitch

SRIOV:
- Qué es? Permite que tráfico de red 'pasa' del switch virtual. Elimina overhead
- Info: https://vswitchzero.com/2019/06/19/an-in-depth-look-at-sr-iov-nic-passthrough
-       https://www.veeam.com/blog/hyperv-set-management-using-powershell.html
-       https://docs.microsoft.com/en-us/windows-hardware/drivers/network/overview-of-single-root-i-o-virtualization--sr-iov-
- Primero habilitar en host ANIMPxx, BIOS --> Hecho, parece
- Get-NetAdapterSriov --> Enabled = True. Muestra tarjetas físicas
- Get-VMSwitch | Select Name, IovEnabled, IovSupport, IovSupportReasons
- Pero apunta a "Default Switch" --> Investigar ***(hasta aquí he llegado)
- Luego en las tarjetas virtuales de las VMs (no en los switches virtuales, no tienen esta opción)

RDMA:
- Escribir directamente en memoria de uno a otro. ROCE e iWarp
- https://docs.microsoft.com/en-us/windows-hardware/drivers/network/background-reading-on-rdma


Antes de poner en producción:
- Repasar todos los settings en Scenario.ps1, hasta línea 112
- Get-VMSwitch - | fl * --> Mirar valor de IovSupport, e IovSupportReasons