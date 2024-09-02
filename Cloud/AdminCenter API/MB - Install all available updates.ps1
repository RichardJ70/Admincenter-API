# Script to schedule all available updates in a 4PS Construct online environment
# Created by 4PS-MB / DKMV4PS

$environmentName       = "Test" # Specify the environment
$useMaintenanceWindows = $false # Schedule the update to run in the maintenance window or not $true / $false

# Get available updates
$AvailableUpdates = Invoke-WebRequest `
    -Method Get `
    -Uri    "https://api.businesscentral.dynamics.com/admin/v2.11/applications/$applicationFamily/environments/$environmentName/apps/availableUpdates" `
    -Headers @{Authorization=("Bearer $accessToken")}

$Update = $AvailableUpdates.Content | ConvertFrom-Json
$Apps = $Update.value

$i = 1
$NoOfApps = $Apps.Count

if ($NoOfApps -eq 0) {
    Write-Host ("No available updates, you are up-to-date.") -ForegroundColor Green
} else {
    Write-Host ("Found $NoOfApps updates:") -ForegroundColor Yellow
    $Apps
    Write-Host ("Press Enter to continue updating, or cancel script.") -ForegroundColor Yellow
    pause
    if ($useMaintenanceWindows -eq $false) {
        Write-Host ("You are not using the maintenance window. Updates will start shortly and user sessions may be lost. Continue?") -ForegroundColor Magenta
        pause
    }
    foreach ($App in $Apps) {

        $AppId = $App.appId
        $AppVer = $App.version
        $AppName = $App.name
        Write-Host ("Scheduling update $i of $NoOfApps : app Id: $AppId   Name: $AppName   Version: $AppVer") -ForegroundColor Yellow

        # Update apps
        $appIdToUpdate = $AppId
        $appTargetVersion = $AppVer
        $response = Invoke-WebRequest `
            -Method Post `
            -Uri    "https://api.businesscentral.dynamics.com/admin/v2.11/applications/$applicationFamily/environments/$environmentName/apps/$appIdToUpdate/update" `
            -Body   (@{
                         targetVersion = $appTargetVersion
                         installOrUpdateNeededDependencies = $true
                         useEnvironmentUpdateWindow = $useMaintenanceWindows
                      } | ConvertTo-Json) `
            -Headers @{Authorization=("Bearer $accessToken")} `
            -ContentType "application/json"

        $i = $i +1
    }

}
