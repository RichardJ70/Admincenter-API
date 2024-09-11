
Import-Module BcContainerHelper -Verbose

#Shared Parameters
$adminVersion = "V2.21"
$applicationFamily = "4PSConstruct"

$bcContainerHelperConfig.apiBaseUrl = "https://4psconstruct.api.bc.dynamics.com"
$bcContainerHelperConfig.baseUrl = "https://4psconstruct.bc.dynamics.com"

######### Login #############
$authContext = New-BcAuthContext -includeDeviceLogin
$accessToken = $authContext.AccessToken
Write-Host -ForegroundColor Cyan 'Authentication complete - we have an access token for Business Central, and it is stored in the $accessToken variable.'

$apps = "https://businesscentralapps.azureedge.net/githubhelloworld/latest/apps.zip"
Publish-PerTenantExtensionApps `
    -bcAuthContext $authContext `
    -environment $environment `
    -appFiles $apps
