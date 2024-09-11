# Copy production environment to a sandbox environment
$sourceEnvironment = ""
$targetEnvironment = ""
$response = Invoke-WebRequest `
    -Method Post `
    -Uri    "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments/$sourceEnvironment/copy" `
    -Body   (@{
                 EnvironmentName = $targetEnvironment
                 Type            = "Sandbox"
              } | ConvertTo-Json) `
    -Headers @{Authorization=("Bearer $accessToken")} `
    -ContentType "application/json"
Write-Host -ForegroundColor Green 'Environment' $targetEnvironment 'is created as a sandbox environment from environment' $s$sourceEnvironment
ConvertFrom-Json $response.Content