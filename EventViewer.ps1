### Install NewRelic Extension for Azure App###
write-output "*** Installing New Relic on PROD Site"
$WebSite = "testsite-arm"
$Kudu = "https://" + $WebSite + ".scm.azurewebsites.net/api/extensionfeed" # Here you can get a list for all Extensions available.
$InstallNRURI = "https://" + $WebSite + ".scm.azurewebsites.net/api/siteextensions" # Install API EndPoint

$username = '$testsite-arm'
$password = "2eT7vdzvoNnZTHcM8wa4oHb8GBfpgqXzBuGomW5LSr9rGBy4DyEdYbssLbh6"
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username,$password)))

$invoke = Invoke-RestMethod -Uri $Kudu -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Method get ###-InFile $filePath -ContentType "multipart/form-data"

$id = (($invoke | ? {$_.id -match "websitelogs*"}).id)  ### Searching for NewRelic ID Extension

try 
{
    $InstallNewRelic = Invoke-RestMethod -Uri "$InstallNRURI/$id" -Headers @{Authorization=("Basic {0}" -f $base64AuthInfo)} -Method Put
    $Status = ($InstallNewRelic.provisioningState).ToString() + "|" + ($InstallNewRelic.installed_date_time).ToString()  ### Status
    Write-Output "NewRelic Installation Status : $Status"
    Restart-AzureRmWebApp -ResourceGroupName Automation-bhaskar -Name $WebSite -Verbose ### Restarting the WebApp
}
catch{$_}