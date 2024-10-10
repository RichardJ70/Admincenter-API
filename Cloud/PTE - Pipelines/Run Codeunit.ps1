
# Script to run a codeunit in Business Central using a webservice  
# The script will first authenticate with Business Central and then run the codeunit
# The script will output the result of the codeunit to the console

Install-Module BcContainerHelper -Force
Import-Module BcContainerHelper -Verbose

#Shared Parameters
$environment = "SandBox4PSNL" #4PS
#$environment = "Sandbox" #Standard BC

#4PS Construct
$bcContainerHelperConfig.apiBaseUrl = "https://4psconstruct.api.bc.dynamics.com"
$bcContainerHelperConfig.baseUrl = "https://4psconstruct.bc.dynamics.com"

#Standard BC
#Not required to set these values but after changing the values, the script will work for 4PS Construct but not anymore for Standard BC
#$bcContainerHelperConfig.apiBaseUrl = "https://api.businesscentral.dynamics.com"
#$bcContainerHelperConfig.baseUrl = "https://businesscentral.dynamics.com"

######### Login #############
$authContext = New-BcAuthContext -includeDeviceLogin
$accessToken = $authContext.AccessToken

function GetAuthHeaders {
    return @{ "Authorization" = "Bearer $($accessToken)" }
}

Write-Host -ForegroundColor Cyan 'Authentication complete - we have an access token for Business Central, and it is stored in the $accessToken variable.'

# Standard BC
# https://api.businesscentral.dynamics.com/v2.0/$environment/ODataV4/<Webservicename>_<Procedure>
# 4PS Construct
# https://4psconstruct.api.bc.dynamics.com/v2.0/$environment/ODataV4/<Webservicename>_<Procedure>
$automationApiUrl = "$($bcContainerHelperConfig.apiBaseUrl.TrimEnd('/'))/v2.0/$environment/ODataV4/UseAPICodeunit_PingPong"

Invoke-WebRequest `
    -Method Post `
    -Uri    $automationApiUrl `
    -Body   (@{
                 pingText = "ping" #Input parameter
              } | ConvertTo-Json) `
    -Headers @{Authorization=("Bearer $accessToken")} `
    -ContentType "application/json"

