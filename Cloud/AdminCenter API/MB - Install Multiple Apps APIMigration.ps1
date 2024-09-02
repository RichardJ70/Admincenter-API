$environmentName = "ApiMigration"

$AppIdsToInstall =
"58623bfa-0559-4bc2-ae1c-0979c29fd9e0", #"Intelligent Cloud Base"
"334ef79e-547e-4631-8ba1-7a7f18e14de6", #"Business Central Intelligent Cloud"
"6992416F-3F39-4D3C-8242-3FFF61350BEA", #"Business Central Cloud Migration - Previous Release"
"57623bfa-0559-4bc2-ae1c-0979c29fc8d1", #"Business Central Cloud Migration API"
"1a91ec97-a44b-461c-a10f-fabf9d0c32f9", #"4PS Hour Registration W1"
"5697f1f3-2156-4211-bedd-32f0da5ae24d", #"4PS Base API NL",
"44bb2baa-6686-4534-9d3c-a758a767047f", #"4PS Azure Maps W1"
"516ce6df-b904-4272-b405-5ad3b2e2422d" #"4PS File Explorer W1"


$i = 1
$NoOfApps = $AppIdsToInstall.Count

foreach ($App in $AppIdsToInstall) {

    Echo "Installeren app $i van $NoOfApps : $App"

    Invoke-WebRequest `
        -Method Post `
        -Uri    "https://api.businesscentral.dynamics.com/admin/v2.11/applications/$applicationFamily/environments/$environmentName/apps/$App/install" `
        -Body   (@{
                    "AcceptIsvEula" = $true #set to $true once you've read the the app provider's terms of use and privacy policy
                    "languageId" = "1033"
                    "installOrUpdateNeededDependencies" = $true
                    "useEnvironmentUpdateWindow" = $false
                } | ConvertTo-Json) `
        -Headers @{Authorization=("Bearer $accessToken")} `
        -ContentType "application/json"

    $i = $i +1

}


Do {
    $response = Invoke-WebRequest `
    -Method Get `
    -Uri    "https://api.businesscentral.dynamics.com/admin/v2.11/applications/$applicationFamily/environments/$environmentName/operations" `
    -Headers @{Authorization=("Bearer $accessToken")}
    $Operations = $response.Content | ConvertFrom-Json
    $Operations = $Operations.value
    $operationsRunning = $Operations | where { $_.status -eq "scheduled" -or $_.status -eq "running" }
    $amount = $operationsRunning.count
    if ( $operationsRunning.count -ne '' ) {
        write-host "Installation of $amount extensions remaining..."
        sleep -Seconds 15
    }
}
Until( $operationsRunning.count -eq '' )


<#

# Check install status
foreach ($App in $AppIdsToInstall) {
    $response= Invoke-WebRequest `
        -Method Get `
        -Uri    "https://api.businesscentral.dynamics.com/admin/v2.11/applications/$applicationFamily/environments/$environmentName/apps/$App/operations" `
        -Headers @{Authorization=("Bearer $accessToken")}
    Write-Host (ConvertTo-Json (ConvertFrom-Json $response.Content))
}

# List installed apps
$response = Invoke-WebRequest `
    -Method Get `
    -Uri    "https://api.businesscentral.dynamics.com/admin/v2.11/applications/$applicationFamily/environments/$environmentName/apps" `
    -Headers @{Authorization=("Bearer $accessToken")}
Write-Host (ConvertTo-Json (ConvertFrom-Json $response.Content))


# Get operations for an environment
$response = Invoke-WebRequest `
    -Method Get `
    -Uri    "https://api.businesscentral.dynamics.com/admin/v2.11/applications/$applicationFamily/environments/$environmentName/operations" `
    -Headers @{Authorization=("Bearer $accessToken")}
Write-Host (ConvertTo-Json (ConvertFrom-Json $response.Content))

#>

