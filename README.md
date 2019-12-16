[![WSLab in MVPDays](/Screenshots/S2DSimulations_presentation_thumb.png)](https://youtu.be/u7d6Go8weBc)

[![WSLab in CDCGernabt](/Screenshots/WSLab_Datacenter_Simulation_presentation_thumb.png)](https://youtu.be/5IX9OLEk50Q)

<!-- TOC -->

- [Project Description](#project-description)
- [Videos](#videos)
- [HowTo](#howto)
    - [Step 1 Download required files (prerequisites)](#step-1-download-required-files-prerequisites)
        - [Scripts](#scripts)
        - [Windows Server 2016](#windows-server-2016)
        - [or Windows Server 2019](#or-windows-server-2019)
        - [or Windows Server Insider Preview](#or-windows-server-insider-preview)
        - [Optionally you can download SCVMM 2019 files](#optionally-you-can-download-scvmm-2019-files)
    - [Step 2 Create folder and Unzip scripts there](#step-2-create-folder-and-unzip-scripts-there)
    - [Step 3 (Optional) Check the LabConfig.ps1](#step-3-optional-check-the-labconfigps1)
    - [Step 4 Right-click and run with PowerShell 1_Prereq.ps1](#step-4-right-click-and-run-with-powershell-1_prereqps1)
    - [Step 5 (optional) Copy SCVMM files (or your tools) to toolsVHD folder](#step-5-optional-copy-scvmm-files-or-your-tools-to-toolsvhd-folder)
    - [Step 6 Right-click and run with PowerShell 2_CreateParentDisks.ps1](#step-6-right-click-and-run-with-powershell-2_createparentdisksps1)
    - [Step 7 Right-click and run with PowerShell Deploy.ps1](#step-7-right-click-and-run-with-powershell-deployps1)
    - [Step 8 Continue with S2D Hyperconverged Scenario](#step-8-continue-with-s2d-hyperconverged-scenario)
    - [Step 9 Cleanup lab with Cleanup.ps1](#step-9-cleanup-lab-with-cleanupps1)
    - [Step 10 Try different scenarios](#step-10-try-different-scenarios)
- [Tips and tricks](#tips-and-tricks)
- [Known issues](#known-issues)
- [So what is it good for?](#so-what-is-it-good-for)

<!-- /TOC -->

# Project Description

 * Deployment Automation of Windows Server labs on WS2016/Windows10 Hyper-V
 * Simply deploy your lab just with these scripts and ISO file.
 * Lab can run LAB on Windows 10, Windows Server 2016 (both Core and GUI) or even in [Azure VM](/Scenarios/Running%20WSLab%20in%20Azure)
 * Major differentiator is that once hydrated (first 2 scripts), deploy takes ~5 minutes. Cleanup is ~10s.
 * Options for setting up a Windows Server 2016-based lab are simpler than other available lab automation systems as the project is based on Powershell scripts rather than XML or DSC configuration files.
 * Scripts are not intentionally doing everything. You can spend nice time studying scenarios.
 * This solution is used in Microsoft Premier Workshop for Software Defined Storage, Hyper-V and System Center VMM. If you have Premier Contract, contact your TAM and our trainers can deliver this workshop for you.
 * Follow [#wslab](https://twitter.com/search?f=tweets&vertical=default&q=%23wslab) hash tag to get latest news.

 * Check [this](https://github.com/Microsoft/WSLab/tree/master/Scenarios) page for end to end scenarios!

# Videos

Note: Some videos may be a bit outdated as there is continuous innovation going on in the scripts.

* [1 Prereq and Create Parent disks](https://youtu.be/705A-mCvzUc)
* [2 Basic S2D Scenario Walkthrough](https://youtu.be/cAOCcTjlkm4)
* [3 LabConfig.ps1 deep dive](https://youtu.be/qX42Yj6_dSA)
* [4 Windows Server Insider and Honolulu](https://youtu.be/Rj_uhDN0tN4)
* [5 Virtual Machine Manager 1711 and Windows Server 1709](https://youtu.be/NTrncW2omSY)
* [6 S2D Disaster recovery - one node OS lost](https://youtu.be/Gd9_rzePrhI)
* [7 S2D Disaster recovery - all nodes OS lost](https://youtu.be/uTzXEFVd16o)
* [8 S2D Bare metal deployment with SCVMM](https://youtu.be/K81qLv7lLuE)

# HowTo

## Step 1 Download required files (prerequisites)

### Scripts

* [Scripts](https://github.com/Microsoft/WSLab/blob/master/scripts.zip?raw=true)

### Windows Server 2016

* [ISO](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2016)
* [Latest Cumulative Update](https://www.catalog.update.microsoft.com/Search.aspx?q=2019%20Cumulative%20Update%20for%20Windows%20Server%202016%20for%20x64-based%20Systems) for Windows Server 2016 and [Servicing Stack Update](http://aka.ms/2016ssu)

### or Windows Server 2019

* [ISO](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2019)
* [Latest Cumulative Update](http://catalog.update.microsoft.com/v7/site/Search.aspx?q=Cumulative%20Update%20for%20Windows%20Server%202019%20for%20x64-based%20Systems%20) for Windows Server 2019 and [Servicing Stack Update](http://aka.ms/2019ssu)

### or Windows Server Insider Preview

* [LTSC ISO](https://www.microsoft.com/en-us/software-download/windowsinsiderpreviewserver)

NOTE: There is no LTSC available yet. In 17744 was a bug, so during deployment process DC creation takes forewer. Workaround is to just log in as corp\Administrator to DC and it magically finishes.

### Optionally you can download SCVMM 2019 files

Note: watch entire process how to deploy SCVMM [here](https://youtu.be/NTrncW2omSY?list=PLf9T7wfY_JD2UpjLXoYNcnu4rc1JSPfqE) (bit outdated)

* [ADK 1809 and ADKwinPE 1809](https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install) Note: you need to run adksetup.exe and download all files and place it to tools disk. Not just setup.exe. Same applies to adkwinpesetup.exe.

* [SCVMM 2019](https://www.microsoft.com/en-us/evalcenter/evaluate-system-center-release)

* [SQL 2017](https://www.microsoft.com/en-us/evalcenter/evaluate-sql-server-2017-rtm)


### Tip: You can download CU and UR using DownloadLatestCU script

You will find this script in CreateParentDisks folder

![](/Screenshots/DownloadLatestCUs.gif)


## Step 2 Create folder and Unzip scripts there

![](/Screenshots/ScriptsExtracted.png)

## Step 3 (Optional) Check the LabConfig.ps1

* Edit LabConfig.ps1 to specify the lab setup that you require (such as different domain name, Domain Admin name...). This script file documents the available configuration options. (The default script will generate a lab with a Windows Server 2016 DataCenter Domain Controller and 4 Windows Server 2016 Core servers ready to be set up with Storage Spaces Direct.)

**Default Labconfig**

![](/Screenshots/LabConfig.png)

**Default Labconfig with collapsed sections (ctrl+M)**

![](/Screenshots/LabConfigCollapsed.png)

**Advanced LabConfig (deleted lines 1-16)**

![](/Screenshots/LabConfigAdvanced.png)

## Step 4 Right-click and run with PowerShell 1_Prereq.ps1
 * 1_Prereq.ps1 will create a folder structure and will download necessary files from the internet.
 * If your server does not have an internet connection, run this on an internet connected machine, copy created files over ,and run 1_prereq.ps1 again.

![](/Screenshots/1_Prereq.png)

**Result**

![](/Screenshots/1_PrereqResult1.png)

**Result: Tools folder created**

![](/Screenshots/1_PrereqResult2.png)

**CreateParentDisk tool, DSC modules and ToolsVHD folder**

![](/Screenshots/ToolsCreateParentDisk.png)

## Step 5 (optional) Copy SCVMM files (or your tools) to toolsVHD folder
 * If you modified labconfig.ps1 in Step 3 to deploy SCVMM, populate the `temp\ToolsVHD\SCVMM` folder. If you downloaded SCVMM trial, run the exe file to extract it. Extract SCVMM Update Rollups (extract MSP files from cabs).

 * You can copy your favorite tools to ToolsVHD, that's always mounted to DC, or to any machine in the lab.

**SCVMM Folders in ToolsVHD folder**

![](/Screenshots/ToolsVHDFolderSCVMM1.png)

![](/Screenshots/ToolsVHDFolderSCVMM2.png)

## Step 6 Right-click and run with PowerShell 2_CreateParentDisks.ps1

 * 2_CreateParentDisks.ps1 will check if you have Hyper-V installed, it will prompt you for Windows Server ISO file, and it will ask for packages (provide Cumulative Update and Servicing Stack Update). After, it will hydrate parent disks and Domain Controller.
 * A Domain controller is provisioned using DSC. Requires time to deploy, but after that you do not need to run this step anymore as DC is saved, and returned to previous state before deploy step.

![](/Screenshots/2_CreateParentDisks.png)

**ISO Prompt**

![](/Screenshots/2_CreateParentDisksISOPrompt.png)

**MSU Prompt**

![](/Screenshots/2_CreateParentDisksMSUPrompt.png)

**Result: Script finished**

![](/Screenshots/2_CreateParentDisksResultCleanup3.png)

**Result: Script cleanup unnecessary folders - before**

![](/Screenshots/2_CreateParentDisksResultCleanup2.png)

**Result: Script cleanup unnecessary folders - after**

![](/Screenshots/2_CreateParentDisksResultCleanup4.png)

**Result: Parent disks are created**

![](/Screenshots/2_CreateParentDisksResultParentDisks.png)

**Result: DC, thats imported during deploy, is Created**

![](/Screenshots/2_CreateParentDisksResultDC.png)

## Step 7 Right-click and run with PowerShell Deploy.ps1

 * Deploy.ps1 will deploy servers specified by Labconfig.ps1. By default, it will deploy servers for S2D Hyperconverged [scenario](https://github.com/Microsoft/WSLab/tree/master/Scenarios).

![](/Screenshots/Deploy.png)

**Result**

![](/Screenshots/DeployResultOverview.png)
 
## Step 8 Continue with S2D Hyperconverged Scenario

* [S2D Hyperconverged Scenario page](https://github.com/Microsoft/WSLab/tree/master/Scenarios/S2D%20Hyperconverged)
* You will be guided to deploy 4 Node Storage Spaces Direct cluster.
* Note: scenario is completely separate script. You use it when logged into DC. Spend time observing what it does as you can easily learn from it. If you are not in rush, run it line by line in PowerShell or PowerShell ISE and use a GUI to observe changes to understand what is happening.

## Step 9 Cleanup lab with Cleanup.ps1

* VMs and switch are identified using prefix defined in LabConfig.
* All VMs\Switches with prefix are listed.

![](/Screenshots/Cleanup.png)

![](/Screenshots/Cleanup1.png)

![](/Screenshots/Cleanup2.png)

## Step 10 Try different scenarios

* [Scenarios page](https://github.com/Microsoft/WSLab/tree/master/Scenarios/)
* Just replace LabConfig and Deploy again (takes 5-10 minutes to spin up new VMs).

# Tips and tricks

* In the tools folder, CreateParentDisk.ps1 script is created. You can use this anytime to create additional parent disks (such as Server with GUI or Windows 10). Just right-click and run with PowerShell

![](/Screenshots/ToolsCreateParentDisk.png)

* If you want to run scripts on Server Core, modify labconfig and use ServerISOFolder and ClientISOFolder variables (MSUs are optional).
* Disable Defender during CreateParentDisks as AMSI is scanning scripts and utilizing the CPU. (Takes twice more time to create parent disks).
* Every script is creating a transcript file. You can look for issues there.
* If you want internet connection, just specify Internet=$true in Labconfig.

# Known issues

* DISM does not work on Cluster Shared Volumes.
* When waiting on DC to come online, the script throws red errors by design. There is nothing to worry about.
* DISM may throw errors on NTFS volumes. Just build the lab again in different folder.
* Sometimes if all machines are started at once, some are not domain joined. Just cleanup and deploy again.

# So what is it good for?

Simulations such as
* how to script against servers
* how to automate configuration
* what will happen when I run this and that command
* how change drive in S2D cluster
* what will happen when one node goes down
* testing new features before pushing to production
* ...
