#$gitdirectory="<Replace with path to local Git repo>"
$rgName = Get-Content .\rg.txt
$WebAppsStr = Get-Content .\ids.txt
$WebApps = $WebAppsStr.Trim().Split(",")


foreach($Webapp in $WebApps)
{ 
    #$location="East US"
    $webappname = $Webapp.Name
    # Configure GitHub deployment from your GitHub repo and deploy once.
    $PropertiesObject = @{
        scmType = "LocalGit";
    }
    Set-AzureRmResource -PropertyObject $PropertiesObject -ResourceGroupName $rgName -ResourceType Microsoft.Web/sites/config -ResourceName $webappname/web -ApiVersion 2015-08-01 -Force | Out-Null

    # Get app-level deployment credentials
    $xml = [xml](Get-AzureRmWebAppPublishingProfile -Name $webappname -ResourceGroupName $rgName -OutputFile null)
    $username = $xml.SelectNodes("//publishProfile[@publishMethod=`"MSDeploy`"]/@userName").value
    $password = $xml.SelectNodes("//publishProfile[@publishMethod=`"MSDeploy`"]/@userPWD").value

    Set-Content -Value "https://${username}:$password@$webappname.scm.azurewebsites.net" -Path .\gitFile.txt | Out-Null

    # Add the Azure remote to your local Git respository and push your code
    #### This method saves your password in the git remote. You can use a Git credential manager to secure your password instead.
    #git remote add azure "https://${username}:$password@$webappname.scm.azurewebsites.net"
    #git push azure master
}