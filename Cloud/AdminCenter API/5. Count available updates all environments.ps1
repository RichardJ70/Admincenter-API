# Script to count all available 4PS Construct online updates in all environments
# Get list of environments
foreach ($Environment in $EnvironmentsToUpdate.name) {
    # Get available updates
    $AvailableUpdates = Invoke-WebRequest `
        -Method Get `
        -Uri    "https://api.businesscentral.dynamics.com/admin/v2.21/applications/$applicationFamily/environments/$Environment/apps/availableUpdates" `
        -Headers @{Authorization=("Bearer $accessToken")}

    $Update = $AvailableUpdates.Content | ConvertFrom-Json
    $Apps = $Update.value
    $NoOfApps = $Apps.Count
    Write-Host ("Environment: $Environment : $NoOfApps updates available") -ForegroundColor Yellow
}