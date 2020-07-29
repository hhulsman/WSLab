
# Ejecutar en Host Hyper-V donde está el Lab

#region General

    # Habilita RDP
    # Devuelve IP address of DC in 172.18 range (Red Animsa)
    
    #Constantes
        # $DHCPServer = 'Animsa26'
        $IPRange    = '172.18.'
    
    
    #Load LabConfig....
        . "$PSScriptRoot\LabConfig.ps1"


    #Set variables
        If (!$LabConfig.DomainNetbiosName){
            $LabConfig.DomainNetbiosName="Corp"
        }
    
  
    #Credentials for Session
        # $username = "$($Labconfig.DomainNetbiosName)\$($LabConfig.LocalAdminUser)" # (Ha sido un typo?)
        $username = "$($Labconfig.DomainNetbiosName)\$($LabConfig.DomainAdminName)"
        $password = $LabConfig.AdminPassword
        $secstr = New-Object -TypeName System.Security.SecureString
        $password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}
        $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $secstr
    
    
    #Get DC Hostname
        # $DCHostName = Invoke-Command -VMGuid $DC.id -Credential $cred  -ScriptBlock { [System.Net.Dns]::GetHostByName($env:computerName).HostName }

#endregion

#region DC
    
    #Grab DC
    $DC = Get-VM -Name ($LabConfig.Prefix+"DC")
    

    # Configure Ping, IPv6, RDP, RPC, Windows Upate
        Invoke-Command -VMGuid $DC.id -Credential $cred  -ScriptBlock {
    
                Param( $Domain, [SecureString] $Cred )
        
                # Disable IPv6
                # Get-NetAdapterBinding -ComponentID ‘ms_tcpip6’ | Disable-NetAdapterBinding -ComponentID ‘ms_tcpip6’ -PassThru
        
                # Habilitar Administración Remota de Windows
                # Enable-NetFirewallRule -DisplayGroup "Administración remota de Windows*"
                # Enable-NetFirewallRule -DisplayGroup "Administración remota de registro de eventos"
                # Enable-NetFirewallRule -DisplayGroup "Administración remota de servicios"
        
                # Habilitar Escritorio Remoto
                Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
                Enable-NetFirewallRule -DisplayGroup "Escritorio remoto"
        
                # Habilitar RPC
                # Enable-NetFirewallRule -name RVM-RPCSS-In-TCP,RVM-VDSLDR-In-TCP,RVM-VDS-In-TCP
        
                # Poner actualizaciones de Windows en Automático
                Set-Service -Name wuauserv -StartupType Automatic     # No es necesario, por si acaso
                Cscript c:\windows\system32\scregedit.wsf /AU 4       # Poner en instalación automática. Otros valores: 1 = Manual, 3 = Sólo descarga
                # Cscript c:\windows\system32\scregedit.wsf /AU /v    # Ver el estado
        
                # Instalar cliente Telnet
                Install-WindowsFeature -Name 'Telnet-Client'
        }
    
    
    #Return DC IPAddress
    $DCDhcpAddress = Invoke-Command -VMGuid $DC.id -Credential $cred  -ScriptBlock {
        Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -match $using:IPRange } 
    }
    
    
    Write-Output "The IP address of the $($DC.Name) is $($DCDhcpAddress.IPAddress)"
    
#endregion

#region Servidores SD2 y Puestos Win10

    foreach ($VMName in $LabConfig.VMs.VMName) {

        #Grab VM
        $VM = Get-VM -Name ($LabConfig.Prefix + $VMName)


        # Configure Ping, IPv6, RDP, RPC, Windows Upate
        Invoke-Command -VMGuid $VM.id -Credential $cred  -ScriptBlock {
        
            Param( $Domain, [SecureString] $Cred )

            Get-NetFirewallRule -Name "*ICMP4*" | Enable-NetFirewallRule
                
            # Disable IPv6
            # Get-NetAdapterBinding -ComponentID ‘ms_tcpip6’ | Disable-NetAdapterBinding -ComponentID ‘ms_tcpip6’ -PassThru
    
            # Habilitar Administración Remota de Windows
            # Enable-NetFirewallRule -DisplayGroup "Administración remota de Windows*"
            # Enable-NetFirewallRule -DisplayGroup "Administración remota de registro de eventos"
            # Enable-NetFirewallRule -DisplayGroup "Administración remota de servicios"
    
            # Habilitar Escritorio Remoto
            Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -value 0
            Enable-NetFirewallRule -DisplayGroup "Escritorio remoto"
    
            # Habilitar RPC
            # Enable-NetFirewallRule -name RVM-RPCSS-In-TCP,RVM-VDSLDR-In-TCP,RVM-VDS-In-TCP
    
            # Poner actualizaciones de Windows en Automático (servidores. Windows 10 pendiente)
            Set-Service -Name wuauserv -StartupType Automatic     # No es necesario, por si acaso
            
            # Sólo en servidores:
            if ($env:COMPUTERNAME -match "S2D") {
                Cscript c:\windows\system32\scregedit.wsf /AU 4       # Poner en instalación automática. Otros valores: 1 = Manual, 3 = Sólo descarga
                # Cscript c:\windows\system32\scregedit.wsf /AU /v    # Ver el estado
            }
    
            # Habilitar cliente Telnet
            if ($env:COMPUTERNAME -match "S2D") {
                # Instalar cliente Telnet (servidores)
                if (!((Get-Windowsfeature "Telnet-Client").Installed)) {
                    Install-WindowsFeature -Name 'Telnet-Client'
                }
            }
            elseif ($env:COMPUTERNAME -match "Win10")  {
                # Instalar cliente Telnet (Win10)
                if (!((Get-WindowsOptionalFeature -FeatureName "TelnetClient" -Online).State -eq 'Enabled')) {
                    Enable-WindowsOptionalFeature -FeatureName 'TelnetClient' -Online
                }
            }
            else {
                Write-Warning "El nombre del equipo no incluye 'S2D' ni 'Win10'. Compruebe el script"
            }
        }
    }


#endregion