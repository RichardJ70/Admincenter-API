
$apps = "https://businesscentralapps.azureedge.net/githubhelloworld/latest/apps.zip"
Publish-PerTenantExtensionApps `
    -bcAuthContext $authContext `
    -environment $environment `
    -appFiles $apps