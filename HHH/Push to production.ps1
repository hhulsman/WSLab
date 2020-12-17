# Push to production

$LabName    = "WSLab5"
$LabFile    = "LabConfig-$($LabName).ps1"
$LabDir     = "\\ANIMC01\ClusterStorage$\Volume3\WSLab\$LabName"

# Crear directorio destino si no existe
if (!(Test-Path -Path $LabDir -ErrorAction SilentlyContinue)) {
    New-Item -Path $LabDir -ItemType Directory
}
# Copiar todo el contenido de Scripts a $Labdir
Copy-Item .\Scripts\*.ps1 $LabDir

# Eliminar el fichero original LabConfig.ps1
Remove-item -Path $LabDir\LabConfig.ps1

# Renombrar LabConfig-WSLabxxx a LabConfig.ps1
Rename-Item -Path $LabDir\$LabFile -NewName "LabConfig.ps1" -Force

break

# Copiar Scenario.ps1 a WSLabn-DC
Copy-Item '.\Scenarios\S2D Hyperconverged\Scenario.ps1' '\\172.18.2.30\C$\Users\LabAdmin\Documents'