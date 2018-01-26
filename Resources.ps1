
$UserName = "bhaskar.desharaju@netenrich.com"
$Password = "Rama123<"
$SecurePassword = ConvertTo-SecureString -AsPlainText -String $Password -Force
$creds = New-Object System.Management.Automation.PSCredential ($UserName,$SecurePassword)

$null = Login-AzureRmAccount -Credential $creds -SubscriptionId 'ca68598c-ecc3-4abc-b7a2-1ecef33f278d'

$Subscriptions = Get-AzureRMSubscription

$Allresources = New-Object System.Collections.ArrayList
foreach($Sub in $Subscriptions)
{
    try
    {
        $null = Select-AzureRmSubscription -SubscriptionId $Sub.Id

        $Resources = Get-AzureRmResource
        foreach($res in $Resources)
        {
            if(($res.ResourceType -notmatch 'Microsoft.Automation/automationAccounts/runbooks') -and ($res.ResourceType -notmatch 'microsoft.insights/*') -and ($res.ResourceType -notmatch 'Microsoft.OperationsManagement/*') -and ($res.ResourceType -notmatch 'Microsoft.Compute/virtualMachines/extensions'))
            {
                $Allresources += $res | Select Name,ResourceId,Location,ResourceType,SubscriptionId
            }
        }
    }
    catch
    {
        # Do nothing
    }
}
[DateTime]$LTime = Get-Date
$TimeSt = $LTime.ToString("dd-MMM-yyyy_HHmmss")
$FileName = "Resources-$TimeSt"
$PSScriptRoot = Split-Path -Path $MyInvocation.MyCommand.Definition
$null = $Allresources | Export-Csv -Path "$PSScriptRoot\$FileName.csv" -NoTypeInformation -Force

# Uploading to S3 bucket
Write-S3Object -BucketName 'azuetoaws' -File "$PSScriptRoot\$FileName.csv" -AccessKey AKIAJ2DA75SBGR7JOP4A -SecretKey 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 -Region us-west-1 -Force