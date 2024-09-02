#### This powershell script can be used for the most common admin center tasks  ####
#### for both single environments and multi environments within the same tenant ####
####                                                                            ####
#### To be able to use the admin center API check the learning portal           ####

Install-Module BcContainenrHelper
Import-Module BcContainerHelper -Verbose

#Shared Parameters
$adminVersion = "V2.21"
$applicationFamily = "4PSConstruct"

######### Login #############
$authContext = New-BcAuthContext -includeDeviceLogin
$accessToken = $authContext.AccessToken
Write-Host -ForegroundColor Cyan 'Authentication complete - we have an access token for Business Central, and it is stored in the $accessToken variable.'

