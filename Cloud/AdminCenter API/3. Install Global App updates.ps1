# Install app updates in all environments
$title = "Install app updates all environments"
$question = "Schedule the update to run in the maintenance window?"
$choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))
$decision = $Host.UI.PromptForChoice($title, $question, $choices, 1)
if ($decision -eq 0){
    $useMaintenanceWindows  = $true
} else {
    $useMaintenanceWindows  = $false
}

# Get available updates
$EnvironmentsToUpdate | ForEach-Object {
    $Environment = $_.name
    $applicationFamily = $_.applicationFamily

    Write-Host 'Available updates for Environment:' $Environment -ForegroundColor Yellow

    $response = Invoke-WebRequest `
    -Method Get `
    -Uri    $Uri "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments/$Environment/apps/availableUpdates" `
    -Headers @{Authorization=("Bearer $accessToken")}
    ConvertFrom-Json $response.Content | Select-Object -ExpandProperty value | Select-Object -Property appId, name, publisher, version | Sort-Object -Property name | Format-Table | Out-String | Write-Host
    $appsToUpdate = ConvertFrom-Json $response.Content | Select-Object -ExpandProperty value

    $i = 1
    $NoOfApps = $appsToUpdate.Count

    if ($NoOfApps -eq 0) {
        Write-Host ("No available updates, you are up-to-date.") -ForegroundColor Green
    } else {
        Write-Host ("Found $NoOfApps updates:") -ForegroundColor Yellow
        $appsToUpdate

        $title = "Install app updates"
        $question = "Do you want to install these updates in the environment?"
        $choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
        $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
        $choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))
        $decision = $Host.UI.PromptForChoice($title, $question, $choices, 0)
        Clear-Host
        if ($decision -eq 0) {
            if ($useMaintenanceWindows -eq $false) {
                Write-Host ("You are not using the maintenance window. Updates will start shortly and user sessions may be lost. Continue?") -ForegroundColor Magenta
                pause
            }
            foreach ($App in $Apps) {
              $AppId = $App.appId
              $AppVer = $App.version
              $AppName = $App.name
              Write-Host ("Scheduling update $i of $NoOfApps : app Id: $AppId   Name: $AppName   Version: $AppVer") -ForegroundColor Yellow
              
              # Update apps
              $appIdToUpdate = $AppId
              $appTargetVersion = $AppVer
              $response = Invoke-WebRequest `
                  -Method Post `
                  -Uri    "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments/$environmentName/apps/$appIdToUpdate/update" `
                  -Body   (@{
                               targetVersion = $appTargetVersion
                               installOrUpdateNeededDependencies = $true
                               useEnvironmentUpdateWindow = $useMaintenanceWindows
                            } | ConvertTo-Json) `
                  -Headers @{Authorization=("Bearer $accessToken")} `
                  -ContentType "application/json"
              
              $i = $i +1
            }
            # Check update status
            Do {
                $response = Invoke-WebRequest `
                -Method Get `
                -Uri    "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments/$environmentName/operations" `
                -Headers @{Authorization=("Bearer $accessToken")}
                $Operations = $response.Content | ConvertFrom-Json
                $Operations = $Operations.value
                $operationsRunning = $Operations | where-object { $_.status -eq "scheduled" -or $_.status -eq "running" }
                $Number = $operationsRunning.count
                if ( $operationsRunning.count -ne '' ) {
                    write-host "Installation of $Number extensions remaining..."
                    Start-Sleep -Seconds 15
                }
            }
            Until( $operationsRunning.count -eq '' )
        } else { Write-Host ("Updates skipped") -ForegroundColor Magenta }      
    }
}