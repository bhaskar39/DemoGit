# Step-1--Manually
$credential = Get-Credential
$credential.Password | ConvertFrom-SecureString | Set-Content c:\encrypted_password1.txt

# Step-2 --Script
$emailusername = "bhaskar.desharaju@netenrich.com"
$encrypted = Get-Content c:\encrypted_password1.txt | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PsCredential($emailusername, $encrypted)

$null = login-azurermaccount -Credential $credential -Verbose