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