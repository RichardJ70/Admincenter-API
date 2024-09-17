
# Script Publish-PerTenantExtensionApps.ps1 is modified to use only for PTE extensions and testing with 4PS Construct
# Publish-PerTenantExtensionApps `
#    -bcAuthContext $authContext `
#    -environment $environment `
#    -appFiles $apps 
#
# It works for Business Central Standard, but not for 4PS Construct. Probably because of the different API calls and the different way of handling the apps in
# version 23.51 of 4PS Construct and version 24.4 of Business Central Standard.

Install-Module BcContainerHelper -Force
Import-Module BcContainerHelper -Verbose

#Shared Parameters
$environment = "SandBox4PSNL" #4PS
$environment = "Sandbox" #Standard BC
$tenant = ""

#4PS Construct
#$bcContainerHelperConfig.apiBaseUrl = "https://4psconstruct.api.bc.dynamics.com"
#$bcContainerHelperConfig.baseUrl = "https://4psconstruct.bc.dynamics.com"

#Standard BC
#Not required to set these values but after changing the values, the script will work for 4PS Construct but not anymore for Standard BC
$bcContainerHelperConfig.apiBaseUrl = "https://api.businesscentral.dynamics.com"
$bcContainerHelperConfig.baseUrl = "https://businesscentral.dynamics.com"

######### Login #############
$authContext = New-BcAuthContext -includeDeviceLogin
$accessToken = $authContext.AccessToken

function GetAuthHeaders {
    return @{ "Authorization" = "Bearer $($accessToken)" }
}

Write-Host -ForegroundColor Cyan 'Authentication complete - we have an access token for Business Central, and it is stored in the $accessToken variable.'

#$appfiles = "D:\OneDrive - RISA Support\Documents\Klanten\BVGO\Powershell\apps\VolkerWessels ICT_VolkerWessels Basis Extensie_23.53.1.1.app"
$appfiles = "D:\Apps-Git\Demo\Standaard\OpenData\RISA Support B.V._Open Data Check_24.0.0.0.app"

#List Companies
Write-Host "$automationApiUrl/companies"
$companies = Invoke-RestMethod -Headers (GetAuthHeaders) -Method Get -Uri "$automationApiUrl/companies" -UseBasicParsing
$companies = $companies.value
$companies | ForEach-Object {
    $companyId = $_.id
    $companyName = $_.name  
    Write-Host "Get a list of api calls from company $companyName with id $companyId" -ForegroundColor Green
}

<#
# Get possible api calls
# Standard BC
# https://api.businesscentral.dynamics.com/v2.0/$tenant/$environment/api/microsoft/automation/v2.0/companies($companyid)/extensions
$automationApiUrl = "$($bcContainerHelperConfig.apiBaseUrl.TrimEnd('/'))/v2.0/$tenant/$environment/api/microsoft/automation/v2.0" #Get possible api calls

# 4PS Construct
# Geen api calls beschikbaar waar extension in beschikbaar zijn. Mogelijk dat dit komt door het verschil in versie van 4PS Construct en Business Central Standard
# Onderstaande zijn getest, maar hebben geen resultaat opgeleverd
#$automationApiUrl = "$($bcContainerHelperConfig.apiBaseUrl.TrimEnd('/'))/v2.0/$environment/api/microsoft/admin/beta" #Get installed api calls microsoft/admin/beta
#$automationApiUrl = "$($bcContainerHelperConfig.apiBaseUrl.TrimEnd('/'))/v2.0/$environment/api/microsoft/automation/beta" #Get installed api calls microsoft/automation/beta
#$automationApiUrl = "$($bcContainerHelperConfig.apiBaseUrl.TrimEnd('/'))/v2.0/$environment/api/microsoft/automate/v1.0" #Get installed api calls microsoft/automate/beta
#$automationApiUrl = "$($bcContainerHelperConfig.apiBaseUrl.TrimEnd('/'))/v2.0/$environment/api/microsoft/runtime/beta" #Get installed api calls microsoft/automation/beta

$Contents = Invoke-WebRequest -Headers (GetAuthHeaders) -Method Get -Uri "$automationApiUrl"
(ConvertFrom-Json $Contents.Content).value | Sort-Object -Property DisplayName
#>

#Get PTE Extensions per company
$companies = Invoke-RestMethod -Headers (GetAuthHeaders) -Method Get -Uri "$automationApiUrl/companies" -UseBasicParsing
$companies = $companies.value
$companies | ForEach-Object {
    $companyId = $_.id
    $companyName = $_.name  
    Write-Host "Extensions from company $companyName with id $companyId" -ForegroundColor Green
    $getExtensions = Invoke-WebRequest -Headers (GetAuthHeaders) -Method Get -Uri "$automationApiUrl/companies($companyId)/extensions"
    $extensions = (ConvertFrom-Json $getExtensions.Content).value | Sort-Object -Property DisplayName | Where-Object {($_.PublishedAs -EQ ' PTE')}
    (ConvertFrom-Json $getExtensions.Content).value | Sort-Object -Property DisplayName | Select-Object -Property id,DisplayName,versionMajor,versionMinor,versionBuild,versionRevision,publisher, isInstalled, PublishedAs | Where-Object {($_.PublishedAs -EQ ' PTE')} | Format-Table -AutoSize
}      
Pause
Write-Host "Publishing and installing apps" -ForegroundColor Green
$body = @{"schedule" = "Current Version"}
$body."SchemaSyncMode" = "Force Sync"

$appDep = $extensions | Where-Object { $_.DisplayName -eq 'Application' }
$appDepVer = [System.Version]"$($appDep.versionMajor).$($appDep.versionMinor).$($appDep.versionBuild).$($appDep.versionRevision)"
if ($appDepVer -ge [System.Version]"23.0.0.0") {
    if ($schemaSyncMode -eq 'Force') {
        $body."SchemaSyncMode" = "Force Sync"
    }
    else {
        $body."SchemaSyncMode" = "Add"
    }
}
else {
    if ($schemaSyncMode -eq 'Force') {
        throw 'SchemaSyncMode Force is not supported before version 21.2'
    }
}
if($schedule) {
    $body."schedule" = $schedule
}

$ifMatchHeader = @{ "If-Match" = '*'}
$jsonHeader = @{ "Content-Type" = 'application/json'}
$streamHeader = @{ "Content-Type" = 'application/octet-stream'}
try {
    Sort-AppFilesByDependencies -appFiles $appFiles -excludeRuntimePackages | ForEach-Object {
        Write-Host -NoNewline "$([System.IO.Path]::GetFileName($_)) - "
        $appJson = Get-AppJsonFromAppFile -appFile $_
        
        $existingApp = $extensions | Where-Object { $_.id -eq $appJson.id -and $_.isInstalled }

        if ($existingApp) {
            if ($existingApp.isInstalled) {
                $existingVersion = [System.Version]"$($existingApp.versionMajor).$($existingApp.versionMinor).$($existingApp.versionBuild).$($existingApp.versionRevision)"
                if ($existingVersion -ge $appJson.version) {
                    Write-Host "already installed"
                }
                else {
                    Write-Host @newLine "upgrading"
                    $existingApp = $null
                }
            }
            else {
                Write-Host @newLine "installing"
                $existingApp = $null
            }
        }
        else {
            Write-Host @newLine "publishing and installing"
        }

        if (!$existingApp) {
            $extensionUpload = (Invoke-RestMethod -Method Get -Uri "$automationApiUrl/companies($companyId)/extensionUpload" -Headers (GetAuthHeaders)).value
            Write-Host @newLine "."
            if ($extensionUpload -and $extensionUpload.systemId) {
                $extensionUpload = Invoke-RestMethod `
                    -Method Patch `
                    -Uri "$automationApiUrl/companies($companyId)/extensionUpload($($extensionUpload.systemId))" `
                    -Headers ((GetAuthHeaders) + $ifMatchHeader + $jsonHeader) `
                    -Body ($body | ConvertTo-Json -Compress)
            }
            else {
                $ExtensionUpload = Invoke-RestMethod `
                    -Method Post `
                    -Uri "$automationApiUrl/companies($companyId)/extensionUpload" `
                    -Headers ((GetAuthHeaders) + $jsonHeader) `
                    -Body ($body | ConvertTo-Json -Compress)
            }
            Write-Host @newLine "."
            if ($null -eq $extensionUpload.systemId) {
                throw "Unable to upload extension"
            }
            $fileBody = [System.IO.File]::ReadAllBytes($_)
            Invoke-RestMethod `
                -Method Patch `
                -Uri $extensionUpload.'extensionContent@odata.mediaEditLink' `
                -Headers ((GetAuthHeaders) + $ifMatchHeader + $streamHeader) `
                -Body $fileBody | Out-Null
            Write-Host @newLine "."    
            Invoke-RestMethod `
                -Method Post `
                -Uri "$automationApiUrl/companies($companyId)/extensionUpload($($extensionUpload.systemId))/Microsoft.NAV.upload" `
                -Headers ((GetAuthHeaders) + $ifMatchHeader) | Out-Null
            Write-Host @newLine "."    
            $completed = $false
            $errCount = 0
            $sleepSeconds = 30
            while (!$completed)
            {
                Start-Sleep -Seconds $sleepSeconds
                try {
                    $extensionDeploymentStatusResponse = Invoke-WebRequest -Headers (GetAuthHeaders) -Method Get -Uri "$automationApiUrl/companies($companyId)/extensionDeploymentStatus" -UseBasicParsing
                    $extensionDeploymentStatuses = (ConvertFrom-Json $extensionDeploymentStatusResponse.Content).value

                    $completed = $true
                    $extensionDeploymentStatuses | Where-Object { $_.publisher -eq $appJson.publisher -and $_.name -eq $appJson.name -and $_.appVersion -eq $appJson.version } | % {
                        if ($_.status -eq "InProgress") {
                            Write-Host @newLine "."
                            $completed = $false
                        }
                        elseif ($_.Status -eq "Unknown") {
                            throw "Unknown Error"
                        }
                        elseif ($_.Status -ne "Completed") {
                            $errCount = 5
                            throw $_.status
                        }
                    }
                    $errCount = 0
                    $sleepSeconds = 5
                }
                catch {
                    if ($errCount++ -gt 4) {
                        Write-Host $_.Exception.Message
                        throw "Unable to publish app. Please open the Extension Deployment Status Details page in Business Central to see the detailed error message."
                    }
                    $sleepSeconds += $sleepSeconds
                    $completed = $false
                }
            }
            if ($completed) {
                Write-Host "completed"
            }
        }
    }
}
catch [System.Net.WebException],[System.Net.Http.HttpRequestException] {
    Write-Host "ERROR $($_.Exception.Message)"
    Write-Host $_.ScriptStackTrace
    throw (GetExtendedErrorMessage $_)
}
catch {
    Write-Host "ERROR: $($_.Exception.Message) [$($_.Exception.GetType().FullName)]"
    TrackException -telemetryScope $telemetryScope -errorRecord $_
    throw
}
finally {
    $getExtensions = Invoke-WebRequest -Headers (GetAuthHeaders) -Method Get -Uri "$automationApiUrl/companies($companyId)/extensions" -UseBasicParsing
    $extensions = (ConvertFrom-Json $getExtensions.Content).value | Sort-Object -Property DisplayName | Where-Object {($_.PublishedAs -EQ ' PTE')}
    if (Test-Path $appFolder) {
        Remove-Item $appFolder -Recurse -Force -ErrorAction SilentlyContinue
    }
    TrackTrace -telemetryScope $telemetryScope
}
