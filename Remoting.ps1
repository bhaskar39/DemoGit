New-Item -Name Hello -Path C:\ -ItemType Directory | Out-Null
Set-Content -Value "Hello" -Path C:\Hello\ 

$a = New-PSSession -ComputerName 13.68.109.96 -Credential (Get-Credential)

$aab = Invoke-Command -ComputerName 13.68.109.96 -Credential (Get-Credential) -ScriptBlock {
    Get-Process
    $obj = New-Object System.Net.WebClient
    $url = "http://www.7-zip.org/a/7z1701-x64.exe"
    $filepath = "C:\Users\ebabula\Documents\7zip.exe"
    $obj.DownloadFile($url,$filepath)
}



