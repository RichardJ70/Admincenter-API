
$environmentName = "NewCompanyNames"
$appIdToInstall  = "57623bfa-0559-4bc2-ae1c-0979c29fc8d1"


Invoke-WebRequest `
        -Method Post `
        -Uri    "https://api.businesscentral.dynamics.com/admin/v2.11/applications/$applicationFamily/environments/$environmentName/apps/$appIdToInstall/install" `
        -Body   (@{
                    "AcceptIsvEula" = $true #set to $true once you've read the the app provider's terms of use and privacy policy
                    "languageId" = "1033"
                    "installOrUpdateNeededDependencies" = $true
                    "useEnvironmentUpdateWindow" = $false
                } | ConvertTo-Json) `
        -Headers @{Authorization=("Bearer $accessToken")} `
        -ContentType "application/json"


# Check install status
$response= Invoke-WebRequest `
    -Method Get `
    -Uri    "https://api.businesscentral.dynamics.com/admin/v2.11/applications/$applicationFamily/environments/$environmentName/apps/$appIdToInstall/operations" `
    -Headers @{Authorization=("Bearer $accessToken")}
Write-Host (ConvertTo-Json (ConvertFrom-Json $response.Content))




# List installed apps
$response = Invoke-WebRequest `
    -Method Get `
    -Uri    "https://api.businesscentral.dynamics.com/admin/v2.11/applications/$applicationFamily/environments/Production/apps" `
    -Headers @{Authorization=("Bearer $accessToken")}
Write-Host (ConvertTo-Json (ConvertFrom-Json $response.Content))
