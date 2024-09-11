# Delete Sandbox environment
# BE cAREFULL: NO QUESTIONS ASKED !!!! #
$environmentNameToDelete = "Fill in the environment name to delete"
$response = Invoke-WebRequest `
    -Method Delete `
    -Uri    "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments/$environmentNameToDelete" `
    -Headers @{Authorization=("Bearer $accessToken")} 
write-host -ForegroundColor Green 'Environment' $environmentNameToDelete 'is deleted'
ConvertFrom-Json $response.Content
