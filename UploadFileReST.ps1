$accountname="271725southindia"

$key = "AgIs1pPag7pEOZzk2uJpXRsPt79ea+qILJkGfmdZnXL+eTpUUYytQfHde3elF+Wo5TB+1JaCD5w3is4mTBxjZA=="

$container="reports"

#file to create

$blkblob="NSGReport.csv"

$f = ".\NSGReport.csv"

$BlobOperation = "PUT"

$body = (Get-Content -Path $f -Raw)

$filelen = $body.Length

#added this per comments in the below blog post.

$filelen = (Get-ChildItem -File $f).Length

$RESTAPI_URL = "https://$accountname.blob.core.windows.net/$container/$blkblob";

$date=(Get-Date).ToUniversalTime()

$datestr=$date.ToString("R");

$datestr2=$date.ToString("s")+"Z";

$strtosign = "$BlobOperation`n`n`n$filelen`n`n`n`n`n`n`n`n`nx-ms-blob-type:BlockBlob`nx-ms-date:$datestr`nx-ms-version:2015-02-21`n/"

$strtosign = $strtosign + $accountname + "/"

$strtosign = $strtosign + $container

$strtosign = $strtosign + "/" +$blkblob

 

write-host $strtosign

 

[byte[]]$dataBytes = ([System.Text.Encoding]::UTF8).GetBytes($strtosign)

$hmacsha256 = New-Object System.Security.Cryptography.HMACSHA256

$hmacsha256.Key = [Convert]::FromBase64String($key)

$sig = [Convert]::ToBase64String($hmacsha256.ComputeHash($dataBytes))

$authhdr = "SharedKey $accountname`:$sig"

 

write-host $authhdr

 

$RequestHeader = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"

 

$RequestHeader.Add("Authorization", $authhdr)

$RequestHeader.Add("x-ms-date", $datestr)

$RequestHeader.Add("x-ms-version", "2015-02-21")

$RequestHeader.Add("x-ms-blob-type","BlockBlob")

 

#create a new PS object to hold the response JSON

$RESTResponse = New-Object PSObject;

$RESTResponse = (Invoke-RestMethod -Uri $RESTAPI_URL -Method put -Headers $RequestHeader -InFile $f);

 

write-host $RESTResponse

write-host "# Success !!! uploaded the file >>" $RESTAPI_URL