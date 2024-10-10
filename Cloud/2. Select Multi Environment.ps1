# Get list of active 4PS environments
$title = "Environment Selection"
$namefilter = ""
$question = "Do you want to use all active Sandbox or Production environments?"
$choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&1 - Sandbox'))
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&2 - Production'))
$decision = $Host.UI.PromptForChoice($title, $question, $choices, 0)
Clear-Host
if ($decision -eq 0) {
    $environmentType = "Sandbox"    
} else {
    $environmentType = "Production"
}
$environmentList = Invoke-WebRequest `
    -Method Get `
    -Uri    "https://api.businesscentral.dynamics.com/admin/$adminVersion/applications/$applicationFamily/environments" `
    -Headers @{Authorization=("Bearer $accessToken")}
Write-Host -ForegroundColor Green 'Active 4PS' $environmenttype 'environments'
ConvertFrom-Json $environmentList.Content | Select-Object -ExpandProperty value | Select-Object -Property name, type, applicationfamily, applicationversion, status, platformversion | where-object {($_.status -eq 'Active') -and ($_.type -eq $environmentType) -and ($_.name -ge $namefilter)} |Format-Table | Out-String | Write-Host
$EnvironmentsToUpdate = $environmentList.Content | ConvertFrom-Json| Select-Object -ExpandProperty value | where-object {($_.status -eq 'Active') -and ($_.type -eq $environmentType) -and ($_.name -ge $namefilter)}