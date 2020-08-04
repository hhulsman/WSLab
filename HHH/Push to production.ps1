# Push to production

$LabVersion = "WSLab4"
$LabFile    = "LabConfig-$($LabVersion).ps1"
$LabDir     = "\\ANIMC01\ClusterStorage$\Volume3\WSLab\$LabVersion"

# Copiar todo el contenido de Scripts a $Labdir
Copy-Item .\Scripts\*.ps1 $LabDir

# Eliminar el fichero original LabConfig.ps1
Remove-item -Path $LabDir\LabConfig.ps1

# Renombrar LabConfig-WSLabxxx a LabConfig.ps1
Rename-Item -Path $LabDir\$LabFile -NewName "LabConfig.ps1" -Force
