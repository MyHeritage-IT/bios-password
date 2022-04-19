powershell (Get-WmiObject -Namespace root/hp/InstrumentedBIOS -Class HP_BIOSSetting ^| Where-Object Name -eq 'Setup Password').IsSet
