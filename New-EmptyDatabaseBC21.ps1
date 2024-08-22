#Variabeles
$BCVersion        = '210'
$DatabaseServer   = 'localhost'
$DatabaseInstance = ''
$ServerInstance   = 'BC210Empty'
$Tenant           = 'BC21TEN'
$AppDataBase      = 'BC21APP'
$BakFilePath      = "C:\Install\4PS\Demo Database BC (21-0).bak"
$SystemAppFile    = "C:\Install\4PS\System.app"
$MicrosoftSysFile = "C:\Install\4PS\Microsoft_System Application.app"
$LicenseFile      = "C:\Install\4PS\BC21scripts\MigrationScripts\License\DEV\DevelopmentLicense_BC21.bclicense"

#SQL data locations
$DataFilePath     = "C:\MSSQL\Data"
$LogFilePath      = "C:\MSSQL\Log"

#Other variabeles
#$SQLInstance = "{0}\{1}" -f ($DatabaseServer, $DatabaseInstance)
$SQLInstance = $DatabaseServer

$startdatetime = Get-Date

Import-Module "C:\Program Files\Microsoft Dynamics 365 Business Central\$BCVersion\Service\NavAdminTool.ps1" # Change version if nessecery, i.e. '150' or '160'.

#$SQLService = 'MSSQL${0}' -f ($DatabaseInstance)
#Start-Service $SQLService # 15.0.2070.41

#Create new database based on .bak file
Write-Host ("Create new database based on .bak file...") -ForegroundColor yellow
New-NAVDatabase `
    -DatabaseServer $DatabaseServer `
    -DatabaseInstance $DatabaseInstance `
    -DatabaseName $Tenant `
    -FilePath $BakFilePath `
    -DataFilesDestinationPath $DataFilePath `
    -LogFilesDestinationPath $LogFilePath

#Create new ServerInstance
Write-Host ("Create new ServerInstance...") -ForegroundColor yellow
New-NAVServerInstance `
    -ManagementServicesPort 7045 `
    -ClientServicesPort 7046 `
    -SOAPServicesPort 7047 `
    -ODataServicesPort 7048 `
    -DeveloperServicesPort 7049 `
    -DatabaseServer $DatabaseServer `
    -DatabaseInstance $DatabaseInstance `
    -DatabaseName $Tenant `
    -ServiceAccount NetworkService `
    -ServerInstance $ServerInstance

#Invoke-NAVApplicationDatabaseConversion
Write-Host ("Invoke-NAVApplicationDatabaseConversion...") -ForegroundColor yellow
Invoke-NAVApplicationDatabaseConversion -DatabaseServer $SQLInstance -DatabaseName $Tenant -Force

#Start ServerInstance
Write-Host ("Start ServerInstance...") -ForegroundColor yellow
Start-NAVServerInstance `
    -ServerInstance $ServerInstance

#Import license file
Write-Host ("Import license file...") -ForegroundColor yellow
Import-NAVServerLicense $ServerInstance -LicenseData ([Byte[]]$(Get-Content -Path $LicenseFile -Encoding Byte)) -Database 2

#Restart ServerInstance
Write-Host ("Restart ServerInstance...") -ForegroundColor yellow
Restart-NAVServerInstance `
    -ServerInstance $ServerInstance `
    -Force

#Sync NAVTenant
Write-Host ("Sync NAVTenant...") -ForegroundColor yellow
Sync-NAVTenant `
    -ServerInstance $ServerInstance `
    -Force

#Remove all companies
Write-Host ("Remove all companies...") -ForegroundColor yellow
Get-NAVCompany `
    -ServerInstance $ServerInstance | `
    ForEach-Object {
        Remove-NAVCompany -ServerInstance $ServerInstance -CompanyName $_.CompanyName -ForceImmediateDataDeletion -Force
    }

#Uninstall all apps
Write-Host ("Uninstall all apps...") -ForegroundColor yellow
Get-NAVAppInfo `
    -ServerInstance $ServerInstance | `
    ForEach-Object {
        Uninstall-NAVApp -ServerInstance $ServerInstance -Name $_.Name -Force -DoNotSaveData -WarningAction SilentlyContinue
        Sync-NAVApp -Mode Clean -ServerInstance $ServerInstance -Name $_.Name -Force -WarningAction SilentlyContinue
    }

#Unpublish all apps
Write-Host ("Unpublish all apps...") -ForegroundColor yellow
Do {
    $Installedapps = Get-NAVAppInfo -ServerInstance $ServerInstance | Select-Object -Property Name, Publisher, Version, Scope |ft
    Get-NAVAppInfo `
        -ServerInstance $ServerInstance | `
        ForEach-Object {
            Unpublish-NAVApp -ServerInstance $ServerInstance -Name $_.Name -ErrorAction SilentlyContinue
        }
}
Until( $Installedapps.count -eq '0' )

#Install new apps
Write-Host ("Publish new apps...") -ForegroundColor yellow
Publish-NAVApp `
    -ServerInstance $ServerInstance `
    -Path $SystemAppFile `
    -PackageType SymbolsOnly `
    -SkipVerification
Publish-NAVApp `
    -ServerInstance $ServerInstance `
    -Path $MicrosoftSysFile `
    -Scope Global `
    -SkipVerification

Write-Host ("Sync new apps...") -ForegroundColor yellow
Sync-NAVApp `
    -ServerInstance $ServerInstance `
    -Name 'System Application'

Write-Host ("Install new apps...") -ForegroundColor yellow
Install-NAVApp `
    -ServerInstance $ServerInstance `
    -Name "System Application"

#Stop ServerInstance
Write-Host ("Stop ServerInstance...") -ForegroundColor yellow
Stop-NAVServerInstance `
    -ServerInstance $ServerInstance

#Go Multitenant
Write-Host ("Export application to App database...") -ForegroundColor yellow
Export-NAVApplication –DatabaseServer $SQLInstance –DatabaseName $Tenant –DestinationDatabaseName $AppDataBase
Write-Host ("Delete application from tenant database...") -ForegroundColor yellow
Remove-NAVApplication –DatabaseServer $SQLInstance –DatabaseName $Tenant -Force

Write-Host ("Set NST to MultiTenant...") -ForegroundColor yellow
Set-NAVServerConfiguration -ServerInstance $ServerInstance -KeyName 'Multitenant' -KeyValue $true
Write-Host ("Set NST to new App Database...") -ForegroundColor yellow
Set-NAVServerConfiguration -ServerInstance $ServerInstance -KeyName 'DatabaseName' -KeyValue $AppDataBase

#Start ServerInstance
Write-Host ("Start ServerInstance...") -ForegroundColor yellow
Start-NAVServerInstance `
    -ServerInstance $ServerInstance

#Mount tenant
Write-Host ("Mount tenant...") -ForegroundColor yellow
Mount-NAVTenant `
    –ServerInstance $ServerInstance `
    -Id $Tenant `
    –DatabaseServer $SQLInstance `
    -DatabaseName $Tenant `
    -OverwriteTenantIdInDatabase `
    -AlternateId $Tenant `
    -DisplayName $Tenant `
    -EnvironmentName $Tenant `
    -AllowAppDatabaseWrite

Write-Host ("Sync-NAVTenant...") -ForegroundColor yellow
Sync-NAVTenant -ServerInstance $ServerInstance -Tenant $Tenant -Force

Write-Host ("Start-NAVDataUpgrade...") -ForegroundColor yellow
Start-NAVDataUpgrade -ServerInstance $ServerInstance -Tenant $Tenant -Force
Get-NAVDataUpgrade -ServerInstance $ServerInstance -Tenant $Tenant

#Import license
Write-Host ("Import license file...") -ForegroundColor yellow
Import-NAVServerLicense `
    -ServerInstance $ServerInstance `
    -LicenseFile $LicenseFile `
    -Tenant $Tenant `
    -Database Tenant

#Summarize Installation
Write-Host ("Summarize Installation...") -ForegroundColor yellow
$Tenant | ForEach-Object{
            Get-NavAppInfo `
                -ServerInstance $ServerInstance `
                -Tenant $_ `
                -TenantSpecificProperties | Sort-Object -Property Name, Version | `
                    Select-Object -Property Name, Publisher, IsPublished, SyncState,NeedsUpgrade, IsInstalled, ExtensionDataVersion, Version, Scope | `
                    Format-Table | Out-String | Write-host
        }

<#
    #Dismount tenant
    Write-Host ("Dismount Tenant...") -ForegroundColor yellow
    Dismount-NAVTenant `
        -ServerInstance $ServerInstance `
        -Tenant $Tenant `
        -Force

    #Remove ServerInstance
    Write-Host ("Remove ServerInstance...") -ForegroundColor yellow
    Remove-NAVServerInstance `
        -ServerInstance $ServerInstance `
        -Force
#>

$duration = '{0}.' -f ((Get-Date)-$startdatetime)
$message  = 'Proces completed in '+$duration
Write-Host ("$message") -ForegroundColor green
