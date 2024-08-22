#NAV
import-module 'C:\Program Files\Microsoft Dynamics NAV\100\Service\NavAdminTool.ps1' | out-null
Mount-NavTenant -ServerInstance NAV2017 -DefaultTimeZone 'W. Europe Standard Time' -Id 'a0956' -DatabaseName 'ACCNAV2017PROJONTW-0956' -DatabaseServer 'VBWNLSQL341.dm100.local' -AllowAppDatabaseWrite -OverwriteTenantIdInDatabase

#BC14
Import-module 'C:\Program Files\Microsoft Dynamics 365 Business Central\140\Service\NavAdminTool.ps1' | out-null
Mount-NavTenant -ServerInstance BC14 -DefaultTimeZone 'W. Europe Standard Time' -Id 'a0955' -DatabaseName 'ACCNAV2017BOUW-0955' -DatabaseServer 'VBWNLSQL341.dm100.local' -AllowAppDatabaseWrite -OverwriteTenantIdInDatabase

