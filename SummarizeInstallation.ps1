# Script to show all apps in a 4PS Construct Business Central database
# Created by 4PS-MB / DKMV4PS

$BCVersion      = '210' # Business Central version, i.e. '150' ~ '210'
$ServerInstance = 'BC210Empty' # Name of the NST

Import-Module "C:\Program Files\Microsoft Dynamics 365 Business Central\$BCVersion\Service\NavAdminTool.ps1"

'default' | ForEach-Object{
            Get-NavAppInfo `
                -ServerInstance $ServerInstance `
                -Tenant $_ `
                -TenantSpecificProperties | Sort-Object -Property Name, Version | `
                    Select-Object -Property ID, Name, Publisher, IsPublished, SyncState,NeedsUpgrade, IsInstalled, ExtensionDataVersion, Version, Scope | `
                    Format-Table | Out-String | Write-host
        }
