

#Constantes
    # $DHCPServer = 'Animsa26'
    $IPRange    = '172.18.'


#Load LabConfig....
    . "$PSScriptRoot\LabConfig.ps1"


#Set variables
    If (!$LabConfig.DomainNetbiosName){
        $LabConfig.DomainNetbiosName="Corp"
    }

#Grab DC
    $DC = Get-VM -Name ($LabConfig.Prefix+"DC")


#Credentials for Session
    $username = "$($Labconfig.DomainNetbiosName)\$($LabConfig.LocalAdminUser)"
    $password = $LabConfig.AdminPassword
    $secstr = New-Object -TypeName System.Security.SecureString
    $password.ToCharArray() | ForEach-Object {$secstr.AppendChar($_)}
    $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $secstr


#Get DC Hostname
    # $DCHostName = Invoke-Command -VMGuid $DC.id -Credential $cred  -ScriptBlock { [System.Net.Dns]::GetHostByName($env:computerName).HostName }


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
            # Set-Service -Name wuauserv -StartupType Automatic # No es necesario
            # Cscript c:\windows\system32\scregedit.wsf /AU 4     # Poner en instalación automática. Otros valores: 1 = Manual, 3 = Sólo descarga
            # Cscript c:\windows\system32\scregedit.wsf /AU /v    # Ver el estado
    
    }


#Return DC IPAddress
    $DCDhcpAddress = Invoke-Command -VMGuid $DC.id -Credential $cred  -ScriptBlock {
        Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -match $using:IPRange } 
    }


    Write-Output "The IP address of the $($DC.Name) is $($DCDhcpAddress.IPAddress)"
