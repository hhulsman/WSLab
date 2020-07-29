
$LabConfig = @{
    DomainAdminName             = 'LabAdmin'
    AdminPassword               = 'Pamplona1'
    LocalAdminUser              = 'Administrador'
    LocalAdminGroup             = 'Administradores'
    DomainAdminGroup            = 'Admins. del dominio'
    SchemaAdminGroup            = 'Administradores de esquema'
    EnterpriseAdminGroup        = 'Administradores de organización'
    VMIntegrationServiceName    = 'Interfaz de servicio invitado'
    Prefix                      = 'WSLab3-'
    SwitchName                  = 'Switch'
    DCEdition                   = '4'
    DCVMProcessorCount          = 4
    Internet                    = $true
    ServerISOFolder             = "\\Animsa9\Instalaciones\Software\Microsoft\Windows Server 2016"
    ServerMSUsFolder            = "\\Animsa9\Instalaciones\Software\Microsoft\Windows Server 2016\Actualizaciones"
    EnableGuestServiceInterface = $true
    GuestServiceInterfaceName   = "Interfaz de servicio invitado"
    AdditionalNetworksConfig    = @()
    VMs                         = @()
    ServerParentPath            = "C:\ClusterStorage\Volume3\WSLab\ParentDisks"  # In case the parent disks are not under $PSScriptRoot. Useful in case of multiple labs over one set of parentdisks
}

1..4 | ForEach-Object {
    $VMNames                    = "S2D"
    $LABConfig.VMs += @{
        VMName                  = "$VMNames$_"
        Configuration           = 'S2D'
        ParentVHD               = 'Win2016Core_G2.vhdx'
        SSDNumber               = 2
        SSDSize                 = 960GB
        HDDNumber               = 4
        HDDSize                 = 4TB
        MemoryStartupBytes      = 2GB
        NestedVirt              = $True
    }
}

$LABConfig.VMs += @{ VMName = 'Win10-1'; Configuration = 'Simple'; ParentVHD = 'Win10_G2.vhdx'; MemoryStartupBytes= 1GB; AddToolsVHD=$True; DisableWCF=$True }
$LABConfig.VMs += @{ VMName = 'Win10-2'; Configuration = 'Simple'; ParentVHD = 'Win10_G2.vhdx'; MemoryStartupBytes= 1GB; AddToolsVHD=$True; DisableWCF=$True }
