# Install Security Tools
Function Install-SymanticAgent
{
    Param
    (
        [string]$DisplayName,
        [string]$DisplayVersion,
        [string]$provisioningAPIKey,
        [String]$hostNameorIPAddress,
        [string]$targetVM,
        [string]$hostName,
        [int]$retryAttempts=5,
        [int]$retrySeconds=60, 
        [pscredential]$Creds
    )

    $deployPath = "C:\Deploy"
    #if condition for 
    if($DisplayName -eq "Symantec Endpoint Protection")
    {
        $installerPath = "$deployPath\SymantecAgents\al_log_syslog-LATEST.msi"   # file name.msi
    }

    if($DisplayName -eq "Traps 4.0.4.27872")
    {
        $installerPath = "$deployPath\Traps\Traps_x64_4.0.4.27872.msi"
    }

    $VerbosePreference=continue

    $data = Invoke-Command -ComputerName $targetVM -Credential $Creds -ScriptBlock {
    #Install software

        function checkSoftware 
        {
            $softwares = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
            $global:availability=$softwares | %{Get-ItemProperty $_.PSPath | ?{$_.DisplayName -eq $using:DisplayName}}
            Write-Host ($global:availability)
        }

        #Calling checkSoftware function

        checkSoftware

        if(($global:availability -eq $null) -or ($global:availability.DisplayVersion -lt $using:DisplayVersion))
        {
            Write-Host("software is not installed in this computer")

            #If MSI file is accessible then it will enter to if loop 

            if(Test-Path $using:installerPath)
            {
               "MSI file is accessible from the directory "

                $cmdhash=@{}
                $cmdhash['FilePath']    = 'msiexec.exe'
                $cmdhash['Wait']        = $true
                $cmdhash['NoNewWindow'] = $true
                $cmdhash['ArgumentList']=@()
                $cmdhash['ArgumentList'] += '/qb'
                $cmdhash['ArgumentList'] += "/i "+$using:installerPath
                if($using:DisplayName -eq "Symantec Endpoint Protection")
                {
                    $cmdhash['ArgumentList'] +="prov_key="+$using:provisioningAPIKey
                    $cmdhash['ArgumentList'] += $using:hostNameorIPAddress
                }
                if($using:DisplayName -eq "Traps 4.0.4.27872")
                {
                    $cmdhash['ArgumentList'] +="CYVERA_SERVER="+$using:hostName
                }
                $status=Start-Process @cmdhash

                #If software installed successfully it will enter this loop
       
                if($?)
                {
                    checkSoftware
           	        "$($Global:availability.DisplayName)--$($Global:availability.DisplayVersion) has been installed"
                }
                else
                {   
                    "Unable to install the software"
                }
            }   
            else
   	        {
                " Unable to access the MSI file from directory"
   	        }
        }

        else
        {
            "software is already existing"
        }
    }
}