#$installerPath = "$deployPath\SecurityTools"

function Install-SymantecAgent([string]$nodeName,[string]$installerPath,[pscredential]$installCreds)
{
   #$installerPath = "$deployPath\SecurityTools"
   #Write-Verbose "Begin : Install-SymantecAgent - $nodeName"
   Write-Output "Begin : Install-SymantecAgent - $nodeName"
   #Test-PendingReboot -nodeName $nodeName
   $InstallerName = "7z1701-x64.msi"
   $FilePath = "{0}\{1}" -f $installerPath, $InstallerName
   Write-Output $installerPath
   Write-Output $FilePath
   #[Version]$InstallerVersion = (Get-MsiProductVersion -Path $FilePath -nodeName $nodeName)[2].toString()

   $result = Invoke-Command -ComputerName $nodeName -Credential $installCreds -ScriptBlock `
   {
       $VerbosePreference=$using:VerbosePreference
       $prop = $null
       $prop = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |  Where-Object{$_.DisplayName -eq "7-Zip 17.01 (x64 edition)"}
       if($prop -eq $null)
       {
               Write-Output "Installing Symantec Agent on $env:COMPUTERNAME"
               $FilePath = "cmd.exe" -f $using:installerPath
               Write-Output $using:installerPath
               Write-Output $FilePath
               $ArgumentList = "/c start /wait msiexec.exe /qn /log setup.log /i $using:InstallerName"
               Write-Output $ArgumentList
               Start-Process -FilePath $FilePath -WorkingDirectory $using:installerPath -ArgumentList $ArgumentList -Verb RunAs -Wait
       }
      <# elseif ([System.Version]$prop.DisplayVersion -ge $using:InstallerVersion)
       {
               Write-Verbose ("    Varian ARIA DICOM Services {0} already installed on $env:COMPUTERNAME" -f $prop.DisplayVersion) 
       }
       elseif ([System.Version]$prop.DisplayVersion -lt $using:InstallerVersion) 
       {
               Write-Verbose "    Upgrading Varian ARIA DICOM Services on $env:COMPUTERNAME"
               $FilePath = "cmd.exe" -f $using:installerPath
               $ArgumentList = "/c start /wait msiexec.exe /qn /log setup.log /i $using:InstallerName"
               Start-Process -FilePath $FilePath -WorkingDirectory $using:installerPath -ArgumentList $ArgumentList -Verb RunAs -Wait
       }#>


   }
   Write-Output $result
}