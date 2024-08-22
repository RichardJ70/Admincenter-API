# Script to only publish (not sync or install) all apps in a folder in a 4PS Construct Business Central database.

$BCVersion      = '200' # Business Central version, i.e. '150' or '160' or '170'.
$ServerInstance = 'BC210Empty' # Name of the NST and therefore also the name of the Key file.
$AppsFolder     = 'C:\Install\4PS\4PSNL_Winter_22-06_-_21.24.23132.2\Software\Extensions\' # Make sure this path ends with \

Import-Module "C:\Program Files\Microsoft Dynamics 365 Business Central\$BCVersion\Service\NavAdminTool.ps1"

Get-ChildItem -Path $AppsFolder | ForEach-Object {
    $AppPath = '{0}{1}' -f $AppsFolder, $_.Name
    Publish-NAVApp -ServerInstance $ServerInstance -Path $AppPath -SkipVerification
}