<!-- TOC -->

- [Overview](#overview)
- [Creating VM with PowerShell](#creating-vm-with-powershell)
- [Creating VM with JSON in UI](#creating-vm-with-json-in-ui)
    - [Windows Server 2019](#windows-server-2019)
    - [Windows 10 20H2](#windows-10-20h2)
- [Creating VM with JSON and PowerShell](#creating-vm-with-json-and-powershell)
    - [Windows Server 2019](#windows-server-2019-1)
    - [Windows 10 20H2](#windows-10-20h2-1)
- [Cleanup the VM and resources](#cleanup-the-vm-and-resources)
    - [Windows Server 2019](#windows-server-2019-2)
    - [Windows 10 20H2](#windows-10-20h2-2)
- [Creating VM Manually](#creating-vm-manually)
    - [Adding premium disk (bit pricey)](#adding-premium-disk-bit-pricey)
- [Overall experience](#overall-experience)

<!-- /TOC -->

# Overview

I was always wondering how fast will be Azure VM to host WSLab since we [announced](https://azure.microsoft.com/en-us/blog/nested-virtualization-in-azure/) availability of nested virtualization in Azure. Thanks to @DaveKawula tweet I decided to give it a try as i have MSDN subscription with ~130eur credit/month

You can find here several options on how to create a VM in Azure that is capable to run WSLab. I learned something new, I hope you will too. It will configure Hyper-V roles and download and extract scripts to d:\ drive.

**Note:** I recommend reverse engineering [JSON](/Scenarios/Running%20WSLab%20in%20Azure/WSLab.json) as you can learn how to configure VMs in Azure.

I also added Windows 10 20H2 machine. You will see provisioning errors, but all works well (looks like it does not evaluate state correctly after enabling Hyper-V with DISM PowerShell module)

# Creating VM with PowerShell

To create VM with PowerShell, run following command.

**Note:** PowerShell DSC in this case does not run, therefore you need to install Hyper-V and download scripts manually.

```PowerShell
#set-execution policy to remote signed for current process
if ((Get-ExecutionPolicy) -ne "RemoteSigned"){Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force}

#download Azure module
if (!(Import-Module -Name Az -ErrorAction Ignore)){
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Install-Module -Name AZ -Force
}

Login-AzAccount -UseDeviceAuthentication

#select context if more available
$context=Get-AzContext -ListAvailable
if (($context).count -gt 1){
    $context | Out-GridView -OutputMode Single | Set-AzContext
}

#Create VM
New-AzVM `
    -ResourceGroupName "WSLabRG" `
    -Name "WSLab" `
    -Location "WestEurope" `
    -VirtualNetworkName "WSLabVirtualNetwork" `
    -SubnetName "WSLab" `
    -SecurityGroupName "WSLabSG" `
    -PublicIpAddressName "WSLabPubIP" `
    -OpenPorts 80,3389 `
    -ImageName Win2019Datacenter `
    -Size Standard_E16_v3 `
    -Credential (Get-Credential) `
    -Verbose

#connect to VM using RDP
mstsc /v:((Get-AzPublicIpAddress -ResourceGroupName WSLabRG).IpAddress)
 
```

# Creating VM with JSON in UI

## Windows Server 2019

[![](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FMicrosoft%2FWSLab%2Fdev%2FScenarios%2FRunning%2520WSLab%2520in%2520Azure%2FWSLab.json)
[![](http://armviz.io/visualizebutton.png)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com/Microsoft/WSLab/master/Scenarios/Running%20WSLab%20in%20Azure/WSLab.json)

## Windows 10 20H2

[![](http://azuredeploy.net/deploybutton.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FMicrosoft%2FWSLab%2Fdev%2FScenarios%2FRunning%2520WSLab%2520in%2520Azure%2FWSLabwin10.json)
[![](http://armviz.io/visualizebutton.png)](http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com/Microsoft/WSLab/master/Scenarios/Running%20WSLab%20in%20Azure/WSLabwin10.json)

![](/Scenarios/Running%20WSLab%20in%20Azure/Screenshots/CustomizedTemplate.png)

# Creating VM with JSON and PowerShell

Or you can create your VM using PowerShell

## Windows Server 2019

```PowerShell
#set-execution policy to remote signed for current process
if ((Get-ExecutionPolicy) -ne "RemoteSigned"){Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force}

#download Azure module
if (!(Get-Command -Name Login-AzAccount -ErrorAction Ignore)){
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Install-Module -Name AZ -Force
}

Login-AzAccount -UseDeviceAuthentication

#Deploy VM to Azure using Template
    New-AzResourceGroup -Name "WSLabRG" -Location "westeurope"
    $TemplateUri="https://raw.githubusercontent.com/Microsoft/WSLab/master/Scenarios/Running%20WSLab%20in%20Azure/WSLab.json"
    New-AzResourceGroupDeployment -Name WSLab -ResourceGroupName WSLabRG -TemplateUri $TemplateUri -Verbose

#connect to VM using RDP
    mstsc /v:((Get-AzPublicIpAddress -ResourceGroupName WSLabRG).IpAddress)
 
```

## Windows 10 20H2

```PowerShell
#set-execution policy to remote signed for current process
if ((Get-ExecutionPolicy) -ne "RemoteSigned"){Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force}

#download Azure module
if (!(Get-Command -Name Login-AzAccount -ErrorAction Ignore)){
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
    Install-Module -Name AZ -Force
}

Login-AzAccount -UseDeviceAuthentication

#Deploy VM to Azure using Template
    New-AzResourceGroup -Name "WSLabwin10RG" -Location "westeurope"
    $TemplateUri="https://raw.githubusercontent.com/Microsoft/WSLab/master/Scenarios/Running%20WSLab%20in%20Azure/WSLabwin10.json"
    New-AzResourceGroupDeployment -Name WSLabwin10 -ResourceGroupName WSLabwin10RG -TemplateUri $TemplateUri -Verbose

#connect to VM using RDP
    mstsc /v:((Get-AzPublicIpAddress -ResourceGroupName WSLabwin10RG).IpAddress)
 
```

![](/Scenarios/Running%20WSLab%20in%20Azure/Screenshots/TemplatePowerShellDeployment.png)

# Cleanup the VM and resources

To cleanup your resources, you can run following command.

## Windows Server 2019

```PowerShell
Get-AzVM -Name WSLab -ResourceGroupName WSLabRG | Remove-AzVM -verbose #-Force
Get-AzResource | Where-Object Name -like WSLab* | Remove-AzResource -verbose #-Force
Get-AzResourceGroup | Where-Object resourcegroupname -eq WSLabRG | Remove-AzResourceGroup -Verbose #-Force
 
```

## Windows 10 20H2

```PowerShell
Get-AzVM -Name WSLabwin10 -ResourceGroupName WSLabwin10RG | Remove-AzVM -verbose #-Force
Get-AzResource | Where-Object name -like WSLabwin10* | Remove-AzResource -verbose #-Force
Get-AzResourceGroup | Where-Object resourcegroupname -eq WSLabwin10RG | Remove-AzResourceGroup -Verbose #-Force
 
```

# Creating VM Manually
To create VM, click on New and select Windows Server 2019 VM.

**Note:** this applies to Windows Server 2019 only. Win10 machine with GUI is not available in this size.

![](/Scenarios/Running%20WSLab%20in%20Azure/Screenshots/CreateVM01.png)

Provide some basic input, such as username and password you will use to connect to the VM.

![](/Scenarios/Running%20WSLab%20in%20Azure/Screenshots/CreateVM02.png)

The only machines with nested virtualization are D and E v3 machines. In MSDN you can consume up to 20 cores, therefore I selected D16S V3.

![](/Scenarios/Running%20WSLab%20in%20Azure/Screenshots/CreateVM03.png)

Select managed disks and also don't forget to enable Auto-Shutdown. Auto-Shutdown is really cool feature. Helps a lot managing costs of your lab. 

![](/Scenarios/Running%20WSLab%20in%20Azure/Screenshots/CreateVM04.png)

Validate the settings and click on Create

![](/Scenarios/Running%20WSLab%20in%20Azure/Screenshots/CreateVM05.png)

Once VM will finish deploying, you will be able to see it running on your dashboard.

![](/Scenarios/Running%20WSLab%20in%20Azure/Screenshots/CreateVM06.png)

## Adding premium disk (bit pricey)

**Note:** Premium disk is not the best choice as it drains your credit quite fast. So either use it and destroy, or use temp storage instead. You can store WSLab on OS and just copy to temp disk to deploy it there.

To add storage, click on add data disk under disks.

![](/Scenarios/Running%20WSLab%20in%20Azure/Screenshots/AddStorage01.png)

You will be able to specify disk. Since I did not have disk created, you can click on Create disk and wizard will open.

![](/Scenarios/Running%20WSLab%20in%20Azure/Screenshots/AddStorage02.png)

In wizard configure 4TB disk, just to have 7500 IOPS.

![](/Scenarios/Running%20WSLab%20in%20Azure/Screenshots/AddStorage03.png)

After disk is configured, you can configure host caching to Read/Write (since you don't care about loosing data)

![](/Scenarios/Running%20WSLab%20in%20Azure/Screenshots/AddStorage04.png)

# Overall experience

I recommend using temp drive D: as its fast enough. After parent disk hydration, you can copy lab to c:\

**Data disappeared after shutting down a VM**
![](/Scenarios/Running%20WSLab%20in%20Azure/Screenshots/TempDrive.png)

**I prefer to keep WSLab on c:\ and copy it to temp drive on machine resume**
![](/Scenarios/Running%20WSLab%20in%20Azure/Screenshots/CopyToTempDrive.png)

In machine overview you are able to connect (after click it will download rdp file with server IP in it), or you can just copy IP to clip and run remote desktop client from your pc. To cut down cots, you can stop VM from here

![](/Scenarios/Running%20WSLab%20in%20Azure/Screenshots/VMOverview.png)

Network is quite fast. Downloading image from eval center is ~ 200Mbits. I was able to see here also speeds around 500Mbits. I guess its because limited speed of source during the day in US.

![](/Scenarios/Running%20WSLab%20in%20Azure/Screenshots/DownloadSpeeds.png)

Performance during file copy inside S2D cluster was quite impressive. Usually its around 200MB/s. On this screenshot you can see peak almost 800MB/s

![](/Scenarios/Running%20WSLab%20in%20Azure/Screenshots/S2DSpeed.png)

Hydration of ws2016 lab took 81 minutes

DC and 4 s2d nodes takes 5,6 minutes

![](/Scenarios/Running%20WSLab%20in%20Azure/Screenshots/S2DClusterHydration.png)

Scenario finishes in ~32 minutes

![](/Scenarios/Running%20WSLab%20in%20Azure/Screenshots/S2DClusterScenarioScript.png)

Enjoy!

![](/Scenarios/Running%20WSLab%20in%20Azure/Screenshots/S2DClusterScenarioScriptFinished.png)