$LabConfig=@{ DomainAdminName='LabAdmin'; AdminPassword='LS1setup!' ; <#Prefix = 'WSLab-'#> ; DCEdition='4'; Internet=$true ; TelemetryLevel='Full' ; TelemetryNickname='' ; AdditionalNetworksConfig=@(); VMs=@()}

1..4 | ForEach-Object {$LABConfig.VMs += @{ VMName = "AzSHCI$_" ; Configuration = 'S2D' ; ParentVHD = 'AzSHCI20H2_G2.vhdx' ; HDDNumber = 10 ; HDDSize= 10TB ; MemoryStartupBytes= 1GB; VMProcessorCount="Max" }}
#Or with nested virtualization enabled
#1..4 | ForEach-Object {$LABConfig.VMs += @{ VMName = "AzSHCI$_" ; Configuration = 'S2D' ; ParentVHD = 'AzSHCI20H2_G2.vhdx' ; HDDNumber = 10 ; HDDSize= 10TB ; MemoryStartupBytes= 4GB; VMProcessorCount="Max" ; NestedVirt=$true}}

#Optional Windows Admin Center in GW mode
$LabConfig.VMs += @{ VMName = 'WACGW' ; ParentVHD = 'Win2019Core_G2.vhdx'; MGMTNICs=1}