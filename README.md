The admin center API can be used to control everything in the admin center through powershell.
The files starting with 1. and 2. are used in de files starting with 3, 4, 5 and 6. The other files are for stand alone usage.

Use the 1. files for authentication. Either use BcContainerHelper with a device login or use standaard Microsoft S2S.
Use the 2. files to handle a single environment of multi environments in the same Microsoft tenant.
Use the 3. files to handle installation of global apps, app updates or uninstallation of global apps.
Use the 4. file to handle scheduling major or minor releases
Use the 5. files to set environment settings
Use the 6. files to handle enviroment actions

PTE - Pipelines is work in progress. With AL-GO, Git pipelines can be used, but not with a BC solution using a different application family, when the partner has not published a public package for their solution. If anyone knows a way to handle this with Git CI/CD please let me know. For now investigation is done to download all installed apps so merging can take place locally, using the script to download all the global (appsource) apps installed on the environment.