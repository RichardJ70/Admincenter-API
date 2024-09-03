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