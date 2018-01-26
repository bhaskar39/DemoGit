# To pull the data from Azure for VM Sizes
# This is for testing
$AppSecretKey = "m96Ga2Qy4nY7XIJcOn8W4yV+HltiTUT2Kl7HuPhgs3E="
$ClientID = "4236a630-c8fb-49c7-b17d-c218ecb12823"
$TenantID = "39058880-0de6-4acb-972d-ca47c32b0163"
$SubscriptionID = "24c4f82b-324c-4ddd-9ea2-53bea8701c36"

Function New-AzureRestAuthorizationHeader 
{ 
    [CmdletBinding()] 
    Param 
    ( 
        [String]$ClientId, 
        [String]$ClientKey, 
        [String]$TenantId
    ) 

    try
    {
        # Import ADAL library to acquire access token 
        # $PSScriptRoot only work PowerShell V3 or above versions 
        Add-Type -Path "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.dll" 
        Add-Type -Path "${env:ProgramFiles(x86)}\Microsoft SDKs\Azure\PowerShell\ServiceManagement\Azure\Services\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll" 

        # Authorization & resource Url 
        $authUrl = "https://login.windows.net/$TenantId/" 
        $resource = "https://management.core.windows.net/" 

        # Create credential for client application 
        $clientCred = [Microsoft.IdentityModel.Clients.ActiveDirectory.ClientCredential]::new($ClientId, $ClientKey) 

        # Create AuthenticationContext for acquiring token 
        $authContext = [Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext]::new($authUrl, $false) 

        # Acquire the authentication result 
        $authResult = $authContext.AcquireTokenAsync($resource, $clientCred).Result 

        # Compose the access token type and access token for authorization header 
        $authHeader = $authResult.AccessTokenType + " " + $authResult.AccessToken 

        # the final header hash table 
        return @{"Authorization"=$authHeader; "Content-Type"="application/json"}
    }
    catch
    {
        Write-Output "There was an error in fetching the AccessToken from Azure. $($Error[0].Exception.Message)"
    }
}

$WebappName = "testdemo-webapp"
$rgname = "mysql"
$ServerName = "demomysqltest"
$RuleName = "Webappdemo"

$WebSite = Get-AzureRmWebApp -Name $WebappName -ResourceGroupName $rgname
$Site = $WebSite.DefaultHostName
$netdata = Invoke-Expression -Command "ping $Site -n 1"
$IPAddress = ($netdata[1].Split("[")).Split("]")[1]

$RBody = @"
{
  "properties": {
    "startIpAddress": "$IPAddress",
    "endIpAddress": "$IPAddress"
  }
}
"@


$Headers = New-AzureRestAuthorizationHeader -ClientId $ClientID -ClientKey $AppSecretKey -TenantId $TenantID
$Uri = "https://management.azure.com/subscriptions/$SubscriptionID/resourceGroups/$rgname/providers/Microsoft.DBforMySQL/servers/$ServerName/firewallRules/$($RuleName)?api-version=2017-04-30-preview"

Invoke-RestMethod -Method Put -Uri $Uri -Body $RBody -Headers $Headers


