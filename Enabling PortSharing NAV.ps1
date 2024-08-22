Import-Module 'C:\Program Files (x86)\Microsoft Dynamics NAV\90\RoleTailored Client\Microsoft.Dynamics.Nav.Model.Tools.psd1' -WarningAction SilentlyContinue | Out-Null
Import-Module 'C:\Program Files\Microsoft Dynamics NAV\90\Service\NavAdminTool.ps1' -WarningAction SilentlyContinue | Out-Null

$ServiceInstance = 'NAV90Ontwikkel'
write-Host -ForegroundColor Green "Enabling PortSharing for $ServiceInstance"
Set-NAVServerInstance -ServerInstance $ServiceInstance -Stop -ErrorAction SilentlyContinue

$null = sc.exe config (get-service NetTcpPortSharing).Name Start= Auto
$null = Start-Service NetTcpPortSharing
$null = sc.exe config (Get-Service "*$ServiceInstance*").Name depend= HTTP/NetTcpPortSharing

Set-NAVServerInstance -ServerInstance $ServiceInstance -Start