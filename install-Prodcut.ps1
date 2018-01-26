Param
(
    $quality = "fs2demo",
    $ServerName = $quality+'tbox'+".example.com",
    $UserName = "fsedev",
    $Password = "xyz123#"
)

$Creds = New-Object System.Management.Automation.PSCredential ($UserName,(ConvertTo-SecureString -String $Password -AsPlainText -Force))

. 'F:\NetEnrich\Projects\Azure R&D\Install-Agent.ps1'

Install-SymanticAgent -DisplayName "" -DisplayVersion "" -hostNameorIPAddress "" -hostName "" -targetVM fs2demo.example.com -provisioningAPIKey "" -Creds $Creds

