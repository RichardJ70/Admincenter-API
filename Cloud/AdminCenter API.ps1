#### This powershell script can be used for the most common admin center tasks  ####
#### for both single environments and multi environments within the same tenant ####
####                                                                            ####
#### To be able to use the admin center API check the learning portal           ####

#Shared Parameters
$adminVersion = "V2.21"
$applicationFamily = "4PSConstruct"

######### Login #############
$authContext = New-BcAuthContext -includeDeviceLogin
$accessToken = $authContext.AccessToken
Write-Host -ForegroundColor Cyan 'Authentication complete - we have an access token for Business Central, and it is stored in the $accessToken variable.'

######### ENVIRONMENT MANAGEMENT ##################
# Get list of active environments
$response = Invoke-WebRequest `
    -Method Get `
    -Uri    "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/environments" `
    -Headers @{Authorization=("Bearer $accessToken")}
Write-Host -ForegroundColor Green 'Active BVGO environments'
ConvertFrom-Json $response.Content | Select-Object -ExpandProperty value | Select-Object -Property name, type, applicationfamily, applicationversion, status, platformversion | where-object {($_.status -eq 'Active')} |Format-Table | Out-String | Write-Host

# Delete Sandbox environment
# BE cAREFULL: NO QUESTIONS ASKED !!!! #
$environmentNameToDelete = "Fill in the environment name to delete"
$response = Invoke-WebRequest `
    -Method Delete `
    -Uri    "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments/$environmentNameToDelete" `
    -Headers @{Authorization=("Bearer $accessToken")} 
write-host -ForegroundColor Green 'Environment' $environmentNameToDelete 'is deleted'
ConvertFrom-Json $response.Content

# Recover Deleted Environment
$environmentNameToRecover = "Fill in the environment name to recover"
$response = Invoke-WebRequest `
    -Method Post `
    -Uri    "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments/$environmentNameToRecover/recover" `
    -Headers @{Authorization=("Bearer $accessToken")} 
write-host -ForegroundColor Green 'Environment' $environmentNameToRecover 'is recovered'
ConvertFrom-Json $response.Content

# Rename Environment
$environmentNameToRename = "Fill in the environment name to rename"
$newenvironmentName = "Fill in the new environment name"
$response = Invoke-WebRequest `
    -Method Post `
    -Uri    "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments/$environmentNameToRename/rename" `
    -Body   (@{
                 NewEnvironmentName = $newenvironmentName
              } | ConvertTo-Json) `
    -Headers @{Authorization=("Bearer $accessToken")} `
    -ContentType "application/json"
Write-Host -ForegroundColor Green 'Environment' $environmentNameToRename 'is renamed to' $newenvironmentName
ConvertFrom-Json $response.Content

# Copy production environment to a sandbox environment
$environmentNameProduction = "Fill in the production environment name"
$newEnvironmentNameSandbox = "Fill in the new sandbox environment name"
$response = Invoke-WebRequest `
    -Method Post `
    -Uri    "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments/$environmentNameProduction/copy" `
    -Body   (@{
                 EnvironmentName = $newEnvironmentNameSandbox
                 Type            = "Sandbox"
              } | ConvertTo-Json) `
    -Headers @{Authorization=("Bearer $accessToken")} `
    -ContentType "application/json"
Write-Host -ForegroundColor Green 'Environment' $newEnvironmentNameSandbox 'is created as a sandbox environment from production environment' $environmentNameProduction
ConvertFrom-Json $response.Content

### Copy Settings from Production to Sandbox ###
## Security Group
# Get security group production environment
$environmentNameProduction = "Fill in the production environment name"
$newEnvironmentNameSandbox = "Fill in the new sandbox environment name"
$response = Invoke-WebRequest `
    -Method Get `
    -Uri    "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments/$environmentNameProduction/settings/securitygroupaccess" `
    -Headers @{Authorization=("Bearer $accessToken")} `
    -ContentType "application/json"
$securitygroup = ConvertFrom-Json $response.Content

# Set same security group to new sandbox
$response = Invoke-WebRequest `
    -Method Post `
    -Uri    "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments/$newEnvironmentNameSandbox/settings/securitygroupaccess" `
    -Body   (@{
                 Value = $securitygroup.id
              } | ConvertTo-Json) `
    -Headers @{Authorization=("Bearer $accessToken")} `
    -ContentType "application/json"
Write-Host -ForegroundColor Green 'Security Group' $securitygroup.id 'is set to sandbox environment' $newEnvironmentNameSandbox

## Application Insights Key
# Get Application Insights Key production environment
# Not supported

# Set Application Insights Key to new sandbox.
# This will restart the environment
$environmentNameSandbox = "Fill in the environment name"
$appInsightsKey = "InstrumentationKey=0ac1fc71-d01d-4600-93af-ba26df180cb5;IngestionEndpoint=https://westeurope-4.in.applicationinsights.azure.com/;LiveEndpoint=https://westeurope.livediagnostics.monitor.azure.com/;ApplicationId=4d5d877f-2a44-4d1e-8f9b-c8f4b91efc66"
$response = Invoke-WebRequest `
    -Method Post `
    -Uri    "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments/$environmentNameSandbox/settings/appinsightskey" `
    -Body   (@{
                 key = $appInsightsKey
              } | ConvertTo-Json) `
    -Headers @{Authorization=("Bearer $accessToken")} `
    -ContentType "application/json"
Write-Host -ForegroundColor Green 'Application Insights Key is set to sandbox environment' $environmentNameSandbox

############# Single Environment Apps #################
############# MAJOR RELEASES #################
# Get update window
$environmentNameSandbox = "Fill in the environment name"
$response = Invoke-WebRequest `
    -Method Get `
    -Uri    "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments/$environmentNameSandbox/settings/upgrade" `
    -Headers @{Authorization=("Bearer $accessToken")}
Write-host -ForegroundColor Green 'Update window for environment' $environmentNameSandbox
ConvertFrom-Json $response.Content

# Set update window
$environmentNameSandbox = "Fill in the environment name"
$preferredStartTimeUtc = "2024-08-21T14:30:00Z"
$preferredEndTimeUtc   = "2024-08-22T01:00:00Z"
$response = Invoke-WebRequest `
    -Method Put `
    -Uri    "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments/$environmentNameSandbox/settings/upgrade" `
    -Body   (@{
                 preferredStartTimeUtc = $preferredStartTimeUtc
                 preferredEndTimeUtc   = $preferredEndTimeUtc
              } | ConvertTo-Json) `
    -Headers @{Authorization=("Bearer $accessToken")} `
    -ContentType "application/json"
Write-Host -ForegroundColor Green 'Update window is set for environment' $environmentNameSandbox
ConvertFrom-Json $response.Content

# Get scheduled updates
$environmentNameSandbox = "Fill in the environment name"
$response = Invoke-WebRequest `
    -Method Get `
    -Uri    "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments/$environmentNameSandbox/upgrade" `
    -Headers @{Authorization=("Bearer $accessToken")}
if ($response.StatusCode -eq 204) {
    Write-Host -ForegroundColor Red 'No scheduled updates for environment' $environmentNameSandbox
} else {
    Write-Host -ForegroundColor Green 'Scheduled updates for environment' $environmentNameSandbox
    ConvertFrom-Json $response.Content
}

# Reschedule update date
$environmentNameSandbox = "Fill in the environment name"
$response = Invoke-WebRequest `
    -Method Put `
    -Uri    "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments/$environmentNameSandbox/upgrade" `
    -Body   (@{
                runOn = $preferredStartTimeUtc
                ignoreUpgradeWindow = $true
              } | ConvertTo-Json) `
    -Headers @{Authorization=("Bearer $accessToken")} `
    -ContentType "application/json"
write-host -ForegroundColor Green 'Environment' $environmentNameSandbox 'is scheduled for update at UTC starttime' $preferredStartTimeUtc

######### Appsource Apps #################
#Get installed apps
$environmentNameSandbox = "Fill in the environment name"
$installedApps = Invoke-WebRequest `
    -Method Get `
    -Uri    "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments/$environmentNameSandbox/apps" `
    -Headers @{Authorization=("Bearer $accessToken")}
Write-Host -ForegroundColor Green 'Installed apps:' $environmentNameSandbox
ConvertFrom-Json $installedApps.Content | Select-Object -ExpandProperty value | Select-Object -Property id, name, publisher, version, state, lastUpdateAttemptResult | Sort-Object -Property name| Format-Table | Out-String | Write-Host

# Get available updates
$environmentNameSandbox = "Fill in the environment name"
$availableUpdates = Invoke-WebRequest `
    -Method Get `
    -Uri    "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments/$environmentNameSandbox/apps/availableUpdates" `
    -Headers @{Authorization=("Bearer $accessToken")}
Write-Host -ForegroundColor Green 'Available updates:' $environmentNameSandbox
ConvertFrom-Json $availableUpdates.Content | Select-Object -ExpandProperty value | Select-Object -Property appId, name, publisher, version | Sort-Object -Property name | Format-Table | Out-String | Write-Host
$appsToUpdate = ConvertFrom-Json $availableUpdates.Content

# Update the apps
$appsToUpdate.value | ForEach-Object {
    $appIdToUpdate = $_.appId
    $appTargetVersion = $_.version
    Invoke-WebRequest `
    -Method Post `
    -Uri    "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments/$environmentNameSandbox/apps/$appIdToUpdate/update" `
    -Body   (@{
                installOrUpdateNeededDependencies = $true
                targetVersion = $appTargetVersion
              } | ConvertTo-Json) `
    -Headers @{Authorization=("Bearer $accessToken")} `
    -ContentType "application/json"
    Write-Host -ForegroundColor Green 'Update for app' $_.name 'to version ' $_.version 'for environment' $environmentNameSandbox 'is scheduled'
}

# Check update app status
$environmentNameSandbox = "Fill in the environment name"
$appsToUpdate.value | ForEach-Object {
    $appIdToUpdate = $_.appId
    $response= Invoke-WebRequest `
    -Method Get `
    -Uri    "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments/$environmentNameSandbox/apps/$appIdToUpdate/operations" `
    -Headers @{Authorization=("Bearer $accessToken")}
    $response = ConvertFrom-Json $response.Content | Select-Object -ExpandProperty value | Select-Object -Property appId, name, publisher, version, status
    Write-Host -ForegroundColor Green 'Update app:' $_.name 
    Write-Host -ForegroundColor Green 'New Version' $_.version 
    Write-Host -ForegroundColor Green 'Status: ' $response.status
    Write-Host ""
}

# Install app from Appsource. 
$environmentNameSandbox = "Fill in the environment name"
$appIdToInstall = "BEC4CA36-C7FB-4110-9DB5-29559CC1F84C" #Jet Reports
$appTargetVersion = "1.24.5.1361"
$response = Invoke-WebRequest `
    -Method Post `
    -Uri    "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments/$environmentNameSandbox/apps/$appIdToInstall/install" `
    -Body   (@{
                AcceptIsvEula = $true
                languageId = "1043"
                targetVersion = $appTargetVersion
                installOrUpdateNeededDependencies = $true
                useEnvironmentUpdateWindow = $false    
            } | ConvertTo-Json) `
    -Headers @{Authorization=("Bearer $accessToken")} `
    -ContentType "application/json"
    
############# Multi Environment #################
############# MAJOR RELEASES #################
$Environments = Invoke-WebRequest `
    -Method Get `
    -Uri    "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/environments" `
    -Headers @{Authorization=("Bearer $accessToken")}
$EnvironmentsToUpdate = ConvertFrom-Json $Environments.Content | Select-Object -ExpandProperty value | where-object {($_.applicationfamily -eq '4PSConstruct') -and ($_.status -eq 'Active')}

# Get update window
$EnvironmentsToUpdate | ForEach-Object {
    $Environment = $_.name

    $response = Invoke-WebRequest `
    -Method Get `
    -Uri    "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments/$Environment/settings/upgrade" `
    -Headers @{Authorization=("Bearer $accessToken")}
    write-host -ForegroundColor Yellow 'Update window for environment' $Environment
    ConvertFrom-Json $response.Content
}

# Set update window
$EnvironmentsToUpdate | ForEach-Object {
    $Environment = $_.name

    $response = Invoke-WebRequest `
    -Method Put `
    -Uri    "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments/$Environment/settings/upgrade" `
    -Body   (@{
                 preferredStartTimeUtc = $preferredStartTimeUtc
                 preferredEndTimeUtc   = $preferredEndTimeUtc
              } | ConvertTo-Json) `
    -Headers @{Authorization=("Bearer $accessToken")} `
    -ContentType "application/json"
    write-host -ForegroundColor Yellow 'Preferred update window for environment' $Environment 'is set to'
    ConvertFrom-Json $response.Content
}

# Get scheduled updates
$EnvironmentsToUpdate | ForEach-Object {
    $Environment = $_.name
    Write-Host 'Environment:' $Environment -ForegroundColor Yellow
    
    $response = Invoke-WebRequest `
    -Method Get `
    -Uri    "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments/$Environment/upgrade" `
    -Headers @{Authorization=("Bearer $accessToken")}
    if ($response.StatusCode -eq 204) {
        Write-Host -ForegroundColor Red 'No scheduled updates for environment' $Environment
    } else {
        Write-Host -ForegroundColor Green 'Scheduled updates for environment' $Environment
        ConvertFrom-Json $response.Content
    }
}

# Reschedule update
$EnvironmentsToUpdate | ForEach-Object {
    $Environment = $_.name

    Invoke-WebRequest `
    -Method Put `
    -Uri    "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments/$Environment/upgrade" `
    -Body   (@{
                runOn = $preferredStartTimeUtc
                ignoreUpgradeWindow = $true
              } | ConvertTo-Json) `
    -Headers @{Authorization=("Bearer $accessToken")} `
    -ContentType "application/json"
    Write-Host -ForegroundColor Yellow 'Environment:' $Environment 'is scheduled for update at UTC starttime' $preferredStartTimeUtc	
 }

######### Appsource Apps #################
# Get installed apps
$EnvironmentsToUpdate | ForEach-Object {
    $Environment = $_.name
    Write-Host 'Installed apps for Environment:' $Environment -ForegroundColor Yellow
    $Uri = "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments/"+$Environment+"/apps"

    $responseInstalled = Invoke-WebRequest `
    -Method Get `
    -Uri    $Uri `
    -Headers @{Authorization=("Bearer $accessToken")}
    ConvertFrom-Json $responseInstalled.Content | Select-Object -ExpandProperty value | Select-Object -Property id, name, publisher, version, state| Sort-Object -Property name| Format-Table | Out-String | Write-Host
}

# Get available updates
$EnvironmentsToUpdate | ForEach-Object {
    $Environment = $_.name
    Write-Host 'Available updates for Environment:' $Environment -ForegroundColor Yellow
    $Uri = "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments/"+$Environment+"/apps/availableUpdates"

    $response= Invoke-WebRequest `
    -Method Get `
    -Uri    $Uri `
    -Headers @{Authorization=("Bearer $accessToken")}
    ConvertFrom-Json $response.Content | Select-Object -ExpandProperty value | Select-Object -Property appId, name, publisher, version | Sort-Object -Property name | Format-Table | Out-String | Write-Host
}

# Update the apps for all environments
$EnvironmentsToUpdate | ForEach-Object {
    $Environment = $_.name
    Write-Host 'Environment:' $Environment -ForegroundColor Yellow
    $Uri = "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments/"+$Environment+"/apps/availableUpdates"
    
    $response= Invoke-WebRequest `
    -Method Get `
    -Uri    $Uri `
    -Headers @{Authorization=("Bearer $accessToken")}
    $appToUpdate = ConvertFrom-Json $response.Content | Select-Object -ExpandProperty Value | Select-Object -Property appId, version, name

    $appToUpdate | ForEach-Object {
        $appIdToUpdate = $_.appId
        $appTargetVersion = $_.version
        $appUri = "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments/"+$Environment+"/apps/$appIdToUpdate/update"

        Invoke-WebRequest `
        -Method Post `
        -Uri    $appUri `
        -Body   (@{
                    installOrUpdateNeededDependencies = $true
                    targetVersion = $appTargetVersion
                } | ConvertTo-Json) `
        -Headers @{Authorization=("Bearer $accessToken")} `
        -ContentType "application/json"
        Write-Host -ForegroundColor Green 'Update app' $_.name 'to version ' $_.version 'is scheduled'
    }
}

# Check update app status
$EnvironmentsToUpdate | ForEach-Object {
    $Environment = $_.name
    Write-Host 'Environment:' $Environment -ForegroundColor Yellow
    $Uri = "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments/"+$Environment+"/apps/availableUpdates"
 
    $response= Invoke-WebRequest `
    -Method Get `
    -Uri    $Uri `
    -Headers @{Authorization=("Bearer $accessToken")}
    $appToUpdate = ConvertFrom-Json $response.Content | Select-Object -ExpandProperty Value | Select-Object -Property appId, version, name

    $appToUpdate | ForEach-Object {
        $appIdToUpdate = $_.appId
        $response= Invoke-WebRequest `
        -Method Get `
        -Uri    "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments/$Environment/apps/$appIdToUpdate/operations" `
        -Headers @{Authorization=("Bearer $accessToken")}
        $response = ConvertFrom-Json $response.Content | Select-Object -ExpandProperty value | Select-Object -Property appId, name, publisher, version, status
        Write-Host -ForegroundColor Green 'Update app:' $_.name 
        Write-Host -ForegroundColor Green 'New Version' $_.version 
        Write-Host -ForegroundColor Green 'Status: ' $response.status
        Write-Host ""
    }
}

## Install app from Appsource in all environments
$appIdToInstall = "EFBDFFC9-4362-4AD7-BB9A-1E30FC987A23" #4PS Dynamic Prognoses
$EnvironmentsToUpdate | ForEach-Object {
    $Environment = $_.name
    Write-Host 'Environment:' $Environment -ForegroundColor Yellow
    $Uri = "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments/"+$Environment+"/apps/$appIdToInstall/install"
 
    Invoke-WebRequest `
    -Method Post `
    -Uri    $Uri `
    -Body   (@{
                AcceptIsvEula = $true
                languageId = "1043"
                installOrUpdateNeededDependencies = $true
                useEnvironmentUpdateWindow = $false    
            } | ConvertTo-Json) `
    -Headers @{Authorization=("Bearer $accessToken")} `
    -ContentType "application/json"

    Write-Host -ForegroundColor Green 'App' $appIdToInstall 'is installed in environment' $Environment
}

# Uninstall app.
$environmentNameSandbox = "Fill in the sandbox environment name"
#$appIdToUnInstall = "4aadc1a9-c361-4b86-a749-139a492026a0" #Jet Reports
$appIdToUnInstall = "E0B65886-53B0-47C6-B680-C72FD8A0D169" #4PS COHUB Interface 4PS Markplaats
$EnvironmentsToUpdate | ForEach-Object {
    $Environment = $_.name
    Write-Host 'Environment:' $Environment -ForegroundColor Yellow
    $Uri = "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments/"+$Environment+"/apps/$appIdToUnInstall/uninstall"
 
    Invoke-WebRequest `
    -Method Post `
    -Uri    $Uri `
    -Body   (@{
                deleteData = $true
                uninstallDependents = $true
                useEnvironmentUpdateWindow = $false    
            } | ConvertTo-Json) `
    -Headers @{Authorization=("Bearer $accessToken")} `
    -ContentType "application/json"
}


