# GetExtsions work for Business Central Standard, but not for 4PS Construct.

#Install-Module BcContainerHelper -Force
Import-Module BcContainerHelper -Verbose

#Shared Parameters
$tenantId = Read-Host "Enter Tenant Id"
$clientId = Read-Host "Enter Client Id"
$clientSecret =  Read-Host "Enter Client Secret" -AsSecureString


# Get list of active 4PS environments
$title = "Show Extensions for 4PS or Standard BC"
$question = "Do you want to show the 4PS installed extensions or standard BC installed extensions?"
$choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&1 - 4PS'))
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&2 - Standard BC'))
$decision = $Host.UI.PromptForChoice($title, $question, $choices, 0)
Clear-Host
if ($decision -eq 0) {
    $aadAppRedirectUri = "https://4psconstruct.bc.dynamics.com/OAuthLanding.htm"
    $bcContainerHelperConfig.apiBaseUrl = "https://4psconstruct.api.bc.dynamics.com"
    $bcContainerHelperConfig.baseUrl = "https://4psconstruct.bc.dynamics.com"
    $companyName = Read-Host "Enter the 4PS company name"
    $environment = Read-Host "Enter the 4PS Environment name"
} else {
    $aadAppRedirectUri = "https://businesscentral.dynamics.com/OAuthLanding.htm"
    $bcContainerHelperConfig.apiBaseUrl = "https://api.businesscentral.dynamics.com"
    $bcContainerHelperConfig.baseUrl = "https://businesscentral.dynamics.com"
    $companyName = Read-Host "Enter the Company Name"
    $environment = Read-Host "Enter the environment name"
}

$authContext = Get-MsalToken `
    -ClientId $clientID `
    -ClientSecret $clientSecret `
    -RedirectUri $aadAppRedirectUri `
    -TenantId $tenantId `
    -Authority "https://login.microsoftonline.com/$tenant" `
    -Scope "https://api.businesscentral.dynamics.com/.default"

$accessToken = $authContext.AccessToken

$automationApiUrl = "$($bcContainerHelperConfig.apiBaseUrl.TrimEnd('/'))/v2.0/$tenant/$environment/api/microsoft/automation/v2.0"

$companies = ""
$companies = Invoke-RestMethod -Headers (@{ "Authorization" = "Bearer $($accessToken)" }) -Method Get -Uri "$automationApiUrl/companies" -UseBasicParsing
$companies = $companies.value | Where-Object { ($companyName -eq "") -or ($_.name -eq $companyName) } | Select-Object -First 1
$companyId = $companies.Id 

$getExtensions = ""
try {
    $getExtensions = Invoke-WebRequest -Headers (@{ "Authorization" = "Bearer $($accessToken)" }) -Method Get -Uri "$automationApiUrl/companies($companyId)/extensions"
}
catch [System.Net.Http.HttpRequestException] {
        Write-Host "ERROR $($_.Exception.Message)"
    }
finally{
    (ConvertFrom-Json $getExtensions.Content).value | Select-Object id, displayName, publisher, versionMajor, versionMinor, versionBuild, versionRevision, isInstalled, publishedAs | Format-Table
}

