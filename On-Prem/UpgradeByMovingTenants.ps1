Import-Module 'C:\Program Files\Microsoft Dynamics 365 Business Central\170\Service\NavAdminTool.ps1' # Change version if nessecery, i.e. '150' or '160'.

$ServerInstance   = 'Tinus170'
$DatabaseServer   = 'localhost\SQL2019'
$DataBase         = 'CONTOSO170'

Set-NAVServerInstance -ServerInstance $ServerInstance -Stop -Force

Export-NAVApplication –DatabaseServer $DatabaseServer –DatabaseName $DataBase –DestinationDatabaseName 'BC170APP'

Remove-NAVApplication –DatabaseServer $DatabaseServer –DatabaseName $DataBase

Set-NAVServerConfiguration -ServerInstance $ServerInstance -KeyName 'DatabaseName' -KeyValue 'BC170APP'
Set-NAVServerConfiguration -ServerInstance $ServerInstance -KeyName 'Multitenant' -KeyValue 'True'

Set-NAVServerInstance -ServerInstance $ServerInstance -Start

Mount-NAVApplication –ServerInstance $ServerInstance –DatabaseServer $DatabaseServer –DatabaseName 'BC170APP'

Mount-NAVTenant –ServerInstance $ServerInstance -Id default –DatabaseServer $DatabaseServer -DatabaseName $DataBase -AllowAppDatabaseWrite -OverwriteTenantIdInDatabase

Mount-NAVTenant –ServerInstance $ServerInstance -Id KLANT1 –DatabaseServer $DatabaseServer -DatabaseName KLANT1 -OverwriteTenantIdInDatabase
Mount-NAVTenant –ServerInstance $ServerInstance -Id KLANT2 –DatabaseServer $DatabaseServer -DatabaseName KLANT2 -OverwriteTenantIdInDatabase

Get-NAVTenant -ServerInstance $ServerInstance


'default' | ForEach-Object{
            Get-NavAppInfo `
                -ServerInstance $ServerInstance `
                -Tenant $_ `
                -TenantSpecificProperties | Sort-Object -Property Name, Version | `
                    Select-Object -Property AppId, Name, Publisher, IsPublished, SyncState,NeedsUpgrade, IsInstalled, ExtensionDataVersion, Version | `
                    Format-Table | Out-String | Write-host
        }
'klant1' | ForEach-Object{
            Get-NavAppInfo `
                -ServerInstance $ServerInstance `
                -Tenant $_ `
                -TenantSpecificProperties | Sort-Object -Property Name, Version | `
                    Select-Object -Property AppId, Name, Publisher, IsPublished, SyncState,NeedsUpgrade, IsInstalled, ExtensionDataVersion, Version | `
                    Format-Table | Out-String | Write-host
        }
'klant2' | ForEach-Object{
            Get-NavAppInfo `
                -ServerInstance $ServerInstance `
                -Tenant $_ `
                -TenantSpecificProperties | Sort-Object -Property Name, Version | `
                    Select-Object -Property AppId, Name, Publisher, IsPublished, SyncState,NeedsUpgrade, IsInstalled, ExtensionDataVersion, Version | `
                    Format-Table | Out-String | Write-host
        }

Sync-NAVTenant –ServerInstance $ServerInstance -Tenant klant2 -Force
Sync-NAVApp –ServerInstance $ServerInstance -Tenant klant2 -Name "System Application"
Sync-NAVApp –ServerInstance $ServerInstance -Tenant klant2 -Name "4PS Construct NL"
Sync-NAVApp –ServerInstance $ServerInstance -Tenant klant2 -Name "Application"
Sync-NAVApp –ServerInstance $ServerInstance -Tenant klant2 -Name "4PS WebShop Basket Connector Base NL"
Get-NavAppInfo `
    -ServerInstance $ServerInstance `
    -Tenant KLANT2 `
    | ForEach-Object{
        Sync-NAVApp –ServerInstance $ServerInstance -Tenant klant2 -Name $_.Name
    }
Get-NavAppInfo `
    -ServerInstance $ServerInstance `
    -Tenant KLANT2 `
    | ForEach-Object{
        Start-NAVAppDataUpgrade -ServerInstance $ServerInstance -Tenant klant2 -Name $_.Name -SkipVersionCheck -ErrorAction Stop
    }


Sync-NAVTenant –ServerInstance $ServerInstance -Tenant default -Force
Sync-NAVTenant –ServerInstance $ServerInstance -Tenant klant1 -Force

Sync-NAVApp –ServerInstance $ServerInstance -Tenant klant1 -Name "System Application"
Sync-NAVApp –ServerInstance $ServerInstance -Tenant klant1 -Name "4PS Construct NL"
Sync-NAVApp –ServerInstance $ServerInstance -Tenant klant1 -Name "Application"
Sync-NAVApp –ServerInstance $ServerInstance -Tenant klant1 -Name "4PS WebShop Basket Connector Base NL"


Invoke-Sqlcmd -ServerInstance $DatabaseServer -Database klant2 -Query "DELETE FROM [KLANT2].[dbo].[Object Metadata Snapshot] WHERE [Name] = 'GS1 Purchase Order Log'"


Sync-NAVApp –ServerInstance $ServerInstance -Tenant klant2 -Name "4PS CES NL"
Sync-NAVApp –ServerInstance $ServerInstance -Tenant klant2 -Name "4PS OpenWeatherMap Site Manager W1"
