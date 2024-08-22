# Script to enable portsharing on all installed NST's
# Created by 4PS-MB / DKMV4PS

# Edit NetTcpPortSharing Configuration
Set-Content 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\SMSvcHost.exe.config' '<?xml version="1.0" encoding="utf-8"?>
<configuration>
    <runtime>
        <gcConcurrent enabled="false" />
    </runtime>
    <system.serviceModel>
        <diagnostics performanceCounters="Off" etwProviderId="{f18839f5-27ff-4e66-bd2d-639b768cf18b}"/>
    </system.serviceModel>    
    <system.serviceModel.activation>
        <net.tcp listenBacklog="10" maxPendingConnections="100" maxPendingAccepts="2" receiveTimeout="00:00:10" teredoEnabled="false">
            <allowAccounts>
                <add securityIdentifier="S-1-5-18"/>
                <add securityIdentifier="S-1-5-19"/>
                <add securityIdentifier="S-1-5-20"/>
                <add securityIdentifier="S-1-5-32-544" />
                <add securityIdentifier="S-1-5-32-568"/>
                <add securityIdentifier="S-1-5-6"/>
            </allowAccounts>
        </net.tcp>
        <net.pipe maxPendingConnections="100" maxPendingAccepts="2" receiveTimeout="00:00:10">
            <allowAccounts>
                <add securityIdentifier="S-1-5-18"/>
                <add securityIdentifier="S-1-5-19"/>
                <add securityIdentifier="S-1-5-20"/>
                <add securityIdentifier="S-1-5-32-544" />
                <add securityIdentifier="S-1-5-32-568"/>
                <add securityIdentifier="S-1-5-6"/>
            </allowAccounts>
        </net.pipe>
        <diagnostics performanceCountersEnabled="true" />
    </system.serviceModel.activation>
</configuration>'

# Set NetTcpPortSharing service
    $Message = "Configuring startup type for service NetTcpPortSharing to Automatic and starting service...`n"
    Write-Host $Message -ForegroundColor Green
    Set-Service NetTcpPortSharing -StartupType Automatic
    Start-Service -Name NetTcpPortSharing 

# Add NetTcpPortSharing dependency to NAV/BC services.
    $Computer = 'localhost'
    $Message = "`nAdding dependency NetTcpPortSharing to installed Business Central Services..."
    Write-Host $Message -ForegroundColor Green
    Get-Service -name MicrosoftDynamicsNavServer* | ForEach-Object {
        $Service = $_.Name
        $Command = 'sc.exe \\{0} config "{1}" depend=NetTcpPortSharing/HTTP' -f $Computer, $Service
        $Command = $Command.Replace('$','`$')
        $Output  = Invoke-Expression -Command $Command -ErrorAction Stop
        if($LastExitCode -ne 0){
            $ErrorMessage = "{0} : Failed to set {1} TcpPortSharing. More details: {2}" -f $Computer, $Service, $Output
            Write-Error $ErrorMessage
            continue
        }
        $Message = "  Dependency TcpPortSharing is configured for service: '{0}'" -f $Service
        Write-Host $Message
    }

