# Install major or minor releases
# Set prefferend start and end time
$preferredStartTimeUtc = "2024-09-02T18:00:00Z"
$preferredEndTimeUtc   = "2024-09-03T06:00:00Z"

$title = "Install major or minor releases"
$question = "De begin en eindtijd van de upgrade is ingesteld op resp. $preferredStartTimeUtc en $preferredEndTimeUtc. Is dat correct?"
$choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))
$decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
if ($decision -eq 1)
{
    Write-Host "Stel eerst de juiste datum/tijd in en herstart het script"
    Break
} else { cls }


$title = "Install major or minor releases"
$question = "Upgrades are scheduled outside working hours. Do you wish to install it during working hours?"
$choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))
$decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
if ($decision -eq 0){
    $IgnoreUpdateWindow = $true
} else {
    $IgnoreUpdateWindow = $false
}

$EnvironmentsToUpdate | ForEach-Object {
    $Environment = $_.name
    $applicationFamily = $_.applicationFamily
    Write-Host 'Environment:' $Environment -ForegroundColor Yellow
    
    $response = Invoke-WebRequest `
    -Method Get `
    -Uri    "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments/$Environment/upgrade" `
    -Headers @{Authorization=("Bearer $accessToken")}
    if ($response.StatusCode -eq 204) {
        Write-Host -ForegroundColor Red 'No scheduled updates for environment' $Environment
        $upgradesFound = $false
    } else {
        Write-Host -ForegroundColor Green 'Scheduled updates for environment' $Environment
        $upgradesFound = $true
    }

    if ($upgradeFound)
    {           
      $response = Invoke-WebRequest `
          -Method Put `
          -Uri    "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments/$Environment/settings/upgrade" `
          -Body   (@{
                       preferredStartTimeUtc = $preferredStartTimeUtc
                       preferredEndTimeUtc   = $preferredEndTimeUtc
                    } | ConvertTo-Json) `
          -Headers @{Authorization=("Bearer $accessToken")} `
          -ContentType "application/json"
         write-host -ForegroundColor Yellow 'Update window for environment' $Environment 'is set to'
         ConvertFrom-Json $response.Content

       $response = Invoke-WebRequest `
          -Method Put `
          -Uri    "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments/$Environment/upgrade" `
          -Body   (@{
                      runOn = $preferredStartTimeUtc
                      ignoreUpgradeWindow = $IgnoreUpdateWindow
                    } | ConvertTo-Json) `
          -Headers @{Authorization=("Bearer $accessToken")} `
          -ContentType "application/json"
        write-host -ForegroundColor Green 'Environment' $environmentNameSandbox 'is scheduled for update at UTC starttime' $preferredStartTimeUtc
    }
}

