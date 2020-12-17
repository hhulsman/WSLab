

# Instrucciones de cómo preparar laboratorios con WSLab

# El código está en:
# - Documents\Visual Studio Code Projects\WSLab:		Código oficial, que va a github (HHulsman/WSLab)
# - Documents\Visual Studio Code Projects\WSLab\HHH:	Código específico HHH


#region Para empezar desde cero
#
#	Tener descargado las ISO's de W2016, W2019, Win10, versiones evaluación, y sus Actualizaciones Cumulativas y Servicing Updates.
#   Guardar (2016) en:
#   - "\\Animsa9\Instalaciones\Software\Microsoft\Windows Server 2016"
#   - "\\Animsa9\Instalaciones\Software\Microsoft\Windows Server 2016\Actualizaciones"
#	
#	
#	- Descargar proyecto desde https://github.com/microsoft/WSLab.github
#	
#		Abrir VSCode
#		Cerrar Workspace si hay uno abierto
#		
#		# Initial setup
#		Set-Location -Path "D:\Users\hhulsman\Documents\Visual Studio Code Projects"
#		git clone https://github.com/microsoft/WSLab.git
#		git remote rename origin upstream
#		git remote add origin https://github.com/hhulsman/WSLab
#		
#		# Create new branch
#		git pull upstream master                        # Actualizar por si acaso
#		git checkout -b Localize						# Create local branch
#		git remote push origin Localize					# Create remote branch
#		git push --set-upstream origin Localize			# Config upstream for new branch
#	
#	
#		# Setup on new machine, once the repository on Github exists
#		Set-Location -Path "D:\Users\hhulsman\Documents\Visual Studio Code Projects"
#		git clone https://github.com/microsoft/WSLab.git
#		git remote rename origin upstream
#		git remote add origin https://github.com/hhulsman/WSLab
#		
#endregion
	
	
#region Preparar el primer Lab (WSLab1)
#
#   Ejecutar todo en Host (ANIMP10, ANIMP11, ...)	
#
#	- Copiar todo el contenido de WSLab\HHH-New a destino (\\ANIMC01\ClusterStorage$\Volume3\WSLab\WSLab1):
#		- Renombrar Labconfig-WSLabx.ps1 a LabConfig.ps1 en destino
#		- Borrar resto ficheros LabConfig-WSLabx.ps1 en destino
#	
#	- Ejecutar 1_Prereqs.ps1 (en host ANIMPxx)
#
#	- Ejecutar 2_CreateParentDisks.ps1
#       - Esto crea los discos padre, y el DC del laboratorio
#       - Al final, cuando pregunta si quiere hacer cleanup, contestar 'Y'
#
#   - Mover WSLab\WSLab1\ParentDisks a WSLab\ParentDisks.
#       - Sirve para dejar los discos creados disponible para múltiples labs
#       - Luego será utilizado con el parámetro ServerParentPath en LabConfig, en Deploy.ps1
#	
#	- Si se va a necesitar VMs con Windows 10:
#		- Ejecutar ParentDisks\CreateParentDisks.ps1 (este script se ha creado en el paso 2_CreateParentDisks)
#       - Seleccionar ISO desde "\\animsa9\Instalaciones\Software\Microsoft\Windows 10\Windows 10 ISOs"
#       - Opcionalmente seleccionar MSU (actualizaciones). No es necesario
#       - Seleccionar versión de Windows 10 (Windows 10 Pro)
#		- Cuando solicita el nombre del fichero a generar (poner: Win10_G2.vhdx (incluir la extensión))
#	
#	- Ejecutar Deploy.ps1
#       - Esto arranca la DC, y crea el resto de las VMs (pero no las arranca)
#		- Revisar LabConfig.ps1 por número de servidores y puestos de trabajo
#		- Se puede volver a ejecutar este script si posteriormente se quiere añadir más máquinas virtuales
#
#	- Ejecutar 4_StartLab.ps1 (Crea el switch si no existe y arranca VMs)
#
#	- Ejecutar 5_PostDeploy.ps1 (habilita RDP en DC etc.)
#       - Esperar hasta que todas las VMs han terminado de arrancar del paso anterior
#	
#   - Iniciar sesión en DC
#	    - Abrir Powershell ISE en modo admin
#	    - Copiar y ejecutar Scenarioxxxx.ps1. Esto crea el clúster y S2D, o instala WAC, etc.
#	
#   - Posteriormente se puede apagar y volver a encender el lab con los siguientes scripts:
#	    - 4_StartLab.ps1 (Crea el switch si no existe y arranca VMs)
#	    - 6_StopLab.ps1 (Elimina el switch y apaga VMs)
#
#   - También se puede eliminar el lab y volver a crear con:
#	    - Cleanup.ps1 (Apaga el DC, y elimina switch y VMs (pero no los parentdisks, ni el DC))
#       - Posteriormente se puede desplegar de nuevo con Deploy.ps1, seguido por 4_StartLab.ps1, 5_PostDeploy.ps1 y Scenarioxxxx.ps1
#
#endregion


#region Para crear un segundo lab
#	
#	- Comprobar que los Parent disks se han movido a WSLab\ParentDisks (en el apartado de arriba)
#	- Comprobar que está especificado el parámetro ServerParentPath en LabConfig
#   - Ejecutar Cleanup.ps1 en el Lab de origen (WSLab1). Importante, si no, fallará Deploy.ps1
#	- Copiar WSLab1 a WSLab2; sólo:
#       - Los scripts
#		- El directorio LAB\DC (pero no LAB\VMs)
#	- Modificar WSLab2\LabConfig.ps1:
#		- Cambiar prefijo WSLab1 por WSLab2
#	- Ejecutar Deploy.ps1, 4_StartLab.ps1, y  5_PostDeploy.ps1
#	- Nota: NO ejecutar Deploy.ps1 para 2 Labs simultáneamente: $env:tmp\Temp\mountdir es el mismo para ambos
#
#endregion


#region Para añadir máquinas Windows 10
#	
#	- Después de ejecutar 2_CreateParentDisks.ps1 se ha creado el fichero CreateParentDisk.ps1 en el directorio ParentDisks.
#	- Ejcutarlo, no requiere ningún LabConfig.ps1. Pide la ISO de Windows 10, y la edición de una lista
#	- Después se puede incluir la especificación en el fichero LabConfig.ps1, y volver a ejecutar Deploy.ps1. Se crearán automáticamente las VMs adicionales
#
#endregion


#region Configurar Git Triangle Workflow
#
#	(Pull from microsoft/WSLab (upstream) y push to hhulsman/WSlab (origin)):
#	        git config remote.pushdefault origin
#	        git config push.default current
#
#endregion