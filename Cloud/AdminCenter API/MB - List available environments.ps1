# Script to list all available 4PS Construct online environments
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

foreach ($ProdEnv in $ProductionEnvironments.name) {
    # Do something with all production environment
}

foreach ($Sandbox in $SandboxEnvironments.name) {
    # Do something with all sandboxes
}
