Param
(
    $gitrepo,
    $branch
)

# Replace the following URL with a public GitHub repo URL
#$gitrepo="https://github.com/Azure-Samples/app-service-web-dotnet-get-started.git"
#$webappname="Testapptest1"
#$location="East US"

$rgName = Get-Content .\rg.txt
$WebAppsStr = Get-Content .\ids.txt
$WebApps = $WebAppsStr.Trim().Split(",")

foreach($Webapp in $WebApps)
{ 
    $WebAppName = (Split-Path $Webapp -Leaf).Trim()
    $WebAppdetails = Get-AzureRmWebApp -Name $WebAppName -ResourceGroupName $rgName
    # Configure GitHub deployment from your GitHub repo and deploy once.
    $PropertiesObject = @{
        repoUrl = "$gitrepo";
        branch = "$branch";
        isManualIntegration = "true";
    }
    $outData = Set-AzureRmResource -PropertyObject $PropertiesObject -ResourceGroupName $rgName -ResourceType Microsoft.Web/sites/sourcecontrols -ResourceName $WebAppName/web -ApiVersion 2015-08-01 -Force
}
