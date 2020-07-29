

# Lab para instalar Windows Admin Center

# Origen: https://github.com/microsoft/WSLab/blob/master/Scenarios/Windows%20Admin%20Center%20Deployments

# Ejecutar en DC ó en equipo de administración (Win10)
# Para reinstalar o renovar el certificado, sólo ejecutar los pasos 3 y 4

# Para reinstalar con un certificado existente, se puede buscar el certificado con:
# Get-ChildItem -Path Cert:\LocalMachine\my | where {'AdminCenter' -in $_.DnsNameList} | select ThumbPrint, DnsName, NotBefore, NotAfter | Sort NotBefore
# $cert = (Get-ChildItem -Path Cert:\LocalMachine\my | where {'AdminCenter' -in $_.DnsNameList} | select ThumbPrint, DnsName, NotBefore, NotAfter | sort notbefore -Descending)[0]


# Nota: Se ha permitido ENROLL para Animsa33$ en el servidor CA (Animsa24), en el paso 2
#       Comprobar si es necesario, con el siguiente servidor


# 1. Install RSAT on Management machine
# 2. Install and configure ADCS role on the domain controller
# 3. Generate a certificate
# 4. Install Windows Admin Center
# 5. Run Windows Admin Center


#region 0. Constantes
$Entorno = 'WSLab'
$Entorno = 'AnimsaUine'

switch ($Entorno) {
    'WSLab' {
        $DCName    = 'DC'
        $WACServer = 'S2D1'
        $Cred      = Get-Credential Corp\LabAdmin
    }
    'AnimsaUine' {
        $DCName    = 'Animsa24'
        $WACServer = 'Animsa33'
        $Cred      = Get-AnimCredential jefe@animsa.uine
    }
    default {
        Write-Warning 'Entorno sin definir'
        exit
    }
}

#endregion

#region 1. Install RSAT on Management machine

    # First, we will check if RSAT is installed (it's necessary to work with servers remotely). If you did not provide RSAT msu
    # (downloaded from http://aka.ms/RSAT) during the lab hydration, we need to install it manually now.
    
    if ((Get-HotFix).HotFixId -notcontains "KB2693643"){
        Invoke-WebRequest -UseBasicParsing -Uri "https://download.microsoft.com/download/1/D/8/1D8B5022-5477-4B9A-8104-6A71FF9D98AB/WindowsTH-RSAT_WS_1803-x64.msu" -OutFile "$env:USERPROFILE\Downloads\WindowsTH-RSAT_WS_1803-x64.msu"
        Start-Process -Wait -Filepath "$env:USERPROFILE\Downloads\WindowsTH-RSAT_WS_1803-x64.msu" -Argumentlist "/quiet"
    }

#endregion
 

#region 2. Install and configure ADCS role on the domain controller

    # On domain controller DC install ADCS role, and after role installation we need to allow issuing certificates of WebServer template.
    # To simplify our lab scenario, we will allow every computer in lab's Active Directory domain to enroll a certificate using the WebServer template.
    
     Invoke-Command -ComputerName $DCName -ScriptBlock {
        # Install ADCS role
        Add-WindowsFeature Adcs-Cert-Authority -IncludeManagementTools
        Install-AdcsCertificationAuthority -Force -CAType EnterpriseRootCa -HashAlgorithmName SHA256 -CACommonName "Lab-Root-CA"
    
        # Install PSPKI module for managing Certification Authority
        Install-PackageProvider -Name NuGet -Force
        Install-Module -Name PSPKI -Force
        Import-Module PSPKI
    
        # Allow Domain Computers and Domain Controllers to enroll WebServer certificates
        Get-CertificateTemplate -Name WebServer |
            Get-CertificateTemplateAcl |
            Add-CertificateTemplateAcl -User "Equipos del dominio" -AccessType Allow -AccessMask Read, Enroll |
            Add-CertificateTemplateAcl -User "Controladores de dominio" -AccessType Allow -AccessMask Read, Enroll |
            Set-CertificateTemplateAcl
    }

#endregion


#region 3. Generate a certificate

    # Certification Authority would be used to issue signed certificates for the Windows Admin Center instances.
    
    # In order to use own certificate instead of default self-signed one, certificate needs to be generated before actually
    # installing Windows Admin Center and certificate needs to be imported in Computer store of that machine.
    
    # Tiene que ser una sesión con CredSSP
    $PSSession = New-AnimCredSSPSession -ComputerName $WACServer -Credential $Cred
    
    # Invoke-Command -ComputerName "S2D1" -ScriptBlock {
    Invoke-Command -Session $PSSession -ScriptBlock {
        # Enforce presence of the root certificate
        certutil -pulse
    
        # Create certificate with SAN for both FQDN and hostname, and other optional ones
        $DNSNames = @(
            $env:COMPUTERNAME
            (Resolve-DnsName -Name $env:COMPUTERNAME | Select-Object -First 1).Name
            'AdminCenter'               # Opcional
            'AdminCenter.animsa.uine'   # Opcionales
            'AdminCenter.ayto.dns'
            'AdminCenter.animsa.es'
        )
        $cert = Get-Certificate -Template WebServer -DnsName $DNSNames -CertStoreLocation cert:\LocalMachine\My
    
        # Certificate's thumbprint needs to be specified in the installer later
        $cert.Certificate.Thumbprint
    }

#endregion


#region 4. Install Windows Admin Center

    # Download Windows Admin Center if not present
    if (-not (Test-Path -Path "$env:USERPROFILE\Downloads\WindowsAdminCenter.msi")){
        Invoke-WebRequest -UseBasicParsing -Uri https://aka.ms/WACDownload -OutFile "$env:USERPROFILE\Downloads\WindowsAdminCenter.msi"
    }
    
    # Copy to target
    Copy-Item -Path "$env:USERPROFILE\Downloads\WindowsAdminCenter.msi" -Destination "$env:USERPROFILE\Downloads\WindowsAdminCenter.msi" -ToSession $PSSession
    
    # Install Windows Admin Center#Install Windows Admin Center (Da problemas en Animsa33, corta la pssession. Probar: Sesión sín CredSSP)
    Invoke-Command -Session $PSSession -ScriptBlock {
        Start-Process msiexec.exe -Wait -ArgumentList "/i $env:USERPROFILE\Downloads\WindowsAdminCenter.msi /qn /L*v log.txt REGISTRY_REDIRECT_PORT_80=1 SME_PORT=443 SME_THUMBPRINT=$($cert.Certificate.Thumbprint) SSL_CERTIFICATE_OPTION=installed"
    }

    Invoke-Command -Session $PSSession -ScriptBlock {
        if ((Get-Service -Name ServerManagementGateway -ErrorAction SilentlyContinue).Status -eq 'Stopped') {
            Start-Service -Name ServerManagementGateway
        }
    }

#endregion


#region 5. Run Windows Admin Center

    # Para acceder a WAC hace falta Edge, Firefox o Chrome. En este caso se usa Firefox (instalar primero)
    Start-Process -FilePath "C:\Program Files\Mozilla Firefox\Firefox.exe" -ArgumentList "http://S2D1.corp.contoso.com"

#endregion
