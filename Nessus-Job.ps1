 PARAM(   
    [Parameter(Mandatory=$True)]
    [string]$nName,
    [string]$nTarget,
    [string]$nemail
    )

$vPolicyId = "put-your-policyID"
$vFolderId = "put-your-nessus-folderID"

Remove-NessusSession 0

# $ErrorActionPreference = "SilentlyContinue" # This is a without hardcode error msg.

# Credentials

$password = ConvertTo-SecureString "put-your-nessus-password" -AsPlainText -Force
$Cred = New-Object System.Management.Automation.PSCredential ("put-your-nessus-username", $password)

# Create a SessionId:

$nns = New-NessusSession -ComputerName "put-your-nessus-ip" -Credentials $Cred

# Create a Scan

$newscan = (New-NessusScan -SessionId $($nns.SessionId) -Enabled 0 -Name $nName -Target $nTarget -PolicyId $nPolicyId -FolderId $nFolderId)

Start-NessusScan -SessionId $($nns.SessionId) -ScanId $($newscan.ScanId)

Write-Host "[IFNO]: ScanId - $($newscan.ScanId)" -ForegroundColor Cyan
Write-Host "[IFNO]: SessionId - $($nns.SessionId)" -ForegroundColor Cyan

#Start-Sleep -s 35

while( (Get-NessusScan -SessionId $($nns.SessionId) -FolderId $nFolderId -Status Running).ScanId -eq $($newscan.ScanId)){
    Write-Host "[INFO]: Running..." -ForegroundColor Cyan
    Start-Sleep -Seconds 30
} Write-Host "[WORKING]: Running the report prepare action." -ForegroundColor Yellow

Export-NessusScan -SessionId $($nns.SessionId) -ScanId $($newscan.ScanId) -Format HTML -Chapters Vuln_By_Host -OutFile C:\inetpub\wwwroot\report\$nName.html
Export-NessusScan -SessionId $($nns.SessionId) -ScanId $($newscan.ScanId) -Format CSV -OutFile C:\inetpub\wwwroot\report\csv\$nName.csv

# Email


$password = ConvertTo-SecureString "put-your-email-password" -AsPlainText -Force
$EmailCred = New-Object System.Management.Automation.PSCredential ("pur-your-email", $password)
$From = ""
$Cc = ""
$Subject = "$nName Results of $nTarget"
$Attachment = "C:\inetpub\wwwroot\report\csv\$nName.csv"
$Body=@"
<html>
<meta charset="utf-8">
<p style="text-align: center;">Hello, Your <strong>$nName</strong> requested <strong>$vTarget</strong> IP results are completed.</p>
<p style="text-align: center;">You can see attachment or link below.</p>
<p style="text-align: center;">&nbsp;</p>
<p style="text-align: center;"><a href="https://put-your-url/report/$nName.html"> <button style="padding: 15px; text-align: center; background-color: #008cba; border: none; color: white;">Please in here! </button></a></p>
<p style="text-align: center;">&nbsp;</p>
</html>
"@

$SMTPServer = ""
$SMTPPort = ""
$To = "$email"
$Attachment = "C:\inetpub\wwwroot\report\csv\$vName.csv"

# Send to Email Report

Send-MailMessage -From $From -to $To -Cc $Cc -Subject $Subject -Body $Body -BodyAsHtml -SmtpServer $SMTPServer -Port $SMTPPort -Credential $EmailCred -Encoding UTF8 -Attachments $Attachment

Write-Host "[Success]: The report file already exists. If you cannot see the correct results. Please contact to System Administrators" -ForegroundColor Green

Write-Host "[INFO] ScanId - $($newscan.ScanId)"  -ForegroundColor Cyan
Write-Host "[INFO] SessionId - $($ss.SessionId)" -ForegroundColor Cyan




Remove-NessusSession $($ss.SessionId)
