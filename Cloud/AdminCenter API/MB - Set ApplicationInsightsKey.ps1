# Script to set Application Insight Key in all available 4PS Construct online environments
# Created by 4PS-MB / DKMV4PS

# Get list of environments
$response = Invoke-WebRequest `
    -Method Get `
    -Uri    "https://api.businesscentral.dynamics.com/admin/v2.11/applications/$applicationFamily/environments" `
    -Headers @{Authorization=("Bearer $accessToken")}

$Environments = $response.Content | ConvertFrom-Json
$Environments = $Environments.value

$ProductionEnvironments = $Environments | where { $_.type -eq "Production" }
$SandboxEnvironments = $Environments | where { $_.type -eq "Sandbox" }

Write-Host("Production environment(s):") -ForegroundColor Green
$ProductionEnvironments

Write-Host("Sandbox environment(s):") -ForegroundColor Green
$SandboxEnvironments

foreach ($Env in $Environments.name) {
    
    # Set AppInsights key
    $environmentName = $Env
    $newAppInsightsKey = "InstrumentationKey=11111111-2222-3333-4444-555555555555;IngestionEndpoint=https://northeurope-2.in.applicationinsights.azure.com/;LiveEndpoint=https://northeurope.livediagnostics.monitor.azure.com/"
    $response = Invoke-WebRequest `
        -Method Post `
        -Uri    "https://api.businesscentral.dynamics.com/admin/v2.11/applications/$applicationFamily/environments/$environmentName/settings/appinsightskey" `
        -Body   (@{
                     key = $newAppInsightsKey
                  } | ConvertTo-Json) `
        -Headers @{Authorization=("Bearer $accessToken")} `
        -ContentType "application/json"
    Write-Host "Responded with: $($response.StatusCode) $($response.StatusDescription)"

}
