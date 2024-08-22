# Script to import NAV/BC admin module
# Created by 4PS-MB / DKMV4PS

if (!$Version) {
  $title     = 'BC version?'
  $question  = 'What version of Business Central are you using?'
  $choices   = '&NAV2015', '&NAV2016', '&NAV2017', '&BC14', '&BC15', '&BC16', '&BC17', '&BC18', '&BC19', '&BC20', '&BC21', '&BC22', '&BC23'
  $decision  = $Host.UI.PromptForChoice($title, $question, $choices, 0)
  if ($decision -eq 0) { $Version = '80' }
  if ($decision -eq 1) { $Version = '90' }
  if ($decision -eq 2) { $Version = '100' }
  if ($decision -eq 3) { $Version = '140' }
  if ($decision -eq 4) { $Version = '150' }
  if ($decision -eq 5) { $Version = '160' }
  if ($decision -eq 6) { $Version = '170' }
  if ($decision -eq 7) { $Version = '180' }
  if ($decision -eq 8) { $Version = '190' }
  if ($decision -eq 9) { $Version = '200' }
  if ($decision -eq 10) { $Version = '210' }
  if ($decision -eq 11) { $Version = '220' }
  if ($decision -eq 12) { $Version = '230' }

}

switch ($Version)
{
    '80' {$Platform = 'NAV'}
    '90' {$Platform = 'NAV'}
    '100' {$Platform = 'NAV'}
    '140' {$Platform = 'BC'}
    '150' {$Platform = 'BC'}
    '160' {$Platform = 'BC'}
    '170' {$Platform = 'BC'}
    '180' {$Platform = 'BC'}
    '190' {$Platform = 'BC'}
    '200' {$Platform = 'BC'}
    '210' {$Platform = 'BC'}
    '220' {$Platform = 'BC'}
    '230' {$Platform = 'BC'}
}

if ($Platform -eq 'NAV') { Import-Module "C:\Program Files\Microsoft Dynamics NAV\$Version\Service\NavAdminTool.ps1" }
if ($Platform -eq 'BC') { Import-Module "C:\Program Files\Microsoft Dynamics 365 Business Central\$Version\Service\NavAdminTool.ps1" }
