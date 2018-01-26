$subs = 'Pay-As-You-Go-Lab','NetEnrichLab-CSP'

foreach($s in $subs)
{
    $s
    Select-AzureRmSubscription $s | Out-Null

    $NICs = Get-AzureRmNetworkInterface | Where-Object {$_.VirtualMachine -eq $null}
    foreach($nic in $NICs)
    {
        $nic.Name
        Remove-AzureRmNetworkInterface -Name $nic.Name -ResourceGroupName $nic.ResourceGroupName -Force
    }

    $Pips = get-AzureRMPublicIPAddress | where-Object {$_.IpConfiguration -eq $null}
    foreach($pip in $Pips)
    {
        $pip.Name
        Remove-AzureRmPublicIpAddress -Name $pip.Name -ResourceGroupName $pip.ResourceGroupName -Force
    }

    $NSGs = Get-AzureRmNetworkSecurityGroup | Where-Object {$_.NetworkInterfaces.Count -eq 0 -and $_.Subnets.Count -eq 0}
    foreach($nsg in $NSGs)
    {
        $nsg.Name
        Remove-AzureRmNetworkSecurityGroup -Name $nsg.Name -ResourceGroupName $nsg.ResourceGroupName -Force
    }

}